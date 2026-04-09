#ifndef FLUTTER_PLUGIN_FLUTTER_AUDIO_OUTPUT_PLUS_PLUGIN_H_
#define FLUTTER_PLUGIN_FLUTTER_AUDIO_OUTPUT_PLUS_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace flutter_audio_output_plus {

class FlutterAudioOutputPlusPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FlutterAudioOutputPlusPlugin();

  virtual ~FlutterAudioOutputPlusPlugin();

  // Disallow copy and assign.
  FlutterAudioOutputPlusPlugin(const FlutterAudioOutputPlusPlugin&) = delete;
  FlutterAudioOutputPlusPlugin& operator=(const FlutterAudioOutputPlusPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace flutter_audio_output_plus

#endif  // FLUTTER_PLUGIN_FLUTTER_AUDIO_OUTPUT_PLUS_PLUGIN_H_
