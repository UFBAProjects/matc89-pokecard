import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pokecard/collection/collection_repository.dart';
import 'package:pokecard/mistery_packet/mistery_packet.dart';

// Provider para acessar o CollectionController com Riverpod
final collectionControllerProvider = StateNotifierProvider<CollectionController, AsyncValue<List<PokeCard>>>(
  (ref) => CollectionController(
    CollectionRepository(FirebaseFirestore.instance),
  ),
);

class CollectionController extends StateNotifier<AsyncValue<List<PokeCard>>> {
  final CollectionRepository repository;

  // Inicializa o estado com um carregando e chama a função para buscar os cards
  CollectionController(this.repository) : super(const AsyncValue.loading()) {
    getAllCards();
  }

  // Função para buscar todos os cards
  Future<void> getAllCards() async {
    try {
      state = const AsyncValue.loading();
      final cards = await repository.getAllCards(); 
      state = AsyncValue.data(cards); 
    } catch (e, st) {
      state = AsyncValue.error(e, st); 
    }
  }
}
