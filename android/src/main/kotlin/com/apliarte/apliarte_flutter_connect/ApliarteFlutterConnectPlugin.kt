package com.apliarte.apliarte_flutter_connect

import android.os.Build
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** ApliarteFlutterConnectPlugin */
class ApliarteFlutterConnectPlugin : FlutterPlugin, MethodCallHandler {
    private var channel: MethodChannel? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(
            flutterPluginBinding.binaryMessenger,
            "com.apliarte.flutter_connect/methods"
        )
        channel?.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initialize" -> result.success(null)
            "getCapabilities" -> result.success(
                mapOf(
                    "platformName" to "android-${Build.VERSION.SDK_INT}",
                    "supportsDiscovery" to false,
                    "supportsAdvertising" to false,
                    "supportsLocalNetworkTransport" to false,
                    "supportsPermissionRequests" to false,
                    "supportedRoles" to listOf("host", "viewer")
                )
            )
            "checkPermissions", "requestPermissions" -> result.success(
                mapOf(
                    "useCase" to (call.argument<String>("useCase") ?: "discoveryOnly"),
                    "status" to "unknown",
                    "requiredPermissions" to listOf("localNetwork"),
                    "missingPermissions" to listOf("localNetwork"),
                    "canRequest" to false,
                    "message" to "Native permission mapping is not implemented yet."
                )
            )
            "startDiscovery", "stopDiscovery", "dispose" -> result.success(null)
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
    }
}
