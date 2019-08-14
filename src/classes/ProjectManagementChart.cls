public with sharing class ProjectManagementChart {

  public static final String fail = 'Error';
  public static final String success = 'completed';
    
  /*
   * Below method retrieves all the projects that has opportunity as closed won 
   * and install date in greater than historic date.
   */
  @RemoteAction
  public static List<Map<String, Object>> getAllProjects() {
    String stageClosedLost = Label.OppStageClosedLost;
    Integer months =14;
    ProjectHistoricDateInMonths__c hd = ProjectHistoricDateInMonths__c.getInstance(UserInfo.getProfileId()); //value set in custom settings - value in months
    if (hd.HistoricDateInMonths__c != null) {
      months = Integer.valueOf(hd.HistoricDateInMonths__c);
    }
    Date historicDate = System.today().addMonths(-months);
    List<Project__c> projectList = [
      SELECT Id, Name, Project_Completed__c, Complete__c, 
        Client_Name__c, Event_Name__c, Opportunity__c, Opportunity__r.Name, 
        Opportunity__r.StageName, Project_Manager__c, Project_Manager__r.Name,
        Client_Visit_Date__c, Collection_Only__c, Derig_Finish_Date_Time__c,
        Derig_Finish_Date_Time_2__c, Derig_Date_Time__c,  De_Rig_Start_Date_Time_2__c,
        Drawing_Completion_Date_Time__c, Event_Finish_Date_Time__c,
        Event_Finish_Date_Time_2__c, Event_Date_Time__c, Event__c,
        Install_Finish_Date_Time__c, Install_Finish_Date_Time_2__c,
        Install_Date_Time__c, Install_start_Date_Time_2__c, Sign_off_Date_Time__c,
        Transport_Arrival_Date_Time__c, Travel_End_Date__c, Travel_End_Date_2__c,
        Travel_Start_Date__c, Travel_Start_Date_2__c, Truck_Loading_Date_Time__c,
        Workshop_Finish_Date_Time__c, Workshop_Start_Date_Time__c, Project_Stage__c,  
        Lock_Dates__c,  Total_Project_Costs__c, Crew_Chief_1__c, Crew_Chief_1__r.Name,
        Crew_Chief_2__c, Crew_Chief_2__r.Name, Crew_Chief_3__c, Crew_Chief_3__r.Name, 
        Deposit_Requested__c, Final_Invoice_Requested__c, Install_Month__c, Install_Year__c, 
        Opportunity__r.Total_Quote_Amount__c, Additional_Info__c
      FROM Project__c
      WHERE 
        (Opportunity__c != null) AND
        ((Project_Completed__c = false) OR (Complete__c = false)) AND
        (Opportunity__r.StageName != :stageClosedLost) AND
        ((Install_Date_Time__c >= :historicDate) OR (Install_Date_Time__c = null))
    ];
    List<Map<String, Object>> projectInfoList = buildWrapperList(projectList);    
    return projectInfoList;
  }
    
  //Below method builds a wrapper class for projects. Used in PM gantt chart page.
  public static List<Map<String, Object>> buildWrapperList(List<Project__c> projectList) {
    List<Map<String, Object>> projectInfoList = new List<Map<String, Object>>();
    if (projectList != null && !projectList.isEmpty()) {
      for (Project__c proj : projectList) {
        Map<String, Object> sobj = new Map<String, Object>();
        sobj.put('ProjectId', proj.Id);
        sobj.put('ProjectNumber', proj.Name);
        sobj.put('EventName', proj.Event_Name__c);
        if (proj.Opportunity__c != null && proj.Opportunity__r.Total_Quote_Amount__c != null) sobj.put('totalProjectCosts', proj.Opportunity__r.Total_Quote_Amount__c); //total projects costs is now total budget.
        if (proj.Opportunity__c != null)  sobj.put('OpportunityName', proj.Opportunity__r.Name);   
        if (proj.Opportunity__c != null) sobj.put('OpportunityStage', proj.Opportunity__r.StageName);
        if (proj.Client_Name__c != null) sobj.put('ClientName', proj.Client_Name__c);
        if (proj.Project_Manager__c != null) sobj.put('PMName', proj.Project_Manager__r.Name);
        // set all dates if not null
        Map<String, String> fieldMap = getFieldToKeyMap();
        for (String field : fieldMap.keySet()) {
          String checkField = field.indexOf('copy__') != -1 ? field.split('copy__')[1] : field;
          if (proj.get(checkField) != null) {
            Datetime d = (Datetime) proj.get(checkField);
            sobj.put(fieldMap.get(field), d.format('dd/MM/yyyy'));
          }
        }  
        if (proj.Project_Stage__c != null) sobj.put('projectStage', proj.Project_Stage__c);
        if (proj.Lock_Dates__c != null) sobj.put('IsLocked', proj.Lock_Dates__c);
        if (proj.Deposit_Requested__c != null) sobj.put('IsDeposited',  proj.Deposit_Requested__c);
        if (proj.Final_Invoice_Requested__c != null) sobj.put('IsInvoiced',  proj.Final_Invoice_Requested__c);
        if (proj.Install_Month__c != null) sobj.put('projectMonth',  proj.Install_Month__c);
        if (proj.Install_Year__c != null) sobj.put('projectYear',  proj.Install_Year__c);
        if (proj.Additional_Info__c != null) sobj.put('additionalInfo',  proj.Additional_Info__c);
        Set<String> crewChiefMembers = new Set<String>();
        if(proj.Crew_Chief_1__c != null) crewChiefMembers.add(proj.Crew_Chief_1__r.Name);
        if(proj.Crew_Chief_2__c != null) crewChiefMembers.add(proj.Crew_Chief_2__r.Name);
        if(proj.Crew_Chief_3__c != null) crewChiefMembers.add(proj.Crew_Chief_3__r.Name);
        if(!crewChiefMembers.isEmpty() && crewChiefMembers.size() > 0) {
          sobj.put('crewChiefMember', crewChiefMembers);
        }
        projectInfoList.add(sobj); 
      }
    }
    return projectInfoList;
  }

  private static Datetime getDate(String dateString) {
    Date d = Date.parse(dateString);
    return Datetime.newInstanceGMT(d.year(), d.month(), d.day());
  }

  private static Map<String, String> getKeyToFieldMap() {
    Map<String, String> dateFields = new Map<String, String>();
    dateFields.put('signoffStartDate', 'Sign_off_Date_Time__c'); // sign off
    dateFields.put('signoffEndDate', 'Sign_off_Date_Time__c'); // sign off
    dateFields.put('drawingStartDate', 'Drawing_Completion_Date_Time__c'); // drawing
    dateFields.put('drawingEndDate', 'Drawing_Completion_Date_Time__c'); // drawing
    dateFields.put('workshopStartDate', 'Workshop_Start_Date_Time__c'); // workshop start
    dateFields.put('workshopEndDate', 'Workshop_Finish_Date_Time__c'); // workshop finish
    dateFields.put('truckStartDate', 'Truck_Loading_Date_Time__c'); // truck loading
    dateFields.put('truckEndDate', 'Truck_Loading_Date_Time__c'); // truck loading
    dateFields.put('transportStartDate', 'Transport_Arrival_Date_Time__c'); // transport arrival
    dateFields.put('transportEndDate', 'Transport_Arrival_Date_Time__c'); // transport arrival
    dateFields.put('travelStartDate', 'Travel_Start_Date__c'); // travel 1 start
    dateFields.put('travelEndDate', 'Travel_End_Date__c');	// travel 1 end
    dateFields.put('installStartDate', 'Install_Date_Time__c'); // install 1 start
    dateFields.put('installEndDate', 'Install_Finish_Date_Time__c'); // install 1 end
    dateFields.put('eventStartDate', 'Event_Date_Time__c'); // event 1 start
    dateFields.put('eventEndDate', 'Event_Finish_Date_Time__c'); // event 1 end
    dateFields.put('derigStartDate', 'Derig_Date_Time__c'); // derig 1 start
    dateFields.put('derigEndDate', 'Derig_Finish_Date_Time__c'); // derig 1 end
    dateFields.put('travel2StartDate', 'Travel_Start_Date_2__c'); // travel 2 start
    dateFields.put('travel2EndDate', 'Travel_End_Date_2__c');	// travel 2 end
    dateFields.put('install2StartDate', 'Install_start_Date_Time_2__c'); // install 2 start
    dateFields.put('install2EndDate', 'Install_Finish_Date_Time_2__c'); // install 2 end
    dateFields.put('event2StartDate', 'Event__c'); // event 2 start
    dateFields.put('event2EndDate', 'Event_Finish_Date_Time_2__c'); // event 2 end
    dateFields.put('derig2StartDate', 'De_Rig_Start_Date_Time_2__c'); // derig 2 start
    dateFields.put('derig2EndDate', 'Derig_Finish_Date_Time_2__c'); // derig 2 end
    dateFields.put('clientStartDate', 'Client_Visit_Date__c'); // client visit
    dateFields.put('clientEndDate', 'Client_Visit_Date__c'); // client visit
    dateFields.put('collectionStartDate', 'Collection_Only__c'); // collection
    dateFields.put('collectionEndDate', 'Collection_Only__c'); // collection
    return dateFields;
  }

  private static Map<String, String> getFieldToKeyMap() {
    Map<String, String> dateFields = new Map<String, String>();
    dateFields.put('Sign_off_Date_Time__c', 'signoffStartDate'); // sign off
    dateFields.put('copy__Sign_off_Date_Time__c', 'signoffEndDate'); // sign off
    dateFields.put('Drawing_Completion_Date_Time__c', 'drawingStartDate'); // drawing
    dateFields.put('copy__Drawing_Completion_Date_Time__c', 'drawingEndDate'); // drawing
    dateFields.put('Workshop_Start_Date_Time__c', 'workshopStartDate'); // workshop start
    dateFields.put('Workshop_Finish_Date_Time__c', 'workshopEndDate'); // workshop finish
    dateFields.put('Truck_Loading_Date_Time__c', 'truckStartDate'); // truck loading
    dateFields.put('copy__Truck_Loading_Date_Time__c', 'truckEndDate'); // truck loading
    dateFields.put('Transport_Arrival_Date_Time__c', 'transportStartDate'); // transport arrival
    dateFields.put('copy__Transport_Arrival_Date_Time__c', 'transportEndDate'); // transport arrival
    dateFields.put('Travel_Start_Date__c', 'travelStartDate'); // travel 1 start
    dateFields.put('Travel_End_Date__c', 'travelEndDate');	// travel 1 end
    dateFields.put('Install_Date_Time__c', 'installStartDate'); // install 1 start
    dateFields.put('Install_Finish_Date_Time__c', 'installEndDate'); // install 1 end
    dateFields.put('Event_Date_Time__c', 'eventStartDate'); // event 1 start
    dateFields.put('Event_Finish_Date_Time__c', 'eventEndDate'); // event 1 end
    dateFields.put('Derig_Date_Time__c', 'derigStartDate'); // derig 1 start
    dateFields.put('Derig_Finish_Date_Time__c', 'derigEndDate'); // derig 1 end
    dateFields.put('Travel_Start_Date_2__c', 'travel2StartDate'); // travel 2 start
    dateFields.put('Travel_End_Date_2__c', 'travel2EndDate');	// travel 2 end
    dateFields.put('Install_start_Date_Time_2__c', 'install2StartDate'); // install 2 start
    dateFields.put('Install_Finish_Date_Time_2__c', 'install2EndDate'); // install 2 end
    dateFields.put('Event__c', 'event2StartDate'); // event 2 start
    dateFields.put('Event_Finish_Date_Time_2__c', 'event2EndDate'); // event 2 end
    dateFields.put('De_Rig_Start_Date_Time_2__c', 'derig2StartDate'); // derig 2 start
    dateFields.put('Derig_Finish_Date_Time_2__c', 'derig2EndDate'); // derig 2 end
    dateFields.put('Client_Visit_Date__c', 'clientStartDate'); // client visit
    dateFields.put('copy__Client_Visit_Date__c', 'clientEndDate'); // client visit
    dateFields.put('Collection_Only__c', 'collectionStartDate'); // collection
    dateFields.put('copy__Collection_Only__c', 'collectionEndDate'); // collection
    return dateFields;
  }
    
  //Below method is used for updating dates that was modified on front end.
  @RemoteAction   
  public static String updateProjects(List<Map<String, String>> modifiedProjs) {
    if (modifiedProjs != null  && !modifiedProjs.isEmpty()) {           
      List<Project__c> updateProjects = new List<Project__c>();
      for (Map<String, String> proj : modifiedProjs) {
        if (proj.get('ProjectId') != null && proj.get('ProjectId') != '') {
          Project__c updateProj = new Project__c (Id = proj.get('ProjectId'));
          Map<String, String> keyMap = getKeyToFieldMap();
          // for each date key, if the value isn't null set it on the project
          for (String key : keyMap.keySet()) {
            if (proj.get(key) != null && proj.get(key) != '') {
              updateProj.put(keyMap.get(key), getDate(proj.get(key)));
            }
          }    
          if (proj.get('additionalInfo') != null) {
            updateProj.put('Additional_Info__c', proj.get('additionalInfo'));
          }
          // @TODO update additional info box
          updateProjects.add(updateProj);
        }
      }
      try {
        if (!updateProjects.isEmpty()) update updateProjects;
      } catch(Exception e) {
        System.debug('Error updating project: '+e);
        return fail;
      }
    }
    return success;
  }
    
  //Below method gives information on events and bank holidays
  @RemoteAction
  public static List<CalenderInformation> getCalendarHeadlines() {
    List<Calendar_Headlines__c> calenderHeadlineList = [
      SELECT Label__c, Headline_Type__c, Start_Date__c, End_Date__c 
      FROM Calendar_Headlines__c 
      WHERE Label__c != null
    ];
    List<CalenderInformation> calenderInfoList = new List<CalenderInformation>();
    if (calenderHeadlineList != null && calenderHeadlineList.size() > 0) {
      for (Calendar_Headlines__c chl : calenderHeadlineList) {
        CalenderInformation calenderSObj = new CalenderInformation();
        calenderSObj.eventOrHolName = chl.Label__c;
        calenderSObj.headlineType = chl.Headline_Type__c;
        calenderSObj.startDate = chl.Start_Date__c.format();
        calenderSObj.endDate = chl.End_Date__c.format();
        calenderInfoList.add(calenderSObj);
      }
    }
    return calenderInfoList;
  }
    
  //Colour codes to be displayed on front end for each type.Its stored in custom setting.
  @RemoteAction
  public static Map<String, String> getColorCodes() {
    List<CustomColorCodes__c> colorList = CustomColorCodes__c.getAll().values();
    Map<String, String> ccSobj = new Map<String, String>();
    if (colorList != null && colorList.size() > 0) {
      ccSobj.put('workshop', (colorList[0].Workshop__c != null) ? colorList[0].Workshop__c : Label.workshopDefaultColour);
      ccSobj.put('derig', (colorList[0].Derig__c != null) ? colorList[0].Derig__c : Label.derigDefaultColour);
      ccSobj.put('derig2', (colorList[0].Derig__c != null) ? colorList[0].Derig__c : Label.derigDefaultColour);
      ccSobj.put('client', (colorList[0].Collection__c != null) ? colorList[0].Collection__c : Label.collectionDefaultColour);
      ccSobj.put('collection', (colorList[0].Collection__c != null) ? colorList[0].Collection__c : Label.collectionDefaultColour);
      ccSobj.put('install', (colorList[0].Install__c != null) ? colorList[0].Install__c : Label.installDefaultColour);
      ccSobj.put('install2', (colorList[0].Install__c != null) ? colorList[0].Install__c : Label.installDefaultColour);
      ccSobj.put('event', (colorList[0].Event__c != null) ? colorList[0].Event__c : Label.eventDefaultColour);
      ccSobj.put('event2', (colorList[0].Event__c != null) ? colorList[0].Event__c : Label.eventDefaultColour);
      ccSobj.put('travel', (colorList[0].Travel__c != null) ? colorList[0].Travel__c : Label.travelDefaultColour);
      ccSobj.put('travel2', (colorList[0].Travel__c != null) ? colorList[0].Travel__c : Label.travelDefaultColour);
      ccSobj.put('signoff', (colorList[0].Signoff__c != null) ? colorList[0].Signoff__c : Label.signoffDefaultColour);  
      ccSobj.put('drawing', (colorList[0].Signoff__c != null) ? colorList[0].Signoff__c : Label.signoffDefaultColour);  
      ccSobj.put('truck', (colorList[0].Truck__c != null) ? colorList[0].Truck__c : Label.truckDefaultColour);
      ccSobj.put('transport', (colorList[0].Truck__c != null) ? colorList[0].Truck__c : Label.truckDefaultColour);
      ccSobj.put('events_Event', (colorList[0].eventEvent__c != null) ? colorList[0].eventEvent__c : Label.eventEventsDefaultColour);
      ccSobj.put('events_Holiday', (colorList[0].eventHoliday__c != null) ? colorList[0].eventHoliday__c : Label.eventHolidayDefaultColour);
    } else {
      ccSobj.put('workshop', Label.workshopDefaultColour);
      ccSobj.put('derig', Label.derigDefaultColour);
      ccSobj.put('derig2', Label.derigDefaultColour);
      ccSobj.put('client', Label.collectionDefaultColour);
      ccSobj.put('collection', Label.collectionDefaultColour);
      ccSobj.put('install', Label.installDefaultColour);
      ccSobj.put('install2', Label.installDefaultColour);
      ccSobj.put('event', Label.eventDefaultColour);
      ccSobj.put('event2', Label.eventDefaultColour);
      ccSobj.put('travel', Label.travelDefaultColour);
      ccSobj.put('travel2', Label.travelDefaultColour);
      ccSobj.put('signoff', Label.signoffDefaultColour);
      ccSobj.put('drawing', Label.signoffDefaultColour);
      ccSobj.put('truck', Label.truckDefaultColour);
      ccSobj.put('transport', Label.truckDefaultColour);
      ccSobj.put('events_Event', Label.eventEventsDefaultColour);
      ccSobj.put('events_Holiday', Label.eventHolidayDefaultColour);
    }       
    return ccSobj;      
  }
    
  //gets all opportunities that is not closed won
  @RemoteAction
  public static List<OpportunityRecords> getAllPipelineOpportunities() {
    List<Opportunity> opportunityRecords = new List<Opportunity>();
    List<OpportunityRecords> oppRecordList = new List<OpportunityRecords>();
    List<String> stageNameList = new List<String>{Label.OppStageQualification, Label.OppStageNeedAnalysis, Label.OppStageProposal};
    opportunityRecords = [
      SELECT Id, Name, Amount, CloseDate, Quote_Sent__c 
      FROM Opportunity 
      WHERE StageName In :stageNameList
    ];
    if (opportunityRecords != null && opportunityRecords.size() > 0) {
      for (Opportunity record : opportunityRecords) {
        OpportunityRecords oppRecord = new OpportunityRecords();
        oppRecord.OppName = record.Name;
        if (record.Amount != null) oppRecord.OppAmount = record.Amount;
        oppRecord.OppClosedDate = record.CloseDate.format();
        oppRecord.OppQuoteSent = record.Quote_Sent__c;
        oppRecordList.add(oppRecord);
      }
    }
    return oppRecordList;
  }
    
  public class OpportunityRecords {
    public String OppName {get; set;}
    public Double OppAmount {get; set;}
    public String OppClosedDate {get; set;}
    public Boolean OppQuoteSent {get; set;}
  }
    
  public class CalenderInformation {
    public String eventOrHolName {get; set;}
    public String headlineType {get; set;}
    public String startDate {get; set;}
    public String endDate {get; set;}
  }
  
}