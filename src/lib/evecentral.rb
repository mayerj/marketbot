require 'nokogiri'

class EveCentral
	ApiEndpoint = "api.eve-central.com"

	class QuickLookCache
		def initialize
			@endpoints = {}
			@timestamps = {}
		end

		def get_from_cache(urn)
			last_get = @timestamps[urn]

			if last_get.nil?
				return get(urn)
			elsif (Time.now.getutc - last_get) > ((1000 * 60) * 5)
				return get(urn)
			else
				return @endpoints[urn]
			end
		end

		def get(urn)
			result = Net::HTTP.get(ApiEndpoint, urn)
			@endpoints[urn] = result
			@timestamps[urn] = Time.now.getutc
			result
		end
	end

	class QuickLookEndpoint
		def initialize(cache, systemId="")
			@cache = cache
			@systemId = systemId
		end

		def get_by_region_jita(type_id)
			result = @cache.get_from_cache("/api/quicklook?regionlimit=10000002&typeid=#{type_id}")

			QuickLook.new result
		end

		def get_by_system(type_id)
			result = @cache.get_from_cache("/api/quicklook?usesystem=#{@systemId}&typeid=#{type_id}")

			QuickLook.new result
		end
	end

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
