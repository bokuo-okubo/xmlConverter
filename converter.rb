require 'rexml/document'
require 'base64'
require 'fileutils'
require 'thwait'
require 'pp'


USER = '4d'
PASS = '4d'

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

def logging(msg)
  puts msg
  begin
    File.open("./error.log", "a") { |f| f.write msg.to_s + "\n" }
    true
  rescue => e
    puts e
    false
  end
end

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
def read_file(file_path)
  begin
    File.open(file_path) { |f| f.read }
  rescue => e
    logging e
  end
end

def write_file(str, file_path, mode: 'w')
  begin
    File.open(file_path, mode) { |f| f.write str}
  rescue => e
    logging e
  end
end


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



file_list = <<LIST
L1-LD14S201M02U03L1R07.xml
L1-LD14S205M03U08L1R07.xml
L1-LD15S604M02U06L1R09.xml
L1-LK14S201J01U06L1R02.xml
L1-LK14S201J01U08L1R01.xml
L1-LK14S201J01U08L1R02.xml
L1-LK14S201J01U08L1R03.xml
L1-LK14S201M01U13L1R01.xml
L1-LK14S205M01U08L1R02.xml
L1-LK15S604J01U02L1R01.xml
L1-LK15S604J01U04L1R03.xml
L1-LK15S604J01U04L1R07.xml
L1-LK15S604M01U01L1R01.xml
L1-LM14S103M01U12L1R07.xml
L1-LM14S201J01U02L1R02.xml
L1-LM14S201J01U04L1R02.xml
L1-LM14S201J01U06L1R03.xml
L1-LM14S201J01U06L1R05.xml
L1-LM14S201M01U13L1R03.xml
L1-LM14S201M01U13L1R05.xml
L1-LM14S201M01U14L1R03.xml
L1-LM14S201M02U14L1R08.xml
L1-LM14S202J02U09L1R02.xml
L1-LM14S202J02U14L1R01.xml
L1-LM14S203J02U05L1R03.xml
L1-LM14S204J01U02L1R02.xml
L1-LM14S205M01U03L1R02.xml
L1-LM15S104J01U06L1R02.xml
L1-LM15S604J01U01L1R02.xml
L1-LM15S604J01U01L1R07.xml
L1-LM15S604J01U04L1R04.xml
L1-LM15S604J01U06L1R07.xml
L1-LM15S604M01U01L1R02.xml
L2-LK15S104J01U12L2R01.xml
L2-LM14S201J01U02L2R01.xml
L2-LM14S201J01U06L2R03.xml
L2-LM14S201J01U08L2R01.xml
L2-LM14S201J01U09L2R05.xml
L2-LM14S201J02U12L2R01.xml
L2-LM14S201J04U10L2R02.xml
L2-LM14S201J04U10L2R04.xml
L2-LM14S201J04U11L2R02.xml
L2-LM14S204J04U09L2R02.xml
L2-LM15S604J01U04L2R05.xml
L2-LM15S604M01U01L2R08.xml
L2-LM15S605J01U06L2R09.xml
L2-LM15S606J02U05L2R08.xml
L3-LK14S201J01U06L3R02.xml
L3-LM14S201J01U02L3R01.xml
L3-LM14S205M01U03L3R01.xml
L3-LM15S205J01U01L3R01.xml
L3-LM15S604J01U04L3R03.xml
L3-LM15S604J01U05L3R08.xml
L3-LM15S604S01U02L3R09.xml
L3-LM15S605J02U04L3R01.xml
LIST

threads = []
file_list.split("\n").each { |file_name| threads << Thread.new { run(file_name) }}
puts 'work in multi-thread'
ThreadsWait.all_waits(*threads) { |th| printf "." }
puts "\ndone!"
