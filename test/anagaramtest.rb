require 'rubygems'
require 'test/unit'
require 'models/anagram'

class AnagramTest  < Test::Unit::TestCase

    def test_sorting_into_word_length
        data = ["one", "two", "three", "four"]
        expected = {3 => ["one", "two"],  4 => ["four"], 5 => ["three"] }
        result = Anagram.sort_by_word_length(data)
        assert_equal(expected, result, "Result of word length sorting  should match expectation")
    end

end