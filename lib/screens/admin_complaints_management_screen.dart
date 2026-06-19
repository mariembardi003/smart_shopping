import 'package:flutter/material.dart';
import '../models/complaint.dart';
import '../services/firestore_service.dart';

class AdminComplaintsManagementScreen extends StatefulWidget {
  const AdminComplaintsManagementScreen({super.key});

  @override
  State<AdminComplaintsManagementScreen> createState() =>
      _AdminComplaintsManagementScreenState();
}

class _AdminComplaintsManagementScreenState
    extends State<AdminComplaintsManagementScreen> {
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _statusColor(ComplaintStatus status) {
    return switch (status) {
      ComplaintStatus.open => Colors.orange.shade200,
      ComplaintStatus.answered => Colors.blue.shade200,
      ComplaintStatus.closed => Colors.green.shade200,
    };
  }

  String _statusLabel(ComplaintStatus status) {
    return switch (status) {
      ComplaintStatus.open => 'En attente',
      ComplaintStatus.answered => 'En cours de traitement',
      ComplaintStatus.closed => 'Résolue',
    };
  }

  Future<void> _showComplaintDetailsDialog(Complaint complaint) async {
    final responseController = TextEditingController(text: complaint.response ?? '');
    ComplaintStatus selectedStatus = complaint.status;
    bool isLoading = false;
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Détails de la réclamation'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Nom du client:', complaint.userName),
                const SizedBox(height: 12),
                _buildDetailRow('Email:', complaint.userEmail ?? 'N/A'),
                const SizedBox(height: 12),
                _buildDetailRow('Date:', _formatDate(complaint.createdAt)),
                const SizedBox(height: 12),
                _buildDetailRow('Objet:', complaint.subject),
                const SizedBox(height: 12),
                Text(
                  'Message:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(complaint.message),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),
                Text(
                  'Changer le statut:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                DropdownButton<ComplaintStatus>(
                  value: selectedStatus,
                  isExpanded: true,
                  items: ComplaintStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(_statusLabel(status)),
                    );
                  }).toList(),
                  onChanged: (status) {
                    if (status != null) setState(() => selectedStatus = status);
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'Réponse:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Form(
                  key: formKey,
                  child: TextFormField(
                    controller: responseController,
                    decoration: InputDecoration(
                      hintText: 'Ajouter une réponse...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    maxLines: 4,
                    validator: (value) {
                      if (selectedStatus == ComplaintStatus.answered &&
                          (value == null || value.isEmpty)) {
                        return 'Une réponse est requise pour marquer en cours';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setState(() => isLoading = true);

                      try {
                        await FirestoreService().respondToComplaint(
                          complaint.id,
                          responseController.text.trim(),
                          selectedStatus,
                        );

                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  const Text('Réclamation mise à jour avec succès'),
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
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(value),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gérer les réclamations'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Complaint>>(
        stream: FirestoreService().getComplaints(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final complaints = snapshot.data ?? [];

          if (complaints.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.mail_outline,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    const Text('Aucune réclamation'),
                    const SizedBox(height: 12),
                    const Text(
                      'Il n\'y a actuellement aucune réclamation à traiter.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              final complaint = complaints[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _statusColor(complaint.status),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      complaint.status == ComplaintStatus.open
                          ? Icons.mail_outline
                          : complaint.status == ComplaintStatus.answered
                              ? Icons.mail
                              : Icons.done_outline,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  title: Text(
                    complaint.subject,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('De: ${complaint.userName}'),
                      const SizedBox(height: 4),
                      Text(
                        'Statut: ${_statusLabel(complaint.status)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(complaint.createdAt),
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 18),
                    onPressed: () =>
                        _showComplaintDetailsDialog(complaint),
                  ),
                  isThreeLine: true,
                  onTap: () => _showComplaintDetailsDialog(complaint),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
