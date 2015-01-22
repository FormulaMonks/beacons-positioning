var noble = require('noble');
var charm = require('charm')();

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
var waitFor = 2;

var distanceByUuid = {};

function calculateDistance(txPower, rssi) {
	if (rssi == 0) {
		return -1.0;
	}

	var ratio = rssi * 1.0/txPower;

	if (ratio < 1.0) {
		return Math.pow(ratio, 10);
	} else {
		var accuracy = (0.89976)*Math.pow(ratio,7.7095) + 0.111;
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
		if (Math.abs(distance - lastValue) < 0.4) { // to avoid quick jumps in signal
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
	console.log('peripheral discovered (' + peripheral.uuid+ '):');

	peripheral.on('rssiUpdate', function(rssi) {
		lastRssiByUuid[peripheral.uuid] = rssi;

		if (Object.keys(lastRssiByUuid).length == waitFor) {
			var log = "";
			var uuids = Object.keys(lastRssiByUuid);
			uuids.sort();
			uuids.forEach(function(uuid) {
				log += "distance: " + calculateDistanceFor(uuid, lastRssiByUuid[uuid]).toFixed(2) + "m device: " + uuid + " | ";
			});
			charm.reset().write(log);
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

