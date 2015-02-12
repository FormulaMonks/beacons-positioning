"use strict";

var worker = function() {
    var distanceByUuid = {};
    var AVERAGE_ITEMS = 40;
    var MAX_DISTANCE = 150;
    var calculateDistanceAlgo = _calculateDistanceInverse;

    function _calculateDistanceInverse(txPower, rssi) {
        if (rssi == 0) {
            return -1.0;
        }

        var n = 5.0;
        var rssiAt1m = -37.0;

        var exp = (rssiAt1m - rssi)/(10 * n);
        return Math.pow(10.0, exp);
    }

    function _calculateDistanceEmpiric(txPower, rssi) {
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

        var distance = calculateDistanceAlgo(-50, rssi);

        if (distance < MAX_DISTANCE) { // avoid error values
            values.push(distance);
        }

        if (values.length == 1) {
            return distance;
        }

        if (values.length > AVERAGE_ITEMS) {
            values = values.slice(1);
            distanceByUuid[uuid] = values;
        }

        var valuesToUse = values.slice(0);
        
        valuesToUse.sort();

        var ten = Math.floor(values.length * 0.1);
        if (ten > 0) {
            valuesToUse = valuesToUse.slice(ten, -ten); // discard top/bottom 10%                
        }

        var total = valuesToUse.reduce(function(a, b) {
            return a + b;
        });

        var avg = total / valuesToUse.length;

        // console.log(valuesToUse.length + " -> " + avg);            

        return avg;
    }

    this.onmessage = function(event) {
        var devices = event.data;

        for (var i = 0; i < devices.length; i++) {
            var device = devices[i];
            device.distance = calculateDistanceFor(device.name, device.rssi);
        };

        postMessage(devices);
    };
};

module.exports = worker;
