package com.apliarte.apliarte_flutter_connect

import android.os.Build
import com.apliarte.apliarte_flutter_connect.p2p.ApliarteP2pHandler
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** ApliarteFlutterConnectPlugin */
class ApliarteFlutterConnectPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private var channel: MethodChannel? = null
    private var p2pHandler: ApliarteP2pHandler? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(
            flutterPluginBinding.binaryMessenger,
            "com.apliarte.flutter_connect/methods"
        )
        channel?.setMethodCallHandler(this)

        p2pHandler = ApliarteP2pHandler(
            flutterPluginBinding.applicationContext,
            flutterPluginBinding.binaryMessenger
        )
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initialize" -> result.success(null)
            "getCapabilities" -> result.success(
                mapOf(
                    "platformName" to "android-${Build.VERSION.SDK_INT}",
                    "supportsDiscovery" to true,
                    "supportsAdvertising" to true,
                    "supportsLocalNetworkTransport" to true,
                    "supportsPermissionRequests" to true,
                    "supportedRoles" to listOf("host", "viewer")
                )
            )
            "checkPermissions", "requestPermissions" -> result.success(
                mapOf(
                    "useCase" to (call.argument<String>("useCase") ?: "discoveryOnly"),
                    "status" to "granted",
                    "requiredPermissions" to listOf("nearbyWifiDevices", "location"),
                    "missingPermissions" to emptyList<String>(),
                    "canRequest" to true,
                    "message" to "Native permissions managed."
                )
            )
            "startDiscovery", "stopDiscovery", "dispose" -> result.success(null)
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
        p2pHandler?.dispose()
        p2pHandler = null
    }

    /* ========================================================================= */
    /* ActivityAware - Blindaje total contra crashes en ciclo de vida de Android */
    /* ========================================================================= */

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        p2pHandler?.activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        // Safe no-op / cleanup para evitar el crash de 622 caídas/mes
        p2pHandler?.activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        p2pHandler?.activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        p2pHandler?.activity = null
    }
}
