({
	doInit: function (component, event, helper) {
		console.log('doInit invoked...');

		//component.set("v.filters", []);

		helper.showSpinner(component);
		helper.getSessionID(component);
	},
	onObjectSel: function (component, event, helper) {
		console.log('onObjectSel invoked...');
		console.log('  > selObjectName=' + component.get("v.selObjectName"));

		if (component.get("v.selObjectName") != "") {
			helper.showSpinner(component);
			helper.getObjectDef(component);
		}

	},
	onDashboardSel: function (component, event, helper) {
		console.log('onDashboardSel invoked...');
		var db = component.get("v.selDashboardId");
		//console.log(JSON.stringify(db));
		if (component.get("v.selDashboardId") != "") {
			helper.showSpinner(component);
			helper.getDashboard(component);
		}
	},
	onDatasetSel: function (component, event, helper) {
		console.log('onDatasetSel invoked...');
		var db = component.get("v.selDatasetId");
		//console.log(JSON.stringify(db));
		if (component.get("v.selDatasetId") != "") {
			helper.showSpinner(component);
			helper.getDatasetDef(component);
		}
	},
	addFilter: function (component, event, helper) {
		var filters = component.get("v.filters");


		if (component.get("v.selDashboardId") == null || component.get("v.selDashboardId") == "" ||
			component.get("v.selObjectName") == null || component.get("v.selObjectName") == "") {
			var toastEvent = $A.get("e.force:showToast");
			toastEvent.setParams({
				title: 'Warning',
				message: 'An Einstein Dashboard and Salesfoce sObject must be chosen before filters can be created!',
				duration: ' 5000',
				type: 'warning',
				mode: 'dismissible'
			});
			toastEvent.fire();
		} else {

			var filter = {
				selDataSetId: null,
				selDatasetDef: null,
				selDatasetXMDS: null,
				selDatasetFieldName: null,
				selObjectName: null,
				selObjectDef: null,
				selFieldName: null,
				selFieldType: "dimension",
				selOperation: "matches",
				selectionFlag: null
			};

			filters.push(filter);

			component.set("v.filters", filters);
		}

	},
	deleteFilter: function (component, event, helper) {
		console.log('deleteFilter invoked...');
		var idx = parseInt(event.getSource().get('v.title'), 10);
		console.log('idx=' + idx);
		var filters = component.get("v.filters");

		//filters.splice(idx, 1);
		//console.log('filters=' + JSON.stringify(filters));
		//component.set("v.filters", filters);

	
        var newFilters = [];
		for (var i = 0; i < filters.length; i++) {
			if (i != idx)
			{
				newFilters.push(filters[i]);
			}
		}
		//component.set("v.filters", []);
		console.log('newFilters=' + JSON.stringify(newFilters));
		component.set("v.filters", newFilters);

	},
	onDatasetChange: function (component, event, helper) {
		console.log('onDatasetChange invoked...');

		var idx = parseInt(event.getSource().get('v.name'), 10);
		console.log('idx=' + idx);
		component.set("v.selIndex", idx);

		var filters = component.get("v.filters");
		var datasetId = filters[idx].selDatasetId;
		//console.log(JSON.stringify(datasetId));
		if (datasetId != "") {
			helper.showSpinner(component);
			helper.getDatasetDef(component);
		}

	},
	onMeasureChange: function (component, event, helper) {
		console.log('onMeasureChange invoked...');
		var filters = component.get("v.filters");
		var idx = parseInt(event.getSource().get('v.name'), 10);
		filters[idx].selDatasetFieldName = null;
		component.set("v.filters", filters);

	},
	copyJSON: function (component, event, helper) {
		var filterJSON = document.getElementById("filterJSON");
		filterJSON.select();
		document.execCommand("copy");

		var toastEvent = $A.get("e.force:showToast");
			toastEvent.setParams({
				title: 'Copy to Clipboard',
				message: 'The Wave Dashboard Filter JSON has been copied to clipboard!',
				duration: ' 500',
				type: 'info',
				mode: 'dismissible'
			});
			toastEvent.fire();
	},
	onFiltersChange: function (component, event, helper) {
		console.log('onFiltersChange invoked...');
		var filters = component.get("v.filters");

		var filterJSON = document.getElementById("filterJSON");

		//console.log(JSON.stringify(filters));
		if (filters != null && filters.length > 0) {
			var json = {};
			json['datasets'] = {};
			
			for (var i = 0; i < filters.length; i++) {
				
				var filter = filters[i];
				if (filter.selDatasetDef != null && filter.selDatasetDef.name != null)
				{
				  var datasetName = filter.selDatasetDef.name;
				  if (json.datasets[datasetName] == null)
				  {
					json.datasets[datasetName] = [];
				  }

				  var fieldFilter = {};
				  if (filter.selDatasetFieldName != null)
				  {
					
					fieldFilter.fields = [filter.selDatasetFieldName];
				  }

				  if (filter.selectionFlag != null && filter.selectionFlag == true)
				  {
                    fieldFilter.selection = ["$" + filter.selFieldName];
				  }

				  if (filter.selFieldName != null)
				  {
					fieldFilter.filter = {"operator":filter.selOperation,"values":["$" + filter.selFieldName]};
				  }
				  json.datasets[datasetName].push(fieldFilter);
				}

			}

            var regex = new RegExp('"', 'g');
            if (component.get("v.prettyPrint"))
            {
                filterJSON.value = JSON.stringify(json, null, 2).replace(regex, '\'');
            }
            else
            {
			  filterJSON.value = JSON.stringify(json).replace(regex, '\'');
            }
		}
		else
		{
			if (filterJSON != null) filterJSON.value = "";
		}
	},
    reset: function (component, event, helper) {
        component.set("v.filters", []);
        helper.getDashboards(component);
    }


})