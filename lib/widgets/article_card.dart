import 'package:diagonal/models/news_model.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const ArticleCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  String _getImageUrl() {
    // Prefer article-provided image when available
    if (article.imageUrl != null && article.imageUrl!.isNotEmpty) {
      return article.imageUrl!;
    }

    // Try to pick an image based on headline keywords for better variety and relevance
    final text = '${article.headline}'.toLowerCase();
    
    // More diverse image selection based on content
    if (text.contains('ai') || text.contains('artificial intelligence') || text.contains('machine learning')) {
      return 'https://images.unsplash.com/photo-1677442136019-21780ecad995?w=1200&auto=format&fit=crop&q=80';
    }else if (text.contains('government') || text.contains('politics')) {
      return 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=800';
    } 
    else if (text.contains('space') || text.contains('nasa') || text.contains('rocket')) {
      return 'https://images.unsplash.com/photo-1446776653964-20c1d3a81b06?w=1200&auto=format&fit=crop&q=80';
    } else if (text.contains('climate') || text.contains('environment') || text.contains('green')) {
      return 'https://images.unsplash.com/photo-1569163139394-de4798aa62b6?w=1200&auto=format&fit=crop&q=80';
    } else if (text.contains('bjp') || text.contains('congress')) {
      return 'https://media.assettype.com/deccanherald/2024-04/0748b54e-60a9-4b16-8b47-7a37537a2864/congress_bjp_file_phoot_969654_1617384003.jpg?w=1200&h=675&auto=format%2Ccompress&fit=max&enlarge=true';
    }
    else if (text.contains('crypto') || text.contains('bitcoin') || text.contains('blockchain')) {
      return 'https://images.unsplash.com/photo-1639762681485-074b7f938ba0?w=1200&auto=format&fit=crop&q=80';
    } else if (text.contains('election') || text.contains('politics') || text.contains('government')) {
      return 'https://images.unsplash.com/photo-1529107386315-e1a2ed48a620?w=1200&auto=format&fit=crop&q=80';
    } else if (text.contains('tech') || text.contains('technology') || text.contains('google') || text.contains('apple')) {
      return 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=1200&auto=format&fit=crop&q=80';
    } else if (text.contains('cricket') || text.contains('ipl') || text.contains('test match')) {
      return 'https://images.unsplash.com/photo-1531415074968-036ba1b575da?w=1200&auto=format&fit=crop&q=80';
    } else if (text.contains('football') || text.contains('soccer') || text.contains('fifa')) {
      return 'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?w=1200&auto=format&fit=crop&q=80';
    } else if (text.contains('stock') || text.contains('market') || text.contains('trading')) {
      return 'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=1200&auto=format&fit=crop&q=80';
    } else if (text.contains('movie') || text.contains('film') || text.contains('cinema')) {
      return 'https://images.unsplash.com/photo-1485846234645-a62644f84728?w=1200&auto=format&fit=crop&q=80';
    } else if (text.contains('health') || text.contains('medical') || text.contains('hospital')) {
      return 'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?w=1200&auto=format&fit=crop&q=80';
    } else if (text.contains('business') || text.contains('economy')) {
      return 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=1200&auto=format&fit=crop&q=80';
    }else
    return 'https://images.unsplash.com/photo-1504711434969-e33886168f5c?w=1200&auto=format&fit=crop&q=80';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Hero(
              tag: 'article_${article.rowId}',
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: CachedNetworkImage(
                  imageUrl: _getImageUrl(),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    height: 200,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    height: 200,
                    child: const Center(
                      child: Icon(
                        Icons.article,
                        size: 60,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category and date row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A1E3D),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          article.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('MMM dd').format(article.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Headline
                  Text(
                    article.headline,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A1E3D),
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Read more
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Read more',
                        style: TextStyle(
                          color: const Color(0xFF0A1E3D).withOpacity(0.7),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
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
    );
  }
}