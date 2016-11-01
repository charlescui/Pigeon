require 'singleton'

require "pigeon/version"
require "pigeon/search"
require "pigeon/location"

require 'byebug'	
require "yaml"
require 'active_support/core_ext/object/blank'

Encoding.default_external="UTF-8"

module Pigeon
    # 单个分词最大长度
    # 内蒙古有个城市名称在市里面最长，也是这个长度
    # 长过这个长度就不认为是一个目标词语了
    MAXLENG = "克孜勒苏柯尔克孜自治州".length
    MAXREAD = 100

    # Your code goes here...
    def self.data
        @data ||= File.join(File.dirname(__FILE__), '..', 'data')
    end
end
