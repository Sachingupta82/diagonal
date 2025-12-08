// article_detail_screen.dart - FIXED VERSION
import 'package:diagonal/models/news_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/gemini_service.dart';

class ArticleDetailScreen extends StatefulWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _aiSummary;
  bool _isLoadingAI = false;
  bool _hasLoadedAI = false;
  late WebViewController _webViewController;
  bool _isLoadingWeb = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1 && !_hasLoadedAI) {
        _loadAISummary();
      }
    });
    _initWebView();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoadingWeb = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoadingWeb = false);
          },
          onWebResourceError: (WebResourceError error) {
            setState(() => _isLoadingWeb = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.article.url));
  }

  Future<void> _loadAISummary() async {
    if (_hasLoadedAI) return;

    setState(() => _isLoadingAI = true);

    try {
      final summary = await GeminiService.getArticleDetails(
        widget.article.headline,
        widget.article.url,
      );
      setState(() {
        _aiSummary = summary;
        _hasLoadedAI = true;
      });
    } catch (e) {
      setState(() {
        _aiSummary = 'Unable to load AI-generated summary at this time.';
      });
    } finally {
      setState(() => _isLoadingAI = false);
    }
  }

  String _getImageUrl() {
    if (widget.article.imageUrl != null && widget.article.imageUrl!.isNotEmpty) {
      return widget.article.imageUrl!;
    }

    final text = widget.article.headline.toLowerCase();
    if (text.contains('ai') || text.contains('artificial intelligence')) {
      return 'https://images.unsplash.com/photo-1677442136019-21780ecad995?w=1200&auto=format&fit=crop&q=80';
    } else if (text.contains('government') || text.contains('politics')) {
      return 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=800';
    } else if (text.contains('space') || text.contains('nasa') || text.contains('rocket')) {
      return 'https://images.unsplash.com/photo-1446776653964-20c1d3a81b06?w=1200&auto=format&fit=crop&q=80';
    } else if (text.contains('bjp') || text.contains('congress')) {
      return 'https://media.assettype.com/deccanherald/2024-04/0748b54e-60a9-4b16-8b47-7a37537a2864/congress_bjp_file_phoot_969654_1617384003.jpg?w=1200&h=675&auto=format%2Ccompress&fit=max&enlarge=true';
    } else if (text.contains('climate') || text.contains('environment')) {
      return 'https://images.unsplash.com/photo-1569163139394-de4798aa62b6?w=1200&auto=format&fit=crop&q=80';
    } else if (text.contains('crypto') || text.contains('bitcoin')) {
      return 'https://images.unsplash.com/photo-1639762681485-074b7f938ba0?w=1200&auto=format&fit=crop&q=80';
    } else if (text.contains('tech') || text.contains('technology')) {
      return 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=1200&auto=format&fit=crop&q=80';
    } else if (text.contains('cricket') || text.contains('ipl')) {
      return 'https://images.unsplash.com/photo-1531415074968-036ba1b575da?w=1200&auto=format&fit=crop&q=80';
    } else if (text.contains('health') || text.contains('medical')) {
      return 'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?w=1200&auto=format&fit=crop&q=80';
    }
    return 'https://images.unsplash.com/photo-1504711434969-e33886168f5c?w=1200&auto=format&fit=crop&q=80';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1E3D),
        elevation: 0,
        title: const Text('Article', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            color: Colors.white,
            child: Column(
              children: [
                // Image
                Hero(
                  tag: 'article_${widget.article.rowId}',
                  child: CachedNetworkImage(
                    imageUrl: _getImageUrl(),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.article, size: 80, color: Colors.grey),
                    ),
                  ),
                ),

                // Article Info
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
                          widget.article.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.article.headline,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A1E3D),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('MMM dd, yyyy').format(widget.article.date),
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Tab Bar
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
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

          // Tab Content - THIS IS KEY: Expanded allows proper scrolling
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Web View Tab - Full scrollable WebView
                Stack(
                  children: [
                    WebViewWidget(controller: _webViewController),
                    if (_isLoadingWeb)
                      Container(
                        color: Colors.white,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                  ],
                ),

                // AI Summary Tab - Scrollable
                _isLoadingAI
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
                              child: const Icon(
                                Icons.auto_awesome,
                                color: Color(0xFF0A1E3D),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'AI-Generated Summary',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0A1E3D),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _aiSummary ?? 'No summary available',
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.7,
                            color: Colors.black87,
                          ),
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
}