package com.github.skeyboy.flutter_audio_output_plus

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

interface AudioEventListener {
    fun onChanged()
}

class AudioChangeReceiver(var audioEventListener: AudioEventListener) : BroadcastReceiver() {

    override fun onReceive(context: Context?, intent: Intent) {
        if (intent.action.equals(Intent.ACTION_HEADSET_PLUG)) {
            audioEventListener.onChanged()
        }
    }
}