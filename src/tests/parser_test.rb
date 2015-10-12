#!/usr/bin/env ruby1.9.3

require 'minitest/autorun'
require './lib/parser'

class TestParserIskFormatter < MiniTest::Unit::TestCase
	def test_isk_printer_shows_2_decimals
		assert_equal "22.00 ISK", Parser::to_eve_price(22)
	end
end
