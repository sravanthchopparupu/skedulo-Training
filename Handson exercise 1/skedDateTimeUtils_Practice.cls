@isTest
private class skedDateTimeUtils_Practice 
{
    @isTest
    static void practiceDateTimeUtils() {
        String vnTimezone = 'Asia/Saigon';
        String sydneyTimezone = 'Australia/Sydney';
        
        //Datetime initialization

        DateTime dateInstance = datetime.newInstance(2023, 10, 05,06,00,00); // time given is 06:00 am 
        DateTime sydneyStartOfDateTime = datetime.newInstance(2023, 10, 05,09,00,00); // time given is 09:00 AM
        
        DateTime sydney9amStartDate = skedDateTimeUtils.toTimezone(sydneyStartOfDateTime,sydneyTimezone);
        
        DateTime vn9am = skedDateTimeUtils.toTimezone(dateInstance,vnTimezone);
        DateTime sydney9am = skedDateTimeUtils.toTimezone(dateInstance,sydneyTimezone);
        DateTime sydneyStartOfDate = skedDateTimeUtils.getStartOfDate(sydney9amStartDate,sydneyTimezone); // Get the start day of time based on SydneyTimezone
        DateTime sydneyNextDate = skedDateTimeUtils.addDays(sydneyStartOfDate, 1, sydneyTimezone);
        
        //-----------checking conditions for System.Assert------------
         System.assertEquals('05/10/2023 06:00 AM', vn9am.format(skedDateTimeUtils.DATE_TIME_DMY_FORMAT, vnTimezone));
         System.assertEquals('05/10/2023 06:00 AM', sydney9am.format(skedDateTimeUtils.DATE_TIME_DMY_FORMAT, sydneyTimezone));
         System.assertEquals('05/10/2023 09:00 AM', sydneyStartOfDate.format(skedDateTimeUtils.DATE_TIME_DMY_FORMAT, sydneyTimezone));
         System.assertEquals('06/10/2023 09:00 AM', sydneyNextDate.format(skedDateTimeUtils.DATE_TIME_DMY_FORMAT, sydneyTimezone));


    }
}
