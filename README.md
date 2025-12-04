# Diagonal

A professional news application built with Flutter that provides contextual news reading through innovative news chains, helping users understand the complete story evolution over time.

## Overview

Diagonal is designed to solve a common problem in news consumption: readers often see today's headlines without understanding the context of events that happened days or weeks before. The app introduces "news chains" - sequences of related articles that show how a story has evolved, giving users the complete picture of ongoing events.

## Features

### Core Functionality

- **TikTok-Style News Feed**: Smooth, infinite scrolling feed with a mix of individual articles and news chains
- **News Chains**: Grouped sequences of related articles showing story evolution over time
- **AI-Powered Insights**: Integration with Google Gemini AI for article summaries and chain analysis
- **Category Filtering**: Browse news by specific categories (50+ available categories)
- **Search**: Full-text search across all articles and chains
- **Timeline View**: Visual timeline representation for news chains showing chronological progression

### User Experience

- **Hero Animations**: Smooth transitions between screens
- **Staggered List Animations**: Professional entry animations for list items
- **Pull-to-Refresh**: Easy content refresh on all feeds
- **Infinite Scroll**: Automatic content loading as users scroll
- **Image Caching**: Fast image loading with intelligent caching
- **External Browser Integration**: Open full articles in external browser

### Monetization

The application implements Google Ads for revenue generation:

- **Banner Ads**: Display every 2 minutes during app usage
- **Interstitial Ads**: Shown when users click on articles
- **Rewarded Ads**: Displayed when users attempt to share news chains

## Technology Stack

### Framework & Language

- Flutter 3.0+
- Dart

### Key Dependencies

- **http**: REST API communication
- **cached_network_image**: Efficient image loading and caching
- **google_generative_ai**: AI-powered content generation
- **flutter_staggered_animations**: Professional UI animations
- **url_launcher**: External URL handling
- **intl**: Date formatting and internationalization
- **shimmer**: Loading state animations

## Architecture

### Project Structure

```
lib/
├── main.dart
├── models/
│   └── news_models.dart
├── services/
│   ├── api_service.dart
|   ├── ads_service.dart
│   └── gemini_service.dart
├── screens/
│   ├── home_screen.dart
│   ├── article_detail_screen.dart
│   ├── chain_detail_screen.dart
│   └── category_screen.dart
└── widgets/
    ├── article_card.dart
    ├── chain_card.dart
    ├── search_bar_widget.dart
    └── category_sheet.dart
```

### API Integration

The application connects to a custom news aggregation API that provides:

- **Feed Endpoint**: Main feed with mixed content (sequences and articles)
- **Active Chains Endpoint**: List of ongoing news chains
- **Search Endpoint**: Full-text search functionality
- **Category Endpoint**: Category-specific news feeds

### AI Integration

Google Gemini AI (gemini-pro model) powers:

- Article summaries and key point extraction
- Context and background information generation
- News chain evolution analysis
- Story development tracking

## Installation

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (2.19 or higher)
- Android Studio / VS Code with Flutter extensions
- Android SDK / Xcode (for respective platforms)

### Setup Steps

1. Clone the repository:
```bash
git clone https://github.com/Sachingupta82/diagonal.git
cd diagonal
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run
```

### Configuration

The application requires the following configurations:

1. **API Endpoint**: Update the base URL in `lib/services/api_service.dart`
2. **Gemini API Key**: Configured in `lib/services/gemini_service.dart`
3. **Google Ads**: Configure ad units in respective platform files

## Usage

### Navigation

The app features a bottom navigation bar with two main sections:

1. **Feed**: Main news feed with mixed content
2. **Chains**: Dedicated view for active news chains

### Reading Articles

- Tap any article card to view details
- AI-generated insights load automatically
- Use the "Read Full Article" button to open in browser

### Exploring News Chains

- Tap chain cards to view the complete timeline
- Scroll through chronologically ordered articles
- Read AI-generated summary of the story evolution
- Tap individual articles within chains for more details

### Search and Categories

- Use the search bar at the top of the home screen
- Access categories via the category icon in the app bar
- Browse 50+ news categories
- Each category maintains its own feed with pagination

## Development Team

- **Sachinkumar Gupta**: App Development and API Integration
- **Rohan Dhiman**: Backend Development

## Support

For issues, questions, or suggestions, please contact:

Email: sachin.apwig@gmail.com

---

Thank You for your visit.
