#!/usr/bin/env ruby1.9.3

require 'minitest/autorun'
require './lib/command'

class TestSimplePriceCommand < MiniTest::Unit::TestCase
	def test_that_command_is_price
		command = Command.new "price Nestor"
		assert_equal "price", command.command
	end

	def test_that_argument_is_nestor
		command = Command.new "price Nestor"
		assert_equal ["Nestor"], command.arguments
	end

	def test_that_argument_is_longer
		command = Command.new "price Mid-Grade Crystal"
		assert_equal ["Mid-Grade Crystal"], command.arguments
	end
	
	def test_multi_line_command
		command = Command.new "price Mid-Grade Crystal\r\nfoo"
		assert_equal ["Mid-Grade Crystal","foo"], command.arguments
		assert_equal "foo", command.get_argument(1,0)
	end
	
	def test_command_single_args
		command = Command.new "pricesystem amarr Nestor"
		assert_equal ["amarr Nestor"], command.arguments
		assert_equal "amarr", command.get_argument(0, 0)

		command = Command.new "pricesystem \"old mans star\" Nestor"
		assert_equal ["\"old mans star\" Nestor"], command.arguments
		assert_equal "old mans star", command.get_argument(0, 0)
		
		command = Command.new "pricesystem \"old mans star\" \"Mid-Grade Crystals\""
		assert_equal ["\"old mans star\" \"Mid-Grade Crystals\""], command.arguments
		assert_equal "old mans star", command.get_argument(0, 0)
		assert_equal "Mid-Grade Crystals", command.get_argument(0, 1)
	end
	
	def test_command_single_args_get_substrings
		command = Command.new "pricesystem \"old mans star\" test long strings"
		assert_equal "test long strings", command.get_rest(0, 0)
		
		command = Command.new "pricesystem jita test long strings"
		assert_equal "test long strings", command.get_rest(0, 0)
	end
end
