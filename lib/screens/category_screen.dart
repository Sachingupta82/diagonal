import 'package:diagonal/models/news_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../services/api_service.dart';
import '../widgets/article_card.dart';
import '../widgets/chain_card.dart';
import 'article_detail_screen.dart';
import 'chain_detail_screen.dart';

class CategoryScreen extends StatefulWidget {
  final String category;

  const CategoryScreen({super.key, required this.category});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _feedItems = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadFeed();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        _loadMoreFeed();
      }
    }
  }

  Future<void> _loadFeed() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.fetchCategoryFeed(widget.category, page: 1);
      setState(() {
        _feedItems.clear();
        for (var sequence in response.sequences) {
          _feedItems.add(sequence);
        }
        _feedItems.addAll(response.articles);
        _currentPage = 1;
        _hasMore = true;
      });
    } catch (e) {
      _showError('Failed to load news feed');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreFeed() async {
    if (_isLoading || !_hasMore) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      _currentPage++;
      final response = await ApiService.fetchCategoryFeed(
        widget.category,
        page: _currentPage,
      );
      
      setState(() {
        for (var sequence in response.sequences) {
          _feedItems.add(sequence);
        }
        _feedItems.addAll(response.articles);
        _hasMore = response.articles.isNotEmpty;
      });
    } catch (e) {
      _currentPage--;
      _showError('Failed to load more news');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
      ),
      body: _isLoading && _feedItems.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadFeed,
              child: AnimationLimiter(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _feedItems.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= _feedItems.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final item = _feedItems[index];

                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: _buildFeedItem(item),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }

  Widget _buildFeedItem(dynamic item) {
    if (item is List<Article>) {
      return ChainCard(
        articles: item,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChainDetailScreen(articles: item),
            ),
          );
        },
      );
    } else if (item is Article) {
      return ArticleCard(
        article: item,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArticleDetailScreen(article: item),
            ),
          );
        },
      );
    }
    return const SizedBox.shrink();
  }
}