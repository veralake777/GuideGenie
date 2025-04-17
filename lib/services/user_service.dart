import 'package:guide_genie/models/user.dart';
import 'package:guide_genie/services/database_service.dart';

class UserService {
  final DatabaseService _db = DatabaseService();
  
  // Get a user by ID
  Future<User?> getUserById(String userId) async {
    // Implementation would normally query database
    // For now, return a test user
    return User(
      id: userId,
      username: 'TestUser',
      email: 'test@example.com',
      bio: 'Gaming enthusiast',
      favoriteGames: [],
      upvotedPosts: [],
      downvotedPosts: [],
      upvotedComments: [],
      downvotedComments: [],
      bookmarkedPosts: [],
      reputation: 0,
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );
  }
  
  // Update user data
  Future<bool> updateUser(User user) async {
    try {
      // Log for debugging
      print('UserService: Updating user ${user.id}');
      print('UserService: Bookmarked posts: ${user.bookmarkedPosts}');
      
      // Here we would normally update the user in the database
      // For now, just return success
      return true;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }
  
  // Toggle bookmark status
  Future<bool> toggleBookmark(User user, String postId) async {
    try {
      final bookmarkedPosts = List<String>.from(user.bookmarkedPosts);
      
      if (bookmarkedPosts.contains(postId)) {
        bookmarkedPosts.remove(postId);
      } else {
        bookmarkedPosts.add(postId);
      }
      
      final updatedUser = user.copyWith(
        bookmarkedPosts: bookmarkedPosts,
      );
      
      // Update user in database (mock)
      print('UserService: Toggled bookmark for post $postId');
      print('UserService: Updated bookmarks: $bookmarkedPosts');
      
      return await updateUser(updatedUser);
    } catch (e) {
      print('Error toggling bookmark: $e');
      return false;
    }
  }
}