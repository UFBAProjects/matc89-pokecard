import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pokecard/withlist_packet/withlist_packet.dart';
import 'package:pokecard/withlist_packet/withlist_packet_repository.dart';

final WithlistCardListControllerProvider =
    StateNotifierProvider<WithlistCardListController, AsyncValue<List<WithlistCard>>>(
  (ref) => WithlistCardListController(
   WithlistCardRepository(FirebaseFirestore.instance),
  ),
);

class WithlistCardListController extends StateNotifier<AsyncValue<List<WithlistCard>>> {
  final  WithlistCardRepository repository;

  WithlistCardListController(this.repository) : super(const AsyncValue.loading()) {
    fetchWithlist();
  }

  Future<void> fetchWithlist() async{
    try{
      final withlist = await repository.fetchWithlist(); 
      state = AsyncValue.data(withlist); 
    }
    catch(e, st){
      state = AsyncValue.error(e, st);
    }
  }
  Future<void> saveAllCardsWithlist(List<WithlistCard> cards) async{
    try{
      state = const AsyncValue.loading(); 
      await repository.saveAllWithlistCard(cards); 
      await fetchWithlist(); 
    }
    catch(e, st){
      state = AsyncValue.error(e, st); 
    }
  }
  Future<void> addWithlistCard(WithlistCard card) async {
    try{
      state = const AsyncValue.loading(); 
      await repository.addCardWithlist(card);
      await fetchWithlist(); 
    }
    catch (e, st){
      state = AsyncValue.error(e,st);
    }
  }

 Future<void> removeWithlistCard(String name)async{
    try{
      state = const AsyncValue.loading(); 
      await repository.removeCardWithlist(name);
      await fetchWithlist(); 
    }
    catch (e, st){
      state = AsyncValue.error(e, st);
    }
}
}