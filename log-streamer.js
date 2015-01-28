"use strict";

var program = require('commander');
var async = require('async');
var charm = require('charm')();
var path = require('path');
var io = require('socket.io')();
var pkg = require(path.join(__dirname, 'package.json'));
var beacons = require("./beacons");
var fs = require("fs");
var port = 3000;

program.version(pkg.version).
option('-l, --logfile <path>', 'path to the log file to stream').
option('-b, --buffer <buffer>', 'number of devices to read until a value is streamed').
parse(process.argv);

var logfile = program.logfile;
if (!logfile) {
    console.error("You need to specify the log file to stream.");
    program.help();
}

var buffer = program.buffer;
if (!buffer) {
    console.error("You need to specify number of devices to buffer before streaming.");
    program.help();
}

charm.pipe(process.stdout);

var logContent = fs.readFileSync(logfile);

var logJson = JSON.parse(logContent);

io.on('connection', function(socket){
    console.log('a user connected');
    socket.on('disconnect', function() {
        console.log('user disconnected');
    });
});

io.listen(port);

var lastTime = 0;
var devicesBuffer = [];

// override on message of worker
beacons.worker.onmessage = function(event) {
    charm.reset();
    var devices = event.data;
    devices.forEach(function(device) {
        charm.write("distance: " + device.distance.toFixed(2) + "m device: " + device.name + " (rssi:" +  device.rssi + ")" + "\n");
    });
    io.emit("update", event.data);
};

async.eachSeries(logJson, function(device, callback) {
    devicesBuffer.push(device);

    if (devicesBuffer.length != buffer) {
        callback();
        return;
    }

    devicesBuffer.sort(function(a, b) {
        return a.name > b.name;
    });

    var after = device.timestamp - lastTime;
    lastTime = device.timestamp;
    setTimeout(function() {
        beacons.worker.postMessage(devicesBuffer);
        devicesBuffer = [];
        callback();
    }, after);
});

console.log("listening web sockets on port " + port);
