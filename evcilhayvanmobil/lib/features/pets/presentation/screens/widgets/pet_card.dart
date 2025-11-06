// lib/features/pets/presentation/widgets/pet_card.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evcilhayvanmobil/core/http.dart'; // apiBaseUrl için
import 'package:evcilhayvanmobil/features/pets/domain/models/pet_model.dart';

class PetCard extends StatelessWidget {
  final Pet pet;
  final VoidCallback onTap; // Tıklanma eylemi

  const PetCard({
    super.key,
    required this.pet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // --- DÜZELTME: Değişkenler build metodunun en başına taşındı ---

    // 1. Sahip adını güvenli bir şekilde al
    // Sahip null'sa VEYA adı null'sa '' (boş string) ata
    final String ownerName = pet.owner?.name ?? '';

    // 2. Güvenli harfi al (boş string'den substring almayı engelle)
    final String avatarLetter = ownerName.isNotEmpty
        ? ownerName.substring(0, 1).toUpperCase()
        : '?';
    
    // --- DÜZELTME BİTTİ ---

    return Card(
      // Kartın kenarlarını yuvarlat
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5.0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        // Kartı tıklanabilir yap
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. FOTOĞRAF KISMI
            SizedBox(
              height: 200, // Fotoğraf yüksekliği
              width: double.infinity,
              child: (pet.photos.isNotEmpty)
                  ? CachedNetworkImage(
                      imageUrl: '${apiBaseUrl}${pet.photos[0]}',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Center(
                            child: Icon(Icons.pets, size: 80, color: Colors.grey)),
                      ),
                    )
                  : Container(
                      // Fotoğraf yoksa
                      color: Colors.grey[300],
                      child: const Center(
                          child: Icon(Icons.pets, size: 80, color: Colors.grey)),
                    ),
            ),

            // 2. BİLGİ KISMI
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // İlan Adı
                  Text(
                    pet.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Tür ve Cins (pet.breed için null kontrolü)
                  Text(
                    // --- BURASI DA GÜNCELLENDİ (Daha okunaklı) ---
                    // 'species' ve 'breed' artık zorunlu (create_pet_screen'e göre)
                    // Ama güncelleme modunda eski veri null olabilir, ?? kontrolü kalsın.
                    '${pet.species} - ${pet.breed ?? 'Bilinmiyor'}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // 3. Sahip bilgisini göster
                  // Değişkenler artık burada (children içinde) değil!
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        // TODO: Sahip avatarı (pet.owner.avatarUrl)
                        child: Text(avatarLetter), // Güvenli harfi kullan
                      ),
                      const SizedBox(width: 8),
                      Text(
                        // ownerName boşsa farklı bir metin göster
                        ownerName.isNotEmpty
                            ? 'İlan sahibi: $ownerName'
                            : 'Sahip bilgisi yok',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}