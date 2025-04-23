import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:guide_genie/providers/auth_provider.dart';
import 'package:guide_genie/providers/game_provider.dart';
import 'package:guide_genie/providers/post_provider.dart';
import 'package:guide_genie/utils/constants.dart';
import 'package:guide_genie/widgets/loading_indicator.dart';

class CreatePostScreen extends StatefulWidget {
  final String? gameId;

  const CreatePostScreen({
    Key? key,
    this.gameId,
  }) : super(key: key);

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();
  
  String? _selectedGameId;
  String _selectedType = 'strategy';
  bool _isSubmitting = false;
  
  @override
  void initState() {
    super.initState();
    _selectedGameId = widget.gameId;
    
    // Fetch games if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      if (gameProvider.games.isEmpty) {
        gameProvider.fetchGames();
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    
    final user = authProvider.currentUser;
    if (user == null || _selectedGameId == null) {
      // This shouldn't happen as the form validation should prevent it
      return;
    }
    
    final selectedGame = gameProvider.games.firstWhere(
      (game) => game.id == _selectedGameId,
    );
    
    final tags = _tagsController.text.isEmpty 
        ? <String>[] 
        : _tagsController.text.split(',').map((tag) => tag.trim()).toList();
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      final success = await postProvider.createPost(
        _titleController.text,
        _contentController.text,
        _selectedGameId!,
        selectedGame.name,
        _selectedType,
        tags,
        user.id,
        user.username,
        user.avatarUrl ?? '',
      );
      
      if (!mounted) return;
      
      if (success) {
        // Show success message and navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Guide created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to the post details screen
        Navigator.pop(context);
      } else {
        // Show error message
        setState(() {
          _isSubmitting = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(postProvider.errorMessage ?? 'Failed to create guide'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final gameProvider = Provider.of<GameProvider>(context);
    
    // Check if user is authenticated
    if (!authProvider.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Create Guide')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'You need to be logged in to create guides',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeL,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.paddingL),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    AppConstants.loginRoute,
                  );
                },
                child: const Text('Log In'),
              ),
            ],
          ),
        ),
      );
    }
    
    // Show loading indicator if games are still loading
    if (gameProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Create Guide')),
        body: const LoadingIndicator(message: 'Loading games...'),
      );
    }
    
    // Show error if games couldn't be loaded
    if (gameProvider.errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Create Guide')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Failed to load games',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeL,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.paddingM),
              Text(
                gameProvider.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: AppConstants.paddingL),
              ElevatedButton(
                onPressed: () {
                  gameProvider.fetchGames();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Guide'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isSubmitting ? null : _submitPost,
            tooltip: 'Submit',
          ),
        ],
      ),
      body: _isSubmitting
          ? const LoadingIndicator(message: 'Creating guide...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingL),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGameDropdown(gameProvider),
                    const SizedBox(height: AppConstants.paddingL),
                    _buildGuideTypeDropdown(),
                    const SizedBox(height: AppConstants.paddingL),
                    _buildTitleField(),
                    const SizedBox(height: AppConstants.paddingL),
                    _buildContentField(),
                    const SizedBox(height: AppConstants.paddingL),
                    _buildTagsField(),
                    const SizedBox(height: AppConstants.paddingXL),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildGameDropdown(GameProvider gameProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Game',
          style: TextStyle(
            fontSize: AppConstants.fontSizeM,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.paddingXS),
        DropdownButtonFormField<String>(
          value: _selectedGameId,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Select a game',
          ),
          items: gameProvider.games.map((game) {
            return DropdownMenuItem<String>(
              value: game.id,
              child: Text(game.name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedGameId = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a game';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildGuideTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Guide Type',
          style: TextStyle(
            fontSize: AppConstants.fontSizeM,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.paddingXS),
        DropdownButtonFormField<String>(
          value: _selectedType,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          items: AppConstants.guideTypeNames.keys.map((String typeName) {
            final displayName = AppConstants.guideTypeNames[typeName] ?? typeName;
            final icon = AppConstants.guideTypeIcons[typeName] ?? Icons.article;
            
            return DropdownMenuItem<String>(
              value: typeName,
              child: Row(
                children: [
                  Icon(icon, size: AppConstants.iconSizeM),
                  const SizedBox(width: AppConstants.paddingS),
                  Text(displayName),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedType = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Title',
          style: TextStyle(
            fontSize: AppConstants.fontSizeM,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.paddingXS),
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter a descriptive title',
          ),
          maxLength: 100,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a title';
            }
            if (value.length < 10) {
              return 'Title must be at least 10 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildContentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Content',
          style: TextStyle(
            fontSize: AppConstants.fontSizeM,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.paddingXS),
        TextFormField(
          controller: _contentController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Write your guide content here',
            alignLabelWithHint: true,
          ),
          maxLines: 15,
          maxLength: 5000,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter some content';
            }
            if (value.length < 50) {
              return 'Content must be at least 50 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTagsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tags (optional)',
          style: TextStyle(
            fontSize: AppConstants.fontSizeM,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.paddingXS),
        TextFormField(
          controller: _tagsController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'e.g. Season 3, Weapons, Beginners (comma separated)',
          ),
        ),
        const SizedBox(height: AppConstants.paddingXS),
        Text(
          'Add relevant tags to help others find your guide',
          style: TextStyle(
            fontSize: AppConstants.fontSizeS,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitPost,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingM),
        ),
        child: const Text(
          'Submit Guide',
          style: TextStyle(
            fontSize: AppConstants.fontSizeL,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}