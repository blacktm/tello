# Tello::Client
require 'socket'

module Tello
  module Client

    attr_accessor :ip, :port, :connected, :ping, :state

    class << self

      # Create a Tello UDP connection
      def connect(ssid = nil)

        # Connect to Tello wifi
        unless Tello::Wifi.connect(ssid)
          puts "#{'Error:'.error} Could not connect to Tello 😢"
          return false
        end

        # If already connected, disconnect
        if @connected
          puts "Reconnecting..."
          disconnect
        end

        # Set IP and port numbers
        @ip = Tello.testing ? 'localhost' : '192.168.10.1'
        @port = 8889

        # Create UDP client, bind to a previous source IP and port if availble
        @client = UDPSocket.new unless @client
        if @source_ip && @source_port
          @client.bind(@source_ip, @source_port)
        end

        # Connect to destination, save IP and port assigned by the OS
        @client.connect(@ip, @port)
        @source_ip = @client.addr[3]
        @source_port = @client.addr[1]

        # Create server to get Tello state
        unless @state_server
          @state_server = UDPSocket.new
          @state_server.bind('0.0.0.0', 8890)
        end

        # Check to see if test server is up
        if Tello.testing
          print "Connecting to test server..."
          @client.send('command', 0)
          sleep 0.5
          unless read_nonblock
            puts "\n#{'Error:'.error} Could not find Tello test server.",
                 "Did you run `tello server` in another terminal window?"
            return false
          end
          puts "connected!"
        end

        # Tello should be connected over wifi and UDP
        @connected = true

        # Threads for real Tello connection only
        unless Tello.testing
          # Create thread to keep Tello alive (must recieve command every 15 sec)
          if @ping then @ping.exit end
          @ping = Thread.new do
            loop do
              begin
                @client.send('command', 0)
              rescue Errno::EADDRNOTAVAIL
                puts "#{'Error:'.error} No response from Tello! Try reconnecting."
                @ping.exit
              end
              sleep 15
            end
          end

          # Get Tello state
          if @state then @state.exit end
          @state = Thread.new do
            loop do
              Tello.store_state(@state_server.recv(256))
            end
          end
        end

        puts "Ready to fly! 🚁"; true
      end

      # Get Tello connection status
      def connected?
        if @connected
          true
        else
          puts "Tello is not yet connected. Run `connect` first."
          false
        end
      end

      # Disconnect the Tello
      def disconnect
        return false unless @connected
        unless Tello.testing
          @state.exit
          @ping.exit
        end
        @client.close
        @client = nil
        @connected = false
        true
      end

      # Read the UDP response without blocking
      def read_nonblock
        begin
          res = @client.recv_nonblock(256)
        rescue IO::WaitReadable
          res = nil
        rescue Errno::ECONNREFUSED, Errno::EADDRNOTAVAIL
          puts "#{'Error:'.error} Cannot communicate with Tello!"
          @connected
        end
      end

      # Send a native Tello command string
      def send(cmd)
        return false unless connected?
        while read_nonblock do end  # flush previous response data
        @client.send(cmd, 0)
        @client.recv(256).strip
      end

      # Change 'ok' and 'error' to boolean response instead
      def return_bool(res)
        case res
        when 'ok'
          true
        when 'error'
          false
        end
      end

      # Change string to number response instead
      def return_num(res)
        if res then res.to_i else res end
      end

    end

  end
end
