# Fly Tello with Ruby!

This gem will let you fly the [Tello drone](https://www.ryzerobotics.com/tello) or [Tello EDU drone](https://www.ryzerobotics.com/tello-edu) using Ruby.

## Your first Tello flight

If you don't already have one, get a Tello drone! A [number of retailers](https://www.ryzerobotics.com/where-to-buy) carry them for $99 USD. (You _can_ also use the [test server](#test-server) packaged with this gem to simulate commands, but that's not nearly as fun.)

Install the Ruby gem:

```
$ gem install tello
```

The gem comes with a command-line utility, also named `tello`. We can use it to launch an interactive console (IRB, or [Pry](http://pryrepl.org) if installed) and send commands to the drone. Go ahead and start the console:

```
$ tello console
```

Now, set the drone on the ground clear of any objects (including yourself) and press the button to turn it on. Wait for it to boot up, until the status light is blinking yellow.

**Linux and Windows users:** Connect to the drone's Wi-Fi manually (the network name should start with `TELLO-`). For macOS users, this will happen automatically with the next command.

In your interactive console, connect to the drone like so (the `>` here is just to note it's a Ruby prompt — don't type that):

```ruby
> connect
```

If you've successfully connected to the drone, you should see a "ready to fly" message. You're now ready to take flight!

```ruby
> takeoff
```

The drone should now be hovering. At this point, you can run all sorts of flight commands, described in the next section. Before we learn about all of them, let's have some fun. Stand clear of the drone and do a back flip:

```ruby
> flip :backward
```

Nice! For now, let's land the drone and learn about what else it can do.

```ruby
> land
```
## Your first Tello EDU flight

This is a bit more involved process, since you have to set up the Tello EDU drones (assuming you have two of them) to connect to your `local WiFi` as described in this [Video](https://www.youtube.com/watch?v=cIsddY4SKgA&t=162s)

The gem comes with a command-line utility, named `telloedu`. We can use it to launch an interactive console and send commands to the drones (one at a time for now). Go ahead and start the console:

```
$ telloedu console
```

Now, set the drones on the ground clear of any objects (including yourself) and press the button to turn them on. Wait for them to boot up, until the status light is blinking yellow.

In your interactive console, connect to the drone like so (the `>` here is just to note it's a Ruby prompt — don't type that):

```ruby
> connect(:ap, 'ipv4.of.drone.1') ### e.g. '192.168.0.101'
```

If you've successfully connected to the drone, you should see a "ready to fly" message. You're now ready to take flight!

```ruby
> takeoff
```

The drone should now be hovering. At this point, you can run all sorts of flight commands, described in the next section. For now, let's land the drone and learn about what else it can do.

```ruby
> land
```

Now, connect to the other drone like so:

```ruby
> connect(:ap, 'ipv4.of.drone.2') ### e.g. '192.168.0.102'
```

If you've successfully connected to the drone, you should see a "ready to fly" message. You're now ready to take flight!

```ruby
> takeoff
```

Now, let's land the drone and learn about what else it can do.

```ruby
> land
```
## Flight commands

This gem comes packed with commands you can send to the Tello drone. Let's go through each one.

### `connect`

The first command you'll run is `connect`. This will establish a network connection to the drone and prepare it for further commands. If already connected, `connect` will try to re-establish a connection (helpful for troubleshooting). If you need to, you can also use the `disconnect` command to break the connection.

### `takeoff`

Use this command to take flight! The drone will soon hover in place.

### `land`

Slowly descend to the ground and stop all rotors.

### `stop`

Immediately stop all rotors. This is like the "kill switch" for the drone, useful in emergencies. Be careful: the drone will fall from the sky and could get damaged.

### `up`, `down`, `left`, `right`, `forward`, `backward`

These are essential movement commands. Each one takes the distance the drone should move as a parameter, from 20 to 500 cm, for example:

```ruby
up 50  # ascend 50 cm
down 100  # descend 1 meter
left 250  # fly to the left 250 cm
right 75  # fly to the right 75 cm
forward 500  # fly forwards 5 m
backward 200  # fly backwards 2 m
```

### `cw`, `ccw`

These commands rotate the drone clockwise or counterclockwise, from 1 to 3600 degrees, for example:

```ruby
cw 90  # turn toward the right
cw 360  # turn toward the right in a full circle
ccw 180  # turn toward the left, facing in the opposite direction
ccw 3600  # spin around 10 times
```

### `flip`

Make the drone do a flip in a given direction, for example:

```ruby
flip :left
flip :right
flip :forward
flip :backward

# Or use this shorthand for the direction
flip :l
flip :r
flip :f
flip :b
```

### `speed`

Get or set the speed of the drone, in cm/s (centimeters per second). Without parameters, it will simply return the speed. To set the speed used during movement commands, provide a value from 10 to 100 as a parameter, for example:

```ruby
speed  # get the current speed in cm/s
speed 75  # set the drone speed to 75 cm/s

speed 100  # set speed to 1 m/s
forward 300  # fly forwards 3 meters in 3 seconds
```

### `go`

The drone can also be given a precise location to move, based on a 3D coordinate system. The `go` command tells the drone to move to an _x, y, z_ position at a given speed. The coordinate values must be between 20 and 500 cm, while the speed must be between 10 and 100 cm/s, for example:

```ruby
# Parameters: x, y, z, speed
go 100, 200, 50, 10
```

### `curve`

Fly in a curve, where the coordinates are between 20 and 500 cm, and speed is between 10 and 100 cm/s, for example:

```ruby
# Parameters: x1, y1, z1, x2, y2, z2, speed
curve 50, 100, 100, 25, 50, 75, 25
```

### `rc`

Send remote controller values via four channels, each between -100 and 100, for example:

```ruby
# Parameters: left/right, forward/backward, up/down, yaw
rc 0, 50, -25, 100
```

### `height`

Get the height of the drone in cm.

### `attitude`

Get the [inertial measurement unit (IMU)](https://en.wikipedia.org/wiki/Inertial_measurement_unit) attitude data. Example response: `"pitch:-8;roll:3;yaw:2;"`

### `acceleration`

Get the IMU angular acceleration data. Example response: `"agx:-138.00;agy:-51.00;agz:-989.00;"`

### `baro`

Get the barometer value.

### `tof`

Get the distance from the [time-of-flight (TOF) camera](https://en.wikipedia.org/wiki/Time-of-flight_camera).

### `time`

Get the flight time.

### `battery`

Get the battery level.

### `temp`

Get the temperature range of the drone in celsius.

### `wifi`

Get the Wi-Fi signal-to-noise ratio (SNR). Provide parameters to set the SSID and password, for example:

```ruby
# Get the SNR
wifi

# Set the SSID with password
wifi ssid: 'my-drone', pass: '12345'
```

### `state`

Get the state of the entire drone represented as a hash. Select a specific value by using one of the following keys: `:pitch`, `:roll`, `:yaw`, `:vgx`, `:vgy`, `:vgz`, `:templ`, `:temph`, `:tof`, `:h`, `:bat`, `:baro`, `:time`, `:agx`, `:agy`, `:agz`

### `send`

Finally, you can send raw command strings to the Tello drone (this is what we use internally for all the commands above). Refer to the [Tello SDK documentation](https://www.ryzerobotics.com/tello/downloads) for a listing of available commands. For example:

```ruby
send 'command'
send 'height?'
send 'up 50'
```

## Test server

You can simulate a connection to a Tello by running a test server at the command line, like so:

```
$ tello server
```

Then, open a new terminal window and run:

```
$ tello console --test
```

Now, run Tello commands just like you would when connected to a real drone.

## Gem development

Run `rake` to build this gem and install locally.

To release a new version:

1. Update the version number in [`version.rb`](lib/tello/version.rb), commit changes
2. Create a [new release](https://github.com/blacktm/tello/releases) in GitHub, with tag in the form `v#.#.#`
3. Run `rake` to build the gem, then push it to [rubygems.org](https://rubygems.org) with `gem push tello-#.#.#.gem`
4. 🎉
