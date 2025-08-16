package com.example.vision_x_flutter

import android.app.PictureInPictureParams
import android.content.res.Configuration
import android.util.Rational
import android.content.Intent
import android.content.Context
import android.os.Build
import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

class MainActivity : FlutterActivity() {
    private val CHANNEL = "samples.flutter.dev/pip"
    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "enterPipMode" -> enterPipMode(result)
                "isPipSupported" -> isPipSupported(result)
                else -> result.notImplemented()
            }
        }
    }

    private fun enterPipMode(result: Result) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && 
                this.packageManager.hasSystemFeature("android.software.picture_in_picture")) {
                
                val params = PictureInPictureParams.Builder()
                    .setAspectRatio(Rational(16, 9))
                    .build()
                    
                this.enterPictureInPictureMode(params)
                result.success(true)
            } else {
                result.success(false)
            }
        } catch (e: Exception) {
            result.error("PIP_ERROR", e.message, null)
        }
    }

    private fun isPipSupported(result: Result) {
        val supported = Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && 
                       this.packageManager.hasSystemFeature("android.software.picture_in_picture")
        result.success(supported)
    }

    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        // 可以在这里根据需要自动进入画中画模式
        // enterPipModeIfNeeded()
    }

    override fun onPictureInPictureModeChanged(
        isInPictureInPictureMode: Boolean, 
        newConfig: Configuration
    ) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
        
        // 通知Flutter端画中画模式变化
        methodChannel?.invokeMethod("onPipModeChanged", isInPictureInPictureMode)
    }
}