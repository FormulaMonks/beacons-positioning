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
async.eachSeries(logJson, function(device, callback) {
    devicesBuffer.push(device);

    charm.write("distance: " + beacons.calculateDistanceFor(device.name, device.rssi).toFixed(2) + "m device: " + device.name + " (rssi:" +  device.rssi + ")" + "\n");

    if (devicesBuffer.length == buffer) {
        var after = device["timestamp"] - lastTime;
        lastTime = device["timestamp"];
        setTimeout(function() {
            io.emit('update', devicesBuffer);
            devicesBuffer = [];
            charm.reset();
            callback();
        }, after);
    } else {
        callback();
    }
});

console.log("listening web sockets on port " + port);
