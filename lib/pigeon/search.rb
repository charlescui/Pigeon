# encoding: UTF-8
require'cgi'

module Pigeon
    class Search
        include Singleton

        def initialize
            @file = File.join(Pigeon.data, 'locations.yml')
            File.open(@file, 'r'){|f| @prov = YAML.load(f)}

            # 生成城市检索表，不管省份不管重名
            # 用于直接查找一维的城市信息
            @city = {}
            @prov.each { |k, v|  
                if v.is_a? Hash
                    v.each { |kk, vv|  
                        @city[kk] = vv
                    }
                end
            }

            # 省市所有地区合并在一起的扁平索引
            # 用于查找所有省市信息
            @all = {}
            @prov.each { |k,v| @all[k] = {}}
            @city.each { |k,v| @all[k] = v}

            @file = File.join(Pigeon.data, 'xzqhdm.yml')
            File.open(@file, 'r'){|f| @xzqhdm = YAML.load(f)}
        end

        # Pigeon::Search.instance.search "我在浙江省杭州市西湖区"
        # => {:latitude=>"120.19", :longitude=>"30.26", :province=>"浙江", :city=>"杭州", :accuracy=>true, :xzqhdm=>"330100"}
        # 返回升级行政区划代码，用于热力图展示
        # Pigeon::Search.instance.search("我在浙江省杭州市西湖区，这里是一个美丽的地方，环境跟黑龙江省的一个冰雪城市哈尔滨相比，温暖很多"){|e| puts e}
        # {:latitude=>"30.26", :longitude=>"120.19", :province=>"浙江", :city=>"杭州", :accuracy=>true, :idx=>7}
        # {:latitude=>"45.75", :longitude=>"126.63", :province=>"黑龙江", :city=>"哈尔滨", :accuracy=>true, :idx=>40}
        def search(str, &blk)
            co = self.coordinate(str, &blk)
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
        def coordinate(str, idx=0, &blk)
            prov, idx_p = self.scan(idx, str, @prov)
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

                        # Search.instance.coordinate "湖北省荆州市"
                        # => {:latitude=>"114.31", :longitude=>"30.52", :province=>"湖北", :city=>"武汉"}
                        city = @prov[prov].keys.first
                        if city.blank?
                            rlt = {
                                :province => prov,
                                :idx => idx_p
                            }
                        else
                            rlt = @prov[prov][city].update ({
                                :province => prov,
                                :city => city,
                                :accuracy => false,
                                :idx => idx_p
                            })
                        end
                    else
                        # 处理直辖市特殊情况
                        # 因为用户所在地是直辖市，一般只说：上海，不会说上海上海，或者上海市上海
                        # 比如from地址是：上海
                        # 那么在词库里面查找，省份是：上海，城市是：上海，这样的数据

                        # Search.instance.coordinate "上海"
                        # => {:latitude=>"121.48", :longitude=>"31.22", :province=>"上海", :city=>"上海"}
                        rlt = @prov[prov][prov].update ({
                            :province => prov,
                            :city => prov,
                            :accuracy => false,
                            :idx => idx_p
                        })
                    end
                else
                    rlt = @prov[prov][city].update ({
                        :province => prov,
                        :city => city,
                        :accuracy => true,
                        :idx => idx_c
                    })
                end
                # 把结果返回给block处理
                yield rlt
                # 如果找到完整一组省市
                # 不确定剩下的字符串是否还有地理信息
                # 需要继续往后查找
                coordinate(str, rlt[:idx], &blk)
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
            if (idx + 1) > str.length
                return nil
            end
            begin
                chars = str[idx..-1].split("")
            rescue Exception => e
                # byebug
            end
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

        # 扁平递归查找
        # 只找省份或者城市
        # 找到一个算一个，没有前后、上下文关系
        def flat_scan(idx, content, data={}, &blk)
            item, idx_p = self.scan(idx, content, data)
            if item.blank?
                # 找不到则停止迭代查找
                # STOP
            else
                rlt = {:item => item}.update(data[item])
                yield rlt
                flat_scan(idx_p, content, data, &blk)
            end
        end

        # 流失扁平递归查找
        def flow_flat_scan(io, flag='all', &blk)
            # IO对象使用gets方法可以不截断
            # 如果使用read会导致字符串截断
            content = io.gets(Pigeon::MAXREAD).force_encoding('utf-8').encode(Encoding.find('UTF-8'), {invalid: :replace, undef: :replace, replace: ''})

            case flag
            when /all/i
                flat_scan(0, content, @all, &blk)
            when /city/i
                flat_scan(0, content, @city, &blk)
            when /prov.*/
                flat_scan(0, content, @prov, &blk)
            end

            if io.eof?
                # STOP
            else
                flow_flat_scan(io, flag, &blk)
            end
        end
    end
end