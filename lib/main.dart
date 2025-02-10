import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'firebase_options.dart';
import 'package:pokecard/mistery_packet/mistery_packet_list_page.dart';

import 'package:pokecard/mistery_packet/mistery_packet_notification_service.dart';

// ✅ Definindo o plugin globalmente
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializa o serviço de notificações
  await initializeNotifications();

  runApp(
    const ProviderScope(child: MaterialApp(home: MisteryPacketListPage())),
  );
}