require 'spec_helper'

describe DisqueJockey::Logger do
  subject { DisqueJockey::Logger }
  it "defines instance methods" do
    [:logger, :fatal, :error, :warn, :info, :debug].each do |method|
      expect(subject.new('test')).to respond_to(method)
    end
  end
end