require 'singleton'

require "pigeon/version"
require "pigeon/search"
require "pigeon/location"

require "yaml"
require 'active_support/core_ext/object/blank'

module Pigeon
  # Your code goes here...
  def self.data
  	@data ||= File.join(File.dirname(__FILE__), '..', 'data')
  end
end
