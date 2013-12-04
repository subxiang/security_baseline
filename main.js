/**
 * main.js
 */
// Production steps of ECMA-262, Edition 5, 15.4.4.19
// Reference: http://es5.github.com/#x15.4.4.19
if (!Array.prototype.map) {
  Array.prototype.map = function(callback, thisArg) {

    var T, A, k;

    if (this == null) {
      throw new TypeError(" this is null or not defined");
    }

    // 1. Let O be the result of calling ToObject passing the |this| value as the argument.
    var O = Object(this);

    // 2. Let lenValue be the result of calling the Get internal method of O with the argument "length".
    // 3. Let len be ToUint32(lenValue).
    var len = O.length >>> 0;

    // 4. If IsCallable(callback) is false, throw a TypeError exception.
    // See: http://es5.github.com/#x9.11
    if (typeof callback !== "function") {
      throw new TypeError(callback + " is not a function");
    }

    // 5. If thisArg was supplied, let T be thisArg; else let T be undefined.
    if (thisArg) {
      T = thisArg;
    }

    // 6. Let A be a new array created as if by the expression new Array(len) where Array is
    // the standard built-in constructor with that name and len is the value of len.
    A = new Array(len);

    // 7. Let k be 0
    k = 0;

    // 8. Repeat, while k < len
    while(k < len) {

      var kValue, mappedValue;

      // a. Let Pk be ToString(k).
      //   This is implicit for LHS operands of the in operator
      // b. Let kPresent be the result of calling the HasProperty internal method of O with argument Pk.
      //   This step can be combined with c
      // c. If kPresent is true, then
      if (k in O) {

        // i. Let kValue be the result of calling the Get internal method of O with argument Pk.
        kValue = O[ k ];

        // ii. Let mappedValue be the result of calling the Call internal method of callback
        // with T as the this value and argument list containing kValue, k, and O.
        mappedValue = callback.call(T, kValue, k, O);

        // iii. Call the DefineOwnProperty internal method of A with arguments
        // Pk, Property Descriptor {Value: mappedValue, : true, Enumerable: true, Configurable: true},
        // and false.

        // In browsers that support Object.defineProperty, use the following:
        // Object.defineProperty(A, Pk, { value: mappedValue, writable: true, enumerable: true, configurable: true });

        // For best browser support, use the following:
        A[ k ] = mappedValue;
      }
      // d. Increase k by 1.
      k++;
    }

    // 9. return A
    return A;
  };
}

var deviceTypes = [
    {id : 'DT_AP', label : 'Access Point'},
    {id : 'DT_FIREWALL', label : 'Firewall'},
    {id : 'DT_ROUTER', label : 'Router'},
    {id : 'DT_SWITCH', label : 'Switch'} ];


require(['dijit/form/Form', 'dojo/json', 'dojo/text!./syslogCfg.js', 'dijit/Dialog', 'dijit/form/TextBox', 'dijit/form/ValidationTextBox', 'dijit/form/Button', 'dijit/form/CheckBox', 'dijit/form/Select', 'dijit/form/FilteringSelect', 'dojo/data/ObjectStore', 'dojo/store/Memory', 'dojo/dom', 'dojo/ready'],
	function(Form, JSON, syslogCfg, Dialog, TextBox, ValidationTextBox, Button, CheckBox, Select, FilteringSelect, ObjectStore, Memory, dom, ready) {

	ready(function() {
		var db = new Memory({data: JSON.parse(syslogCfg), idProperty: 'name'});

		var deviceName = new ValidationTextBox({
			pattern: '[a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9]',
			invalidMessage: 'Invalid device name',
			lowercase: true,
			placeHolder: 'e.g., sgjusw-core-01',
			required: true
		}, 'deviceName');

		var deviceType = new Select({
			store: createMemStore(deviceTypes),
			required: true
		}, "deviceType");

		var secret = new ValidationTextBox({
			placeHolder: 'e.g., SeCreTpAsSWorD',
			required: true
		}, 'secret');

		var infName = new ValidationTextBox({
//			pattern: '\\w+',
//			invalidMessage: 'Invalid interface name',
//			lowercase: true,
			placeHolder: 'e.g., vnet1',
			required: true
		}, 'infName');

		var country = new FilteringSelect({
			store: db,
			required: true,
			searchAttr: 'name',
			fetchProperties: {sort: [{attribute: 'name', descending: false}]},
			onChange: function(val) {
				dijit.byId('city').set('store', new Memory({data: this.item.cities, idProperty: 'name'}));
				dijit.byId('city').set('value', null);
			}
		}, 'country');

		var city = new FilteringSelect({
			required: true
		}, 'city');

		dom.byId('localMonitorPanel').style.display = 'none';

		var localMonitor = new CheckBox({
			onChange: function(val) {
				toggleDisplay('localMonitorPanel');
				dijit.byId('snmpIP').required = val;
				dijit.byId('snmpCommunity').required = val;
			}
		}, 'localMonitor');

		var snmpIP = new ValidationTextBox({
			placeHolder: 'e.g., 10.138.1.123',
			pattern: '(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])',
			invalidMessage: 'Invalid IPv4 address',
			required: false
		}, 'snmpIP');

		var snmpCommunity = new ValidationTextBox({
			placeHolder: 'e.g., SomeString',
			required: false
		}, 'snmpCommunity');

		var submit = new Button({
			label: 'Generate',
			onClick: function() {
				if (dijit.byId('myForm').validate()) {
					var params = {
						deviceType: '',
						deviceName: '',
						secret: '',
						infName: '',
						country: '',
						city: '',
						snmpIP: '',
						snmpCommunity: ''
					};

					for (var key in params) {
						params[key] = dijit.byId(key).get('value');
					}

					var cfg = dijit.byId('city').get('item')['config'];
					for (var key in cfg) {
						params[key] = cfg[key];
					}

					var output = new Dialog({
						title: "Baseline Configuration for Device <b>" + params['deviceName'] + "</b> (Click to Select All)",
						content: generate(getTemplate(params['deviceType']), params),
						onClick: function() {
							selectText(this.domNode.getElementsByTagName('pre')[0]);
						}
					});
					output.show();
				}
			}
		}, 'submit');

		var myForm = new Form({}, 'myForm');

		function createMemStore(data, id, label) {
			var memory = new Memory({
				data: data,
				idProperty: id || 'id'
			});
			return new ObjectStore({objectStore: memory, labelProperty: label || 'label'});
		}

		function toggleDisplay(panelId) {
			var panel = dom.byId(panelId);
			panel.style.display = panel.style.display == 'none' ? 'block' : 'none';
		}

		function selectText(dom) {
		    var sel, range;
		    if (window.getSelection && document.createRange) {
		        range = document.createRange();
		        range.selectNode(dom);
		        sel = window.getSelection();
		        sel.removeAllRanges();
		        sel.addRange(range);
		    } else if (document.body.createTextRange) {
		        range = document.body.createTextRange();
		        range.moveToElementText(dom);
		        range.select();
		    }
		}

		function generate(template, params){
			template = template.replace(/\$(\w+)/g, function(word, key) {
				if (!params[key] || params[key] instanceof Array) {
					return word;
				} else {
					return params[key];
				}
			});

			return template.replace(/^.*\$(\w+).*$/gm, function(line, key) {
	        	if (params[key]) {
	        		return params[key].map(function(item) {
	                    return line.replace("$" + key, item);
	                }).join("\n");
	        	} else {
	        		return "";
	        	}
		    });
		}

		function getTemplate(deviceType) {
			switch(deviceType) {
			case "DT_FIREWALL":
				return dom.byId("template_firewall").innerHTML;
			case "DT_SWITCH":
				return dom.byId("template_switch").innerHTML;
			case "DT_ROUTER":
				return dom.byId("template_router").innerHTML;
			case "DT_AP":
				return dom.byId("template_ap").innerHTML;
			default:
			}
		}
	});
});