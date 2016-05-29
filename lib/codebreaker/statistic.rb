module Codebreaker

  class Statistic
    attr_accessor :name, :inputs, :results
    
    def initialize
      @name = nil
      @inputs = []
      @results = []
    end

    def rounds
      @inputs.size
    end

    def save(file_path = "../../statistic.json")
      File.open(file_path, 'a') {|f| f.write self.to_json } unless empty?
    end

    def to_s
      statistic = "Rounds played: #{self.rounds}\n"
      rounds.times do |index|
        statistic += "#{index + 1}: #{@inputs[index]}\t->\t#{@results[index]}\n"
      end
      statistic
    end

    def to_json
      hash = {}
      hash['name'] = self.name if self.name
      hash['rounds'] = self.rounds
      hash['inputs'] = self.inputs
      hash['results'] = self.results

      hash['game'] = hash
    end

    private

    def empty?
      self.rounds == 0 ? true : false
    end
  end
end