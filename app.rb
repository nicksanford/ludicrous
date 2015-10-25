require 'octokit'
require 'rdiscount'
require './lib/wrappers/github'
require './lib/parsers'
require './lib/constants'

module App
  include Constants
  include Parsers
  include Wrappers::Github

  def self.call(env)
    puts Rack::Request.new(env).params
    if deploy_commit_sha = Rack::Request.new(env).params['head_long']
      update_log_with_pull_request_message(deploy_commit_sha)
    else
      [500, { 'Content-Type' => 'text/html' }, ['Error']]
    end
  end

  def self.update_log_with_pull_request_message(deploy_commit_sha)
    old_index_markdown_hash = contents_hash(PAGES_REPO_NAME, MARKDOWN_FILENAME)
    index_markdown = insert_body_into_markdown(old_index_markdown_hash[:contents],
                              fetch_body_array(deploy_commit_sha),
                              current_now_string)
    update_markdown index_markdown, old_index_markdown_hash[:sha]
    update_html index_markdown
    [200, { 'Content-Type' => 'text/html' }, []]
  end

  private
  def self.current_now_string
    Time.now.strftime('%m/%d/%Y - %A')
  end

  def self.fetch_body_array(commit_sha)
    pr_number = parse_pull_request_number commit_message(DEPLOY_REPO_NAME, commit_sha)
    parse_lines pr_body(DEPLOY_REPO_NAME, pr_number)
  end

  def self.insert_body_into_markdown(lines, body_array, now_string)
    if i = lines.index(now_string)
      lines[0..i] + body_array + lines[i+1..lines.length]
    else
      [now_string] + body_array + lines
    end.join("\n\n")
  end

  def self.update_html(index_markdown)
    html_sha = contents_hash(PAGES_REPO_NAME, HTML_FILENAME)[:sha]
    index_html = RDiscount.new(index_markdown).to_html
    update(PAGES_REPO_NAME, HTML_FILENAME, COMMIT_MESSAGE, html_sha, index_html, PAGES_BRANCH)
  end

  def self.update_markdown(markdown_sha, index_markdown)
    update(PAGES_REPO_NAME, MARKDOWN_FILENAME, COMMIT_MESSAGE, markdown_sha, index_markdown, PAGES_BRANCH)
  end
end
