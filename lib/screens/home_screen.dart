import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/json_storage_service.dart';
import '../models/engin.dart';
import 'engin_list_screen.dart';
import 'rapport_screen.dart';
import 'test_screen.dart';
import 'auth_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final JsonStorageService _storageService = JsonStorageService();
  int _selectedIndex = 0;
  List<Engin> _engins = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEngins();
  }

  Future<void> _loadEngins() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Engin> engins = await _storageService.getEnginsWithOfflineSupport();
      setState(() {
        _engins = engins;
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

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la déconnexion: $e')),
      );
    }
  }

  Widget _buildDashboard() {
    return RefreshIndicator(
      onRefresh: _loadEngins,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carte de bienvenue
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.engineering, color: Colors.blue[700], size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tableau de Bord Technicien',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'UID: ${_authService.currentUser?.uid ?? 'Non connecté'}',
                                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<bool>(
                      future: _storageService.isOnline(),
                      builder: (context, snapshot) {
                        bool isOnline = snapshot.data ?? false;
                        return Row(
                          children: [
                            Icon(
                              isOnline ? Icons.wifi : Icons.wifi_off,
                              color: isOnline ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isOnline ? 'En ligne' : 'Hors ligne',
                              style: TextStyle(
                                color: isOnline ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Statistiques rapides
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.precision_manufacturing, 
                               color: Colors.blue[700], size: 32),
                          const SizedBox(height: 8),
                          Text(
                            '${_engins.length}',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const Text('Engins Total'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.check_circle, 
                               color: Colors.green[700], size: 32),
                          const SizedBox(height: 8),
                          Text(
                            '${_engins.where((e) => e.statut.toLowerCase() == 'actif').length}',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const Text('Actifs'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Actions rapides
            const Text(
              'Actions Rapides',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.list, color: Colors.blue[700]),
                    title: const Text('Voir tous les engins'),
                    subtitle: const Text('Liste complète avec synchronisation'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      setState(() {
                        _selectedIndex = 1;
                      });
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.report, color: Colors.orange[700]),
                    title: const Text('Gestion des rapports'),
                    subtitle: const Text('Ajouter, modifier, supprimer des rapports'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      setState(() {
                        _selectedIndex = 2;
                      });
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.refresh, color: Colors.green[700]),
                    title: const Text('Synchroniser'),
                    subtitle: const Text('Forcer la synchronisation des données'),
                    trailing: _isLoading 
                        ? const SizedBox(
                            width: 20, 
                            height: 20, 
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.arrow_forward_ios),
                    onTap: _isLoading ? null : _loadEngins,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildDashboard(),
      EnginListScreen(engins: _engins, onRefresh: _loadEngins),
      const RapportScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('TGCC App'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.science),
            onPressed: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => const TestScreen()),
            ),
            tooltip: 'Tests',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadEngins,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Tableau de Bord',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.precision_manufacturing),
            label: 'Engins',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Rapports',
          ),
        ],
      ),
    );
  }
}
