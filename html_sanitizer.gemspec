Gem::Specification.new do |s|
  s.name        = 'html_sanitizer'
  s.version     = '0.0.1'
  s.date        = '2012-08-04'
  s.summary     = "Caching HTML Sanitizer"
  s.description = "A HTML sanitizer that caches sanitized markup in an HStore field"
  s.authors     = ["Adam Trilling"]
  s.email       = 'adamtrilling@gmail.com'
  s.files       = ["lib/html_sanitizer.rb"]
  s.homepage    =
    'http://github.com/adamtrilling/html_sanitizer'

  s.add_runtime_dependency 'activerecord', '>= 4.0.0.beta'
  s.add_runtime_dependency 'sanitize', '>= 2.0.3'
  s.add_runtime_dependency 'nokogiri', '1.5.5'
end