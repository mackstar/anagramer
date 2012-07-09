require 'rubygems'
require 'test/unit'
require '../services/storage'

class StorageTest  < Test::Unit::TestCase

    def test_not_exists
        assert_equal(Storage.read("key"), false, "Key not existing should return false")
    end

    def test_read_write_and_delete
        hash = {"one" => [1, "one", "first"], "2" => "the number two"}
        Storage.write("numbers", hash)
        result = Storage.read("numbers")
        assert_equal(result, hash, "Should be able to read the number we have just saved")
        Storage.delete("numbers")
        assert_equal(Storage.read("numbers"), false, "Key not existing should return false")
    end

end