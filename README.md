# Pigeon

`鸽子`
在天空飞翔,了解大地的每一寸土壤.

根据输入的语句，找出省市信息，并从自带的地理位置母本库中给出经纬度坐标，从自带的行政区划代码库中给出行政区划代码。

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pigeon'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pigeon

## Usage

```ruby
Pigeon::Search.instance.search "我在浙江省杭州市西湖区"
# => {:latitude=>"30.26", :longitude=>"120.19", :province=>"浙江", :city=>"杭州", :accuracy=>true, :xzqhdm=>"330100"}
```

## TODO

- 丰富词库
- 增加街道一级数据
- 支持长文本分词
- 支持命令行管道方式处理

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/pigeon. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

