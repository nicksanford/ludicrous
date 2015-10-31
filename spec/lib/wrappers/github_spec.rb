require 'spec_helper'
require './lib/wrappers/github'
require 'pry'

RSpec.describe Wrappers::Github do
  subject { Class.new { extend Wrappers::Github } }

  let(:octokit) { double('octokit') }
  before { stub_const('Wrappers::Github::OCTOKIT', octokit) }

  describe '#commit_message' do
    before { allow(octokit).to receive_message_chain(:commit, :commit, :message) }

    let(:repo) { double }
    let(:sha) { double }

    it 'calls octokit.commit with repo and sha' do
      expect(octokit).to receive(:commit).with(repo, sha)
      subject.commit_message(repo, sha)
    end

    it 'calls octokit.commit.commit.message' do
      expect(octokit).to receive_message_chain(:commit, :commit, :message)
      subject.commit_message(repo, sha)
    end
  end

  describe '#pr_body' do
    let(:repo) { double }
    let(:number) { double }

    before { allow(octokit).to receive_message_chain(:pull_request, :body) }

    it 'calls octokit.pull_request with repo and number' do
      expect(octokit).to receive(:pull_request).with(repo, number)
      subject.pr_body(repo, number)
    end

    it 'calls octokit.pull_request.body' do
      expect(octokit).to receive_message_chain(:pull_request, :body)
      subject.pr_body(repo, number)
    end
  end

  describe '#update' do
    let(:repo) { double }
    let(:path) { double }
    let(:message) { double }
    let(:sha) { double }
    let(:contents) { double }
    let(:branch) { double }

    it 'calls octokit.update_contents with(repo, path, message, sha, contents, branch: branch)' do
      expect(octokit).to receive(:update_contents).with(repo, path, message, sha, contents, branch: branch)
      subject.update(repo, path, message, sha, contents, branch)
    end
  end
end
