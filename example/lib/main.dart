import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_audio_output_plus/flutter_audio_output_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _flutterAudioOutputPlusPlugin = FlutterAudioOutputPlus();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _flutterAudioOutputPlusPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
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
}
