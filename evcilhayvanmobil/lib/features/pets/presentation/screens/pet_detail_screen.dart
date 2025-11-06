// lib/features/pets/presentation/screens/pet_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evcilhayvanmobil/core/http.dart';
import 'package:evcilhayvanmobil/features/pets/data/repositories/pets_repository.dart';
import 'package:evcilhayvanmobil/features/pets/domain/models/pet_model.dart';
import 'package:evcilhayvanmobil/features/auth/data/repositories/auth_repository.dart';

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('İlan Detayı'),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFc7d2fe), Color(0xFFeef2ff)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: petAsyncValue.when(
        data: (pet) {
          final bool isOwner = (currentUser?.id == pet.owner?.id);

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFeef2ff), Color(0xFFF8F9FB)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailHeader(pet: pet),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: Opacity(opacity: value, child: child),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pet.name,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                pet.bio ?? 'Açıklama yok',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      height: 1.5,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _InfoGrid(pet: pet),
                        const SizedBox(height: 24),
                        _OwnerSection(pet: pet),
                      ],
                    ),
                  ),
                  if (currentUser != null && !isOwner)
                    _ActionButtons(pet: pet),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text('Hata: İlan yüklenemedi.\n$e'),
          ),
        ),
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  final Pet pet;

  const _DetailHeader({required this.pet});

  @override
  Widget build(BuildContext context) {
    final heroTag = 'pet-image-${pet.id}';

    return Stack(
      children: [
        Hero(
          tag: heroTag,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
            child: SizedBox(
              height: 320,
              width: double.infinity,
              child: pet.photos.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: '${apiBaseUrl}${pet.photos[0]}',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.pets, size: 100, color: Colors.grey),
                      ),
                    ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.15),
                  Colors.black.withOpacity(0.55),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 24,
          bottom: 24,
          right: 24,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.place_rounded,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      pet.location['coordinates'] != null &&
                              pet.location['coordinates'].length == 2
                          ? 'Konum: ${pet.location['coordinates'][1]}, ${pet.location['coordinates'][0]}'
                          : 'Konum bilgisi paylaşılmadı',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoGrid extends StatelessWidget {
  final Pet pet;

  const _InfoGrid({required this.pet});

  @override
  Widget build(BuildContext context) {
    final items = <_InfoTileData>[
      _InfoTileData('Tür', pet.species, Icons.category_outlined),
      _InfoTileData('Cins', pet.breed ?? 'Bilinmiyor', Icons.badge_outlined),
      _InfoTileData('Cinsiyet', pet.gender, Icons.transgender),
      _InfoTileData('Yaş (Ay)', pet.ageMonths.toString(), Icons.cake_rounded),
      _InfoTileData('Aşı Durumu', pet.vaccinated ? 'Aşılı' : 'Aşısız', Icons.vaccines),
    ];

    return GridView.builder(
      shrinkWrap: true,
      itemCount: items.length,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.6,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.9, end: 1),
          duration: Duration(milliseconds: 300 + index * 120),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.scale(scale: value, child: child);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  height: 38,
                  width: 38,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon,
                      color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.title,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.value,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OwnerSection extends StatelessWidget {
  final Pet pet;

  const _OwnerSection({required this.pet});

  @override
  Widget build(BuildContext context) {
    final ownerName = pet.owner?.name ?? 'Sahip Bilgisi Yok';
    final avatarLetter = ownerName.isNotEmpty ? ownerName[0].toUpperCase() : '?';

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.12),
              child: Text(
                avatarLetter,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ownerName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'İlan sahibi ile iletişime geçmek için mesaj gönder.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final Pet pet;

  const _ActionButtons({required this.pet});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.95, end: 1),
        duration: const Duration(milliseconds: 400),
        builder: (context, value, child) {
          return Transform.scale(scale: value, child: child);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () { /* TODO: Pass */ },
                  icon: const Icon(Icons.close),
                  label: const Text('Geç'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    foregroundColor: Colors.grey[700],
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () { /* TODO: Like */ },
                  icon: const Icon(Icons.favorite, color: Colors.white),
                  label: const Text('Beğen'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTileData {
  final String title;
  final String value;
  final IconData icon;

  const _InfoTileData(this.title, this.value, this.icon);
}
