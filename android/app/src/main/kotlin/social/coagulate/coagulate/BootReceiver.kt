package social.coagulate.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED ||
            intent.action == Intent.ACTION_MY_PACKAGE_REPLACED
        ) {
            Log.d("BootReceiver", "Device booted / app updated – starting foreground service")

            val prefs = context.getSharedPreferences("reunicorn_prefs", Context.MODE_PRIVATE)
            val enabled = prefs.getBoolean("foreground_service_enabled", true)
            if (enabled) {
                ReunicornForegroundService.start(context)
            }
        }
    }
}
