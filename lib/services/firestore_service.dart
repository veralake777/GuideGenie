import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/game.dart';
import '../models/guide.dart';
import '../models/user.dart';
import '../models/comment.dart';
import 'firebase_service.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseService.instance.firestore;

  // Collection references
  CollectionReference<Map<String, dynamic>> get _gamesCollection => 
      _firestore.collection('games');
  
  CollectionReference<Map<String, dynamic>> get _guidesCollection => 
      _firestore.collection('guides');
  
  CollectionReference<Map<String, dynamic>> get _usersCollection => 
      _firestore.collection('users');
  
  CollectionReference<Map<String, dynamic>> get _commentsCollection => 
      _firestore.collection('comments');

  // GAMES
  Future<List<Game>> getAllGames() async {
    try {
      final snapshot = await _gamesCollection.get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Game.fromMap({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      debugPrint('Error getting all games: $e');
      return [];
    }
  }

  Future<Game?> getGameById(String id) async {
    try {
      final doc = await _gamesCollection.doc(id).get();
      if (!doc.exists) return null;
      
      return Game.fromMap({...doc.data()!, 'id': doc.id});
    } catch (e) {
      debugPrint('Error getting game by id: $e');
      return null;
    }
  }

  Future<List<Game>> searchGames(String query) async {
    try {
      // Firebase doesn't have direct text search like SQL, 
      // so we'll get all games and filter in-memory
      final snapshot = await _gamesCollection.get();
      final List<Game> games = snapshot.docs.map((doc) {
        return Game.fromMap({...doc.data(), 'id': doc.id});
      }).toList();
      
      // Filter by name (case insensitive)
      return games.where((game) => 
          game.name.toLowerCase().contains(query.toLowerCase())).toList();
    } catch (e) {
      debugPrint('Error searching games: $e');
      return [];
    }
  }

  Future<Game> createGame(Game game) async {
    try {
      // Remove id as Firestore will generate one
      final gameMap = game.toMap();
      gameMap.remove('id');

      // Add to Firestore
      final docRef = await _gamesCollection.add(gameMap);
      
      // Get the new document with the generated ID
      final newDoc = await docRef.get();
      return Game.fromMap({...newDoc.data()!, 'id': newDoc.id});
    } catch (e) {
      debugPrint('Error creating game: $e');
      rethrow;
    }
  }

  Future<Game?> updateGame(Game game) async {
    try {
      final gameId = game.id;
      final gameMap = game.toMap();
      gameMap.remove('id'); // Remove id as it's not stored in the document
      
      await _gamesCollection.doc(gameId).update(gameMap);
      
      return getGameById(gameId);
    } catch (e) {
      debugPrint('Error updating game: $e');
      return null;
    }
  }

  Future<bool> deleteGame(String id) async {
    try {
      await _gamesCollection.doc(id).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting game: $e');
      return false;
    }
  }

  // USERS
  Future<User?> getUserById(String id) async {
    try {
      final doc = await _usersCollection.doc(id).get();
      if (!doc.exists) return null;
      
      return User.fromMap({...doc.data()!, 'id': doc.id});
    } catch (e) {
      debugPrint('Error getting user by id: $e');
      return null;
    }
  }

  Future<User?> getUserByUsername(String username) async {
    try {
      final query = await _usersCollection
          .where('username', isEqualTo: username)
          .limit(1)
          .get();
      
      if (query.docs.isEmpty) return null;
      
      final doc = query.docs.first;
      return User.fromMap({...doc.data(), 'id': doc.id});
    } catch (e) {
      debugPrint('Error getting user by username: $e');
      return null;
    }
  }

  Future<User> createUser(User user) async {
    try {
      // Remove id as Firestore will generate one
      final userMap = user.toMap();
      userMap.remove('id');

      // Add to Firestore
      final docRef = await _usersCollection.add(userMap);
      
      // Get the new document with the generated ID
      final newDoc = await docRef.get();
      return User.fromMap({...newDoc.data()!, 'id': newDoc.id});
    } catch (e) {
      debugPrint('Error creating user: $e');
      rethrow;
    }
  }

  // GUIDES
  Future<List<Guide>> getGuidesByGame(String gameId) async {
    try {
      final snapshot = await _guidesCollection
          .where('gameId', isEqualTo: gameId)
          .get();
      
      return snapshot.docs.map((doc) {
        return Guide.fromMap({...doc.data(), 'id': doc.id});
      }).toList();
    } catch (e) {
      debugPrint('Error getting guides by game: $e');
      return [];
    }
  }

  // COMMENTS
  Future<List<Comment>> getCommentsByGuide(String guideId) async {
    try {
      final snapshot = await _commentsCollection
          .where('guideId', isEqualTo: guideId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        return Comment.fromMap({...doc.data(), 'id': doc.id});
      }).toList();
    } catch (e) {
      debugPrint('Error getting comments by guide: $e');
      return [];
    }
  }
}