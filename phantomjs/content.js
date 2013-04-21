var page = require('webpage').create();
var system = require('system');
var address = system.args[1];
page.open(address, function (status) {
    if (status !== 'success') {
        console.log('Unable to access network');
	} else {
		var p = page.evaluate(function () {
			return document.getElementsByTagName('html')[0].outerHTML;
		});
		console.log(p);
	}
	phantom.exit();
});
