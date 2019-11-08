#!/usr/bin/env ruby

require 'csv'

class Analyzer
  TIMESTAMP_PATTERN = /[\d]+:[\d]+:[\d]+.*[A|P]M/
  IGNORE_KEY_PATTERN = /[\\ESCAPE]/

  def initialize(data_dir)
    @data_dir = data_dir
    @app_usages = {}
    @detail_usages = {}
  end

  def generate_app_usages
    app_usages = []

    Dir.chdir("#{@data_dir}/App")
    date_dir_strings = Dir.glob('*').select { |f| File.directory? f }
    date_dir_strings.each do |date_dir_str|
      one_day_app_usages = generate_app_usage(date_dir_str)
      app_usages += one_day_app_usages
    end

    app_usages
  end

  # Generate detail usage for each date
  # @return: [
  #   { date: '20191105', app: 'Google Chrome', usages: { '00:00': 0, '00:10': 0, ..., '23:50': 0 }, ...
  # ]
  def generate_detail_usages
    detail_usages = []

    Dir.chdir("#{@data_dir}/Key")
    date_dir_strings = Dir.glob('*').select { |f| File.directory? f }
    date_dir_strings.each do |date_dir_str|
      Dir.chdir("#{@data_dir}/Key/#{date_dir_str}")
      app_dir_strings = Dir.glob('*')
      app_dir_strings.each do |app_dir_str|
        app_detail_json = generate_detail_usage(date_dir_str, app_dir_str)
        detail_usages << {
          'date'   => reformat_date_str(date_dir_str),
          'app'    => app_dir_str,
          'usages' => app_detail_json
        }
      end
    end

    detail_usages
  end

  private

  # Generate app usage for each date
  # @return: [
  #   { date: '20191105', app: 'Google Chrome', usages: { '00:00': 0, '00:10': 0, ..., '23:50': 0 }, ...
  # ]
  def generate_app_usage(date_str)
    all_app_usages = []
    file = read_app_file(date_str)

    logs = file.read.split(/\n/)
    logs.each_with_index do |log, index|
      break if index == logs.length - 1

      # current app name
      app_name = parse_app_name(log)

      # find or create app usage
      app_usage = all_app_usages.find { |e| e['app'] == app_name }
      unless app_usage
        app_usage = {
          'date' => reformat_date_str(date_str),
          'app' => app_name,
          'usages' => default_usage_hash
        }
        all_app_usages << app_usage
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

    all_app_usages
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

  def generate_detail_usage(date_str, app)
    results = default_usage_hash

    file = read_detail_file(date_str, app)
    time = nil
    while !file.eof?
      line = file.readline
      matched = line.match(TIMESTAMP_PATTERN)
      if matched
        time_str = matched[0]
        hr, min, sec, sep = time_str.split(/[:| ]/)
        hr_offset = sep == 'AM' ? 0 : 12
        hr = hr.to_i % 12 + hr_offset
        min = min.to_i / 10 * 10
        sec = sec.to_i
        time = time_key(hr, min)
      elsif results[time]
        sanitized_str = line.gsub(IGNORE_KEY_PATTERN, '')
        results[time] += sanitized_str.length
      end
    end

    results
  end

  def read_app_file(date_str)
    File.open("#{@data_dir}/App/#{date_str}/Time Stamps of Apps")
  end

  def read_detail_file(date_str, app_name)
    File.open("#{@data_dir}/Key/#{date_str}/#{app_name}")
  end

  def reformat_date_str(date_dir_str)
    day, month, year = date_dir_str.split('-')
    "#{year}#{month.to_s.rjust(2, '0')}#{day.to_s.rjust(2, '0')}"
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

  def time_key(hr, min)
    "#{hr.to_s.rjust(2, '0')}:#{min.to_s.rjust(2, '0')}"
  end
end