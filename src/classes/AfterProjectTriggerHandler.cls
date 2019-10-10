public with sharing class AfterProjectTriggerHandler 
{
	public static void deleteProjectTimeSlots(List<Id> projectIds)
	{
		List<Project_Time_Slots__c> projectTSList = new List<Project_Time_Slots__c>();
		
		projectTSList = [Select Id, Project__c from Project_Time_Slots__c where Project__c In :projectIds];
		
		if(!projectTSList.isEmpty() && projectTSList.size() > 0)
		{
			delete projectTSList;
		}		
	}
}