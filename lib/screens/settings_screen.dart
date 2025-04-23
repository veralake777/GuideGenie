import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:guide_genie/services/database_service.dart';
import 'package:guide_genie/utils/constants.dart';
import 'package:guide_genie/utils/ui_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _useMockData = false;
  bool _enableDarkMode = true;
  bool _enableNotifications = true;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  void _loadSettings() {
    // Load settings from environment or shared preferences
    setState(() {
      _useMockData = dotenv.env['USE_MOCK_DATA'] == 'true' || 
                    dotenv.env['DATA_SOURCE']?.toLowerCase() == 'mock';
      _enableDarkMode = true; // Always dark mode for now
      _enableNotifications = true; // Default value
    });
  }
  
  void _toggleMockData(bool value) {
    setState(() {
      _useMockData = value;
      
      // Set mock data mode on the DatabaseService
      DatabaseService().setMockDataMode(value);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Switched to ${value ? 'MOCK' : 'LIVE'} data mode'),
          duration: const Duration(seconds: 2),
          backgroundColor: AppConstants.gamingDarkPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusS),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: Container(
        decoration: UIHelper.gamingGradientBackground(),
        child: Stack(
          children: [
            // Grid pattern overlay
            UIHelper.gridPatternOverlay(opacity: 0.05),
            
            // Main content
            ListView(
              padding: const EdgeInsets.all(AppConstants.paddingL),
              children: [
                // Data Source Section
                _buildSettingsSection(
                  title: 'Data Source',
                  icon: Icons.storage,
                  children: [
                    _buildToggleSetting(
                      title: 'Use Mock Data',
                      subtitle: 'Use offline sample data instead of live database',
                      value: _useMockData,
                      onChanged: _toggleMockData,
                    ),
                    const SizedBox(height: AppConstants.paddingS),
                    Text(
                      'When enabled, the app will use sample data rather than connecting to the online database. Useful for development and testing.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppConstants.paddingL),
                
                // Appearance Section
                _buildSettingsSection(
                  title: 'Appearance',
                  icon: Icons.palette,
                  children: [
                    _buildToggleSetting(
                      title: 'Dark Mode',
                      subtitle: 'Use dark theme throughout the app',
                      value: _enableDarkMode,
                      onChanged: (value) {
                        setState(() {
                          _enableDarkMode = value;
                        });
                        // Dark mode is always enabled in this version
                        if (!value) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Light mode is not available in this version'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          setState(() {
                            _enableDarkMode = true;
                          });
                        }
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: AppConstants.paddingL),
                
                // Notifications Section
                _buildSettingsSection(
                  title: 'Notifications',
                  icon: Icons.notifications,
                  children: [
                    _buildToggleSetting(
                      title: 'Enable Notifications',
                      subtitle: 'Receive updates on new guides and content',
                      value: _enableNotifications,
                      onChanged: (value) {
                        setState(() {
                          _enableNotifications = value;
                        });
                        // Notification setting is just for display in this version
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Notifications ${value ? 'enabled' : 'disabled'}'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: AppConstants.paddingL),
                
                // About Section
                _buildSettingsSection(
                  title: 'About',
                  icon: Icons.info_outline,
                  children: [
                    ListTile(
                      title: const Text(
                        'App Version',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        'v${AppConstants.appVersion}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.help_outline,
                          color: AppConstants.primaryNeon,
                        ),
                        onPressed: () {
                          showAboutDialog(
                            context: context,
                            applicationName: AppConstants.appName,
                            applicationVersion: 'v${AppConstants.appVersion}',
                            applicationIcon: const Icon(
                              Icons.videogame_asset,
                              color: AppConstants.primaryNeon,
                              size: 40,
                            ),
                            children: [
                              Text(
                                'GuideGenie is your ultimate companion for game strategies, guides, and community insights.',
                                style: TextStyle(color: Colors.grey[300]),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
        border: Border.all(
          color: AppConstants.primaryNeon.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            decoration: BoxDecoration(
              color: AppConstants.gamingDarkBlue.withOpacity(0.5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppConstants.borderRadiusM),
                topRight: Radius.circular(AppConstants.borderRadiusM),
              ),
              border: Border(
                bottom: BorderSide(
                  color: AppConstants.primaryNeon.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AppConstants.primaryNeon,
                  size: 20,
                ),
                const SizedBox(width: AppConstants.paddingM),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Section content
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildToggleSetting({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppConstants.primaryNeon,
          activeTrackColor: AppConstants.primaryNeon.withOpacity(0.3),
        ),
      ],
    );
  }
}