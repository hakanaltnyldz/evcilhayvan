// lib/features/auth/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:evcilhayvanmobil/features/auth/data/repositories/auth_repository.dart';
import 'package:evcilhayvanmobil/features/pets/data/repositories/pets_repository.dart';
import 'package:evcilhayvanmobil/core/http.dart';
import 'package:evcilhayvanmobil/features/pets/domain/models/pet_model.dart';


import '../../../pets/presentation/screens/widgets/pet_card.dart'; 

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  // Silme Diyalogu (Değişiklik yok)
  void _showDeleteDialog(BuildContext context, WidgetRef ref, String petId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('İlanı Sil'),
          content: const Text('Bu ilanı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.'),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () { Navigator.of(dialogContext).pop(); },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Sil'),
              onPressed: () async {
                try {
                  await ref.read(petsRepositoryProvider).deletePet(petId);
                  ref.invalidate(myPetsProvider);
                  Navigator.of(dialogContext).pop(); 
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('İlan başarıyla silindi.'), backgroundColor: Colors.green),
                  );
                } catch (e) {
                  Navigator.of(dialogContext).pop(); 
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Hata: ${e.toString()}'), backgroundColor: Colors.red),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider);
    final myPetsAsyncValue = ref.watch(myPetsProvider);

    if (currentUser == null) {
      // (Güvenlik kontrolü)
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Profili görmek için giriş yapmalısınız.'),
              ElevatedButton(
                onPressed: () => context.goNamed('login'),
                child: const Text('Giriş Yap'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              context.pushNamed('settings');
            },
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Profil bilgileri (Değişiklik yok)
                    CircleAvatar(
                      radius: 50,
                      child: (currentUser.avatarUrl != null)
                        ? ClipOval( 
                            child: CachedNetworkImage(
                              imageUrl: '${apiBaseUrl}${currentUser.avatarUrl}', 
                              placeholder: (context, url) => const CircularProgressIndicator(),
                              errorWidget: (context, url, error) => const Icon(Icons.person),
                              fit: BoxFit.cover, width: 100, height: 100,
                            ),
                          )
                        : Text( 
                            currentUser.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(fontSize: 40),
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(currentUser.name, style: Theme.of(context).textTheme.headlineSmall),
                    Text(currentUser.email),
                    Text('Şehir: ${currentUser.city ?? 'Belirtilmemiş'}'),
                    
                    // Ayarlar'a taşındığı için "Şifre Değiştir" butonu kaldırıldı.
                    
                    const Divider(height: 32),
                    Text('İlanlarım', style: Theme.of(context).textTheme.headlineSmall),
                  ],
                ),
              ),
            ),
          ];
        },
        // "İlanlarım" listesi
        body: myPetsAsyncValue.when(
          data: (pets) {
            if (pets.isEmpty) {
              return const Center(child: Text('Henüz hiç ilanınız yok.'));
            }
            return ListView.builder(
              // --- HATA DÜZELTMESİ: BOTTOM OVERFLOW ---
              // Listenin sonuna, alt bar (BottomNavBar) için boşluk ekliyoruz
              // 80.0, alt bar'ın yüksekliği + biraz boşluktur.
              padding: const EdgeInsets.only(bottom: 90.0), 
              // --- DÜZELTME BİTTİ ---
              itemCount: pets.length,
              itemBuilder: (context, index) {
                final pet = pets[index];
                
                // Sahibi null ise (bozuk veri) kartı gösterme
                if (pet.owner == null) return const SizedBox.shrink();

                return Stack(
                  children: [
                    PetCard(
                      pet: pet,
                      onTap: () {
                        context.pushNamed('pet-detail', pathParameters: {'id': pet.id});
                      },
                    ),
                    Positioned(
                      top: 16, 
                      right: 24, 
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            style: IconButton.styleFrom(backgroundColor: Colors.black.withOpacity(0.5)),
                            onPressed: () {
                              context.pushNamed('create-pet', extra: pet);
                            },
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.white),
                            style: IconButton.styleFrom(backgroundColor: Colors.black.withOpacity(0.5)),
                            onPressed: () {
                              _showDeleteDialog(context, ref, pet.id);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('İlanlar yüklenemedi: $e')),
        ),
      ),
    );
  }
}