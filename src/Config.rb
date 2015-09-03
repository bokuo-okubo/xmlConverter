require 'yaml'

class Config
  def self.[](key)
    conf[key]
  end

  def self.conf
    @@conf ||= YAML.load_file("../config/conf.yml")
  end
end
