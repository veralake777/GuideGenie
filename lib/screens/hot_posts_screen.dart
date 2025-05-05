import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/post_card.dart';

class HotPostsScreen extends StatelessWidget {
  const HotPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hot Posts')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('upvotes', descending: true)
            .limit(50)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hot posts found.'));
          }

          final posts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final data = posts[index].data() as Map<String, dynamic>;
              final authorRef = data['users'] as DocumentReference?;

              if (authorRef is DocumentReference) {
                return FutureBuilder<DocumentSnapshot>(
                  future: authorRef.get(),
                  builder: (context, authorSnapshot) {
                    final authorName = authorSnapshot.data?.get('username') ?? 'Unknown';
                    final postData = {
                      ...data,
                      'id': posts[index].id,
                    };
                    return PostCard(postData: postData, authorName: authorName, postId: postData['id']);
                  },
                );
              } else {
                final postData = {
                  ...data,
                  'id': posts[index].id,
                };
                return PostCard(postData: postData, authorName: 'Unknown', postId: postData['id']);
              }
            },
          );
        },
      ),
    );
  }
}