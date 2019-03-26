# PSEADashboardFilterGenerator
THIS SOFTWARE IS COVERED BY [THIS DISCLAIMER](https://raw.githubusercontent.com/thedges/Disclaimer/master/disclaimer.txt).

A utility Lightning Component to help generate the JSON filter for the "Wave Dashboard" Lightning Component that comes standard with Salesforce.

![alt text](https://github.com/thedges/PSEADashboardFilterGenerator/blob/master/PSEADashboardFilterGenerator.gif "Sample Image")

## Setup
  1. Install the package from the <b>Deploy to Salesforce</b> button below
  2. Add the permission set ("EA Filter Gen") to your user. This provides access to tab ("EA Filter Gen") tab.
  3. Create <b>Remote Site Setting</b> per details below for your base URL: https://[domain].my.salesforce.com
  4. Use the component. The component is very easy to use:

     * Select the Einstein Analytics (Wave) dashboard you want to bind to and the Salesforce Object
     * Create individual rows for each filter you want to bind between the dashboard and Salesforce object
     * The filter JSON will be auto-created in bottom as you build the filter. Just copy the text to clipboard (use the convenience button in top-right) and paste in the filter section of your Wave Dashboard Lightning Component configuration.

If you get an error pop-up like the following, it means you don't have a Remote Site Setting configured for your local Wave APIs.

![alt text](https://github.com/thedges/PSEADashboardFilterGenerator/blob/master/unauthorized-endpoint.png "Sample Image")

Go to <b>Setup > Remote Site Settings</b> can create a new entry like following. This should resolve the issue:

![alt text](https://github.com/thedges/PSEADashboardFilterGenerator/blob/master/remote-site.png "Sample Image")

<a href="https://githubsfdeploy.herokuapp.com">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>
