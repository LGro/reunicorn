package social.coagulate.app

import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "social.coagulate.app/foreground_service"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                val prefs = getSharedPreferences("reunicorn_prefs", Context.MODE_PRIVATE)
                when (call.method) {
                    "startService" -> {
                        prefs.edit().putBoolean("foreground_service_enabled", true).apply()
                        ReunicornForegroundService.start(this)
                        result.success(true)
                    }
                    "stopService" -> {
                        prefs.edit().putBoolean("foreground_service_enabled", false).apply()
                        ReunicornForegroundService.stop(this)
                        result.success(true)
                    }
                    "isServiceEnabled" -> {
                        result.success(prefs.getBoolean("foreground_service_enabled", true))
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
