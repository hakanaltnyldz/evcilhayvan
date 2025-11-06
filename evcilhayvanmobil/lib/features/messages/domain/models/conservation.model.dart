// lib/features/messages/domain/models/conversation_model.dart

import '../../../auth/domain/user_model.dart';
import '../../../pets/domain/models/pet_model.dart'; // Pet modeli

class Conversation {
  final String id;
  // Sohbetteki diğer kişi (kendimiz hariç)
  final User otherParticipant; 
  // Hangi ilan üzerinden eşleşildi
  final Pet relatedPet; 
  final String lastMessage;
  final DateTime updatedAt;

  Conversation({
    required this.id,
    required this.otherParticipant,
    required this.relatedPet,
    required this.lastMessage,
    required this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json, String currentUserId) {
    // Katılımcı listesinden kendimizi çıkarıp diğer kişiyi bulmalıyız.
    final List<dynamic> participantsJson = json['participants'];
    final Map<String, dynamic> otherParticipantJson = participantsJson.firstWhere(
      (p) => p['_id'] != currentUserId,
      orElse: () => participantsJson.first, // Tek kişi varsa (hatalı veri) kendisini al
    );

    return Conversation(
      id: json['_id'],
      otherParticipant: User.fromJson(otherParticipantJson),
      relatedPet: Pet.fromJson(json['relatedPet']),
      lastMessage: json['lastMessage'] ?? "Sohbeti Başlatın",
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}