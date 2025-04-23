import 'package:flutter/material.dart';
import 'package:guide_genie/models/game.dart';
import 'package:guide_genie/utils/constants.dart';

class GameCard extends StatelessWidget {
  final Game game;
  final bool isCompact;
  final Function()? onTap;
  
  const GameCard({
    Key? key,
    required this.game,
    this.isCompact = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {
        Navigator.pushNamed(
          context,
          AppConstants.gameDetailsRoute,
          arguments: {'gameId': game.id},
        );
      },
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
      child: Container(
        width: isCompact ? 130 : 280,
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
            _buildGameCover(context),
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGameName(),
                  const SizedBox(height: AppConstants.paddingXS),
                  _buildGameDetails(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCover(BuildContext context) {
    return Stack(
      children: [
        // Game Cover Image
        Container(
          height: 100,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          ),
          child: Image.network(
            game.coverImageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Icon(
                  Icons.image_not_supported,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                ),
              );
            },
          ),
        ),
        // Featured Badge
        if (game.isFeatured)
          Positioned(
            top: AppConstants.paddingS,
            right: AppConstants.paddingS,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingS,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusS),
              ),
              child: Text(
                'Featured',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontSize: AppConstants.fontSizeXS,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGameName() {
    return Text(
      game.name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: AppConstants.fontSizeM,
      ),
    );
  }

  Widget _buildGameDetails() {
    return Row(
      children: [
        // Rating
        const Icon(
          Icons.star,
          size: AppConstants.iconSizeS,
          color: Colors.amber,
        ),
        const SizedBox(width: 4),
        Text(
          game.rating.toString(),
          style: const TextStyle(
            fontSize: AppConstants.fontSizeS,
          ),
        ),
        const SizedBox(width: AppConstants.paddingM),
        // Guide Count
        const Icon(
          Icons.book,
          size: AppConstants.iconSizeS,
          color: Colors.grey,
        ),
        const SizedBox(width: 4),
        Text(
          '${game.postCount} guides',
          style: const TextStyle(
            fontSize: AppConstants.fontSizeS,
          ),
        ),
      ],
    );
  }
}