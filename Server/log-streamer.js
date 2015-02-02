"use strict";

var program = require('commander');
var async = require('async');
var charm = require('charm')();
var path = require('path');
var io = require('socket.io')();
var pkg = require(path.join(__dirname, 'package.json'));
var beacons = require("./beacons");
var fs = require("fs");
var defaultPort = 3000;

program.version(pkg.version).
option('-l, --logfile <path>', 'path to the log file to stream').
option('-p, --port <port>', 'listening port', parseInt).
parse(process.argv);

var logfile = program.logfile;
if (!logfile) {
    console.error("You need to specify the log file to stream.");
    program.help();
}

var port = program.port;
if (!port) {
    port = defaultPort;
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
    // charm.reset();
    var devices = event.data;
    devices.forEach(function(device) {
        charm.write("distance: " + device.distance.toFixed(2) + "m device: " + device.name + " (rssi:" +  device.rssi + ")" + "\n");
    });
    io.emit("update", devices);
};

async.eachSeries(logJson, function(device, callback) {
    var delay = device.timestamp - lastTime;
    lastTime = device.timestamp;
    setTimeout(function() {
        beacons.worker.postMessage([device]);
        callback();
    }, delay);
});

console.log("listening web sockets on port " + port);
