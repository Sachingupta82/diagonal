// chain_detail_screen.dart - FIXED VERSION WITH PROPER SCROLLING
import 'package:diagonal/models/news_model.dart';
import 'package:diagonal/services/ads_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/gemini_service.dart';
import 'package:share_plus/share_plus.dart';

class ChainDetailScreen extends StatefulWidget {
  final List<Article> articles;

  const ChainDetailScreen({super.key, required this.articles});

  @override
  State<ChainDetailScreen> createState() => _ChainDetailScreenState();
}

class _ChainDetailScreenState extends State<ChainDetailScreen> with TickerProviderStateMixin {
  String? _aiSummary;
  bool _isLoadingAI = false;
  bool _hasLoadedAI = false;
  int _selectedIndex = 0;
  late AnimationController _animationController;

  // For article reading
  bool _showArticleReader = false;
  Article? _selectedArticle;
  late TabController _articleTabController;
  WebViewController? _webViewController;
  bool _isLoadingWeb = true;
  String? _articleAISummary;
  bool _isLoadingArticleAI = false;

  @override
  void initState() {
    super.initState();
    _loadAISummary();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
    _articleTabController = TabController(length: 2, vsync: this);
    _articleTabController.addListener(() {
      if (_articleTabController.index == 1 && _selectedArticle != null && _articleAISummary == null) {
        _loadArticleAISummary();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _articleTabController.dispose();
    super.dispose();
  }

  Future<void> _loadAISummary() async {
    if (_hasLoadedAI) return;
    setState(() => _isLoadingAI = true);
    try {
      final sortedArticles = List<Article>.from(widget.articles)..sort((a, b) => a.date.compareTo(b.date));
      final chainHeadlines = sortedArticles
          .asMap()
          .entries
          .map((entry) => '${entry.key + 1}. ${DateFormat('MMM dd, yyyy').format(entry.value.date)}: ${entry.value.headline}')
          .join('\n');
      final summary = await GeminiService.getChainSummary(chainHeadlines);
      setState(() {
        _aiSummary = summary;
        _hasLoadedAI = true;
      });
    } catch (e) {
      setState(() => _aiSummary = 'Unable to load AI-generated summary.');
    } finally {
      setState(() => _isLoadingAI = false);
    }
  }

  Future<void> _loadArticleAISummary() async {
    if (_selectedArticle == null) return;
    setState(() => _isLoadingArticleAI = true);
    try {
      final summary = await GeminiService.getArticleDetails(
        _selectedArticle!.headline,
        _selectedArticle!.url,
      );
      setState(() => _articleAISummary = summary);
    } catch (e) {
      setState(() => _articleAISummary = 'Unable to load AI summary.');
    } finally {
      setState(() => _isLoadingArticleAI = false);
    }
  }

  void _openArticleReader(Article article) {
    setState(() {
      _selectedArticle = article;
      _showArticleReader = true;
      _articleAISummary = null;
      _isLoadingWeb = true;
      _articleTabController.index = 0;
    });

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) => setState(() => _isLoadingWeb = true),
          onPageFinished: (String url) => setState(() => _isLoadingWeb = false),
          onWebResourceError: (WebResourceError error) => setState(() => _isLoadingWeb = false),
        ),
      )
      ..loadRequest(Uri.parse(article.url));
  }

  void _closeArticleReader() {
    setState(() {
      _showArticleReader = false;
      _selectedArticle = null;
      _webViewController = null;
    });
  }

  void _shareChain() {
    AdService.instance.showRewardedAd(
      onAdWatched: () {
        final sortedArticles = List<Article>.from(widget.articles)..sort((a, b) => a.date.compareTo(b.date));
        Share.share(
          '📰 Check out this Story Chain on Diagonal News!\n\n'
              '${sortedArticles.first.headline}\n\n'
              '${sortedArticles.length} articles tracking this story over ${sortedArticles.last.date.difference(sortedArticles.first.date).inDays} days\n\n'
              'Download Diagonal News App to stay updated!',
          subject: 'Story Chain from Diagonal News',
        );
      },
      onAdCancelled: () {
        _showSnackBar('Watch the ad to unlock sharing', isError: true);
      },
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _getDynamicImageForArticle(Article article) {
    if (article.imageUrl != null && article.imageUrl!.isNotEmpty) {
      return article.imageUrl!;
    }

    final text = article.headline.toLowerCase();
    if (text.contains('ai') || text.contains('artificial intelligence')) {
      return 'https://images.unsplash.com/photo-1677442136019-21780ecad995?w=1200&auto=format&fit=crop&q=80';
    } else if (text.contains('bjp') || text.contains('congress')) {
      return 'https://media.assettype.com/deccanherald/2024-04/0748b54e-60a9-4b16-8b47-7a37537a2864/congress_bjp_file_phoot_969654_1617384003.jpg?w=1200&h=675&auto=format%2Ccompress&fit=max&enlarge=true';
    } else if (text.contains('tech') || text.contains('technology')) {
      return 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=1200&auto=format&fit=crop&q=80';
    }
    return 'https://images.unsplash.com/photo-1504711434969-e33886168f5c?w=1200&auto=format&fit=crop&q=80';
  }

  @override
  Widget build(BuildContext context) {
    if (_showArticleReader && _selectedArticle != null) {
      return _buildArticleReader();
    }

    final sortedArticles = List<Article>.from(widget.articles)..sort((a, b) => a.date.compareTo(b.date));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF0A1E3D),
            actions: [
              IconButton(
                onPressed: _shareChain,
                icon: const Icon(Icons.share),
                tooltip: 'Share Story Chain',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.1),
                ),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Story Timeline',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0A1E3D), Color(0xFF1E3A5F), Color(0xFF2A4A6F)],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF0A1E3D), Color(0xFF1E3A5F)]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0A1E3D).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(Icons.article_outlined, '${sortedArticles.length}', 'Articles'),
                      Container(width: 1, height: 40, color: Colors.white24),
                      _buildStatItem(Icons.calendar_today_outlined, '${sortedArticles.last.date.difference(sortedArticles.first.date).inDays}', 'Days'),
                      Container(width: 1, height: 40, color: Colors.white24),
                      _buildStatItem(Icons.category_outlined, sortedArticles.first.category, 'Category'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A1E3D).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.auto_awesome, color: Color(0xFF0A1E3D), size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'AI Story Summary',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A1E3D)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_isLoadingAI)
                    const Center(child: CircularProgressIndicator())
                  else if (_aiSummary == null || _aiSummary!.trim().isEmpty)
                    const Text('AI summary not available', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
                  else
                    Text(_aiSummary!, style: TextStyle(fontSize: 15, height: 1.6, color: Colors.grey[800])),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(color: const Color(0xFF0A1E3D), borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Story Evolution',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0A1E3D)),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final article = sortedArticles[index];
                final isSelected = index == _selectedIndex;
                final isLast = index == sortedArticles.length - 1;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                      _animationController.reset();
                      _animationController.forward();
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? const Color(0xFF0A1E3D) : Colors.white,
                                  border: Border.all(color: const Color(0xFF0A1E3D), width: isSelected ? 4 : 2),
                                ),
                              ),
                              if (!isLast)
                                Expanded(child: Container(width: 2, color: const Color(0xFF0A1E3D).withOpacity(0.3))),
                            ],
                          ),
                          const SizedBox(width: 16),

                          Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF0A1E3D) : Colors.grey.shade200,
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isSelected ? const Color(0xFF0A1E3D).withOpacity(0.15) : Colors.black.withOpacity(0.05),
                                    blurRadius: isSelected ? 20 : 10,
                                    offset: Offset(0, isSelected ? 8 : 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                    child: CachedNetworkImage(
                                      imageUrl: _getDynamicImageForArticle(article),
                                      height: isSelected ? 200 : 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey[300],
                                        child: const Center(child: CircularProgressIndicator()),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.article, size: 60),
                                      ),
                                    ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF0A1E3D),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                article.category,
                                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            const Spacer(),
                                            Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey[600]),
                                            const SizedBox(width: 6),
                                            Text(
                                              DateFormat('MMM dd, yyyy').format(article.date),
                                              style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          article.headline,
                                          style: TextStyle(
                                            fontSize: isSelected ? 17 : 15,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF0A1E3D),
                                            height: 1.3,
                                          ),
                                          maxLines: isSelected ? 4 : 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (isSelected) ...[
                                          const SizedBox(height: 16),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton.icon(
                                              onPressed: () => _openArticleReader(article),
                                              icon: const Icon(Icons.open_in_new, size: 18),
                                              label: const Text('Read Article'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF0A1E3D),
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(vertical: 14),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                elevation: 0,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              childCount: sortedArticles.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildArticleReader() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1E3D),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: _closeArticleReader,
        ),
        title: const Text('Article', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: Column(
              children: [
                CachedNetworkImage(
                  imageUrl: _getDynamicImageForArticle(_selectedArticle!),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A1E3D),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _selectedArticle!.category,
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _selectedArticle!.headline,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A1E3D), height: 1.3),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('MMM dd, yyyy').format(_selectedArticle!.date),
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                  ),
                  child: TabBar(
                    controller: _articleTabController,
                    labelColor: const Color(0xFF0A1E3D),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: const Color(0xFF0A1E3D),
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    tabs: const [
                      Tab(text: 'Read Full'),
                      Tab(text: 'AI Summary'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _articleTabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Stack(
                  children: [
                    if (_webViewController != null)
                      WebViewWidget(controller: _webViewController!),
                    if (_isLoadingWeb)
                      Container(
                        color: Colors.white,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                  ],
                ),
                _isLoadingArticleAI
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0A1E3D).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.auto_awesome, color: Color(0xFF0A1E3D), size: 24),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'AI-Generated Summary',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A1E3D)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _articleAISummary ?? 'No summary available',
                          style: const TextStyle(fontSize: 16, height: 1.7, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}