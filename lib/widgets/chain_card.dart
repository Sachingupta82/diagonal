import 'package:diagonal/models/news_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChainCard extends StatelessWidget {
  final List<Article> articles;
  final VoidCallback onTap;

  const ChainCard({
    super.key,
    required this.articles,
    required this.onTap,
  });

  String _getImageUrl(Article article) {
    if (article.imageUrl != null && article.imageUrl!.isNotEmpty) {
      return article.imageUrl!;
    }
    
    final category = article.category.toLowerCase();
    final articleText = article.headline.toLowerCase();
    if (category.contains('tech') || category.contains('science') || articleText.contains('ai') || articleText.contains('artificial intelligence')) {
      return 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=800';
    }if (category.contains('ai') || category.contains('artificial intelligence') || category.contains('machine learning')) {
      return 'https://images.unsplash.com/photo-1677442136019-21780ecad995?w=1200&auto=format&fit=crop&q=80';
    } else if (category.contains('government') || category.contains('politics') || articleText.contains('government') || articleText.contains('politics')) {
      return 'https://www.lawnn.com/wp-content/uploads/2017/06/The-Central-Government-of-India-to-repeal-1824-obsolete-laws.jpg';
    }
    else if (category.contains('space') || category.contains('nasa') || category.contains('rocket')) {
      return 'https://images.unsplash.com/photo-1446776653964-20c1d3a81b06?w=1200&auto=format&fit=crop&q=80';
    }
    else if (category.contains('bjp') || category.contains('congress') || articleText.contains('bjp') || articleText.contains('congress')) {
      return 'https://media.assettype.com/deccanherald/2024-04/0748b54e-60a9-4b16-8b47-7a37537a2864/congress_bjp_file_phoot_969654_1617384003.jpg?w=1200&h=675&auto=format%2Ccompress&fit=max&enlarge=true';
    }
    else if (category.contains('climate') || category.contains('environment')) {
      return 'https://images.unsplash.com/photo-1569163139394-de4798aa62b6?w=1200&auto=format&fit=crop&q=80';
    } else if (category.contains('crypto') || category.contains('bitcoin')) {
      return 'https://images.unsplash.com/photo-1639762681485-074b7f938ba0?w=1200&auto=format&fit=crop&q=80';
    } 
    else if (category.contains('sport') || category.contains('cricket')) {
      return 'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=800';
    } else if (category.contains('business') || category.contains('market')) {
      return 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800';
    } else if (category.contains('health')) {
      return 'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?w=800';
    } else if (category.contains('world')) {
      return 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=800';
    }
    return 'https://images.unsplash.com/photo-1504711434969-e33886168f5c?w=800';
  }

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) return const SizedBox.shrink();

    // Sort by date (latest first for display)
    final sortedArticles = List<Article>.from(articles)
      ..sort((a, b) => b.date.compareTo(a.date));
    
    final latestArticle = sortedArticles.first;
    final oldestArticle = sortedArticles.last;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF0A1E3D).withOpacity(0.05),
                Colors.white,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with chain icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF0A1E3D),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.link,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'NEWS CHAIN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${articles.length} articles',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Latest article preview
              ClipRRect(
                child: CachedNetworkImage(
                  imageUrl: _getImageUrl(latestArticle),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    height: 180,
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    height: 180,
                    child: const Icon(Icons.article, size: 60),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Latest headline
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 4,
                          height: 16,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A1E3D),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            latestArticle.headline,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0A1E3D),
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Timeline info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.timeline,
                            size: 16,
                            color: Color(0xFF0A1E3D),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${DateFormat('MMM dd').format(oldestArticle.date)} - ${DateFormat('MMM dd, yyyy').format(latestArticle.date)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF0A1E3D),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // View chain button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'View chain',
                          style: TextStyle(
                            color: const Color(0xFF0A1E3D).withOpacity(0.7),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: const Color(0xFF0A1E3D).withOpacity(0.7),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}