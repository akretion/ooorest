Dir.glob("#{Rails.root}/app/models/ooor/*.rb").sort.each { |file| require_dependency file }
