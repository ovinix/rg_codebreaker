require 'spec_helper'

module Codebreaker
  RSpec.describe Game do
    let(:game) { Game.new }

    context "#start" do
      before do
        expect(game).to receive(:run).and_return(nil)
        game.start
      end

      it "generates secret code" do
        expect(game.instance_variable_get(:@secret_code)).not_to be_empty
      end

      it "saves 4 numbers secret code" do
        expect(game.instance_variable_get(:@secret_code).size).to eq(4)
      end

      it "saves secret code numbers from 1 to 6" do
        expect(game.instance_variable_get(:@secret_code)).to match(/[1-6]+/)
      end
    end

    context "#run" do
      let(:game) { Game.new(3) }

      before do
        expect(game).to receive(:round).exactly(3).and_return(false)
        expect(game).to receive(:finish).and_return(false)
      end

      it "should say greeting" do
        expect { game.run }.to output(/Let the Game begin!/).to_stdout
      end
    end

    context "#round" do
      after do
        statistic = game.instance_variable_get(:@statistic)
        expect(statistic.inputs).not_to be_empty 
        expect(statistic.results).not_to be_empty 
      end

      it "should ask for guess" do
        expect(game).to receive(:ask).and_return("")
        expect { game.round }.to output(/Enter your guess:/).to_stdout
      end

      it "should be 'true' for winner" do
        expect(game).to receive(:ask).and_return("")
        expect(game).to receive(:valid?).and_return(true)
        expect(game).to receive(:check).and_return("++++")

        expect(game.round).to be true
      end

      it "should be 'false' for input with wrong code" do
        expect(game).to receive(:ask).and_return("")
        expect(game).to receive(:valid?).and_return(true)
        expect(game).to receive(:check).and_return("+++")

        expect(game.round).to be false
      end

      it "should be 'false' then hint was asked" do
        expect(game).to receive(:ask).and_return("h")
        expect(game).to receive(:hint)

        expect(game.round).to be false

        expect(game).to receive(:ask).and_return("H")
        expect(game).to receive(:hint)

        expect(game.round).to be false
      end

      it "should be 'false' with wrong input" do
        expect(game).to receive(:ask).and_return("12hg")
        expect(game.round).to be false
      end
    end

    context "#valid?" do
      let(:valid_code) { "1234" }
      let(:invalid_code) { "aaaz5" }

      it "checks if code is valid and replies with boolean" do
        expect([true, false]).to include(game.valid? valid_code)
        expect([true, false]).to include(game.valid? invalid_code)
      end

      it "valid with 4 numbers from 1 to 6" do
        expect(game.valid? valid_code).to be true
      end

      it "not valid with letters" do
        expect(game.valid? "1aaa").to be false
      end

      it "not valid with size more then 4" do
        expect(game.valid? "11111").to be false
      end

      it "not valid with size less then 4" do
        expect(game.valid? "111").to be false
      end

      it "not valid with number higher then 6" do
        expect(game.valid? "1117").to be false
      end

      it "not valid with number less then 1" do
        expect(game.valid? "1110").to be false
      end
    end

    context "#check" do
      before do
        game.instance_variable_set(:@secret_code, "1214")
      end

      it "replies with nothing for totally wrong code" do
        expect(game.check("5555")).to be_empty
      end

      it "replies with '-' for correct number on wrong place" do
        expect(game.check("5551")).to eq("-")
      end

      it "replies with '+' for correct number on correct place" do
        expect(game.check("1555")).to eq("+")
      end

      it "replies with '--' for two correct numbers on wrong place" do
        expect(game.check("5521")).to eq("--")
      end

      it "replies with '++' for two correct numbers on correct place" do
        expect(game.check("1255")).to eq("++")
      end

      it "replies with '+' for correct number repeated 4 times" do
        expect(game.check("2222")).to eq("+")
      end

      it "replies with '----' for correct numbers on wrong places" do
        expect(game.check("4121")).to eq("----")
      end

      it "replies with '++++' for correct code" do
        expect(game.check("1214")).to eq("++++")
      end
    end

    context "#hint" do
      before do
        game.instance_variable_set(:@secret_code, "1234")
      end

      it "gives a hint" do
        expect(game.hint).not_to be_empty 
      end
      it "hint should contain one number" do
        expect(game.hint.size).to eq(1)
      end
      it "hint should be a number" do
        expect(game.hint).to match(/\d/)
      end
      it "first and others hints should be the same" do
        expect(game.hint).to eq(game.hint)
      end
    end

    context "#ask" do
      let(:input) { "1214\n" }

      before do
        expect(game).to receive(:gets).and_return(input)
      end

      it "code entered" do
        expect(game.ask).to eq(input.chomp)
      end
    end

    context "#say" do
      let(:text) { "Hello\n" }

      it "should say 'Hello'" do
        expect { game.say text }.to output(/#{text}/).to_stdout
      end

      it "should contain dashed" do
        expect { game.say text }.to output(/----/).to_stdout
      end
    end

    context "#finish" do
      it "should say that game is finished" do
        expect(game).to receive(:game_statistic).and_return nil
        expect(game).to receive(:replay).and_return nil
        expect { game.finish }.to output(/Game finished!/).to_stdout
      end
    end

    context "#game_statistic" do
      it "should save statistic with 'y'" do
        statistic = game.instance_variable_get(:@statistic)
        expect(game).to receive(:ask).and_return('y')
        expect(statistic).to receive(:save).and_return nil
        expect(game).to receive(:say)
        expect { game.game_statistic }.to output(/Do you want to save result/).to_stdout
      end

      it "should save statistic with 'Y'" do
        statistic = game.instance_variable_get(:@statistic)
        expect(game).to receive(:ask).and_return('Y')
        expect(statistic).to receive(:save).and_return nil
        expect(game).to receive(:say)
        expect { game.game_statistic }.to output(/Do you want to save result/).to_stdout
      end

      it "should not save statistic with 'n'" do
        statistic = game.instance_variable_get(:@statistic)
        expect(game).to receive(:ask).and_return('n')
        expect(statistic).not_to receive(:save)
        expect { game.game_statistic }.to output(/Do you want to save result/).to_stdout
      end

      it "should not save statistic with 'N'" do
        statistic = game.instance_variable_get(:@statistic)
        expect(game).to receive(:ask).and_return('N')
        expect(statistic).not_to receive(:save)
        expect { game.game_statistic }.to output(/Do you want to save result/).to_stdout
      end
    end

    context "#replay" do
      it "should restart game with 'y'" do
        expect(game).to receive(:ask).and_return('y')
        expect(game).to receive(:reset_game).and_return nil
        expect(game).to receive(:start).and_return nil
        expect { game.replay }.to output(/Replay/).to_stdout
      end

      it "should restart game with 'Y'" do
        expect(game).to receive(:ask).and_return('Y')
        expect(game).to receive(:reset_game).and_return nil
        expect(game).to receive(:start).and_return nil
        expect { game.replay }.to output(/Replay/).to_stdout
      end

      it "should not restart game with 'n'" do
        expect(game).to receive(:ask).and_return('n')
        expect(game).not_to receive(:reset_game)
        expect(game).not_to receive(:start)
        expect { game.replay }.to output(/Replay/).to_stdout
      end

      it "should restart game with 'Y'" do
        expect(game).to receive(:ask).and_return('N')
        expect(game).not_to receive(:reset_game)
        expect(game).not_to receive(:start)
        expect { game.replay }.to output(/Replay/).to_stdout
      end
    end

    context "#reset_game" do
      it "should reset the game" do
        game.reset_game
        expect(game.instance_variable_get(:@secret_code)).to eq nil
        expect(game.instance_variable_get(:@hint)).to eq nil
        expect(game.instance_variable_get(:@statistic).rounds).to eq 0
      end
    end
  end
end