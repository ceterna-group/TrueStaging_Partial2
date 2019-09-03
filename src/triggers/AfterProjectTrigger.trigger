trigger AfterProjectTrigger on Project__c (after update) 
{
	if(Trigger.IsAfter) {
		if(Trigger.IsUpdate) {

			List<Id> projectIds = new List<Id>();
			for(Project__c proj : Trigger.new) {
				Project__c oldProj = Trigger.oldMap.get(proj.Id);
				if(oldProj.Lock_Dates__c == true && proj.Lock_Dates__c == false) {
					projectIds.add(proj.Id);
					System.debug('id&&&&&&&&  '+proj.Id);
				}
			}
			
			if(!projectIds.isEmpty() && projectIds.size() > 0) {
				AfterProjectTriggerHandler.deleteProjectTimeSlots(projectIds);
			}
		}	
	}
}