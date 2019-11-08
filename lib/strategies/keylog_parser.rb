require_relative '../helpers/parser'

class KeylogParser
  include Helpers::Parser

  # Generate usages for each date
  # @return: [
  #   { date: '20191105', app: 'Google Chrome', usages: { '00:00': 0, '00:10': 0, ..., '23:50': 0 }, ...
  # ]
  def generate_usages(context)
    usages = []

    Dir.chdir("#{context.data_dir}/Key")
    date_dir_strings = Dir.glob('*').select { |f| File.directory? f }
    date_dir_strings.each do |date_dir_str|
      Dir.chdir("#{context.data_dir}/Key/#{date_dir_str}")
      app_dir_strings = Dir.glob('*')
      app_dir_strings.each do |app_dir_str|
        app_detail_json = generate_one_day_one_app_usages(context.data_dir, date_dir_str, app_dir_str)
        usages << {
          'date'   => reformat_date_str(date_dir_str),
          'app'    => app_dir_str,
          'usages' => app_detail_json
        }
      end
    end

    usages
  end

  private

  def generate_one_day_one_app_usages(data_dir, date_str, app)
    results = default_usage_hash

    file = read_keylog_file(data_dir, date_str, app)
    time = nil
    while !file.eof?
      line = file.readline
      timestamp_str = parse_timestamp_str(line)
      if timestamp_str
        hr, min, sec, sep = parse_timestamp(timestamp_str)
        time = time_key(hr, min / 10 * 10)
      elsif results[time]
        sanitized_str = line.gsub(IGNORE_KEY_PATTERN, '')
        results[time] += sanitized_str.length
      end
    end

    results
  end
end
