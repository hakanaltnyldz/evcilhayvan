// lib/features/connect/presentation/screens/connect_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:evcilhayvanmobil/core/http.dart';
import 'package:evcilhayvanmobil/core/widgets/modern_background.dart';
import 'package:evcilhayvanmobil/features/auth/data/repositories/auth_repository.dart';
import 'package:evcilhayvanmobil/features/messages/data/repositories/message_repository.dart';

class ConnectScreen extends ConsumerWidget {
  const ConnectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsyncValue = ref.watch(allUsersProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Topluluğu Keşfet'),
      ),
      body: ModernBackground(
        child: SafeArea(
          child: usersAsyncValue.when(
            data: (users) {
              if (users.isEmpty) {
                return const _EmptyConnectState();
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return _UserCard(
                    name: user.name,
                    city: user.city,
                    about: user.about,
                    avatarUrl: user.avatarUrl != null
                        ? '${apiBaseUrl}${user.avatarUrl}'
                        : null,
                    onMessageTap: () async {
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
                        final repo = ref.read(messageRepositoryProvider);
                        final conversation = await repo.createOrGetConversation(
                          participantId: user.id,
                          currentUserId: currentUser.id,
                        );
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          context.pushNamed(
                            'chat',
                            pathParameters: {'conversationId': conversation.id},
                            extra: {
                              'name': user.name,
                              'avatar': user.avatarUrl != null
                                  ? '${apiBaseUrl}${user.avatarUrl}'
                                  : null,
                            },
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
                      }
                    },
                  );
                },
              );
            },
            loading: () => const _LoadingList(),
            error: (error, stackTrace) {
              return _ErrorState(message: error.toString());
            },
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
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundImage: avatarUrl != null ? CachedNetworkImageProvider(avatarUrl!) : null,
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
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(city!, style: theme.textTheme.bodySmall),
                    ],
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
          FilledButton.tonalIcon(
            onPressed: onMessageTap,
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Sohbet'),
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
