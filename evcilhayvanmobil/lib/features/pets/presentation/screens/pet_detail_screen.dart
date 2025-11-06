// lib/features/pets/presentation/screens/pet_detail_screen.dart
import 'dart:ui';
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
        elevation: 0,
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
            child: SafeArea(
              top: false,
              bottom: false,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
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
                                const SizedBox(height: 16),
                                _PetBioCard(pet: pet),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),
                          _DetailChips(pet: pet),
                          const SizedBox(height: 28),
                          _InfoGrid(pet: pet),
                          const SizedBox(height: 28),
                          _HighlightsSection(pet: pet),
                          const SizedBox(height: 28),
                          _OwnerSection(pet: pet),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (isOwner)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: _OwnerInfoBanner(),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
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
      bottomNavigationBar:
          petAsyncValue.maybeWhen(
            data: (pet) {
              final bool isOwner = (currentUser?.id == pet.owner?.id);
              if (currentUser != null && !isOwner) {
                return _ActionButtons(pet: pet);
              }
              return null;
            },
            orElse: () => null,
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

    final locationCoordinates = pet.location['coordinates'];
    final hasCoordinates =
        locationCoordinates is List && locationCoordinates.length == 2;

    return Stack(
      children: [
        Hero(
          tag: heroTag,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(36),
              bottomRight: Radius.circular(36),
            ),
            child: SizedBox(
              height: 340,
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
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.65),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 60,
          right: 24,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.6, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white.withOpacity(0.18),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.25),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shield_rounded,
                        color: Colors.white.withOpacity(0.9),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        pet.isActive ? 'Yayında' : 'Pasif',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: Colors.white.withOpacity(0.85),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.place_rounded,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          hasCoordinates
                              ? 'Konum: ${locationCoordinates[1]}, ${locationCoordinates[0]}'
                              : 'Konum bilgisi paylaşılmadı',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
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
      _InfoTileData('İlan Durumu', pet.isActive ? 'Yayında' : 'Pasif', Icons.waving_hand_outlined),
    ];

    return GridView.builder(
      shrinkWrap: true,
      itemCount: items.length,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.8,
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.12),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.18),
              child: Text(
                avatarLetter,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ownerName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'İlan sahibi ile iletişime geçmek için mesaj gönder.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey[600]),
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
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(24, 12, 24, 20),
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
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () { /* TODO: Pass */ },
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                  label: const Text('Mesaj At'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () { /* TODO: Like */ },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.favorite_rounded, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Beğen'),
                    ],
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

class _PetBioCard extends StatelessWidget {
  final Pet pet;

  const _PetBioCard({required this.pet});

  @override
  Widget build(BuildContext context) {
    final ageInYears = pet.ageMonths ~/ 12;
    final remainingMonths = pet.ageMonths % 12;
    final ageLabel = ageInYears > 0
        ? '${ageInYears.toString()} yaş${remainingMonths > 0 ? ' ${remainingMonths.toString()} ay' : ''}'
        : '${pet.ageMonths} aylık';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.15),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.pets, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${pet.species} • ${pet.gender}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Yaklaşık $ageLabel',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            pet.bio?.isNotEmpty == true
                ? pet.bio!
                : 'Bu sevimli dostumuz hakkında yakında daha fazla bilgi paylaşılacak.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _DetailChips extends StatelessWidget {
  final Pet pet;

  const _DetailChips({required this.pet});

  List<_ChipData> _buildChips() {
    final chips = <_ChipData>[
      _ChipData(
        label: pet.species,
        icon: Icons.pets_outlined,
      ),
      _ChipData(
        label: pet.gender,
        icon: pet.gender.toLowerCase().contains('erkek')
            ? Icons.male_rounded
            : Icons.female_rounded,
      ),
      _ChipData(
        label: pet.vaccinated ? 'Aşıları Tam' : 'Aşı Gerekiyor',
        icon: pet.vaccinated ? Icons.health_and_safety : Icons.medical_information,
      ),
      _ChipData(
        label: pet.ageMonths < 12 ? 'Yavruluk Dönemi' : 'Yetişkin',
        icon: pet.ageMonths < 12 ? Icons.emoji_nature : Icons.star_rounded,
      ),
    ];

    return chips;
  }

  @override
  Widget build(BuildContext context) {
    final chips = _buildChips();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 24 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: chips
            .map(
              (chip) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.08),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      chip.icon,
                      size: 18,
                      color: const Color(0xFF6366F1),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      chip.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _HighlightsSection extends StatelessWidget {
  final Pet pet;

  const _HighlightsSection({required this.pet});

  List<_HighlightInfo> _buildHighlights() {
    final ageInYears = pet.ageMonths ~/ 12;
    final remainingMonths = pet.ageMonths % 12;
    final ageLabel = ageInYears > 0
        ? '${ageInYears.toString()} yaş${remainingMonths > 0 ? ' ${remainingMonths.toString()} ay' : ''}'
        : '${pet.ageMonths} aylık';

    return [
      _HighlightInfo(
        icon: Icons.favorite_border_rounded,
        title: 'Sevgi Dolu Bir Dost',
        description:
            'Güvenli ve sevgi dolu bir yuva arıyor. Ona vakit ayıracak, oyun oynayacak bir aileye hazır.',
      ),
      _HighlightInfo(
        icon: Icons.health_and_safety,
        title: pet.vaccinated ? 'Aşıları Tam' : 'Aşı Takibi Gerekebilir',
        description: pet.vaccinated
            ? 'Veteriner kontrolleri düzenli yapılmış, aşıları tamamlanmış durumda.'
            : 'Sahiplenildikten sonra veteriner kontrolü ile aşı takvimi güncellenmeli.',
      ),
      _HighlightInfo(
        icon: Icons.timeline_rounded,
        title: 'Yaş Bilgisi',
        description: 'Şu an $ageLabel. Yeni evine uyum sağlaması için sakin ve sabırlı olmak önemli.',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final highlights = _buildHighlights();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Öne Çıkan Özellikler',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 16),
        ...List.generate(highlights.length, (index) {
          final highlight = highlights[index];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1),
            duration: Duration(milliseconds: 350 + index * 120),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: Container(
              margin: EdgeInsets.only(bottom: index == highlights.length - 1 ? 0 : 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      highlight.icon,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          highlight.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          highlight.description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                height: 1.5,
                                color: Colors.grey[700],
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _HighlightInfo {
  final IconData icon;
  final String title;
  final String description;

  const _HighlightInfo({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _ChipData {
  final String label;
  final IconData icon;

  const _ChipData({required this.label, required this.icon});
}

class _OwnerInfoBanner extends StatelessWidget {
  const _OwnerInfoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.celebration_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bu ilan size ait',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'İlanını güncel tutarak daha fazla ilgi çekebilirsin. Fotoğraf ve açıklama eklemeyi unutma!',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(height: 1.5, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
