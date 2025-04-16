import 'package:flutter/material.dart';
import 'package:guide_genie/utils/constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guide Genie',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF050A18),
        primaryColor: const Color(0xFF00FFFF),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF00FFFF),   // Cyan neon
          secondary: const Color(0xFFFF00FF), // Magenta neon
          tertiary: const Color(0xFF00FF00),  // Green neon
          background: const Color(0xFF0A1128),
          surface: const Color(0xFF240046),
        ),
      ),
      home: const DemoPage(),
    );
  }
}

class DemoPage extends StatelessWidget {
  const DemoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Guide Genie',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF00FFFF),
            fontSize: 24,
            shadows: [
              Shadow(
                color: Color(0xFF00FFFF),
                blurRadius: 10,
                offset: Offset(0, 0),
              ),
            ],
          ),
        ),
        backgroundColor: const Color(0xFF240046),
        centerTitle: true,
        elevation: 8,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Splash screen demo
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF0A1128),
                    const Color(0xFF240046),
                    const Color(0xFF9000FF).withOpacity(0.8),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App icon with neon glow
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A1128),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00FFFF).withOpacity(0.7),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                        border: Border.all(
                          color: const Color(0xFF00FFFF).withOpacity(0.7),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.videogame_asset,
                        size: 80,
                        color: Color(0xFF00FFFF),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // App name with gaming font and neon glow
                    const Text(
                      'Guide Genie',
                      style: TextStyle(
                        color: Color(0xFF00FFFF),
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                        shadows: [
                          Shadow(
                            color: Color(0xFF00FFFF),
                            blurRadius: 10,
                            offset: Offset(0, 0),
                          ),
                          Shadow(
                            color: Color(0xFF00FFFF),
                            blurRadius: 20,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Game card example
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Featured Games',
                style: TextStyle(
                  color: const Color(0xFFFF00FF),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: const Color(0xFFFF00FF).withOpacity(0.7),
                      blurRadius: 6,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ),
            
            // Game cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _buildGameCard(
                    'Fortnite',
                    'Battle Royale',
                    'https://cdn2.unrealengine.com/en-22br-zerobuild-egs-launcher-2560x1440-2560x1440-a6f40c2ccea5.jpg',
                  ),
                  const SizedBox(height: 16),
                  _buildGameCard(
                    'League of Legends',
                    'MOBA',
                    'https://cdn1.epicgames.com/offer/24b9b5e323bc40eea252a10cdd3b2f10/LOL_2560x1440-98749e0d718e82d27a084941939bc9d3',
                  ),
                  const SizedBox(height: 16),
                  _buildGameCard(
                    'Valorant',
                    'Tactical FPS',
                    'https://images.contentstack.io/v3/assets/bltb6530b271fddd0b1/blt81e8a3e8ac6c05e7/63b8a86598f3080c466a9ae4/Val_Ep6_Homepage_Act1_1920x1080.jpg',
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Post preview example
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Popular Guides',
                style: TextStyle(
                  color: const Color(0xFF00FF00),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: const Color(0xFF00FF00).withOpacity(0.7),
                      blurRadius: 6,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ),
            
            // Posts
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _buildPostCard(
                    'Fortnite Season X Tier List',
                    'Check out the latest tier rankings for all weapons in Season X!',
                    'Tier List',
                    'JohnDoe',
                  ),
                  const SizedBox(height: 16),
                  _buildPostCard(
                    'Valorant - Best Agent Combos',
                    'Learn the most effective agent combinations for competitive play.',
                    'Strategy',
                    'ProGamer123',
                  ),
                  const SizedBox(height: 16),
                  _buildPostCard(
                    'League of Legends - S-Tier Champions',
                    'The definitive guide to the most powerful champions in the current meta.',
                    'Meta Analysis',
                    'LeagueExpert',
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF240046),
        selectedItemColor: const Color(0xFF00FFFF),
        unselectedItemColor: Colors.white.withOpacity(0.6),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        currentIndex: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFFFF00FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
  
  Widget _buildGameCard(String title, String genre, String imageUrl) {
    return Card(
      elevation: 8,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: const Color(0xFFFF00FF).withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  genre,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text('4.8', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'View Guides',
                        style: TextStyle(color: Color(0xFFFF00FF)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPostCard(String title, String description, String type, String author) {
    return Card(
      elevation: 8,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: const Color(0xFF00FF00).withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FF00).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: const Color(0xFF00FF00).withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    type,
                    style: const TextStyle(
                      color: Color(0xFF00FF00),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(Icons.bookmark_border, color: Colors.white.withOpacity(0.6)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: const Color(0xFF00FFFF),
                      child: Text(
                        author[0],
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      author,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.thumb_up_outlined, size: 16, color: Colors.white.withOpacity(0.6)),
                    const SizedBox(width: 4),
                    Text('125', style: TextStyle(color: Colors.white.withOpacity(0.6))),
                    const SizedBox(width: 12),
                    Icon(Icons.comment_outlined, size: 16, color: Colors.white.withOpacity(0.6)),
                    const SizedBox(width: 4),
                    Text('32', style: TextStyle(color: Colors.white.withOpacity(0.6))),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}