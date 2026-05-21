package com.apliarte.apliarte_flutter_connect

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.mockito.Mockito
import kotlin.test.Test

internal class ApliarteFlutterConnectPluginTest {
    @Test
    fun onMethodCall_initialize_returnsSuccess() {
        val plugin = ApliarteFlutterConnectPlugin()
        val call = MethodCall("initialize", null)
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)

        plugin.onMethodCall(call, mockResult)

        Mockito.verify(mockResult).success(null)
    }
}
