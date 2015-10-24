require 'octokit'
require 'rdiscount'
require 'pry'
module App
  CLIENT            = Octokit::Client.new(access_token: ENV['ACCESS_TOKEN']) 
  PAGES_REPO_NAME   = ENV['PAGES_REPO_NAME']
  PAGES_BRANCH      = CLIENT.branch(PAGES_REPO_NAME, 'gh-pages')
  DEPLOY_REPO_NAME  = ENV['DEPLOY_REPO_NAME']
  MARKDOWN_FILENAME = ENV['MARKDOWN_FILENAME']
  HTML_FILENAME     = ENV['HTML_FILENAME']

  def self.call(env)
    puts Rack::Request.new(env).params
    if deploy_commit_sha = Rack::Request.new(env).params['head_long']
      puts deploy_commit_sha
      body = fetch_body_from_commit(deploy_commit_sha)
      puts body 
      puts fetch_old_index_markdown
      index_markdown = add_body(fetch_old_index_markdown, body, current_now_string).join("\n\n")
      puts index_markdown
      update_files index_markdown
      success_response
    else
      error_response
    end
  end

  private
  def self.fetch_body_from_commit(commit_sha)
    commit_message = CLIENT.commit(DEPLOY_REPO_NAME, commit_sha).commit.message
    CLIENT.pull_request(DEPLOY_REPO_NAME, parse_pull_request_number(commit_message)).body
  end

  def self.fetch_old_index_markdown
    Base64.decode64 CLIENT.contents(PAGES_REPO_NAME, path: MARKDOWN_FILENAME).content
  end

  def self.update_files(index_markdown)
    File.write(MARKDOWN_FILENAME, index_markdown)
    File.write(HTML_FILENAME, RDiscount.new(index_markdown).to_html)
  end

  def self.parse_pull_request_number message_string
    message_string.split(' ').detect { |word| word.include? '#' }.match(/\d+/).to_s.to_i
  end

  def self.current_now_string
    Time.now.strftime('%m/%d/%Y - %A')
  end

  def self.add_body(lines, body, now_string)
    body_array = body.split("\n").reject { |word| word == "" }
    if i = lines.index(now_string)
      lines[0..i] + body_array + lines[i+1..lines.length]
    else
      [now_string] + body_array + lines
    end
  end

  def self.error_response
    [500, { 'Content-Type' => 'text/html' }, StringIO.new('Error')]
  end

  def self.success_response
    [200, { 'Content-Type' => 'text/html' }, StringIO.new('')]
  end
end
