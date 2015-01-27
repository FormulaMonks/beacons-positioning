var noble = require('noble');
var EventEmitter = require("events").EventEmitter;

var lastRssiByUuid = {};
var deviceNameByUuid = {};
var distanceByUuid = {};

var ee = new EventEmitter();
ee.waitForNDevices = null;

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

// this function and similars should be executed by some thread of the pool of background threads.
function calculateDistanceFor(uuid, rssi) {
    if (!distanceByUuid[uuid]) {
        distanceByUuid[uuid] = [];
    }

    var values = distanceByUuid[uuid];

    var distance = calculateDistance(-50, rssi);
    if (values.length >= 10) {
        var lastValue = values[0];
        if (Math.abs(distance - lastValue) < 4) { // to avoid quick jumps in signal
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

noble.on('discover', function(peripheral) {
    console.log('peripheral discovered (' + peripheral.advertisement.localName + '):');

    peripheral.on('rssiUpdate', function(rssi) {
        lastRssiByUuid[peripheral.uuid] = rssi;
        deviceNameByUuid[peripheral.uuid] = peripheral.advertisement.localName

        if (Object.keys(lastRssiByUuid).length == ee.waitForDevices) {
            var log = "";
            var devices = [];
            var uuids = Object.keys(lastRssiByUuid);
            uuids.sort();
            uuids.forEach(function(uuid) {
                var device = {
                    name: deviceNameByUuid[uuid], 
                    distance: calculateDistanceFor(uuid, lastRssiByUuid[uuid]).toFixed(2),
                    rssi: lastRssiByUuid[uuid]
                };
                devices.push(device);
            });
            ee.emit("update", devices);
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

ee.calculateDistanceFor = calculateDistanceFor;

module.exports = ee;
