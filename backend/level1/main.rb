require 'json'
require 'date'

file = File.read('data/input.json')
data_hash = JSON.parse(file)

SKIP_DAY = 1

delivery_hash = { deliveries: [] }
data_hash['packages'].map do |package|
  delivery_promise = data_hash['carriers'].find{|x| x['code'] == package['carrier']}['delivery_promise']

  shipping_date = Date.parse(package['shipping_date'])
  expected_delivery = shipping_date + SKIP_DAY + delivery_promise
  delivery_hash[:deliveries] << { package_id: package['id'], expected_delivery: expected_delivery.to_s }
end

File.open('data/output.json', 'w') do |f|
  f.puts delivery_hash.to_json
end
