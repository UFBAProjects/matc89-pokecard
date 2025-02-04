import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokecard/collection.dart';
import 'package:pokecard/collection/collection_list_page.dart';
import 'package:pokecard/mistery_packet/mistery_packet_list_page.dart';
import 'package:pokecard/withlist_packet/withlist_packet_list_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:pokecard/deck/pages/deck_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const ProviderScope(
      child: MaterialApp(
        home: HomePage(),
      ),
    ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = <Widget>[
    const MisteryPacketListPage(),
    PokeCardListPage(),
    const DeckListPage(),
    const WithlistPacketListPage()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            backgroundColor: Color.fromARGB(255, 129, 49, 76),
            icon: Icon(Icons.question_mark),
            label: 'Mistery Packet',
          ),
          BottomNavigationBarItem(
            backgroundColor: Color.fromARGB(255, 129, 49, 76),
            icon: Icon(Icons.credit_card),
            label: 'Cards',
          ),
          BottomNavigationBarItem(
            backgroundColor: Color.fromARGB(255, 129, 49, 76),
            icon: Icon(Icons.dashboard),
            label: 'Decks',
          ),
          BottomNavigationBarItem(
            backgroundColor: Color.fromARGB(255, 129, 49, 76),
            icon: Icon(Icons.favorite),
            label: 'Whishlist',
          ),
        ],
      ),
    );
  }
}
