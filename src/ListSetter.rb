require './FileHandler.rb'

module ListSetter
  include FileHandler

  def to_curl_list
    @@load_curl_list ||= load_curl_list.map { |path| read_file path }
  end

  #########################
  #### private methods ####
  #########################
  private 
  def load_curl_list
    @to_curl_list ||= load_files_paths('./curl_lists' , '*.xml')
  end

  def load_files_paths(to_load_dir, ext)
    Dir.glob("./#{to_load_dir}/#{ext}")
  end
end