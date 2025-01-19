import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokecard/card_list_page.dart';

void main() {
  runApp(ProviderScope(child: MaterialApp(home: CardListPage())));
}
