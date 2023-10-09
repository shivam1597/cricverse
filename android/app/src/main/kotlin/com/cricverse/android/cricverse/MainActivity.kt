package com.cricverse.android.cricverse

import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() , MethodChannel.MethodCallHandler{

    private val CHANNEL = "cricverse/customChannel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Set up the method channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getVersion" -> {
                result.success(getAppVersion())
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun getAppVersion(): String {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val androidVersion = "Android ${Build.VERSION.RELEASE}" // Get the Android version name
                val apiLevel = "API level ${Build.VERSION.SDK_INT}" // Get the API level
                // Now you can use `androidVersion` and `apiLevel` as needed in your app.
                return androidVersion
            }
        }
        catch (e: PackageManager.NameNotFoundException) {
            e.printStackTrace()
        }
        return "N/A" // Return a default value in case of an error
    }
}
