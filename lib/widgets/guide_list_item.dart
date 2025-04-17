import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/guide_post.dart';
import '../utils/constants.dart';

class GuideListItem extends StatelessWidget {
  final GuidePost guide;
  final bool showGameInfo;
  final VoidCallback onTap;
  final bool isBookmarked;
  final VoidCallback? onBookmarkToggle;

  const GuideListItem({
    Key? key,
    required this.guide,
    this.showGameInfo = false,
    required this.onTap,
    this.isBookmarked = false,
    this.onBookmarkToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timeAgo = timeago.format(guide.createdAt);
    final guideType = AppConstants.guideTypeNames[guide.type] ?? guide.type;
    final guideTypeIcon = AppConstants.guideTypeIcons[guide.type] ?? Icons.article;
    
    return Card(
      elevation: 8,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
        side: BorderSide(
          color: AppConstants.primaryNeon.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        splashColor: AppConstants.primaryNeon.withOpacity(0.1),
        highlightColor: AppConstants.primaryNeon.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Guide type & bookmarks row
              Row(
                children: [
                  // Guide type chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingS,
                      vertical: AppConstants.paddingXXS,
                    ),
                    decoration: BoxDecoration(
                      color: AppConstants.gamingDarkPurple.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusS),
                      border: Border.all(
                        color: AppConstants.secondaryNeon.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          guideTypeIcon,
                          size: 14,
                          color: AppConstants.secondaryNeon,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          guideType,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Bookmark button
                  if (onBookmarkToggle != null)
                    IconButton(
                      icon: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: isBookmarked 
                            ? AppConstants.accentNeon
                            : Colors.white.withOpacity(0.7),
                      ),
                      onPressed: onBookmarkToggle,
                      visualDensity: VisualDensity.compact,
                      tooltip: isBookmarked ? 'Remove from bookmarks' : 'Add to bookmarks',
                    ),
                ],
              ),
              
              const SizedBox(height: AppConstants.paddingS),
              
              // Title
              Text(
                guide.title,
                style: const TextStyle(
                  fontSize: AppConstants.fontSizeL,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: AppConstants.paddingS),
              
              // Game info (if enabled)
              if (showGameInfo) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.sports_esports,
                      size: 14,
                      color: AppConstants.primaryNeon,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        guide.gameName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingS),
              ],
              
              // Footer with author info and stats
              Row(
                children: [
                  // Author avatar
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppConstants.gamingDarkPurple,
                    backgroundImage: guide.authorAvatarUrl.isNotEmpty
                        ? NetworkImage(guide.authorAvatarUrl) as ImageProvider
                        : null,
                    child: guide.authorAvatarUrl.isEmpty
                        ? Text(
                            guide.authorName.isNotEmpty
                                ? guide.authorName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: AppConstants.primaryNeon,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  
                  // Author name & post time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          guide.authorName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          timeAgo,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Likes
                  Row(
                    children: [
                      Icon(
                        Icons.thumb_up,
                        size: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${guide.likes}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(width: AppConstants.paddingM),
                  
                  // Comments
                  Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${guide.commentCount}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}