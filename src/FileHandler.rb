require 'yaml'

module FileHandler
  def read_yaml(str)
    YAML.load(str)
  end

  # TODO : use default logger class.
  # def logging(msg)
  #   write_file(msg, "../log/error.log", "a")
  #   msg
  # end

  ## return String xml
  def read_file(file_path)
    begin
      File.open(file_path) { |f| f.read }
    rescue => e
      #logging e
    end
  end

  def write_file(str, file_path, mode: 'w')
    begin
      File.open(file_path, mode) { |f| f.write str}
    rescue => e
      #logging e
    end
  end
end
