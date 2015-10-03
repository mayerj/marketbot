#!/usr/bin/env ruby1.9.3

require './lib/evecentral'

xml_string = File.open('temp.xml', 'rb') { |file| file.read }

ql = EveCentral::QuickLook.new xml_string

print ql.get_lowest_price()
