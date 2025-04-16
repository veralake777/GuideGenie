import 'package:flutter/material.dart';
import 'package:guide_genie/models/game.dart';
import 'package:guide_genie/providers/auth_provider.dart';
import 'package:guide_genie/providers/game_provider.dart';
import 'package:guide_genie/screens/account_screen.dart';
import 'package:guide_genie/screens/game_screen.dart';
import 'package:guide_genie/widgets/custom_app_bar.dart';
import 'package:guide_genie/widgets/game_card.dart';
import 'package:guide_genie/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load games when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GameProvider>(context, listen: false).loadGames();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  void _navigateToGameScreen(Game game) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(game: game),
      ),
    );
  }
  
  void _navigateToAccountScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AccountScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Guide Genie',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: _navigateToAccountScreen,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.onPrimary,
                    radius: 32,
                    child: Icon(
                      Icons.person,
                      size: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    authProvider.currentUser?.username ?? 'Guest User',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    authProvider.currentUser?.email ?? 'Not signed in',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              selected: true,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('My Account'),
              onTap: () {
                Navigator.pop(context);
                _navigateToAccountScreen();
              },
            ),
            if (authProvider.isAuthenticated)
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.pop(context);
                  authProvider.logout();
                },
              ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'All Games',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            ...gameProvider.games.map((game) => ListTile(
              title: Text(game.name),
              onTap: () {
                Navigator.pop(context);
                _navigateToGameScreen(game);
              },
            )).toList(),
          ],
        ),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).colorScheme.primary,
            tabs: const [
              Tab(text: 'Popular'),
              Tab(text: 'Competitive'),
              Tab(text: 'All Games'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Popular Games Tab (P0)
                _buildGameGrid(gameProvider.p0Games),
                
                // Competitive Games Tab (P1)
                _buildGameGrid(gameProvider.p1Games),
                
                // All Games Tab (All games)
                _buildGameGrid(gameProvider.games),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGameGrid(List<Game> games) {
    final gameProvider = Provider.of<GameProvider>(context);
    
    if (gameProvider.isLoading) {
      return const Center(
        child: LoadingIndicator(),
      );
    }
    
    if (gameProvider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load games',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                gameProvider.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                gameProvider.loadGames();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (games.isEmpty) {
      return const Center(
        child: Text('No games available'),
      );
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        return GameCard(
          game: game,
          onTap: () => _navigateToGameScreen(game),
        );
      },
    );
  }
}
