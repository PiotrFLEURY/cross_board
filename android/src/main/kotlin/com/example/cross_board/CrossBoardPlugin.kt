package com.example.cross_board

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** CrossBoardPlugin */
class CrossBoardPlugin : FlutterPlugin, MethodCallHandler {

    companion object {
        const val CHANNEL_METHOD_REQUEST_PERMISSION = "requestPermission"
        const val CHANNEL_METHOD_COPY = "copy"
        const val CHANNEL_METHOD_PASTE = "paste"
    }

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    private lateinit var clipboardManager: ClipboardManager

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "cross_board")
        channel.setMethodCallHandler(this)
        clipboardManager =
            flutterPluginBinding.applicationContext.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            CHANNEL_METHOD_REQUEST_PERMISSION -> {
                requestPermission(result)
            }
            CHANNEL_METHOD_COPY -> {
                copy(call, result)
            }
            CHANNEL_METHOD_PASTE -> {
                paste(result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun requestPermission(result: Result) {
        result.success(true)
    }

    private fun copy(call: MethodCall, result: Result) {
        val text = call.arguments as String
        // Creates a new text clip to put on the clipboard
        val clip: ClipData = ClipData.newPlainText("cross_board_text", text)
        clipboardManager.setPrimaryClip(clip)
        result.success(Unit)
    }

    private fun paste(result: Result) {
        val text = clipboardManager.primaryClip?.getItemAt(0)?.text
        result.success(text ?: "")
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
