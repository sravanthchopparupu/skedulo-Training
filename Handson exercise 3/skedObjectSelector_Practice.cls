@isTest
private class skedObjectSelector_Practice 
{
    @isTest
    static void practiceObjectSelector() 
    {
        String brisbaneTimezone = 'Australia/Brisbane';
        Set<Id> resourceIds = new Set<Id>();
        
        DateTime currentTime = DateTime.now();
        DateTime next7DaysTime = currentTime.addDays(7);
        
        Integer duration = 60;
        DateTime start = DateTime.now();
        DateTime finish = start.addMinutes(duration);
        
        
        // Data set up
        
        sked__region__c region = new sked__region__c(
            Name = 'Sydney',
            sked__Timezone__c = 'brisbaneTimezone',
            sked__Country_Code__c = 'AU'
        );
        insert region;
        
        Account account = new Account(
            Name = 'SkedTest',
            BillingCity = 'Minnesota',
            BillingCountry = 'UK',
            BillingPostalCode = '12345',
            BillingState = 'AN',
            BillingStreet = '123 Rising Street',
            Phone = '(123) 456-7890'
        );
        insert account;
        sked__job__c job = new sked__job__c(
            sked__type__c = 'Initial DayCare Visit',
            sked__start__c = start,
            sked__finish__c = finish,
            sked__region__c = region.id,
            sked__Duration__c = duration,
            sked__job_status__c = 'En Route',
            sked__account__c = account.id
        );
        insert job;
        sked__Resource__c resource = new sked__Resource__c(
            name 					= 'SkedTest',
            sked__Resource_Type__c 	= 'Person',
            sked__Primary_Region__c = region.Id,
            sked__Category__c 		= 'Customer Service',
            sked__Country_Code__c 	= 'AU',
            sked__Is_Active__c      = True,
            sked__Home_Address__c 	= '123 Street road, Sydney, AUS'
        );
        sked__Resource__c notRelevantResource = resource.clone();
        insert new List<sked__Resource__c>{resource, notRelevantResource};
            resourceIds.add(resource.Id);
        
        // Create first activity in the past
        sked__Activity__c firstActivity = new sked__Activity__c(
            sked__Address__c 	= '123 Street road, Sydney, AUS',
            sked__Type__c 		= 'Dinner Break',
            sked__Start__c 		= currentTime.addDays(-7),
            sked__End__c 		= currentTime.addDays(-7).addMinutes(120),
            sked__Resource__c 	= resource.Id
        );
        insert new List<sked__Activity__c>{firstActivity};
            
            sked__job_allocation__c joballocation = new sked__job_allocation__c(
                sked__job__c = job.id,
                sked__resource__c = resource.id,
                sked__status__c = 'En Route'
            );
        insert joballocation;
        // sub query for the sked__Activities__c list based on the record ID
        List<sked__Resource__c> resourceActivityList = [SELECT id, (SELECT id
                                                                    FROM sked__Activities__r) FROM sked__Resource__c 
                                                        WHERE Id IN :resourceIds AND sked__Is_Active__c = true];
        Test.startTest();
        // Init new selector
        skedObjectSelector resourceSelector = skedObjectSelector.newInstance(sked__Resource__c.SObjectType);
        //-----------------------Add the code below this line-----------------------
        //This is a query for sample resources
        List<sked__Resource__c> resources = Database.query(
            skedObjectSelector.newInstance(sked__Resource__c.SObjectType) //Used for getting an instance of skedObjectSelector for the Resource object
            .filter('sked__Is_Active__c = true') //Active resources is been retrieved
            .filter('Id IN :resourceIds') //Extra filter condition
            .subQuery('sked__Job_Allocations__r') //Used for returning an instance of skedObjectSelector for Job Allocation object
            .filter('sked__Job__r.sked__Start__c =: start') //Subquery's first filter
            .filter('sked__Job__r.sked__Finish__c =:finish') //Subquery's second filter
            .filterLogic('{0} OR {1}') //Used for defining subquery's filter logic - use OR instead of AND (default)
            .sort('Name') //Sorting by Name in ascending order is done
            .parent //Getting back to main query
            .parentQuery('sked__Primary_Region__c') //Related Region fields defined in field mapping are been queried
            .size(20) //Maximum 20 records are retrieved
            .getQuery() //Dynamic SOQL query is been generated
        );
        
        System.debug('<----number of resources present here---->'+resources.size());
        
        Test.stopTest();
        
        System.assertEquals(1, resources.size());
        System.assertEquals(region.name, resources[0].sked__Primary_Region__r.Name);
        System.assertEquals(region.sked__Timezone__c, resources[0].sked__Primary_Region__r.sked__Timezone__c);
        System.assertEquals(1, resourceActivityList[0].sked__Activities__r.size());
    }
}