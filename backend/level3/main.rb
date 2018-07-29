require 'json'
require 'date'

file = File.read('data/input.json')
@data_hash = JSON.parse(file)

SKIP_DAY = 1
delivery_hash = { deliveries: [] }

# Methods
def distance(package)
  @data_hash['country_distance'][package['origin_country']][package['destination_country']]
end

def carrier(package)
  @data_hash['carriers'].find{|x| x['code'] == package['carrier']}
end

def oversea_delay(package, carrier)
  distance(package) / carrier['oversea_delay_threshold']
end

def delivery(package, carrier)
  shipping_date = Date.parse(package['shipping_date'])
  range_dates = shipping_date..(shipping_date + SKIP_DAY + carrier['delivery_promise'])

  skip_saturday = 0
  skip_sunday = 0
  range_dates.each do |date|
    skip_saturday = 1 if !carrier['saturday_deliveries'] && date.saturday?
    skip_sunday = 1 if date.sunday?
  end

  shipping_date + SKIP_DAY + skip_saturday + skip_sunday + carrier['delivery_promise']
end

# Start
@data_hash['packages'].map do |package|
  carrier = carrier(package)

  shipping_date = Date.parse(package['shipping_date'])

  oversea_delay = oversea_delay(package, carrier)

  expected_delivery = delivery(package, carrier) + oversea_delay
  
  delivery_hash[:deliveries] << { package_id: package['id'], expected_delivery: expected_delivery.to_s, overseay_delay: oversea_delay }
end

File.open('data/output.json', 'w') do |f|
  f.puts delivery_hash.to_json
end
