#!/usr/bin/env ruby1.9.3

require 'minitest/autorun'
require './lib/evefit'
require './lib/evedb'
require 'ruby-prof'

class TestEveFitQuantityParser < MiniTest::Unit::TestCase
	def test_evefit_quantity_parser_get_quantity
		evedb = EveDb.new "../data/typeIDs.cache" 
		fit = EveFit.new evedb, "Nestor x2"
		
		assert_equal 2, fit.quantity[fit.items[0]]
	end

	def test_evefit_astero
		evedb = EveDb.new "../data/typeIDs.cache" 

#		RubyProf.start
astero = <<SQL
[Astero, Astero]
Damage Control II
Drone Damage Amplifier II
Energized Adaptive Nano Membrane II
Small Ancillary Armor Repairer

Warp Scrambler II
Warp Scrambler II
Relic Analyzer I
5MN Y-T8 Compact Microwarpdrive

Covert Ops Cloaking Device II
Core Probe Launcher I

Small Anti-Explosive Pump I
Small Auxiliary Nano Pump II
Small Auxiliary Nano Pump II


Hobgoblin II x10
Hornet EC-300 x5

Sisters Core Scanner Probe x8
Nanite Repair Paste x91
SQL

		fit = EveFit.new evedb, astero

#		result = RubyProf.stop
#printer = RubyProf::GraphPrinter.new(result)
#printer.print(STDOUT, {})

		assert_equal false, fit.has_unknown_items
		assert_equal 16, fit.items.count
	end

	def test_fits_work_with_ammo
ship = <<SQL
[Federation Navy Comet, Rhaul Klindal's Federation Navy Comet]
Magnetic Field Stabilizer II
Magnetic Field Stabilizer II
Nanofiber Internal Structure II
Nanite Repair Paste

5MN Y-T8 Compact Microwarpdrive
Warp Disruptor II
X5 Prototype Engine Enervator

150mm Railgun II,Caldari Navy Antimatter Charge S
150mm Railgun II,Caldari Navy Antimatter Charge S

Small Anti-Explosive Pump I
Small Transverse Bulkhead I
Small Transverse Bulkhead I


Warrior II x1
Warrior II x2
SQL

		evedb = EveDb.new "../data/typeIDs.cache" 
		fit = EveFit.new evedb, ship
		assert_equal false, fit.has_unknown_items
	end

	def test_exotic_dancers
		evedb = EveDb.new "../data/typeIDs.cache" 
		fit = EveFit.new evedb, "Exotic Dancers, Female"
		assert_equal false, fit.has_unknown_items
		assert_equal 1, fit.items.count
	end

end
