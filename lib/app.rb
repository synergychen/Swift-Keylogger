#!/usr/bin/env ruby

require_relative 'adapters/chart_js'
require_relative 'exporter'
require_relative 'strategies/analyzer'
require_relative 'strategies/keylog_parser'
require_relative 'strategies/screen_time_parser'

data_dir = File.expand_path("./build/Data", Dir.pwd)
screen_time_dir = "#{data_dir}/App"
keylog_dir = "#{data_dir}/Key"

# ===============
# APP SCREEN TIME
# ===============
# app screen time analyzer
screen_time_parser = ScreenTimeParser.new
screen_time_analyzer = Analyzer.new(screen_time_parser, data_dir)
screen_time_json = screen_time_analyzer.generate_usages
# export app usages
Exporter.to_json(screen_time_json, "#{data_dir}/screen_time.json")
chart_js_data = Adapters::ChartJs.new(screen_time_json).convert
Exporter.to_json(chart_js_data, "#{data_dir}/screen_time_chart_js.json")

# ==========
# APP KEYLOG
# ==========
# app keylog analyzer
keylog_parser = KeylogParser.new
keylog_analyzer = Analyzer.new(keylog_parser, data_dir)
keylog_json = keylog_analyzer.generate_usages
# export app detail usages
Exporter.to_csv(keylog_json, "#{data_dir}/keylog.csv")
Exporter.to_json(keylog_json, "#{data_dir}/keylog.json")
chart_js_data = Adapters::ChartJs.new(keylog_json).convert
Exporter.to_json(chart_js_data, "#{data_dir}/keylog_chart_js.json")