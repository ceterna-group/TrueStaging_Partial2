/**
 * Created by Ashwi on 03/09/2019.
 */

public class ProjectTriggerHandler {

    public static void afterUpdate(Map<Id, Project__c> newRecordMap, Map<Id, Project__c> oldRecordMap) {
        checkBookingOverride(newRecordMap, oldRecordMap);
    }

    public static void checkBookingOverride(Map<Id, Project__c> newRecordMap, Map<Id, Project__c> oldRecordMap) {

        Map<String, List<String>> typeDateMap = new Map<String, List<String>>();
        typeDateMap.put('Workshop', new List<String>{'Workshop_Start_Date_Time__c', 'Workshop_Finish_Date_Time__c' });
        typeDateMap.put('Install', new List<String>{'Install_Date_Time__c', 'Install_Finish_Date_Time__c' });
        typeDateMap.put('Event', new List<String>{'Event__c', 'Event_Finish_Date_Time__c' });
        typeDateMap.put('Derig', new List<String>{'Derig_Date_Time__c', 'Derig_Finish_Date_Time__c' });
        typeDateMap.put('Travel', new List<String>{'Travel_Start_Date__c', 'Travel_End_Date__c' });

        String body = 'Dear' + ', <br/><br/>' + 'The following timeslots no longer fall within the relevant range: <br/><br/>';

        for(Project_Time_Slots__c timeSlot : [SELECT Id, Type__c, Date__c, Project__c, Project__r.Name, Project__r.Workshop_Start_Date_Time__c,
                                                Project__r.Install_Date_Time__c, Project__r.Event_Date_Time__c, Project__r.Derig_Date_Time__c
                                                FROM Project_Time_Slots__c WHERE Project__c IN : newRecordMap.keySet()]){

            if (timeSlot.Date__c < (Datetime)newRecordMap.get(timeSlot.Project__c).get(typeDateMap.get(timeSlot.Type__c)[0]) ||
                    timeSlot.Date__c > (Datetime)newRecordMap.get(timeSlot.Project__c).get(typeDateMap.get(timeSlot.Type__c)[1])){
                // do something
                body += 'Timeslot for : ' + 'Project - ' + newRecordMap.get(timeSlot.Project__c).Name + '<br/>';
                body += 'Workshop Date: ' + newRecordMap.get(timeSlot.Project__c).Workshop_Start_Date_Time__c + '<br/>';
                body += 'Install Date: ' + newRecordMap.get(timeSlot.Project__c).Install_Date_Time__c + '<br/>';
                body += 'Event Date: ' + newRecordMap.get(timeSlot.Project__c).Event_Date_Time__c + '<br/>';
                body += 'Derig Date: ' + newRecordMap.get(timeSlot.Project__c).Derig_Date_Time__c + '<br/>';

            }
        }

        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();

        List<String> sendTo = new List<String>();
        sendTo.add('ashwin@ceterna.com');
        mail.setToAddresses(sendTo);

        mail.setReplyTo('test@ceterna.com');
        mail.setSenderDisplayName('Ceterna Support Test');

        mail.setSubject('Crew Allocation App - Edited Slots Report');
        body += '<br/><br/>Regards, </br> Ceterna Support';
        mail.setHtmlBody(body);

        mails.add(mail);

        Messaging.sendEmail(mails);

    }
}