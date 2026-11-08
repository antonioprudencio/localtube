package com.localtube.app

import android.app.PictureInPictureParams
import android.content.res.Configuration
import android.os.Build
import android.util.Rational
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Atividade principal do LocalTube.
 *
 * Expõe ao Flutter (canal `com.localtube.app/system`):
 * - `enterPip(width, height)`: entra em Picture-in-Picture com a proporção do vídeo.
 * - `setAutoPip(bool)`: entra em PiP automaticamente ao sair do app com vídeo tocando.
 * E notifica `pipChanged(bool)` quando o modo PiP muda.
 */
class MainActivity : FlutterActivity() {
    private val channelName = "com.localtube.app/system"
    private var channel: MethodChannel? = null
    private var autoPip = false
    private var aspect = Rational(16, 9)

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "enterPip" -> {
                        val w = call.argument<Int>("width") ?: 16
                        val h = call.argument<Int>("height") ?: 9
                        updateAspect(w, h)
                        result.success(enterPip())
                    }
                    "sdkInt" -> result.success(Build.VERSION.SDK_INT)
                    "setAutoPip" -> {
                        autoPip = call.arguments as? Boolean ?: false
                        applyAutoEnter()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    private fun updateAspect(w: Int, h: Int) {
        if (w <= 0 || h <= 0) return
        // O Android limita a proporção do PiP entre 1:2.39 e 2.39:1.
        val ratio = w.toDouble() / h.toDouble()
        aspect = when {
            ratio > 2.39 -> Rational(239, 100)
            ratio < 1 / 2.39 -> Rational(100, 239)
            else -> Rational(w, h)
        }
    }

    private fun buildParams(): PictureInPictureParams? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return null
        val builder = PictureInPictureParams.Builder().setAspectRatio(aspect)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            builder.setAutoEnterEnabled(autoPip)
            builder.setSeamlessResizeEnabled(true)
        }
        return builder.build()
    }

    private fun applyAutoEnter() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            buildParams()?.let { setPictureInPictureParams(it) }
        }
    }

    private fun enterPip(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return false
        if (!packageManager.hasSystemFeature("android.software.picture_in_picture")) return false
        return try {
            enterPictureInPictureMode(buildParams()!!)
        } catch (e: IllegalStateException) {
            false
        }
    }

    // Android 8–11: entra em PiP ao apertar Home com vídeo tocando.
    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        if (autoPip && Build.VERSION.SDK_INT in Build.VERSION_CODES.O until Build.VERSION_CODES.S) {
            enterPip()
        }
    }

    override fun onPictureInPictureModeChanged(
        isInPictureInPictureMode: Boolean,
        newConfig: Configuration,
    ) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
        channel?.invokeMethod("pipChanged", isInPictureInPictureMode)
    }
}
