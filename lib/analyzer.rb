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
        detail_usages << { date: reformat_date_str(date_dir_str), app: app_dir_str, usages: app_detail_json }
      end
    end

    p detail_usages
    detail_usages
  end

  def generate_detail_usage(date_str, app)
    results = default_detail_hash

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

  def read_detail_file(date_str, app_name)
    File.open("#{@data_dir}/Key/#{date_str}/#{app_name}")
  end

  def reformat_date_str(date_dir_str)
    day, month, year = date_dir_str.split('-')
    "#{year}#{month.to_s.rjust(2, '0')}#{day.to_s.rjust(2, '0')}"
  end

  def default_detail_hash
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