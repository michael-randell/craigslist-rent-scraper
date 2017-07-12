require 'csv'

class Rental
  attr_accessor :title, :address, :rent, :url

  @@all = []

  def initialize
    @@all << self
  end

  def self.all
    @@all
  end

  def self.create_csv
    csv_string = CSV.generate do |csv|
      csv << ["Title", "Address", "Rent", "Url"]
      self.all.each do |rental|
        csv << [rental.title, rental.address, rental.rent, rental.url]
      end
    end
  end

end
