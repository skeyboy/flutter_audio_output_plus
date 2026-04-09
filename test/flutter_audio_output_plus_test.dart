import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_audio_output_plus/flutter_audio_output_plus.dart';
import 'package:flutter_audio_output_plus/flutter_audio_output_plus_platform_interface.dart';
import 'package:flutter_audio_output_plus/flutter_audio_output_plus_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterAudioOutputPlusPlatform
    with MockPlatformInterfaceMixin
    implements FlutterAudioOutputPlusPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<dynamic> changeOutput({required OutputDevice device}) {
    // TODO: implement changeOutput
    throw UnimplementedError();
  }

  @override
  Future<bool> changeToBluetooth() {
    // TODO: implement changeToBluetooth
    throw UnimplementedError();
  }

  @override
  Future<bool> changeToHeadphones() {
    // TODO: implement changeToHeadphones
    throw UnimplementedError();
  }

  @override
  Future<bool> changeToReceiver() {
    // TODO: implement changeToReceiver
    throw UnimplementedError();
  }

  @override
  Future<bool> changeToSpeaker() {
    // TODO: implement changeToSpeaker
    throw UnimplementedError();
  }

  @override
  Future<dynamic> getAvailableInputs() {
    // TODO: implement getAvailableInputs
    throw UnimplementedError();
  }

  @override
  Future<OutputDevice?> getCurrentOutput() {
    // TODO: implement getCurrentOutput
    throw UnimplementedError();
  }
}

void main() {
  final FlutterAudioOutputPlusPlatform initialPlatform =
      FlutterAudioOutputPlusPlatform.instance;

  test('$MethodChannelFlutterAudioOutputPlus is the default instance', () {
    expect(
      initialPlatform,
      isInstanceOf<MethodChannelFlutterAudioOutputPlus>(),
    );
  });

  test('getPlatformVersion', () async {
    FlutterAudioOutputPlus flutterAudioOutputPlusPlugin =
        FlutterAudioOutputPlus();
    MockFlutterAudioOutputPlusPlatform fakePlatform =
        MockFlutterAudioOutputPlusPlatform();
    FlutterAudioOutputPlusPlatform.instance = fakePlatform;

    expect(await flutterAudioOutputPlusPlugin.getPlatformVersion(), '42');
  });
}
