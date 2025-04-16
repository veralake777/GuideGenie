import 'package:flutter/material.dart';
import 'package:guide_genie/models/game.dart';
import 'package:guide_genie/models/post.dart';
import 'package:guide_genie/services/api_service.dart';
import 'package:uuid/uuid.dart';

class PostProvider with ChangeNotifier {
  List<Post> _posts = [];
  List<Post> _featuredPosts = [];
  Post? _selectedPost;
  List<Comment> _comments = [];
  bool _isLoading = false;
  String? _errorMessage;

  final ApiService _apiService = ApiService();
  final _uuid = Uuid();

  List<Post> get posts => _posts;
  List<Post> get featuredPosts => _featuredPosts;
  Post? get selectedPost => _selectedPost;
  List<Comment> get comments => _comments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Initialize the post provider
  PostProvider() {
    fetchFeaturedPosts();
  }

  // Fetch all posts from the API
  Future<void> fetchPosts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final postsData = await _apiService.getPosts();
      _posts = postsData.map((post) => Post.fromJson(post)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load posts: ${e.toString()}';
      
      // In case of error, provide some sample posts for testing
      _loadSamplePosts();
      notifyListeners();
    }
  }

  // Fetch featured posts
  Future<void> fetchFeaturedPosts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final postsData = await _apiService.getFeaturedPosts();
      _featuredPosts = postsData.map((post) => Post.fromJson(post)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load featured posts: ${e.toString()}';
      
      // In case of error, provide some sample featured posts
      _loadSamplePosts();
      _featuredPosts = _posts.where((post) => post.isFeatured).toList();
      notifyListeners();
    }
  }

  // Fetch posts for a specific game
  Future<void> fetchPostsByGame(String gameId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final postsData = await _apiService.getPostsByGame(gameId);
      _posts = postsData.map((post) => Post.fromJson(post)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load posts for this game: ${e.toString()}';
      
      // In case of error, filter sample posts by game
      _loadSamplePosts();
      _posts = _posts.where((post) => post.gameId == gameId).toList();
      notifyListeners();
    }
  }

  // Fetch posts of a specific type
  Future<void> fetchPostsByType(GuideType type) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final postsData = await _apiService.getPostsByType(type.toString().split('.').last);
      _posts = postsData.map((post) => Post.fromJson(post)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load posts of this type: ${e.toString()}';
      
      // In case of error, filter sample posts by type
      _loadSamplePosts();
      _posts = _posts.where((post) => post.type == type).toList();
      notifyListeners();
    }
  }

  // Get details for a specific post
  Future<void> fetchPostDetails(String postId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final postData = await _apiService.getPostDetails(postId);
      _selectedPost = Post.fromJson(postData);
      _isLoading = false;
      notifyListeners();
      
      // Also fetch comments for this post
      fetchComments(postId);
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load post details: ${e.toString()}';
      
      // Find the post in the existing list if API call fails
      _selectedPost = _posts.firstWhere(
        (post) => post.id == postId,
        orElse: () => _posts.first,
      );
      notifyListeners();
      
      // Also load sample comments
      _loadSampleComments(postId);
    }
  }

  // Fetch comments for a post
  Future<void> fetchComments(String postId) async {
    try {
      final commentsData = await _apiService.getComments(postId);
      _comments = commentsData.map((comment) => Comment.fromJson(comment)).toList();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load comments: ${e.toString()}';
      
      // Load sample comments if API call fails
      _loadSampleComments(postId);
      notifyListeners();
    }
  }

  // Create a new post
  Future<bool> createPost(
    String title,
    String content,
    String gameId,
    String gameName,
    GuideType type,
    List<String> tags,
    String authorId,
    String authorName,
    String authorAvatarUrl,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newPost = {
        'title': title,
        'content': content,
        'gameId': gameId,
        'gameName': gameName,
        'type': type.toString().split('.').last,
        'tags': tags,
        'authorId': authorId,
        'authorName': authorName,
        'authorAvatarUrl': authorAvatarUrl,
      };
      
      final response = await _apiService.createPost(newPost);
      final createdPost = Post.fromJson(response);
      
      _posts.add(createdPost);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to create post: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Add a comment to a post
  Future<bool> addComment(
    String postId,
    String content,
    String authorId,
    String authorName,
    String authorAvatarUrl,
  ) async {
    try {
      final newComment = {
        'postId': postId,
        'content': content,
        'authorId': authorId,
        'authorName': authorName,
        'authorAvatarUrl': authorAvatarUrl,
      };
      
      final response = await _apiService.addComment(newComment);
      final createdComment = Comment.fromJson(response);
      
      _comments.add(createdComment);
      
      // Update comment count on the post
      if (_selectedPost != null && _selectedPost!.id == postId) {
        _selectedPost = _selectedPost!.copyWith(
          commentCount: _selectedPost!.commentCount + 1
        );
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add comment: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Vote on a post (upvote or downvote)
  Future<bool> votePost(String postId, bool isUpvote) async {
    try {
      await _apiService.votePost(postId, isUpvote);
      
      // Update the post in the list
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex >= 0) {
        final post = _posts[postIndex];
        _posts[postIndex] = post.copyWith(
          upvotes: isUpvote ? post.upvotes + 1 : post.upvotes,
          downvotes: !isUpvote ? post.downvotes + 1 : post.downvotes,
        );
      }
      
      // Also update the selected post if it's the same one
      if (_selectedPost != null && _selectedPost!.id == postId) {
        _selectedPost = _selectedPost!.copyWith(
          upvotes: isUpvote ? _selectedPost!.upvotes + 1 : _selectedPost!.upvotes,
          downvotes: !isUpvote ? _selectedPost!.downvotes + 1 : _selectedPost!.downvotes,
        );
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to vote on post: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Load sample posts for testing (will be removed later)
  void _loadSamplePosts() {
    final currentTime = DateTime.now();
    final samplePosts = [
      Post(
        id: '1',
        title: 'Fortnite Chapter 4 Season 3 Weapons Tier List',
        content: 'Here\'s my comprehensive tier list for the current Fortnite season weapons...',
        authorId: 'user1',
        authorName: 'FortniteProGamer',
        authorAvatarUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
        gameId: '1',
        gameName: 'Fortnite',
        type: GuideType.tierList,
        tags: ['Weapons', 'Meta', 'Chapter 4', 'Season 3'],
        upvotes: 245,
        downvotes: 12,
        commentCount: 42,
        createdAt: currentTime.subtract(Duration(days: 5)),
        updatedAt: currentTime.subtract(Duration(days: 3)),
        isFeatured: true,
      ),
      Post(
        id: '2',
        title: 'Best Valorant Agent Compositions for Every Map',
        content: 'I\'ve analyzed the top team comps used in VCT tournaments...',
        authorId: 'user2',
        authorName: 'TacticalValorant',
        authorAvatarUrl: 'https://randomuser.me/api/portraits/women/2.jpg',
        gameId: '3',
        gameName: 'Valorant',
        type: GuideType.strategy,
        tags: ['Agents', 'Team Composition', 'Maps'],
        upvotes: 189,
        downvotes: 8,
        commentCount: 37,
        createdAt: currentTime.subtract(Duration(days: 8)),
        updatedAt: currentTime.subtract(Duration(days: 7)),
        isFeatured: true,
      ),
      Post(
        id: '3',
        title: 'Ultimate Warzone Loadout Guide for Season 3',
        content: 'After extensive testing, these loadouts provide the best TTK and versatility...',
        authorId: 'user3',
        authorName: 'WarzoneWizard',
        authorAvatarUrl: 'https://randomuser.me/api/portraits/men/3.jpg',
        gameId: '6',
        gameName: 'Warzone',
        type: GuideType.loadout,
        tags: ['Weapons', 'Attachments', 'Season 3', 'Meta'],
        upvotes: 312,
        downvotes: 24,
        commentCount: 56,
        createdAt: currentTime.subtract(Duration(days: 3)),
        updatedAt: currentTime.subtract(Duration(days: 3)),
        isFeatured: true,
      ),
      Post(
        id: '4',
        title: 'League of Legends: Current Champion Meta Analysis',
        content: 'Breaking down the top picks by role following patch 13.12...',
        authorId: 'user4',
        authorName: 'LeagueLegend',
        authorAvatarUrl: 'https://randomuser.me/api/portraits/women/4.jpg',
        gameId: '2',
        gameName: 'League of Legends',
        type: GuideType.meta,
        tags: ['Champions', 'Patch 13.12', 'Roles', 'Meta'],
        upvotes: 178,
        downvotes: 15,
        commentCount: 29,
        createdAt: currentTime.subtract(Duration(days: 6)),
        updatedAt: currentTime.subtract(Duration(days: 5)),
        isFeatured: false,
      ),
      Post(
        id: '5',
        title: 'Street Fighter 6: Complete Character Tier List',
        content: 'Ranking all fighters from S to D tier based on competitive viability...',
        authorId: 'user5',
        authorName: 'FGCMaster',
        authorAvatarUrl: 'https://randomuser.me/api/portraits/men/5.jpg',
        gameId: '4',
        gameName: 'Street Fighter',
        type: GuideType.tierList,
        tags: ['Characters', 'Tier List', 'Competitive'],
        upvotes: 142,
        downvotes: 18,
        commentCount: 33,
        createdAt: currentTime.subtract(Duration(days: 10)),
        updatedAt: currentTime.subtract(Duration(days: 9)),
        isFeatured: false,
      ),
      Post(
        id: '6',
        title: 'Marvel Rivals: Best Characters for Beginners',
        content: 'If you\'re just starting out, these characters are the easiest to learn...',
        authorId: 'user6',
        authorName: 'MarvelFan',
        authorAvatarUrl: 'https://randomuser.me/api/portraits/women/6.jpg',
        gameId: '7',
        gameName: 'Marvel Rivals',
        type: GuideType.tips,
        tags: ['Beginners', 'Characters', 'Tips'],
        upvotes: 98,
        downvotes: 5,
        commentCount: 22,
        createdAt: currentTime.subtract(Duration(days: 2)),
        updatedAt: currentTime.subtract(Duration(days: 2)),
        isFeatured: true,
      ),
      Post(
        id: '7',
        title: 'Call of Duty Multiplayer: Pro Tips for Improving K/D Ratio',
        content: 'Advanced techniques to consistently top the leaderboards...',
        authorId: 'user7',
        authorName: 'CODVeteran',
        authorAvatarUrl: 'https://randomuser.me/api/portraits/men/7.jpg',
        gameId: '5',
        gameName: 'Call of Duty',
        type: GuideType.strategy,
        tags: ['Multiplayer', 'Tips', 'Improvement'],
        upvotes: 126,
        downvotes: 11,
        commentCount: 27,
        createdAt: currentTime.subtract(Duration(days: 7)),
        updatedAt: currentTime.subtract(Duration(days: 7)),
        isFeatured: false,
      ),
      Post(
        id: '8',
        title: 'Fortnite: Best Landing Spots for High Kill Games',
        content: 'Strategic landing spots that offer the best loot and early game fights...',
        authorId: 'user1',
        authorName: 'FortniteProGamer',
        authorAvatarUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
        gameId: '1',
        gameName: 'Fortnite',
        type: GuideType.strategy,
        tags: ['Landing', 'Early Game', 'Locations'],
        upvotes: 156,
        downvotes: 9,
        commentCount: 31,
        createdAt: currentTime.subtract(Duration(days: 4)),
        updatedAt: currentTime.subtract(Duration(days: 4)),
        isFeatured: false,
      ),
      Post(
        id: '9',
        title: 'Valorant: Complete Guide to Mastering Jett',
        content: 'Everything you need to know about playing Jett effectively...',
        authorId: 'user8',
        authorName: 'JettMain',
        authorAvatarUrl: 'https://randomuser.me/api/portraits/women/8.jpg',
        gameId: '3',
        gameName: 'Valorant',
        type: GuideType.strategy,
        tags: ['Jett', 'Agent Guide', 'Abilities'],
        upvotes: 205,
        downvotes: 14,
        commentCount: 45,
        createdAt: currentTime.subtract(Duration(days: 9)),
        updatedAt: currentTime.subtract(Duration(days: 8)),
        isFeatured: true,
      ),
      Post(
        id: '10',
        title: 'League of Legends: Comprehensive Warding Guide',
        content: 'Master vision control with these advanced warding techniques...',
        authorId: 'user9',
        authorName: 'SupportGuru',
        authorAvatarUrl: 'https://randomuser.me/api/portraits/men/9.jpg',
        gameId: '2',
        gameName: 'League of Legends',
        type: GuideType.strategy,
        tags: ['Warding', 'Vision', 'Support', 'Map Control'],
        upvotes: 167,
        downvotes: 7,
        commentCount: 38,
        createdAt: currentTime.subtract(Duration(days: 12)),
        updatedAt: currentTime.subtract(Duration(days: 11)),
        isFeatured: false,
      ),
    ];
    
    _posts = samplePosts;
    _featuredPosts = _posts.where((post) => post.isFeatured).toList();
  }

  // Load sample comments for testing (will be removed later)
  void _loadSampleComments(String postId) {
    final currentTime = DateTime.now();
    final sampleComments = [
      Comment(
        id: _uuid.v4(),
        postId: postId,
        content: 'This guide is super helpful! I went from barely getting any kills to winning matches consistently.',
        authorId: 'user10',
        authorName: 'GratefulGamer',
        authorAvatarUrl: 'https://randomuser.me/api/portraits/men/10.jpg',
        upvotes: 24,
        downvotes: 1,
        createdAt: currentTime.subtract(Duration(days: 2, hours: 8)),
        updatedAt: currentTime.subtract(Duration(days: 2, hours: 8)),
      ),
      Comment(
        id: _uuid.v4(),
        postId: postId,
        content: 'I disagree with your assessment of the shotgun. It\'s way more powerful than you give it credit for, especially in close quarters.',
        authorId: 'user11',
        authorName: 'ShotgunSpecialist',
        authorAvatarUrl: 'https://randomuser.me/api/portraits/women/11.jpg',
        upvotes: 16,
        downvotes: 8,
        createdAt: currentTime.subtract(Duration(days: 2, hours: 5)),
        updatedAt: currentTime.subtract(Duration(days: 2, hours: 5)),
      ),
      Comment(
        id: _uuid.v4(),
        postId: postId,
        content: 'Could you add some more details about controller settings? I\'m struggling to find the right sensitivity.',
        authorId: 'user12',
        authorName: 'ControllerPlayer',
        authorAvatarUrl: 'https://randomuser.me/api/portraits/men/12.jpg',
        upvotes: 9,
        downvotes: 0,
        createdAt: currentTime.subtract(Duration(days: 1, hours: 14)),
        updatedAt: currentTime.subtract(Duration(days: 1, hours: 14)),
      ),
      Comment(
        id: _uuid.v4(),
        postId: postId,
        content: 'This is basically the same information as your last guide. Would love to see some new insights.',
        authorId: 'user13',
        authorName: 'CriticalThinker',
        authorAvatarUrl: 'https://randomuser.me/api/portraits/women/13.jpg',
        upvotes: 5,
        downvotes: 12,
        createdAt: currentTime.subtract(Duration(days: 1, hours: 8)),
        updatedAt: currentTime.subtract(Duration(days: 1, hours: 8)),
      ),
      Comment(
        id: _uuid.v4(),
        postId: postId,
        content: 'Just tried this strategy in my last match and got a victory royale! Thanks for sharing!',
        authorId: 'user14',
        authorName: 'VictoryAchieved',
        authorAvatarUrl: 'https://randomuser.me/api/portraits/men/14.jpg',
        upvotes: 31,
        downvotes: 0,
        createdAt: currentTime.subtract(Duration(hours: 18)),
        updatedAt: currentTime.subtract(Duration(hours: 18)),
      ),
    ];
    
    _comments = sampleComments;
  }

  // Filter posts by query
  List<Post> searchPosts(String query) {
    if (query.isEmpty) {
      return _posts;
    }
    return _posts.where(
      (post) => post.title.toLowerCase().contains(query.toLowerCase()) ||
                post.content.toLowerCase().contains(query.toLowerCase()) ||
                post.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()))
    ).toList();
  }
}