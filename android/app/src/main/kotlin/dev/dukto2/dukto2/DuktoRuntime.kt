package dev.dukto2.dukto2

import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor

/** One engine/server, independent of Activity recreation; never boot-started. */
object DuktoRuntime {
    private var retained: FlutterEngine? = null
    var bridge: PlatformBridge? = null
        private set
    var visible = false
    private var stopping = false
    fun engine(context: Context): FlutterEngine {
        retained?.let { return it }
        val engine = FlutterEngine(context.applicationContext)
        retained = engine
        bridge = PlatformBridge(context).also { it.initialize(engine) }
        engine.dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())
        return engine
    }
    fun releaseIfUnused() {
        if (bridge?.hasActivity != true && !BackgroundReceiveService.active && TransferService.current == null) stop()
    }
    fun stop() {
        if (stopping) return
        val currentBridge = bridge ?: return
        stopping = true
        val old = retained
        currentBridge.shutdownRuntime {
            bridge?.close()
            bridge = null
            retained = null
            old?.destroy()
            stopping = false
        }
    }
}
