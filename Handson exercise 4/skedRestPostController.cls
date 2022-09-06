@RestResource(urlMapping='/Skedulo/AvailableResource/*')
global with sharing class skedRestPostController 
{
    public static string regionId { get; set; }
    public static string homeId { get; set; }
    public static string suiteId { get; set; }
    public static string roomId { get; set; }
    public static string timezone { get; set; }
    public static String startDate { get; set; }
    public static Integer duration { get; set; }
    public static Integer intStartTime { get; set; }
    public static Integer intEndTime { get; set; }
    public static String endDate { get; set; }
    public static Decimal latitude { get; set; }
    public static Decimal longitude { get; set; }
    public static List<Id> tagIds { get; set; }
    public static List<Id> eventIds { get; set; }
    public static Boolean includeResourceInfo { get; set; }
    public static Integer offsetTime { get; set; }
        
    @HttpPost
    global static void doPost() 
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        String uri = req.requestURI;
        String reqBody = req.requestBody.toString();
        Integer resStatusCode = res.statusCode; 
        Boolean success = TRUE;
        
        Map<String, Object> body = new Map<String, Object>();
        body = (Map<String, Object>)JSON.deserializeUntyped(reqBody);
                
        //Response object is been initialized
        resp resp = new resp();
        err errors = new err();
        skedJobSchedulingModel.Criteria cr=new skedJobSchedulingModel.Criteria();
        cr.regionId = (String)body.get('regionId');
        cr.homeId = (String)body.get('homeId');
        cr.suiteId = (String)body.get('suiteId');
        cr.roomId = (String)body.get('roomId');
        cr.timezone = (String)body.get('timezone');
        cr.startDate = (String)body.get('startDate');
        cr.duration = (Integer)body.get('duration');
        cr.intStartTime = (Integer)body.get('intStartTime');
        cr.intEndTime = (Integer)body.get('intEndTime');
        cr.endDate = (String)body.get('endDate');
        cr.latitude = (Decimal)body.get('latitude');
        cr.longitude = (Decimal)body.get('longitude');
        cr.tagIds = (List<Id>)body.get('tagIds');
        cr.eventIds = (List<Id>)body.get('eventIds');
        cr.includeResourceInfo = (Boolean)body.get('includeResourceInfo');
        cr.offsetTime = (Integer)body.get('offsetTime');
        
        if (string.isBlank(startDate) == NULL) 
        {
            errors.message = 'startDate Missing.';
            errors.type = 'Bad Request';
            errors.code = '400';
            success = FALSE;
        }
        else if (string.isBlank(endDate) == NULL) 
        {
            errors.message = 'endDate Missing.';
            errors.type = 'Bad Request';
            errors.code = '400';
            success = FALSE;
        }        
        if (success == TRUE) 
        {    
            try
            {
                skedJobSchedulingCtrlHandler sked = new skedJobSchedulingCtrlHandler();
                sked.getAvailableResources(cr);
            } 
            catch (Exception e) 
            {
                errors.message = 'On API execution this Error found' + e.getMessage();
                errors.type = 'Server Error';
                errors.code = '500';            
                success = FALSE;
            }
        }        
        
        //Response object is being finalized
        if (success) 
        {
            res.statusCode = 200;
        } 
        else 
        {
            resp.error = errors;        
            res.responseBody = Blob.valueOf(JSON.serialize(resp));    
            res.statusCode = Integer.valueOf(errors.code);
        }          
    }
    
    //Main class response
    public class resp 
    {
        public err error { get; set; }                       
    }
    
    //sub class response
    public class err 
    {
        public String message { get; set; }
        public String type { get; set; }
        public String code { get; set; }        
        public String trace_id { get; set; }        
    }   
    
}