import 'flutter_audio_output_plus_platform_interface.dart';

class OutputDevice {
  OutputDevice({required this.id, required this.type, required this.label});

  final String id;
  final String type;
  final String label;

  @override
  String toString() {
    return "OutputDevice(id:$id, type:$type, label:$label)";
  }

  @override
  int get hashCode => toString().hashCode;

  @override
  bool operator ==(Object other) {
    if (other is OutputDevice) {
      return id == other.id;
    } else {
      return false;
    }
  }
}

class FlutterAudioOutputPlus {
  Future<String?> getPlatformVersion() {
    return FlutterAudioOutputPlusPlatform.instance.getPlatformVersion();
  }

  Future<OutputDevice?> getCurrentOutput() {
    return FlutterAudioOutputPlusPlatform.instance.getCurrentOutput();
  }

  Future<List<OutputDevice>> getAvailableInputs() async {
    final result = await FlutterAudioOutputPlusPlatform.instance
        .getAvailableInputs();

    final reResult = _convertToStringMaps(result);
    return reResult
        .map(
          (device) => OutputDevice(
            id: device['id'] ?? "",
            type: device['type'] ?? "",
            label: device['label'] ?? "",
          ),
        )
        .toList();
  }

  Future<dynamic> changeOutput({required OutputDevice device}) {
    return FlutterAudioOutputPlusPlatform.instance.changeOutput(device: device);
  }

  Future<dynamic> changeToSpeaker() {
    return FlutterAudioOutputPlusPlatform.instance.changeToSpeaker();
  }

  List<Map<String, String>> _convertToStringMaps(List<Object?> originalList) {
    return originalList.whereType<Map>().map((map) {
      return Map<String, String>.fromEntries(
        map.entries.map(
          (entry) =>
              MapEntry(entry.key.toString(), entry.value?.toString() ?? ''),
        ),
      );
    }).toList();
  }
}
