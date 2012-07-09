require "json"

# Storage class which is mainly using static properties and methods
class Storage

  @@dir = File.dirname(File.dirname(__FILE__)) + "/data/"

  # Gets filepath key file should be found at
  def self.filepath key
    @@dir + key + ".json"
  end

  # Gets storage directory
  def self.dir
     @@dir
  end

  # Writes the data using the key and data
  def self.write key, data
    File.open(self.filepath(key), "w") do |f|
      f.write(data.to_json)
    end
  end

  # Deletes data by key
  def self.delete key
    if(key.class == Array)
      key.each {|k|  File.delete(self.filepath(k)) }
    else
      File.delete(self.filepath(key))
    end
  end

  # Reads the data by key
  def self.read key
    return false unless File.exist?(self.filepath(key))
    file = File.new(self.filepath(key), "r")
    string = ""
    while (line = file.gets)
        string << line
    end
    JSON.parse(string)
  end

end