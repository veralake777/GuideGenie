import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../models/game.dart';
import '../models/user.dart' as app_models;
import 'firebase_service.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseService.instance.firestore;

  CollectionReference<Map<String, dynamic>> get _posts => _firestore.collection('posts');
  CollectionReference<Map<String, dynamic>> get _comments => _firestore.collection('comments');
  CollectionReference<Map<String, dynamic>> get _games => _firestore.collection('games');
  CollectionReference<Map<String, dynamic>> get _users => _firestore.collection('users');

  // Posts
  Future<List<Post>> getAllPosts() async {
    final snapshot = await _posts.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => Post.fromJson({...doc.data(), 'id': doc.id})).toList();
  }

  Future<List<Post>> getPostsByGame(String gameId) async {
    final snapshot = await _posts.where('gameId', isEqualTo: gameId).orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => Post.fromJson({...doc.data(), 'id': doc.id})).toList();
  }

  Future<void> createPost(Post post) async {
    final postMap = post.toJson();
    postMap.remove('id');
    await _posts.add(postMap);
  }

  Future<Post?> getPostById(String id) async {
    final doc = await _posts.doc(id as String?).get();
    if (!doc.exists) return null;
    return Post.fromJson({...doc.data()!, 'id': doc.id});
  }

  // Comments
  Future<List<Comment>> getCommentsByPost(String postId) async {
    final snapshot = await _comments.where('postId', isEqualTo: postId).orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => Comment.fromJson({...doc.data(), 'id': doc.id})).toList();
  }

  Future<void> createComment(Comment comment) async {
    final commentMap = comment.toJson();
    commentMap.remove('id');
    await _comments.add(commentMap);
  }

  // Games
  Future<List<Game>> getAllGames() async {
    final snapshot = await _games.get();
    return snapshot.docs.map((doc) => Game.fromJson({...doc.data(), 'id': doc.id})).toList();
  }

  Future<Game?> getGameById(String id) async {
    final doc = await _games.doc(id).get();
    if (!doc.exists) return null;
    return Game.fromJson({...doc.data()!, 'id': doc.id});
  }

  // Users
  Future<app_models.User?> getUserById(String id) async {
    final doc = await _users.doc(id).get();
    if (!doc.exists) return null;
    return app_models.User.fromJson({...doc.data()!, 'id': doc.id});
  }

  Future<void> createUser(app_models.User user) async {
    final userMap = user.toJson();
    userMap.remove('id');
    await _users.doc(user.id as String?).set(userMap);
  }

  Future<void> updateUser(app_models.User user) async {
    final userMap = user.toJson();
    userMap.remove('id');
    await _users.doc(user.id as String?).update(userMap);
  }
}
