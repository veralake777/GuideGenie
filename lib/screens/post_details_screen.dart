import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:guide_genie/models/post.dart';
import 'package:guide_genie/models/comment.dart';
import 'package:guide_genie/providers/auth_provider.dart';
import 'package:guide_genie/providers/post_provider.dart';
import 'package:guide_genie/utils/constants.dart';
import 'package:guide_genie/widgets/loading_indicator.dart';
import 'package:guide_genie/widgets/error_message.dart';

class PostDetailsScreen extends StatefulWidget {
  final String postId;

  const PostDetailsScreen({
    Key? key,
    required this.postId,
  }) : super(key: key);

  @override
  _PostDetailsScreenState createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  final _commentController = TextEditingController();
  bool _isAddingComment = false;

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch post details and comments
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      postProvider.fetchPostDetails(widget.postId);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<PostProvider>(
        builder: (context, postProvider, _) {
          final post = postProvider.selectedPost;
          
          if (postProvider.isLoading) {
            return const LoadingIndicator(message: 'Loading guide...');
          }

          if (postProvider.errorMessage != null) {
            return ErrorMessage(
              message: postProvider.errorMessage!,
              onRetry: () => postProvider.fetchPostDetails(widget.postId),
            );
          }

          if (post == null) {
            return const Center(
              child: Text('Guide not found'),
            );
          }

          return CustomScrollView(
            slivers: [
              _buildAppBar(post),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPostHeader(post),
                    _buildPostContent(post),
                    _buildCommentSection(postProvider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(Post post) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 120,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          post.title,
          style: const TextStyle(
            fontSize: AppConstants.fontSizeL,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        background: Container(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      actions: [
        // Vote buttons
        Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            if (authProvider.isAuthenticated) {
              return Row(
                children: [
                  // Upvote
                  IconButton(
                    icon: const Icon(Icons.thumb_up),
                    onPressed: () {
                      final postProvider = Provider.of<PostProvider>(
                        context,
                        listen: false,
                      );
                      postProvider.votePost(post.id, true);
                    },
                  ),
                  // Downvote
                  IconButton(
                    icon: const Icon(Icons.thumb_down),
                    onPressed: () {
                      final postProvider = Provider.of<PostProvider>(
                        context,
                        listen: false,
                      );
                      postProvider.votePost(post.id, false);
                    },
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildPostHeader(Post post) {
    // Get the guide type name and icon
    final typeName = post.type.toString().split('.').last;
    final IconData typeIcon = AppConstants.guideTypeIcons[typeName] ?? Icons.article;
    
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post metadata
          Row(
            children: [
              // Author avatar
              CircleAvatar(
                radius: AppConstants.avatarSizeM / 2,
                backgroundImage: NetworkImage(post.authorAvatarUrl),
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                onBackgroundImageError: (exception, stackTrace) {
                  // Handle image loading error
                },
                child: post.authorAvatarUrl.isEmpty 
                    ? Text(post.authorName[0], style: TextStyle(color: Theme.of(context).colorScheme.primary))
                    : null,
              ),
              const SizedBox(width: AppConstants.paddingM),
              // Author name and post date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppConstants.fontSizeM,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Posted on ${_formatDate(post.createdAt)}',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeS,
                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              // Guide type badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingM,
                  vertical: AppConstants.paddingXS,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      typeIcon,
                      size: AppConstants.iconSizeS,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: AppConstants.paddingXS),
                    Text(
                      AppConstants.guideTypeNames[typeName] ?? typeName,
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeS,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingM),
          
          // Game and tags
          Row(
            children: [
              Icon(
                Icons.videogame_asset,
                size: AppConstants.iconSizeS,
                color: Colors.grey,
              ),
              const SizedBox(width: AppConstants.paddingXS),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppConstants.gameDetailsRoute,
                    arguments: {'gameId': post.gameId},
                  );
                },
                child: Text(
                  post.gameName,
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeS,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          
          // Tags
          if (post.tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppConstants.paddingS),
              child: Wrap(
                spacing: AppConstants.paddingXS,
                runSpacing: AppConstants.paddingXS,
                children: post.tags.map((tag) {
                  return Chip(
                    label: Text(
                      tag,
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeXS,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.all(0),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
            ),
          
          const Divider(height: AppConstants.paddingXL),
        ],
      ),
    );
  }

  Widget _buildPostContent(Post post) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingL,
        vertical: AppConstants.paddingM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post content
          Text(
            post.content,
            style: TextStyle(
              fontSize: AppConstants.fontSizeM,
              height: 1.6,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: AppConstants.paddingXL),
          
          // Post stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Upvotes
              Row(
                children: [
                  Icon(
                    Icons.thumb_up,
                    size: AppConstants.iconSizeS,
                    color: Colors.green,
                  ),
                  const SizedBox(width: AppConstants.paddingXS),
                  Text(
                    post.upvotes.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppConstants.fontSizeS,
                    ),
                  ),
                ],
              ),
              // Downvotes
              Row(
                children: [
                  Icon(
                    Icons.thumb_down,
                    size: AppConstants.iconSizeS,
                    color: Colors.red,
                  ),
                  const SizedBox(width: AppConstants.paddingXS),
                  Text(
                    post.downvotes.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppConstants.fontSizeS,
                    ),
                  ),
                ],
              ),
              // Comments
              Row(
                children: [
                  Icon(
                    Icons.comment,
                    size: AppConstants.iconSizeS,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: AppConstants.paddingXS),
                  Text(
                    post.commentCount.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppConstants.fontSizeS,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: AppConstants.paddingXL),
        ],
      ),
    );
  }

  Widget _buildCommentSection(PostProvider postProvider) {
    final comments = postProvider.comments;
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Padding(
      padding: const EdgeInsets.only(
        left: AppConstants.paddingL,
        right: AppConstants.paddingL,
        bottom: AppConstants.paddingXXL,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          const Text(
            'Comments',
            style: TextStyle(
              fontSize: AppConstants.fontSizeL,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.paddingM),
          
          // Comment form (only for authenticated users)
          if (authProvider.isAuthenticated)
            Column(
              children: [
                TextField(
                  controller: _commentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Write a comment...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.paddingS),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: _isAddingComment
                        ? null
                        : () => _addComment(postProvider, authProvider),
                    child: _isAddingComment
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Post Comment'),
                  ),
                ),
                const Divider(height: AppConstants.paddingXL),
              ],
            ),
          
          // Comments list
          comments.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppConstants.paddingL),
                    child: Text(
                      'No comments yet. Be the first to comment!',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return _buildCommentItem(comment);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Comment comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comment header
          Row(
            children: [
              // Author avatar
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(comment.authorAvatarUrl),
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                onBackgroundImageError: (exception, stackTrace) {
                  // Handle image loading error
                },
                child: comment.authorAvatarUrl.isEmpty 
                    ? Text(comment.authorName[0], style: TextStyle(color: Theme.of(context).colorScheme.primary))
                    : null,
              ),
              const SizedBox(width: AppConstants.paddingS),
              // Author name and comment date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.authorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppConstants.fontSizeS,
                      ),
                    ),
                    Text(
                      _formatDate(comment.createdAt),
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeXS,
                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingS),
          // Comment content
          Text(
            comment.content,
            style: TextStyle(
              fontSize: AppConstants.fontSizeS,
              height: 1.5,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: AppConstants.paddingS),
          // Comment stats
          Row(
            children: [
              // Upvotes
              Row(
                children: [
                  Icon(
                    Icons.thumb_up_outlined,
                    size: AppConstants.iconSizeS,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    comment.upvotes.toString(),
                    style: const TextStyle(
                      fontSize: AppConstants.fontSizeXS,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppConstants.paddingM),
              // Downvotes
              Row(
                children: [
                  Icon(
                    Icons.thumb_down_outlined,
                    size: AppConstants.iconSizeS,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    comment.downvotes.toString(),
                    style: const TextStyle(
                      fontSize: AppConstants.fontSizeXS,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _addComment(PostProvider postProvider, AuthProvider authProvider) async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) return;

    final user = authProvider.currentUser;
    if (user == null) return;

    setState(() {
      _isAddingComment = true;
    });

    try {
      final success = await postProvider.addComment(
        widget.postId,
        comment,
        user.id,
        user.username,
        user.avatarUrl ?? '',
      );

      if (success) {
        _commentController.clear();
      }
    } finally {
      setState(() {
        _isAddingComment = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      if (difference.inHours < 1) {
        if (difference.inMinutes < 1) {
          return 'Just now';
        } else {
          return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
        }
      } else {
        return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
      }
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}