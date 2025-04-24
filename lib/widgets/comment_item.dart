import 'package:flutter/material.dart';
import 'package:guide_genie/models/comment.dart';
import 'package:guide_genie/providers/auth_provider.dart';
import 'package:guide_genie/providers/post_provider.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentItem extends StatelessWidget {
  final Comment comment;
  final int depth;
  final Function(Comment) onReply;

  // Maximum nesting level for comments
  static const int maxDepth = 3;

  const CommentItem({
    Key? key,
    required this.comment,
    required this.depth,
    required this.onReply,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    final childComments = postProvider.getChildComments(comment.id);
    
    return Container(
      margin: EdgeInsets.only(
        left: depth * 16.0,
        bottom: 16.0,
      ),
      decoration: BoxDecoration(
        border: Border(
          left: depth > 0
              ? BorderSide(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  width: 2,
                )
              : BorderSide.none,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: depth > 0 ? 8.0 : 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Comment header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  radius: 12,
                  child: Text(
                    (comment.authorName?.isNotEmpty == true ? comment.authorName![0] : 'A').toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  comment.authorName ?? 'Anonymous',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  timeago.format(comment.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            
            // Comment content
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Text(
                comment.content,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            
            // Comment actions
            Row(
              children: [
                // Upvote button
                IconButton(
                  icon: Icon(
                    Icons.arrow_upward,
                    size: 16,
                    color: authProvider.hasUpvotedComment(comment.id)
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                  ),
                  onPressed: () => _upvoteComment(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 4),
                Text(
                  '${comment.upvotes}',
                  style: const TextStyle(fontSize: 12),
                ),
                
                const SizedBox(width: 16),
                
                // Downvote button
                IconButton(
                  icon: Icon(
                    Icons.arrow_downward,
                    size: 16,
                    color: authProvider.hasDownvotedComment(comment.id)
                        ? Theme.of(context).colorScheme.error
                        : Colors.grey,
                  ),
                  onPressed: () => _downvoteComment(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 4),
                Text(
                  '${comment.downvotes}',
                  style: const TextStyle(fontSize: 12),
                ),
                
                const SizedBox(width: 16),
                
                // Reply button (only show if we haven't reached max depth)
                if (depth < maxDepth)
                  TextButton(
                    onPressed: () => onReply(comment),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Reply',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
            
            // Child comments (recursive)
            if (childComments.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  children: childComments.map((childComment) {
                    return CommentItem(
                      comment: childComment,
                      depth: depth + 1,
                      onReply: onReply,
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _upvoteComment(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    
    final user = authProvider.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be logged in to vote')),
      );
      return;
    }
    
    if (authProvider.hasUpvotedComment(comment.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have already upvoted this comment')),
      );
      return;
    }
    
    final success = await postProvider.upvoteComment(comment.id, user.id);
    
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(postProvider.errorMessage ?? 'Failed to upvote comment')),
      );
    }
  }

  void _downvoteComment(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    
    final user = authProvider.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be logged in to vote')),
      );
      return;
    }
    
    if (authProvider.hasDownvotedComment(comment.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have already downvoted this comment')),
      );
      return;
    }
    
    final success = await postProvider.downvoteComment(comment.id, user.id);
    
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(postProvider.errorMessage ?? 'Failed to downvote comment')),
      );
    }
  }
}
