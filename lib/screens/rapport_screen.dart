import 'package:flutter/material.dart';
import '../models/rapport.dart';
import '../services/db_helper.dart';

class RapportScreen extends StatefulWidget {
  const RapportScreen({super.key});

  @override
  State<RapportScreen> createState() => _RapportScreenState();
}

class _RapportScreenState extends State<RapportScreen> {
  final DBHelper _dbHelper = DBHelper();
  List<Rapport> _rapports = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRapports();
  }

  Future<void> _loadRapports() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Rapport> rapports = await _dbHelper.getAllRapports();
      setState(() {
        _rapports = rapports;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addRapport() async {
    final enginIdController = TextEditingController();
    final usageController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Ajouter un Rapport'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: enginIdController,
                  decoration: const InputDecoration(
                    labelText: 'ID de l\'engin',
                    hintText: 'Ex: 123',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: usageController,
                  decoration: const InputDecoration(
                    labelText: 'Usage (heures)',
                    hintText: 'Ex: 8.5',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setDialogState(() {
                            selectedDate = date;
                          });
                        }
                      },
                      child: const Text('Changer'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (enginIdController.text.isNotEmpty && usageController.text.isNotEmpty) {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      try {
        final rapport = Rapport(
          enginId: int.parse(enginIdController.text),
          date: selectedDate.toIso8601String().split('T')[0],
          usage: double.parse(usageController.text),
        );

        await _dbHelper.insertRapport(rapport);
        await _loadRapports();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rapport ajouté avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'ajout: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _editRapport(Rapport rapport) async {
    final enginIdController = TextEditingController(text: rapport.enginId.toString());
    final usageController = TextEditingController(text: rapport.usage.toString());
    DateTime selectedDate = DateTime.parse(rapport.date);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Modifier le Rapport'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: enginIdController,
                  decoration: const InputDecoration(
                    labelText: 'ID de l\'engin',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: usageController,
                  decoration: const InputDecoration(
                    labelText: 'Usage (heures)',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setDialogState(() {
                            selectedDate = date;
                          });
                        }
                      },
                      child: const Text('Changer'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (enginIdController.text.isNotEmpty && usageController.text.isNotEmpty) {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('Modifier'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      try {
        final updatedRapport = Rapport(
          id: rapport.id,
          enginId: int.parse(enginIdController.text),
          date: selectedDate.toIso8601String().split('T')[0],
          usage: double.parse(usageController.text),
        );

        await _dbHelper.updateRapport(updatedRapport);
        await _loadRapports();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rapport modifié avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la modification: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteRapport(Rapport rapport) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le rapport'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer le rapport de l\'engin ${rapport.enginId} '
          'du ${rapport.date} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _dbHelper.deleteRapport(rapport.id!);
        await _loadRapports();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rapport supprimé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la suppression: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showStatistics() async {
    try {
      int totalCount = await _dbHelper.getReportsCount();
      
      // Calculer des statistiques simples
      double totalUsage = _rapports.fold(0.0, (sum, rapport) => sum + rapport.usage);
      double avgUsage = _rapports.isNotEmpty ? totalUsage / _rapports.length : 0.0;

      // Grouper par engin
      Map<int, List<Rapport>> rapportsParEngin = {};
      for (var rapport in _rapports) {
        rapportsParEngin.putIfAbsent(rapport.enginId, () => []).add(rapport);
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Statistiques'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nombre total de rapports: $totalCount'),
                const SizedBox(height: 8),
                Text('Usage total: ${totalUsage.toStringAsFixed(2)} heures'),
                const SizedBox(height: 8),
                Text('Usage moyen: ${avgUsage.toStringAsFixed(2)} heures'),
                const SizedBox(height: 16),
                const Text('Rapports par engin:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...rapportsParEngin.entries.map((entry) {
                  double usageEngin = entry.value.fold(0.0, (sum, r) => sum + r.usage);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      'Engin ${entry.key}: ${entry.value.length} rapport(s), '
                      '${usageEngin.toStringAsFixed(2)}h',
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du calcul des statistiques: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // En-tête avec actions
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_rapports.length} rapport(s)',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _showStatistics,
                    icon: const Icon(Icons.analytics),
                    tooltip: 'Statistiques',
                  ),
                  ElevatedButton.icon(
                    onPressed: _addRapport,
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Liste des rapports
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _rapports.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.report_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucun rapport disponible',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _addRapport,
                            icon: const Icon(Icons.add),
                            label: const Text('Ajouter un rapport'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadRapports,
                      child: ListView.builder(
                        itemCount: _rapports.length,
                        itemBuilder: (context, index) {
                          final rapport = _rapports[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue[100],
                                child: Text(
                                  '${rapport.enginId}',
                                  style: TextStyle(
                                    color: Colors.blue[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                'Engin ${rapport.enginId}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Date: ${rapport.date}'),
                                  Text(
                                    'Usage: ${rapport.usage} heures',
                                    style: TextStyle(
                                      color: Colors.blue[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  switch (value) {
                                    case 'edit':
                                      _editRapport(rapport);
                                      break;
                                    case 'delete':
                                      _deleteRapport(rapport);
                                      break;
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit),
                                        SizedBox(width: 8),
                                        Text('Modifier'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Supprimer', style: TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}
