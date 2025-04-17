import 'package:flutter/material.dart';
import '../models/game.dart';
import '../models/guide_post.dart';
import '../widgets/popular_guide_card.dart';

class GameDetailsScreen extends StatefulWidget {
  final String gameId;
  
  const GameDetailsScreen({
    Key? key,
    required this.gameId,
  }) : super(key: key);

  @override
  State<GameDetailsScreen> createState() => _GameDetailsScreenState();
}

class _GameDetailsScreenState extends State<GameDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Game? game;
  List<GuidePost> guides = [];
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadGameData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadGameData() async {
    // TODO: Replace with API call
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Sample data - would be fetched from API
    setState(() {
      isLoading = false;
      game = Game(
        id: widget.gameId,
        name: widget.gameId == '1' 
            ? 'Fortnite' 
            : widget.gameId == '2'
                ? 'League of Legends'
                : widget.gameId == '3'
                    ? 'Valorant'
                    : 'Call of Duty: Warzone',
        genre: widget.gameId == '1' 
            ? 'Battle Royale' 
            : widget.gameId == '2'
                ? 'MOBA'
                : widget.gameId == '3'
                    ? 'Tactical FPS'
                    : 'Battle Royale',
        imageUrl: widget.gameId == '1'
            ? 'https://cdn2.unrealengine.com/en-22br-zerobuild-egs-launcher-2560x1440-2560x1440-a6f40c2ccea5.jpg'
            : widget.gameId == '2'
                ? 'https://cdn1.epicgames.com/offer/24b9b5e323bc40eea252a10cdd3b2f10/LOL_2560x1440-98749e0d718e82d27a084941939bc9d3'
                : widget.gameId == '3'
                    ? 'https://images.contentstack.io/v3/assets/bltb6530b271fddd0b1/blt81e8a3e8ac6c05e7/63b8a86598f3080c466a9ae4/Val_Ep6_Homepage_Act1_1920x1080.jpg'
                    : 'https://www.callofduty.com/content/dam/atvi/callofduty/cod-touchui/blog/hero/mwiii/MWIII-LAUNCH-TACTICS-TOUT.jpg',
        rating: widget.gameId == '1' ? 4.8 : widget.gameId == '2' ? 4.7 : widget.gameId == '3' ? 4.9 : 4.6,
        description: widget.gameId == '1'
            ? 'A battle royale game where 100 players fight to be the last person standing.'
            : widget.gameId == '2'
                ? 'A team-based strategy game where two teams of five champions face off to destroy the other\'s base.'
                : widget.gameId == '3'
                    ? 'A 5v5 character-based tactical shooter set on the global stage.'
                    : 'A free-to-play battle royale game from the Call of Duty franchise.',
      );

      // Sample guides
      guides = [
        GuidePost(
          id: '101',
          title: 'Ultimate Beginner\'s Guide',
          content: 'Everything you need to know to get started with ${game!.title}. Learn the basics and get competitive quickly.',
          authorId: 'user1',
          authorName: 'GameGuru',
          authorAvatarUrl: '',
          gameId: widget.gameId,
          gameName: game!.title,
          type: 'Guide',
          likes: 435,
          commentCount: 57,
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
          tags: ['beginner', 'basics', 'tutorial'],
        ),
        GuidePost(
          id: '102',
          title: 'Current Meta Analysis',
          content: 'A breakdown of the current meta in ${game!.title}. Find out what strategies and loadouts are dominating.',
          authorId: 'user2',
          authorName: 'MetaMaster',
          authorAvatarUrl: '',
          gameId: widget.gameId,
          gameName: game!.title,
          type: 'Meta',
          likes: 287,
          commentCount: 42,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          tags: ['meta', 'analysis', 'tier-list'],
        ),
        GuidePost(
          id: '103',
          title: 'Advanced Tactics',
          content: 'Take your ${game!.title} skills to the next level with these pro-level tactics and strategies.',
          authorId: 'user3',
          authorName: 'ProPlayer',
          authorAvatarUrl: '',
          gameId: widget.gameId,
          gameName: game!.title,
          type: 'Strategy',
          likes: 198,
          commentCount: 29,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          tags: ['advanced', 'tactics', 'pro-tips'],
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Game Details'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  game!.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Game image
                    Image.network(
                      game!.imageUrl,
                      fit: BoxFit.cover,
                    ),
                    // Gradient overlay for better text visibility
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    // TODO: Implement share functionality
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_border),
                  onPressed: () {
                    // TODO: Implement bookmark functionality
                  },
                ),
              ],
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Guides'),
                    Tab(text: 'Community'),
                  ],
                  indicatorColor: Theme.of(context).primaryColor,
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Overview Tab
            _buildOverviewTab(),
            
            // Guides Tab
            _buildGuidesTab(),
            
            // Community Tab
            _buildCommunityTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to create guide screen
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Game info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  game!.genre,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: Color(0xFFF5C842),
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    game!.rating.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Game description
          Text(
            'About',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            game!.description,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Colors.grey[300],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Related guides section
          Text(
            'Popular Guides',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Show first two guides
          if (guides.isNotEmpty)
            PopularGuideCard(guide: guides[0]),
          
          if (guides.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: PopularGuideCard(guide: guides[1]),
            ),
          
          const SizedBox(height: 16),
          // View more button
          Center(
            child: TextButton(
              onPressed: () {
                _tabController.animateTo(1); // Switch to Guides tab
              },
              child: Text(
                'View All Guides',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGuidesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: guides.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: PopularGuideCard(guide: guides[index]),
        );
      },
    );
  }
  
  Widget _buildCommunityTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Community Features Coming Soon',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Discuss strategies, share experiences, and connect with other players',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  
  _SliverAppBarDelegate(this._tabBar);
  
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: _tabBar,
    );
  }
  
  @override
  double get maxExtent => _tabBar.preferredSize.height;
  
  @override
  double get minExtent => _tabBar.preferredSize.height;
  
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}