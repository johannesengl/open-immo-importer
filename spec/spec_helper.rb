# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
Dir[Rails.root.join('spec/support/**/*.rb')].each{ |f| require f }

# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

def seed_districts
  districts = [["Kreuzberg", "Mitte"], ["Mitte", "Mitte"], ["Moabit", "Mitte"], ["Hansaviertel", "Mitte"], ["Tiergarten", "Mitte"], ["Wedding", "Mitte"], ["Gesundbrunnen", "Mitte"], ["Friedrichshain", "Friedrichshain-Kreuzberg"], ["Prenzlauer Berg", "Pankow"], ["Weißensee", "Pankow"], ["Blankenburg", "Pankow"], ["Heinersdorf", "Pankow"], ["Karow", "Pankow"], ["Stadtrandsiedlung Malchow", "Pankow"], ["Pankow", "Pankow"], ["Blankenfelde", "Pankow"], ["Buch", "Pankow"], ["Französisch Buchholz", "Pankow"], ["Niederschönhausen", "Pankow"], ["Rosenthal", "Pankow"], ["Wilhelmsruh", "Pankow"], ["Charlottenburg", "Charlottenburg-Wilmersdorf"], ["Wilmersdorf", "Charlottenburg-Wilmersdorf"], ["Schmargendorf", "Charlottenburg-Wilmersdorf"], ["Grunewald", "Charlottenburg-Wilmersdorf"], ["Westend", "Charlottenburg-Wilmersdorf"], ["Charlottenburg-Nord", "Charlottenburg-Wilmersdorf"], ["Halensee", "Charlottenburg-Wilmersdorf"], ["Spandau", "Spandau"], ["Haselhorst", "Spandau"], ["Siemensstadt", "Spandau"], ["Staaken", "Spandau"], ["Gatow", "Spandau"], ["Kladow", "Spandau"], ["Hakenfelde", "Spandau"], ["Falkenhagener Feld", "Spandau"], ["Wilhelmstadt", "Spandau"], ["Steglitz", "Steglitz-Zehlendorf"], ["Lichterfelde", "Steglitz-Zehlendorf"], ["Lankwitz", "Steglitz-Zehlendorf"], ["Zehlendorf", "Steglitz-Zehlendorf"], ["Dahlem", "Steglitz-Zehlendorf"], ["Nikolassee", "Steglitz-Zehlendorf"], ["Wannsee", "Steglitz-Zehlendorf"], ["Schöneberg", "Tempelhof-Schöneberg"], ["Friedenau", "Tempelhof-Schöneberg"], ["Tempelhof", "Tempelhof-Schöneberg"], ["Mariendorf", "Tempelhof-Schöneberg"], ["Marienfelde", "Tempelhof-Schöneberg"], ["Lichtenrade", "Tempelhof-Schöneberg"], ["Neukölln", "Neukölln"], ["Britz", "Neukölln"], ["Buckow", "Neukölln"], ["Rudow", "Neukölln"], ["Gropiusstadt", "Neukölln"], ["Alt-Treptow", "Treptow-Köpenick"], ["Plänterwald", "Treptow-Köpenick"], ["Baumschulenweg", "Treptow-Köpenick"], ["Johannisthal", "Treptow-Köpenick"], ["Niederschöneweide", "Treptow-Köpenick"], ["Altglienicke", "Treptow-Köpenick"], ["Adlershof", "Treptow-Köpenick"], ["Bohnsdorf", "Treptow-Köpenick"], ["Oberschöneweide", "Treptow-Köpenick"], ["Köpenick", "Treptow-Köpenick"], ["Friedrichshagen", "Treptow-Köpenick"], ["Rahnsdorf", "Treptow-Köpenick"], ["Grünau", "Treptow-Köpenick"], ["Müggelheim", "Treptow-Köpenick"], ["Schmöckwitz", "Treptow-Köpenick"], ["Marzahn", "Marzahn-Hellersdorf"], ["Biesdorf", "Marzahn-Hellersdorf"], ["Kaulsdorf", "Marzahn-Hellersdorf"], ["Mahlsdorf", "Marzahn-Hellersdorf"], ["Hellersdorf", "Marzahn-Hellersdorf"], ["Friedrichsfelde", "Lichtenberg"], ["Karlshorst", "Lichtenberg"], ["Lichtenberg", "Lichtenberg"], ["Falkenberg", "Lichtenberg"], ["Malchow", "Lichtenberg"], ["Wartenberg", "Lichtenberg"], ["Neu-Hohenschönhausen", "Lichtenberg"], ["Alt-Hohenschönhausen", "Lichtenberg"], ["Fennpfuhl", "Lichtenberg"], ["Rummelsburg", "Lichtenberg"], ["Reinickendorf", "Reinickendorf"], ["Tegel", "Reinickendorf"], ["Konradshöhe", "Reinickendorf"], ["Heiligensee", "Reinickendorf"], ["Frohnau", "Reinickendorf"], ["Hermsdorf", "Reinickendorf"], ["Waidmannslust", "Reinickendorf"], ["Lübars", "Reinickendorf"], ["Wittenau", "Reinickendorf"], ["Märkisches Viertel", "Reinickendorf"], ["Borsigwalde", "Reinickendorf"], ["Mitte-Kreuzberg", "Friedrichshain-Kreuzberg"]]

  districts.each do |district|
    District.find_or_create_by(name: district[0], parent_district: ParentDistrict.find_or_create_by(name: district[1]))
  end
end
