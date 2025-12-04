import 'dart:convert';
import 'package:diagonal/models/news_model.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://unsaluting-louvenia-nonsequaciously.ngrok-free.dev';
  
  static Future<FeedResponse> fetchFeed({int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/feed/tiktok?page=$page'),
        
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return FeedResponse.fromJson(data);
      } else {
        throw Exception('Failed to load feed');
      }
    } catch (e) {
      throw Exception('Error fetching feed: $e');
    }
  }

  static Future<ActiveChainsResponse> fetchActiveChains({int page = 1, int limit = 50}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/feed/active-chains?page=$page&limit=$limit'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ActiveChainsResponse.fromJson(data);
      } else {
        throw Exception('Failed to load active chains');
      }
    } catch (e) {
      throw Exception('Error fetching active chains: $e');
    }
  }

  static Future<SearchResponse> searchNews(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search?q=${Uri.encodeComponent(query)}'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return SearchResponse.fromJson(data);
      } else {
        throw Exception('Failed to search news');
      }
    } catch (e) {
      throw Exception('Error searching news: $e');
    }
  }

  static Future<FeedResponse> fetchCategoryFeed(String category, {int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/feed/category/$category/tiktok?page=$page'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return FeedResponse.fromJson(data);
      } else {
        throw Exception('Failed to load category feed');
      }
    } catch (e) {
      throw Exception('Error fetching category feed: $e');
    }
  }
}