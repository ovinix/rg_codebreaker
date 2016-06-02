require 'spec_helper'

module Codebreaker
  RSpec.describe Statistic do

    context "#rounds" do
      let(:inputs) { "123".chars }

      it "should return zero with no inputs" do
        expect(subject.rounds).to eq 0
      end

      it "should return number of rounds" do
        subject.instance_variable_set(:@inputs, inputs)
        expect(subject.rounds).to eq inputs.size
      end
    end

    context "#save" do
      let(:file_path) { "../../statistic.json" }
      
      it "should not save empty statistic" do
        subject.save
        expect(File.exists?(file_path)).to be false
      end

      it "should save statistic" do
        allow(subject).to receive(:empty?).and_return false
        subject.save
        expect(File.exists?(file_path)).to be true
        File.delete(file_path)
      end
    end
  end
end