import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokecard/mistery_packet/mistery_packet_list_controller.dart';
import 'package:pokecard/mistery_packet/mistery_packet.dart';

class MisteryPacketListPage extends ConsumerStatefulWidget {
  const MisteryPacketListPage({super.key});

  @override
  ConsumerState<MisteryPacketListPage> createState() => _MisteryPacketListPageState();
}

class _MisteryPacketListPageState extends ConsumerState<MisteryPacketListPage> {
  bool isButtonEnabled = true;

  @override
  void initState() {
    super.initState();
    _checkPacketAvailability();
  }

  // check if is allowed open a new packet
  Future<void> _checkPacketAvailability() async {
    final controller = ref.read(cardListControllerProvider.notifier);
    final canOpen = await controller.canOpenPacket();
    setState(() {
      isButtonEnabled = canOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cardListAsyncValue = ref.watch(cardListControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mistery Packet')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: isButtonEnabled
                    ? () async {
                        final controller = ref.read(cardListControllerProvider.notifier);

                        
                        final canOpen = await controller.canOpenPacket();
                        if (canOpen) {
                          try {
                            await controller.fetchPokemonCards(); 
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Pacote aberto com sucesso! Pokémons carregados.')),
                            );
                            
                            setState(() {
                              isButtonEnabled = false;
                            });
                            Future.delayed(const Duration(hours: 2), () {
                              setState(() {
                                isButtonEnabled = true;
                              });
                            });
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erro ao abrir pacote: $e')),
                            );
                          }
                        }
                      }
                    : () {
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Aguarde os 2 minutos de abrir outro pacote.')),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isButtonEnabled ? Colors.grey : Colors.white,
                ),
                child: const Text('Open New Packet'),
              ),

              const SizedBox(height: 20),

              cardListAsyncValue.when(
                data: (cardList) {
                  if (cardList.isEmpty) {
                    return const Text(
                      'Nenhum Pokémon carregado. Clique no botão para abrir um novo pacote.',
                      textAlign: TextAlign.center,
                    );
                  }
                  return Expanded(child: _buildList(context, cardList));
                },
                loading: () => const CircularProgressIndicator(),
                error: (error, stackTrace) => Text('Erro: $error'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<PokeCard> cardList) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final crossAxisCount = isMobile ? 2 : 3;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: cardList.length,
      itemBuilder: (context, index) {
        final card = cardList[index];

        final colorMap = {
          'black': Colors.black,
          'blue': Colors.blue,
          'brown': Colors.brown,
          'gray': Colors.grey,
          'green': Colors.green,
          'pink': Colors.pink,
          'purple': Colors.purple,
          'red': Colors.red,
          'white': Colors.white,
          'yellow': Colors.yellow,
        };
        final cardColor = colorMap[card.color.toLowerCase()] ?? Colors.grey;

        return Container(
          decoration: BoxDecoration(
            color: cardColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black, width: 2),
          ),
          margin: const EdgeInsets.all(8.0),
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                card.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Image.network(
                  card.image,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Type: ${card.type}',
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
              Text(
                'Weight: ${card.weight}',
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
              Text(
                'Abilities: ${card.abilities.join(", ")}',
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
            ],
          ),
        );
      },
    );
  }
}
