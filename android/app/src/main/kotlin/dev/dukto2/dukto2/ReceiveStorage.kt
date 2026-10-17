package dev.dukto2.dukto2

import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.os.Handler
import android.os.Looper
import android.os.ParcelFileDescriptor
import android.provider.DocumentsContract
import android.provider.MediaStore
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.io.BufferedOutputStream
import java.io.OutputStream
import java.util.concurrent.Executors

/** Owns only documents created for dukto2 transfers. No filesystem paths are
 * derived from content URIs, and no complete file crosses the platform channel. */
class ReceiveStorage(private val context: Context) {
    private val resolver = context.contentResolver
    private val prefs = context.getSharedPreferences("receive-storage", Context.MODE_PRIVATE)
    private val worker = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())
    private val stages = mutableMapOf<String, Stage>()
    private var recovered = false
    private data class Stage(val uri: Uri, val folder: Uri?, val media: Boolean,
                             val name: String, val size: Long, var output: OutputStream?,
                             var bytes: Long = 0)

    fun handle(call: MethodCall, result: MethodChannel.Result): Boolean {
        if (call.method !in setOf("receiveLocation", "prepareReceive", "writeReceive",
                "closeReceive", "commitReceive", "discardReceive", "openReceived")) return false
        worker.execute {
            try {
                recover()
                val value: Any? = when (call.method) {
                    "receiveLocation" -> location()
                    "prepareReceive" -> prepare(call.argument<String>("id")!!,
                        call.argument<String>("name")!!, call.argument<Number>("size")!!.toLong())
                    "writeReceive" -> {
                        val stage = stage(call)
                        val bytes = call.argument<ByteArray>("bytes")!!
                        require(bytes.size <= 256 * 1024) { "Write buffer too large" }
                        check(stage.bytes + bytes.size <= stage.size) { "File exceeds agreed size" }
                        checkNotNull(stage.output).write(bytes)
                        stage.bytes += bytes.size
                        null
                    }
                    "closeReceive" -> { close(stage(call)); null }
                    "commitReceive" -> commit(call.argument<String>("id")!!)
                    "discardReceive" -> { discard(call.argument<String>("id")!!); null }
                    "openReceived" -> {
                        val uriString = call.argument<String>("uri")!!
                        require(prefs.getStringSet("completed", emptySet())!!.contains(uriString)) { "Unknown received document" }
                        val uri = Uri.parse(uriString)
                        val intent = Intent(Intent.ACTION_VIEW).apply {
                            setDataAndType(uri, resolver.getType(uri) ?: "application/octet-stream")
                            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        context.startActivity(intent)
                        null
                    }
                    else -> null
                }
                main.post { result.success(value) }
            } catch (error: Exception) {
                main.post { result.error("STORAGE", error.message ?: "Cannot save received file", null) }
            }
        }
        return true
    }

    fun setFolder(uri: Uri, flags: Int, result: MethodChannel.Result) {
        worker.execute {
            try {
                val takeFlags = flags and (Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
                require(takeFlags and Intent.FLAG_GRANT_WRITE_URI_PERMISSION != 0) { "Folder is not writable" }
                resolver.takePersistableUriPermission(uri, takeFlags)
                val document = DocumentsContract.buildDocumentUriUsingTree(uri, DocumentsContract.getTreeDocumentId(uri))
                val capabilities = flagsOf(document)
                require(capabilities and DocumentsContract.Document.FLAG_DIR_SUPPORTS_CREATE != 0) { "Folder cannot create documents" }
                check(prefs.edit().putString("tree", uri.toString()).commit())
                main.post { result.success(location()) }
            } catch (error: Exception) {
                main.post { result.error("STORAGE", error.message, null) }
            }
        }
    }

    private fun location(): Map<String, Any> {
        val tree = prefs.getString("tree", null)
        if (tree != null) {
            val uri = Uri.parse(tree)
            val document = DocumentsContract.buildDocumentUriUsingTree(uri, DocumentsContract.getTreeDocumentId(uri))
            val name = try { displayName(document) } catch (_: Exception) { "已授权文件夹（请检查访问权限）" }
            return mapOf("direct" to true, "label" to name, "kind" to "folder")
        }
        return if (Build.VERSION.SDK_INT >= 29)
            mapOf("direct" to true, "label" to "下载 / dukto2", "kind" to "downloads")
        else mapOf("direct" to false, "label" to "应用内（可选择接收文件夹）", "kind" to "private")
    }

    private fun prepare(id: String, name: String, size: Long): Map<String, Any> {
        require(Regex("^[a-f0-9]{48}$").matches(id) && !stages.containsKey(id))
        require(name.isNotEmpty() && name.length <= 240 && name != "." && name != ".." &&
            !name.contains('/') && !name.contains('\\') && name.none { it.code < 32 })
        require(size >= 0)
        val treeString = prefs.getString("tree", null)
        val stage: Stage
        if (treeString == null && Build.VERSION.SDK_INT >= 29) {
            val values = ContentValues().apply {
                put(MediaStore.Downloads.DISPLAY_NAME, name)
                put(MediaStore.Downloads.MIME_TYPE, "application/octet-stream")
                put(MediaStore.Downloads.RELATIVE_PATH, "${Environment.DIRECTORY_DOWNLOADS}/dukto2")
                put(MediaStore.Downloads.IS_PENDING, 1)
            }
            val uri = checkNotNull(resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values))
            stage = Stage(uri, null, true, name, size, null)
        } else {
            require(treeString != null) { "请先选择接收文件夹" }
            val tree = Uri.parse(treeString)
            val parent = DocumentsContract.buildDocumentUriUsingTree(tree, DocumentsContract.getTreeDocumentId(tree))
            // A new private-to-this-transfer child folder prevents name collisions
            // without overwriting any document that existed before this offer.
            val folder = checkNotNull(DocumentsContract.createDocument(resolver, parent,
                DocumentsContract.Document.MIME_TYPE_DIR, "dukto2-$id"))
            val uri = try {
                checkNotNull(DocumentsContract.createDocument(resolver, folder, "application/octet-stream", ".dukto2-$id.partial"))
            } catch (error: Exception) {
                DocumentsContract.deleteDocument(resolver, folder)
                throw error
            }
            stage = Stage(uri, folder, false, name, size, null)
        }
        stages[id] = stage
        try {
            remember(id, stage)
            if (!stage.media) {
                val flags = flagsOf(stage.uri)
                require(flags and DocumentsContract.Document.FLAG_SUPPORTS_RENAME != 0 &&
                        flags and DocumentsContract.Document.FLAG_SUPPORTS_DELETE != 0) {
                    "此文件提供程序不支持安全提交，请选择本地可写文件夹"
                }
            }
            val descriptor = checkNotNull(resolver.openFileDescriptor(stage.uri, "w"))
            stage.output = BufferedOutputStream(ParcelFileDescriptor.AutoCloseOutputStream(descriptor), 256 * 1024)
            return mapOf("id" to id)
        } catch (error: Exception) {
            discard(id)
            throw error
        }
    }

    private fun stage(call: MethodCall): Stage = checkNotNull(stages[call.argument<String>("id")]) { "Receive target no longer exists" }

    private fun close(stage: Stage) {
        val output = stage.output
        stage.output = null
        output?.close()
    }

    private fun commit(id: String): Map<String, Any> {
        val stage = checkNotNull(stages[id])
        check(stage.output == null && stage.bytes == stage.size) { "Incomplete receive target" }
        val uri: Uri
        if (stage.media && Build.VERSION.SDK_INT >= 29) {
            val values = ContentValues().apply { put(MediaStore.Downloads.IS_PENDING, 0) }
            check(resolver.update(stage.uri, values, null, null) == 1) { "Cannot publish received file" }
            uri = stage.uri
        } else {
            // The folder was created for this transfer alone. Refuse to rename
            // over a file added there by the user while reception was running.
            val children = DocumentsContract.buildChildDocumentsUriUsingTree(stage.folder!!,
                DocumentsContract.getDocumentId(stage.folder))
            resolver.query(children, arrayOf(DocumentsContract.Document.COLUMN_DISPLAY_NAME), null, null, null)?.use { cursor ->
                while (cursor.moveToNext()) check(cursor.getString(0) != stage.name) { "Destination already exists" }
            }
            uri = checkNotNull(DocumentsContract.renameDocument(resolver, stage.uri, stage.name))
        }
        // Publishing is the commit point. After it, discard must never remove it,
        // even if saving history or delivering the reply subsequently fails.
        stages.remove(id)
        prefs.edit().remove("pending-$id").commit()
        val completed = prefs.getStringSet("completed", emptySet())!!.toMutableSet()
        completed.add(uri.toString())
        prefs.edit().putStringSet("completed", completed.toList().takeLast(100).toSet()).commit()
        return mapOf("uri" to uri.toString(), "name" to stage.name)
    }

    private fun remember(id: String, stage: Stage) {
        val record = JSONObject().apply {
            put("uri", stage.uri.toString()); put("folder", stage.folder?.toString())
            put("media", stage.media)
        }
        check(prefs.edit().putString("pending-$id", record.toString()).commit()) { "Cannot record pending file" }
    }

    private fun discard(id: String) {
        val stage = stages[id]
        if (stage != null) {
            try { close(stage) } finally { deletePending(stage.uri, stage.folder, stage.media, id) }
            stages.remove(id)
        } else {
            val recordString = prefs.getString("pending-$id", null)
            if (recordString != null) {
                val record = JSONObject(recordString)
                val folder = record.optString("folder").takeIf { it.isNotEmpty() && it != "null" }?.let(Uri::parse)
                deletePending(Uri.parse(record.getString("uri")), folder, record.getBoolean("media"), id)
            }
        }
        prefs.edit().remove("pending-$id").commit()
    }

    fun shutdown() {
        worker.execute {
            for (id in stages.keys.toList()) {
                try { discard(id) } catch (_: Exception) { /* Journal is kept for next launch. */ }
            }
        }
        worker.shutdown()
    }

    private fun deletePending(uri: Uri, folder: Uri?, media: Boolean, id: String) {
        if (media && Build.VERSION.SDK_INT >= 29) {
            resolver.query(uri, arrayOf(MediaStore.Downloads.IS_PENDING), null, null, null)?.use { cursor ->
                if (cursor.moveToFirst() && cursor.getInt(0) == 1) resolver.delete(uri, null, null)
            }
        } else {
            // A crash between rename/publication and journal cleanup must keep
            // the final document. Only our marked partials may be deleted.
            val name = try { displayName(uri) } catch (_: Exception) { null }
            if (name == ".dukto2-$id.partial") {
                DocumentsContract.deleteDocument(resolver, uri)
                if (folder != null) {
                    val children = DocumentsContract.buildChildDocumentsUriUsingTree(folder, DocumentsContract.getDocumentId(folder))
                    resolver.query(children, arrayOf(DocumentsContract.Document.COLUMN_DOCUMENT_ID), null, null, null)?.use {
                        if (it.count == 0) DocumentsContract.deleteDocument(resolver, folder)
                    }
                }
            }
        }
    }

    private fun recover() {
        if (recovered) return
        recovered = true
        for ((key, value) in prefs.all) {
            if (!key.startsWith("pending-") || value !is String) continue
            try {
                val record = JSONObject(value)
                val folder = record.optString("folder").takeIf { it.isNotEmpty() && it != "null" }?.let(Uri::parse)
                deletePending(Uri.parse(record.getString("uri")), folder, record.getBoolean("media"), key.removePrefix("pending-"))
                prefs.edit().remove(key).commit()
            } catch (_: Exception) {
                // A removed SD card/revoked grant can become accessible later.
                // Keep the journal entry; never delete unrelated documents.
            }
        }
    }

    private fun displayName(uri: Uri): String = resolver.query(uri,
        arrayOf(DocumentsContract.Document.COLUMN_DISPLAY_NAME), null, null, null)!!.use {
        check(it.moveToFirst()); it.getString(0)
    }

    private fun flagsOf(uri: Uri): Int = resolver.query(uri,
        arrayOf(DocumentsContract.Document.COLUMN_FLAGS), null, null, null)!!.use {
        check(it.moveToFirst()); it.getInt(0)
    }
}
