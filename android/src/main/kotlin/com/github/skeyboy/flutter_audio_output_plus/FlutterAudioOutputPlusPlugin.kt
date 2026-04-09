package com.github.skeyboy.flutter_audio_output_plus

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.AudioDeviceInfo
import android.media.AudioDeviceInfo.*
import android.media.AudioManager
import android.os.Build
import android.util.Log
import com.itsmurphy.flutter_audio_output.AudioChangeReceiver
import com.itsmurphy.flutter_audio_output.AudioEventListener
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.Serializable
import java.util.Arrays

/** FlutterAudioOutputPlusPlugin */
class FlutterAudioOutputPlusPlugin :
    FlutterPlugin,
    MethodCallHandler {
    // The MethodChannel that will the communication between Flutter and native Android
    //
    // This local reference serves to register the plugin with the Flutter Engine and unregister it
    // when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private var audioManager: AudioManager? = null
    private var context: Context? = null
    private var audioChangeReceiver: AudioChangeReceiver? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_audio_output_plus")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.getApplicationContext()
        audioManager = context!!.getSystemService(Context.AUDIO_SERVICE) as AudioManager?

        // Register audio change receiver
        audioChangeReceiver = AudioChangeReceiver(listener)
        val filter: IntentFilter = IntentFilter(Intent.ACTION_HEADSET_PLUG)
        context!!.registerReceiver(audioChangeReceiver, filter)
    }

    private val listener: AudioEventListener = object : AudioEventListener {
        override fun onChanged() {
            channel.invokeMethod("inputChanged", 1)
        }
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        if (call.method.equals("getPlatformVersion")) {
            result.success("Android " + android.os.Build.VERSION.RELEASE)
        } else if (call.method.equals("getCurrentOutput")) {
            val deviceInfo = this.currentOutput.first()
            if (deviceInfo != null) {
                result.success(
                    mapOf(
                        "id" to deviceInfo.id.toString(),
                        "type" to deviceInfo.type,
                        "label" to deviceInfo.productName.toString()
                    )
                )
            } else {
                result.success(
                    null
                )
            }
        } else if (call.method.equals("getAvailableInputs")) {
            result.success(this.availableInputs)
        } else if (call.method.equals("changeToReceiver")) {
            result.success(changeToReceiver())
        } else if (call.method.equals("changeToSpeaker")) {
            result.success(changeToSpeaker())
        } else if (call.method.equals("changeToHeadphones")) {
            result.success(changeToHeadphones())
        } else if (call.method.equals("changeToBluetooth")) {
            result.success(changeToBluetooth())
        } else if (call.method.equals("changeOutput")) {

            val id = call.argument<String>("id")
            val type = call.argument<String>("type") ?: "0"


            val typeNum = type?.toIntOrNull()
            if (typeNum == TYPE_BUILTIN_SPEAKER) {
                result.success(changeToSpeaker())
            } else if (typeNum == TYPE_BUILTIN_EARPIECE) {
                result.success(changeToReceiver())
            } else if (typeNum == TYPE_BLUETOOTH_A2DP || typeNum == TYPE_BLUETOOTH_SCO) {
                result.success(changeToBluetooth())
            } else if (typeNum == TYPE_USB_HEADSET) {
                result.success(changeToHeadphones())
            } else if (typeNum == TYPE_WIRED_HEADSET) {
                result.success(changeToHeadphones())
            } else {
                result.success(false)
            }


        } else {
            result.notImplemented()
        }
    }

    private fun mutableMapOf(pairs: () -> Pair<String, Int>) {}

    private fun changeToReceiver(): Boolean {
        audioManager!!.setMode(AudioManager.MODE_IN_COMMUNICATION)
        audioManager!!.stopBluetoothSco()
        audioManager!!.setBluetoothScoOn(false)
        audioManager!!.setSpeakerphoneOn(false)
        listener.onChanged()
        return true
    }

    private fun changeToSpeaker(): Boolean {
        audioManager!!.setMode(AudioManager.MODE_NORMAL)
        audioManager!!.stopBluetoothSco()
        audioManager!!.setBluetoothScoOn(false)
        audioManager!!.setSpeakerphoneOn(true)
        listener.onChanged()
        return true
    }

    private fun changeToHeadphones(): Boolean {
        return changeToReceiver()
    }

    private fun changeToBluetooth(): Boolean {
        audioManager!!.setMode(AudioManager.MODE_IN_COMMUNICATION)
        audioManager!!.startBluetoothSco()
        audioManager!!.setBluetoothScoOn(true)
        listener.onChanged()
        return true
    }

    private val currentOutput: MutableList<AudioDeviceInfo?>
        get() {
            val audioDevices: Array<AudioDeviceInfo?>? =
                audioManager?.getDevices(AudioManager.GET_DEVICES_OUTPUTS)


            var info = mutableListOf<AudioDeviceInfo?>()

            if (audioManager?.isSpeakerphoneOn() == true) {
                val deviceInfo = audioDevices?.first { it?.type == TYPE_BUILTIN_SPEAKER }
                if (deviceInfo != null) {
                    info.add(deviceInfo)
                }
            } else if (audioManager?.isBluetoothScoOn() == true) {
                val deviceInfo =
                    audioDevices?.first { it?.type == TYPE_BLUETOOTH_SCO || it?.type == TYPE_BLUETOOTH_A2DP }
                if (deviceInfo != null) {
                    info.add(deviceInfo)
                }
            } else if (this.isWiredHeadsetOn) {
                val deviceInfo =
                    audioDevices?.first { it?.type == TYPE_USB_HEADSET || it?.type == TYPE_WIRED_HEADSET }
                if (deviceInfo != null) {
                    info.add(deviceInfo)
                }
            } else {
                val deviceInfo = audioDevices?.first { it?.type == TYPE_BUILTIN_EARPIECE }
                if (deviceInfo != null) {
                    info.add(deviceInfo)
                }
            }
            return info
        }

    private val isWiredHeadsetOn: Boolean
        get() {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val audioDevices: Array<out AudioDeviceInfo?>? =
                    audioManager?.getDevices(AudioManager.GET_DEVICES_OUTPUTS)
                if (audioDevices != null) {
                    for (deviceInfo in audioDevices) {
                        if (deviceInfo?.type === TYPE_WIRED_HEADPHONES ||
                            deviceInfo?.type === TYPE_WIRED_HEADSET
                        ) {
                            return true
                        }
                    }
                }
                return false
            } else {
                // Fallback for older versions
                return audioManager?.isWiredHeadsetOn ?: false
            }
        }

    private val availableInputs: List<Map<String, Any>>?
        get() {


            val audioDevices: Array<AudioDeviceInfo?>? =
                audioManager?.getDevices(AudioManager.GET_DEVICES_OUTPUTS)


            val result = audioDevices?.filter {
                it?.type == TYPE_WIRED_HEADPHONES || it?.type == TYPE_BLUETOOTH_SCO || it?.type == TYPE_BLUETOOTH_A2DP || it?.type == TYPE_WIRED_HEADSET || it?.type == TYPE_USB_HEADSET || it?.type == TYPE_BUILTIN_EARPIECE || it?.type == TYPE_BUILTIN_SPEAKER
            }?.filterNotNull()?.map {
                mapOf(
                    "id" to it.id.toString(),
                    "type" to it.type,
                    "label" to it.productName.toString()
                )
            }
            return result
        }

    private val isBluetoothAvailable: Boolean
        get() {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val audioDevices: Array<AudioDeviceInfo> =
                    audioManager!!.getDevices(AudioManager.GET_DEVICES_OUTPUTS)
                for (deviceInfo in audioDevices) {
                    if (deviceInfo.getType() === TYPE_BLUETOOTH_A2DP ||
                        deviceInfo.getType() === TYPE_BLUETOOTH_SCO
                    ) {
                        return true
                    }
                }
                return false
            } else {
                // For older versions, we'll assume bluetooth is available if SCO is on
                return audioManager!!.isBluetoothScoOn()
            }
        }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        // Unregister receiver
        if (audioChangeReceiver != null && context != null) {
            try {
                context!!.unregisterReceiver(audioChangeReceiver)
            } catch (e: IllegalArgumentException) {

            }

            channel.setMethodCallHandler(null)
        }
    }
}
