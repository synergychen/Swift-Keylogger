module Helpers
  module Parser
    TIMESTAMP_PATTERN = /[\d]+:[\d]+:[\d]+.*[A|P]M/
    IGNORE_KEY_PATTERN = /[\\ESCAPE]/

    def read_screen_time_file(data_dir, date_str)
      File.open("#{data_dir}/App/#{date_str}/Time Stamps of Apps")
    end

    def read_keylog_file(data_dir, date_str, app_name)
      File.open("#{data_dir}/Key/#{date_str}/#{app_name}")
    end

    def parse_app_name(str)
      str.split(/\t/).last
    end

    def parse_timestamp_str(str)
      matched = str.match(TIMESTAMP_PATTERN)
      return unless matched
      matched[0]
    end

    def parse_timestamp(time_str)
      hr, min, sec, sep = time_str.split(/[:| ]/)
      hr_offset = sep == 'AM' ? 0 : 12
      hr = hr.to_i % 12 + hr_offset
      min = min.to_i
      sec = sec.to_i
      [hr, min, sec]
    end

    def time_to_sec(hr, min, sec)
      ((hr * 60 + min) * 60) + sec
    end

    def reformat_date_str(date_dir_str)
      day, month, year = date_dir_str.split('-')
      "#{year}#{month.to_s.rjust(2, '0')}#{day.to_s.rjust(2, '0')}"
    end

    def time_key(hr, min)
      "#{hr.to_s.rjust(2, '0')}:#{min.to_s.rjust(2, '0')}"
    end

    def default_usage_hash
      hash = {}
      (0..23).each do |hr|
        (0..59).step(10).each do |min|
          key = time_key(hr, min)
          hash[key] = 0
        end
      end
      hash
    end
  end
end
