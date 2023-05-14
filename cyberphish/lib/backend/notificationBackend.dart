// ignore_for_file: depend_on_referenced_packages, file_names, camel_case_types

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

// notification service class
class notificationBackend {
  notificationBackend();

  final _localNotificationsPlugin = FlutterLocalNotificationsPlugin();
  Future<void> setup() async {
    const androidSetting = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(
      android: androidSetting,
    );

    await _localNotificationsPlugin
        .initialize(initSettings)
        .then((_) {})
        .catchError((Object error) {
      debugPrint('Error: $error');
    });
  }

  void addNotification(String title, String body, int endTime,
      {required String channel}) {
    tz.initializeTimeZones();
    final scheduleTime =
        tz.TZDateTime.fromMillisecondsSinceEpoch(tz.local, endTime);
    final androidDetail = AndroidNotificationDetails(
      channel, // channel Id
      channel, // channel Name
    );
    final noticeDetail = NotificationDetails(
      android: androidDetail,
    );
    const id = 0;
    _localNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduleTime,
      noticeDetail,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
    );
    FlutterRingtonePlayer.play(
      android: AndroidSounds.notification,
      ios: IosSounds.glass,
      looping: false,
      volume: 0.01,
      asAlarm: false,
    );
  }
}
