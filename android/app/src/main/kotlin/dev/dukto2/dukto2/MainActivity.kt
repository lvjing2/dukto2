package dev.dukto2.dukto2

import android.content.Context
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun provideFlutterEngine(context: Context): FlutterEngine = DuktoRuntime.engine(context)
    override fun shouldDestroyEngineWithHost(): Boolean = false
    override fun configureFlutterEngine(engine: FlutterEngine) { DuktoRuntime.bridge?.attach(this) }
    override fun onResume() { super.onResume(); DuktoRuntime.visible = true; DuktoRuntime.bridge?.attach(this) }
    override fun onPause() { DuktoRuntime.visible = false; super.onPause() }
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        intent.getStringExtra("dukto2.request")?.let { DuktoRuntime.bridge?.event("backgroundRequestOpened", it) }
    }
    @Deprecated("Activity result bridge")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        DuktoRuntime.bridge?.onActivityResult(requestCode, resultCode, data)
    }
    override fun onRequestPermissionsResult(code: Int, permissions: Array<out String>, results: IntArray) {
        super.onRequestPermissionsResult(code, permissions, results)
        DuktoRuntime.bridge?.onRequestPermissionsResult(code, permissions, results)
    }
    override fun onDestroy() {
        DuktoRuntime.bridge?.detach(this)
        if (!isChangingConfigurations) DuktoRuntime.releaseIfUnused()
        super.onDestroy()
    }
}
