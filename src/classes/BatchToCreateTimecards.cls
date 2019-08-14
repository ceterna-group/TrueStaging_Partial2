global class BatchToCreateTimecards implements Database.Batchable<SObject>
{
	global Database.QueryLocator start(Database.BatchableContext BC)
	{
		String query = 'Select l.Staff_List__r.Allocation_type__c, l.Staff_List__c, l.Project_Time_Slots__r.Type__c, l.Project_Time_Slots__r.Project__c, l.Project_Time_Slots__r.Finish_Time__c, l.Project_Time_Slots__r.Start_Time__c, l.Project_Time_Slots__c, l.CreatedDate  From Labour_Truck_Allocation__c l where l.Project_Time_Slots__r.Type__c != \'Workshop\' and l.Staff_List__r.Allocation_type__c != \'Truck\'  and l.Project_Time_Slots__r.Start_Time__c = YESTERDAY';
		return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
    	List<Clocking_Machine_Data__c> timecardList = new List<Clocking_Machine_Data__c>();
      	for(Sobject sObj : scope)
      	{
      			Labour_Truck_Allocation__c allocation = (Labour_Truck_Allocation__c) sObj;
      			
      			Clocking_Machine_Data__c timecard = new Clocking_Machine_Data__c(
	      			Clock_in_Time__c = allocation.Project_Time_Slots__r.Start_Time__c,
	      			Clock_Out_Time__c = allocation.Project_Time_Slots__r.Finish_Time__c,
	      			Project_Number__c = allocation.Project_Time_Slots__r.Project__c,
	      			Staff_List__c = allocation.Staff_List__c,
	      			Timecard_Type__c = 'Other'
      			);
      			
      			timecardList.add(timecard);
      	}      
      	
      	
      	if(!timecardList.isEmpty()) 
      		insert timecardList;
      	
   }
	
   global void finish(Database.BatchableContext BC)
   {}
}