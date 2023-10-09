class RedditModel{
  String? title;
  String? subreddit;
  String? fullText;
  double? createdAt;
  String? authorName;
  String? url;
  int? upVotes;
  double? upvoteRatio;
  String? thumbnail;
  bool? textVisible;
  String? searchSubtitles;
  String? videoUrl;
  bool? isVideo;
  RedditModel(
      {this.url,
        this.title,
        this.authorName,
        this.createdAt,
        this.fullText,
        this.subreddit,
        this.thumbnail,
        this.upvoteRatio,
        this.upVotes,
        this.textVisible,
        this.videoUrl,
        this.isVideo,
        this.searchSubtitles});
}