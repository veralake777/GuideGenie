import 'package:flutter/material.dart';
import 'package:guide_genie/services/api_service_new.dart';
import 'package:guide_genie/utils/constants.dart';
import 'package:guide_genie/utils/ui_helper.dart';
import 'package:guide_genie/utils/validation_helper.dart';
import 'package:uuid/uuid.dart';

class CreateGameScreen extends StatefulWidget {
  const CreateGameScreen({Key? key}) : super(key: key);

  @override
  _CreateGameScreenState createState() => _CreateGameScreenState();
}

class _CreateGameScreenState extends State<CreateGameScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  final Uuid _uuid = const Uuid();
  bool _isLoading = false;
  
  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  
  String _selectedGenre = 'FPS';
  final List<String> _genres = [
    'Battle Royale',
    'MOBA',
    'FPS',
    'Fighting',
    'Strategy',
    'Sports',
    'Racing',
    'RPG',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create game data
      final gameData = {
        'id': 'game-${_uuid.v4().substring(0, 8)}',
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'imageUrl': _imageUrlController.text.trim(),
        'genre': _selectedGenre,
        'rating': 4.0, // Default rating
        'isFeatured': false,
        'developer': 'Unknown Developer',
        'publisher': 'Unknown Publisher',
        'releaseDate': DateTime.now().toIso8601String(), 
      };

      // Send POST request to create the game
      await _apiService.createGame(gameData);

      setState(() {
        _isLoading = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Game created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to the previous screen
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create game: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const neonColor = Color(0xFF00FFFF); // Cyan neon
    const fontFamily = 'Audiowide'; // Gaming font

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Game'),
        elevation: 0,
      ),
      body: Container(
        decoration: UIHelper.gamingGradientBackground(),
        child: Stack(
          children: [
            // Add grid pattern overlay
            UIHelper.gridPatternOverlay(opacity: 0.05),
            
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Heading
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Add a New Game',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: neonColor,
                              fontFamily: fontFamily,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Fill in the details to add a new game to the platform',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Game Name
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Game Name',
                        hintText: 'Enter the name of the game',
                        prefixIcon: const Icon(Icons.games),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: ValidationHelper.validateNotEmpty,
                    ),
                    const SizedBox(height: 16),

                    // Game Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        hintText: 'Enter a description of the game',
                        prefixIcon: const Icon(Icons.description),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 3,
                      validator: ValidationHelper.validateNotEmpty,
                    ),
                    const SizedBox(height: 16),

                    // Image URL
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: InputDecoration(
                        labelText: 'Image URL',
                        hintText: 'Enter the URL of the game cover image',
                        prefixIcon: const Icon(Icons.image),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: ValidationHelper.validateUrl,
                    ),
                    const SizedBox(height: 16),

                    // Genre Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedGenre,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedGenre = newValue!;
                        });
                      },
                      items: _genres.map((genre) {
                        return DropdownMenuItem(
                          value: genre,
                          child: Text(genre),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Genre',
                        prefixIcon: const Icon(Icons.category),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: neonColor,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                              )
                            : const Text(
                                'CREATE GAME',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}