import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_audio_output_plus.dart';
import 'flutter_audio_output_plus_method_channel.dart';

abstract class FlutterAudioOutputPlusPlatform extends PlatformInterface {
  /// Constructs a FlutterAudioOutputPlusPlatform.
  FlutterAudioOutputPlusPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterAudioOutputPlusPlatform _instance =
      MethodChannelFlutterAudioOutputPlus();

  /// The default instance of [FlutterAudioOutputPlusPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterAudioOutputPlus].
  static FlutterAudioOutputPlusPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterAudioOutputPlusPlatform] when
  /// they register themselves.
  static set instance(FlutterAudioOutputPlusPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<OutputDevice?> getCurrentOutput() {
    throw UnimplementedError('getCurrentOutput() has not been implemented.');
  }

  Future<dynamic> getAvailableInputs() {
    throw UnimplementedError('getAvailableInputs() has not been implemented.');
  }

  Future<dynamic> changeOutput({required OutputDevice device}) {
    throw UnimplementedError('changeOutput() has not been implemented.');
  }

  Future<bool> changeToSpeaker() async {
    throw UnimplementedError('changeToSpeaker() has not been implemented.');
  }

  Future<bool> changeToReceiver() async {
    throw UnimplementedError('changeToReceiver() has not been implemented.');
  }

  Future<bool> changeToHeadphones() async {
    throw UnimplementedError('changeToHeadphones() has not been implemented.');
  }

  Future<bool> changeToBluetooth() async {
    throw UnimplementedError('changeToBluetooth() has not been implemented.');
  }
}
