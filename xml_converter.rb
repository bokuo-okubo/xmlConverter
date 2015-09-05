require 'pp'
require 'json'
require 'csv'

require './src/FileHandler.rb'
require './src/Converter.rb'
require './src/Thread.rb'


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
    threads = []
    load_files.map do |xml_str|
      Thread.max_concurrent= 10
      threads << Thread.new do
        printf '.'
        converter.xml_to_page_obj(xml_str)
      end
    end
  end

  def serial_run
    load_files_path
    converter = Converter.new
    base_ratio = load_files.length 
    register = 0
    counter = 0
    time = Time.now.strftime "%Y%m%d"
    file = File.open(time + ".csv", "a" )
    begin
      load_files.each do |xml_str|
        file.write("#{counter}\t")
        if counter%1000 == 0
          register = counter
          puts "#{ (register.to_f/base_ratio.to_f) * 100 } %"
        end
        hash = converter.xml_to_page_obj(xml_str)

        id = hash[:id] ? hash[:id] : 'cannot pick id'
        error = hash[:error] ? hash[:error] : 0
        template = hash[:template]
        attributes = hash[:attributes]
        attributes = attributes.map { |hash| hash.to_a.join(".") }.join(",") if attributes
        file.write( [id, error, template, attributes ].join("\t") + "\n" )
        counter += 1
      end            
    ensure
      file.close
    end
  end
end

container = XMLConverter.new.serial_run
