import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../models/salon_profile.dart';

class HeroGallery extends StatelessWidget {
  const HeroGallery({super.key, required this.photos});

  final List<SalonPhotoRow> photos;

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return const AspectRatio(
        aspectRatio: 4 / 3,
        child: ColoredBox(color: Color(0x11000000)),
      );
    }
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: PageView(
        children: [
          for (final photo in photos)
            CachedNetworkImage(imageUrl: photo.photoUrl, fit: BoxFit.cover),
        ],
      ),
    );
  }
}
