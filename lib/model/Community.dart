class Community {
  final String id;
  final String name;
  final String title;
  final String? description;
  final String? publicDescription;
  final int memberCount;
  final int onlineCount;
  final DateTime createdAt;
  final String type;
  final bool isMature;
  final String createdBy;
  final List<String> topics;
  final bool over18;
  final String subredditType;

  final String? iconImg;
  final String? headerImg;
  final String? bannerImg;

  Community({
    required this.id,
    required this.name,
    required this.title,
    this.description,
    this.publicDescription,
    required this.memberCount,
    required this.onlineCount,
    required this.createdAt,
    required this.type,
    required this.isMature,
    required this.createdBy,
    required this.topics,
    required this.over18,
    required this.subredditType,
    this.iconImg,
    this.headerImg,
    this.bannerImg,
  });

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      id: json['id'] as String,
      name: json['name'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      publicDescription: json['public_description'] as String?,
      memberCount: json['memberCount'] as int? ?? 0,
      onlineCount: json['onlineCount'] as int? ?? 0,
      createdAt: json['createdAt'] is DateTime
          ? json['createdAt'] as DateTime
          : DateTime.fromMillisecondsSinceEpoch(
              ((json['created_utc'] ?? 0) * 1000).toInt(),
            ),
      type: json['type'] as String? ?? 'public',
      isMature: json['isMature'] as bool? ?? false,
      createdBy: json['createdBy'] as String? ?? '',
      topics: List<String>.from(json['topics'] ?? []),
      over18: json['over18'] as bool? ?? false,
      subredditType: json['subredditType'] as String? ?? 'public',
      iconImg: json['icon_img'] as String?,
      headerImg: json['header_img'] as String?,
      bannerImg: json['banner_img'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'description': description,
      'public_description': publicDescription,
      'memberCount': memberCount,
      'onlineCount': onlineCount,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'type': type,
      'isMature': isMature,
      'createdBy': createdBy,
      'topics': topics,
      'over18': over18,
      'subredditType': subredditType,
      'icon_img': iconImg,
      'header_img': headerImg,
      'banner_img': bannerImg,
    };
  }
}
