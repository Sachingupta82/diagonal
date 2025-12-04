import 'package:diagonal/models/news_model.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/gemini_service.dart';

class ArticleDetailScreen extends StatefulWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  String? _aiDetails;
  bool _isLoading = false;
  bool _hasLoadedDetails = false;

  @override
  void initState() {
    super.initState();
    _loadAIDetails();
  }

  Future<void> _loadAIDetails() async {
    if (_hasLoadedDetails) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final details = await GeminiService.getArticleDetails(
        widget.article.headline,
        widget.article.url,
      );
      setState(() {
        _aiDetails = details;
        _hasLoadedDetails = true;
      });
    } catch (e) {
      setState(() {
        _aiDetails = 'Unable to load AI-generated details at this time.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _launchURL() async {
    final uri = Uri.parse(widget.article.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open URL')),
        );
      }
    }
  }

  String _getImageUrl() {
    // If article has image URL, use it
    if (widget.article.imageUrl != null && widget.article.imageUrl!.isNotEmpty) {
      return widget.article.imageUrl!;
    }
    
    // Otherwise use a placeholder based on category
    final text = widget.article.headline.toLowerCase();
    if (text.contains('ai') || text.contains('artificial intelligence')) {
      return 'https://images.unsplash.com/photo-1677442136019-21780ecad995?w=1200&auto=format&fit=crop&q=80';
    } else if (text.contains('government') || text.contains('politics')) {
      return 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=800';
    }
    else if (text.contains('space') || text.contains('nasa') || text.contains('rocket')) {
      return 'https://images.unsplash.com/photo-1446776653964-20c1d3a81b06?w=1200&auto=format&fit=crop&q=80';
    }
    else if (text.contains('bjp') || text.contains('congress')) {
      return 'https://media.assettype.com/deccanherald/2024-04/0748b54e-60a9-4b16-8b47-7a37537a2864/congress_bjp_file_phoot_969654_1617384003.jpg?w=1200&h=675&auto=format%2Ccompress&fit=max&enlarge=true';
    }
    else if (text.contains('climate') || text.contains('environment')) {
      return 'https://images.unsplash.com/photo-1569163139394-de4798aa62b6?w=1200&auto=format&fit=crop&q=80';
    } else if (text.contains('crypto') || text.contains('bitcoin')) {
      return 'https://images.unsplash.com/photo-1639762681485-074b7f938ba0?w=1200&auto=format&fit=crop&q=80';
    } else if (text.contains('election') || text.contains('politics')) {
      return 'https://images.unsplash.com/photo-1529107386315-e1a2ed48a620?w=1200&auto=format&fit=crop&q=80';
    } else if (text.contains('tech') || text.contains('technology')) {
      return 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=1200&auto=format&fit=crop&q=80';
    } else if (text.contains('cricket') || text.contains('ipl')) {
      return 'https://images.unsplash.com/photo-1531415074968-036ba1b575da?w=1200&auto=format&fit=crop&q=80';
    } else if (text.contains('football') || text.contains('soccer')) {
      return 'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?w=1200&auto=format&fit=crop&q=80';
    } else if (text.contains('stock') || text.contains('market')) {
      return 'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=1200&auto=format&fit=crop&q=80';
    } else if (text.contains('movie') || text.contains('film')) {
      return 'https://images.unsplash.com/photo-1485846234645-a62644f84728?w=1200&auto=format&fit=crop&q=80';
    } else if (text.contains('health') || text.contains('medical')) {
      return 'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?w=1200&auto=format&fit=crop&q=80';
    } else if (text.contains('business') || text.contains('economy')) {
      return 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=1200&auto=format&fit=crop&q=80';
    } else if (text.contains('sport')) {
      return 'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=1200&auto=format&fit=crop&q=80';
    } else if (text.contains('world') || text.contains('india')) {
      return 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=1200&auto=format&fit=crop&q=80';
    }else
    return 'https://images.unsplash.com/photo-1504711434969-e33886168f5c?w=1200&auto=format&fit=crop&q=80';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'article_${widget.article.rowId}',
                child: CachedNetworkImage(
                  imageUrl: _getImageUrl(),
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.article, size: 80, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A1E3D),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.article.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Headline
                  Text(
                    widget.article.headline,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A1E3D),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Date
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('MMM dd, yyyy').format(widget.article.date),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Open Source Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _launchURL,
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Read Full Article'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A1E3D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // AI-Generated Details Section
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0A1E3D).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.auto_awesome,
                                color: Color(0xFF0A1E3D),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'AI-Generated Insights',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0A1E3D),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_isLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (_aiDetails != null)
                          Text(
                            _aiDetails!,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.6,
                              color: Colors.black87,
                            ),
                          )
                        else
                          const Text(
                            'No details available',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}