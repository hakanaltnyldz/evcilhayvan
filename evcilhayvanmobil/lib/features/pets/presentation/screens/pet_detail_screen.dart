// lib/features/pets/presentation/screens/pet_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evcilhayvanmobil/core/http.dart'; 
import 'package:evcilhayvanmobil/features/pets/data/repositories/pets_repository.dart';
import 'package:evcilhayvanmobil/features/pets/domain/models/pet_model.dart';
import 'package:evcilhayvanmobil/features/auth/data/repositories/auth_repository.dart';

// Provider (Değişiklik yok)
final petDetailProvider = FutureProvider.autoDispose.family<Pet, String>((ref, petId) {
  final repository = ref.watch(petsRepositoryProvider);
  return repository.getPetById(petId);
});

class PetDetailScreen extends ConsumerWidget {
  final String petId;
  const PetDetailScreen({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petAsyncValue = ref.watch(petDetailProvider(petId));
    final currentUser = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('İlan Detayı'),
      ),
      body: petAsyncValue.when(
        data: (pet) {
          // --- HATA DÜZELTMESİ BURADA ---
          // 'pet.owner.id' yerine 'pet.owner?.id' kullanıyoruz.
          // Eğer 'pet.owner' null ise, 'isOwner' false olacaktır.
          final bool isOwner = (currentUser?.id == pet.owner?.id);
          // --- DÜZELTME BİTTİ ---

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fotoğraf (Değişiklik yok)
                (pet.photos.isNotEmpty)
                  ? CachedNetworkImage(
                      imageUrl: '${apiBaseUrl}${pet.photos[0]}', 
                      height: 300, width: double.infinity, fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 300, color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 300, color: Colors.grey[300],
                        child: const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                      ),
                    )
                  : Container( 
                      height: 300, width: double.infinity, color: Colors.grey[300],
                      child: const Center(child: Icon(Icons.pets, size: 100, color: Colors.grey)),
                    ),
                
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.name,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(pet.bio ?? 'Açıklama yok', style: Theme.of(context).textTheme.bodyLarge),
                      const Divider(height: 32),
                      
                      // --- HATA DÜZELTMESİ BURADA ---
                      // 'pet.owner.name' yerine 'pet.owner?.name' kullanıyoruz.
                      // Eğer 'owner' null ise, "Sahip Bilgisi Yok" yazacak.
                      _buildDetailRow('İlan Sahibi', pet.owner?.name ?? 'Sahip Bilgisi Yok'),
                      // --- DÜZELTME BİTTİ ---
                      
                      _buildDetailRow('Tür', pet.species),
                      _buildDetailRow('Cins', pet.breed ?? 'Bilinmiyor'),
                      _buildDetailRow('Cinsiyet', pet.gender),
                      _buildDetailRow('Yaş (Ay)', pet.ageMonths.toString()),
                      _buildDetailRow('Aşı Durumu', pet.vaccinated ? 'Aşılı' : 'Aşısız'),
                      _buildDetailRow('Konum', (pet.location['coordinates'] != null && pet.location['coordinates'].length == 2)
                          ? 'Enlem: ${pet.location['coordinates'][1]}, Boylam: ${pet.location['coordinates'][0]}'
                          : 'Belirtilmemiş'),
                    ],
                  ),
                ),

                // Butonlar (Değişiklik yok, 'isOwner' artık doğru çalışıyor)
                if (currentUser != null && !isOwner)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () { /* TODO: Pass */ },
                          icon: const Icon(Icons.close),
                          label: const Text('Geç'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () { /* TODO: Like */ },
                          icon: const Icon(Icons.favorite, color: Colors.red),
                          label: const Text('Beğen'),
                        ),
                      ],
                    ),
                  )
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Hata: İlan yüklenemedi.\n$e')),
      ),
    );
  }

  // Detay satırları için yardımcı widget (Değişiklik yok)
  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}