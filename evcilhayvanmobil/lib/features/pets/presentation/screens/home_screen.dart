import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:evcilhayvanmobil/features/pets/data/repositories/pets_repository.dart';
import 'widgets/pet_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsyncValue = ref.watch(petFeedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('İlanları Keşfet'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16), // 🔧 taşmayı önler
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(petFeedProvider);
            },
            child: petsAsyncValue.when(
              data: (pets) {
                print('📦 FEED PETS LENGTH: ${pets.length}');
                final validPets = pets.toList();
                print('✅ VALID PETS LENGTH: ${validPets.length}');

                if (validPets.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'Şu anda görüntülenecek ilan bulunamadı.\nYeni ilanlar yolda olabilir 😊',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80), // 🔹 alt butonlardan uzak tutar
                  itemCount: validPets.length,
                  itemBuilder: (context, index) {
                    final pet = validPets[index];
                    return PetCard(
                      pet: pet,
                      onTap: () => context.pushNamed(
                        'pet-detail',
                        pathParameters: {'id': pet.id},
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) {
                print('❌ FEED ERROR: $error');
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Text(
                        'Akış yüklenirken hata oluştu:\n\n$error',
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
