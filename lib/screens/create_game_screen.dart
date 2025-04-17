import 'package:flutter/material.dart';
import 'package:guide_genie/models/game.dart';
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
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _developerController = TextEditingController();
  final _publisherController = TextEditingController();
  
  String _selectedGenre = 'FPS';
  List<String> _selectedPlatforms = [];
  bool _isFeatured = false;
  
  bool _isLoading = false;
  String? _errorMessage;
  
  final List<String> _genreOptions = [
    'FPS', 'Battle Royale', 'MOBA', 'Fighting', 'RPG', 'Action', 'Adventure', 
    'Strategy', 'Sports', 'Racing', 'Simulation', 'Puzzle', 'Card', 'Other'
  ];
  
  final List<String> _platformOptions = [
    'PC', 'PlayStation 5', 'PlayStation 4', 'Xbox Series X/S', 'Xbox One', 
    'Nintendo Switch', 'iOS', 'Android', 'Mac', 'Linux'
  ];
  
  final ApiService _apiService = ApiService();
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _developerController.dispose();
    _publisherController.dispose();
    super.dispose();
  }
  
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Generate a unique ID
      final id = const Uuid().v4();
      
      // Create game object
      final game = Game(
        id: id,
        title: _titleController.text.trim(),
        name: _titleController.text.trim(),  // Using title as name
        description: _descriptionController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
        genre: _selectedGenre,
        genres: [_selectedGenre], // Only use single genre at time of creation
        platforms: _selectedPlatforms,
        developer: _developerController.text.trim(),
        publisher: _publisherController.text.trim(),
        rating: 0.0, // Default rating
        releaseDate: DateTime.now(), // Default to current date
        postCount: 0, // Default post count
        isFeatured: _isFeatured,
      );
      
      // Convert the game to JSON for API
      final gameData = {
        'id': game.id,
        'title': game.title,
        'name': game.name,
        'description': game.description,
        'imageUrl': game.imageUrl,
        'genre': game.genre,
        'genres': game.genres,
        'platforms': game.platforms,
        'developer': game.developer,
        'publisher': game.publisher,
        'rating': game.rating,
        'releaseDate': game.releaseDate.toIso8601String(),
        'postCount': game.postCount,
        'isFeatured': game.isFeatured,
      };
      
      // Call API to create the game
      await _apiService.createGame(gameData);
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Game created successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        
        // Navigate back
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to create game: ${e.toString()}';
      });
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage!),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: UIHelper.gamingAppBar(
        title: 'Add New Game',
        backgroundColor: AppConstants.gamingDarkPurple.withOpacity(0.85),
      ),
      body: Container(
        decoration: UIHelper.gamingGradientBackground(),
        child: Stack(
          children: [
            // Add subtle grid pattern background
            UIHelper.gridPatternOverlay(opacity: 0.05),
            
            // Main content
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.paddingL),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Game title
                      _buildSectionTitle('Game Title*'),
                      _buildTextField(
                        controller: _titleController,
                        hintText: 'Enter game title',
                        validator: ValidationHelper.validateRequired,
                      ),
                      
                      const SizedBox(height: AppConstants.paddingL),
                      
                      // Game description
                      _buildSectionTitle('Description*'),
                      _buildTextField(
                        controller: _descriptionController,
                        hintText: 'Enter game description',
                        maxLines: 4,
                        validator: ValidationHelper.validateRequired,
                      ),
                      
                      const SizedBox(height: AppConstants.paddingL),
                      
                      // Game image URL
                      _buildSectionTitle('Cover Image URL*'),
                      _buildTextField(
                        controller: _imageUrlController,
                        hintText: 'Enter cover image URL',
                        validator: ValidationHelper.validateUrl,
                      ),
                      
                      const SizedBox(height: AppConstants.paddingL),
                      
                      // Game genre
                      _buildSectionTitle('Genre*'),
                      _buildDropdown(
                        value: _selectedGenre,
                        items: _genreOptions,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedGenre = newValue;
                            });
                          }
                        },
                      ),
                      
                      const SizedBox(height: AppConstants.paddingL),
                      
                      // Game platforms
                      _buildSectionTitle('Platforms'),
                      _buildPlatformCheckboxes(),
                      
                      const SizedBox(height: AppConstants.paddingL),
                      
                      // Developer and Publisher
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle('Developer*'),
                                _buildTextField(
                                  controller: _developerController,
                                  hintText: 'Enter developer',
                                  validator: ValidationHelper.validateRequired,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppConstants.paddingM),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle('Publisher*'),
                                _buildTextField(
                                  controller: _publisherController,
                                  hintText: 'Enter publisher',
                                  validator: ValidationHelper.validateRequired,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: AppConstants.paddingL),
                      
                      // Featured game option
                      UIHelper.neonContainer(
                        padding: const EdgeInsets.all(AppConstants.paddingM),
                        borderRadius: AppConstants.borderRadiusM,
                        borderColor: AppConstants.primaryNeon.withOpacity(0.5),
                        glowIntensity: 0.3,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Featured Game',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Featured games appear on the home screen',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _isFeatured,
                              onChanged: (value) {
                                setState(() {
                                  _isFeatured = value;
                                });
                              },
                              activeColor: AppConstants.primaryNeon,
                              inactiveTrackColor: Colors.grey.shade800,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: AppConstants.paddingXL),
                      
                      // Submit button
                      Center(
                        child: _isLoading
                            ? UIHelper.gamingProgressIndicator()
                            : UIHelper.neonButton(
                                text: 'SAVE GAME',
                                onPressed: _submitForm,
                                width: 200,
                                height: 50,
                                textSize: 16,
                                textColor: Colors.white,
                                borderColor: AppConstants.accentNeon,
                                backgroundColor: AppConstants.gamingDarkPurple,
                              ),
                      ),
                      
                      if (_errorMessage != null) ...[
                        const SizedBox(height: AppConstants.paddingM),
                        Center(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: AppConstants.paddingXL),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return UIHelper.neonContainer(
      borderColor: AppConstants.primaryNeon.withOpacity(0.7),
      glowIntensity: 0.3,
      borderRadius: AppConstants.borderRadiusM,
      padding: EdgeInsets.zero,
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
          filled: true,
          fillColor: AppConstants.gamingDarkBlue.withOpacity(0.7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingM,
            vertical: AppConstants.paddingS,
          ),
        ),
        validator: validator,
      ),
    );
  }
  
  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required void Function(String?)? onChanged,
  }) {
    return UIHelper.neonContainer(
      borderColor: AppConstants.primaryNeon.withOpacity(0.7),
      glowIntensity: 0.3,
      borderRadius: AppConstants.borderRadiusM,
      padding: EdgeInsets.zero,
      child: DropdownButtonFormField<String>(
        value: value,
        dropdownColor: AppConstants.gamingDarkBlue,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppConstants.gamingDarkBlue.withOpacity(0.7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingM,
            vertical: AppConstants.paddingS,
          ),
        ),
        items: items.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
  
  Widget _buildPlatformCheckboxes() {
    return UIHelper.neonContainer(
      borderColor: AppConstants.primaryNeon.withOpacity(0.7),
      glowIntensity: 0.3,
      borderRadius: AppConstants.borderRadiusM,
      backgroundColor: AppConstants.gamingDarkBlue.withOpacity(0.7),
      padding: const EdgeInsets.all(AppConstants.paddingM),
      child: Wrap(
        spacing: AppConstants.paddingL,
        runSpacing: AppConstants.paddingS,
        children: _platformOptions.map((platform) {
          final isSelected = _selectedPlatforms.contains(platform);
          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedPlatforms.remove(platform);
                } else {
                  _selectedPlatforms.add(platform);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingS,
                vertical: AppConstants.paddingXS,
              ),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppConstants.primaryNeon.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusS),
                border: Border.all(
                  color: isSelected
                      ? AppConstants.primaryNeon
                      : Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSelected 
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: isSelected
                        ? AppConstants.primaryNeon
                        : Colors.white.withOpacity(0.5),
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    platform,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}