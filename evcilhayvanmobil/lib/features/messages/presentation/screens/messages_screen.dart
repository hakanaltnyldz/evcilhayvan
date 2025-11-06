// lib/features/messages/presentation/screens/messages_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:evcilhayvanmobil/core/widgets/modern_background.dart';
import 'package:evcilhayvanmobil/features/messages/data/repositories/message_repository.dart';

class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Sohbetler'),
      ),
      body: ModernBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const _Header(),
                Expanded(
                  child: conversationsAsync.when(
                    data: (conversations) {
                      if (conversations.isEmpty) {
                        return const _EmptyConversations();
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          await ref.refresh(conversationsProvider.future);
                        },
                        child: ListView.separated(
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          padding: const EdgeInsets.only(bottom: 24, top: 12),
                          itemCount: conversations.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final conv = conversations[index];
                            return _ConversationCard(
                              title: conv.otherParticipant.name,
                              subtitle: conv.lastMessage.isNotEmpty
                                  ? conv.lastMessage
                                  : 'Sohbete başla',
                              petName: conv.relatedPet.name,
                              updatedAt: conv.updatedAt,
                              onTap: () {
                                context.pushNamed(
                                  'chat',
                                  pathParameters: {'conversationId': conv.id},
                                  extra: {
                                    'name': conv.otherParticipant.name,
                                    'avatar': conv.otherParticipant.avatarUrl,
                                  },
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                    loading: () => const _LoadingState(),
                    error: (error, stack) => _ErrorState(message: error.toString()),
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

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Topluluğunla bağlantıda kal',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sahiplenme süreçlerini ve yeni eşleşmeleri buradan takip et.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _ConversationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String petName;
  final DateTime updatedAt;
  final VoidCallback onTap;

  const _ConversationCard({
    required this.title,
    required this.subtitle,
    required this.petName,
    required this.updatedAt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.12),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor:
                  theme.colorScheme.primary.withOpacity(0.1),
              child: Text(
                title.isNotEmpty ? title[0].toUpperCase() : '?',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        _formatUpdatedAt(updatedAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.pets,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          petName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
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

class _EmptyConversations extends StatelessWidget {
  const _EmptyConversations();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wechat_outlined,
                size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Henüz bir konuşma yok',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Evcil dostlar hakkında konuşmaya başlamak için ilanlardan birine göz at.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 32),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: ShimmerTile(index: index),
        );
      },
    );
  }
}

class ShimmerTile extends StatefulWidget {
  final int index;
  const ShimmerTile({super.key, required this.index});

  @override
  State<ShimmerTile> createState() => _ShimmerTileState();
}

class _ShimmerTileState extends State<ShimmerTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final baseColor = Theme.of(context).colorScheme.surface;
        final highlightColor =
            Theme.of(context).colorScheme.primary.withOpacity(0.12);
        final t = 0.5 + (_controller.value * 0.5);
        final color = Color.lerp(baseColor, highlightColor, t)!;

        return Container(
          height: 86,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(24),
          ),
        );
      },
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
          Icon(Icons.error_outline, color: theme.colorScheme.error),
          const SizedBox(height: 12),
          Text(
            'Sohbetler yüklenemedi',
            style: theme.textTheme.titleMedium,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatUpdatedAt(DateTime time) {
  final hours = time.hour.toString().padLeft(2, '0');
  final minutes = time.minute.toString().padLeft(2, '0');
  return '$hours:$minutes';
}
