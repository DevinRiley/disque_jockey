require 'spec_helper'

describe DisqueJockey do

  it "sets Thread.abort_on_exception to true" do
    expect(Thread.abort_on_exception).to eq true
  end

  it "::configuration returns a configuration object" do
    expect(DisqueJockey.configuration.class).to eq DisqueJockey::Configuration
  end

  it "::configure method changes the configuration" do
    expect do
      DisqueJockey.configure { |config| config.worker_groups = 1 }
    end.to_not raise_error
    expect(DisqueJockey.configuration.worker_groups).to eq 1
  end

  it "::run! calls the Supervisor::work! method" do
    expect(DisqueJockey::Supervisor).to receive(:work!)
    DisqueJockey.run!
  end
end