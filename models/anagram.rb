require "uuid"
require "services/storage"
require "date"

# This class contains the main business logic for anigrams, sessions
# and storage of them, it depends on session and the storage service.
class Anagram

  # Initializer
  def initialize(session)
      @session = session
      @session[:key] ||= UUID.new.generate
      @session[:date] ||= Time.now.strftime("%y-%m-%d")
  end

  # Sorts word array by words length producing a hash
  def self.sort_by_word_length words
    lists = {}
    words.each do |word|
      key = word.strip.length
      if lists[key].nil?
         lists[key] = [word.strip]
      else
        lists[key] << word.strip
      end
    end
    lists
  end

  # @TODO DRY this up as is the same as above method
  def self.create_anagram_hash words
    lists = {}
    words.each do |word|
      key = word.chars.sort.to_s
      if lists[key].nil?
         lists[key] = [word]
       else
         lists[key] << word
       end
    end
    lists
  end
  
  # Initial uploading method which calls methods to get
  def upload params
    Storage.delete get_session_keys
    words = params['file'][:tempfile].readlines
    words_sorted_by_length = Anagram.sort_by_word_length words
    words_sorted_by_length.each_pair do |word_length, words|
      data_to_store = Anagram.create_anagram_hash words
      Storage.write get_key_for_word_length(word_length), data_to_store
    end
    @session[:uploaded] = true
  end
  
  # Creates the storage key depending on word length
  def get_key_for_word_length word_length
    @session[:date] + "_" + @session[:key] + "_word_file_" + word_length.to_s
  end

  # Creates the storage key name for results
  def get_key_for_results
    @session[:date] + "_" + @session[:key] + "_results"
  end

  # Gets all the storage key names for current stored data
  def get_session_keys
    keys = []
    base = @session[:date] + "_" + @session[:key]
    Dir.foreach(Storage.dir) do |file|
      keys << file.gsub(/\.json/, "") if /^#{base}/.match(file)
    end
    keys
  end

  # Gets all of the old sessions storage keys from storage data
  def self.get_old_sessions date=nil
    date (Date.today-2).strftime('%Y-%m-%d') if date.nil?
    Dir.foreach(Storage.dir) do |file|
      keys << file.gsub(/\.json/, "") if /^#{date}/.match(file)
    end
    keys
  end

  # Deletes storage keys
  def self.old_sessions 
    keys = Anagram.get_old_sessions
    Storage.delete keys
  end

  # Gets results
  def results
    Storage.read(get_key_for_results)
  end

  # Point of entry when guessing a word
  def guess word
    key = get_key_for_word_length word.strip.length
    word_lists = Storage.read(key)
    result = (word_lists == false || word_lists[word.chars.sort.to_s].nil?)? false : word_lists[word.chars.sort.to_s]
    update_results word, result
    result
  end

  # Upload results to include latest guess
  def update_results word, result
    result_record = results
    result_record = [] unless result_record
    result_record << {:word => word, :matches => result }
    Storage.write get_key_for_results, result_record
  end
end