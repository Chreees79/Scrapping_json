require 'nokogiri'
require 'open-uri'
require 'json'
require 'csv'
require 'google_drive'
class Scrapper 
attr_accessor :final_array

  def get_townhall_email(townhall_url)
    page = Nokogiri::HTML(URI.open(townhall_url))
    page.xpath('/html/body/div[1]/main/section[2]/div/table/tbody/tr[4]/td[2]').text
  end

# ---------------------------  extract emails of the townhall --------------------------------------------------

  def get_townhall_urls
    page = Nokogiri::HTML(URI.open('http://annuaire-des-mairies.com/val-d-oise.html'))
    list_of_urls = []
    page.xpath('//a[contains(@class, "lientxt")]').each {|town| list_of_urls.push(town['href'])}

    return list_of_urls
  end

# ---------------------------  extract names of the townhall  ---------------------------------

  def get_townhall_name
    page = Nokogiri::HTML(URI.open('http://annuaire-des-mairies.com/val-d-oise.html'))
    list_of_towns = []
    page.xpath('//a[contains(@class, "lientxt")]').each {|town| list_of_towns.push(town.text)}
    return list_of_towns
  end

# --------------------------- build hash name / url  -----------------------------------------

  def initialize
    list_of_towns = get_townhall_name
    list_of_urls = get_townhall_urls
    @final_array = []
    @final_array = list_of_towns.zip(list_of_urls).map { |town, url| {town => get_townhall_email("http://annuaire-des-mairies.com/#{url}")} }
  end

  def save_as_json
    File.open("db/email.json", "w") do |f| 
      f.write(JSON.pretty_generate(@final_array))
    end
  end

  def save_as_spreadsheet
    session = GoogleDrive::Session.from_config("config.json")
    ws = session.create_spreadsheet("Mairies et emails du Val d'Oise").worksheets[0]
    number_rows = @final_array.size
    number_col = 2
    (1..number_rows).each do |row|
      ws[row, 1] = @final_array[row-1].keys[0]
      ws[row, 2] = @final_array[row-1].values[0]
      end
      ws.save
    (1..number_rows).each do |row|
      (1..2).each do |col|
        p ws[row, col] 
      end
    end
  end

  def save_as_csv
    CSV.open("db/email.csv", "w") do |csv|
      @final_array.each do |element|
      csv << element.to_a[0]
      end
    end
  end
end

