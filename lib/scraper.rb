require 'nokogiri'
require 'open-uri'
require 'pry'

require_relative './rental.rb'

class Scraper
  @@doc = nil
  @@city = nil

  def get_page
    @@doc ||= Nokogiri::HTML(open("https://#{@@city}.craigslist.org/search/apa?availabilityMode=0&hints=bedsbaths&max_bathrooms=2&max_bedrooms=3&min_bathrooms=2&min_bedrooms=3", "User-Agent" => "foobar"))
  end

  def get_listings
    self.get_page.css(".result-row")
  end

  def make_rentals(city)
    @@city = city
    self.get_listings.each do |rental|
      scraped_title = rental.css("a.result-title").text
      scraped_address = rental.css("span.result-hood").text
      #rental.xpath('//span[contains(@class, "result-price")]').first.try(:text)
      scraped_rent = rental.css("span.result-price").text
      scraped_url = rental.at('a')[:href]

      rental = Rental.new
      rental.title = scraped_title
      rental.url = "https://#{@@city}.craigslist.org" + scraped_url
      if !scraped_address.empty?
         clean_address = scraped_address.gsub(/[()]/, '')
         clean_address[0] = ''
         rental.address = clean_address
      end
      if !scraped_rent.empty?
        split_at = scraped_rent.length / 2
        rental.rent = scraped_rent[0, split_at]
      end
    end

    if next_page = @@doc.at('a[title="next page"]')
      next_page_link = "https://#{@@city}.craigslist.org" + next_page.values[0]
      @@doc = Nokogiri::HTML(open(next_page_link, "User-Agent" => "foobar")) #, 'User-Agent' => 'ruby'
      make_rentals(@@city)
    end
  end
end

Scraper.new.make_rentals("miami") #initialize scraper
puts CSV.parse(Rental.create_csv) #Rental.create_csv creates csv string + CSV.parse to parse csv string
