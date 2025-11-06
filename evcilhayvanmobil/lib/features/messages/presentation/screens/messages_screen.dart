// lib/features/messages/presentation/screens/messages_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:evcilhayvanmobil/features/messages/data/repositories/message_repository.dart';
import 'package:go_router/go_router.dart';

class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mesajlar'),
      ),
      body: conversationsAsync.when(
        data: (conversations) {
          if (conversations.isEmpty) {
            return const Center(
              child: Text('Henüz bir konuşma yok.'),
            );
          }

          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conv = conversations[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(conv.otherParticipant.name.isNotEmpty
                      ? conv.otherParticipant.name[0].toUpperCase()
                      : '?'),
                ),
                title: Text(conv.otherParticipant.name),
                subtitle: Text(
                  conv.lastMessage.isNotEmpty
                      ? conv.lastMessage
                      : 'Sohbete başla',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Chat ekranına yönlendir
                  context.pushNamed(
                    'chat',
                    pathParameters: {'conversationId': conv.id},
                    extra: conv.otherParticipant.name,
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Hata: ${error.toString()}')),
      ),
    );
  }
}
