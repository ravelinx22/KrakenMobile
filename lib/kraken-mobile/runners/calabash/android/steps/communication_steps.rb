ParameterType(
  name:        'property',
  regexp:      /[^\"]*/,
  type:        String,
  transformer: ->(s) {
    channel = @scenario_tags.grep(/@user/).first
    if ENV["PROPERTIES_PATH"] && channel
      raise "Property #{s} should start with '<' and end with '>'" if !s.start_with?("<") || ! s.end_with?(">")
      s.slice!("<")
      s.slice!(">")
      file = open(ENV["PROPERTIES_PATH"])
      content = file.read
      properties = JSON.parse(content)
      raise "Property <#{s}> not found for #{channel}" if !properties[channel] || !properties[channel][s]
      return properties[channel][s]
    else
      return s
    end
  }
)

Then /^I wait for a signal containing "([^\"]*)"$/ do |string|
  channel = @scenario_tags.grep(/@user/).first
  readSignal(channel, string, KrakenMobile::Constants::DEFAULT_TIMEOUT)
end

Then /^I wait for a signal containing "([^\"]*)" for (\d+) seconds$/ do |string, int|
  channel = @scenario_tags.grep(/@user/).first
  readSignal(channel, string, int)
end

Then /^I send a signal to user (\d+) containing "([^\"]*)"$/ do |int, string|
  writeSignal("@user#{int}", string)
end
