import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/guide_post.dart';
import '../models/game.dart';

class PostDetailsScreen extends StatefulWidget {
  final String postId;
  
  const PostDetailsScreen({
    Key? key,
    required this.postId,
  }) : super(key: key);

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  bool isLoading = true;
  GuidePost? post;
  Game? game;
  final TextEditingController _commentController = TextEditingController();
  bool isBookmarked = false;
  bool isLiked = false;
  
  @override
  void initState() {
    super.initState();
    _loadPostData();
  }
  
  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
  
  Future<void> _loadPostData() async {
    // TODO: Replace with API call
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Sample data
    setState(() {
      isLoading = false;
      post = GuidePost(
        id: widget.postId,
        title: 'Ultimate Fortnite Season X Weapon Tier List',
        description: 'Check out the latest tier rankings for all weapons in Season X! This guide breaks down each weapon by its damage, rarity, and situational effectiveness.',
        author: 'JohnDoe',
        gameId: '1',
        type: 'Tier List',
        likes: 245,
        comments: 38,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        content: '''
# Season X Weapon Tier List

With the new season underway, the meta has shifted significantly. Here's a comprehensive breakdown of all weapons currently in the game, ranked from S-Tier (strongest) to D-Tier (weakest).

## S-Tier Weapons
- **Combat Shotgun** - Devastating at close range with a fast fire rate and good range
- **Assault Rifle (SCAR)** - Excellent all-around performance with good damage and accuracy
- **Bolt-Action Sniper Rifle** - One-shot headshot capability makes this a must-have

## A-Tier Weapons
- **Pump Shotgun** - High damage but slower fire rate than Combat Shotgun
- **Submachine Gun** - Great for close-quarters combat with high DPS
- **Heavy Sniper Rifle** - Massive damage but longer reload time

## B-Tier Weapons
- **Tactical Shotgun** - Decent choice early game
- **Burst Assault Rifle** - Good damage but less consistent than regular AR
- **Hand Cannon** - Powerful but slow fire rate

## C-Tier Weapons
- **Pistol** - Only useful early game
- **Drum Gun** - Nerfed significantly from previous seasons
- **Hunting Rifle** - Outclassed by other snipers

## D-Tier Weapons
- **Grey Pistol** - Avoid at all costs
- **Drum Shotgun** - Poor damage and accuracy
        ''',
      );
      
      game = Game(
        id: '1',
        title: 'Fortnite',
        genre: 'Battle Royale',
        imageUrl: 'https://cdn2.unrealengine.com/en-22br-zerobuild-egs-launcher-2560x1440-2560x1440-a6f40c2ccea5.jpg',
        rating: 4.8,
        description: 'A battle royale game where 100 players fight to be the last person standing.',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Guide Details'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(game!.title),
        actions: [
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            ),
            onPressed: () {
              setState(() {
                isBookmarked = !isBookmarked;
              });
              // TODO: Implement bookmark functionality with API
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post header
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Guide type tag and date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          post!.type,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Text(
                        timeago.format(post!.createdAt),
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Guide title
                  Text(
                    post!.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Author info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          post!.author[0],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post!.author,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Guide Creator',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Implement follow functionality
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                          foregroundColor: Theme.of(context).primaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Follow'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Post content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildFormattedContent(post!.content),
              ),
            ),
            
            const Divider(),
            
            // Like and comment section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        isLiked = !isLiked;
                      });
                      // TODO: Implement like functionality with API
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Icon(
                            isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                            color: isLiked ? Theme.of(context).primaryColor : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            post!.likes.toString(),
                            style: TextStyle(
                              color: isLiked ? Theme.of(context).primaryColor : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.comment_outlined,
                        color: Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        post!.comments.toString(),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const Divider(),
            
            // Comments header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'Comments (${post!.comments})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            // Comment input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.grey[600],
                    child: const Icon(
                      Icons.person,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: IconButton(
                      icon: const Icon(
                        Icons.send,
                        size: 16,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        // TODO: Implement comment submission
                        if (_commentController.text.isNotEmpty) {
                          // Add comment logic
                          _commentController.clear();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            // Sample comments
            _buildCommentItem(
              author: 'Alex Thompson',
              comment: "This tier list is spot on! I've been dominating with the Combat Shotgun lately.",
              timestamp: DateTime.now().subtract(const Duration(hours: 3)),
              likes: 42,
            ),
            _buildCommentItem(
              author: 'Sarah J.',
              comment: "I think the Burst AR should be higher tier. It's really effective if you can master it!",
              timestamp: DateTime.now().subtract(const Duration(hours: 12)),
              likes: 28,
            ),
            _buildCommentItem(
              author: 'GamerPro99',
              comment: 'Great list! What about the new items that were just added?',
              timestamp: DateTime.now().subtract(const Duration(days: 1)),
              likes: 15,
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
  
  List<Widget> _buildFormattedContent(String content) {
    final List<Widget> widgets = [];
    final lines = content.split('\n');
    
    for (var line in lines) {
      if (line.startsWith('# ')) {
        // Main heading
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              line.substring(2),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      } else if (line.startsWith('## ')) {
        // Subheading
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              line.substring(3),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      } else if (line.startsWith('- ')) {
        // Bullet point
        final text = line.substring(2);
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 16)),
                Expanded(
                  child: _formatRichText(text),
                ),
              ],
            ),
          ),
        );
      } else if (line.isEmpty) {
        // Empty line for spacing
        widgets.add(const SizedBox(height: 8));
      } else {
        // Regular paragraph
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              line,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        );
      }
    }
    
    return widgets;
  }
  
  Widget _formatRichText(String text) {
    if (text.contains('**')) {
      // Handle bold text marked with **
      final List<TextSpan> spans = [];
      final parts = text.split('**');
      
      for (int i = 0; i < parts.length; i++) {
        if (i % 2 == 0) {
          // Regular text
          spans.add(TextSpan(text: parts[i]));
        } else {
          // Bold text
          spans.add(
            TextSpan(
              text: parts[i],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        }
      }
      
      return RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[200],
          ),
          children: spans,
        ),
      );
    } else {
      // Regular text
      return Text(
        text,
        style: const TextStyle(fontSize: 16),
      );
    }
  }
  
  Widget _buildCommentItem({
    required String author,
    required String comment,
    required DateTime timestamp,
    required int likes,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              author[0],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      author,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeago.format(timestamp),
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment),
                const SizedBox(height: 4),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        // TODO: Implement like comment functionality
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.thumb_up_outlined,
                              size: 14,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Like',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$likes likes',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: () {
                        // TODO: Implement reply functionality
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          'Reply',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
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
}