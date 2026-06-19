import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AdminCashierManagementScreen extends StatefulWidget {
  const AdminCashierManagementScreen({super.key});

  @override
  State<AdminCashierManagementScreen> createState() => _AdminCashierManagementScreenState();
}

class _AdminCashierManagementScreenState extends State<AdminCashierManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesSearch(AppUser user) {
    final term = _searchTerm.toLowerCase();
    if (term.isEmpty) return true;
    return user.name.toLowerCase().contains(term) ||
        user.email.toLowerCase().contains(term);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _showAddCashierDialog() async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Ajouter un caissier'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nom'),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Nom requis' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Email requis';
                      if (!value.contains('@')) return 'Email invalide';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Mot de passe'),
                    validator: (value) =>
                        (value == null || value.length < 6)
                            ? 'Minimum 6 caractères'
                            : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration:
                        const InputDecoration(labelText: 'Téléphone (optionnel)'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setState(() => isLoading = true);

                      try {
                        final user = await AuthService().createCashier(
                          emailController.text.trim(),
                          passwordController.text.trim(),
                          nameController.text.trim(),
                        );

                        // Update phone if provided
                        if (phoneController.text.isNotEmpty) {
                          await FirestoreService().updateUserData(
                            user.id,
                            {'phone': phoneController.text.trim()},
                          );
                        }

                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Caissier créé avec succès'),
                              backgroundColor: Colors.green.shade700,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erreur : $e'),
                              backgroundColor: Colors.red.shade700,
                            ),
                          );
                          setState(() => isLoading = false);
                        }
                      }
                    },
              child: const Text('Créer'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditCashierDialog(AppUser cashier) async {
    final nameController = TextEditingController(text: cashier.name);
    final emailController = TextEditingController(text: cashier.email);
    final phoneController = TextEditingController(text: cashier.phone ?? '');
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Modifier le caissier'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nom'),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Nom requis' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      helperText: 'Impossible de modifier l\'email',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration:
                        const InputDecoration(labelText: 'Téléphone (optionnel)'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setState(() => isLoading = true);

                      try {
                        await FirestoreService().updateUserData(
                          cashier.id,
                          {
                            'name': nameController.text.trim(),
                            'phone': phoneController.text.trim(),
                          },
                        );

                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Caissier modifié avec succès'),
                              backgroundColor: Colors.green.shade700,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erreur : $e'),
                              backgroundColor: Colors.red.shade700,
                            ),
                          );
                          setState(() => isLoading = false);
                        }
                      }
                    },
              child: const Text('Modifier'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteCashier(AppUser cashier) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
            'Êtes-vous sûr de vouloir supprimer le caissier "${cashier.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FirestoreService().deleteUserProfile(cashier.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Caissier supprimé avec succès'),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gérer les caissiers'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<AppUser>>(
        stream: FirestoreService().getCashiers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allCashiers = snapshot.data ?? [];
          final cashiers = allCashiers.where(_matchesSearch).toList();

          if (cashiers.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.storefront_outlined,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    const Text('Aucun caissier trouvé'),
                    const SizedBox(height: 12),
                    const Text(
                      'Créez un nouveau caissier pour commencer.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchTerm = value),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Rechercher par nom ou email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: _searchTerm.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchTerm = '');
                            },
                          )
                        : null,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cashiers.length,
                  itemBuilder: (context, index) {
                    final cashier = cashiers[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange.shade100,
                          child: Icon(
                            Icons.storefront_outlined,
                            color: Colors.orange.shade700,
                          ),
                        ),
                        title: Text(
                          cashier.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Email: ${cashier.email}'),
                            if (cashier.phone != null)
                              Text('Téléphone: ${cashier.phone}'),
                            Text(
                              'Créé: ${_formatDate(cashier.createdAt)}',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: const Text('Modifier'),
                              onTap: () =>
                                  _showEditCashierDialog(cashier),
                            ),
                            PopupMenuItem(
                              child: const Text('Supprimer',
                                  style: TextStyle(color: Colors.red)),
                              onTap: () => _deleteCashier(cashier),
                            ),
                          ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCashierDialog,
        backgroundColor: Colors.green.shade700,
        child: const Icon(Icons.add),
      ),
    );
  }
}
