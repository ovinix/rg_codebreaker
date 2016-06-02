require 'spec_helper'

module Codebreaker
  RSpec.describe Game do

    context "#start" do
      before do
        expect(subject).to receive(:run).and_return(nil)
        subject.start
      end

      it "generates secret code" do
        expect(subject.instance_variable_get(:@secret_code)).not_to be_empty
      end

      it "saves 4 numbers secret code" do
        expect(subject.instance_variable_get(:@secret_code).size).to eq(4)
      end

      it "saves secret code numbers from 1 to 6" do
        expect(subject.instance_variable_get(:@secret_code)).to match(/[1-6]+/)
      end
    end

    context "#run" do
      subject { Game.new(3) }

      before do
        expect(subject).to receive(:round).exactly(3).and_return(false)
        expect(subject).to receive(:finish).and_return(false)
      end

      it "should say greeting" do
        expect { subject.run }.to output(/Let the Game begin!/).to_stdout
      end
    end

    context "#round" do
      after do
        statistic = subject.instance_variable_get(:@statistic)
        expect(statistic.inputs).not_to be_empty 
        expect(statistic.results).not_to be_empty 
      end

      it "should ask for guess" do
        expect(subject).to receive(:ask).and_return("")
        expect { subject.round }.to output(/Enter your guess:/).to_stdout
      end

      it "should be 'true' for winner" do
        expect(subject).to receive(:ask).and_return("")
        expect(subject).to receive(:valid?).and_return(true)
        expect(subject).to receive(:check).and_return("++++")

        expect(subject.round).to be true
      end

      it "should be 'false' for input with wrong code" do
        expect(subject).to receive(:ask).and_return("")
        expect(subject).to receive(:valid?).and_return(true)
        expect(subject).to receive(:check).and_return("+++")

        expect(subject.round).to be false
      end

      it "should be 'false' then hint was asked with 'h'" do
        expect(subject).to receive(:ask).and_return("h")
        expect(subject).to receive(:hint)

        expect(subject.round).to be false
      end

      it "should be 'false' then hint was asked with 'H'" do
        expect(subject).to receive(:ask).and_return("H")
        expect(subject).to receive(:hint)

        expect(subject.round).to be false
      end

      it "should be 'false' with wrong input" do
        expect(subject).to receive(:ask).and_return("12hg")
        expect(subject.round).to be false
      end
    end

    context "#valid?" do
      let(:valid_code) { "1234" }
      let(:invalid_code) { "aaaz5" }

      it "checks if code is valid and replies with boolean" do
        expect([true, false]).to include(subject.valid? valid_code)
        expect([true, false]).to include(subject.valid? invalid_code)
      end

      it "valid with 4 numbers from 1 to 6" do
        expect(subject.valid? valid_code).to be true
      end

      it "not valid with letters" do
        expect(subject.valid? "1aaa").to be false
      end

      it "not valid with size more then 4" do
        expect(subject.valid? "11111").to be false
      end

      it "not valid with size less then 4" do
        expect(subject.valid? "111").to be false
      end

      it "not valid with number higher then 6" do
        expect(subject.valid? "1117").to be false
      end

      it "not valid with number less then 1" do
        expect(subject.valid? "1110").to be false
      end
    end

    context "#check" do
      results = {
                  "5555": "",
                  "5551": "-",
                  "1555": "+",
                  "5521": "--",
                  "1255": "++",
                  "2222": "+",
                  "4121": "----",
                  "1214": "++++"
                }

      before do
        subject.instance_variable_set(:@secret_code, "1214")
      end

      results.each do |guess, reply|
        it "should reply with '#{reply}' for '#{guess}'" do
          expect(subject.check(guess.to_s)).to eq(reply)
        end
      end
    end

    context "#hint" do
      before do
        subject.instance_variable_set(:@secret_code, "1234")
      end

      it "gives a hint" do
        expect(subject.hint).not_to be_empty 
      end
      it "hint should contain one number" do
        expect(subject.hint.size).to eq(1)
      end
      it "hint should be a number" do
        expect(subject.hint).to match(/\d/)
      end
      it "first and others hints should be the same" do
        expect(subject.hint).to eq(subject.hint)
      end
    end

    context "#ask" do
      let(:input) { "1214\n" }

      before do
        expect(subject).to receive(:gets).and_return(input)
      end

      it "code entered" do
        expect(subject.ask).to eq(input.chomp)
      end
    end

    context "#say" do
      let(:text) { "Hello\n" }

      it "should say 'Hello'" do
        expect { subject.say text }.to output(/#{text}/).to_stdout
      end

      it "should contain dashed" do
        expect { subject.say text }.to output(/----/).to_stdout
      end
    end

    context "#finish" do
      it "should say that game is finished" do
        expect(subject).to receive(:game_statistic).and_return nil
        expect(subject).to receive(:replay).and_return nil
        expect { subject.finish }.to output(/Game finished!/).to_stdout
      end
    end

    context "#game_statistic" do
      it "should save statistic with 'y'" do
        statistic = subject.instance_variable_get(:@statistic)
        expect(subject).to receive(:ask).and_return('y')
        expect(statistic).to receive(:save).and_return nil
        expect(subject).to receive(:say)
        expect { subject.game_statistic }.to output(/Do you want to save result/).to_stdout
      end

      it "should save statistic with 'Y'" do
        statistic = subject.instance_variable_get(:@statistic)
        expect(subject).to receive(:ask).and_return('Y')
        expect(statistic).to receive(:save).and_return nil
        expect(subject).to receive(:say)
        expect { subject.game_statistic }.to output(/Do you want to save result/).to_stdout
      end

      it "should not save statistic with 'n'" do
        statistic = subject.instance_variable_get(:@statistic)
        expect(subject).to receive(:ask).and_return('n')
        expect(statistic).not_to receive(:save)
        expect { subject.game_statistic }.to output(/Do you want to save result/).to_stdout
      end

      it "should not save statistic with 'N'" do
        statistic = subject.instance_variable_get(:@statistic)
        expect(subject).to receive(:ask).and_return('N')
        expect(statistic).not_to receive(:save)
        expect { subject.game_statistic }.to output(/Do you want to save result/).to_stdout
      end
    end

    context "#replay" do
      it "should restart game with 'y'" do
        expect(subject).to receive(:ask).and_return('y')
        expect(subject).to receive(:reset_game).and_return nil
        expect(subject).to receive(:start).and_return nil
        expect { subject.replay }.to output(/Replay/).to_stdout
      end

      it "should restart game with 'Y'" do
        expect(subject).to receive(:ask).and_return('Y')
        expect(subject).to receive(:reset_game).and_return nil
        expect(subject).to receive(:start).and_return nil
        expect { subject.replay }.to output(/Replay/).to_stdout
      end

      it "should not restart game with 'n'" do
        expect(subject).to receive(:ask).and_return('n')
        expect(subject).not_to receive(:reset_game)
        expect(subject).not_to receive(:start)
        expect { subject.replay }.to output(/Replay/).to_stdout
      end

      it "should restart game with 'Y'" do
        expect(subject).to receive(:ask).and_return('N')
        expect(subject).not_to receive(:reset_game)
        expect(subject).not_to receive(:start)
        expect { subject.replay }.to output(/Replay/).to_stdout
      end
    end

    context "#reset_game" do
      it "should reset the game" do
        subject.reset_game
        expect(subject.instance_variable_get(:@secret_code)).to eq nil
        expect(subject.instance_variable_get(:@hint)).to eq nil
        expect(subject.instance_variable_get(:@statistic).rounds).to eq 0
      end
    end
  end
end