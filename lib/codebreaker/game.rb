require "#{ File.dirname(__FILE__) }/statistic"

module Codebreaker

  class Game
    def initialize(rounds = 5)
      @secret_code = nil
      @hint = nil
      @statistic = Statistic.new
      @rounds = rounds
    end

    def start
      @secret_code = (1..4).map { rand(1..6) }.join
      run
    end

    def valid?(code)
      !!code.match(/^[1-6]{4}$/)
    end

    def check(code)
      code = code.clone
      result =  @secret_code.chars.map.with_index do |el, i|
                  if el == code[i]
                    code[i] = "+"
                    "+"
                  else
                    el
                  end
                end.join

      code.chars.each do |el|
        result.sub!(el, "-") if result.include?(el) && el != "+"
      end

      result.gsub(/\d/, "")
    end

    def hint
      @hint ||= @secret_code[rand(0..3)]
    end

    def reset_game
      @secret_code = nil
      @hint = nil
      @statistic = Statistic.new
    end

    def ask
      gets.chomp
    end

    def say(text)
      puts '----------------------------------------------'
      puts text
      puts '----------------------------------------------'
    end

    def run
      say "Let the Game begin!\n" \
          "You can enter 'H' for a hint.\n" \
          "It will cost you one round."
      @rounds.times do |index|
        break if round
      end
      finish
    end

    def round
      puts 'Enter your guess:'
      input = ask
      @statistic.inputs << input
      if valid?(input)
        result = check(input)
        @statistic.results << result
        if result == '++++'
          say 'You won!!!'
          return true
        else
          puts result
        end
      elsif input.match(/^[Hh]$/)
        puts "I hope it will help you: #{hint}"
        @statistic.results << "Hint asked."
      else
        puts "Please enter somethig better then '#{input}'"
        @statistic.results << "Bad input."
      end

      return false
    end

    def finish
      say 'Game finished!'
      game_statistic
      replay
    end

    def game_statistic
      puts 'Do you want to save result (Y/n) ?'
      return unless ask.match(/^[Yy]$/)
      @statistic.save
      say "Statistic:\n#{@statistic}\n"
    end

    def replay
      puts 'Replay (Y/n) ?'
      if ask.match(/^[Yy]$/)
        reset_game
        start
      else
        say 'Game finished!'
      end
    end
  end
end