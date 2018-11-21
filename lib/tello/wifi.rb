# Tello::Wifi

module Tello
  module Wifi

    attr_accessor :tello_ssid, :macos_airport

    # Initialize data
    case Tello.os
    when :macos
      @macos_airport = '/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport'
    end

    class << self

      # Find and connect to a Tello Wi-Fi
      def connect(ssid = nil)

        # Skip connecting to Wi-Fi if in test mode
        if Tello.testing
          puts "In test mode, skipping Wi-Fi setup..."
          return true
        end

        # Assume Wi-Fi manually connected on Linux and Windows, for now
        # TODO: Actually implement
        unless Tello.os == :macos
          return true
        end

        # If provided SSID, set it, else look for a Tello Wi-Fi
        if ssid
          @tello_ssid = ssid
        else
          # Look for a Tello over Wi-Fi
          print "📶 Looking for Tello Wi-Fi..."

          # Done if already connected
          if wifi_connected?
            puts "already connected!"
            return true
          end

          # Search for a Tello Wi-Fi SSID (by default starting with "TELLO-")
          @tello_ssid = get_tello_wifi

          if @tello_ssid
            puts "found!"
          else
            puts "nothing found"
            return false
          end
        end

        # Connect to the Tello Wi-Fi
        print "🔗 Connecting to #{@tello_ssid}..."

        if connect_tello_wifi
          puts "done!"; true
        else
          puts "failed!"; false
        end
      end

      # Check if already connected to a Tello Wi-Fi, e.g. "TELLO-A5983D"
      def wifi_connected?
        @connected = case Tello.os
        when :macos
          macos_wifi_connected?
        when :linux
          linux_wifi_connected?
        when :windows
          windows_wifi_connected?
        end
      end

      # macOS `#wifi_connected?`
      def macos_wifi_connected?
        if `#{@macos_airport} -I`.match(/(tello-)\w+/i) then true else false end
      end

      # Linux `#wifi_connected?`
      def linux_wifi_connected?
        puts "`#linux_connected?` not implemented"; false
      end

      # Windows `#wifi_connected?`
      def windows_wifi_connected?
        puts "`#windows_connected?` not implemented"; false
      end

      # Look for a Tello Wi-Fi SSID starting with "TELLO-"
      # Returns an SSID, e.g. "TELLO-B5889D", or `nil` if nothing found
      def get_tello_wifi
        case Tello.os
        when :macos
          macos_get_tello_wifi
        when :linux
          linux_get_tello_wifi
        when :windows
          windows_get_tello_wifi
        end
      end

      # macOS `#get_tello_wifi`
      def macos_get_tello_wifi
        res = `#{@macos_airport} scan`.match(/(tello-)\w+/i)
        res ? res[0] : nil
      end

      # Linux `#get_tello_wifi`
      def linux_get_tello_wifi
        puts "`#linux_get_tello_wifi` not implemented"; false
      end

      # Windows `#get_tello_wifi`
      def windows_get_tello_wifi
        puts "`#windows_get_tello_wifi` not implemented"; false
      end

      # Connect to an SSID stored in `@tello_ssid`
      def connect_tello_wifi
        case Tello.os
        when :macos
          macos_connect_tello_wifi
        when :linux
          linux_connect_tello_wifi
        when :windows
          windows_connect_tello_wifi
        end
      end

      # macOS `#connect_tello_wifi`
      def macos_connect_tello_wifi
        # Assumes `en0` is wifi, might have to use this to confirm:
        #   networksetup -listallhardwareports
        res = `networksetup -setairportnetwork en0 #{@tello_ssid}`
        res == '' ? true : false
      end

      # Linux `#connect_tello_wifi`
      def linux_connect_tello_wifi
        puts "`#linux_get_tello_wifi` not implemented"; false
      end

      # Windows `#connect_tello_wifi`
      def windows_connect_tello_wifi
        puts "`#windows_get_tello_wifi` not implemented"; false
      end

    end
  end
end
