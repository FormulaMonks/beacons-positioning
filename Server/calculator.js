"use strict";

var worker = function() {
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
