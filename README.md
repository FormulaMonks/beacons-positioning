# Beacons Positioning

This repo contains some pieces that try to solve the problem of indoor positioning: locating a device inside a room using 3 or more beacons.

## Server

```
$ cd Server/
$ npm install
```

and then you have 2 options:

### Receive signals from bluetooth LE beacons and broadcast them through a web socket API.

```
$ node beacons-streamer.js
Usage: beacons-streamer [options]

Options:

-n, --number of <devices>  number of devices to listen to
-l, --logfile <filename>   the log file to save received signals
```

### Broadcast signals of a logged session

```
$ node log-streamer.js 
Usage: log-streamer [options]

Options:

-l, --logfile <path>   path to the log file to stream
-n, --buffer <buffer>  number of devices to read until a value is streamed
```

### Details

The server behaves as a device (by capturing beacons signals, using the `noble` node module) and as an API that streams these values. In a future the server should only receive measured signals from the room beacons and expose an API for other devices to see other devices around.

By collecting bluetooth signals, it can use the strength of each signal (RSSI) to calculate an estimated distance from the server to the beacon. Since Bluetooth signals attenuate due to environment elements (walls, people, other signals, etc.), it's pretty common to have a good amount of noise when measuring. Due to this fact, the server has a noise cancelling algorithm that basically average the last N measures and discard the top/bottom 10% in case there is some unexpected jump on the signal.

## Client

You can have a simulated beacons environment by using a computer (with bluetooth LE) that runs the server and 3 iOS devices emitting in the room (see Estimote Virtual Beacon app). Then on another device (or using the iOS simulator), you can connect to the server using the client to see a map of the room and the devices positions.

The iOS client is an app that initially put 3 beacons on the screen and can perform these actions:

1. Play with a simulated room:

* touching and dragging near the beacon will move its position.
* touching (> 30 pixels) from a beacon and dragging up/down will make the measured distance (gray circle) to vary according.
* you can tap on the 'Start Simulation' button to see small random variations on measured distance and see how the estimated position looks like.

2. Read and visualize (heat map) the values from the server:

* The client will try to connect to the server on start (localhost:3000) to display the located devices on the map if successul. The bigger the heat map area, the more discrepancy there is between the measured distances meaning the error is bigger.

