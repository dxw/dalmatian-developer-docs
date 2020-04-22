paths = %w[config/initializers/*.rb app/**/*.rb].map(&:freeze).freeze
paths.each do |path|
 Dir[path].each do |file|
   next if file.include?('initializers/autoloader') # skip me
   require_relative "../../#{file}"
 end
end
