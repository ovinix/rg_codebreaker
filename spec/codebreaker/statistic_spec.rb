require 'spec_helper'

module Codebreaker
  RSpec.describe Statistic do
    let(:statistic) { Statistic.new }

    context "#rounds" do
      let(:inputs) { "123".chars }

      it "should return zero with no inputs" do
        expect(statistic.rounds).to eq 0
      end

      it "should return number of rounds" do
        statistic.instance_variable_set(:@inputs, inputs)
        expect(statistic.rounds).to eq inputs.size
      end
    end

    context "#save" do
      let(:file_path) { "../../statistic.json" }
      
      it "should not save empty statistic" do
        statistic.save
        expect(File.exists?(file_path)).to be false
      end

      it "should save statistic" do
        allow(statistic).to receive(:empty?).and_return false
        statistic.save
        expect(File.exists?(file_path)).to be true
        File.delete(file_path)
      end
    end
  end
end