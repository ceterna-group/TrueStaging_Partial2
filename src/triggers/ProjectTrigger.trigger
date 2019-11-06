/**
 * Created by Ashwin on 03/09/2019.
 */
trigger ProjectTrigger on Project__c (after update) {

    if(Trigger.isAfter) {
        if(Trigger.isUpdate) {
            ProjectTriggerHandler.afterUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
}