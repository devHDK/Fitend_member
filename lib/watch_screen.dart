import 'dart:async';

import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:watch_connectivity/watch_connectivity.dart';

class WatchScreen extends StatefulWidget {
  const WatchScreen({super.key});

  @override
  State<WatchScreen> createState() => _WatchScreenState();
}

class _WatchScreenState extends State<WatchScreen> {
  final _watch = WatchConnectivity();

  var _count = 0;

  var _supported = false;
  var _paired = false;
  var _reachable = false;
  var _context = <String, dynamic>{};
  var _receivedContexts = <Map<String, dynamic>>[];
  final _log = <String>[];

  Timer? timer;

  @override
  void initState() {
    super.initState();
    healthInit();

    _watch.messageStream.listen((e) => setState(() {
          _log.add('Received message: $e');
          print('수신수신');
        }));

    _watch.contextStream
        .listen((e) => setState(() => _log.add('Received context: $e')));

    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  void initPlatformState() async {
    _supported = await _watch.isSupported;
    _paired = await _watch.isPaired;
    _reachable = await _watch.isReachable;
    _context = await _watch.applicationContext;
    _receivedContexts = await _watch.receivedApplicationContexts;
    setState(() {});
  }

  void checkMessage() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Supported: $_supported'),
                Text('Paired: $_paired'),
                Text('Reachable: $_reachable'),
                Text('Context: $_context'),
                Text('Received contexts: $_receivedContexts'),
                TextButton(
                  onPressed: initPlatformState,
                  child: const Text('Refresh'),
                ),
                const SizedBox(height: 8),
                const Text('Send'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: sendMessage,
                      child: const Text('Message'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: sendContext,
                      child: const Text('Context'),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: toggleBackgroundMessaging,
                  child: Text(
                    '${timer == null ? 'Start' : 'Stop'} background messaging',
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () async {
                    try {
                      await _watch.startWatchApp();
                    } catch (e) {
                      print(e);
                    }
                  },
                  child: const Text('Start watch app'),
                ),
                const SizedBox(width: 16),
                const Text('Log'),
                ..._log.reversed.map(Text.new),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void sendMessage() {
    final message = {'data': 'Hello'};
    _watch.sendMessage(message);
    setState(() => _log.add('Sent message: $message'));
  }

  void sendContext() {
    _count++;
    final context = {'data': _count};
    _watch.updateApplicationContext(context);
    setState(() => _log.add('Sent context: $context'));
  }

  void toggleBackgroundMessaging() {
    if (timer == null) {
      timer = Timer.periodic(const Duration(seconds: 1), (_) => sendMessage());
    } else {
      timer?.cancel();
      timer = null;
    }
    setState(() {});
  }

  void healthInit() async {
    // create a HealthFactory for use in the app, choose if HealthConnect should be used or not
    final health = HealthFactory(useHealthConnectIfAvailable: true);

    // define the types to get
    var types = [
      HealthDataType.HEART_RATE,
      HealthDataType.WORKOUT,
      HealthDataType.STEPS,
    ];

    // requesting access to the data types before reading them
    final requested = await health.requestAuthorization(types);

    final now = DateTime.now();

    // fetch health data from the last 24 hours
    final healthData = await health.getHealthDataFromTypes(
      now.subtract(const Duration(days: 1)),
      now,
      types,
    );

    // request permissions to write steps and blood glucose
    types = [HealthDataType.STEPS, HealthDataType.BLOOD_GLUCOSE];
    final permissions = [
      HealthDataAccess.READ_WRITE,
      HealthDataAccess.READ_WRITE,
    ];
    await health.requestAuthorization(types, permissions: permissions);

    // write steps and blood glucose
    var success =
        await health.writeHealthData(10, HealthDataType.STEPS, now, now);
    success = await health.writeHealthData(
      3.1,
      HealthDataType.BLOOD_GLUCOSE,
      now,
      now,
    );

    // get the number of steps for today
    final midnight = DateTime(now.year, now.month, now.day);
    final steps = await health.getTotalStepsInInterval(midnight, now);
  }
}
