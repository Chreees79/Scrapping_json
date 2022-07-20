require 'bundler'
Bundler.require

$:.unshift File.expand_path('./../lib/app', __FILE__)
require 'scrapper'

scrap_town = Scrapper.new 

#scrap_town.save_as_json
#scrap_town.save_as_csv
scrap_town.save_as_spreadsheet
