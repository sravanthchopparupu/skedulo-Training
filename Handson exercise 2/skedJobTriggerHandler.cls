public class skedJobTriggerHandler 
{
public static void onAfterInsert(List<sked__job__c> Listofjobs) 
{
    sendJobCompletionSMS(Listofjobs, null);
}    
public static void onAfterUpdate(List<sked__job__c> Listofjobs, Map<id, sked__job__c> map_id_old) 
{
    sendJobCompletionSMS(Listofjobs,map_id_old);
}     
public static void sendJobCompletionSMS(List<sked__job__c> Listofjobs, Map<id, sked__job__c> map_id_old) 
{
    Set<Id> Idsofcontacts = new Set<Id>();
    for (sked__Job__c job : Listofjobs) 
    {
        if (map_id_old != null) 
        {
            if (job.sked__Job_Status__c != map_id_old.get(job.Id).sked__Job_Status__c && job.sked__Job_Status__c == 'Complete' && !String.isBlank(job.sked__Contact__c)) 
            {
                Idsofcontacts.add(job.sked__Contact__c);
            }
        } 
        else if (job.sked__Job_Status__c == 'Complete' && !String.isBlank(job.sked__Contact__c)) 
        {
            Idsofcontacts.add(job.sked__Contact__c);
        }
    }
    onCalloutResponse(Idsofcontacts);
}
@future (callout=true) 
public static void onCalloutResponse(Set<Id> Idsofcontacts) 
{        
    try 
    {
        List<Contact> conDetailList = [SELECT id, Phone,LastName FROM Contact WHERE Id IN : Idsofcontacts LIMIT 1];
        if (conDetailList.size() > 0) 
        {
            String phone = conDetailList[0].Phone;
            String countryCode = 'AU';
            String message = 'handson exercise 2 is being processed';
            sked.ApiResult.Sms response = sked.SkeduloAPI.sms(message, countryCode, phone);
            if (response.isSuccess()) 
            {
                System.debug('Message has been sent--->'+response); 
            } 
            else 
            {
                System.debug('Error occured: ' + response.getError());
            } 
        }
    } 
    catch(Exception e) 
    {
        System.debug('This is the following exception which has occurred: ' + e.getMessage());
    }
    
}
}