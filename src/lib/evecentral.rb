require 'nokogiri'

class EveCentral

	class QuickLook
		def initialize(xml_string)
			@xml_doc = Nokogiri::XML(xml_string)
		end

		def get_lowest_price()
			r = @xml_doc.xpath("//evec_api/quicklook/sell_orders/order")

			prices = []
			r.each do |x|
				prices.push(x.xpath("./price").first.content.to_f)
			end

			prices.sort!
			prices[0]
		end
	end

end
