import 'package:flutter/material.dart';
import 'package:guide_genie/models/guide_post.dart';
import 'package:guide_genie/models/post.dart';
import 'package:guide_genie/models/comment.dart';
import 'package:guide_genie/services/api_service_new.dart';

class PostProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Post> _posts = [];
  List<Post> _featuredPosts = [];
  List<Post> _latestPosts = [];
  Post? _selectedPost;
  List<Comment> _comments = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Post> get posts => _posts;
  List<Post> get featuredPosts => _featuredPosts;
  List<Post> get latestPosts => _latestPosts;
  Post? get selectedPost => _selectedPost;
  List<Comment> get comments => _comments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Load all posts - combined loading
  Future<void> loadPosts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Load all post types concurrently
      await Future.wait([
        fetchPosts(),
        fetchFeaturedPosts(),
        fetchLatestPosts(),
      ]);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      throw e; // Re-throw for the caller to handle
    }
  }
  
  // Get popular posts (most upvoted)
  List<GuidePost> getPopularPosts() {
    // If direct GuidePost data exists, convert and use
    if (_posts.isNotEmpty) {
      final sortedPosts = List<Post>.from(_posts);
      sortedPosts.sort((a, b) => b.upvotes.compareTo(a.upvotes));
      
      return sortedPosts.take(5).map((post) => GuidePost(
        id: post.id,
        title: post.title,
        content: post.content,
        gameId: post.gameId,
        gameName: post.gameName,
        type: post.type,
        authorId: post.authorId,
        authorName: post.authorName,
        authorAvatarUrl: post.authorAvatarUrl,
        createdAt: post.createdAt,
        updatedAt: post.updatedAt,
        likes: post.upvotes,
        commentCount: post.commentCount,
        tags: post.tags,
      )).toList();
    }
    
    // Otherwise return empty list
    return [];
  }
  
  // Get all posts as GuidePost objects
  Future<List<GuidePost>> getPosts() async {
    if (_posts.isEmpty) {
      await fetchPosts();
    }
    
    return _posts.map((post) => GuidePost(
      id: post.id,
      title: post.title,
      content: post.content,
      gameId: post.gameId,
      gameName: post.gameName,
      type: post.type,
      authorId: post.authorId,
      authorName: post.authorName,
      authorAvatarUrl: post.authorAvatarUrl,
      createdAt: post.createdAt,
      updatedAt: post.updatedAt,
      likes: post.upvotes,
      commentCount: post.commentCount,
      tags: post.tags,
    )).toList();
  }

  // Fetch all posts
  Future<void> fetchPosts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final postsData = await _apiService.getPosts();
      _posts = postsData.map((data) => Post.fromJson(data)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
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
      _featuredPosts = postsData.map((data) => Post.fromJson(data)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch latest posts
  Future<void> fetchLatestPosts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final postsData = await _apiService.getLatestPosts();
      _latestPosts = postsData.map((data) => Post.fromJson(data)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch posts by game
  Future<void> fetchPostsByGame(String gameId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final postsData = await _apiService.getPostsByGame(gameId);
      _posts = postsData.map((data) => Post.fromJson(data)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch post details
  Future<void> fetchPostDetails(String postId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final postData = await _apiService.getPostDetails(postId);
      _selectedPost = Post.fromJson(postData);
      
      // Also fetch comments for this post
      final commentsData = await _apiService.getComments(postId);
      _comments = commentsData.map((data) => Comment.fromJson(data)).toList();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new post
  Future<bool> createPost(
    String title,
    String content,
    String gameId,
    String gameName,
    String type,
    List<String> tags,
    String authorId,
    String authorName,
    String authorAvatarUrl,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      
      final post = Post(
        id: '', // Will be set by the API
        title: title,
        content: content,
        gameId: gameId,
        gameName: gameName,
        type: type,
        tags: tags,
        authorId: authorId,
        authorName: authorName,
        authorAvatarUrl: authorAvatarUrl,
        createdAt: now,
        updatedAt: now,
        upvotes: 0,
        downvotes: 0,
        commentCount: 0,
        isFeatured: false,
      );
      
      await _apiService.createPost(post.toJson());
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Add comment to a post
  Future<bool> addComment(
    String postId,
    String content,
    String authorId,
    String authorName,
    String authorAvatarUrl,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      
      final comment = Comment(
        id: '', // Will be set by the API
        postId: postId,
        content: content,
        authorId: authorId,
        authorName: authorName,
        authorAvatarUrl: authorAvatarUrl,
        createdAt: now,
        upvotes: 0,
        downvotes: 0,
        parentCommentId: null,
        childCommentIds: const [],
      );
      
      await _apiService.createComment(comment.toJson());
      
      // Update comment count
      if (_selectedPost != null && _selectedPost!.id == postId) {
        _selectedPost = _selectedPost!.copyWith(
          commentCount: _selectedPost!.commentCount + 1,
        );
        
        // Refresh comments
        final commentsData = await _apiService.getComments(postId);
        _comments = commentsData.map((data) => Comment.fromJson(data)).toList();
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Vote on a post
  Future<bool> votePost(String postId, bool isUpvote) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.votePost(postId, isUpvote);
      
      // Update local post data
      if (_selectedPost != null && _selectedPost!.id == postId) {
        _selectedPost = _selectedPost!.copyWith(
          upvotes: isUpvote ? _selectedPost!.upvotes + 1 : _selectedPost!.upvotes,
          downvotes: !isUpvote ? _selectedPost!.downvotes + 1 : _selectedPost!.downvotes,
        );
      }
      
      // Also update in other lists
      _updatePostInList(_posts, postId, isUpvote);
      _updatePostInList(_featuredPosts, postId, isUpvote);
      _updatePostInList(_latestPosts, postId, isUpvote);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Search posts by query (returns Post list)
  List<Post> searchPosts(String query) {
    final lowerCaseQuery = query.toLowerCase();
    
    return _posts.where((post) {
      return post.title.toLowerCase().contains(lowerCaseQuery) ||
          post.content.toLowerCase().contains(lowerCaseQuery) ||
          post.gameName.toLowerCase().contains(lowerCaseQuery) ||
          post.authorName.toLowerCase().contains(lowerCaseQuery) ||
          post.tags.any((tag) => tag.toLowerCase().contains(lowerCaseQuery));
    }).toList();
  }
  
  // Search posts by query (returns GuidePost list for UI)
  List<GuidePost> searchGuidePosts(String query) {
    final posts = searchPosts(query);
    
    return posts.map((post) => GuidePost(
      id: post.id,
      title: post.title,
      content: post.content,
      gameId: post.gameId,
      gameName: post.gameName,
      type: post.type,
      authorId: post.authorId,
      authorName: post.authorName,
      authorAvatarUrl: post.authorAvatarUrl,
      createdAt: post.createdAt,
      updatedAt: post.updatedAt,
      likes: post.upvotes,
      commentCount: post.commentCount,
      tags: post.tags,
    )).toList();
  }

  // Get posts by type
  List<Post> getPostsByType(String type) {
    return _posts.where((post) => post.type == type).toList();
  }

  // Helper method to update a post in a list
  void _updatePostInList(List<Post> postList, String postId, bool isUpvote) {
    final index = postList.indexWhere((post) => post.id == postId);
    if (index != -1) {
      postList[index] = postList[index].copyWith(
        upvotes: isUpvote ? postList[index].upvotes + 1 : postList[index].upvotes,
        downvotes: !isUpvote ? postList[index].downvotes + 1 : postList[index].downvotes,
      );
    }
  }

  // Reset selected post
  void resetSelectedPost() {
    _selectedPost = null;
    _comments = [];
    notifyListeners();
  }
}