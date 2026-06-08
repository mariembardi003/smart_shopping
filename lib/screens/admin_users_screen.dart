import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../services/firestore_service.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  Future<void> _changeRole(BuildContext context, AppUser user) async {
    final selectedRole = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Changer le rôle'),
          children: UserRole.values.map((role) {
            return SimpleDialogOption(
              onPressed: () => Navigator.pop(context, role.name),
              child: Text(role.name.toUpperCase()),
            );
          }).toList(),
        );
      },
    );

    if (selectedRole != null) {
      await FirestoreService().updateUserRole(user.id, selectedRole);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des caissiers'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<AppUser>>(
        stream: FirestoreService().getUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_search_outlined, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text('Aucun utilisateur trouvé'),
                ],
              ),
            );
          }
          final users = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  title: Text(user.name),
                  subtitle: Text('${user.email}\nRôle: ${user.role.name}'),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.green),
                    onPressed: () => _changeRole(context, user),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
