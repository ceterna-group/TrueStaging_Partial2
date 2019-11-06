//
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

        Map<String,Map<String,String>> projectMap = new Map<String,Map<String,String>>();
        Map<String,String> oppNameMap = new Map<String,String>();

        List<Project_Time_Slots__c> projectTimeSlots = [SELECT Id, Type__c, Title__c, Date__c, Project__c, Project__r.Name, Project__r.Workshop_Start_Date_Time__c,
                                                                Project__r.Install_Date_Time__c, Project__r.Event_Date_Time__c, Project__r.Derig_Date_Time__c,
                                                                Email_Sent__c, Name, Start_Time__c, Finish_Time__c, Project__r.Opportunity__r.Name,
                                                                (SELECT Name, Assigned_Role__c, Project_Time_Slots_Start_Time__c,
                                                                        Project_Time_Slots_Finish_Time__c, Staff_List__r.Name
                                                                FROM Labour_Truck_Allocation__r)
                                                        FROM Project_Time_Slots__c
                                                        WHERE Project__c IN :newRecordMap.keySet()];

        List<Project_Time_Slots__c> timeSlotsToDelete = new List<Project_Time_Slots__c>();

        for (Project_Time_Slots__c timeSlot : projectTimeSlots){

            if (timeSlot.Date__c < (Datetime)newRecordMap.get(timeSlot.Project__c).get(typeDateMap.get(timeSlot.Type__c)[0]) ||
                    timeSlot.Date__c > (Datetime)newRecordMap.get(timeSlot.Project__c).get(typeDateMap.get(timeSlot.Type__c)[1])){

                oppNameMap.put(timeSlot.Project__c,timeSlot.Project__r.Opportunity__r.Name);

                // add it to the list of time slots to delete
                timeSlotsToDelete.add(timeSlot);

                // then add the content to the email body map
                if (!projectMap.containsKey(timeSlot.Project__c)){
                    projectMap.put(timeSlot.Project__c, new Map<String,String>());
                }

                if (!projectMap.get(timeSlot.Project__c).containsKey(timeSlot.Type__c)){

                    String typeInfo = '<p><span style="font-size:14px;font-weight:bold;">Type: ' + timeSlot.Type__c + '</span><br/>' +
                            'The start date was ' + Datetime.valueOf(oldRecordMap.get(timeSlot.Project__c).get(typeDateMap.get(timeSlot.Type__c)[0])).format('dd-MM-YYYY') + ' ' +
                            'and the end date was ' + Datetime.valueOf(oldRecordMap.get(timeSlot.Project__c).get(typeDateMap.get(timeSlot.Type__c)[1])).format('dd-MM-YYYY') + '<br/>' +
                            'The start date is now ' + Datetime.valueOf(newRecordMap.get(timeSlot.Project__c).get(typeDateMap.get(timeSlot.Type__c)[0])).format('dd-MM-YYYY') + ' ' +
                            'and the end date is now ' + Datetime.valueOf(newRecordMap.get(timeSlot.Project__c).get(typeDateMap.get(timeSlot.Type__c)[1])).format('dd-MM-YYYY') + '<br/><br/>' +
                            'The following ' + timeSlot.Type__c + ' time slots and entries have been deleted:';
                    projectMap.get(timeSlot.Project__c).put(timeSlot.Type__c, typeInfo);
                }

                String typeInfoBody = projectMap.get(timeSlot.Project__c).get(timeSlot.Type__c);

                typeInfoBody += '<p><b>Time slot: ' + timeSlot.Title__c + ' ' + timeSlot.Start_Time__c + ' - ' + timeSlot.Finish_Time__c + ' ' + '</b><br/>';

                for (Labour_Truck_Allocation__c allocation : timeSlot.Labour_Truck_Allocation__r){
                    typeInfoBody += '<span style="padding-left:5px;">' + allocation.Staff_List__r.Name + ' - ' + allocation.Assigned_Role__c + '</span><br/>';
                }

                projectMap.get(timeSlot.Project__c).put(timeSlot.Type__c, typeInfoBody + '<br/></p>');

            }

        }

        if (!timeSlotsToDelete.isEmpty()) {

            String body = 'Hello' + ', <br/>' + 'Dates have been changed which may affect your Crew Allocation App: <br/><br/>';

            for (String projectId : projectMap.keySet()){

                body += '<p><span style="font-size:20px;"><b>' + oppNameMap.get(projectId) + ' - ' + newRecordMap.get(projectId).Project_Number_Hidden__c + '</b></span>';

                for (String type : projectMap.get(projectId).keySet()){

                    body += projectMap.get(projectId).get(type) + '<br/>';
                }

                body += '</p>';
            }

            List<Messaging.SingleEmailMessage> mails    = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail           = new Messaging.SingleEmailMessage();

            List<String> sendTo = new List<String>();
            sendTo.add('operations@truestaging.co.uk');
            sendTo.add('jake@ceterna.com');
            sendTo.add('ronan@ceterna.com');
            mail.setToAddresses(sendTo);

            mail.setReplyTo('test@ceterna.com');
            mail.setSenderDisplayName('Crew Allocation App');

            mail.setSubject('Crew Allocation App - Edited Slots Report');
            mail.setHtmlBody(body);

            mails.add(mail);

            Messaging.sendEmail(mails);
            delete timeSlotsToDelete;
        }
    }
}