import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pokecard/mistery_packet/wishlist_packet.dart';
import 'package:pokecard/mistery_packet/wishlist_packet_repository.dart';

final WithlistCardListControllerProvider =
    StateNotifierProvider<WithlistCardListController, AsyncValue<List<WithlistCard>>>(
  (ref) => WithlistCardListController(
   (FirebaseFirestore.instance),
  ),
);

class WithlistCardListController extends StateNotifier<AsyncValue<List<WishlistCard>>> {
  final  WithlistCardRepository repository;

  WithlistCardListController(this.repository) : super(const AsyncValue.loading()) {
    fetchWithlistCards();
  }

  Future<void> fetchWithlist() async{
    try{
      final withlist = await repository.fetchWithlistCards(); 
      state = AsyncValue.data(withlist); 
    }
    catch(e){
      state = AsyncValue.error(e);
    }
  }
  Future<void> saveAllCardsWithlist(List<WishlistCard> cards) async{
    try{
      state = const AsyncValue.loading(); 
      await WithlistCardRepository.saveAllCardsWithlist(cards); 
      await fetchWithlist(); 
    }
    catch(e){
      state = AsyncValue.error(e); 
    }
  }
  Future<void> addWithlistCard(WishlistCard card) async {
    try{
      state = const AsyncValue.loading(); 
      await WithlistCardRepository.addCardWithlist(card);
      await fetchWithlist(); 
    }
    catch (e){
      state = AsyncValue.error(e);
    }
  }

 Future<void> removeWithlistCard(String name){
    try{
      state = const AsyncValue.loading(); 
      await WithlistCardRepository.removeCardWithlist(card);
      await fetchWithlist(); 
    }
    catch (e){
      state = AsyncValue.error(e);
    }
}