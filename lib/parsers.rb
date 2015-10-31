module Parsers
  def parse_lines(string)
    string.gsub("\r", '').split("\n").reject { |line| line == '' }
  end

  def parse_pull_request_number(message_string)
    message_string.split(' ').detect { |word| word.include? '#' }.match(/\d+/).to_s
  end
end
