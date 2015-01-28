"use strict";

var program = require('commander');
var charm = require('charm')();
var path = require('path');
var io = require('socket.io')();
var pkg = require(path.join(__dirname, 'package.json'));
var beacons = require("./beacons");
var fs = require("fs");
var port = 3000;
var LOG = false;

program.version(pkg.version).
option('-n, --number of <devices>', 'number of devices to listen to', parseInt).
parse(process.argv);

var waitFor = program.number;
if (!waitFor) {
    console.error("You need to specify the number of devices to listen to.");
    program.help();
}

charm.pipe(process.stdout);

io.on('connection', function(socket){
    console.log('a user connected');
    socket.on('disconnect', function(){
        console.log('user disconnected');
    });
});

var startTime = new Date();

beacons.waitForDevices = waitFor;
beacons.on('update', function(devices) {
    charm.reset();
    devices.forEach(function(device) {
        device.timestamp = (new Date() - startTime).toString();

        if (LOG) {
            fs.appendFile("log.txt", JSON.stringify(device) + ", ");            
        }
        
        charm.write("distance: " + device.distance + "m device: " + device.name + " (rssi:" +  device.rssi + ")" + "\n");
    });
    io.emit('update', devices);
});

io.listen(port);

console.log("listening web sockets on port " + port);
console.log("waiting for " + waitFor + " devices to connect...");
