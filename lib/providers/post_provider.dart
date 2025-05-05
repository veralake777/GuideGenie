import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/post.dart';

class PostProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Post> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchAllPosts() async {
    _setLoading(true);
    try {
      _posts = await _firestoreService.getAllPosts();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load posts';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchPostsByGame(String gameId) async {
    _setLoading(true);
    try {
      _posts = await _firestoreService.getPostsByGame(gameId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load posts';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createPost(Post post) async {
    _setLoading(true);
    try {
      await _firestoreService.createPost(post);
      await fetchAllPosts();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create post';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
