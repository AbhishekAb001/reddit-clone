
class RedditPost {
  final String subreddit;
  final String timeAgo;
  final String views;
  final String title;
  final String imageUrl;
  final int upvotes;
  final int comments;
  final int shares;

  RedditPost({
    required this.subreddit,
    required this.timeAgo,
    required this.views,
    required this.title,
    required this.imageUrl,
    required this.upvotes,
    required this.comments,
    required this.shares,
  });
}