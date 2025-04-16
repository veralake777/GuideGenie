import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/guide_post.dart';
import '../screens/post_details_screen.dart';
import '../utils/constants.dart';
import '../utils/ui_helper.dart';

class PopularGuideCard extends StatelessWidget {
  final GuidePost guide;
  
  const PopularGuideCard({
    Key? key,
    required this.guide,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailsScreen(postId: guide.id),
          ),
        );
      },
      child: UIHelper.gamingCard(
        cardColor: AppConstants.gamingDarkBlue.withOpacity(0.7),
        borderColor: AppConstants.primaryNeon.withOpacity(0.7),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostDetailsScreen(postId: guide.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Guide type & date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Type pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryNeon.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusXL),
                    border: Border.all(
                      color: AppConstants.primaryNeon.withOpacity(0.5),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppConstants.primaryNeon.withOpacity(0.2),
                        blurRadius: 4,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Text(
                    _formatGuideType(guide.type),
                    style: TextStyle(
                      color: AppConstants.primaryNeon,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                
                // Date with icon
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      timeago.format(guide.createdAt),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Guide title with neon effect
            Text(
              guide.title,
              style: UIHelper.neonTextStyle(
                color: Colors.white,
                fontSize: 16,
                letterSpacing: 0.5,
                addShadow: true,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 8),
            
            // Guide description
            Text(
              _getGuideDescription(guide),
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 12),
            
            // Divider
            Divider(
              color: AppConstants.primaryNeon.withOpacity(0.2),
              thickness: 1,
              height: 1,
            ),
            
            const SizedBox(height: 12),
            
            // Guide stats
            Row(
              children: [
                // Author with glowing avatar
                _buildAuthorAvatar(),
                const SizedBox(width: 8),
                Text(
                  guide.authorName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                
                const Spacer(),
                
                // Game tag pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppConstants.gamingDarkPurple.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
                    border: Border.all(
                      color: AppConstants.secondaryNeon.withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.sports_esports,
                        size: 12,
                        color: AppConstants.secondaryNeon.withOpacity(0.8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        guide.gameName,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Stats container
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppConstants.gamingDarkPurple.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusS),
                  ),
                  child: Row(
                    children: [
                      // Likes
                      Icon(
                        Icons.thumb_up_outlined,
                        size: 14,
                        color: AppConstants.accentNeon.withOpacity(0.8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatNumber(guide.likes),
                        style: TextStyle(
                          color: AppConstants.accentNeon.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      // Comments
                      Icon(
                        Icons.comment_outlined,
                        size: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        guide.commentCount.toString(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // Format guide type to be more user-friendly
  String _formatGuideType(String type) {
    if (type == 'tierList') return 'Tier List';
    if (type == 'metaAnalysis') return 'Meta Analysis';
    if (type == 'beginnerTips') return 'Beginner Tips';
    if (type == 'advancedTips') return 'Advanced Tips';
    
    // Capitalize first letter
    return type.isNotEmpty 
        ? type[0].toUpperCase() + type.substring(1)
        : 'Guide';
  }
  
  // Extract a description from the content if none exists
  String _getGuideDescription(GuidePost guide) {
    if (guide.content.isEmpty) {
      return 'No description available';
    }
    
    // If content is markdown, try to extract first paragraph
    final content = guide.content;
    if (content.startsWith('#')) {
      // Find the first paragraph after headers
      final paragraphMatch = RegExp(r'^\s*([^#\n].+)$', multiLine: true).firstMatch(content);
      if (paragraphMatch != null) {
        return paragraphMatch.group(1) ?? 'No description available';
      }
    }
    
    // Return first 100 chars
    return content.length > 100 
        ? content.substring(0, 100) + '...'
        : content;
  }
  
  // Format large numbers with K suffix (e.g. 1.2K)
  String _formatNumber(int number) {
    if (number >= 1000) {
      double num = number / 1000;
      return '${num.toStringAsFixed(1)}K';
    }
    return number.toString();
  }
  
  // Build author avatar with glow effect
  Widget _buildAuthorAvatar() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppConstants.secondaryNeon.withOpacity(0.4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 14,
        backgroundColor: AppConstants.secondaryNeon.withOpacity(0.8),
        backgroundImage: guide.authorAvatarUrl.isNotEmpty 
            ? NetworkImage(guide.authorAvatarUrl) 
            : null,
        child: guide.authorAvatarUrl.isEmpty
            ? Text(
                guide.authorName.isNotEmpty ? guide.authorName[0].toUpperCase() : '?',
                style: TextStyle(
                  color: AppConstants.gamingDarkPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              )
            : null,
      ),
    );
  }
}