// lib/widgets/post_card.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostCard extends StatefulWidget {
  final Map<String, dynamic> postData;
  final String authorName;
  final String postId;

  const PostCard({
    super.key,
    required this.postData,
    required this.authorName,
    required this.postId
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isBookmarked = false;
  bool isUpvoted = false;
  bool isDownvoted = false;

  Future<void> _handleVote({required bool upvote}) async {
    if (FirebaseAuth.instance.currentUser == null) return;

    final postId = widget.postData['id'];
    if (postId == null) return;

    final field = upvote ? 'upvotes' : 'downvotes';
    final value = (widget.postData[field] ?? 0) + 1;

    setState(() {
      isUpvoted = upvote;
      isDownvoted = !upvote;
    });

    await FirebaseFirestore.instance.collection('posts').doc(postId).update({field: value});
  }

  void _handleCommentTap() {
    final postId = widget.postData['id'];
    if (postId == null) return;

    Navigator.pushNamed(context, '/post', arguments: postId);
  }

  void _handleBookmark() {
    setState(() {
      isBookmarked = !isBookmarked;
    });

    // Optionally update Firestore bookmark status here
  }

  void _handleMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => const SizedBox(height: 100, child: Center(child: Text('More options'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.postData;
    final theme = Theme.of(context);
    final preview = (post['content'] as String?)?.substring(0, (post['content'] as String?)?.length.clamp(0, 100) ?? 0) ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left vote column
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_upward,
                          color: isUpvoted ? Colors.purpleAccent : Colors.grey),
                      onPressed: () => _handleVote(upvote: true),
                    ),
                    Text('${post['upvotes'] ?? 0}'),
                    IconButton(
                      icon: Icon(Icons.arrow_downward,
                          color: isDownvoted ? Colors.redAccent : Colors.grey),
                      onPressed: () => _handleVote(upvote: false),
                    ),
                  ],
                ),
              ),

              // Right main content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Meta
                      Row(
                        children: [
                          Text('u/${widget.authorName}', style: theme.textTheme.labelMedium),
                          const SizedBox(width: 8),
                          Text('• ${post['createdAt']?.toDate().toLocal().toString().split(' ').first ?? 'now'}',
                              style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey)),
                          const Spacer(),
                          IconButton(
                            onPressed: _handleMoreOptions,
                            icon: const Icon(Icons.more_horiz, size: 20),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Title
                      Text(post['title'] ?? '', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),

                      const SizedBox(height: 4),

                      // Preview
                      Text(preview, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),

                      const SizedBox(height: 8),

                      // Action bar
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.comment_outlined),
                            onPressed: _handleCommentTap,
                          ),
                          Text('${post['commentCount'] ?? 0}'),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: Icon(
                              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            ),
                            onPressed: _handleBookmark,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
