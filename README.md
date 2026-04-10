# flutter_audio_output_plus

A Flutter package flutter_audio_output is to adapt music output.

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/to/develop-plugins),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

```dart
 Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion =
          await _flutterAudioOutputPlusPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  dynamic getCurrentOutput;
  List<OutputDevice>? getAvailableInputs;
  dynamic changeToSpeaker;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Column(
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final getCurrentOutput = await _flutterAudioOutputPlusPlugin
                        .getCurrentOutput();
                    setState(() {
                      this.getCurrentOutput = getCurrentOutput;
                    });
                  },
                  child: Text("getCurrentOutput $getCurrentOutput"),
                ),

                if (getCurrentOutput != null) Column(children: []),
              ],
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final getAvailableInputs =
                        await _flutterAudioOutputPlusPlugin
                            .getAvailableInputs();
                    setState(() {
                      this.getAvailableInputs = getAvailableInputs;
                    });
                  },
                  child: Expanded(child: Text("getAvailableInputs ")),
                ),
                if (getAvailableInputs != null)
                  Column(
                    children: [
                      ...(getAvailableInputs?.map(
                            (e) => ElevatedButton(
                              onPressed: () async {
                                await _flutterAudioOutputPlusPlugin
                                    .changeOutput(device: e);
                              },
                              child: Expanded(
                                child: Text(
                                  "${e}",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ) ??
                          []),
                    ],
                  ),
              ],
            ),
            ElevatedButton(
              onPressed: () async {
                final changeToSpeaker = await _flutterAudioOutputPlusPlugin
                    .changeToSpeaker();
                setState(() {
                  this.changeToSpeaker = changeToSpeaker;
                });
              },
              child: Text("changeToSpeaker $changeToSpeaker"),
            ),
            Center(child: Text('Running on: $_platformVersion\n')),
          ],
        ),
      ),
    );
  }
```