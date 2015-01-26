var noble = require('noble');
var program = require('commander');
var charm = require('charm')();
var path = require('path');
var pkg = require(path.join(__dirname, 'package.json'));

program.version(pkg.version).
option('-n, --number of <devices>', 'number of devices to listen to', parseInt).
parse(process.argv);

var devices = program.number;
if (!devices) {
    console.error("You need to specify the number of devices to listen to.");
    program.help();
}

charm.pipe(process.stdout);

noble.on('stateChange', function(state) {
    if (state === 'poweredOn') {
        noble.startScanning();
    } else {
        noble.stopScanning();
    }
});

noble.on('scanStart', function() {
    console.log('on -> scanStart');
});

noble.on('scanStop', function() {
    console.log('on -> scanStop');
});

var lastRssiByUuid = {};
var deviceNameByUuid = {};
var waitFor = program.number;

var distanceByUuid = {};

function calculateDistance(txPower, rssi) {
    if (rssi == 0) {
        return -1.0;
    }

    var ratio = rssi * 1.0 / txPower;

    if (ratio < 1.0) {
        return Math.pow(ratio, 10);
    } else {
        var accuracy = (0.89976) * Math.pow(ratio, 7.7095) + 0.111;
        return accuracy;
    }
}

function calculateDistanceFor(uuid, rssi) {
    if (!distanceByUuid[uuid]) {
        distanceByUuid[uuid] = [];
    }

    var values = distanceByUuid[uuid];

    var distance = calculateDistance(-45, rssi);
    if (values.length >= 10) {
        var lastValue = values[0];
        if (Math.abs(distance - lastValue) < 2) { // to avoid quick jumps in signal
            values.unshift(distance);
        }
    } else {
        values.unshift(distance);
    }

    if (values.length > 20) {
        values = values.slice(0, -1);
        distanceByUuid[uuid] = values;
    }

    var total = values.reduce(function(a, b) {
        return a + b;
    });

    var avg = total / values.length;

    // console.log(values.length + " -> " + avg);

    return avg;
}

noble.on('discover', function(peripheral) {
    console.log('peripheral discovered (' + peripheral.advertisement.localName + '):');


    peripheral.on('rssiUpdate', function(rssi) {
        lastRssiByUuid[peripheral.uuid] = rssi;
        deviceNameByUuid[peripheral.uuid] = peripheral.advertisement.localName

        if (Object.keys(lastRssiByUuid).length == waitFor) {
            var log = "";
            var uuids = Object.keys(lastRssiByUuid);
            uuids.sort();
            charm.reset();
            uuids.forEach(function(uuid) {
                charm.write("distance: " + calculateDistanceFor(uuid, lastRssiByUuid[uuid]).toFixed(2) + "m device: " + deviceNameByUuid[uuid] + " (rssi:" +  lastRssiByUuid[uuid] + ")" + "\n");
            });
            lastRssiByUuid = {};
        }
    });
    peripheral.on('connect', function() {
        console.log('on -> connect');

        setInterval(function() {
            peripheral.updateRssi();
        }, 300);
    });

    peripheral.on('disconnect', function() {
        console.log('on -> disconnect');

        peripheral.connect();
    });

    peripheral.connect();

});

console.log("waiting for " + waitFor + " devices to connect...");
