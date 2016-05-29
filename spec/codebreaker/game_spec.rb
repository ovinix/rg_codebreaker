require 'spec_helper'
 
module Codebreaker
  RSpec.describe Game do
    context "#start" do
      let(:game) { Game.new }
 
      before do
        game.start
      end
 
      it "saves secret code" do
        expect(game.instance_variable_get(:@secret_code)).not_to be_empty
      end
 
      it "saves 4 numbers secret code" do
        expect(game.instance_variable_get(:@secret_code).size).to eq(4)
      end
 
      it "saves secret code with numbers from 1 to 6" do
        expect(game.instance_variable_get(:@secret_code)).to match(/[1-6]+/)
      end
    end
  end
end