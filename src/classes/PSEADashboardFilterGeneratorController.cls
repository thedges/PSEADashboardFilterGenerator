global class PSEADashboardFilterGeneratorController {
    public static final String HTTP_GET  = 'GET';
    public static final String HTTP_POST = 'POST';

    public static final Integer DASHBOARD_PAGE_SIZE = 50;

    @AuraEnabled
    public static List<NameLabel> getDashboardList(String sessionId)
    {
        try {
            List<NameLabel> dbList = new List<NameLabel>();
            String resp;
            DashboardsDef dDef;
            Integer i = 0;
            String nextPageUrl = null;

            do {
                resp = apiDashboards(sessionId, nextPageUrl);
                dDef = (DashboardsDef)JSON.deserialize(resp, DashboardsDef.class);
                for (DashboardDef db : dDef.dashboards)
                {
                    dbList.add(new NameLabel(db.name, db.label, db.id));
                }
                nextPageUrl = dDef.nextPageUrl;
            } while (nextPageUrl != null);

            dbList.sort();
            //System.debug('Dashboard Name List = ' + JSON.serialize(dbList));
            return dbList;
        }
        catch (AuraHandledException ae) {
            throw ae;
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

    }

    @AuraEnabled
    public static DashboardDef getDashboardById(String sessionId, String dashboardId)
    {
        try {
            String resp = apiDashboardById(sessionId, dashboardId);
            DashboardDef def = (DashboardDef)JSON.deserialize(resp, DashboardDef.class);
            def.datasets.sort();
            return def;
        }
        catch (AuraHandledException ae) {
            throw ae;
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

    }


    @AuraEnabled
    public static DataSetDef getDatasetById(String sessionId, String datasetId)
    {
        try {
            String resp = apiDatasetById(sessionId, datasetId);
            DataSetDef ds = (DataSetDef)JSON.deserialize(resp, DataSetDef.class);
            return ds;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static DataSetXMDSDef getDatasetXMDSById(String sessionId, String datasetId, String versionId)
    {
        try {
            String resp = apiDatasetXMDSById(sessionId, dataSetId, versionId);
            //System.debug('resp=' + resp);
            //return null;
            DataSetXMDSDef ds = (DataSetXMDSDef)JSON.deserialize(resp, DataSetXMDSDef.class);
            if (ds.dates != null) ds.dates.sort();
            if (ds.dimensions != null) ds.dimensions.sort();
            if (ds.measures != null) ds.measures.sort();
            return ds;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<NameLabel> getObjectNameList()
    {
        try {
            List<NameLabel> objList = new List<NameLabel>();

            List<Schema.sObjectType> allObjects = Schema.getGlobalDescribe().Values();
            for (Schema.sObjectType ot : allObjects)
            {
                Schema.DescribeSObjectResult objDesc = ot.getDescribe();

                if (objDesc.getKeyPrefix() != null &&
                        objDesc.isCreateable() &&
                        !objDesc.isCustomSetting()  &&
                        objDesc.isMruEnabled())
                {
                    objList.add(new NameLabel(objDesc.name, objDesc.label, null));
                }
            }

            objList.sort();

            return objList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<ObjectDef> getObjectDefList()
    {
        try {
            List<ObjectDef> objList = new List<ObjectDef>();

            List<Schema.sObjectType> allObjects = Schema.getGlobalDescribe().Values();
            for (Schema.sObjectType ot : allObjects)
            {
                Schema.DescribeSObjectResult objDesc = ot.getDescribe();

                if (objDesc.getKeyPrefix() != null &&
                        objDesc.isCreateable() &&
                        !objDesc.isCustomSetting()  &&
                        objDesc.isMruEnabled())
                {
                    ObjectDef objDef = new ObjectDef();
                    objDef.name = objDesc.name;
                    objDef.label = objDesc.label;

                    Map<String, Schema.SObjectField> fieldMap = objDesc.fields.getMap();
                    List<String> keys = new List<String>(fieldMap.keySet());
                    for (String key : keys)
                    {
                        Schema.DescribeFieldResult descField = fieldMap.get(key).getDescribe();
                        objDef.addField(descField.name, descField.label, String.valueOf(descField.type));
                    }

                    objDef.fields.sort();

                    objList.add(objDef);
                }
            }

            return objList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    } 

    @AuraEnabled
    public static ObjectDef getObjectDefByName(String objectName)
    {
        try {
            Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
            Schema.DescribeSObjectResult objDesc = objType.getDescribe();

            ObjectDef objDef = new ObjectDef();
            objDef.name = objDesc.name;
            objDef.label = objDesc.label;

            Map<String, Schema.SObjectField> fieldMap = objDesc.fields.getMap();
            List<String> keys = new List<String>(fieldMap.keySet());
            for (String key : keys)
            {
                Schema.DescribeFieldResult descField = fieldMap.get(key).getDescribe();
                objDef.addField(descField.name, descField.label, String.valueOf(descField.type));
            }
            objDef.fields.sort();
            return objDef;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static ObjectDef getObjectDefByRecordId(Id recordId)
    {
        try {
            // return metadata for specific object
            String sObjName = recordId.getSObjectType().getDescribe().getName();
            return getObjectDefByName(sObjName);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // ************************************************* //
    // classes to query Analytics API //
    // ************************************************* //
    private static String apiDashboards()
    {
        String resp = apiDashboards(null, null);
        return resp;
    }


    private static String apiDashboards(String sessionId, String nextPage)
    {
        String endpoint = null;
        if (nextPage != null)
        {
            endpoint = nextPage;
        }
        else {
            endpoint = '/services/data/v43.0/wave/dashboards?pageSize=' + DASHBOARD_PAGE_SIZE;
        }

        String resp = callAPI(HTTP_GET, endpoint, null, sessionId);
        return resp;
    }

    private static String apiDashboardById(String sessionId, String dashboardId)
    {
        String resp = callAPI(HTTP_GET, '/services/data/v43.0/wave/dashboards/' + dashboardId, null, sessionId);
        return resp;
    }


    private static String apiDatasetById(String sessionId, String datasetId)
    {
        String resp = callAPI(HTTP_GET, '/services/data/v43.0/wave/datasets/' + datasetId, null, sessionId);
        return resp;
    }


    private static String apiDatasetXMDSByVersionUrl(String sessionId, String endpoint)
    {
        String resp = callAPI(HTTP_GET, endpoint + '/xmds/main', null, sessionId);
        return resp;
    }

    private static String apiDataSetXMDSById(String sessionId, String datasetId, String versionId)
    {

        String resp = callAPI(HTTP_GET, '/services/data/v43.0/wave/datasets/' + datasetId + '/versions/' + versionId + '/xmds/main', null, sessionId);
        return resp;
    }

    private static String testAPI(String method, String endpoint, String body)
    {
        Http http = new Http();
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();

        httpReq.setMethod(method);
        httpReq.setEndpoint(endpoint);
        httpReq.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
         System.debug('endpoint=' + httpReq.getEndpoint());

        httpRes = http.send(httpReq);

        if (httpRes.getStatusCode() != 200)
        {
            throw new AuraHandledException('Wave API REST call failed with: Code=' + httpRes.getStatusCode() + ' Status=' + httpRes.getStatus());
        }

        return httpRes.getBody();
    }

    private static String callAPI(String method, String endpoint, String body, String sessionId)
    {
        Http http = new Http();
        HttpRequest httpReq = new HttpRequest();   
        HttpResponse httpRes = new HttpResponse();

        httpReq.setMethod(method);
        httpReq.setHeader('Content-Type', 'application/json');

        if (sessionId == null) sessionId = UserInfo.getSessionId();

        httpReq.setHeader('Authorization', 'Bearer ' + sessionId);

        String baseURL = URL.getSalesforceBaseUrl().toExternalForm();

        httpReq.setEndpoint(baseURL + endpoint);
         System.debug('endpoint=' + httpReq.getEndpoint());

        httpRes = http.send(httpReq);

        if (httpRes.getStatusCode() != 200)
        {
            throw new AuraHandledException('Wave API REST call failed with: Code=' + httpRes.getStatusCode() + ' Status=' + httpRes.getStatus());
        }

        return httpRes.getBody();
    }

    // ************************************************* //
    // classes to parse the Anayltics Def REST responses //
    // ************************************************* //
    public class DashboardsDef
    {
        public List<DashboardDef> dashboards;
        public String nextPageUrl;
        public String totalSize;
    }

    public class DashboardDef implements Comparable
    {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String label;
        public String description;
        public String type;
        public String url;

        @AuraEnabled public List<DataSetDef> datasets;

        public Integer compareTo(Object compareTo) {
            DashboardDef comp = (DashboardDef)compareTo;

            Integer returnValue = 0;
            if (label > comp.label )
            {
                returnValue = 1;
            }
            else if (label < comp.label)
            {
                returnValue = -1;
            }
            return returnValue;
        }
    }

    public class DataSetDef implements Comparable
    {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String label;
        public String url;
        @AuraEnabled public String currentVersionId;
        @AuraEnabled public String currentVersionUrl;

        @AuraEnabled public DataSetXMDSDef xmds;

        public Integer compareTo(Object compareTo) {
            DataSetDef comp = (DataSetDef)compareTo;

            Integer returnValue = 0;
            if (label > comp.label )
            {
                returnValue = 1;
            }
            else if (label < comp.label)
            {
                returnValue = -1;
            }
            return returnValue;
        }
    }

    public class DataSetXMDSDef
    {
        public String type;
        public String url;

        @AuraEnabled public List<DateDef> dates;
        @AuraEnabled public List<StandardFieldDef> dimensions;
        @AuraEnabled public List<StandardFieldDef> measures;
    }

    public class DateDef implements Comparable
    {
        @AuraEnabled public String label;
        @AuraEnabled public String fullyQualifiedName;
        @AuraEnabled public String alias;
        public String description;

        @AuraEnabled public DateFieldDef fields;

        public Integer compareTo(Object compareTo) {
            DateDef comp = (DateDef)compareTo;

            Integer returnValue = 0;
            if (label > comp.label )
            {
                returnValue = 1;
            }
            else if (label < comp.label)
            {
                returnValue = -1;
            }
            return returnValue;
        }

    }

    public class DateFieldDef
    {
        @AuraEnabled public String day;
        @AuraEnabled public String epochDay;
        @AuraEnabled public String epochSecond;
        @AuraEnabled public String fullField;
        @AuraEnabled public String hour;
        @AuraEnabled public String minute;
        @AuraEnabled public String month;
        @AuraEnabled public String quarter;
        @AuraEnabled public String second;
        @AuraEnabled public String week;
        @AuraEnabled public String year;
    }

    public class StandardFieldDef implements Comparable
    {
        @AuraEnabled public String field;
        @AuraEnabled public String label;

        public Integer compareTo(Object compareTo) {
            StandardFieldDef comp = (StandardFieldDef)compareTo;

            Integer returnValue = 0;
            if (label > comp.label )
            {
                returnValue = 1;
            }
            else if (label < comp.label)
            {
                returnValue = -1;
            }
            return returnValue;
        }
    }

    // *************************** //
    // classes for Object metadata //
    // *************************** //
    public class ObjectDef
    {
        @AuraEnabled public String name;
        @AuraEnabled public String label;

        @AuraEnabled  public List<ObjectField> fields = new List<ObjectField>();

        public void addField(String name, String label, String ftype)
        {
            ObjectField fld = new ObjectField();
            fld.name = name;
            fld.label = label;
            fld.ftype = ftype;
            fields.add(fld);
        }
    }

    public class ObjectField implements Comparable
    {
        @AuraEnabled public String name;
        @AuraEnabled public String label;
        @AuraEnabled public String ftype;

        public Integer compareTo(Object compareTo) {
            ObjectField comp = (ObjectField)compareTo;

            Integer returnValue = 0;
            if (label > comp.label )
            {
                returnValue = 1;
            }
            else if (label < comp.label)
            {
                returnValue = -1;
            }
            return returnValue;
        }
    }

    public class NameLabel implements Comparable
    {
        @AuraEnabled public String name;
        @AuraEnabled public String label;
        @AuraEnabled public String id;

        public NameLabel()
        {

        }

        public NameLabel(String name, String label, String id)
        {
            this.name = name;
            this.label= label;
            this.id= id;
        }

        public Integer compareTo(Object compareTo) {
            NameLabel comp = (NameLabel)compareTo;

            Integer returnValue = 0;
            if (label > comp.label )
            {
                returnValue = 1;
            }
            else if (label < comp.label)
            {
                returnValue = -1;
            }
            return returnValue;
        }
    }

    public static void test()
    {
        /*
        List<NameLabel> objList = getObjectNameList();
        System.debug('objList=' + JSON.serialize(objList));

        ObjectDef objDef = getObjectDefByName(objList[0].name);
        System.debug('objDef=' + JSON.serialize(objDef));
        */

        String tmpStr = testAPI(HTTP_GET, 'https://saldemomay18sdo.my.salesforce.com?ec=302&startURL=%2Fapex%2Fgetsessionidvf%3Finline%3D1', null);
        System.debug('tmpStr=' + tmpStr);

        List<NameLabel> dbList = getDashboardList(null);
        System.debug('dbList=' + JSON.serialize(dbList));


        /*
                        for (DatasetDef tmpDef : dbList[0].datasets)
                        {

                        String datasetId = tmpDef.id;

                        DataSetDef dsDef = getDatasetById(datasetId);
                        System.debug('dsDef[' + tmpDef.name + ']=' + JSON.serialize(dsDef));

                        String versionId = dsDef.currentVersionId;

                        DataSetXMDSDef dsXmdsDef = getDatasetXMDSById(dataSetId, versionId);
                        System.debug('dsXmdsDef=' + JSON.serialize(dsXmdsDef));
                        }
                        */
    }
}