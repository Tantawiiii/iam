import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../core/constant/app_colors.dart';

class ProductImageSlider extends StatefulWidget {
  final String? image;
  final String? linkVideo;
  final List<dynamic> gallery;

  const ProductImageSlider({
    super.key,
    this.image,
    this.linkVideo,
    required this.gallery,
  });

  @override
  State<ProductImageSlider> createState() => _ProductImageSliderState();
}

class _ProductImageSliderState extends State<ProductImageSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  YoutubePlayerController? _youtubeController;

  List<String> get _allImages {
    final List<String> images = [];

    if (widget.image != null && widget.image!.isNotEmpty) {
      images.add(widget.image!);
    }

    if (widget.gallery.isNotEmpty) {
      for (var item in widget.gallery) {
        if (item is String && item.isNotEmpty) {
          images.add(item);
        } else if (item is Map && item['url'] != null) {
          images.add(item['url'].toString());
        }
      }
    }
    return images;
  }

  String? _extractVideoId(String url) {
    final idLike = url.trim();
    final idReg = RegExp(r'^[a-zA-Z0-9_-]{11}$');
    if (idReg.hasMatch(idLike)) {
      return idLike;
    }

    final fromPlugin = YoutubePlayer.convertUrlToId(url);
    if (fromPlugin != null && idReg.hasMatch(fromPlugin)) {
      return fromPlugin;
    }

    try {
      final uri = Uri.parse(url.trim());
      final host = uri.host.toLowerCase();
      if (host.contains('youtu.be')) {
        final segs = uri.pathSegments;
        if (segs.isNotEmpty && idReg.hasMatch(segs.first)) {
          return segs.first;
        }
      }
      if (host.contains('youtube.com')) {
        final vParam = uri.queryParameters['v'];
        if (vParam != null && idReg.hasMatch(vParam)) {
          return vParam;
        }
        final segs = uri.pathSegments;
        if (segs.length >= 2) {
          final candidate = segs[1];
          if (idReg.hasMatch(candidate)) {
            return candidate;
          }
        }
      }
    } catch (_) {

    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    if (widget.linkVideo != null && widget.linkVideo!.isNotEmpty) {
      final videoId = _extractVideoId(widget.linkVideo!);
      if (videoId != null) {
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            enableCaption: true,
            controlsVisibleAtStart: false,
            useHybridComposition: true,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = _allImages;
    final hasVideo = _youtubeController != null;
    final totalItems = images.length + (hasVideo ? 1 : 0);

    if (totalItems == 0) {
      return Container(
        width: double.infinity,
        height: 300.h,
        color: AppColors.overlayColor,
        child: Icon(
          Icons.image_outlined,
          color: AppColors.greyTextColor,
          size: 60.sp,
        ),
      );
    }

    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 300.h,
          color: AppColors.overlayColor,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: totalItems,
            itemBuilder: (context, index) {
              if (hasVideo && index == images.length) {
                return _buildVideoItem();
              }
              if (index < images.length) {
                return _buildImageItem(images[index]);
              }
              return _buildPlaceholder();
            },
          ),
        ),
        if (totalItems > 1)
          Positioned(
            bottom: 16.h,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  totalItems,
                  (index) => Container(
                    width: 8.w,
                    height: 8.w,
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? AppColors.primaryColor
                          : Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVideoItem() {
    if (_youtubeController == null) {
      return _buildPlaceholder();
    }

    return Container(
      color: Colors.black,
      child: YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _youtubeController!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: AppColors.primaryColor,
        ),
        builder: (context, player) {
          return AspectRatio(aspectRatio: 16 / 9, child: player);
        },
      ),
    );
  }

  Widget _buildImageItem(String imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, url) => Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      ),
      errorWidget: (context, url, error) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.overlayColor,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: AppColors.greyTextColor,
          size: 60.sp,
        ),
      ),
    );
  }
}
