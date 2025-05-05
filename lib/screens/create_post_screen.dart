import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/constants.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  bool _isSubmitting = false;

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to post.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final newPost = {
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'createdAt': Timestamp.now(),
        'author': FirebaseFirestore.instance.collection('users').doc(user.uid),
        'authorId': user.uid,
        'upvotes': 0,
        'downvotes': 0,
      };

      await FirebaseFirestore.instance.collection('posts').add(newPost);

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, AppConstants.homeRoute, (route) => false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post created successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create post: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Post')),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: AppConstants.paddingM),
              TextFormField(
                controller: _contentController,
                maxLines: 8,
                decoration: const InputDecoration(labelText: 'Content'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter content'
                    : null,
              ),
              const SizedBox(height: AppConstants.paddingL),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitPost,
                  child: _isSubmitting
                      ? const CircularProgressIndicator.adaptive()
                      : const Text('Submit Post'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
