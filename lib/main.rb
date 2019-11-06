require_relative 'analyzer'
require_relative 'exporter'
require_relative 'adapters/chart_js'

data_dir = File.expand_path("./build/Data", Dir.pwd)
detail_usages_dir = "#{data_dir}/Key"

# analyze
analyzer = Analyzer.new(data_dir)
detail_usages_json = analyzer.generate_detail_usages

# export
Exporter.to_csv(detail_usages_json, "#{detail_usages_dir}/detail_usages.csv")
Exporter.to_json(detail_usages_json, "#{detail_usages_dir}/detail_usages.json")
chart_js_data = Adapters::ChartJs.new(detail_usages_json).convert
Exporter.to_json(chart_js_data, "#{detail_usages_dir}/detail_usages_chart_js.json")