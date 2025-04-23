import 'package:flutter/material.dart';
import 'package:guide_genie/services/http_client.dart';
import 'package:guide_genie/services/rest_api_service.dart';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({Key? key}) : super(key: key);

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  final RestApiService _apiService = RestApiService();
  bool _isLoading = false;
  bool _isApiHealthy = false;
  List<dynamic> _games = []; // Change type to accept both Game objects and Map
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkApiHealth();
  }

  Future<void> _checkApiHealth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final isHealthy = await ApiClient.checkHealth();
      
      setState(() {
        _isApiHealthy = isHealthy;
        _isLoading = false;
      });
      
      if (isHealthy) {
        _loadGames();
      } else {
        setState(() {
          _errorMessage = 'API is not healthy. Please check server connection.';
        });
      }
    } catch (e) {
      setState(() {
        _isApiHealthy = false;
        _isLoading = false;
        _errorMessage = 'Error checking API health: $e';
      });
    }
  }

  Future<void> _loadGames() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final games = await _apiService.getGames();
      
      setState(() {
        _games = games;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading games: $e';
      });
    }
  }

  Future<void> _createSampleGame() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final newGame = {
      'name': 'Sample Game ${DateTime.now().millisecondsSinceEpoch}',
      'description': 'A sample game created for testing',
      'icon_url': 'https://via.placeholder.com/150',
      'status': 'active'
    };

    try {
      final createdGame = await _apiService.createGame(newGame);
      
      if (createdGame != null) {
        _loadGames(); // Reload games list
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to create game';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error creating game: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkApiHealth,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _checkApiHealth,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: _isApiHealthy ? Colors.green.shade100 : Colors.red.shade100,
                      child: Row(
                        children: [
                          Icon(
                            _isApiHealthy ? Icons.check_circle : Icons.error,
                            color: _isApiHealthy ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isApiHealthy
                                ? 'API Connection: Healthy'
                                : 'API Connection: Unhealthy',
                            style: TextStyle(
                              color: _isApiHealthy ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _games.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.games,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No games found',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton(
                                    onPressed: _createSampleGame,
                                    child: const Text('Create Sample Game'),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: _games.length,
                              padding: const EdgeInsets.all(16),
                              itemBuilder: (context, index) {
                                final game = _games[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: ListTile(
                                    leading: game['icon_url'] != null
                                        ? Image.network(
                                            game['icon_url'],
                                            width: 50,
                                            height: 50,
                                            errorBuilder: (_, __, ___) => const Icon(
                                              Icons.image_not_supported,
                                              size: 50,
                                            ),
                                          )
                                        : const Icon(Icons.games, size: 50),
                                    title: Text(game['name'] ?? 'Unnamed Game'),
                                    subtitle: Text(
                                      game['description'] ?? 'No description',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: Text(
                                      game['status'] ?? 'unknown',
                                      style: TextStyle(
                                        color: game['status'] == 'active'
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createSampleGame,
        child: const Icon(Icons.add),
      ),
    );
  }
}