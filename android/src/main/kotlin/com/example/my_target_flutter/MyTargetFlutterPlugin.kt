package com.example.my_target_flutter

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.*


/** MyTargetFlutterPlugin */
class MyTargetFlutterPlugin : FlutterPlugin, ActivityAware {
    companion object {
        private const val  CHANNEL_NAME = "my_target_flutter"
        private const val AD_LISTENER_CHANNEL_NAME = "my_target_flutter/ad_listener"
    }


    private var adEventHandler: AdEventHandler? = null
    private lateinit var adListenerChannel: EventChannel
    private  lateinit var dartChannel: MethodChannel

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val messenger: BinaryMessenger = binding.binaryMessenger
         dartChannel = MethodChannel(
            messenger,
            CHANNEL_NAME,
        )
         val context = binding.applicationContext
         adListenerChannel = EventChannel(
            messenger, AD_LISTENER_CHANNEL_NAME)
        adEventHandler = AdEventHandler()
        adListenerChannel.setStreamHandler(adEventHandler)
         val methodCallHandler = MethodCallHandler(context, adEventHandler!!)
        dartChannel.setMethodCallHandler(methodCallHandler)

    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {

    }

    override fun onDetachedFromActivityForConfigChanges() {
        dartChannel.setMethodCallHandler(null)
        adListenerChannel.setStreamHandler(null)
        adEventHandler = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }

    override fun onDetachedFromActivity() {
    }


}
