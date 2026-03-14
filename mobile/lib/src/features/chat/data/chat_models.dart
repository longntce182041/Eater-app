class ChatMessage {
  final String id;
  final String senderId;
  final String senderRole; // "user" | "nutritionist"
  final String content;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderRole,
    required this.content,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      senderRole: json['senderRole'] as String? ?? 'user',
      content: json['content'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}

class NutritionistInfo {
  final String id;
  final String fullName;
  final String specialization;
  final int experience;
  final String? email;

  const NutritionistInfo({
    required this.id,
    required this.fullName,
    required this.specialization,
    required this.experience,
    this.email,
  });

  factory NutritionistInfo.fromJson(Map<String, dynamic> json) {
    return NutritionistInfo(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName'] as String? ?? '',
      specialization: json['specialization'] as String? ?? '',
      experience: (json['experience'] as num?)?.toInt() ?? 0,
      email: json['email'] as String?,
    );
  }
}

