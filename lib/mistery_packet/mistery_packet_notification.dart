import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:pokecard/mistery_packet/mistery_packet_notification_service.dart';


void scheduleNotificationIn2Minutes() async {
  const AndroidNotificationDetails androidDetails =
      AndroidNotificationDetails('your_channel_id', 'your_channel_name',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true);

  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidDetails);

  // ✅ Usa o plugin globalmente para agendar a notificação
  await flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    'Pokémon Mistery Packet',
    'Você já pode abrir seu novo pacote.',
    tz.TZDateTime.now(tz.local).add(const Duration(minutes: 2)),
    notificationDetails,
    androidScheduleMode: AndroidScheduleMode.exact,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );
}
