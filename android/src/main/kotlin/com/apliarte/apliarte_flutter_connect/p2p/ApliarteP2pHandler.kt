package com.apliarte.apliarte_flutter_connect.p2p

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.location.LocationManager
import android.net.NetworkInfo
import android.net.wifi.WifiManager
import android.net.wifi.WpsInfo
import android.net.wifi.p2p.*
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result

/**
 * ApliarteP2pHandler
 *
 * Manejador nativo robusto de Wi-Fi Direct P2P para Android.
 * Compatible nativamente con Android Gradle Plugin 8.x.
 * Protegido contra cierres inesperados en onDetachedFromActivity.
 */
class ApliarteP2pHandler(
    private val context: Context,
    private val messenger: BinaryMessenger
) : MethodChannel.MethodCallHandler {

    companion object {
        private const val TAG = "ApliarteP2P"
        const val METHOD_CHANNEL = "com.apliarte.flutter_connect/p2p"
        const val PEERS_CHANNEL = "com.apliarte.flutter_connect/p2p_peers"
        const val STATE_CHANNEL = "com.apliarte.flutter_connect/p2p_state"
        const val CONNECTION_CHANNEL = "com.apliarte.flutter_connect/p2p_connection"
    }

    private var methodChannel: MethodChannel = MethodChannel(messenger, METHOD_CHANNEL)
    private var peersEventChannel: EventChannel = EventChannel(messenger, PEERS_CHANNEL)
    private var stateEventChannel: EventChannel = EventChannel(messenger, STATE_CHANNEL)
    private var connectionEventChannel: EventChannel = EventChannel(messenger, CONNECTION_CHANNEL)

    var activity: Activity? = null

    private var wifiP2pManager: WifiP2pManager? = null
    private var wifiP2pChannel: WifiP2pManager.Channel? = null
    private var receiver: BroadcastReceiver? = null

    private var foundPeers: MutableList<String> = mutableListOf()
    private var wifiP2pEnabled: Boolean = false
    private var networkInfo: NetworkInfo? = null
    private var wifiP2pInfo: WifiP2pInfo? = null
    private var groupClients: String = "[]"

    init {
        methodChannel.setMethodCallHandler(this)
        peersEventChannel.setStreamHandler(FoundPeersStreamHandler)
        stateEventChannel.setStreamHandler(WifiP2pStateStreamHandler)
        connectionEventChannel.setStreamHandler(ConnectedPeersStreamHandler)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "initialize" -> initialize(result)
            "discover" -> discover(result)
            "stopDiscovery" -> stopDiscovery(result)
            "connect" -> {
                val address: String = call.argument("address") ?: ""
                connect(address, result)
            }
            "disconnect" -> disconnect(result)
            "createGroup" -> createGroup(result)
            "removeGroup" -> removeGroup(result)
            "groupInfo" -> requestGroupInfo(result)
            "fetchPeers" -> result.success(foundPeers)
            "checkLocationPermission" -> checkLocationPermission(result)
            "askLocationPermission" -> askLocationPermission(result)
            "checkLocationEnabled" -> checkLocationEnabled(result)
            "checkGpsEnabled" -> checkGpsEnabled(result)
            "enableLocationServices" -> enableLocationServices(result)
            "checkWifiEnabled" -> checkWifiEnabled(result)
            "enableWifiServices" -> enableWifiServices(result)
            else -> result.notImplemented()
        }
    }

    private fun initialize(result: Result) {
        try {
            wifiP2pManager = context.getSystemService(Context.WIFI_P2P_SERVICE) as? WifiP2pManager
            if (wifiP2pManager == null) {
                result.success(false)
                return
            }

            wifiP2pChannel = wifiP2pManager?.initialize(context, Looper.getMainLooper(), null)

            val intentFilter = IntentFilter().apply {
                addAction(WifiP2pManager.WIFI_P2P_STATE_CHANGED_ACTION)
                addAction(WifiP2pManager.WIFI_P2P_PEERS_CHANGED_ACTION)
                addAction(WifiP2pManager.WIFI_P2P_CONNECTION_CHANGED_ACTION)
                addAction(WifiP2pManager.WIFI_P2P_THIS_DEVICE_CHANGED_ACTION)
            }

            if (receiver != null) {
                try {
                    context.unregisterReceiver(receiver)
                } catch (_: Exception) {}
            }

            receiver = object : BroadcastReceiver() {
                override fun onReceive(ctx: Context, intent: Intent) {
                    when (intent.action) {
                        WifiP2pManager.WIFI_P2P_STATE_CHANGED_ACTION -> {
                            val state = intent.getIntExtra(WifiP2pManager.EXTRA_WIFI_STATE, -1)
                            wifiP2pEnabled = (state == WifiP2pManager.WIFI_P2P_STATE_ENABLED)
                        }
                        WifiP2pManager.WIFI_P2P_PEERS_CHANGED_ACTION -> {
                            requestPeersUpdate()
                        }
                        WifiP2pManager.WIFI_P2P_CONNECTION_CHANGED_ACTION -> {
                            @Suppress("DEPRECATION")
                            networkInfo = intent.getParcelableExtra(WifiP2pManager.EXTRA_NETWORK_INFO)
                            val mgr = wifiP2pManager
                            val ch = wifiP2pChannel
                            if (mgr != null && ch != null) {
                                mgr.requestConnectionInfo(ch) { info ->
                                    wifiP2pInfo = info
                                    if (info != null && info.groupFormed && info.isGroupOwner) {
                                        mgr.requestGroupInfo(ch) { group ->
                                            if (group != null) {
                                                val clientsList = mutableListOf<String>()
                                                for (client in group.clientList) {
                                                    clientsList.add(
                                                        "{\"deviceName\": \"${client.deviceName}\", \"deviceAddress\": \"${client.deviceAddress}\"}"
                                                    )
                                                }
                                                groupClients = clientsList.toString()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                context.registerReceiver(receiver, intentFilter, Context.RECEIVER_NOT_EXPORTED)
            } else {
                context.registerReceiver(receiver, intentFilter)
            }

            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Error initializing Wi-Fi P2P", e)
            result.error("INIT_ERROR", e.localizedMessage, null)
        }
    }

    private fun discover(result: Result) {
        val mgr = wifiP2pManager
        val ch = wifiP2pChannel
        if (mgr == null || ch == null) {
            result.success(false)
            return
        }

        mgr.discoverPeers(ch, object : WifiP2pManager.ActionListener {
            override fun onSuccess() {
                result.success(true)
            }
            override fun onFailure(reasonCode: Int) {
                Log.w(TAG, "discoverPeers failed with reason: $reasonCode")
                result.success(false)
            }
        })
    }

    private fun stopDiscovery(result: Result) {
        val mgr = wifiP2pManager
        val ch = wifiP2pChannel
        if (mgr == null || ch == null) {
            result.success(false)
            return
        }

        mgr.stopPeerDiscovery(ch, object : WifiP2pManager.ActionListener {
            override fun onSuccess() {
                result.success(true)
            }
            override fun onFailure(reasonCode: Int) {
                Log.w(TAG, "stopPeerDiscovery failed with reason: $reasonCode")
                result.success(false)
            }
        })
    }

    private fun connect(address: String, result: Result) {
        val mgr = wifiP2pManager
        val ch = wifiP2pChannel
        if (mgr == null || ch == null) {
            result.success(false)
            return
        }

        val config = WifiP2pConfig().apply {
            deviceAddress = address
            wps.setup = WpsInfo.PBC
        }

        mgr.connect(ch, config, object : WifiP2pManager.ActionListener {
            override fun onSuccess() {
                result.success(true)
            }
            override fun onFailure(reasonCode: Int) {
                Log.w(TAG, "connect failed with reason: $reasonCode")
                result.success(false)
            }
        })
    }

    private fun disconnect(result: Result) {
        val mgr = wifiP2pManager
        val ch = wifiP2pChannel
        if (mgr == null || ch == null) {
            result.success(false)
            return
        }

        mgr.cancelConnect(ch, object : WifiP2pManager.ActionListener {
            override fun onSuccess() {
                result.success(true)
            }
            override fun onFailure(reasonCode: Int) {
                result.success(false)
            }
        })
    }

    private fun createGroup(result: Result) {
        val mgr = wifiP2pManager
        val ch = wifiP2pChannel
        if (mgr == null || ch == null) {
            result.success(false)
            return
        }

        mgr.createGroup(ch, object : WifiP2pManager.ActionListener {
            override fun onSuccess() {
                result.success(true)
            }
            override fun onFailure(reasonCode: Int) {
                Log.w(TAG, "createGroup failed with reason: $reasonCode")
                result.success(false)
            }
        })
    }

    private fun removeGroup(result: Result) {
        val mgr = wifiP2pManager
        val ch = wifiP2pChannel
        if (mgr == null || ch == null) {
            result.success(false)
            return
        }

        mgr.removeGroup(ch, object : WifiP2pManager.ActionListener {
            override fun onSuccess() {
                result.success(true)
            }
            override fun onFailure(reasonCode: Int) {
                result.success(false)
            }
        })
    }

    private fun requestGroupInfo(result: Result) {
        val mgr = wifiP2pManager
        val ch = wifiP2pChannel
        if (mgr == null || ch == null) {
            result.success(null)
            return
        }

        mgr.requestGroupInfo(ch) { group ->
            if (group != null) {
                val clients = mutableListOf<String>()
                for (c in group.clientList) {
                    clients.add(
                        "{\"deviceName\": \"${c.deviceName}\", \"deviceAddress\": \"${c.deviceAddress}\"}"
                    )
                }
                result.success(
                    "{\"isGroupOwner\": ${group.isGroupOwner}, \"passPhrase\": \"${group.passphrase ?: ""}\", \"groupNetworkName\": \"${group.networkName ?: ""}\", \"clients\": $clients}"
                )
            } else {
                result.success(null)
            }
        }
    }

    private fun requestPeersUpdate() {
        val mgr = wifiP2pManager
        val ch = wifiP2pChannel
        if (mgr == null || ch == null) return

        mgr.requestPeers(ch) { peers ->
            val list = mutableListOf<String>()
            for (device in peers.deviceList) {
                list.add(
                    "{\"deviceName\": \"${device.deviceName}\", \"deviceAddress\": \"${device.deviceAddress}\", \"isGroupOwner\": ${device.isGroupOwner}, \"isServiceDiscoveryCapable\": ${device.isServiceDiscoveryCapable}, \"primaryDeviceType\": \"${device.primaryDeviceType ?: ""}\", \"secondaryDeviceType\": \"${device.secondaryDeviceType ?: ""}\", \"status\": ${device.status}}"
                )
            }
            foundPeers = list
        }
    }

    private fun checkLocationPermission(result: Result) {
        val fine = context.checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED
        val coarse = context.checkSelfPermission(Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED
        result.success(fine && coarse)
    }

    private fun askLocationPermission(result: Result) {
        val act = activity
        if (act != null) {
            val perms = arrayOf(Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.ACCESS_COARSE_LOCATION)
            act.requestPermissions(perms, 2468)
            result.success(true)
        } else {
            result.success(false)
        }
    }

    private fun checkLocationEnabled(result: Result) {
        val lm = context.getSystemService(Context.LOCATION_SERVICE) as? LocationManager
        result.success(lm?.isLocationEnabled ?: false)
    }

    private fun checkGpsEnabled(result: Result) {
        val lm = context.getSystemService(Context.LOCATION_SERVICE) as? LocationManager
        val gps = lm?.isProviderEnabled(LocationManager.GPS_PROVIDER) ?: false
        val net = lm?.isProviderEnabled(LocationManager.NETWORK_PROVIDER) ?: false
        result.success(gps && net)
    }

    private fun enableLocationServices(result: Result) {
        val act = activity
        if (act != null) {
            act.startActivity(Intent(android.provider.Settings.ACTION_LOCATION_SOURCE_SETTINGS))
            result.success(true)
        } else {
            result.success(false)
        }
    }

    private fun checkWifiEnabled(result: Result) {
        val wm = context.applicationContext.getSystemService(Context.WIFI_SERVICE) as? WifiManager
        result.success(wm?.isWifiEnabled ?: false)
    }

    private fun enableWifiServices(result: Result) {
        val act = activity
        if (act != null) {
            act.startActivity(Intent(android.provider.Settings.ACTION_WIFI_SETTINGS))
            result.success(true)
        } else {
            result.success(false)
        }
    }

    fun dispose() {
        methodChannel.setMethodCallHandler(null)
        peersEventChannel.setStreamHandler(null)
        stateEventChannel.setStreamHandler(null)
        connectionEventChannel.setStreamHandler(null)
        if (receiver != null) {
            try {
                context.unregisterReceiver(receiver)
            } catch (_: Exception) {}
            receiver = null
        }
    }

    private val FoundPeersStreamHandler = object : EventChannel.StreamHandler {
        private var handler = Handler(Looper.getMainLooper())
        private var eventSink: EventChannel.EventSink? = null

        override fun onListen(p0: Any?, sink: EventChannel.EventSink) {
            eventSink = sink
            val r = object : Runnable {
                override fun run() {
                    eventSink?.success(foundPeers)
                    handler.postDelayed(this, 1000)
                }
            }
            handler.postDelayed(r, 1000)
        }

        override fun onCancel(p0: Any?) {
            eventSink = null
        }
    }

    private val WifiP2pStateStreamHandler = object : EventChannel.StreamHandler {
        private var handler = Handler(Looper.getMainLooper())
        private var eventSink: EventChannel.EventSink? = null

        override fun onListen(p0: Any?, sink: EventChannel.EventSink) {
            eventSink = sink
            val r = object : Runnable {
                override fun run() {
                    eventSink?.success(wifiP2pEnabled)
                    handler.postDelayed(this, 1000)
                }
            }
            handler.postDelayed(r, 1000)
        }

        override fun onCancel(p0: Any?) {
            eventSink = null
        }
    }

    private val ConnectedPeersStreamHandler = object : EventChannel.StreamHandler {
        private var handler = Handler(Looper.getMainLooper())
        private var eventSink: EventChannel.EventSink? = null

        override fun onListen(p0: Any?, sink: EventChannel.EventSink) {
            eventSink = sink
            val r = object : Runnable {
                override fun run() {
                    val ni = networkInfo
                    val wi = wifiP2pInfo
                    if (ni != null && wi != null && ni.isConnected && wi.groupFormed) {
                        eventSink?.success("{\"isConnected\": ${ni.isConnected}, \"isGroupOwner\": ${wi.isGroupOwner}, \"groupOwnerAddress\": \"${wi.groupOwnerAddress?.hostAddress ?: ""}\", \"groupFormed\": ${wi.groupFormed}, \"clients\": $groupClients}")
                    } else {
                        eventSink?.success("null")
                    }
                    handler.postDelayed(this, 1000)
                }
            }
            handler.postDelayed(r, 1000)
        }

        override fun onCancel(p0: Any?) {
            eventSink = null
        }
    }
}
