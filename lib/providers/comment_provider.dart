import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/comment.dart';

class CommentProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Comment> _comments = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Comment> get comments => _comments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchCommentsForPost(String postId) async {
    _setLoading(true);
    try {
      _comments = await _firestoreService.getCommentsByPost(postId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load comments';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createComment(Comment comment) async {
    _setLoading(true);
    try {
      await _firestoreService.createComment(comment);
      await fetchCommentsForPost(comment.postId);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create comment';
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