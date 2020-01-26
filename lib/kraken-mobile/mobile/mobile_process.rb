require 'kraken-mobile/device_process.rb'

class MobileProcess < DeviceProcess
  #-------------------------------
  # Required methods
  #-------------------------------
  def before_execute
    register_process_to_directory
    device.create_inbox
  end

  def after_execute
    device.delete_inbox
  end

  def execute
    # TODO, Change command
    open("|ADB_DEVICE_ARG=#{device.id} calabash-android run ~/Desktop/app.apk --tags @user#{id}", 'r') do |output|
      loop do
        $stdout.print output.readline.to_s
        $stdout.flush
      end
    end
    $CHILD_STATUS.exitstatus
  rescue EOFError
    nil
  end

  #-------------------------------
  # Methods
  #-------------------------------
  def register_process_to_directory
    File.open(K::DIRECTORY_PATH, 'a') do |file|
      file.puts("#{id}#{K::SEPARATOR}#{device}")
    end
  end
end
