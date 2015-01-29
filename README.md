# Beacons Positioning

this repo contains some pieces that try to solve the problem of indoor positioning: locating a device inside a room using 3 or more beacons.

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

-h, --help                 output usage information
-V, --version              output the version number
-n, --number of <devices>  number of devices to listen to
-l, --logfile <filename>   the log file to save received signals
```

### Broadcast signals of a logged session

```
$ node log-streamer.js 
Usage: log-streamer [options]

Options:

-h, --help             output usage information
-V, --version          output the version number
-l, --logfile <path>   path to the log file to stream
-n, --buffer <buffer>  number of devices to read until a value is streamed
```

## Client



