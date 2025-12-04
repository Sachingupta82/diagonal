import 'package:diagonal/models/news_model.dart';
import 'package:diagonal/services/ads_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import '../services/gemini_service.dart';
import 'package:share_plus/share_plus.dart';

class ChainDetailScreen extends StatefulWidget {
  final List<Article> articles;

  const ChainDetailScreen({super.key, required this.articles});

  @override
  State<ChainDetailScreen> createState() => _ChainDetailScreenState();
}

class _ChainDetailScreenState extends State<ChainDetailScreen> with SingleTickerProviderStateMixin {
  String? _aiSummary;
  bool _isLoading = false;
  bool _hasLoadedSummary = false;
  int _selectedIndex = 0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _loadAISummary();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAISummary() async {
    if (_hasLoadedSummary) return;
    setState(() => _isLoading = true);
    try {
      final chainHeadlines = widget.articles
          .asMap()
          .entries
          .map((entry) => '${entry.key + 1}. ${DateFormat('MMM dd, yyyy').format(entry.value.date)}: ${entry.value.headline}')
          .join('\n');
      final summary = await GeminiService.getChainSummary(chainHeadlines);
      setState(() {
        _aiSummary = summary;
        _hasLoadedSummary = true;
      });
    } catch (e) {
      setState(() => _aiSummary = 'Unable to load AI-generated summary.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showSnackBar('Could not open URL', isError: true);
    }
  }

  // Generate deep link for chain
  String _generateChainDeepLink() {
    // Extract article IDs (you'll need to get rowId from articles)
    final articleIds = widget.articles.map((a) => a.rowId).join(',');
    return 'https://diagonalnews.app/chain?articles=$articleIds';
  }

  // Share chain with rewarded ad
  void _shareChain() {
    AdService.instance.showRewardedAd(
      onAdWatched: () {
        debugPrint('User watched rewarded ad, sharing chain...');
        final deepLink = _generateChainDeepLink();
        final sortedArticles = List<Article>.from(widget.articles)..sort((a, b) => a.date.compareTo(b.date));
        
        Share.share(
          '📰 Check out this Story Chain on Diagonal News!\n\n'
          '${sortedArticles.first.headline}\n\n'
          '${sortedArticles.length} articles tracking this story over ${sortedArticles.last.date.difference(sortedArticles.first.date).inDays} days\n\n'
          '$deepLink\n\n'
          'Download Diagonal News App to stay updated!',
          subject: 'Story Chain from Diagonal News',
        );
      },
      onAdCancelled: () {
        debugPrint(' User cancelled rewarded ad');
        _showSnackBar('Watch the ad to unlock sharing', isError: true);
      },
    );
  }

void _showFullSummaryBottomSheet() {
  final sortedArticles = List<Article>.from(widget.articles)..sort((a, b) => a.date.compareTo(b.date));
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0A1E3D), Color(0xFF1E3A5F)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Complete AI-Generated Story Summary',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A1E3D),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _aiSummary ?? 'No summary available.',
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.7,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A1E3D).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF0A1E3D).withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: const Color(0xFF0A1E3D)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'This summary was intelligently generated by analyzing ${widget.articles.length} articles over ${sortedArticles.last.date.difference(sortedArticles.first.date).inDays + 1} days.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
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
  );
}

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
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
    
    final text = '${article.headline}'.toLowerCase();
    
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
    final sortedArticles = List<Article>.from(widget.articles)..sort((a, b) => a.date.compareTo(b.date));
    final selectedArticle = sortedArticles[_selectedIndex];

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
              // Share button with reward ad
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
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF0A1E3D),
                          Color(0xFF1E3A5F),
                          Color(0xFF2A4A6F),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: -50,
                    top: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0A1E3D), Color(0xFF1E3A5F)],
                ),
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
                      _buildStatItem(
                        Icons.article_outlined,
                        '${sortedArticles.length}',
                        'Articles',
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white24,
                      ),
                      _buildStatItem(
                        Icons.calendar_today_outlined,
                        '${sortedArticles.last.date.difference(sortedArticles.first.date).inDays}',
                        'Days',
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white24,
                      ),
                      _buildStatItem(
                        Icons.category_outlined,
                        sortedArticles.first.category,
                        'Category',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.access_time, color: Colors.white70, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          '${DateFormat('MMM dd, yyyy').format(sortedArticles.first.date)} — ${DateFormat('MMM dd, yyyy').format(sortedArticles.last.date)}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
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
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
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
              child: const Icon(
                Icons.auto_awesome,
                color: Color(0xFF0A1E3D),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'AI Story Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A1E3D),
              ),
            ),
            const Spacer(),
            if (_isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 16),

        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_aiSummary == null || _aiSummary!.trim().isEmpty)
          const Text(
            'AI summary not available',
            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
          )
        else ...[
          Text(
            _aiSummary!,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Colors.grey[800],
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _showFullSummaryBottomSheet(),
              icon: const Icon(Icons.auto_awesome_motion, size: 18),
              label: const Text('Read Full AI Summary'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0A1E3D),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
        ],
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
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A1E3D),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Story Evolution',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A1E3D),
                    ),
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
                                  border: Border.all(
                                    color: const Color(0xFF0A1E3D),
                                    width: isSelected ? 4 : 2,
                                  ),
                                ),
                              ),
                              if (!isLast)
                                Expanded(
                                  child: Container(
                                    width: 2,
                                    color: const Color(0xFF0A1E3D).withOpacity(0.3),
                                  ),
                                ),
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
                                  color: isSelected 
                                    ? const Color(0xFF0A1E3D) 
                                    : Colors.grey.shade200,
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isSelected 
                                      ? const Color(0xFF0A1E3D).withOpacity(0.15)
                                      : Colors.black.withOpacity(0.05),
                                    blurRadius: isSelected ? 20 : 10,
                                    offset: Offset(0, isSelected ? 8 : 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(15),
                                    ),
                                    child: CachedNetworkImage(
                                      imageUrl: _getDynamicImageForArticle(article),
                                      height: isSelected ? 200 : 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
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
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 5,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF0A1E3D),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                article.category,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
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
                                              DateFormat('MMM dd, yyyy').format(article.date),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
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
                                          Row(
                                            children: [
                                              Expanded(
                                                child: ElevatedButton.icon(
                                                  onPressed: () => _launchURL(article.url),
                                                  icon: const Icon(Icons.open_in_new, size: 18),
                                                  label: const Text('Read Article'),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFF0A1E3D),
                                                    foregroundColor: Colors.white,
                                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    elevation: 0,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              IconButton(
                                                onPressed: () async {
                                                  await Clipboard.setData(
                                                    ClipboardData(text: article.url),
                                                  );
                                                  _showSnackBar('Link copied to clipboard');
                                                },
                                                icon: const Icon(Icons.copy),
                                                style: IconButton.styleFrom(
                                                  backgroundColor: Colors.grey[100],
                                                  foregroundColor: const Color(0xFF0A1E3D),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              // Individual article share with reward ad
                                              IconButton(
                                                onPressed: () {
                                                  AdService.instance.showRewardedAd(
                                                    onAdWatched: () {
                                                      final deepLink = 'https://diagonalnews.app/article?id=${article.rowId}';
                                                      Share.share(
                                                        '📰 ${article.headline}\n\n'
                                                        'Read more: $deepLink\n\n'
                                                        'via Diagonal News App',
                                                        subject: article.headline,
                                                      );
                                                    },
                                                    onAdCancelled: () {
                                                      _showSnackBar('Watch the ad to unlock sharing', isError: true);
                                                    },
                                                  );
                                                },
                                                icon: const Icon(Icons.share_outlined),
                                                tooltip: 'Share Article',
                                                style: IconButton.styleFrom(
                                                  backgroundColor: Colors.grey[100],
                                                  foregroundColor: const Color(0xFF0A1E3D),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                ),
                                              ),
                                            ],
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

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}