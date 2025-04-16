import 'package:flutter/material.dart';
import '../models/game.dart';
import '../models/guide_post.dart';
import '../widgets/app_drawer.dart';
import '../widgets/featured_game_card.dart';
import '../widgets/popular_guide_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;
  List<Game> featuredGames = [];
  List<GuidePost> popularGuides = [];
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    // Simulate API call with a delay
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Sample data - would be fetched from API
    setState(() {
      isLoading = false;
      
      // Featured games data
      featuredGames = [
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
      
      // Popular guides data
      popularGuides = [
        GuidePost(
          id: '101',
          title: 'Ultimate Beginner\'s Guide to Valorant',
          description: 'Everything you need to know to get started with Valorant. Learn the basics and get competitive quickly.',
          author: 'GameGuru',
          gameId: '3',
          type: 'Guide',
          likes: 435,
          comments: 57,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          content: '',
        ),
        GuidePost(
          id: '102',
          title: 'Fortnite Season X Weapon Tier List',
          description: 'Check out the latest tier rankings for all weapons in Season X! This guide breaks down each weapon by its damage, rarity, and situational effectiveness.',
          author: 'FortniteExpert',
          gameId: '1',
          type: 'Tier List',
          likes: 287,
          comments: 42,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          content: '',
        ),
        GuidePost(
          id: '103',
          title: 'Best Champions for Solo Queue in League of Legends',
          description: 'Looking to climb the ranked ladder? These champions offer the best carrying potential for solo players.',
          author: 'LOL_Master',
          gameId: '2',
          type: 'Meta',
          likes: 329,
          comments: 61,
          createdAt: DateTime.now().subtract(const Duration(hours: 12)),
          content: '',
        ),
        GuidePost(
          id: '104',
          title: 'Advanced Warzone Movement Techniques',
          description: 'Master these movement techniques to outplay your opponents and survive longer in Warzone matches.',
          author: 'WarzoneWizard',
          gameId: '4',
          type: 'Strategy',
          likes: 198,
          comments: 29,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          content: '',
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Guide Genie',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Search feature coming soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              // TODO: Implement notifications functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications feature coming soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Featured games section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Featured Games',
                            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // TODO: Navigate to all games screen
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('All Games feature coming soon!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Text(
                              'See All',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Featured games carousel
                    SizedBox(
                      height: 170,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                        scrollDirection: Axis.horizontal,
                        itemCount: featuredGames.length,
                        itemBuilder: (context, index) {
                          return FeaturedGameCard(game: featuredGames[index]);
                        },
                      ),
                    ),
                    
                    // Popular guides section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Popular Guides',
                            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // TODO: Navigate to all guides screen
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('All Guides feature coming soon!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Text(
                              'See All',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Popular guides list
                    ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: popularGuides.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: PopularGuideCard(guide: popularGuides[index]),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to create guide screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Create Guide feature coming soon!'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}