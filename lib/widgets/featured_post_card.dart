import 'package:flutter/material.dart';
import 'package:guide_genie/models/post.dart';
import 'package:guide_genie/utils/constants.dart';

class FeaturedPostCard extends StatelessWidget {
  final Post post;
  
  const FeaturedPostCard({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the guide type name and icon
    final typeName = post.type.toString().split('.').last;
    final IconData typeIcon = AppConstants.guideTypeIcons[typeName] ?? Icons.article;
    
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppConstants.postDetailsRoute,
          arguments: {'postId': post.id},
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Featured label
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.paddingXS,
                horizontal: AppConstants.paddingM,
              ),
              color: Theme.of(context).colorScheme.primary,
              child: Text(
                'FEATURED GUIDE',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: AppConstants.fontSizeXS,
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: AppConstants.fontSizeL,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  // Author and guide type
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage(post.authorAvatarUrl),
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        onBackgroundImageError: (exception, stackTrace) {
                          // Handle image loading error
                        },
                        child: post.authorAvatarUrl.isEmpty 
                            ? Text(post.authorName[0], style: TextStyle(color: Theme.of(context).colorScheme.primary))
                            : null,
                      ),
                      const SizedBox(width: AppConstants.paddingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.authorName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: AppConstants.fontSizeS,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(
                                  Icons.videogame_asset,
                                  size: AppConstants.iconSizeS,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  post.gameName,
                                  style: const TextStyle(
                                    fontSize: AppConstants.fontSizeXS,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingS,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              typeIcon,
                              size: AppConstants.iconSizeS,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              AppConstants.guideTypeNames[typeName] ?? typeName,
                              style: TextStyle(
                                fontSize: AppConstants.fontSizeXS,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  // Content preview
                  Text(
                    post.content,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      fontSize: AppConstants.fontSizeS,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  // Stats
                  _buildPostStats(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostStats() {
    return Row(
      children: [
        // Views
        _buildStatItem(Icons.remove_red_eye, post.upvotes + post.downvotes, 'views'),
        const SizedBox(width: AppConstants.paddingM),
        // Upvotes
        _buildStatItem(Icons.thumb_up, post.upvotes, 'upvotes'),
        const SizedBox(width: AppConstants.paddingM),
        // Comments
        _buildStatItem(Icons.comment, post.commentCount, 'comments'),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, int count, String label) {
    return Row(
      children: [
        Icon(
          icon,
          size: AppConstants.iconSizeS,
          color: Colors.grey,
        ),
        const SizedBox(width: 4),
        Text(
          count.toString(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: AppConstants.fontSizeS,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: AppConstants.fontSizeXS,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}