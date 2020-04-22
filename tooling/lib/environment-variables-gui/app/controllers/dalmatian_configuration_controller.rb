require 'yaml'

class DalmatianConfiguration
  def initialize
    @config = YAML.load(File.read("dalmatian-config/dalmatian.yml"))
  end

  def config
    @config
  end

  def infrastructures
    config['infrastructures']
  end
end
