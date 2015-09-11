require 'yaml'
require 'logger'

module FileHandler ## TODO : to change to Class methods in this class has
  
  def read_yaml(str)
    YAML.load(str)
  end

  # TODO : use default logger class.
  def logging(msg)
    @@logger ||= Logger.new('./logfile.log')
    @@logger.debug(msg)
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
end
