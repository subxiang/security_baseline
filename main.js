/**
 * main.js
 */
var deviceTypes = [
    {id : 'DT_AP', label : 'Access Point'},
    {id : 'DT_FIREWALL', label : 'Firewall'},
    {id : 'DT_ROUTER', label : 'Router'},
    {id : 'DT_SWITCH', label : 'Switch'} ];


require(['dijit/form/Form', 'dojo/json', 'dojo/text!./syslogCfg.json', 'dijit/Dialog', 'dijit/form/TextBox', 'dijit/form/ValidationTextBox', 'dijit/form/Button', 'dijit/form/CheckBox', 'dijit/form/Select', 'dijit/form/FilteringSelect', 'dojo/data/ObjectStore', 'dojo/store/Memory', 'dojo/dom', 'dojo/ready'],
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
			pattern: '\\w+',
			invalidMessage: 'Invalid interface name',
			lowercase: true,
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
							selectText(this.domNode.querySelector('pre'));
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
			return template.replace(/^.*\n$/gm, function(line) {
		        var m = line.match(/\$(\w+)/);
		        if (m) {
		        	var value = params[m[1]];
		        	if (value) {
		        		if (value instanceof Array) {
			                return value.map(function(item) {
			                    return line.replace(m[0], item);
			                }).join("\n");
			            } else {
			                return line.replace(m[0], value);
			            }
		        	} else {
		        		return "";
		        	}
		        } else {
		        	return line;
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