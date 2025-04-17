import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/guide_post.dart';
import '../providers/auth_provider.dart';
import '../providers/post_provider.dart';
import '../services/api_service_new.dart';
import '../utils/constants.dart';
import '../utils/ui_helper.dart';
import '../widgets/guide_list_item.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_indicator.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({Key? key}) : super(key: key);

  @override
  _BookmarksScreenState createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  bool isLoading = true;
  List<GuidePost> bookmarkedGuides = [];
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBookmarkedGuides();
  }

  Future<void> _loadBookmarkedGuides() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      final apiService = ApiService();
      
      if (!authProvider.isAuthenticated) {
        setState(() {
          isLoading = false;
          errorMessage = 'You need to be logged in to view bookmarks';
        });
        return;
      }
      
      final user = authProvider.currentUser;
      if (user == null) {
        setState(() {
          isLoading = false;
          errorMessage = 'User information not available';
        });
        return;
      }
      
      // Get user's bookmarked post IDs
      final bookmarkedIds = user.bookmarkedPosts;
      
      if (bookmarkedIds.isEmpty) {
        setState(() {
          isLoading = false;
          bookmarkedGuides = [];
        });
        return;
      }
      
      print('Found ${bookmarkedIds.length} bookmarked posts: $bookmarkedIds');
      
      // Load all posts if needed
      if (postProvider.posts.isEmpty) {
        await postProvider.loadPosts();
      }
      
      // Filter posts to only include bookmarked ones
      final allGuides = await postProvider.getPosts();
      final filtered = allGuides.where((guide) => 
        bookmarkedIds.contains(guide.id)).toList();
      
      print('Displaying ${filtered.length} bookmarked guides');
      
      setState(() {
        bookmarkedGuides = filtered;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading bookmarked guides: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load bookmarks: ${e.toString()}';
      });
    }
  }

  Future<void> _handleRefresh() async {
    await _loadBookmarkedGuides();
    return;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bookmarks',
          style: TextStyle(
            fontFamily: AppConstants.gamingFontFamily,
            letterSpacing: 1,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _handleRefresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Container(
        decoration: UIHelper.gamingGradientBackground(),
        child: isLoading
            ? const LoadingIndicator(message: 'Loading your bookmarks...')
            : !authProvider.isAuthenticated
                ? Center(
                    child: EmptyState(
                      icon: Icons.login,
                      title: 'Login Required',
                      message: 'You need to login to view your bookmarks',
                      actionLabel: 'Login',
                      onAction: () {
                        Navigator.pushNamed(context, AppConstants.loginRoute);
                      },
                    ),
                  )
                : errorMessage != null
                    ? Center(
                        child: EmptyState(
                          icon: Icons.error_outline,
                          title: 'Error',
                          message: errorMessage!,
                          actionLabel: 'Try Again',
                          onAction: _loadBookmarkedGuides,
                        ),
                      )
                    : bookmarkedGuides.isEmpty
                        ? Center(
                            child: EmptyState(
                              icon: Icons.bookmark_border,
                              title: 'No Bookmarks Yet',
                              message: 'Bookmark your favorite guides to access them quickly!',
                              actionLabel: 'Explore Guides',
                              onAction: () {
                                Navigator.pushReplacementNamed(context, AppConstants.homeRoute);
                              },
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _handleRefresh,
                            backgroundColor: AppConstants.gamingDarkBlue,
                            color: AppConstants.primaryNeon,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(AppConstants.paddingM),
                              itemCount: bookmarkedGuides.length,
                              itemBuilder: (ctx, i) {
                                final guide = bookmarkedGuides[i];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: AppConstants.paddingM),
                                  child: GuideListItem(
                                    guide: guide,
                                    showGameInfo: true,
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppConstants.postDetailsRoute,
                                        arguments: {'postId': guide.id},
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
      ),
    );
  }
}