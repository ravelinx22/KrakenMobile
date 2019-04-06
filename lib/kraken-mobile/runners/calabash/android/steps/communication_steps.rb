Then("I wait for a signal containing {string}") do |string|
  channel = @scenario_tags.grep(/@user/).first
  readSignal(channel, string, KrakenMobile::Constants::DEFAULT_TIMEOUT)
end

Then("I wait for a signal containing {string} for {int} seconds") do |string, int|
  channel = @scenario_tags.grep(/@user/).first
  readSignal(channel, string, int)
end

Then("I send a signal to user {int} containing {string}") do |int, string|
  writeSignal("@user#{int}", string)
end
