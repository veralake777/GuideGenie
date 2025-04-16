import 'package:flutter/material.dart';
import 'package:guide_genie/models/comment.dart';
import 'package:guide_genie/models/post.dart';
import 'package:guide_genie/services/api_service.dart';

class PostProvider with ChangeNotifier {
  List<Post> _posts = [];
  List<Comment> _comments = [];
  bool _isLoading = false;
  String? _errorMessage;
  Post? _selectedPost;

  final ApiService _apiService = ApiService();

  List<Post> get posts => _posts;
  List<Comment> get comments => _comments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Post? get selectedPost => _selectedPost;

  // Load posts for a specific game
  Future<void> loadPostsForGame(String gameId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final postsData = await _apiService.getPostsForGame(gameId);
      _posts = postsData.map((postJson) => Post.fromJson(postJson)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load posts: ${e.toString()}';
      notifyListeners();
    }
  }

  // Load comments for a specific post
  Future<void> loadCommentsForPost(String postId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final commentsData = await _apiService.getCommentsForPost(postId);
      _comments = commentsData.map((commentJson) => Comment.fromJson(commentJson)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load comments: ${e.toString()}';
      notifyListeners();
    }
  }

  // Select a post to display its details
  void selectPost(Post post) {
    _selectedPost = post;
    loadCommentsForPost(post.id);
    notifyListeners();
  }

  // Clear the selected post
  void clearSelectedPost() {
    _selectedPost = null;
    _comments = [];
    notifyListeners();
  }

  // Create a new post
  Future<bool> createPost(Post post) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final createdPost = await _apiService.createPost(post);
      _posts.add(Post.fromJson(createdPost));
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

  // Create a new comment
  Future<bool> createComment(Comment comment) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final createdComment = await _apiService.createComment(comment);
      _comments.add(Comment.fromJson(createdComment));
      
      // Update the post's comment IDs list if it's the selected post
      if (_selectedPost != null && comment.postId == _selectedPost!.id) {
        final updatedCommentIds = [..._selectedPost!.commentIds, comment.id];
        _selectedPost = _selectedPost!.copyWith(commentIds: updatedCommentIds);
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to create comment: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Upvote a post
  Future<bool> upvotePost(String postId, String userId) async {
    try {
      await _apiService.upvotePost(postId, userId);
      
      // Update the local post data
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex >= 0) {
        _posts[postIndex] = _posts[postIndex].copyWith(
          upvotes: _posts[postIndex].upvotes + 1,
        );
      }
      
      // Update selected post if needed
      if (_selectedPost?.id == postId) {
        _selectedPost = _selectedPost!.copyWith(
          upvotes: _selectedPost!.upvotes + 1,
        );
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to upvote post: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Downvote a post
  Future<bool> downvotePost(String postId, String userId) async {
    try {
      await _apiService.downvotePost(postId, userId);
      
      // Update the local post data
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex >= 0) {
        _posts[postIndex] = _posts[postIndex].copyWith(
          downvotes: _posts[postIndex].downvotes + 1,
        );
      }
      
      // Update selected post if needed
      if (_selectedPost?.id == postId) {
        _selectedPost = _selectedPost!.copyWith(
          downvotes: _selectedPost!.downvotes + 1,
        );
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to downvote post: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Upvote a comment
  Future<bool> upvoteComment(String commentId, String userId) async {
    try {
      await _apiService.upvoteComment(commentId, userId);
      
      // Update the local comment data
      final commentIndex = _comments.indexWhere((comment) => comment.id == commentId);
      if (commentIndex >= 0) {
        _comments[commentIndex] = _comments[commentIndex].copyWith(
          upvotes: _comments[commentIndex].upvotes + 1,
        );
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to upvote comment: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Downvote a comment
  Future<bool> downvoteComment(String commentId, String userId) async {
    try {
      await _apiService.downvoteComment(commentId, userId);
      
      // Update the local comment data
      final commentIndex = _comments.indexWhere((comment) => comment.id == commentId);
      if (commentIndex >= 0) {
        _comments[commentIndex] = _comments[commentIndex].copyWith(
          downvotes: _comments[commentIndex].downvotes + 1,
        );
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to downvote comment: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Get comments organized in threads
  List<Comment> getThreadedComments() {
    // Get top-level comments (no parent)
    final topLevelComments = _comments.where((comment) => comment.parentCommentId == null).toList();
    
    // Sort by vote score (upvotes - downvotes)
    topLevelComments.sort((a, b) => b.voteScore.compareTo(a.voteScore));
    
    return topLevelComments;
  }

  // Get child comments for a parent comment
  List<Comment> getChildComments(String parentCommentId) {
    final childComments = _comments.where((comment) => comment.parentCommentId == parentCommentId).toList();
    childComments.sort((a, b) => b.voteScore.compareTo(a.voteScore));
    return childComments;
  }

  // Filter posts by tag
  List<Post> getPostsByTag(String tag) {
    return _posts.where((post) => post.tags.contains(tag)).toList();
  }

  // Get the hottest posts (most upvotes in the last week)
  List<Post> getHottestPosts() {
    final now = DateTime.now();
    final oneWeekAgo = now.subtract(const Duration(days: 7));
    
    final recentPosts = _posts.where((post) => post.createdAt.isAfter(oneWeekAgo)).toList();
    recentPosts.sort((a, b) => b.voteScore.compareTo(a.voteScore));
    
    return recentPosts;
  }

  // Get the latest posts
  List<Post> getLatestPosts() {
    final sortedPosts = List<Post>.from(_posts);
    sortedPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedPosts;
  }
}
