import 'package:evcilhayvanmobil/features/messages/domain/models/conservation.model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Conversation.fromJson', () {
    test('parses embedded related pet payloads safely', () {
      final json = {
        '_id': 'conversation-1',
        'participants': [
          {
            '_id': 'current-user',
            'name': 'Current User',
            'email': 'current@example.com',
            'role': 'user',
          },
          {
            '_id': 'other-user',
            'name': 'Other User',
            'email': 'other@example.com',
            'role': 'user',
          },
        ],
        'relatedPet': {
          '_id': 'pet-123',
          'name': 'Mırmır',
          'species': 'Cat',
          'breed': 'Tekir',
          'gender': 'Female',
          'ageMonths': 24,
          'vaccinated': true,
          'location': {
            'type': 'Point',
            'coordinates': [0.0, 0.0],
          },
          'isActive': true,
          'photos': <String>[],
        },
        'lastMessage': 'Merhaba!',
        'updatedAt': '2024-01-01T12:00:00.000Z',
      };

      final conversation = Conversation.fromJson(json, 'current-user');

      expect(conversation.relatedPet, isNotNull);
      expect(conversation.relatedPet!.id, 'pet-123');
      expect(conversation.relatedPetId, 'pet-123');
    });

    test('parses plain related pet identifiers without crashing', () {
      final json = {
        '_id': 'conversation-2',
        'participants': [
          {
            '_id': 'current-user',
            'name': 'Current User',
            'email': 'current@example.com',
            'role': 'user',
          },
          {
            '_id': 'other-user',
            'name': 'Other User',
            'email': 'other@example.com',
            'role': 'user',
          },
        ],
        'relatedPet': 'pet-456',
        'lastMessage': 'Selam!',
        'updatedAt': '2024-01-01T12:00:00.000Z',
      };

      final conversation = Conversation.fromJson(json, 'current-user');

      expect(conversation.relatedPet, isNull);
      expect(conversation.relatedPetId, 'pet-456');
    });
  });
}
