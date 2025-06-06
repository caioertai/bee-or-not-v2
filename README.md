# 🐝 Bee or Not v2

A modern headline guessing game built with Rails 8 where users test their ability to distinguish between real and fake news headlines.

## 🎮 Game Overview

Players are presented with headlines and must decide whether they're REAL (from actual news sources) or FAKE (deliberately crafted absurd headlines). The game tracks accuracy and provides immediate feedback with source verification.

### Features

- **Clean Modern UI**: Built with Tailwind CSS and Slim templates
- **Real-time Interactions**: Turbo Streams for seamless gameplay without page reloads
- **Mobile-first Design**: Responsive layout optimized for all devices
- **Comprehensive Scoring**: Track accuracy, total rounds, and correct guesses
- **Source Verification**: Direct links to original articles for verification
- **Performance Metrics**: Motivational feedback based on accuracy percentage
- **Smart Headline Management**: No headline repetition within games, natural completion when exhausted
- **Optimized Performance**: Subquery-based headline selection for scalable gameplay

## 🛠️ Technical Stack

- **Rails 8.0.1** with modern defaults
- **Slim Templates** for clean, readable views
- **Tailwind CSS** for utility-first styling
- **Turbo Streams** for real-time interactions
- **SQLite** for development/testing (production-ready for PostgreSQL)
- **Kamal 2** deployment configuration

## 🚀 Getting Started

### Prerequisites

- Ruby 3.3.0 or higher
- Rails 8.0.1
- Node.js (for asset compilation)

### Installation

```bash
# Clone the repository
git clone https://github.com/caioertai/bee-or-not-v2.git
cd bee-or-not-v2

# Install dependencies
bundle install

# Setup database
bin/rails db:setup

# Start the development server
bin/dev
```

Visit `http://localhost:3000` to start playing!

### Running Tests

```bash
# Run the full test suite
bin/rails test

# Run with coverage
COVERAGE=true bin/rails test
```

### Database Setup

The application includes seed data with 10 curated headlines (5 real from Reuters, 5 fake from Babylon Bee):

```bash
# Reset and seed the database
bin/rails db:reset

# Scrape fresh Babylon Bee headlines
bin/rails scraper:babylon_bee
```

## 🏗️ Architecture

### Models

- **Game**: Tracks overall game state and statistics
- **Round**: Individual headline presentation with associated guesses
- **Guess**: User's decision (real/fake) with correctness calculation
- **Headline**: News content with real/fake classification and source URL
- **Source**: News publication metadata (Reuters, Babylon Bee, etc.)

### Key Design Decisions

- **Query-based Scoring**: Correctness calculated from source data, not stored
- **Boolean Guess Field**: Clean `real` boolean instead of string values
- **Explicit Round Creation**: Prevents side effects and improves testability
- **ActiveRecord Associations**: Proper has_many/belongs_to relationships
- **Headline Uniqueness**: Subquery-based selection prevents repetition within games
- **Natural Game Completion**: Games end gracefully when all headlines are exhausted
- **Controller Simplicity**: Guard clauses and minimal instance variables (2-ivar rule)


## 🧪 Testing

Comprehensive test suite covering:

- **Model validations and business logic**
- **Controller actions and responses**
- **Turbo Stream interactions**
- **Integration workflows**
- **Edge cases and error handling**

## 🚦 Deployment

Configured for deployment with Kamal 2:

```bash
# Deploy to production
kamal deploy
```

## 📋 TODO

### Completed Features ✅

- [x] **~~Fix Source URLs~~**: ✅ Implemented source_url database field with proper validation
- [x] **~~Source Management~~**: ✅ Added Source model with proper associations and constraints
- [x] **~~Automated Content~~**: ✅ Babylon Bee scraper for fresh satirical headlines

### Near-term Improvements

- [ ] **Scraper Resilience**: Add retry logic and better error handling for API changes
- [ ] **Rate Limiting**: Implement delays and respect robots.txt for scraping
- [ ] **More News Sources**: Add scrapers for additional real news sources (BBC, CNN, etc.)
- [ ] **Background Processing**: Move scraping to async jobs with Sidekiq
- [ ] **Database Constraints**: Add check constraints for content length validation
- [ ] **Improve Error Handling**: Add proper 404 pages and error recovery

### Performance & Scalability

- [x] **~~Optimize Headline Selection~~**: ✅ Implemented subquery-based selection for better performance
- [x] **~~Add Headline Tracking~~**: ✅ Prevent users from seeing repeated headlines in same session
- [ ] **Score Calculation Caching**: Implement caching for expensive aggregation queries
- [ ] **Database Pagination**: Add pagination for large headline datasets
- [ ] **Scraper Monitoring**: Add health checks and alerting for scraper failures
- [ ] **Database Indexes**: Optimize queries with proper indexing strategy

### Game Features

- [x] **~~Game Completion Logic~~**: ✅ Added natural end states when all headlines are exhausted
- [ ] **Difficulty Levels**: Implement easy/medium/hard headline categories
- [ ] **Game Modes**: Add timed rounds, category-specific games, multiplayer challenges
- [ ] **Progress Tracking**: Visual progress bars and round counters
- [ ] **Achievement System**: Badges for accuracy milestones and streaks

### User Experience

- [ ] **User Authentication**: Add user accounts for persistent score tracking
- [ ] **Leaderboards**: Global and friends-only high score tables
- [ ] **Social Features**: Share scores, challenge friends, compete in tournaments
- [ ] **Enhanced Feedback**: More detailed explanations for why headlines are real/fake
- [ ] **Accessibility Improvements**: Better keyboard navigation and screen reader support

### Technical Enhancements

- [ ] **Scraper Configuration**: Move hardcoded URLs to Rails configuration files
- [ ] **API Monitoring**: Track Babylon Bee API changes and health
- [ ] **Real-time Multiplayer**: WebSocket-based multiplayer games
- [ ] **Mobile App**: React Native or PWA implementation
- [ ] **Analytics Integration**: Track user behavior and headline effectiveness
- [ ] **Content Management**: Admin interface for managing headlines and sources
- [ ] **API Development**: REST API for mobile apps and integrations

### Infrastructure

- [ ] **Performance Monitoring**: APM integration (New Relic, Skylight)
- [ ] **Error Tracking**: Sentry or Rollbar integration
- [ ] **Background Jobs**: Sidekiq for async processing
- [ ] **CDN Integration**: Asset delivery optimization
- [ ] **Database Optimization**: Connection pooling and query optimization


## 🙏 Acknowledgments

- Built with [Rails Omakase](https://omakase.rubyonrails.org/) conventions
- UI inspired by modern news and gaming interfaces
- Test headlines crafted to be educational and entertaining
