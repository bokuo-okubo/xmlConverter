require './src/FileHandler.rb'
require './src/converter.rb'
require 'pp'
require 'json'
require 'csv'

class XMLConverter
  include FileHandler
  @@load_file_path
  @@load_file_list

  def load_files_path
    @@load_file_path ||= Dir.glob('./input_files/*.xml')
  end

  def load_files
    @@load_file_list ||= @@load_file_path.map { |path| read_file path }
  end

  def run
    load_files_path
    converter = Converter.new
    load_files.map { |xml_str| converter.xml_to_page_obj(xml_str) }
  end
end
csv_base = XMLConverter.new.run.map{ |hash| hash.map { |k,v| [k, v] } }
time = Time.now.strftime "%Y%m%d%H%M%S"
CSV.open(time + ".csv", "wb") { |csv| csv_base.each {|row| csv << row.flatten } }