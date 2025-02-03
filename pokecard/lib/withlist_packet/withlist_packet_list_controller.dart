import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pokecard/withlist_packet/withlist_packet_repository.dart';
import 'package:pokecard/mistery_packet/mistery_packet.dart';

final WithlistCardListControllerProvider = StateNotifierProvider<
    WithlistCardListController, AsyncValue<List<PokeCard>>>(
  (ref) => WithlistCardListController(
    WithlistCardRepository(FirebaseFirestore.instance),
  ),
);

final getAllMyCardsProvider = FutureProvider<List<PokeCard>>((ref) async {
  final controller = ref.read(WithlistCardListControllerProvider.notifier);
  return controller.getAllCards();
});

class WithlistCardListController
    extends StateNotifier<AsyncValue<List<PokeCard>>> {
  final WithlistCardRepository repository;

  WithlistCardListController(this.repository)
      : super(const AsyncValue.loading()) {
    fetchWithlist();
  }

  Future<void> fetchWithlist() async {
    try {
      final withlist = await repository.fetchWithlist();
      state = AsyncValue.data(withlist ?? []);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<List<PokeCard>> getAllCards() async {
    try {
      final cards = await repository.getAllCards();
      return cards ?? [];
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      throw Exception('Falha ao carregar os cards: $e');
    }
  }

  Future<void> addWithlistCard(PokeCard card) async {
    try {
      await repository.addCardWithlist(card);
      await fetchWithlist();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      throw Exception('Falha ao adicionar os cards na wishlist: $e');
    }
  }
  
  Future<void> removeWithlistCard(String name) async {
    try {
      await repository.removeCardWithlist(name);
      await fetchWithlist();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      throw Exception('Falha ao remover os cards na wishlist: $e');
    }
  }
}
