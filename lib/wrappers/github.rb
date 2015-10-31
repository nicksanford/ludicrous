require 'octokit'
require './lib/parsers'

module Wrappers
  module Github
    include Parsers

    OCTOKIT = Octokit::Client.new(access_token: ENV['ACCESS_TOKEN'])

    def commit_message(repo, sha)
      OCTOKIT.commit(repo, sha).commit.message
    end

    def pr_body(repo, number)
      OCTOKIT.pull_request(repo, number).body
    end

    def contents_hash(repo, path)
      contents = OCTOKIT.contents(repo, path: path)
      {
        sha: contents.sha,
        contents: parse_lines(Base64.decode64(contents.content))
      }
    end

    def update(repo, path, message, sha, contents, branch)
      OCTOKIT.update_contents(repo, path, message, sha, contents, branch: branch)
    end
  end
end
