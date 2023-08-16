package com.example.flutter_billpocket

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

/** FlutterBillpocketPlugin */
class FlutterBillpocketPlugin : FlutterPlugin, ActivityAware {

    private var streamHandlerImpl: StreamHandlerImpl? = null
    private var methodHandlerImpl: MethodCallHandlerImpl? = null


    private var activityBinding: ActivityPluginBinding? = null

    private var listenerTransaction: ListenerTransaction? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        methodHandlerImpl = MethodCallHandlerImpl()
        methodHandlerImpl?.startListening(flutterPluginBinding.binaryMessenger)
        methodHandlerImpl?.setContext(flutterPluginBinding.applicationContext)

        streamHandlerImpl = StreamHandlerImpl()
        streamHandlerImpl?.startListening(flutterPluginBinding.binaryMessenger)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        if (methodHandlerImpl != null) {
            methodHandlerImpl!!.stopListening()
            methodHandlerImpl = null
        }
        if (streamHandlerImpl != null) {
            streamHandlerImpl!!.stopListening()
            streamHandlerImpl = null
        }
    }

    private fun attachToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
        initialize()
    }

    private fun detachActivity() {
        activityBinding = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.attachToActivity(binding);
    }

    override fun onDetachedFromActivityForConfigChanges() {
        this.detachActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        this.attachToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        this.detachActivity()
    }

    private fun initialize() {
        listenerTransaction = ListenerTransaction(streamHandlerImpl!!, activityBinding!!.activity)
        methodHandlerImpl?.setListenerTransaction(listenerTransaction!!)
    }
}
