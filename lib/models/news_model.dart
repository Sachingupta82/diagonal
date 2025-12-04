class Article {
  final String rowId;
  final DateTime date;
  final String category;
  final String headline;
  final String url;
  final String? imageUrl;
  final int isChainMember;
  final int? chainId;
  final int? storyIndex;
  final int chainLength;
  final String clusterSize;
  final double? score;

  Article({
    required this.rowId,
    required this.date,
    required this.category,
    required this.headline,
    required this.url,
    this.imageUrl,
    required this.isChainMember,
    this.chainId,
    this.storyIndex,
    required this.chainLength,
    required this.clusterSize,
    this.score,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      rowId: json['row_id'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      category: json['category'] ?? '',
      headline: json['headline'] ?? '',
      url: json['url'] ?? '',
      imageUrl: json['image_url'],
      isChainMember: json['is_chain_member'] ?? 0,
      chainId: json['chain_id'],
      storyIndex: json['story_index'],
      chainLength: json['chain_length'] ?? 0,
      clusterSize: json['cluster_size']?.toString() ?? '0',
      score: json['score']?.toDouble(),
    );
  }
}

class NewsChain {
  final int chainId;
  final int clusterId;
  final int length;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime latestArticleDate;
  final List<Article> articles;

  NewsChain({
    required this.chainId,
    required this.clusterId,
    required this.length,
    required this.startDate,
    required this.endDate,
    required this.latestArticleDate,
    required this.articles,
  });

  factory NewsChain.fromJson(Map<String, dynamic> json) {
    return NewsChain(
      chainId: json['chain_id'] ?? 0,
      clusterId: json['cluster_id'] ?? 0,
      length: json['length'] ?? 0,
      startDate: DateTime.parse(json['start_date'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['end_date'] ?? DateTime.now().toIso8601String()),
      latestArticleDate: DateTime.parse(json['latest_article_date'] ?? DateTime.now().toIso8601String()),
      articles: (json['articles'] as List?)
          ?.map((article) => Article.fromJson(article))
          .toList() ?? [],
    );
  }
}

class FeedResponse {
  final int page;
  final int limit;
  final List<List<Article>> sequences;
  final List<Article> articles;
  final List<int> featuredChains;

  FeedResponse({
    required this.page,
    required this.limit,
    required this.sequences,
    required this.articles,
    required this.featuredChains,
  });

  factory FeedResponse.fromJson(Map<String, dynamic> json) {
    return FeedResponse(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      sequences: (json['sequences'] as List?)
          ?.map((sequence) => (sequence as List)
              .map((article) => Article.fromJson(article))
              .toList())
          .toList() ?? [],
      articles: (json['articles'] as List?)
          ?.map((article) => Article.fromJson(article))
          .toList() ?? [],
      featuredChains: (json['featured_chains'] as List?)
          ?.map((id) => id as int)
          .toList() ?? [],
    );
  }
}

class ActiveChainsResponse {
  final int page;
  final int limit;
  final List<NewsChain> items;

  ActiveChainsResponse({
    required this.page,
    required this.limit,
    required this.items,
  });

  factory ActiveChainsResponse.fromJson(Map<String, dynamic> json) {
    return ActiveChainsResponse(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 50,
      items: (json['items'] as List?)
          ?.map((item) => NewsChain.fromJson(item))
          .toList() ?? [],
    );
  }
}

class SearchResponse {
  final List<Article> articles;
  final List<NewsChain> chains;

  SearchResponse({
    required this.articles,
    required this.chains,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    return SearchResponse(
      articles: (json['articles'] as List?)
          ?.map((article) => Article.fromJson(article))
          .toList() ?? [],
      chains: (json['chains'] as List?)
          ?.map((chain) => NewsChain.fromJson(chain))
          .toList() ?? [],
    );
  }
}

class Category {
  final String category;
  final String count;

  Category({
    required this.category,
    required this.count,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      category: json['category'] ?? '',
      count: json['cnt'] ?? '0',
    );
  }
}