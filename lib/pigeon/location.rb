module Pigeon
    # 用来将原始数据格式化为YAML数据
    class Location
        # 把TXT数据结构化
        def self.reconstruct00
            @file = File.join(Application.settings.root, 'config', 'locations00.txt')
            @data = IO.readlines(@file)
            @prov = {}
            @data.each { |e|  
                # 安徽 安徽省 合肥 北纬31.52 东经117.17
                prov, prov_alias, city, latitude, longitude = e.split(" ")

                # 一个省有多个城市
                @prov[prov] ||= {}
                # 一个城市有经纬坐标两个值
                @prov[prov][city] = {
                    latitude: latitude.gsub("北纬", ""),
                    longitude: longitude.gsub("东经", "")
                }
            }
            File.open(File.join(Application.settings.root, 'config', 'locations00.yml'), 'w+'){|f|
                f << YAML.dump(@prov)
            }
        end

        def self.reconstruct01
            @file = File.join(Application.settings.root, 'config', 'locations01.txt')
            @data = IO.readlines(@file)
            @prov = {}
            @data.each { |e|  
                e.chomp!
                if e.include?("城市:")
                    # 城市:上海上海 经度:121.48 纬度:31.22 
                    name, longitude, latitude = e.split(' ')
                    name = name.split(':')[1]
                    longitude = longitude.split(':')[1]
                    latitude = latitude.split(':')[1]
                    puts "Name:#{name}"
                    data = Search.instance.search(name)
                    if !data.blank? and (prov = data[:province])
                        city = name[prov.size..-1]
                        @prov[prov] ||= {}
                        @prov[prov][city] = {
                            latitude: latitude,
                            longitude: longitude
                        }
                    end
                end
            }
            File.open(File.join(Application.settings.root, 'config', 'locations01.yml'), 'w+'){|f|
                f << YAML.dump(@prov)
            }
        end

        # 行政区划代码数据整理
        # 下载自国家统计局
        # http://www.stats.gov.cn/tjsj/tjbz/xzqhdm/201608/t20160809_1386477.html
        def self.xzqhdm
            @file = File.join(Application.settings.root, 'config', 'xzqhdm.txt')
            @data = IO.readlines(@file)
            @prov = {}
            # 记录上一次命中的省份
            prov = ''
            # 根据母本数据
            # 整理出省/县级市这样的二级结构
            # 省、直辖市、自治区
            # 市、自治州、地区、盟
            # 市、县、区、自治县、旗
            @data.each { |e|  
                e.chomp!
                if (e =~ /^(\d+)(\s{6})(\S+)[省,市]$/) || (e =~ /^(\d+)(\s{6})(\S+)$/)
                    code = $1
                    # 省或者直辖市或者自治区
                    prov = $3
                    @prov[prov] = {:xzqhdm => code}
                elsif (!e.include?("自治") and (e =~ /^(\d+)(\s{7})(\S+)[市,县]$/)) || (e =~ /^(\d+)(\s{7})(\S+)$/)
                    code = $1
                    # 地级市
                    city = $3
                    @prov[prov][city] = {:xzqhdm => code}
                elsif (!e.include?("自治") and (e =~ /^(\d+)(\s{8,})(\S+)[市,县,区]$/)) || (e =~ /^(\d+)(\s{8})(\S+)$/)
                    code = $1
                    # 县级市或者区或者自治县
                    district = $3
                    @prov[prov][district] = {:xzqhdm => code}
                else
                    puts "Error:#{e}"
                end
            }
            File.open(File.join(Application.settings.root, 'config', 'xzqhdm.yml'), 'w+'){|f|
                f << YAML.dump(@prov)
            }
        end
    end
end