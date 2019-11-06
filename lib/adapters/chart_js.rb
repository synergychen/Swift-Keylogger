module Adapters
  class ChartJs
    COLORS = [
      '#d50000',
      '#c51162',
      '#aa00ff',
      '#6200ea',
      '#304ffe',
      '#2962ff',
      '#0091ea',
      '#00b8d4',
      '#00bfa5',
      '#00c853',
      '#64dd17',
      '#aeea00',
      '#ffd600',
      '#ffab00',
      '#ff6d00',
      '#dd2c00'
    ]

    def initialize(data)
      @data = data
    end

    def convert
      return [] if @data.empty?

      labels = @data.first['usages'].keys

      grouped_data = @data.group_by { |e| e['date'] }
      grouped_data.map do |date, arr|
        datasets = arr.map do |data|
          {
            'label' => data['app'],
            'data' => data['usages'].values,
            'backgroundColor' => string_to_color(data['app'])
          }
        end
        {
          'group' => date,
          'data' => {
            'labels' => labels,
            'datasets' => datasets
          }
        }
      end
    end

    def string_to_color(str)
      num = str.codepoints.to_a.sum
      COLORS[num % COLORS.length]
    end
  end
end