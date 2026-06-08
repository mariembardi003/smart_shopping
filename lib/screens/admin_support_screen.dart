import 'package:flutter/material.dart';
import '../models/complaint.dart';
import '../services/firestore_service.dart';

class AdminSupportScreen extends StatefulWidget {
  const AdminSupportScreen({super.key});

  @override
  State<AdminSupportScreen> createState() => _AdminSupportScreenState();
}

class _AdminSupportScreenState extends State<AdminSupportScreen> {
  Widget _statusChip(ComplaintStatus status) {
    final color = switch (status) {
      ComplaintStatus.open => Colors.orange.shade200,
      ComplaintStatus.answered => Colors.blue.shade200,
      ComplaintStatus.closed => Colors.green.shade200,
    };
    return Chip(
      label: Text(status.name.toUpperCase()),
      backgroundColor: color,
    );
  }

  Future<void> _replyToComplaint(Complaint complaint) async {
    final controller = TextEditingController(text: complaint.response ?? '');
    ComplaintStatus selectedStatus = complaint.status;
    final stateContext = context;

    await showDialog<void>(
      context: stateContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Répondre à la réclamation'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: controller,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Réponse'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ComplaintStatus>(
                initialValue: selectedStatus,
                items: ComplaintStatus.values.map((value) {
                  return DropdownMenuItem(value: value, child: Text(value.name.toUpperCase()));
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    selectedStatus = value;
                  });
                },
                decoration: const InputDecoration(labelText: 'Statut'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              final response = controller.text.trim();
              final navigator = Navigator.of(dialogContext);
              await FirestoreService().respondToComplaint(
                complaint.id,
                response,
                selectedStatus,
              );
              if (!mounted) return;
              navigator.pop();
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réclamations clients'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Complaint>>(
        stream: FirestoreService().getComplaints(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.support_agent, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text('Aucune réclamation pour le moment'),
                ],
              ),
            );
          }
          final complaints = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: complaints.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final complaint = complaints[index];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            complaint.subject,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          _statusChip(complaint.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Client: ${complaint.userName}'),
                      const SizedBox(height: 8),
                      Text(complaint.message),
                      if (complaint.response != null && complaint.response!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Text('Réponse:', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(complaint.response!),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _replyToComplaint(complaint),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
                              child: const Text('Répondre'),
                            ),
                          ),
                        ],
                      ),
                    ],
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
