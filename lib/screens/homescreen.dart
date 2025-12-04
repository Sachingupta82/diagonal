import 'dart:async';

import 'package:diagonal/services/ads_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/news_model.dart';
import '../services/api_service.dart';
import '../widgets/article_card.dart';
import '../widgets/chain_card.dart';
import '../widgets/category_sheet.dart';
import '../widgets/search_bar_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'article_detail_screen.dart';
import 'chain_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final PageController _featuredController = PageController(viewportFraction: 0.85);
  late AnimationController _fabAnimationController;
  List<dynamic> _feedItems = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  bool _isLoadingChains = false;
  int _currentIndex = 0;
  int _featuredIndex = 0;
  bool _showFab = false;
  Timer? _interstitialTimer;

  void _startInterstitialTimer() {
    _interstitialTimer?.cancel();
    _interstitialTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      AdService.instance.showInterstitialAd(
        onAdClosed: () {
          debugPrint('Interstitial ad closed on HomeScreen');
        },
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _startInterstitialTimer(); // Start the 2-minute timer
    _loadFeed();
    _scrollController.addListener(_onScroll);
    _featuredController.addListener(_onFeaturedScroll);
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _interstitialTimer?.cancel();
    _scrollController.dispose();
    _featuredController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _onFeaturedScroll() {
    if (_featuredController.page != null) {
      setState(() {
        _featuredIndex = _featuredController.page!.round();
      });
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    
    if (_scrollController.offset > 200 && !_showFab) {
      setState(() => _showFab = true);
      _fabAnimationController.forward();
    } else if (_scrollController.offset <= 200 && _showFab) {
      setState(() => _showFab = false);
      _fabAnimationController.reverse();
    }

    final max = _scrollController.position.maxScrollExtent;
    final current = _scrollController.position.pixels;
    if (max - current < 300) {
      if (!_isLoading && _hasMore) {
        if (_currentIndex == 0) {
          _loadMoreFeed();
        } else {
          _loadMoreChains();
        }
      }
    }
  }

  Future<void> _loadFeed() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.fetchFeed(page: 1);
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
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMoreFeed() async {
    if (_isLoading || !_hasMore) return;
    
    setState(() => _isLoading = true);

    try {
      _currentPage++;
      final response = await ApiService.fetchFeed(page: _currentPage);
      
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
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMoreChains() async {
    if (_isLoadingChains || !_hasMore) return;
    
    setState(() => _isLoadingChains = true);

    try {
      _currentPage++;
      final response = await ApiService.fetchActiveChains(page: _currentPage);
      
      setState(() {
        _feedItems.addAll(response.items);
        _hasMore = response.items.isNotEmpty;
      });
    } catch (e) {
      _currentPage--;
      _showError('Failed to load more chains');
    } finally {
      setState(() => _isLoadingChains = false);
    }
  }

  Future<void> _loadChains() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.fetchActiveChains(page: 1);
      setState(() {
        _feedItems.clear();
        _feedItems.addAll(response.items);
        _currentPage = 1;
        _hasMore = true;
      });
    } catch (e) {
      _showError('Failed to load chains');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showCategorySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CategorySheet(),
    );
  }

  // Navigate with interstitial ad
  void _navigateToArticle(Article article) {
    AdService.instance.showInterstitialAd(
      onAdClosed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailScreen(article: article),
          ),
        );
      },
    );
  }

  void _navigateToChain(List<Article> articles) {
    AdService.instance.showInterstitialAd(
      onAdClosed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChainDetailScreen(articles: articles),
          ),
        );
      },
    );
  }

  String _getDynamicImageForArticle(Article article) {
    final text = '${article.category} ${article.headline}'.toLowerCase();
    
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
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 80,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF0A1E3D),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Diagonal',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  letterSpacing: -0.5,
                  color: Color.fromARGB(255, 200, 198, 198)
                ),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF0A1E3D),
                      const Color(0xFF1E3A5F),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.category_outlined, size: 20),
                ),
                onPressed: _showCategorySheet,
                tooltip: 'Categories',
              ),
              const SizedBox(width: 8),
            ],
          ),

          SliverToBoxAdapter(
            child: SearchBarWidget(
              onSearch: (query) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchResultsScreen(query: query),
                  ),
                );
              },
            ),
          ),

          if (_feedItems.where((i) => i is Article).isNotEmpty)
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A1E3D),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Featured Stories',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A1E3D),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 280,
                    child: PageView.builder(
                      controller: _featuredController,
                      itemCount: (_feedItems.where((i) => i is Article).length).clamp(0, 5),
                      itemBuilder: (context, idx) {
                        final articlesOnly = _feedItems.where((i) => i is Article).cast<Article>().toList();
                        if (idx >= articlesOnly.length) return const SizedBox.shrink();
                        final art = articlesOnly[idx];
                        final isActive = idx == _featuredIndex;
                        
                        return AnimatedScale(
                          scale: isActive ? 1.0 : 0.9,
                          duration: const Duration(milliseconds: 300),
                          child: GestureDetector(
                            onTap: () => _navigateToArticle(art), // Show ad before navigation
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: art.imageUrl != null && art.imageUrl!.isNotEmpty 
                                        ? art.imageUrl! 
                                        : _getDynamicImageForArticle(art),
                                      fit: BoxFit.cover,
                                      placeholder: (c, u) => Container(
                                        color: Colors.grey[300],
                                        child: const Center(child: CircularProgressIndicator()),
                                      ),
                                      errorWidget: (c, u, e) => Container(color: Colors.grey[300]),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.black.withOpacity(0.7),
                                            Colors.transparent,
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.7),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 16,
                                      left: 16,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0A1E3D),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          art.category,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 16,
                                      bottom: 16,
                                      right: 16,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            art.headline,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              height: 1.3,
                                            ),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(Icons.access_time, color: Colors.white70, size: 14),
                                              const SizedBox(width: 4),
                                              Text(
                                                _getTimeAgo(art.date),
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 12,
                                                ),
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
                          ),
                        );
                      },
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          (_feedItems.where((i) => i is Article).length).clamp(0, 5),
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: index == _featuredIndex ? 24 : 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: index == _featuredIndex 
                                ? const Color(0xFF0A1E3D) 
                                : Colors.grey[300],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A1E3D),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _currentIndex == 0 ? 'Latest Updates' : 'Active Story Chains',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A1E3D),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_isLoading && _feedItems.isEmpty)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= _feedItems.length) return null;
                    final item = _feedItems[index];
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildFeedItem(item, index),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: _feedItems.length,
                ),
              ),
            ),

          if (_hasMore && _feedItems.isNotEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimationController,
        child: FloatingActionButton(
          onPressed: () {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
          backgroundColor: const Color(0xFF0A1E3D),
          child: const Icon(Icons.arrow_upward, color: Colors.white54),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
              _feedItems.clear();
              _currentPage = 1;
              _hasMore = true;
            });
            if (index == 0) {
              _loadFeed();
            } else {
              _loadChains();
            }
          },
          selectedItemColor: const Color.fromARGB(255, 255, 255, 255),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Feed',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.link_outlined),
              activeIcon: Icon(Icons.link),
              label: 'Chains',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedItem(dynamic item, int index) {
    if (item is List<Article>) {
      return ChainCard(
        articles: item,
        onTap: () => _navigateToChain(item), // Show ad before navigation
      );
    } else if (item is Article) {
      return ArticleCard(
        article: item,
        onTap: () => _navigateToArticle(item), // Show ad before navigation
      );
    } else if (item is NewsChain) {
      return ChainCard(
        articles: item.articles,
        onTap: () => _navigateToChain(item.articles), // Show ad before navigation
      );
    }
    return const SizedBox.shrink();
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class SearchResultsScreen extends StatefulWidget {
  final String query;

  const SearchResultsScreen({super.key, required this.query});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  bool _isLoading = true;
  List<Article> _articles = [];
  List<NewsChain> _chains = [];

  @override
  void initState() {
    super.initState();
    _performSearch();
  }

  Future<void> _performSearch() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.searchNews(widget.query);
      setState(() {
        _articles = response.articles;
        _chains = response.chains;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to search news'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToArticle(Article article) {
    AdService.instance.showInterstitialAd(
      onAdClosed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailScreen(article: article),
          ),
        );
      },
    );
  }

  void _navigateToChain(List<Article> articles) {
    AdService.instance.showInterstitialAd(
      onAdClosed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChainDetailScreen(articles: articles),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search: ${widget.query}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_chains.isNotEmpty) ...[
                  Text(
                    'Related Chains',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0A1E3D),
                        ),
                  ),
                  const SizedBox(height: 12),
                  ...AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 375),
                    childAnimationBuilder: (widget) => SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(child: widget),
                    ),
                    children: _chains.map((chain) {
                      return ChainCard(
                        articles: chain.articles,
                        onTap: () => _navigateToChain(chain.articles),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
                if (_articles.isNotEmpty) ...[
                  Text(
                    'Articles',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0A1E3D),
                        ),
                  ),
                  const SizedBox(height: 12),
                  ...AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 375),
                    childAnimationBuilder: (widget) => SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(child: widget),
                    ),
                    children: _articles.map((article) {
                      return ArticleCard(
                        article: article,
                        onTap: () => _navigateToArticle(article),
                      );
                    }).toList(),
                  ),
                ],
                if (_articles.isEmpty && _chains.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'No results found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}