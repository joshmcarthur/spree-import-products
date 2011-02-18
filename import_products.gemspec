Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'import_products'
  s.version     = '1.0.0'
  s.summary     = "spree_import_products ... imports products. From a CSV file via Spree's Admin interface" 
  #s.description = 'Add (optional) gem description here'
  s.required_ruby_version = '>= 1.8.7'

  s.author            = 'Chetan Mittal'
  s.email             = 'chetan.mittal@niamtech.com'
  s.homepage          = 'http://chetanmittal.heroku.com'

  s.files        = Dir['CHANGELOG', 'README.md', 'LICENSE', 'lib/**/*', 'app/**/*']
  s.require_path = 'lib'
  s.requirements << 'none'

  s.has_rdoc = true

  s.add_dependency('spree_core', '>= 0.30.1')
  s.add_dependency('fastercsv')
end
