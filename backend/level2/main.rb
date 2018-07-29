require 'json'
require 'date'

file = File.read('data/input.json')
data_hash = JSON.parse(file)

SKIP_DAY = 1

delivery_hash = { deliveries: [] }
data_hash['packages'].map do |package|
  carrier = data_hash['carriers'].find{|x| x['code'] == package['carrier']}

  shipping_date = Date.parse(package['shipping_date'])

  # Je regarde durant la date de depart du colis à l'arrivée si il y a un samedi ou/et dimanche
  range_dates = shipping_date..(shipping_date + SKIP_DAY + carrier['delivery_promise'])
  
  skip_saturday = 0
  skip_sunday = 0
  range_dates.each do |date|
    skip_saturday = 1 if !carrier['saturday_deliveries'] && date.saturday?
    skip_sunday = 1 if date.sunday?
  end

  expected_delivery = shipping_date + SKIP_DAY + skip_saturday + skip_sunday + carrier['delivery_promise']
  
  delivery_hash[:deliveries] << { package_id: package['id'], expected_delivery: expected_delivery.to_s }
end

File.open('data/output.json', 'w') do |f|
  f.puts delivery_hash.to_json
end
