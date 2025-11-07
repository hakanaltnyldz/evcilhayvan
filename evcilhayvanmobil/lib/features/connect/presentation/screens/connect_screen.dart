// lib/features/connect/presentation/screens/connect_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:evcilhayvanmobil/core/http.dart';
import 'package:evcilhayvanmobil/core/theme/app_palette.dart';
import 'package:evcilhayvanmobil/core/widgets/modern_background.dart';
import 'package:evcilhayvanmobil/features/auth/data/repositories/auth_repository.dart';
import 'package:evcilhayvanmobil/features/auth/domain/user_model.dart';
import 'package:evcilhayvanmobil/features/messages/data/repositories/message_repository.dart';
import 'package:evcilhayvanmobil/features/messages/domain/models/conservation.model.dart';
import 'package:evcilhayvanmobil/features/pets/data/repositories/pets_repository.dart';
import 'package:evcilhayvanmobil/features/pets/domain/models/pet_model.dart';

enum _ConnectViewMode { conversations, community }

final _connectViewModeProvider = StateProvider<_ConnectViewMode>(
  (ref) => _ConnectViewMode.community,
);

final _conversationPetProvider =
    FutureProvider.autoDispose.family<Pet?, String>((ref, petId) async {
  final repo = ref.watch(petsRepositoryProvider);
  try {
    return await repo.getPetById(petId);
  } catch (_) {
    return null;
  }
});

class ConnectScreen extends ConsumerWidget {
  const ConnectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsyncValue = ref.watch(allUsersProvider);
    final viewMode = ref.watch(_connectViewModeProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Topluluğu Keşfet'),
      ),
      body: ModernBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _ConnectHero(),
                const SizedBox(height: 20),
                const _ModeSwitcher(),
                const SizedBox(height: 16),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: viewMode == _ConnectViewMode.community
                        ? _CommunityList(
                            key: const ValueKey('community'),
                            usersAsyncValue: usersAsyncValue,
                          )
                        : const _ConversationsPanel(
                            key: ValueKey('conversations'),
                          ),
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

class _UserCard extends StatelessWidget {
  final String name;
  final String? city;
  final String? about;
  final String? avatarUrl;
  final VoidCallback onMessageTap;

  const _UserCard({
    required this.name,
    required this.city,
    required this.about,
    required this.avatarUrl,
    required this.onMessageTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [
            AppPalette.heroGradient.first.withOpacity(0.12),
            AppPalette.heroGradient.last.withOpacity(0.18),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.12),
            blurRadius: 22,
            offset: const Offset(0, 14),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.06),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -6,
            right: -6,
            child: Icon(
              Icons.pets,
              size: 48,
              color: theme.colorScheme.primary.withOpacity(0.08),
            ),
          ),
          Row(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundImage:
                    avatarUrl != null ? CachedNetworkImageProvider(avatarUrl!) : null,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                child: avatarUrl == null
                    ? Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: theme.textTheme.titleLarge,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (city != null && city!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on,
                                size: 16, color: theme.colorScheme.primary),
                            const SizedBox(width: 4),
                            Text(city!, style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ),
                    if (about != null && about!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        about!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: onMessageTap,
                icon: const Icon(Icons.chat_bubble_rounded),
                label: const Text('Sohbet'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModeSwitcher extends ConsumerWidget {
  const _ModeSwitcher();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mode = ref.watch(_connectViewModeProvider);
    final notifier = ref.read(_connectViewModeProvider.notifier);

    Widget buildSegment(String label, _ConnectViewMode value) {
      final bool isSelected = mode == value;
      return Expanded(
        child: GestureDetector(
          onTap: () => notifier.state = value,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surface.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.28),
                        blurRadius: 18,
                        offset: const Offset(0, 12),
                      ),
                    ]
                  : [],
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.12),
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.75),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.08),
        ),
      ),
      child: Row(
        children: [
          buildSegment('Topluluk', _ConnectViewMode.community),
          const SizedBox(width: 8),
          buildSegment('Sohbetlerim', _ConnectViewMode.conversations),
        ],
      ),
    );
  }
}

class _CommunityList extends ConsumerWidget {
  final AsyncValue<List<User>> usersAsyncValue;

  const _CommunityList({super.key, required this.usersAsyncValue});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return usersAsyncValue.when(
      data: (users) {
        if (users.isEmpty) {
          return const _EmptyConnectState();
        }
        return ListView.separated(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: users.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final user = users[index];
            return _UserCard(
              name: user.name,
              city: user.city,
              about: user.about,
              avatarUrl: _resolveAvatarUrl(user.avatarUrl),
              onMessageTap: () => _handleStartConversation(context, ref, user),
            );
          },
        );
      },
      loading: () => const _LoadingList(),
      error: (error, stackTrace) => _ErrorState(message: error.toString()),
    );
  }

  Future<void> _handleStartConversation(
      BuildContext context, WidgetRef ref, User user) async {
    final currentUser = ref.read(authProvider);

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Diğer kullanıcılarla sohbet için giriş yapın.'),
        ),
      );
      return;
    }

    if (currentUser.id == user.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bu profil zaten sizin!'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _ProgressDialog(),
    );

    try {
      final conversation = await ref.read(messageRepositoryProvider).createOrGetConversation(
            participantId: user.id,
            currentUserId: currentUser.id,
          );
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      ref.invalidate(conversationsProvider);
      ref.read(_connectViewModeProvider.notifier).state = _ConnectViewMode.conversations;
      context.pushNamed(
        'chat',
        pathParameters: {'conversationId': conversation.id},
        extra: {
          'name': user.name,
          'avatar': _resolveAvatarUrl(user.avatarUrl),
        },
      );
    } catch (error) {
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }
}

class _ConversationsPanel extends ConsumerWidget {
  const _ConversationsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider);
    if (currentUser == null) {
      return const _LoginRequiredCard();
    }

    final conversationsAsync = ref.watch(conversationsProvider);
    return conversationsAsync.when(
      data: (conversations) {
        if (conversations.isEmpty) {
          return const _EmptyConversationsPanel();
        }
        return RefreshIndicator(
          onRefresh: () async {
            await ref.refresh(conversationsProvider.future);
          },
          child: ListView.separated(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: conversations.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              return _ConversationPreviewCard(conversation: conversation);
            },
          ),
        );
      },
      loading: () => const _LoadingList(),
      error: (error, stackTrace) => _ErrorState(message: error.toString()),
    );
  }
}

class _ConversationPreviewCard extends ConsumerWidget {
  final Conversation conversation;

  const _ConversationPreviewCard({required this.conversation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    Pet? pet = conversation.relatedPet;
    AsyncValue<Pet?>? petAsync;
    if (pet == null && conversation.relatedPetId != null) {
      petAsync = ref.watch(_conversationPetProvider(conversation.relatedPetId!));
      pet = petAsync.valueOrNull;
    }

    final bool isPetLoading = petAsync?.isLoading ?? false;
    final avatarUrl = _resolveAvatarUrl(conversation.otherParticipant.avatarUrl);

    void openChat() {
      ref.read(_connectViewModeProvider.notifier).state = _ConnectViewMode.conversations;
      context.pushNamed(
        'chat',
        pathParameters: {'conversationId': conversation.id},
        extra: {
          'name': conversation.otherParticipant.name,
          'avatar': avatarUrl,
        },
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: openChat,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: [
                AppPalette.heroGradient.first.withOpacity(0.16),
                AppPalette.heroGradient.last.withOpacity(0.18),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.12),
                blurRadius: 22,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundImage:
                            avatarUrl != null ? CachedNetworkImageProvider(avatarUrl) : null,
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                        child: avatarUrl == null
                            ? Text(
                                conversation.otherParticipant.name.isNotEmpty
                                    ? conversation.otherParticipant.name[0].toUpperCase()
                                    : '?',
                                style: theme.textTheme.titleLarge,
                              )
                            : null,
                      ),
                      if (pet != null)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.pets, size: 14, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                pet.name,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (isPetLoading)
                        Positioned(
                          bottom: -6,
                          left: 6,
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          conversation.otherParticipant.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          pet != null
                              ? 'İlan üzerinden sohbet ediyorsunuz.'
                              : 'Sohbet detaylarını görmek için açın.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: theme.colorScheme.primary),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                conversation.lastMessage.isNotEmpty
                    ? conversation.lastMessage
                    : 'Sohbete başlamak için mesaj gönderin.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              if (conversation.relatedPetId != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: TextButton.icon(
                    onPressed: () {
                      context.pushNamed(
                        'pet-detail',
                        pathParameters: {'petId': conversation.relatedPetId!},
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                    ),
                    icon: const Icon(Icons.photo_album_outlined),
                    label: const Text('İlana git'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginRequiredCard extends StatelessWidget {
  const _LoginRequiredCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_outline, size: 58, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Sohbetlerini görmek için giriş yap',
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Toplulukta sohbetleri takip etmek için hesabına giriş yap ya da hemen kayıt ol.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyConversationsPanel extends StatelessWidget {
  const _EmptyConversationsPanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline,
              size: 60, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Henüz bir sohbet yok',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'İlan detaylarından mesaj göndererek ilk sohbetini başlat.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectHero extends StatelessWidget {
  const _ConnectHero();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: [
            AppPalette.heroGradient.first.withOpacity(0.3),
            AppPalette.heroGradient.last.withOpacity(0.32),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.12),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Topluluğu keşfet',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Hayvanseverlerle tanış, minik dostlarına yeni arkadaşlar bul. Sohbet başlatarak iletişime geç.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.75),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    _HeroTag(icon: Icons.chat, label: 'Canlı sohbet'),
                    _HeroTag(icon: Icons.favorite, label: 'Güvenli eşleşme'),
                    _HeroTag(icon: Icons.pets, label: 'Mutlu patiler'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Image.network(
              'https://images.unsplash.com/photo-1583511655826-05700d52f4d9?auto=format&fit=crop&w=420&q=80',
              width: 110,
              height: 140,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 110,
                height: 140,
                color: theme.colorScheme.primary.withOpacity(0.1),
                child: Icon(
                  Icons.pets,
                  size: 42,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroTag extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroTag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppPalette.accentGradient,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppPalette.secondary.withOpacity(0.22),
            blurRadius: 14,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyConnectState extends StatelessWidget {
  const _EmptyConnectState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sentiment_satisfied_alt,
              size: 64, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Henüz kimse burada değil',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'İlk bağlantıyı sen kur ve topluluğu hareketlendir.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_outline, size: 54, color: theme.colorScheme.error),
          const SizedBox(height: 12),
          Text(
            'Bağlanmak için giriş yap',
            style: theme.textTheme.titleMedium,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      itemCount: 5,
      itemBuilder: (context, index) {
        return const _LoadingCard();
      },
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.surface;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      height: 110,
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(26),
      ),
    );
  }
}

String? _resolveAvatarUrl(String? path) {
  if (path == null || path.isEmpty) return null;
  if (path.startsWith('http')) return path;
  return '$apiBaseUrl$path';
}

class _ProgressDialog extends StatelessWidget {
  const _ProgressDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Sohbet hazırlanıyor...'),
          ],
        ),
      ),
    );
  }
}
