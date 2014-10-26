source 'https://rubygems.org'

if ENV.key?('PUPPET_VERSION')
  puppetversion = "#{ENV['PUPPET_VERSION']}"
else
  puppetversion = ['~> 3']
end

gem 'puppet', puppetversion, :require => false
gem 'puppet-lint'
gem 'rspec-puppet'
gem 'puppetlabs_spec_helper', '>= 0.1.0'
