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
    begin
      xml_obj = REXML::Document.new(xml_str).root
      id = xml_obj.attribute('id').value
    rescue => e
      { error: "can't create xml obj" }
    end

    begin
      template_type = xml_obj.elements['template'].text
      layout_info_attributes = xml_obj.elements['layout_info'].attributes
      { id: id, template: template_type, attributes: layout_info_attributes}
    rescue => e
      { error: e, id: id }
    end
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
end