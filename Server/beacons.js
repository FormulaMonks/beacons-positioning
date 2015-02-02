"use strict";

var Worker = require('webworker-threads').Worker;
var EventEmitter = require("events").EventEmitter;
var noble = require("noble");
var calculator = require("./calculator");

// var lastRssiByUuid = {};
// var deviceNameByUuid = {};

var worker = new Worker(calculator);

var ee = new EventEmitter();
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
        var device = {
            name: peripheral.advertisement.localName, 
            rssi: rssi
        };
        
        worker.postMessage([device]);
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
