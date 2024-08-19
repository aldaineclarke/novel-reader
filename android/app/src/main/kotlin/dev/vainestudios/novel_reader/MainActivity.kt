package dev.vainestudios.babel_novel

import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.view.WindowManager

class MainActivity: FlutterActivity() {
    private val CHANNEL = "brightnessPlatform"
    private lateinit var layout: WindowManager.LayoutParams
    
    override fun onCreate(savedInstanceState: Bundle?){
        super.onCreate(savedInstanceState)
        layout = window.attributes
    }


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "setBrightness" -> {
                    val brightness = call.argument<Double>("brightness")
                    if (brightness != null) {
                        setBrightness(brightness.toFloat())
                        result.success(null)
                    } else {
                        result.error("ERROR", "Brightness value not found", null)
                    }
                }
                "getBrightness" -> {
                    val currentBrightness = window.attributes.screenBrightness
                    if (currentBrightness >= 0) {
                        result.success(currentBrightness.toString())
                    } else {
                        // Screen brightness is less than 0, meaning it is in auto-brightness mode
                        result.success("auto")
                    }
                }
                else -> result.notImplemented()
            }
        }
    }


    private fun setBrightness(brightness: Float) {
        val layoutParams = window.attributes
        layoutParams.screenBrightness = brightness
        window.attributes = layoutParams
    }
}
