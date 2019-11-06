require_relative 'analyzer'
require_relative 'exporter'

data_dir = File.expand_path("./build/Data", Dir.pwd)
detail_usages_dir = "#{data_dir}/Key"

# analyze
analyzer = Analyzer.new(data_dir)
detail_usages_json = analyzer.generate_detail_usages

# export
exporter = Exporter.new(detail_usages_json)
exporter.to_json("#{detail_usages_dir}/detail_usages.json")
exporter.to_csv("#{detail_usages_dir}/detail_usages.csv")