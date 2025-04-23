import 'package:flutter/material.dart';
import 'package:guide_genie/models/post.dart';
import 'package:guide_genie/utils/constants.dart';

class PostCard extends StatelessWidget {
  final Post post;
  
  const PostCard({
    Key? key,
    required this.post, required void Function() onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppConstants.postDetailsRoute,
          arguments: {'postId': post.id},
        );
      },
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
      child: Container(
        width: 280,
        margin: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingS,
          vertical: AppConstants.paddingS,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPostHeader(context),
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPostTitle(),
                  const SizedBox(height: AppConstants.paddingXS),
                  _buildPostMetadata(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostHeader(BuildContext context) {
    // Get the guide type name and icon
    final typeName = post.type.toString().split('.').last;
    final IconData typeIcon = AppConstants.guideTypeIcons[typeName] ?? Icons.article;
    
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingM,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(post.authorAvatarUrl),
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            onBackgroundImageError: (exception, stackTrace) {
              // Handle image loading error
            },
            child: post.authorAvatarUrl.isEmpty 
                ? Text(post.authorName[0], style: TextStyle(color: Theme.of(context).colorScheme.primary))
                : null,
          ),
          const SizedBox(width: AppConstants.paddingS),
          Expanded(
            child: Text(
              post.authorName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppConstants.fontSizeS,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingS,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusS),
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
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostTitle() {
    return Text(
      post.title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: AppConstants.fontSizeM,
        height: 1.3,
      ),
    );
  }

  Widget _buildPostMetadata(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Game name
        Expanded(
          child: Row(
            children: [
              const Icon(
                Icons.videogame_asset,
                size: AppConstants.iconSizeS,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  post.gameName,
                  style: const TextStyle(
                    fontSize: AppConstants.fontSizeS,
                    color: Colors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppConstants.paddingS),
        // Likes
        Row(
          children: [
            const Icon(
              Icons.thumb_up,
              size: AppConstants.iconSizeS,
              color: Colors.grey,
            ),
            const SizedBox(width: 2),
            Text(
              post.upvotes.toString(),
              style: const TextStyle(
                fontSize: AppConstants.fontSizeS,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(width: AppConstants.paddingS),
        // Comments
        Row(
          children: [
            const Icon(
              Icons.comment,
              size: AppConstants.iconSizeS,
              color: Colors.grey,
            ),
            const SizedBox(width: 2),
            Text(
              post.commentCount.toString(),
              style: const TextStyle(
                fontSize: AppConstants.fontSizeS,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}