require 'calabash-android/monkey_helpers'

module KrakenMobile
  module CalabashAndroid
    module MonkeyHelper

      # Runs inteligent monkey
      def run_inteligent_monkey channel, number_of_events
        device_id = channel_to_device_id channel
        logger = open("./#{device_id}.txt", 'w')
        number_of_events.times do |i|
          handle_random_action channel, logger
        end
        logger.close
      end

      # Runs adb monkey
      def run_monkey channel, number_of_events
        devices_helper = DevicesHelper::Manager.new({runner: ENV["RUNNER"], config_path: ENV["CONFIG_PATH"]}).device_helper
        device_id = channel_to_device_id channel
        height, width = devices_helper.screen_size device_id
        start_monkey
        actions = [:move, :down, :up]
        number_of_events.times do |i|
          monkey_touch(actions.sample, rand(5..(width-5)) , rand(5..(height-5)))
        end
        kill_existing_monkey_processes
      end

      # Runs monkey in an speciic part of the screen
      def run_small_monkey channel, number_of_events, height_start, height_end, width_start, width_end
        devices_helper = DevicesHelper::Manager.new({runner: ENV["RUNNER"], config_path: ENV["CONFIG_PATH"]}).device_helper
        device_id = channel_to_device_id channel
        height, width = devices_helper.screen_size device_id
        start_monkey
        actions = [:move, :down, :up]
        numb_height_start = (height*(height_start/100.0)).to_i+5
        numb_height_end = (height*(height_end/100.0)).to_i-5
        numb_width_start = (width*(width_start/100.0)).to_i+5
        numb_width_end = (width*(width_end/100.0)).to_i-5
        number_of_events.times do |i|
          pos_x = rand(numb_width_start..numb_width_end)
          pos_y = rand(numb_height_start..numb_height_end)
          monkey_touch(actions.sample,pos_x,pos_y)
        end
        kill_existing_monkey_processes
      end

      ###########################################
      ############## Events #####################
      ###########################################
      def handle_random_action channel, logger
        arr = [method(:enter_last_signal_in_random_input), method(:send_random_signal), method(:random_click)]
        arr.sample.call(channel, logger)
      end

      def random_click channel, logger
        elements = query("*")
        element = elements.sample if elements
        return if !element
        x = element["rect"]["x"]
        y = element["rect"]["y"]
        begin
          puts "#{x},#{y} click"
          perform_action(random_touch_action, x, y)
          logger.puts("Random click text: x: #{x} y: #{y}")
        rescue => e
          logger.puts(e)
        end
      end

      def enter_last_signal_in_random_input channel, logger
        last_signal = readLastSignal(channel)
        enter_text_in_random_input last_signal, logger
      end

      def enter_text_in_random_input text, logger
        return if input_texts.count <= 0
        input = input_texts.sample
        x = input["rect"]["x"]
        y = input["rect"]["y"]
        perform_action(random_touch_action, x, y)
        logger.puts("Typed text: #{text} x: #{x} y: #{y}")
        enter_text text
      end

      def send_random_signal channel, logger
        return if app_texts.count <= 0
        text = app_texts.sample
        text.slice!("(")
        text.slice!(")")
        logger.puts("Wrote signal: #{text}")
        writeSignalToAll(text)
      end

      def random_touch_action
        actions = ["touch_coordinate"]
        actions.sample
      end

      private
      def app_texts
        query("*", "text").select{ |e| !e["error"]}
      end

      def buttons
        query("android.support.v7.widget.AppCompatButton")
      end

      def enter_text text
        perform_action('keyboard_enter_text', text) if keyboard_visible?
      end

      def input_texts
        query("android.support.v7.widget.AppCompatEditText")
      end
    end
  end
end
