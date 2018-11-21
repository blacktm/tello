# Tello state

module Tello

  @state

  class << self

    # Take a Tello state string, parse to a hash, and store.
    # String in the form:
    #   "pitch:11;roll:-18;yaw:118;vgx:0;vgy:0;vgz:0;templ:78;temph:80;tof:10;\
    #    h:0;bat:27;baro:-64.81;time:0;agx:242.00;agy:315.00;agz:-1057.00;\r\n"
    def store_state(str)
      str.strip!
      @state = Hash[
        str.split(';').map do |pair|
          k, v = pair.split(':', 2)
          [k.to_sym, v.to_i]
        end
      ]
    end

    def state; @state end

  end
end
