// lib/features/mating/presentation/screens/mating_screen.dart
import 'package:flutter/material.dart';

import 'package:evcilhayvanmobil/core/theme/app_palette.dart';
import 'package:evcilhayvanmobil/core/widgets/modern_background.dart';

class MatingScreen extends StatefulWidget {
  const MatingScreen({super.key});

  @override
  State<MatingScreen> createState() => _MatingScreenState();
}

class _MatingScreenState extends State<MatingScreen> {
  final List<String> _species = const ['Tümü', 'Köpek', 'Kedi', 'Kuş'];
  String _selectedSpecies = 'Tümü';
  String _selectedGender = 'Tümü';
  double _maxDistance = 20;

  final List<_MatingProfile> _profiles = const [
    _MatingProfile(
      name: 'Milo',
      breed: 'Golden Retriever',
      gender: 'Erkek',
      distance: 4,
      age: '2 yaş',
      imageUrl:
          'https://images.unsplash.com/photo-1558944351-c1f4588d39c5?auto=format&fit=crop&w=400&q=80',
    ),
    _MatingProfile(
      name: 'Luna',
      breed: 'British Shorthair',
      gender: 'Dişi',
      distance: 8,
      age: '1.5 yaş',
      imageUrl:
          'https://images.unsplash.com/photo-1518791841217-8f162f1e1131?auto=format&fit=crop&w=400&q=80',
    ),
    _MatingProfile(
      name: 'Zuzu',
      breed: 'Muhabbet Kuşu',
      gender: 'Erkek',
      distance: 2,
      age: '8 aylık',
      imageUrl:
          'https://images.unsplash.com/photo-1501700493788-fa1a4fc9fe62?auto=format&fit=crop&w=400&q=80',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _profiles.where((profile) {
      final matchesSpecies =
          _selectedSpecies == 'Tümü' || profile.species == _selectedSpecies;
      final matchesGender =
          _selectedGender == 'Tümü' || profile.gender == _selectedGender;
      final matchesDistance = profile.distance <= _maxDistance;
      return matchesSpecies && matchesGender && matchesDistance;
    }).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Eşleşme Bul'),
      ),
      body: ModernBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Evcil dostların için uygun eşleşmeleri keşfet.',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _FilterChips(
                  label: 'Tür',
                  values: _species,
                  selectedValue: _selectedSpecies,
                  onSelected: (value) => setState(() => _selectedSpecies = value),
                ),
                const SizedBox(height: 12),
                _FilterChips(
                  label: 'Cinsiyet',
                  values: const ['Tümü', 'Erkek', 'Dişi'],
                  selectedValue: _selectedGender,
                  onSelected: (value) => setState(() => _selectedGender = value),
                ),
                const SizedBox(height: 12),
                Text(
                  'Maksimum mesafe: ${_maxDistance.round()} km',
                  style: theme.textTheme.bodyMedium,
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: theme.colorScheme.primary,
                    inactiveTrackColor:
                        theme.colorScheme.primary.withOpacity(0.15),
                    thumbColor: theme.colorScheme.secondary,
                    overlayColor: theme.colorScheme.secondary.withOpacity(0.12),
                  ),
                  child: Slider(
                    value: _maxDistance,
                    min: 1,
                    max: 50,
                    divisions: 49,
                    label: '${_maxDistance.round()} km',
                    onChanged: (value) => setState(() => _maxDistance = value),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: filtered.isEmpty
                      ? const _EmptyState()
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final profile = filtered[index];
                            return _ProfileCard(profile: profile);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final String label;
  final List<String> values;
  final String selectedValue;
  final ValueChanged<String> onSelected;

  const _FilterChips({
    required this.label,
    required this.values,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleSmall),
        const SizedBox(height: 6),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: values.map((value) {
            final isSelected = value == selectedValue;
            return FilterChip(
              label: Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isSelected
                      ? Colors.white
                      : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => onSelected(value),
              showCheckmark: false,
              backgroundColor: theme.colorScheme.surface,
              selectedColor: theme.colorScheme.primary,
              side: BorderSide(
                color: isSelected
                    ? Colors.transparent
                    : theme.colorScheme.primary.withOpacity(0.12),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final _MatingProfile profile;

  const _ProfileCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.12),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
        border: Border.all(
          color: AppPalette.primary.withOpacity(0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: Image.network(
              profile.imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        profile.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        profile.gender,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${profile.breed} · ${profile.age}',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.map_outlined,
                        size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 6),
                    Text(
                      '${profile.distance} km yakınında',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.info_outline),
                        label: const Text('Detaylar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.favorite_outline),
                        label: const Text('Eşleşme iste'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 60, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Filtreleri gevşetmeyi deneyin',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Yakınında henüz uygun eşleşme bulunamadı.',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _MatingProfile {
  final String name;
  final String breed;
  final String gender;
  final double distance;
  final String age;
  final String imageUrl;

  const _MatingProfile({
    required this.name,
    required this.breed,
    required this.gender,
    required this.distance,
    required this.age,
    required this.imageUrl,
  });

  String get species {
    if (breed.toLowerCase().contains('köpek')) return 'Köpek';
    if (breed.toLowerCase().contains('kedi')) return 'Kedi';
    if (breed.toLowerCase().contains('kuş')) return 'Kuş';
    return 'Tümü';
  }
}
