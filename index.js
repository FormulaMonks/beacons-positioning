var program = require('commander');
var charm = require('charm')();
var path = require('path');
var express = require('express');
var pkg = require(path.join(__dirname, 'package.json'));
var beacons = require("./beacons");

program.version(pkg.version).
option('-n, --number of <devices>', 'number of devices to listen to', parseInt).
parse(process.argv);

var waitFor = program.number;
if (!waitFor) {
    console.error("You need to specify the number of devices to listen to.");
    program.help();
}

charm.pipe(process.stdout);

beacons.waitForDevices = waitFor;
beacons.on('update', function(devices) {
    charm.reset();
    devices.forEach(function(device) {
        charm.write("distance: " + device.distance + "m device: " + device.name + " (rssi:" +  device.rssi + ")" + "\n");
    });
});

console.log("waiting for " + waitFor + " devices to connect...");
