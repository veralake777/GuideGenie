import 'package:flutter/material.dart';
import 'package:guide_genie/models/comment.dart';
import 'package:guide_genie/models/post.dart';
import 'package:guide_genie/providers/auth_provider.dart';
import 'package:guide_genie/providers/post_provider.dart';
import 'package:guide_genie/widgets/comment_item.dart';
import 'package:guide_genie/widgets/custom_app_bar.dart';
import 'package:guide_genie/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostScreen extends StatefulWidget {
  final Post post;

  const PostScreen({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final _commentController = TextEditingController();
  bool _isPostingComment = false;

  @override
  void initState() {
    super.initState();
    
    // Load comments when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      postProvider.selectPost(widget.post);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _postComment() async {
    if (_commentController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _isPostingComment = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    
    final user = authProvider.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be logged in to comment')),
      );
      setState(() {
        _isPostingComment = false;
      });
      return;
    }
    
    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID
      postId: widget.post.id,
      authorId: user.id,
      authorName: user.username,
      content: _commentController.text.trim(),
      createdAt: DateTime.now(),
    );
    
    final success = await postProvider.createComment(newComment);
    
    if (success) {
      _commentController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(postProvider.errorMessage ?? 'Failed to post comment')),
      );
    }
    
    setState(() {
      _isPostingComment = false;
    });
  }

  Future<void> _upvotePost() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    
    final user = authProvider.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be logged in to vote')),
      );
      return;
    }
    
    if (authProvider.hasUpvotedPost(widget.post.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have already upvoted this post')),
      );
      return;
    }
    
    final success = await postProvider.votePost(widget.post.id, true);
    
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(postProvider.errorMessage ?? 'Failed to upvote post')),
      );
    }
  }

  Future<void> _downvotePost() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    
    final user = authProvider.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be logged in to vote')),
      );
      return;
    }
    
    if (authProvider.hasDownvotedPost(widget.post.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have already downvoted this post')),
      );
      return;
    }
    
    final success = await postProvider.downvotePost(widget.post.id, user.id);
    
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(postProvider.errorMessage ?? 'Failed to downvote post')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    // If the post is selected, use the most up-to-date data
    final post = postProvider.selectedPost ?? widget.post;
    
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Post',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Post content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Post header
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Post metadata
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        radius: 12,
                        child: Text(
                          post.authorName[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        post.authorName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        timeago.format(post.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  
                  // Tags
                  if (post.tags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: post.tags.map((tag) {
                          return Chip(
                            label: Text(
                              tag,
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          );
                        }).toList(),
                      ),
                    ),
                  
                  const Divider(height: 32),
                  
                  // Post content
                  Text(
                    post.content,
                    style: const TextStyle(fontSize: 16),
                  ),
                  
                  // Media content
                  if (post.mediaUrls.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.image,
                          size: 48,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 16),
                  
                  // Voting buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.arrow_upward,
                              color: authProvider.hasUpvotedPost(post.id)
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey,
                            ),
                            onPressed: _upvotePost,
                          ),
                          Text(
                            '${post.upvotes}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.arrow_downward,
                              color: authProvider.hasDownvotedPost(post.id)
                                  ? Theme.of(context).colorScheme.error
                                  : Colors.grey,
                            ),
                            onPressed: _downvotePost,
                          ),
                          Text(
                            '${post.downvotes}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.comment,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${post.commentIds.length} comments',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const Divider(height: 32),
                  
                  // Comments section header
                  const Text(
                    'Comments',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Comments list
                  _buildCommentsList(),
                ],
              ),
            ),
          ),
          
          // Comment input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(
                top: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(12),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.newline,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: _isPostingComment
                      ? const LoadingIndicator()
                      : IconButton(
                          icon: Icon(
                            Icons.send,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          onPressed: _postComment,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCommentsList() {
    final postProvider = Provider.of<PostProvider>(context);
    
    if (postProvider.isLoading) {
      return const Center(
        child: LoadingIndicator(),
      );
    }
    
    if (postProvider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 24,
              color: Colors.red,
            ),
            const SizedBox(height: 8),
            Text(
              'Failed to load comments',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                postProvider.loadCommentsForPost(widget.post.id);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    final comments = postProvider.getThreadedComments(widget.post.id);
    
    if (comments.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24.0),
          child: Text(
            'No comments yet. Be the first to comment!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: comments.length,
      itemBuilder: (context, index) {
        return CommentItem(
          comment: comments[index],
          depth: 0,
          onReply: (parentComment) {
            // Set comment text to reply format
            _commentController.text = '@${parentComment.authorName} ';
            _commentController.selection = TextSelection.fromPosition(
              TextPosition(offset: _commentController.text.length),
            );
            
            // Focus the comment field
            FocusScope.of(context).requestFocus(FocusNode());
          },
        );
      },
    );
  }
}
