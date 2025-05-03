class RedditPost {
  final String id;
  final String title;
  final String subreddit;
  final String author;
  final int ups;
  final int numComments;
  final String thumbnail;
  final DateTime createdUtc;
  final String selfText;
  final bool isSelf;
  final String url;
  final bool isVideo;
  final bool isGallery;
  final String? mediaUrl;
  final List<String>? galleryUrls;
  final String? previewUrl;
  final int? views;
  final int? shares;

  RedditPost({
    required this.id,
    required this.title,
    required this.subreddit,
    required this.author,
    required this.ups,
    required this.numComments,
    required this.thumbnail,
    required this.createdUtc,
    required this.selfText,
    required this.isSelf,
    required this.url,
    required this.isVideo,
    required this.isGallery,
    this.mediaUrl,
    this.galleryUrls,
    this.previewUrl,
    this.views,
    this.shares,
  });

  factory RedditPost.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    // Handle gallery posts
    List<String>? galleryUrls;
    if (data['is_gallery'] == true && data['gallery_data'] != null) {
      final mediaMetadata = data['media_metadata'] as Map<String, dynamic>?;
      if (mediaMetadata != null) {
        galleryUrls = mediaMetadata.values
            .map((item) => item['s']?['u'] as String?)
            .where((url) => url != null)
            .cast<String>()
            .toList();
      }
    }

    // Handle preview images
    String? previewUrl;
    if (data['preview']?['images'] != null &&
        data['preview']['images'].isNotEmpty) {
      previewUrl = data['preview']['images'][0]['source']['url']
          ?.replaceAll(RegExp(r'&amp;'), '&');
    }

    return RedditPost(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      subreddit: data['subreddit'] ?? '',
      author: data['author'] ?? '[deleted]',
      ups: data['ups'] ?? 0,
      numComments: data['num_comments'] ?? 0,
      thumbnail: data['thumbnail'] ?? '',
      createdUtc: DateTime.fromMillisecondsSinceEpoch(
        ((data['created_utc'] ?? 0) * 1000).toInt(),
      ),
      selfText: data['selftext'] ?? '',
      isSelf: data['is_self'] ?? false,
      url: data['url'] ?? '',
      isVideo: data['is_video'] ?? false,
      isGallery: data['is_gallery'] ?? false,
      mediaUrl: data['media']?['reddit_video']?['fallback_url'],
      galleryUrls: galleryUrls,
      previewUrl: previewUrl,
      views: data['view_count']?.toInt(),
      shares: data['share_count']?.toInt(),
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdUtc);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  String get viewCount {
    if (views == null) return '';
    if (views! >= 1000000) {
      return '${(views! / 1000000).toStringAsFixed(1)}M views';
    } else if (views! >= 1000) {
      return '${(views! / 1000).toStringAsFixed(1)}K views';
    }
    return '$views views';
  }
}
