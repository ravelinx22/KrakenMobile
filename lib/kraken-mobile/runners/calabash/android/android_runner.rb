require 'kraken-mobile/helpers/devices_helper/adb_helper'
require 'kraken-mobile/helpers/feature_grouper'
require 'kraken-mobile/runners/runner'
require 'parallel'


module KrakenMobile
	module Runner
		class CalabashAndroidRunner < KrakenRunner
			BASE_COMMAND = "calabash-android run"

      def initialize(options)
        super(options)
				@adb_helper = DevicesHelper::AdbHelper.new()
			end

      #-------------------------------
      # Hooks
      #-------------------------------
      def before_execution process_number
        device = @adb_helper.connected_devices[process_number]
        @adb_helper.create_file "inbox", device.id
        @adb_helper.create_file "kraken_settings", device.id
      end

      def after_execution process_number
        device = @adb_helper.connected_devices[process_number]
        @adb_helper.delete_file "inbox", device.id
        @adb_helper.delete_file "kraken_settings", device.id
      end

      #-------------------------------
      # Execution
      #-------------------------------
      def run_in_parallel
        feature_folder = @options[:feature_folder]
        devices_connected = @adb_helper.connected_devices
        groups = FeatureGrouper.file_groups(feature_folder, devices_connected.size)
        threads = groups.size
        puts "Running with #{threads} threads: #{groups}"
        test_results = Parallel.map_with_index(
          groups,
          :in_threads => threads,
          :start => lambda { |group, index|
            before_execution(index)
          },
          :finish => lambda { |group, index, _|
            after_execution(index)
          }
        ) do |group, index|
          run_tests(group, index, @options)
        end
      end

      def run_tests(test_files, process_number, options)
				cucumber_options = "#{options[:cucumber_options]} #{options[:cucumber_reports]}"
				command = build_execution_command(process_number, options[:apk_path], cucumber_options, test_files)
				puts "\n****** PROCESS #{process_number} STARTED ******\n\n"
				@command_helper.execute_command(process_number, command)
				puts "\n****** PROCESS #{process_number} COMPLETED ******\n\n"
			end

      #-------------------------------
      # Helpers
      #-------------------------------
			def build_execution_command process_number, apk_path, cucumber_options, test_files
        device = @adb_helper.connected_devices[process_number]
				execution_command = @command_helper.build_command [BASE_COMMAND, apk_path, cucumber_options, *test_files, "--tags @user#{device.position}"]
				env_variables = {
					AUTOTEST: '1',
					ADB_DEVICE_ARG: device.id,
					DEVICE_INFO: device.model,
					TEST_PROCESS_NUMBER: (process_number+1).to_s,
					SCREENSHOT_PATH: device.screenshot_prefix,
          PROTOCOL: @options[:protocol]
				}
				exports = @command_helper.build_export_env_command env_variables
				exports + @command_helper.terminal_command_separator + execution_command
			end
		end
	end
end
