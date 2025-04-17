import 'package:flutter/material.dart';
import 'package:guide_genie/models/guide_post.dart';
import 'package:guide_genie/services/api_service_new.dart';
import 'package:guide_genie/utils/constants.dart';
import 'package:guide_genie/utils/ui_helper.dart';
import 'package:guide_genie/widgets/guide_card.dart';
import 'package:guide_genie/widgets/loading_indicator.dart';

class AllGuidesScreen extends StatefulWidget {
  const AllGuidesScreen({Key? key}) : super(key: key);

  @override
  _AllGuidesScreenState createState() => _AllGuidesScreenState();
}

class _AllGuidesScreenState extends State<AllGuidesScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<GuidePost> _guides = [];
  String _selectedFilter = 'Latest';
  String _selectedType = 'All';
  
  final List<String> _filters = [
    'Latest',
    'Popular',
    'Featured',
  ];
  
  final List<String> _types = [
    'All',
    'Strategy',
    'Tier List',
    'Loadout',
    'Meta Analysis',
    'Beginner Tips',
    'Advanced Tips',
    'Guide',
  ];

  @override
  void initState() {
    super.initState();
    _loadGuides();
  }

  Future<void> _loadGuides() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Map<String, dynamic>> guideList;
      
      // Get appropriate guides based on filter
      if (_selectedFilter == 'Latest') {
        guideList = await _apiService.getLatestPosts();
      } else if (_selectedFilter == 'Popular') {
        // Assuming most upvoted are most popular
        guideList = await _apiService.getPosts();
        guideList.sort((a, b) => (b['upvotes'] as int).compareTo(a['upvotes'] as int));
      } else if (_selectedFilter == 'Featured') {
        guideList = await _apiService.getFeaturedPosts();
      } else {
        guideList = await _apiService.getPosts();
      }
      
      setState(() {
        _guides = guideList.map((json) => GuidePost.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading guides: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load guides: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<GuidePost> _getFilteredGuides() {
    if (_selectedType == 'All') {
      return _guides;
    } else {
      return _guides.where((guide) => 
        guide.type.toLowerCase() == _selectedType.toLowerCase()).toList();
    }
  }

  void _applyFilters(String filter, String type) {
    setState(() {
      bool shouldReload = _selectedFilter != filter;
      _selectedFilter = filter;
      _selectedType = type;
      
      if (shouldReload) {
        _loadGuides();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Guides'),
        elevation: 0,
      ),
      body: Container(
        decoration: UIHelper.gamingGradientBackground(),
        child: Stack(
          children: [
            // Add grid pattern overlay
            UIHelper.gridPatternOverlay(opacity: 0.05),
            
            Column(
              children: [
                // Filter row
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // First row: Latest, Popular, Featured
                        ...List.generate(_filters.length, (index) {
                          final filter = _filters[index];
                          final isSelected = filter == _selectedFilter;
                          
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              selected: isSelected,
                              label: Text(filter),
                              onSelected: (selected) {
                                _applyFilters(filter, _selectedType);
                              },
                              backgroundColor: Colors.grey[800],
                              selectedColor: AppConstants.primaryNeon.withOpacity(0.2),
                              checkmarkColor: AppConstants.primaryNeon,
                              labelStyle: TextStyle(
                                color: isSelected ? AppConstants.primaryNeon : Colors.white,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected ? AppConstants.primaryNeon : Colors.transparent,
                                  width: 1,
                                ),
                              ),
                              elevation: 0,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                
                // Type filter
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _types.length,
                      itemBuilder: (context, index) {
                        final type = _types[index];
                        final isSelected = type == _selectedType;
                        
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            selected: isSelected,
                            label: Text(type),
                            onSelected: (selected) {
                              setState(() {
                                _selectedType = type;
                              });
                            },
                            backgroundColor: Colors.grey[800],
                            selectedColor: AppConstants.secondaryNeon.withOpacity(0.2),
                            checkmarkColor: AppConstants.secondaryNeon,
                            labelStyle: TextStyle(
                              color: isSelected ? AppConstants.secondaryNeon : Colors.white,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected ? AppConstants.secondaryNeon : Colors.transparent,
                                width: 1,
                              ),
                            ),
                            elevation: 0,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                // Guide list
                Expanded(
                  child: _isLoading
                      ? const Center(child: LoadingIndicator())
                      : _guides.isEmpty
                          ? Center(
                              child: Text(
                                'No guides found',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 16),
                              itemCount: _getFilteredGuides().length,
                              itemBuilder: (context, index) {
                                final guide = _getFilteredGuides()[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: GuideCard(
                                    guide: guide,
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppConstants.postDetailsRoute,
                                        arguments: {'postId': guide.id},
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create guide screen or show dialog if not logged in
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Create Guide feature coming in next update!'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        backgroundColor: AppConstants.primaryNeon,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}