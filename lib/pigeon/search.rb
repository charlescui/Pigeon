module Pigeon
    class Search
        include Singleton

        def initialize
            @file = File.join(Pigeon.data, 'locations.yml')
            File.open(@file, 'r'){|f| @prov = YAML.load(f)}

            @file = File.join(Pigeon.data, 'xzqhdm.yml')
            File.open(@file, 'r'){|f| @xzqhdm = YAML.load(f)}
        end

        # Search.instance.search "我在浙江省杭州市西湖区"
        # => {:latitude=>"120.19", :longitude=>"30.26", :province=>"浙江", :city=>"杭州", :accuracy=>true, :xzqhdm=>"330100"}
        # 返回升级行政区划代码，用于热力图展示
        def search(str)
            co = self.coordinate(str)
            # 补全行政区划代码
            if !co.blank? and co[:province]
                co[:xzqhdm] = self.xzqhdm(co[:province], co[:city])
            end
            co
        end

        # 从一个字符串中，找到跟字典库中匹配的关键字
        # 目的是找到省份，城市，以及坐标

        # Search.instance.coordinate "我在浙江省杭州市西湖区"
        # => {:latitude=>"120.19", :longitude=>"30.26", :province=>"浙江", :city=>"杭州", :accuracy=>true}
        # accuracy表示精准匹配
        # 当只能找到省，不能找到匹配市的数据的时候，accuracy是false
        def coordinate(str)
            prov, idx_p = self.scan(0, str, @prov)
            if prov.blank?
                return nil
            else
                city, idx_c = self.scan(idx_p, str, @prov[prov])
                if city.blank?
                    # 处理城市为空的情况
                    if @prov[prov][prov].blank?
                        # 如果不是直辖市
                        # 数据母本中没有该城市
                        # 则使用该省份的省会城市数据

                        # Search.instance.search "湖北省荆州市"
                        # => {:latitude=>"114.31", :longitude=>"30.52", :province=>"湖北", :city=>"武汉"}
                        city = @prov[prov].keys.first
                        if city.blank?
                            return {:province => prov}
                        else
                            return @prov[prov][city].update ({
                                :province => prov,
                                :city => city,
                                :accuracy => false
                            })
                        end
                    else
                        # 处理直辖市特殊情况
                        # 因为用户所在地是直辖市，一般只说：上海，不会说上海上海，或者上海市上海
                        # 比如from地址是：上海
                        # 那么在词库里面查找，省份是：上海，城市是：上海，这样的数据

                        # Search.instance.search "上海"
                        # => {:latitude=>"121.48", :longitude=>"31.22", :province=>"上海", :city=>"上海"}
                        return @prov[prov][prov].update ({
                            :province => prov,
                            :city => prov,
                            :accuracy => false
                        })
                    end
                else
                    return @prov[prov][city].update ({
                        :province => prov,
                        :city => city,
                        :accuracy => true
                    })
                end
            end
        end

        # 通过省市查询行政区划代码
        # 如果城市不传
        # 则返回省份的代码
        def xzqhdm(province, city=nil)
            if city.blank? and !@xzqhdm[province].blank?
                return @xzqhdm[province][:xzqhdm]
            end
            if !city.blank? and !@xzqhdm[province].blank?
                if !@xzqhdm[province][city].blank?
                    return @xzqhdm[province][city][:xzqhdm]
                else
                    return @xzqhdm[province][:xzqhdm]
                end
            end
            return nil
        end

        # 递归扫描字符串
        # 找到跟data的某个key一样的值
        # idx 本次查询的开始位置，从0开始
        # str 要分词的字符串
        # data Hash结构的母本数据
        def scan(idx, str, data={})
            if idx + 1 > str.length
                return nil
            end
            chars = str[idx..-1].split("")
            prefix = []
            # 根据Hash结构找到母本中有的KEY
            while (char = chars.shift)
                prefix << char
                concat = prefix.join('')
                if data[concat]
                    # 返回命中的文本以及该文本结尾的位置
                    # 为了继续该字符串的下一次下一个关键词查找
                    return [concat, idx+concat.size]
                end
            end
            scan(idx + 1, str, data)
        end
    end
end