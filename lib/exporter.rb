require 'csv'
require 'json'

class Exporter
  class << self
    def to_json(data, file_path)
      File.open(file_path, 'wb') do |f|
        f.write(data.to_json)
      end
    end

    def to_csv(data, file_path)
      CSV.open(file_path, 'wb') do |csv|
        csv << ['Date', 'App Name', 'Time', 'Keystroke Count']
        data.each do |data|
          date = data['date']
          app = data['app']
          usages = data['usages']
          usages.each do |time, count|
            csv << [date, app, time, count]
          end
        end
      end
    end
  end
end