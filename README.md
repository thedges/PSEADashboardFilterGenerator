# PSEADashboardFilterGenerator
A utility Lightning Component to help generate the JSON filter for the "Wave Dashboard" Lightning Component that comes standard with Salesforce.

![alt text](https://github.com/thedges/PSEADashboardFilterGenerator/blob/master/PSEADashboardFilterGenerator.png "Sample Image")

This package creates a tab called "EA Filter Gen" that includes the component. The component is very easy to use:

  1. Select the Einstein Analytics (Wave) dashboard you want to bind to and the Salesfoce Object
  2. Create individual rows for each filter you want to bind between the dashboard and Salesforce object
  3. The filter JSON will be auto-created in bottom as you build the filter. Just copy the text to clipboard (use the convenience button in top-right) and past in the filter section of your Wave Dashboard Lightning Component configuration.

If you get an error pop-up like the following, it means you don't have a Remote Site Setting configured for your local Wave APIs.

![alt text](https://github.com/thedges/PSEADashboardFilterGenerator/blob/master/unauthorized-endpoint.png "Sample Image")

Go to <b>Setup > Remote Site Settings</b> can create a new entry like following. This should resolve the issue:

![alt text](https://github.com/thedges/PSEADashboardFilterGenerator/blob/master/remote-site.png "Sample Image")

<b>WARNING:</b> One issue is noted with the tool so far. If you create one of more field filters and then delete them all, you will get an error like below the next time you try to create and configure a new field filter. For now until I can figure this out, just refresh the page to reload the component to get rid of this.

![alt text](https://github.com/thedges/PSEADashboardFilterGenerator/blob/master/error.png "Sample Image")

<a href="https://githubsfdeploy.herokuapp.com">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>
