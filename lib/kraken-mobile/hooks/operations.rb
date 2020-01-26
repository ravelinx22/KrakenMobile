require 'calabash-android/management/adb'
require 'calabash-android/operations'
require 'kraken-mobile/test_scenario'

def start_test_kraken_server_in_backgrouond
  start_test_server_in_background
  tag_process_id = @scenario_tags.grep(/@user/).first
  process_id = tag_process_id.delete_prefix('@user')

  DeviceProcess.notify_ready_to_start(process_id)
  sleep(1) until TestScenario.ready_to_start?
end

def shutdown_test_kraken_server
  shutdown_test_server
end
