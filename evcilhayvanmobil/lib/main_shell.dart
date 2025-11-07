import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:evcilhayvanmobil/core/http.dart';
import 'package:evcilhayvanmobil/features/auth/data/repositories/auth_repository.dart';
import 'package:evcilhayvanmobil/core/theme/app_palette.dart';

class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _selectedIndex = 1;

  static const List<String> _routeNames = [
    'messages', // 0: Sohbetler
    'home', // 1: Sahiplen
    'connect', // 2: Bağlan
    'mating', // 3: Çiftleştir
    'profile', // 4: Profil
  ];

  void _onItemTapped(int index, BuildContext context) {
    final currentUser = ref.read(authProvider);
    if (currentUser == null && index != 1) {
      context.goNamed('login');
      return;
    }

    context.goNamed(_routeNames[index]);
  }

  void _updateCurrentIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();

    if (location.startsWith('/messages')) {
      _selectedIndex = 0;
    } else if (location.startsWith('/connect')) {
      _selectedIndex = 2;
    } else if (location.startsWith('/mating')) {
      _selectedIndex = 3;
    } else if (location.startsWith('/profile')) {
      _selectedIndex = 4;
    } else if (location == '/' || location.startsWith('/pet')) {
      _selectedIndex = 1;
    } else {
      _selectedIndex = 1; // Varsayılan
    }
  }

  @override
  Widget build(BuildContext context) {
    _updateCurrentIndex(context);
    final currentUser = ref.watch(authProvider);
    final theme = Theme.of(context);

    return SafeArea( // ✅ taşma önleyen katman
      child: Scaffold(
        resizeToAvoidBottomInset: false, // 🔧 alt taşma uyarılarını da susturur
        body: widget.child,
        floatingActionButton: (currentUser != null)
            ? DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppPalette.accentGradient,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppPalette.secondary.withOpacity(0.32),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: FloatingActionButton.extended(
                  onPressed: () {
                    context.pushNamed('create-pet');
                  },
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add),
                  label: const Text('Yeni İlan'),
                  elevation: 0,
                ),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppPalette.background.withOpacity(0.94),
                  theme.colorScheme.surfaceVariant.withOpacity(0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.18),
                  blurRadius: 28,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BottomNavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                currentIndex: _selectedIndex,
                onTap: (index) => _onItemTapped(index, context),
                type: BottomNavigationBarType.fixed,
                showSelectedLabels: true,
                showUnselectedLabels: false,
                selectedItemColor: theme.colorScheme.primary,
                unselectedItemColor: theme.colorScheme.onSurfaceVariant,
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: _MessagesNavIcon(
                      avatarUrl: _resolveAvatarUrl(currentUser?.avatarUrl),
                    ),
                    activeIcon: _MessagesNavIcon(
                      avatarUrl: _resolveAvatarUrl(currentUser?.avatarUrl),
                      isActive: true,
                    ),
                    label: 'Sohbetler',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.pets_outlined),
                    activeIcon: Icon(Icons.pets),
                    label: 'Sahiplen',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.people_alt_outlined),
                    activeIcon: Icon(Icons.people_alt),
                    label: 'Bağlan',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.favorite_border),
                    activeIcon: Icon(Icons.favorite),
                    label: 'Çiftleştir',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    activeIcon: Icon(Icons.person),
                    label: 'Profil',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MessagesNavIcon extends StatelessWidget {
  final String? avatarUrl;
  final bool isActive;

  const _MessagesNavIcon({
    this.avatarUrl,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (avatarUrl == null || avatarUrl!.isEmpty) {
      return Icon(
        isActive ? Icons.chat_bubble_rounded : Icons.chat_bubble_outline_rounded,
      );
    }

    final borderColor = isActive
        ? theme.colorScheme.primary.withOpacity(0.8)
        : theme.colorScheme.primary.withOpacity(0.4);

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.22),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: CircleAvatar(
        radius: 14,
        backgroundImage: NetworkImage(avatarUrl!),
      ),
    );
  }
}

String? _resolveAvatarUrl(String? path) {
  if (path == null || path.isEmpty) return null;
  if (path.startsWith('http')) return path;
  return '$apiBaseUrl$path';
}
