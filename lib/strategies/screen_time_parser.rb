require_relative '../helpers/parser'

class ScreenTimeParser
  include Helpers::Parser

  def generate_usages(context)
    usages = []

    Dir.chdir("#{context.data_dir}/App")
    date_dir_strings = Dir.glob('*').select { |f| File.directory? f }
    date_dir_strings.each do |date_dir_str|
      one_day_usages = generate_one_day_usages(context.data_dir, date_dir_str)
      usages += one_day_usages
    end

    usages
  end

  private

  # Generate all app usages for one day
  # @return: [
  #   { date: '20191105', app: 'Google Chrome', usages: { '00:00': 0, '00:10': 0, ..., '23:50': 0 }, ...
  # ]
  def generate_one_day_usages(data_dir, date_str)
    all_usages = []
    file = read_screen_time_file(data_dir, date_str)

    logs = file.read.split(/\n/)
    logs.each_with_index do |log, index|
      break if index == logs.length - 1

      # current app name
      app_name = parse_app_name(log)

      # find or create app usage
      app_usage = all_usages.find { |e| e['app'] == app_name }
      unless app_usage
        app_usage = {
          'date'   => reformat_date_str(date_str),
          'app'    => app_name,
          'usages' => default_usage_hash
        }
        all_usages << app_usage
      end

      # time spent on current app
      current_timestamp_str = parse_timestamp_str(log)
      current_hr, current_min, current_sec = parse_timestamp(current_timestamp_str)
      current_total_sec = time_to_sec(current_hr, current_min, current_sec)
      next_timestamp_str = parse_timestamp_str(logs[index + 1])
      next_hr, next_min, next_sec = parse_timestamp(next_timestamp_str)
      next_total_sec = time_to_sec(next_hr, next_min, next_sec)
      time_spent = next_total_sec - current_total_sec

      # aggregate time spent on app
      app_usage['usages'][time_key(current_hr, current_min / 10 * 10)] += time_spent
    end

    all_usages
  end
end
