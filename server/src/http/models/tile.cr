module AlexiServer
  module HttpAPI
    class Tile
      property year : Int32
      property day : Int32
      property tile_num : Int32

      raise "No root setup" unless ENV.has_key?("ALEXI_ROOT")
      @@root = ENV["ALEXI_ROOT"]

      def initialize(@year, @day, @tile_num)
      end

      def self.get_years_range
        years = [] of Int32
        raise "Wrong root setup" unless File.directory? @@root
        Dir.each @@root do |yyyy|
          year = yyyy.to_i?
          next unless year
          next if ((years.size == 2) && (year >= years[0]) && (year <= years[1]))
          has_day = false
          path = File.join(@@root, yyyy)
          Dir.each path do |ddd|
            day = ddd.to_i?
            next if day.nil?
            has_day = true
            break
          end
          next unless has_day
          if years.size == 0
            years << year << year
          else
            years[0] = year if year < years[0]
            years[1] = year if year > years[1]
          end
        end
        years
      end

      def self.get_days_in_year(year)
        yyyy = year.to_s
        days = [] of Int32
        path = File.join(@@root, yyyy)
        return days unless File.directory? path
        Dir.each path do |name|
          day = name.to_i?
          if day
            days << day unless Dir.empty?(path + "/" + name)
          end
        end
        days.sort
      end

      def self.get_tiles_in_day(year, day)
        yyyy = year.to_s
        tiles = [] of Int32
        ddd = day.to_s
        raise "wrong day parameter" unless (ddd.size <= 3)
        while ddd.size != 3
          ddd = "0#{ddd}"
        end
        path = File.join(@@root, yyyy, ddd)
        return tiles unless File.directory? path
        prefix = "FINAL_EDAY_#{yyyy}#{ddd}_T"
        suffix = ".tif"
        Dir.each path do |name|
          next unless (name.starts_with?(prefix) && name.ends_with?(suffix))
          tile = name[(prefix.size)...(-suffix.size)].to_i?
          tiles << tile if tile
        end
        tiles.sort
      end
    end
  end
end
