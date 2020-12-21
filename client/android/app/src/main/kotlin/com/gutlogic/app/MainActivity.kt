package com.gutlogic.app

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(@NonNull engine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(engine)
        FlavorChannel(engine.dartExecutor.binaryMessenger)
        AppleAuthChannel(engine.dartExecutor.binaryMessenger)
    }
}
