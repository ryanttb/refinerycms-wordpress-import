source "http://rubygems.org"
ruby '2.1.5'

gemspec

gem 'refinerycms', '~> 2.1.5'
gem 'refinerycms-blog', '~> 2.1.0'
gem 'refinerycms-authentication', '~> 2.1.0'

# Refinery/rails should pull in the proper versions of these
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
end

gem 'jquery-rails'

group :development, :test do
  gem 'refinerycms-testing', '~> 2.1.5'
  gem 'factory_girl_rails'
  gem 'generator_spec'

  gem 'database_cleaner'
  gem 'guard-rspec'
  gem 'ffi'
  gem 'guard-bundler'
  gem 'fakeweb'
  gem 'libnotify' if  RUBY_PLATFORM =~ /linux/i

  require 'rbconfig'

  platforms :mswin, :mingw do
    gem 'win32console'
    gem 'rb-fchange', '~> 0.0.5'
    gem 'rb-notifu', '~> 0.0.4'
  end

  platforms :ruby do
    gem 'spork', '0.9.0.rc9'
    gem 'guard-spork'

    unless ENV['TRAVIS']
      if RbConfig::CONFIG['target_os'] =~ /darwin/i
        gem 'rb-fsevent', '>= 0.3.9'
        gem 'growl',      '~> 1.0.3'
      end
      if RbConfig::CONFIG['target_os'] =~ /linux/i
        gem 'rb-inotify', '>= 0.5.1'
        gem 'libnotify',  '~> 0.1.3'
      end
    end
  end
end

