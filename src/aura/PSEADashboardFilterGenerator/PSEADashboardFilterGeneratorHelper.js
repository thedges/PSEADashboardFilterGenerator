({
	getDashboards : function(component) {
		console.log('helper.getDashboards invoked...');
        var self = this;

        var action = component.get("c.getDashboardList");
        action.setParams({ 'sessionId' : component.get("v.sessionId") });

        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
				var resp = actionResult.getReturnValue();
				//console.log('dashboards=' + JSON.stringify(resp));
                component.set("v.dashboards", resp);
        
                self.getObjects(component);
            }
            else {
                self.hideSpinner(component);
                self.handleErrors(actionResult.getError());
            }
            
        });
        $A.enqueueAction(action);
    },
    getDashboard : function(component) {
		console.log('helper.getDashboard invoked...');
        var self = this;

        var action = component.get("c.getDashboardById");
        action.setParams({ 'sessionId' : component.get("v.sessionId"),
                           'dashboardId' : component.get("v.selDashboardId") });

        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
                self.hideSpinner(component);
				var resp = actionResult.getReturnValue();
                component.set("v.selDashboardDef", resp);
                component.set("v.selDatasetDef", null);
                component.set("v.selDatasetXMDS", null);
			    //console.log('dashboard=' + JSON.stringify(resp));
            }
            else {
                self.hideSpinner(component);
                self.handleErrors(actionResult.getError());
            }
            
        });
        $A.enqueueAction(action);
    },
    getObjects : function(component) {
		console.log('helper.getObjectDefs invoked...');
        var self = this;

        var action = component.get("c.getObjectNameList");
        
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
                self.hideSpinner(component);
				var resp = actionResult.getReturnValue();
                component.set("v.objects", resp);
            }
            else {
                self.hideSpinner(component);
                self.handleErrors(actionResult.getError());
            }
            
        });
        $A.enqueueAction(action);
	},
    getObjectDef : function(component) {
		console.log('helper.getObjectDef invoked...');
        var self = this;

        var action = component.get("c.getObjectDefByName");
        action.setParams({ 'objectName' : component.get("v.selObjectName") });
        
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
                self.hideSpinner(component);
                var resp = actionResult.getReturnValue();
                //console.log('selObject=' + JSON.stringify(resp));
                component.set("v.selObjectDef", resp);

                
            }
            else {
                self.hideSpinner(component);
                self.handleErrors(actionResult.getError());
            }
            
        });
        $A.enqueueAction(action);
	},
    getDatasetDef : function(component) {
		console.log('helper.getDatasetDef invoked...');
        var self = this;

        var idx = component.get("v.selIndex");
        var filters = component.get("v.filters");
        var action = component.get("c.getDatasetById");
        action.setParams({ 'sessionId' : component.get("v.sessionId"),
                           'datasetId' : filters[idx].selDatasetId });
        
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
                self.hideSpinner(component);
                var idx = component.get("v.selIndex");
                console.log("idx=" + idx);
                var filters = component.get("v.filters");
                //console.log("filters=" + JSON.stringify(filters));
                var resp = actionResult.getReturnValue();
                //console.log('selDatasetDef=' + JSON.stringify(resp));
                filters[idx].selDatasetDef = resp;
                component.set("v.filters", filters);
                this.getDatasetXMDS(component);
            }
            else {
                self.hideSpinner(component);
                self.handleErrors(actionResult.getError());
            }
            
        });
        $A.enqueueAction(action);
	},
    getDatasetXMDS : function(component) {
		console.log('helper.getDatasetXMDS invoked...'); 
        var self = this;

        var idx = component.get("v.selIndex");
        console.log("idx=" + idx);
        var filters = component.get("v.filters");
        //console.log("filters=" + JSON.stringify(filters));
        var datasetDef = filters[idx].selDatasetDef;
        //console.log("datasetDef=" + datasetDef);

        var action = component.get("c.getDatasetXMDSById");
        action.setParams({ 'sessionId' : component.get("v.sessionId"),
                           'datasetId' : datasetDef.id,
                           'versionId' : datasetDef.currentVersionId });
        
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
                console.log('helper.getDatasetXMDS response...');
                self.hideSpinner(component);
                var idx = component.get("v.selIndex");
                console.log('idx=' + idx);
                var filters = component.get("v.filters");
                console.log('filters=' + JSON.stringify(filters));
                var resp = actionResult.getReturnValue();
                console.log('selDatasetXMDS=' + JSON.stringify(resp));
                filters[idx].selDatasetXMDS = resp;
                console.log('filters=' + JSON.stringify(filters));
                component.set("v.filters", filters);
            }
            else {
                self.hideSpinner(component);
                self.handleErrors(actionResult.getError());
            }
            
        });
        $A.enqueueAction(action);
	},
    handleErrors : function(errors) {
        let toastParams = {
            title: "Error!",
            message: "Unknown error", // Default error message
            type: "error",
            mode: "sticky"
        };
        // Pass the error message if any
        if (errors && Array.isArray(errors) && errors.length > 0) {
            toastParams.message = errors[0].message;
        }
        // Fire error toast
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
    },
    showSpinner:function(component){
        component.set("v.IsSpinner",true);
    },
    hideSpinner:function(component){
        component.set("v.IsSpinner",false);
    },
    getSessionID:function(component){
        console.log('onObjectSel invoked...');

        var self = this;
        var url = window.location.href;
        var arr = url.split("/");
        var dotarr = arr[2].split(".");
        
        var vfOrigin = "https://" + dotarr[0] + ".my.salesforce.com";
        window.addEventListener("message", function(event) {
            if (event.origin !== vfOrigin) {
                // Not the expected origin: Reject the message!
                return;
            }
            // Only handle messages we are interested in
            if (event.data.name === "PSWaveDashboardFilterGenerator") {
                // Handle the message
                //console.log(event.data.payload);
                component.set("v.sessionId", event.data.payload);
                self.getDashboards(component);
            }
        }, false);
    }
})