/**
 * Created by Ashwin on 03/09/2019.
 */
trigger ProjectTrigger on Project__c (before insert, before update, before delete, after insert, after update) {

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {

        }
        if (Trigger.isUpdate) {

        }
    }

    if(Trigger.IsAfter) {
        if (Trigger.isInsert) {

        }
        if(Trigger.IsUpdate) {

            ProjectTriggerHandler.afterUpdate(Trigger.newMap, Trigger.oldMap);


        }
    }
}