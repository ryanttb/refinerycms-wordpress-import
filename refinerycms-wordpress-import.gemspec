# Provide a simple gemspec so you can easily use your enginex
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.platform          = Gem::Platform::RUBY
  s.name        = "refinerycms-wordpress-import"
  s.summary     = "Import WordPress XML dumps into refinerycms(-blog)."
  s.description = "This gem imports a WordPress XML dump into refinerycms (Page, User) and refinerycms-blog (BlogPost, BlogCategory, Tag, BlogComment)"
  s.version     = "0.4.1b"
  s.date        = "2012-06-18"

  s.authors     = ['Marc Remolt', 'Marc Lee']
  s.email       = 'marc.remolt@googlemail.com'
  s.homepage    = 'https://github.com/mremolt/refinerycms-wordpress-import'

  s.add_dependency 'refinerycms-core', '~> 2.1.5'
  s.add_dependency 'refinerycms-blog', '~> 2.1.0'
  s.add_dependency 'nokogiri', '~> 1.6.6'

  s.files = Dir["{app,lib,config}/**/*"] + ["MIT-LICENSE", "Rakefile", "Gemfile", "README.rdoc"]
end
