import 'package:flutter/material.dart';
import '../widgets/featured_game_card.dart';
import '../widgets/popular_guide_card.dart';
import '../widgets/app_drawer.dart';
import '../models/game.dart';
import '../models/guide_post.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  // Temporary data until we connect to an API
  final List<Game> featuredGames = [
    Game(
      id: '1',
      title: 'Fortnite',
      genre: 'Battle Royale',
      imageUrl: 'https://cdn2.unrealengine.com/en-22br-zerobuild-egs-launcher-2560x1440-2560x1440-a6f40c2ccea5.jpg',
      rating: 4.8,
      description: 'A battle royale game where 100 players fight to be the last person standing.',
    ),
    Game(
      id: '2',
      title: 'League of Legends',
      genre: 'MOBA',
      imageUrl: 'https://cdn1.epicgames.com/offer/24b9b5e323bc40eea252a10cdd3b2f10/LOL_2560x1440-98749e0d718e82d27a084941939bc9d3',
      rating: 4.7,
      description: 'A team-based strategy game where two teams of five champions face off to destroy the other\'s base.',
    ),
    Game(
      id: '3',
      title: 'Valorant',
      genre: 'Tactical FPS',
      imageUrl: 'https://images.contentstack.io/v3/assets/bltb6530b271fddd0b1/blt81e8a3e8ac6c05e7/63b8a86598f3080c466a9ae4/Val_Ep6_Homepage_Act1_1920x1080.jpg',
      rating: 4.9,
      description: 'A 5v5 character-based tactical shooter set on the global stage.',
    ),
    Game(
      id: '4',
      title: 'Call of Duty: Warzone',
      genre: 'Battle Royale',
      imageUrl: 'https://www.callofduty.com/content/dam/atvi/callofduty/cod-touchui/blog/hero/mwiii/MWIII-LAUNCH-TACTICS-TOUT.jpg',
      rating: 4.6,
      description: 'A free-to-play battle royale game from the Call of Duty franchise.',
    ),
  ];
  
  final List<GuidePost> popularGuides = [
    GuidePost(
      id: '1',
      title: 'Fortnite Season X Weapon Tier List',
      description: 'Check out the latest tier rankings for all weapons in Season X! This guide breaks down each weapon by its damage, rarity, and situational effectiveness.',
      author: 'JohnDoe',
      gameId: '1',
      type: 'Tier List',
      likes: 245,
      comments: 38,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      content: '',
    ),
    GuidePost(
      id: '2',
      title: 'Valorant - Best Agent Combos for Competitive Play',
      description: 'Learn the most effective agent combinations for competitive play. This guide covers synergies between different agents and optimal team compositions for each map.',
      author: 'ProGamer123',
      gameId: '3',
      type: 'Strategy',
      likes: 189,
      comments: 52,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      content: '',
    ),
    GuidePost(
      id: '3',
      title: 'League of Legends - S-Tier Champions in Current Meta',
      description: 'The definitive guide to the most powerful champions in the current meta. Includes detailed analysis of build paths, runes, and matchups for each role.',
      author: 'LeagueExpert',
      gameId: '2',
      type: 'Meta Analysis',
      likes: 312,
      comments: 74,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      content: '',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'G',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text('Guide Genie'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Navigate to search screen
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.games_outlined),
            activeIcon: Icon(Icons.games),
            label: 'Games',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmarks_outlined),
            activeIcon: Icon(Icons.bookmarks),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Section
          Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF272935),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Level Up Your Gaming Experience',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Access comprehensive guides, tier lists, and strategies created by the community for all your favorite games in one place.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[300],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Navigate to games list
                  },
                  child: const Text('Browse Game Guides'),
                ),
              ],
            ),
          ),
          
          // Featured Games Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
            child: Text(
              'Featured Games',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 240,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              scrollDirection: Axis.horizontal,
              itemCount: featuredGames.length,
              itemBuilder: (context, index) {
                return FeaturedGameCard(game: featuredGames[index]);
              },
            ),
          ),
          
          // Popular Guides Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
            child: Text(
              'Popular Guides',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: popularGuides.length,
            itemBuilder: (context, index) {
              return PopularGuideCard(guide: popularGuides[index]);
            },
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}