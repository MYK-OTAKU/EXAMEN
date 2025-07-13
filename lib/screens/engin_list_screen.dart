import 'package:flutter/material.dart';
import '../models/engin.dart';
import '../services/auth_service.dart';

class EnginListScreen extends StatefulWidget {
  final List<Engin> engins;
  final VoidCallback onRefresh;

  const EnginListScreen({
    super.key,
    required this.engins,
    required this.onRefresh,
  });

  @override
  State<EnginListScreen> createState() => _EnginListScreenState();
}

class _EnginListScreenState extends State<EnginListScreen> {
  final AuthService _authService = AuthService();
  String _searchQuery = '';
  String _statusFilter = 'Tous';

  List<Engin> get _filteredEngins {
    return widget.engins.where((engin) {
      bool matchesSearch = engin.libelle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          engin.id.toString().contains(_searchQuery);
      
      bool matchesStatus = _statusFilter == 'Tous' || 
                          engin.statut.toLowerCase() == _statusFilter.toLowerCase();
      
      return matchesSearch && matchesStatus;
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'actif':
        return Colors.green;
      case 'inactif':
        return Colors.red;
      case 'maintenance':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'actif':
        return Icons.check_circle;
      case 'inactif':
        return Icons.cancel;
      case 'maintenance':
        return Icons.build;
      default:
        return Icons.help;
    }
  }

  Future<void> _addToFirestore(Engin engin) async {
    try {
      await _authService.addOrUpdateEngin(engin);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Engin "${engin.libelle}" ajouté à Firestore'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showEnginDetails(Engin engin) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(engin.libelle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${engin.id ?? 'Non défini'}'),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  _getStatusIcon(engin.statut),
                  color: _getStatusColor(engin.statut),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Statut: ${engin.statut}',
                  style: TextStyle(
                    color: _getStatusColor(engin.statut),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _addToFirestore(engin);
            },
            child: const Text('Ajouter à Firestore'),
          ),
        ],
      ),
    );
  }

  void _showAddEnginDialog() {
    final idController = TextEditingController();
    final libelleController = TextEditingController();
    String selectedStatus = 'Actif';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un Engin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: idController,
              decoration: const InputDecoration(labelText: 'ID (optionnel)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: libelleController,
              decoration: const InputDecoration(labelText: 'Libellé'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedStatus,
              decoration: const InputDecoration(labelText: 'Statut'),
              items: ['Actif', 'Inactif', 'Maintenance'].map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  selectedStatus = value;
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (libelleController.text.isNotEmpty) {
                final engin = Engin(
                  id: idController.text.isNotEmpty ? int.tryParse(idController.text) : null,
                  libelle: libelleController.text,
                  statut: selectedStatus,
                );
                Navigator.of(context).pop();
                _addToFirestore(engin);
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredEngins = _filteredEngins;

    return Column(
      children: [
        // Barre de recherche et filtres
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher par libellé ou ID...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _statusFilter,
                      decoration: InputDecoration(
                        labelText: 'Filtrer par statut',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: ['Tous', 'Actif', 'Inactif', 'Maintenance'].map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _statusFilter = value ?? 'Tous';
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _showAddEnginDialog,
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

        // Compteur et info
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${filteredEngins.length} engin(s) trouvé(s)',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: widget.onRefresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Actualiser'),
              ),
            ],
          ),
        ),

        // Liste des engins
        Expanded(
          child: filteredEngins.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.precision_manufacturing,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isNotEmpty || _statusFilter != 'Tous'
                            ? 'Aucun engin trouvé avec ces critères'
                            : 'Aucun engin disponible',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: widget.onRefresh,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Actualiser'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    widget.onRefresh();
                  },
                  child: ListView.builder(
                    itemCount: filteredEngins.length,
                    itemBuilder: (context, index) {
                      final engin = filteredEngins[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getStatusColor(engin.statut).withOpacity(0.1),
                            child: Icon(
                              _getStatusIcon(engin.statut),
                              color: _getStatusColor(engin.statut),
                            ),
                          ),
                          title: Text(
                            engin.libelle,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (engin.id != null)
                                Text('ID: ${engin.id}'),
                              Row(
                                children: [
                                  Icon(
                                    _getStatusIcon(engin.statut),
                                    size: 16,
                                    color: _getStatusColor(engin.statut),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    engin.statut,
                                    style: TextStyle(
                                      color: _getStatusColor(engin.statut),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.cloud_upload),
                                onPressed: () => _addToFirestore(engin),
                                tooltip: 'Ajouter à Firestore',
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 16),
                            ],
                          ),
                          onTap: () => _showEnginDetails(engin),
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
