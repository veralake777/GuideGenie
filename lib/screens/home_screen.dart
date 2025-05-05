// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guide_genie/widgets/post_card.dart';
import 'package:guide_genie/utils/ui_constants.dart';
import 'package:guide_genie/utils/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Home Feed'),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No posts yet.'));
          }

          final posts = snapshot.data!.docs;

          return ListView.separated(
            // padding: const EdgeInsets.symmetric(
            //   horizontal: UIConstants.screenPadding,
            //   vertical: UIConstants.cardElementSpacing,
            // ),
            itemCount: posts.length,
            separatorBuilder: (_, __) => const SizedBox(height: UIConstants.cardElementSpacing),
            itemBuilder: (context, index) {
              final data = posts[index].data() as Map<String, dynamic>;
              final authorRef = data['users'] as DocumentReference?;

              if (authorRef is DocumentReference) {
                return FutureBuilder<DocumentSnapshot>(
                  future: authorRef.get(),
                  builder: (context, snapshot) {
                    final authorName = snapshot.data?.get('username') ?? 'Unknown';
                    return PostCard(
                      postData: data,
                      authorName: authorName,
                      postId: posts[index].id,
                    );
                  },
                );
              } else {
                return PostCard(
                  postData: data,
                  authorName: 'Unknown',
                  postId: posts[index].id,
                );
              }
            },
          );
        },
      ),
    );
  }
}
