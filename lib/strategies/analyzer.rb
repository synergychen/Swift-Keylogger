class Analyzer
  attr_reader :data_dir

  def initialize(parser, data_dir)
    @parser = parser
    @data_dir = data_dir
  end

  def generate_usages
    @parser.generate_usages(self)
  end
end
