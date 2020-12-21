package com.gutlogic.app

import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

class AppleAuthChannel(messenger: BinaryMessenger) {
    val channel = MethodChannel(messenger, "com.gutlogic.app/apple")

    init {
        channel.setMethodCallHandler(::handle)
    }

    private fun handle(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "available") {
            result.success(false)
        } else {
            result.notImplemented()
        }
    }
}
