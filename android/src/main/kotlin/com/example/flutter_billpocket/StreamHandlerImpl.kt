package com.example.flutter_billpocket

import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.StreamHandler

class StreamHandlerImpl : StreamHandler {
    private val TAG = "StreamHandlerImpl"

    private val STREAM_CHANNEL_NAME = "billpocket/transaction"

    private var channel: EventChannel? = null

    private var eventSink: EventChannel.EventSink? = null

    fun startListening(messenger: BinaryMessenger?) {
        if (channel != null) {
            Log.wtf(TAG, "Setting a method call handler before the last was disposed.")
            stopListening()
        }
        channel = EventChannel(messenger, STREAM_CHANNEL_NAME)
        channel?.setStreamHandler(this)
    }

    fun stopListening() {
        if (channel == null) {
            Log.d(TAG, "Tried to stop listening when no MethodChannel had been initialized.")
            return
        }
        channel!!.setStreamHandler(null)
        channel = null
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    fun onTransactionAborted(message: String) {
        eventSink?.success(mapOf("event" to "onTransactionAborted", "message" to message))
    }

    fun onBeforeTransaction(message: String) {
        eventSink?.success(mapOf("event" to "onBeforeTransaction", "message" to message))
    }

    fun onCardRead(message: String) {
        eventSink?.success(mapOf("event" to "onCardRead", "message" to message))
    }

    fun getSignature(message: String) {
        eventSink?.success(mapOf("event" to "getSignature", "message" to message))
    }

    fun onReaderWaitingForCard(message: String) {
        eventSink?.success(mapOf("event" to "onReaderWaitingForCard", "message" to message))
    }

    fun onMsiDefined(message: String, listMsi: String) {
        eventSink?.success(
            mapOf(
                "event" to "onMsiDefined",
                "message" to message,
                "list" to listMsi
            )
        )
    }

    fun onGetPin(message: String) {
        eventSink?.success(mapOf("event" to "onGetPin", "message" to message))
    }

    fun onMagneticCardFound(message: String) {
        eventSink?.success(mapOf("event" to "onMagneticCardFound", "message" to message))
    }

    fun onTransactionFinished(message: String) {
        eventSink?.success(mapOf("event" to "onTransactionFinished", "message" to message))
    }

    fun onTransactionSuccessful(message: String) {
        eventSink?.success(mapOf("event" to "onTransactionSuccessful", "message" to message))
    }

    fun resultStartTransaction(message: String) {
        eventSink?.success(mapOf("event" to "resultStartTransaction", "message" to message))
    }

    fun resultStartTransactionSuccess(message: String) {
        eventSink?.success(mapOf("event" to "resultStartTransactionSuccess", "message" to message))
    }

    fun resultStartTransactionError(message: String) {
        eventSink?.error("FlutterBillpocketException", message, null)
    }


}