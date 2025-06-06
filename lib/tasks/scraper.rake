namespace :scraper do
  desc "Scrape headlines from Babylon Bee"
  task babylon_bee: :environment do
    puts "Starting Babylon Bee scraper..."

    scraper = Scrapers::BabylonBeeScraper.new
    headlines = scraper.scrape_headlines

    if headlines.any?
      puts "Successfully scraped #{headlines.length} headlines:"
      headlines.each_with_index do |headline, index|
        puts "#{index + 1}. #{headline.content}"
      end
    else
      puts "No headlines were scraped. This might be due to:"
      puts "- Network connectivity issues"
      puts "- Website structure changes"
      puts "- Rate limiting"
    end

    puts "\nTotal headlines in database: #{Headline.count}"
    puts "Real headlines: #{Headline.real.count}"
    puts "Fake headlines: #{Headline.fake.count}"
  end

  desc "Scrape headlines from Not the Bee"
  task not_the_bee: :environment do
    puts "Starting Not the Bee scraper..."

    scraper = Scrapers::NotTheBeeScraper.new
    headlines = scraper.scrape_headlines

    if headlines.any?
      puts "Successfully scraped #{headlines.length} headlines:"
      headlines.each_with_index do |headline, index|
        puts "#{index + 1}. #{headline.content}"
      end
    else
      puts "No headlines were scraped. This might be due to:"
      puts "- Network connectivity issues"
      puts "- Website structure changes"
      puts "- Rate limiting"
    end

    puts "\nTotal headlines in database: #{Headline.count}"
    puts "Real headlines: #{Headline.real.count}"
    puts "Fake headlines: #{Headline.fake.count}"
  end
end
