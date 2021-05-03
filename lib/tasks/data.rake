puts "data.rake"

# from Savannah implementation

namespace :data do
  require 'open-uri'
  require 'csv'
  require 'json'


  task load_drains: :environment do
    puts 'Loading drains...'
    url = 'medford_drains.csv'
    csv_string = open(url).read
    drains = CSV.parse(csv_string, headers: true)
    puts "#{drains.size} Drains."

    total = 0
    drains.each_slice(1000) do |group|
      updated = 0
      created = 0
      group.each do |drain|
        thing_hash = {
          name: drain['type'],
          system_use_code: drain['type'],
          lat: drain['lat'],
          lng: drain['lon'],
        }

        # # Match any existing records, accounting for rounding errors:
        # thing = Thing
        #   .where('round(lat, 10) = ?', BigDecimal(thing_hash[:lat]).round(10))
        #   .where('round(lng, 10) = ?', BigDecimal(thing_hash[:lng]).round(10))
        #   .first
        # if thing
        #   thing.assign_attributes(thing_hash)
        #   if thing.changed?
        #     updated += 1
        #   end
        # else
        #   Thing.create(thing_hash)
        #   created += 1
        # end
        
        total += 1
      end

      print "updated/created: #{updated}/#{created} ... #{total}\n"
    end
  end
end
