# 🐝 Bee or Not v2

A modern headline guessing game built with Rails 8 where users test their ability to distinguish between real and fake news headlines.

## 🎮 Game Overview

Players are presented with headlines and must decide whether they're REAL (from actual news sources) or FAKE (deliberately crafted absurd headlines). The game tracks accuracy and provides immediate feedback with source verification.

### Features

- **Clean Modern UI**: Built with Tailwind CSS and Slim templates
- **Real-time Interactions**: Turbo Streams for seamless gameplay without page reloads
- **Mobile-first Design**: Responsive layout optimized for all devices
- **Comprehensive Scoring**: Track accuracy, total rounds, and correct guesses
- **Source Verification**: Links to verify real headlines (placeholder implementation)
- **Performance Metrics**: Motivational feedback based on accuracy percentage

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

The application includes seed data with 10 curated headlines (5 real, 5 fake):

```bash
# Reset and seed the database
bin/rails db:reset
```

## 🏗️ Architecture

### Models

- **Game**: Tracks overall game state and statistics
- **Round**: Individual headline presentation with associated guesses
- **Guess**: User's decision (real/fake) with correctness calculation
- **Headline**: News content with real/fake classification

### Key Design Decisions

- **Query-based Scoring**: Correctness calculated from source data, not stored
- **Boolean Guess Field**: Clean `real` boolean instead of string values
- **Explicit Round Creation**: Prevents side effects and improves testability
- **ActiveRecord Associations**: Proper has_many/belongs_to relationships

### Database Schema

```ruby
# Games: Simple session tracking
create_table "games" do |t|
  t.timestamps
end

# Headlines: Content with reality classification  
create_table "headlines" do |t|
  t.string :content, null: false
  t.boolean :real, null: false
  t.timestamps
end

# Rounds: Link games to specific headlines
create_table "rounds" do |t|
  t.references :game, foreign_key: true
  t.references :headline, foreign_key: true
  t.timestamps
end

# Guesses: User decisions with boolean real/fake
create_table "guesses" do |t|
  t.references :round, foreign_key: true
  t.boolean :real
  t.timestamps
end
```

## 🧪 Testing

Comprehensive test suite with 44 tests covering:

- **Model validations and business logic**
- **Controller actions and responses**
- **Turbo Stream interactions**
- **Integration workflows**
- **Edge cases and error handling**

```bash
# Test results
44 runs, 97 assertions, 0 failures, 0 errors, 0 skips
```

## 🚦 Deployment

Configured for deployment with Kamal 2:

```bash
# Deploy to production
kamal deploy
```

## 📋 TODO

### Near-term Improvements

- [ ] **Fix Source URLs**: Replace placeholder URLs with real source_url database field
- [ ] **Add Database Constraints**: Implement check constraints for content length and boolean validation
- [ ] **Improve Error Handling**: Add proper 404 pages and error recovery
- [ ] **Content Uniqueness**: Add validation to prevent duplicate headlines

### Performance & Scalability

- [ ] **Optimize Headline Selection**: Replace `RANDOM()` with more scalable selection algorithm
- [ ] **Add Headline Tracking**: Prevent users from seeing repeated headlines in same session
- [ ] **Score Calculation Caching**: Implement caching for expensive aggregation queries
- [ ] **Database Pagination**: Add pagination for large headline datasets

### Game Features

- [ ] **Game Completion Logic**: Add round limits or natural end states
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

- [ ] **Real-time Multiplayer**: WebSocket-based multiplayer games
- [ ] **Mobile App**: React Native or PWA implementation
- [ ] **Analytics Integration**: Track user behavior and headline effectiveness
- [ ] **Content Management**: Admin interface for managing headlines
- [ ] **API Development**: REST API for mobile apps and integrations

### Infrastructure

- [ ] **Performance Monitoring**: APM integration (New Relic, Skylight)
- [ ] **Error Tracking**: Sentry or Rollbar integration
- [ ] **Background Jobs**: Sidekiq for async processing
- [ ] **CDN Integration**: Asset delivery optimization
- [ ] **Database Optimization**: Connection pooling and query optimization

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass (`bin/rails test`)
6. Commit your changes (`git commit -m 'Add amazing feature'`)
7. Push to the branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with [Rails Omakase](https://omakase.rubyonrails.org/) conventions
- UI inspired by modern news and gaming interfaces
- Test headlines crafted to be educational and entertaining
