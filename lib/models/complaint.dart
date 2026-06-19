enum ComplaintStatus { open, answered, closed }

class Complaint {
  final String id;
  final String userId;
  final String userName;
  final String? userEmail;
  final String subject;
  final String message;
  final ComplaintStatus status;
  final String? response;
  final DateTime createdAt;

  Complaint({
    required this.id,
    required this.userId,
    required this.userName,
    this.userEmail,
    required this.subject,
    required this.message,
    required this.status,
    this.response,
    required this.createdAt,
  });

  factory Complaint.fromFirestore(String docId, Map<String, dynamic> data) {
    return Complaint(
      id: docId,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userEmail: data['userEmail'],
      subject: data['subject'] ?? '',
      message: data['message'] ?? '',
      status: ComplaintStatus.values.firstWhere(
        (role) => role.name == data['status'],
        orElse: () => ComplaintStatus.open,
      ),
      response: data['response'],
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'subject': subject,
      'message': message,
      'status': status.name,
      'response': response,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Complaint copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? subject,
    String? message,
    ComplaintStatus? status,
    String? response,
    DateTime? createdAt,
  }) {
    return Complaint(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      status: status ?? this.status,
      response: response ?? this.response,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
