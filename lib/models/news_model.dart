class NewsModel{
  String? title;
  String? url;
  String? publishedTime;
  String? summary;
  String? thumbnail;
  String? slug;
  String? objectId;
  String? genreId;
  String? subtitle; // for cwc news
  String? imageCredit;
  String? newsId;
  String? publisher;
  String? publisherLogo;
  Map<String, dynamic>? matchMeta;
  NewsModel({this.url, this.title, this.thumbnail, this.subtitle, this.genreId, this.slug, this.objectId, this.matchMeta, this.publishedTime, this.summary, this.imageCredit, this.newsId, this.publisher, this.publisherLogo});
//   if match meta available, then {series-slug}-seriesObjectId-{slug}-objectId/match-report -> to construct url
// else, {slug}-objectId -> to construct url
}