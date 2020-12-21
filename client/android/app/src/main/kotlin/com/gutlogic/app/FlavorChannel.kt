package com.gutlogic.app

import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

class FlavorChannel(messenger: BinaryMessenger) {
    val channel = MethodChannel(messenger, "com.gutlogic.app/flavor")

    init {
        channel.setMethodCallHandler(::handle)
    }

    private fun handle(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "get") {
            result.success(BuildConfig.FLAVOR)
        } else {
            result.notImplemented()
        }
    }
}
