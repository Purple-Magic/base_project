#!/usr/bin/env ruby

require 'open3'
require 'shellwords'

environment = ARGV.fetch(0, ENV.fetch('RAILS_ENV', 'production'))
required_keys = %w[MAIN_HOST DB_HOST POSTGRES_DB POSTGRES_PASSWORD POSTGRES_USER]

def capture_value(*command)
  stdout, stderr, status = Open3.capture3(*command)
  return stdout.strip if status.success?

  warn %(Error: Command failed: #{command.shelljoin})
  warn stdout unless stdout.strip.empty?
  warn stderr unless stderr.strip.empty?
  exit 1
end

def credential_value(environment, path)
  capture_value('dip', 'rails', 'credentials:fetch', "#{environment}.#{path}")
end

def terraform_value(environment, output)
  capture_value('terraform', '-chdir=terraform', 'workspace', 'select', environment)
  capture_value('terraform', '-chdir=terraform', 'output', '-raw', output)
end

values = {
  'MAIN_HOST' => ENV['MAIN_HOST'].to_s.strip,
  'DB_HOST' => ENV['DB_HOST'].to_s.strip,
  'POSTGRES_USER' => ENV['POSTGRES_USER'].to_s.strip,
  'POSTGRES_PASSWORD' => ENV['POSTGRES_PASSWORD'].to_s.strip,
  'POSTGRES_DB' => ENV['POSTGRES_DB'].to_s.strip
}

values['MAIN_HOST'] = terraform_value(environment, 'main_host_ip') if values['MAIN_HOST'].empty?
values['DB_HOST'] = credential_value(environment, 'database.host') if values['DB_HOST'].empty?
values['POSTGRES_USER'] = credential_value(environment, 'database.username') if values['POSTGRES_USER'].empty?
values['POSTGRES_PASSWORD'] = credential_value(environment, 'database.password') if values['POSTGRES_PASSWORD'].empty?
values['POSTGRES_DB'] = credential_value(environment, 'database.primary.name') if values['POSTGRES_DB'].empty?

missing = required_keys.select { |key| values[key].to_s.strip.empty? }

unless missing.empty?
  warn %(Error: Missing or empty values for #{missing.join(', ')} in "#{environment}" deployment configuration.)
  warn 'Expected database values in Rails credentials and MAIN_HOST from Terraform output or ENV.'
  exit 1
end

required_keys.each do |key|
  puts "#{key}=#{Shellwords.escape(values.fetch(key))}"
end
