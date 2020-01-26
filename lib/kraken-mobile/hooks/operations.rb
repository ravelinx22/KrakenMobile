require 'calabash-android/management/adb'
require 'calabash-android/operations'
require 'kraken-mobile/test_scenario'

def start_test_kraken_server_in_backgrouond
  start_test_server_in_background

  DeviceProcess.notify_process_state(
    process_id: process_id,
    state: K::PROCESS_STATES[:ready_to_start]
  )
  sleep(1) until TestScenario.ready_to_start? # TODO, add timeout
end

def shutdown_test_kraken_server
  DeviceProcess.notify_process_state(
    process_id: process_id,
    state: K::PROCESS_STATES[:ready_to_finish]
  )
  sleep(1) until TestScenario.ready_to_finish? # TODO, add timeout

  shutdown_test_server
end

private

def process_id
  tag_process_id = @scenario_tags.grep(/@user/).first
  tag_process_id.delete_prefix('@user')
end
