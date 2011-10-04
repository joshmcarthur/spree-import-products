Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'import_products'
  s.version     = '1.0.1'
  s.summary     = "spree_import_products ... imports products. From a CSV file via Spree's Admin interface" 
  #s.description = 'Add (optional) gem description here'
  s.required_ruby_version = '>= 1.8.7'

  s.author            = 'Josh McArthur'
  s.email             = 'josh@3months.com'
  s.homepage          = 'http://www.3months.com'

  s.files        = Dir['CHANGELOG', 'README.md', 'LICENSE', 'lib/**/*', 'app/**/*']
  s.require_path = 'lib'
  s.requirements << 'none'


  s.add_dependency('spree_core', '>= 0.30.1')
  s.add_dependency('delayed_job')
end
