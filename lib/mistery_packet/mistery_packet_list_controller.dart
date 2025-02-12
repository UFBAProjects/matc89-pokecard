import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pokecard/mistery_packet/mistery_packet.dart';
import 'package:pokecard/mistery_packet/mistery_packet_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


Future<String> getUserId() async {
  final prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('user_id');

  if (userId == null) {
    userId = const Uuid().v4();
    await prefs.setString('user_id', userId);
  }

  return userId;
}

final cardListControllerProvider =
    StateNotifierProvider<CardListController, AsyncValue<List<PokeCard>>>(
  (ref) => CardListController(
    PokeCardRepository(FirebaseFirestore.instance),
  ),
);

class CardListController extends StateNotifier<AsyncValue<List<PokeCard>>> {
  final PokeCardRepository repository;

  CardListController(this.repository) : super(const AsyncValue.data([])) {
    saveUserData(); 
  }

  



  Future<void> saveUserData() async {
    final fireStore = FirebaseFirestore.instance;
    final userId = await getUserId();
    final userPokem = fireStore.collection('pokeUsers').doc(userId);

    final snapshot = await userPokem.get();

    if (!snapshot.exists) {
      final currentTime = DateTime.now().millisecondsSinceEpoch;

      await userPokem.set({
        'user_id': userId,
        'created_at': currentTime,
      }, SetOptions(merge: true));
    }
  }

  Future<void> fetchPokemonCards() async {
    try {
      state = const AsyncValue.loading(); 

      final fireStore = FirebaseFirestore.instance;
      final userId = await getUserId();
      final userPokem = fireStore.collection('pokeUsers').doc(userId);

      final currentTime = DateTime.now().millisecondsSinceEpoch;

      await userPokem.set({
        'last_open_time': currentTime
      }, SetOptions(merge: true));

      const generalEndpoint =
          'https://pokeapi.co/api/v2/pokemon/?offset=300&limit=300';

      // Fetch general Pokémon data
      final generalResponse = await http.get(Uri.parse(generalEndpoint));
      if (generalResponse.statusCode != 200) {
        throw Exception('Failed to fetch Pokémon list');
      }

      final generalData = json.decode(generalResponse.body);
      final results = generalData['results'] as List;

      // Randomly select 6 Pokémon
      final random = Random();
      final selectedPokemon =
          List.generate(6, (_) => results[random.nextInt(results.length)]);

      // Fetch detailed data for each selected Pokémon
      final List<PokeCard> cards = [];
      for (var pokemon in selectedPokemon) {
        final detailResponse = await http.get(Uri.parse(pokemon['url']));
        if (detailResponse.statusCode != 200) {
          throw Exception(
              'Failed to fetch details for Pokémon: ${pokemon['name']}');
        }

        final detailData = json.decode(detailResponse.body);

        final colorResponse =
            await http.get(Uri.parse(detailData['species']['url']));
        if (colorResponse.statusCode != 200) {
          throw Exception(
              'Failed to fetch color for Pokémon: ${pokemon['name']}');
        }

        final colorData = json.decode(colorResponse.body);

        // Build PokeCard object
        cards.add(PokeCard(
          name: detailData['name'],
          image: detailData['sprites']['front_default'] ?? '',
          type: (detailData['types'] as List)
              .map((t) => t['type']['name'] as String)
              .join(', '),
          weight: detailData['weight'],
          abilities: (detailData['abilities'] as List)
              .map((a) => a['ability']['name'] as String)
              .toList(),
          color: colorData['color']['name'],
        ));
      }

      state = AsyncValue.data(cards);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> canOpenPacket() async {
    final fireStore = FirebaseFirestore.instance;
    final userId = await getUserId();
    final userDoc = fireStore.collection('pokeUsers').doc(userId);

    final snapshot = await userDoc.get();
    if (snapshot.exists && snapshot.data()!.containsKey('last_open_time')) {
      final lastOpenTime = snapshot.data()!['last_open_time'];
      final currentTime = DateTime.now().millisecondsSinceEpoch;

      if (currentTime - lastOpenTime < 2 * 60 * 1000) {
        return false;  
      }
    }
    return true;  
  }

}

// notification controller

class NotificationController extends StateNotifier<List<RemoteMessage>> {
  NotificationController() : super([]);

  void addNotification(RemoteMessage message) {
    state = [...state, message];
  }
}

final notificationProvider = StateNotifierProvider<NotificationController, List<RemoteMessage>>((ref) {
  return NotificationController();
});

