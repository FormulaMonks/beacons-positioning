"use strict";

var program = require('commander');
var charm = require('charm')();
var path = require('path');
var io = require('socket.io')();
var pkg = require(path.join(__dirname, 'package.json'));
var beacons = require("./beacons");
var fs = require("fs");
var defaultPort = 3000;

program.version(pkg.version).
option('-l, --logfile <filename>', 'the log file to save received signals').
option('-p, --port <port>', 'listening port', parseInt).
parse(process.argv);

var port = program.port;
if (!port) {
    port = defaultPort;
}

charm.pipe(process.stdout);

io.on('connection', function(socket){
    console.log('a user connected');
    socket.on('disconnect', function(){
        console.log('user disconnected');
    });
});

var startTime = new Date();

beacons.on('update', function(devices) {
    // charm.reset();
    devices.forEach(function(device) {
        device.timestamp = (new Date() - startTime).toString();

        if (program.logfile) {
            fs.appendFile(output, JSON.stringify(device) + ", ");            
        }
        
        charm.write("distance: " + device.distance + "m device: " + device.name + " (rssi:" +  device.rssi + ")" + "\n");
    });
    io.emit('update', devices);
});

io.listen(port);

console.log("listening web sockets on port " + port);
