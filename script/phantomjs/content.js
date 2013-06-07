var page = require('webpage').create();
var system = require('system');
var address = system.args[1];
page.open(address, function (status) {
	if (status !== 'success') {
		console.log('Unable to access network');
	} else {
		console.log(console.log('<we_dont_need_roads>'));
		console.log(page.evaluate(function () {
			function getAllElementsWithAttributes(attributes) {
				var matchingElements = [];
				var allElements = document.getElementsByTagName('*');
				for (var i = 0; i < allElements.length; i++) {
					for (var n = 0; n < attributes.length; n++) {
						if (allElements[i].getAttribute(attributes[n])) {
							// Element exists with attribute. Add to array.
							matchingElements.push(allElements[i]);
						}
					}
				}
				return matchingElements;
			}

			var arr = getAllElementsWithAttributes(['href', 'src']);
			for (var i = 0; i < arr.length; i++) {
				if (arr[i].getAttribute('href')) {
					arr[i].setAttribute('href', arr[i].href);
				} else if (arr[i].getAttribute('src')) {
					arr[i].setAttribute('src', arr[i].src);
				}
			}
			return document.getElementsByTagName('html')[0].outerHTML;
		}));
		console.log('</we_dont_need_roads>');
		console.log(page.evaluate(function () {
			return document.body.innerText;
		}));
	}
	phantom.exit();
});
