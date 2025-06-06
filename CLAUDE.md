# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Bee or Not v2 is a Rails 8 headline guessing game where users distinguish between real and fake news headlines. Built with modern Rails conventions using Turbo Streams for real-time interactions and Tailwind CSS for styling.

## Development Commands

### Starting Development
```bash
# Primary development command (runs web server + CSS watcher)
bin/dev

# Alternative manual setup
bin/rails server  # Web server on port 3000
bin/rails tailwindcss:watch  # CSS compilation watcher
```

### Database Operations
```bash
bin/rails db:setup          # Create, migrate, and seed database
bin/rails db:reset          # Drop, create, migrate, and seed
bin/rails db:seed           # Load 10 curated headlines (5 real, 5 fake)
```

### Testing
```bash
bin/rails test              # Full test suite
bin/rails test:system       # System tests with Capybara/Selenium
COVERAGE=true bin/rails test # Test with coverage reports
```

### Code Quality
```bash
bin/rubocop                 # Rails Omakase Ruby styling
bin/brakeman                # Security vulnerability scanning
```

### Deployment
```bash
kamal deploy                # Deploy with Kamal 2
```

## Core Architecture

### Game Flow
1. **Game Creation**: New games start immediately and redirect to first guess
2. **Round Management**: Each round presents one headline from random selection
3. **Guess Processing**: Uses Turbo Streams to update feedback and stats without page reload
4. **Score Calculation**: Query-based scoring from guess/headline comparison (not stored)

### Key Models and Relationships
- **Game** → has_many :rounds → has_many :guesses (through rounds)
- **Round** → belongs_to :game, :headline; has_many :guesses
- **Guess** → belongs_to :round; boolean `real` field for user decision
- **Headline** → boolean `real` field for correct answer; random selection via `RANDOM()`

### Controller Patterns
- **GamesController**: Simple CRUD for game lifecycle
- **GuessesController**: Handles Turbo Stream responses for real-time feedback
- **Nested routing**: `/games/:id/guess` (singular resource)

### Critical Design Elements
- **Current Round Logic**: `current_round` association finds rounds without guesses
- **Lazy Round Creation**: New rounds created in `set_game` before_action when needed
- **Turbo Stream Updates**: Simultaneous updates to round content and game stats
- **Score Accuracy**: Uses `accuracy_ratio` method for percentage calculations

### Template Architecture
- **Slim Templates**: All views use Slim syntax for cleaner markup
- **Turbo Stream Partials**: `_feedback.html.slim` and `_stats.html.slim` for real-time updates
- **Responsive Design**: Tailwind CSS with mobile-first approach

### Database Schema Notes
- No stored scores - calculated via associations and joins
- `RANDOM()` selection for headlines (noted as scalability concern in TODO)
- Boolean fields for guess.real and headline.real (cleaner than string values)

### Test Structure
- Comprehensive model, controller, and integration tests
- Fixtures provide test data for all models
- Parallel test execution enabled via `parallelize(workers: :number_of_processors)`

## Technology Stack Specifics

- **Rails 8.0.1** with modern defaults
- **Slim templates** for clean view syntax
- **Tailwind CSS** via tailwindcss-rails gem
- **Turbo Streams** for SPA-like interactions
- **SQLite** for development (PostgreSQL-ready for production)
- **Solid Cache/Queue/Cable** for Rails 8 built-in adapters
- **Propshaft** for modern asset pipeline
- **Importmap** for JavaScript management

## Code Style Guidelines

### Model Design
- **Avoid callbacks**, especially those that trigger database commits or side effects
- Keep models focused on data integrity and business logic
- Use proper OOP design patterns with thoughtful names instead of generic "service objects"
- Prefer POROs (Plain Old Ruby Objects) with descriptive, intention-revealing names

### Controller Patterns
- **Limit to two instance variables per controller**: one for nested resource, one for main resource
- Example: `@game` (nested resource) and `@guess` (main resource) in GuessesController
- Avoid over-instantiation and complex setup in controllers

### View Logic Organization
- **Representation logic** can exist in both models and views initially
- **Migrate to ViewComponents** when logic becomes substantial or reusable
- Use `strict_loading!` on any ApplicationRecord passed to ViewComponents to prevent N+1 queries

## Performance Considerations

The current implementation uses `RANDOM()` for headline selection, which is noted in the README as needing optimization for scalability. Score calculations involve complex joins that may benefit from caching in high-traffic scenarios.

## Development Workflow & Quality Standards

### Code Quality Expectations
- **Always run RuboCop** before committing - use `bin/rubocop -A` for auto-corrections
- **Comprehensive testing required** - run `bin/rails test` frequently during development
- **Data integrity focus** - implement both Rails validations AND database constraints
- **Explicit over implicit** - prefer direct attributes with validation over methods with fallback logic

### Git & Documentation Standards
- **Detailed commit messages** using the established format with `🤖 Generated with [Claude Code]` footer
- **Comprehensive PR descriptions** with summary, changes made, and test plan sections
- **Proactive documentation updates** - update README TODOs when features are completed
- **Use TodoWrite tool extensively** for task planning and progress tracking

### Database Design Principles
- **Progressive constraint tightening** - start nullable, populate data, then add NOT NULL
- **Dual-layer validation** - Rails validations for user feedback, DB constraints for data integrity
- **Thoughtful migrations** - handle existing data gracefully in schema changes
- **Proper associations** - use `belongs_to`/`has_many` with appropriate `dependent:` options

### API Integration Approach
- **Analyze real requests** - when provided curl commands, implement exactly as specified
- **Graceful error handling** - comprehensive logging and fallback strategies
- **Authentication complexity** - handle CSRF tokens, session cookies, and headers properly
- **Respectful scraping** - consider rate limiting and Terms of Service compliance

### Testing Philosophy  
- **Test-driven refinement** - run tests after every significant change
- **Update fixtures comprehensively** - ensure test data reflects new model requirements
- **Edge case coverage** - test validation failures, duplicate prevention, error scenarios
- **Integration verification** - test that scrapers and external integrations work end-to-end