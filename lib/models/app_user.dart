enum UserRole { client, admin, cashier }

extension UserRoleX on UserRole {
  String get label {
    return switch (this) {
      UserRole.client => 'Client',
      UserRole.admin => 'Admin',
      UserRole.cashier => 'Caissier',
    };
  }
}

class AppUser {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? phone;
  final String? address;
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phone,
    this.address,
    required this.createdAt,
  });

  factory AppUser.fromFirestore(String docId, Map<String, dynamic> data) {
    final roleString = data['role'] as String? ?? 'client';
    return AppUser(
      id: docId,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: UserRole.values.firstWhere(
        (value) => value.name == roleString,
        orElse: () => UserRole.client,
      ),
      phone: data['phone'],
      address: data['address'],
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'role': role.name,
      'phone': phone,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    String? phone,
    String? address,
    DateTime? createdAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
