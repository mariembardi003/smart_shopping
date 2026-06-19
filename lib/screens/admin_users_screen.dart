import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../services/firestore_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  IconData _roleIcon(UserRole role) {
    return switch (role) {
      UserRole.client => Icons.person_outline,
      UserRole.cashier => Icons.storefront_outlined,
      UserRole.admin => Icons.shield_outlined,
    };
  }

  Color _roleColor(UserRole role) {
    return switch (role) {
      UserRole.client => Colors.blue.shade700,
      UserRole.cashier => Colors.orange.shade700,
      UserRole.admin => Colors.grey.shade700,
    };
  }

  bool _matchesSearch(AppUser user) {
    final term = _searchTerm.toLowerCase();
    if (term.isEmpty) return true;
    return user.name.toLowerCase().contains(term) ||
        user.email.toLowerCase().contains(term);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profils utilisateurs'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<AppUser>>(
        stream: FirestoreService().getUsers(roles: ['client', 'cashier']),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allUsers = snapshot.data ?? [];
          final users = allUsers.where(_matchesSearch).toList();

          if (users.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person_search_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text('Aucun utilisateur trouvé'),
                  const SizedBox(height: 12),
                  const Text(
                    'Les clients et caissiers apparaîtront ici lorsqu’ils auront un compte.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Rechercher par nom ou email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchTerm = value.trim();
                    });
                  },
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: _roleColor(
                            user.role,
                          ).withOpacity(0.15),
                          child: Icon(
                            _roleIcon(user.role),
                            color: _roleColor(user.role),
                          ),
                        ),
                        title: Text(
                          user.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(user.email),
                            if (user.phone != null &&
                                user.phone!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text('Tél: ${user.phone}'),
                            ],
                            const SizedBox(height: 4),
                            Text(
                              'Inscrit: ${_formatDate(user.createdAt)}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        trailing: Chip(
                          label: Text(user.role.label),
                          backgroundColor: _roleColor(
                            user.role,
                          ).withOpacity(0.15),
                          labelStyle: TextStyle(
                            color: _roleColor(user.role),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
