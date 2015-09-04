require 'rexml/document'
require 'base64'
require 'fileutils'
require 'thwait'
require 'yaml'
require 'pp'

Conf = Struct.new(:user, :pass)

class Converter
  ResourceObject = Struct.new(:filename, :encodes)
  PageObject = Struct.new(:layout_info_attributes, :resources)

  def convert_to_obj(rexml_doc, attribute, match_path)
    resources = REXML::XPath.match(rexml_doc, match_path).map do |node|
      filename = node.attribute(attribute).value
      elements = node.elements.map{ |data| data.text.gsub(/\<\!\[CDATA\[/, "").gsub(/\]\]\>/, "") }
      Resource.new(filename, elements)
    end
  end

  def xml_to_page_obj(xml_str)
    xml_obj = REXML::Document.new(xml_str).root
    template_type = xml_obj.elements['template'].text
    layout_info_attributes = xml_obj.elements['layout_info'].attributes
    {template: template_type, attributes: layout_info_attributes}
  end

  def xml_to_resource_obj(xml_obj)
    filename = xml_obj.attribute('source').value
    encodes = xml_obj.elements.map { |data| data.text.gsub(/\<\!\[CDATA\[/, "").gsub(/\]\]\>/, "") }
    build_resource_object(filename, encodes)
  end

  def build_resource_object(*parms)
    ResourceObject.new(*parms)
  end

  def build_page_object(resources)
    PageObject.new(resources)
  end

  def decode_base64(encoded)
    Base64.decode64 encoded
  end
end ## class


####################################################################################################
def read_yaml(str)
  YAML.load(str)
end

def set_config(file_path)
  yml = read_file(file_path)
  conf = read_yaml(yml)
  user = conf[:user]
  pass = conf[:pass]
  Conf.new(user, pass)
end


def run(input_file_path)
  str_file = read_file(input_file_path)
  doc = REXML::Document.new(str_file)
  match_path = 'contents/resources/resource'
  attribute = 'source'
  objs = convert_to_obj(doc, attribute, match_path)
  str = objs.first.encodes.join

  name_bin_ary = objs.map do |resource|
    output_file_name = resource.filename
    encoded = resource.encodes.join
    binary = decode_base64 encoded
    [binary, output_file_name]
  end

  ext = File.extname input_file_path
  dir_name = File.basename(input_file_path, ext)
  Dir.mkdir(dir_name)
  name_bin_ary.each do |binary, output_file_name|
    path = "#{dir_name}/#{output_file_name}"
    write_file(binary, path)
  end
end


# def logging(msg)
#   puts msg
#   begin
#     File.open("./error.log", "a") { |f| f.write msg.to_s + "\n" }
#     true
#   rescue => e
#     puts e
#     false
#   end
# end

def curl(uri, save_path, user: nil, pass: nil)
  ary = uri.to_s.split("/")
  save_file_name = ary[-2].to_s + "-" + ary[-1].to_s
  begin
    unless :user.nil? || :pass.nil?
      `curl --anyauth --user #{user}:#{pass} #{ uri } -o #{ save_path + save_file_name } >/dev/null 2>&1`
    else
      `curl #{ uri } -o #{ save_path + save_file_name } >/dev/null 2>&1`
    end
  rescue => e
    logging e
  end
end

## return String xml
# def read_file(file_path)
#   begin
#     File.open(file_path) { |f| f.read }
#   rescue => e
#     logging e
#   end
# end

# def write_file(str, file_path, mode: 'w')
#   begin
#     File.open(file_path, mode) { |f| f.write str}
#   rescue => e
#     logging e
#   end
# end


Resource = Struct.new(:filename, :encodes,)
def convert_to_obj(rexml_doc, attribute, match_path)
  resources = REXML::XPath.match(rexml_doc, match_path).map do |node|
    filename = node.attribute(attribute).value
    elements = node.elements.map{ |data| data.text.gsub(/\<\!\[CDATA\[/, "").gsub(/\]\]\>/, "") }
    Resource.new(filename, elements)
  end
end

def decode_base64(encoded)
  Base64.decode64 encoded
end



# file_list = <<LIST
# LIST

# threads = []
# file_list.split("\n").each { |file_name| threads << Thread.new { run(file_name) }}
# puts 'work in multi-thread'
# ThreadsWait.all_waits(*threads) { |th| printf "." }
# puts "\ndone!"
