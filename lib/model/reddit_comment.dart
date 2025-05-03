import 'dart:convert';

class RedditComment {
  final String id;
  final String author;
  final String body;
  final int ups;
  final int downs;
  final DateTime createdUtc;
  final List<RedditComment> replies;
  final bool isSubmitter;
  final String parentId;
  final int depth;
  final String? authorFlairText;
  final String distinguished;

  RedditComment({
    required this.id,
    required this.author,
    required this.body,
    required this.ups,
    required this.downs,
    required this.createdUtc,
    required this.replies,
    required this.isSubmitter,
    required this.parentId,
    required this.depth,
    this.authorFlairText,
    required this.distinguished,
  });

  factory RedditComment.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    // Parse replies
    List<RedditComment> replies = [];
    if (data['replies'] != null &&
        data['replies'] != '' &&
        data['replies'] is Map) {
      final repliesData = data['replies']['data'];
      if (repliesData != null && repliesData['children'] != null) {
        for (var reply in repliesData['children']) {
          // Skip "more comments" type entries
          if (reply['kind'] == 't1') {
            replies.add(RedditComment.fromJson(reply));
          }
        }
      }
    }

    return RedditComment(
      id: data['id'] ?? '',
      author: data['author'] ?? '[deleted]',
      body: data['body'] ?? '',
      ups: data['ups'] ?? 0,
      downs: data['downs'] ?? 0,
      createdUtc: DateTime.fromMillisecondsSinceEpoch(
        ((data['created_utc'] ?? 0) * 1000).toInt(),
      ),
      replies: replies,
      isSubmitter: data['is_submitter'] ?? false,
      parentId: data['parent_id'] ?? '',
      depth: data['depth'] ?? 0,
      authorFlairText: data['author_flair_text'],
      distinguished: data['distinguished'] ?? '',
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
}
