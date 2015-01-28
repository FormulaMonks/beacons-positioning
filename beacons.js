"use strict";

var Worker = require('webworker-threads').Worker;
var EventEmitter = require("events").EventEmitter;
var noble = require("noble");
var calculator = require("./calculator");

var lastRssiByUuid = {};
var deviceNameByUuid = {};

var worker = new Worker(calculator);

var ee = new EventEmitter();
ee.waitForNDevices = null;
ee.worker = worker;

worker.emitter = ee;
worker.onmessage = function(event) {
    this.emitter.emit("update", event.data);
};

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
        deviceNameByUuid[peripheral.uuid] = peripheral.advertisement.localName;

        if (Object.keys(lastRssiByUuid).length == ee.waitForDevices) {
            var log = "";
            var devices = [];
            var uuids = Object.keys(lastRssiByUuid);
            uuids.sort();
            uuids.forEach(function(uuid) {
                var device = {
                    name: deviceNameByUuid[uuid], 
                    rssi: lastRssiByUuid[uuid]
                };
                devices.push(device);
            });
            
            worker.postMessage(devices);

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

module.exports = ee;
