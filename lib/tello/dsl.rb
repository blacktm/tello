# Tello::DSL
# Define Tello domain-specific language
require 'timeout'

module Tello
  module DSL
    TIMEOUT_SEC = 6 # Needs to be tweaked after more testing

    # Warn Linux and Windows users to manually connect to Wi-Fi, for now
    unless Tello.os == :macos
      puts "Linux and Windows users:".bold,
        "  Manually connect to Tello Wi-Fi before running the `connect` command"
    end

    # Connect to the drone
    def connect(ssid=nil, ip=nil, bind_port=nil)
      Tello::Client.connect(ssid, ip, bind_port)
    end

    # Is the drone connected?
    def connected?
      Tello::Client.connected?
    end

    # Disconnect the drone
    def disconnect
      Tello::Client.disconnect
    end

    # Send a native Tello command to the drone
    def send(s)
      puts s
      begin
        ### WARNING: Ruby Timeout considered harmful (according to Dr. Google)
        Timeout::timeout(TIMEOUT_SEC) { Tello::Client.send(s) }
      rescue
        err = $!.to_s
        puts err unless err == 'execution expired'
        puts "timeout after #{TIMEOUT_SEC} seconds"
      end
    end

    def ap_mode(ssid, passwd)
      if ssid.to_s.strip.size == 0
        puts 'Cannot set AP mode when SSID is empty'
        return false
      end
      cmd = "ap #{ssid.to_s} #{passwd.to_s}"
      send(cmd)
    end

    # Check if value is within the common movement range
    def in_move_range?(v)
      (20..500).include? v
    end

    # Takeoff and land
    [:takeoff, :land, :streamon, :streamoff].each do |cmd|
      define_method cmd do
        Tello::Client.return_bool send("#{cmd.to_s}")
      end
    end

    # Move in a given direction
    [:up, :down, :left, :right, :forward, :back].each do |cmd|
      define_method cmd do |x|
        if in_move_range? x
          Tello::Client.return_bool send("#{cmd.to_s} #{x}")
        else
          puts "Movement must be between 20..500 cm"
        end
      end
    end
    alias_method :front, :forward
    alias_method :backward, :back

    # Turn clockwise or counterclockwise
    [:cw, :ccw].each do |cmd|
      define_method cmd do |x|
        if (1..3600).include? x
          Tello::Client.return_bool send("#{cmd.to_s} #{x}")
        else
          puts "Rotation must be between 1..3600 degrees"
        end
      end
    end

    # Flip in a given direction
    def flip(f)
      case f
      when :left, :l
        Tello::Client.return_bool send('flip l')
      when :right, :r
        Tello::Client.return_bool send('flip r')
      when :forward, :f
        Tello::Client.return_bool send('flip f')
      when :backward, :b
        Tello::Client.return_bool send('flip b')
      else
        puts "Not a valid direction to flip"
        false
      end
    end

    # Get or set the flight speed
    def speed(s = nil)
      if s
        if (10..100).include? s
          Tello::Client.return_bool send("speed #{s}")
        else
          puts "Speed must be between 10..100 cm/s"
        end
      else
        s = send('speed?')
        s == false ? false : s.to_f
      end
    end

    # Fly to a location in x/y/z coordinates and provided speed
    def go(x, y, z, speed = 10)

      # Check if coordinates are in range
      unless in_move_range?(x) && in_move_range?(y) && in_move_range?(z)
        puts "x/y/z coordinates must be between 20..500 cm"
        return false
      end

      # Check if speed is in range
      unless (10..100).include? speed
        puts "Speed must be between 10..100 cm/s"
        return false
      end

      Tello::Client.return_bool send("go #{x} #{y} #{z} #{speed}")
    end

    # Fly in a curve; If arc radius is not within 0.5..10 m, command responds false
    def curve(x1, y1, z1, x2, y2, z2, speed = 10)

      # Check if coordinates are in range
      # TODO: x/y/z can't be between -20..20 at the same time
      unless in_move_range?(x1) && in_move_range?(y1) && in_move_range?(z1) &&
             in_move_range?(x2) && in_move_range?(y2) && in_move_range?(z2)
        puts "x/y/z coordinates must be between 20..500 cm"
        return false
      end

      # Check if speed is in range
      unless (10..60).include? speed
        puts "Speed must be between 10..60 cm/s"
        return false
      end

      Tello::Client.return_bool send("curve #{x1} #{y1} #{z1} #{x2} #{y2} #{z2} #{speed}")
    end

    # Send RC control via four channels:
    #   a: left/right, b: forward/backward, c: up/down, d: yaw
    def rc(a, b, c, d)

      # Check if channel values are in range
      [a, b, c, d].each do |v|
        unless (-100..100).include? v
          puts "RC channel values must be between -100..100"
          return false
        end
      end

      Tello::Client.return_bool send("rc #{a} #{b} #{c} #{d}")
    end

    # Get the height of the drone
    def height
      Tello::Client.return_num send('height?')
    end

    # Get IMU attitude data
    def attitude
      send('attitude?')
    end

    # Get IMU angular acceleration data
    def acceleration
      send('acceleration?')
    end

    # Get barometer value
    def baro
      Tello::Client.return_num send('baro?')
    end

    # Get distance value from TOF
    def tof
      Tello::Client.return_num send('tof?')
    end

    # Get the flight time
    def time
      Tello::Client.return_num send('time?')
    end

    # Get the battery level
    def battery
      b = send('battery?')
      b == false ? false : Tello::Client.return_num(b)
    end

    # Get the temperature of the drone
    def temp
      send('temp?')
    end

    def sdk
      send('sdk?')
    end

    def sn
      send('sn?')
    end

    def bye!
      ## Tell the server to exit gracefully.
      ## Only applicable in test mode.
      if Tello.testing
        send('bye!')
        exit(0) if connected?
      end
    end

    # Get Wi-Fi signal-to-noise ratio (SNR); if parameters, set SSID and password
    def wifi(ssid: nil, pass: nil)
      if ssid && pass
        Tello::Client.return_bool send("wifi #{ssid} #{pass}")
      else
        Tello::Client.return_num send('wifi?')
      end
    end

    # stop: hovers in the air per Tello SDK 2.0 User Guide
    def stop
      Tello::Client.return send('stop')
    end
    alias_method :hover, :stop

    # Halt all motors immediately
    def halt
      Tello::Client.return_bool send('emergency')
    end

  end
end
