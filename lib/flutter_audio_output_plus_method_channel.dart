import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_audio_output_plus.dart';
import 'flutter_audio_output_plus_platform_interface.dart';

/// An implementation of [FlutterAudioOutputPlusPlatform] that uses method channels.
class MethodChannelFlutterAudioOutputPlus
    extends FlutterAudioOutputPlusPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_audio_output_plus');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<OutputDevice?> getCurrentOutput() async {
    final result = await methodChannel.invokeMethod<dynamic>(
      'getCurrentOutput',
    );

    return OutputDevice(
      id: result["id"],
      type: "${result["type"]}",
      label: result['label'],
    );
  }

  @override
  Future<dynamic> getAvailableInputs() async {
    final result = await methodChannel.invokeMethod<List<dynamic>>(
      'getAvailableInputs',
    );
    return result;
  }

  @override
  Future<dynamic> changeOutput({required OutputDevice device}) async {
    final result = await methodChannel.invokeMethod<bool>(
      'changeOutput',
      <String, dynamic>{
        "id": device.id,
        "type": device.type,
        "label": device.label,
      },
    );
    return result ?? false;
  }

  @override
  Future<bool> changeToSpeaker() async {
    final result = await methodChannel.invokeMethod<bool>('changeToSpeaker');
    return result ?? false;
  }

  @override
  Future<bool> changeToReceiver() async {
    final result = await methodChannel.invokeMethod<bool>('changeToReceiver');
    return result ?? false;
  }

  @override
  Future<bool> changeToHeadphones() async {
    final result = await methodChannel.invokeMethod<bool>('changeToHeadphones');
    return result ?? false;
  }

  @override
  Future<bool> changeToBluetooth() async {
    final result = await methodChannel.invokeMethod<bool>('changeToBluetooth');
    return result ?? false;
  }
}
