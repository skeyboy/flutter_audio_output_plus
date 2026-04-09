#include "include/flutter_audio_output_plus/flutter_audio_output_plus_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "flutter_audio_output_plus_plugin.h"

void FlutterAudioOutputPlusPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  flutter_audio_output_plus::FlutterAudioOutputPlusPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
