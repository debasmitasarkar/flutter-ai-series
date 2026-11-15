package dev.debasmita.interop_bench

import android.os.Build
import android.os.Looper
import android.os.SystemClock
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // The platform-channel baseline: the same calls the JNIgen bindings make.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "bench")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "uptime" -> result.success(SystemClock.uptimeMillis())
                    "osVersion" -> result.success(Build.VERSION.RELEASE)
                    "isMainThread" -> result.success(Looper.myLooper() == Looper.getMainLooper())
                    else -> result.notImplemented()
                }
            }
    }
}
