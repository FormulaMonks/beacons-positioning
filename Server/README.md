## Server

```
$ cd Server/
$ npm install
```

and then you have 2 options:

### Receive signals from bluetooth LE beacons and broadcast them through a socket.io API

```
$ node beacons-streamer.js
Usage: beacons-streamer [options]

Options:

-l, --logfile <filename>   the log file to save received signals
-p, --port <port>          listening port
```

### Broadcast signals of a logged session

```
$ node log-streamer.js 
Usage: log-streamer [options]

Options:

-l, --logfile <path>   path to the log file to stream
-p, --port <port>      listening port
```

you can find some logs on `Server/saved-logs`.

### Details

The server behaves as a device (by capturing beacons signals, using the `noble` node module) and as an API that streams these values. In a future the server should only receive measured signals from the room beacons and expose an API allowing devices to see other devices around.

By collecting bluetooth signals, it can use the strength of each signal (RSSI) to calculate an estimated distance from the server to the beacon. Since Bluetooth signals attenuate due to environment elements (walls, people, other signals, etc.), it's pretty common to have a good amount of noise when measuring. Due to this fact, the server has a noise cancelling algorithm that basically average the last N measures and discard the top/bottom 10% in case there is some unexpected jump on the signal.

You can have a simulated beacons environment by using a computer (with bluetooth LE) that runs the server and 3 iOS devices emitting in the room (see Estimote Virtual Beacon app). Then on another device (or using the iOS simulator), you can connect to the server using this client to see a map of the room and the devices positions.

### Socket.IO API

```
socket.emit('update', [
{ name: 'iPad',
    distance: 2.0836143860600043,
    rssi: -59,
    timestamp: '3082' },
  { name: 'iPhone',
    distance: 3.4219873656782474,
    rssi: -58,
    timestamp: '3081' },
  { name: 'iPod touch',
    distance: 0.5376388832674435,
    rssi: -46,
    timestamp: '3081' }
]);
```
