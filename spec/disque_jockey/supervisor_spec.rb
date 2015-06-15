require 'spec_helper'

describe DisqueJockey::Supervisor do
  subject { DisqueJockey::Supervisor }

  after(:each) do
    subject.instance_variable_set(:@worker_classes, [])
  end

  it "::register_worker adds a worker" do
    stub_const("FakeWorker", '')
    subject.register_worker(FakeWorker)
    expect(subject.worker_classes).to eq [FakeWorker]
  end

  it "::logger provides a DisqueJockey::Logger object" do
    expect(subject.logger.class).to eq DisqueJockey::Logger
  end

  it "::spawn_worker_groups spawns as many worker groups as the config says" do
    subject.instance_variable_set(:@worker_classes, ['something'])
    allow(Process).to receive(:fork).and_yield
    allow_any_instance_of(DisqueJockey::Configuration).to receive(:worker_groups).and_return 2
    group = double("WorkerGroup", work!: true)
    expect(DisqueJockey::WorkerGroup).to receive(:new).twice.and_return(group)
    expect(group).to receive(:work!).twice
    subject.send(:spawn_worker_groups)
  end

  it "::spawn_worker_groups raises an error if there are no worker classes" do
    expect{subject.send(:spawn_worker_groups)}.to raise_error(NoWorkersFoundError)
  end

  it "::load_workers loads classes in a workers directory" do
    expect(Object.const_defined?('FixtureWorker')).to eq false
    subject.send(:load_workers)
    expect(Object.const_defined?('FixtureWorker')).to eq true
  end

  it "::spawn_worker_group forks a process and creates a new worker group" do
    group = double("WorkerGroup", work!: true)
    expect(DisqueJockey::WorkerGroup).to receive(:new).and_return(group)
    expect(Process).to receive(:fork).and_yield
    subject.send(:spawn_worker_group)
  end
end