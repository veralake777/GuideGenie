import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/game.dart';

class GameProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Game> _games = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Game> get games => _games;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchGames() async {
    _setLoading(true);
    try {
      _games = await _firestoreService.getAllGames();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load games';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}