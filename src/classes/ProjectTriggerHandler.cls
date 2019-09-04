//
public static class ProjectTriggerHandler {

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

        String body = 'Dear X' + ', <br/><br/>' + 'The following timeslots no longer fall within the relevant range: <br/><br/>';

        Integer timeSlotCount = 0;

        List<Project_Time_Slots__c> projectTimeSlots =  [SELECT Id, Type__c, Date__c, Project__c, Project__r.Name, Project__r.Workshop_Start_Date_Time__c,
                                                                Project__r.Install_Date_Time__c, Project__r.Event_Date_Time__c, Project__r.Derig_Date_Time__c,
                                                                Email_Sent__c, Name, Start_Time__c, Finish_Time__c,
                                                                (SELECT Name, Assigned_Role__c, Project_Time_Slots_Start_Time__c,
                                                                        Project_Time_Slots_Finish_Time__c, Staff_List__r.Name
                                                                FROM Labour_Truck_Allocation__r)
                                                        FROM Project_Time_Slots__c
                                                        WHERE Project__c IN : newRecordMap.keySet()];

        for(Project_Time_Slots__c timeSlot : projectTimeSlots){

            if (timeSlot.Date__c < (Datetime)newRecordMap.get(timeSlot.Project__c).get(typeDateMap.get(timeSlot.Type__c)[0]) ||
                    timeSlot.Date__c > (Datetime)newRecordMap.get(timeSlot.Project__c).get(typeDateMap.get(timeSlot.Type__c)[1])){

                if(timeSlot.Email_Sent__c == false){

                    timeSlotCount += 1;
                    System.debug('timeslotDATE:' + timeSlot.Date__c);
                    System.debug('wholeMap@' + typeDateMap);
                    System.debug('typeDateMap1@' + (Datetime)newRecordMap.get(timeSlot.Project__c).get(typeDateMap.get(timeSlot.Type__c)[0]));
                    System.debug('typeDateMap2@' + (Datetime)newRecordMap.get(timeSlot.Project__c).get(typeDateMap.get(timeSlot.Type__c)[1]));

                    body += 'Timeslot for : ' + '<b>Project - ' + newRecordMap.get(timeSlot.Project__c).Name + '</b><br/>';
                    body += 'Project Time Slot Name : <b>' + timeSlot.Name + '</b>  <br/>';
                    body += 'Type : ' + timeSlot.Type__c + '<br/><br/>';
                    body += 'Project Time Slot Start Time : ' + timeSlot.Start_Time__c + '<br/>';
                    body += 'Project Time Slot Finish Time : ' + timeSlot.Finish_Time__c + '<br/><br/>';

                    for(Labour_Truck_Allocation__c labourTruckAllocation : timeSlot.Labour_Truck_Allocation__r){
                        body += labourTruckAllocation.Staff_List__r.Name + ' - ' + labourTruckAllocation.Assigned_Role__c + '<br/>';
                    }

                    body += '<br/><br/>';

                    timeSlot.Email_Sent__c = true;
                }

            } else if(timeSlot.Email_Sent__c) {
                timeSlot.Email_Sent__c = false;
            }
        }

        if(timeSlotCount > 0) {

            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            List<String> sendTo = new List<String>();
            sendTo.add('ashwin@ceterna.com');
            mail.setToAddresses(sendTo);

            mail.setReplyTo('test@ceterna.com');
            mail.setSenderDisplayName('Ceterna Support Test');

            mail.setSubject('Crew Allocation App - Edited Slots Report');
            body += '<br/><br/>Regards, <br/> Ceterna Support';
            mail.setHtmlBody(body);

            mails.add(mail);

            Messaging.sendEmail(mails);
            update projectTimeSlots;
        }
    }
}