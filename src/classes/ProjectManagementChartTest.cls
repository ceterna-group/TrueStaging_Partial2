@isTest
private class ProjectManagementChartTest
{
    static testMethod void testGetAllProjects()
    {
      Account acc = new Account(Name='Test Account');
      insert acc;
      
      Opportunity opp = new Opportunity(Name = 'Test Opp', AccountId=acc.Id, StageName='Closed Won', CloseDate=System.today(), Expected_Install_Month__c = 'June', Year__c = String.valueOf(System.today().Year()));
      insert opp;
      
    Staff_List__c staffSobj1 = new Staff_List__c(
        Name = 'Employee person 1',
        Forklift_license__c = true,
        Forklift_Licence_Expiry_Date__c = Date.newInstance(2016, 10, 21),
        CNC_Operator__c = false,
        Project_Roles__c = 'Crew Chief',
        Status__c = 'Active',
        Allocation_type__c = 'Truck',
        Secondary_Project_Role__c = 'Crew Chief' 
    );
    
    Staff_List__c staffSobj2 = new Staff_List__c( 
      Name = 'Employee person 2',
      Forklift_license__c = false,
      CNC_Operator__c = true,
      Project_Roles__c = 'Crew Chief',
      Status__c = 'Active',
      Allocation_type__c = 'Employee'       
    );
    
    Staff_List__c staffSobj3 = new Staff_List__c( 
      Name = 'Freelance person 1',
      Forklift_license__c = false,
      CNC_Operator__c = false,
      Project_Roles__c = 'Carpenter',
      Status__c = 'Active',
      Allocation_type__c = 'Freelance'       
    );
    insert new List<Staff_List__c>{staffSobj1, staffSobj2, staffSobj3};    
      
      Project__c project1 = new Project__c(
        Event_Name__c = 'Test project 1',
        Opportunity__c = opp.Id,
        Derig_Date_Time__c = DateTime.newInstance(2016, 06, 21),
        Derig_Finish_Date_Time__c = DateTime.newInstance(2016, 06, 22),
        Event_Date_Time__c = DateTime.newInstance(2016, 07, 24),
        Event_Finish_Date_Time__c = DateTime.newInstance(2016, 07, 25),
        Install_Date_Time__c = DateTime.newInstance(2016, 07, 02),
        Install_Finish_Date_Time__c = DateTime.newInstance(2016, 07, 03),
        Workshop_Start_Date_Time__c = DateTime.newInstance(2016, 07, 10),
        Workshop_Finish_Date_Time__c = DateTime.newInstance(2016, 07, 20),
        Travel_Start_Date__c = DateTime.newInstance(2016, 07, 21),
        Travel_End_Date__c = DateTime.newInstance(2016, 07, 22),
        Truck_Loading_Date_Time__c = DateTime.newInstance(2016, 07, 26),
        Sign_off_Date_Time__c = DateTime.newInstance(2016, 07, 08),
        Additional_Info__c = 'client visit date information',
        Crew_Chief_1__c = staffSobj1.Id,
        Crew_Chief_2__c = staffSobj2.Id,
        Crew_Chief_3__c = staffSobj3.Id,
        Project_Completed__c = false,
        Complete__c = false
      );
      
      Project__c project2 = new Project__c(
        Event_Name__c = 'Test project 2',
        Opportunity__c = opp.Id,
        Derig_Date_Time__c = DateTime.newInstance(2016, 09, 21),
        Derig_Finish_Date_Time__c = DateTime.newInstance(2016, 09, 22),
        Event_Date_Time__c = DateTime.newInstance(2016, 10, 24),
        Event_Finish_Date_Time__c = DateTime.newInstance(2016, 10, 25),
        Install_Date_Time__c = DateTime.newInstance(2016, 10, 02),
        Install_Finish_Date_Time__c = DateTime.newInstance(2016, 10, 03),
        Workshop_Start_Date_Time__c = DateTime.newInstance(2016, 10, 10),
        Additional_Info__c = 'client visit date information',
        Workshop_Finish_Date_Time__c = DateTime.newInstance(2016, 10, 20),
        Project_Completed__c = true,
        Complete__c = true
      );
      
      Project__c project3 = new Project__c(
        Event_Name__c = 'Test project 3',
        Opportunity__c = opp.Id,
        Workshop_Start_Date_Time__c = DateTime.newInstance(2016, 10, 10),
        Workshop_Finish_Date_Time__c = DateTime.newInstance(2016, 10, 20),
        Additional_Info__c = 'client visit date information',
        Project_Completed__c = true,
        Complete__c = true
      );
      
      Project__c project4 = new Project__c(
        Event_Name__c = 'Test project 2',
        Additional_Info__c = 'client visit date information',
        Opportunity__c = opp.Id,
        Derig_Date_Time__c = DateTime.newInstance(2016, 09, 21),  
        Derig_Finish_Date_Time__c = DateTime.newInstance(2016, 09, 22),
        Project_Completed__c = true,
        Complete__c = true            
      );
      
      insert new List<Project__c>{project1, project2, project3, project4};
      
      Test.startTest();
      
      List<Map<String, Object>> projects = ProjectManagementChart.getAllProjects();
      
      Test.stopTest();
      
      System.assert(projects.size() > 0);
    }
    
    static testMethod void testBuildWrapperList()
    {
      Account acc = new Account(Name='Test Account');
      insert acc;
      
      Opportunity opp = new Opportunity(Name = 'Test Opp', AccountId=acc.Id, StageName='Closed Won', CloseDate=System.today(), Expected_Install_Month__c = 'June', Year__c = String.valueOf(System.today().Year()));
      insert opp;
      
      Project__c project1 = new Project__c(
        Event_Name__c = 'Test project 1',
        Opportunity__c = opp.Id,
        Project_Stage__c = 'Phase 1 - Build',
        Additional_Info__c = 'client visit date information',
        Derig_Date_Time__c = DateTime.newInstance(2016, 06, 21),
        Derig_Finish_Date_Time__c = DateTime.newInstance(2016, 06, 22),
        Event_Date_Time__c = DateTime.newInstance(2016, 07, 24),
        Event_Finish_Date_Time__c = DateTime.newInstance(2016, 07, 25),
        Install_Date_Time__c = DateTime.newInstance(2016, 07, 02),
        Install_Finish_Date_Time__c = DateTime.newInstance(2016, 07, 03),
        Workshop_Start_Date_Time__c = DateTime.newInstance(2016, 07, 10),
        Workshop_Finish_Date_Time__c = DateTime.newInstance(2016, 07, 20),
        Project_Completed__c = true,
        Complete__c = false        
      );
      insert project1;
            
      List<Project__c> projectList = [SELECT Id, Name, Project_Completed__c, Complete__c, 
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
                                 Where Opportunity__c != null and ((Project_Completed__c = false) OR (Complete__c = false)) and Id = :project1.Id];
      
      Test.startTest();
        List<Map<String, Object>> pgcList = ProjectManagementChart.buildWrapperList(projectList);
      Test.stopTest();
      
      System.assertEquals(1, pgcList.size());
    }
    
    static testMethod void testUpdateProjects()
    {      
      Account acc = new Account(Name='Test Account');
      insert acc;
      
      Opportunity opp = new Opportunity(Name = 'Test Opp', AccountId=acc.Id, StageName='Closed Won', CloseDate=System.today(), Expected_Install_Month__c = 'June', Year__c = String.valueOf(System.today().Year()));
      insert opp;
      
      Project__c project1 = new Project__c(
        Event_Name__c = 'Test project 1',
        Opportunity__c = opp.Id,
        Derig_Date_Time__c = null,
        Derig_Finish_Date_Time__c =  null,
        Event_Date_Time__c = null,
        Event_Finish_Date_Time__c = null,
        Install_Date_Time__c = null,
        Install_Finish_Date_Time__c = null,        
        Workshop_Start_Date_Time__c = null,
        Workshop_Finish_Date_Time__c = null,
        Project_Completed__c = false,
        Complete__c = true
      );
      insert project1;
      
      Map<String, String> uip = new Map<String, String>();
      uip.put('ProjectId', project1.Id);
      uip.put('workshopStartDate', Date.newInstance(2016, 07, 10).format());
      uip.put('workshopEndDate', Date.newInstance(2016, 07, 20).format());
      uip.put('derigStartDate', Date.newInstance(2016, 07, 28).format());
      uip.put('derigEndDate', Date.newInstance(2016, 07, 29).format());
      uip.put('eventStartDate', Date.newInstance(2016, 07, 24).format());
      uip.put('eventEndDate', Date.newInstance(2016, 07, 25).format());
      uip.put('installStartDate', Date.newInstance(2016, 07, 02).format());
      uip.put('installEndDate', Date.newInstance(2016, 07, 03).format());
      uip.put('travelStartDate', Date.newInstance(2016, 07, 01).format());
      uip.put('travelEndDate', Date.newInstance(2016, 07, 02).format());
      uip.put('signoffStartDate', Date.newInstance(2016, 06, 29).format());
      uip.put('truckStartDate', Date.newInstance(2016, 07, 20).format());
      List<Map<String, String>> ui = new List<Map<String, String>>();
      ui.add(uip);
      
      Test.startTest();
        String returnS = ProjectManagementChart.updateProjects(ui);
      Test.stopTest();
      
      System.assertEquals('completed', returnS);
    }
      
    
    static testMethod void testGetCalendarHeadlines()
    { 
      Calendar_Headlines__c ch = new Calendar_Headlines__c(
      Label__c = 'Event1',
      Headline_Type__c = '  Event',
      Start_Date__c = Date.newInstance(2016, 06,10),
      End_Date__c = Date.newInstance(2016,08,09)
      );
      
      insert ch;
      
      Test.startTest();
        List<ProjectManagementChart.CalenderInformation> chList = ProjectManagementChart.getCalendarHeadlines();
      Test.stopTest();
      
      System.assertEquals(1, chList.size());
    }  
    
    static testMethod void testGetAllProjectsWithCustomSettings()
    {
      insert new ProjectHistoricDateInMonths__c(SetupOwnerId=UserInfo.getProfileId(), HistoricDateInMonths__c=2);
      
      Account acc = new Account(Name='Test Account');
      insert acc;
      
      Opportunity opp = new Opportunity(Name = 'Test Opp', AccountId=acc.Id, StageName='Closed Won', CloseDate=System.today(), Expected_Install_Month__c = 'June', Year__c = String.valueOf(System.today().Year()));
      insert opp;
      
      Project__c project1 = new Project__c(
        Event_Name__c = 'Test project 1',
        Opportunity__c = opp.Id,
        Derig_Date_Time__c = DateTime.newInstance(2016, 06, 21),
        Derig_Finish_Date_Time__c = DateTime.newInstance(2016, 06, 22),
        Event_Date_Time__c = DateTime.newInstance(2016, 07, 24),
        Event_Finish_Date_Time__c = DateTime.newInstance(2016, 07, 25),
        Install_Date_Time__c = DateTime.newInstance(2016, 07, 02),
        Install_Finish_Date_Time__c = DateTime.newInstance(2016, 07, 03),
        Workshop_Start_Date_Time__c = DateTime.newInstance(2016, 07, 10),
        Workshop_Finish_Date_Time__c = DateTime.newInstance(2016, 07, 20),
        Project_Completed__c = false,
        Complete__c = false
      );
      
      Project__c project2 = new Project__c(
        Event_Name__c = 'Test project 2',
        Opportunity__c = opp.Id,
        Derig_Date_Time__c = DateTime.newInstance(2015, 09, 21),
        Derig_Finish_Date_Time__c = DateTime.newInstance(2015, 09, 22),
        Event_Date_Time__c = DateTime.newInstance(2015, 10, 24),
        Event_Finish_Date_Time__c = DateTime.newInstance(2015, 10, 25),
        Install_Date_Time__c = DateTime.newInstance(2015, 10, 02),
        Install_Finish_Date_Time__c = DateTime.newInstance(2015, 10, 03),
        Workshop_Start_Date_Time__c = DateTime.newInstance(2015, 10, 10),
        Workshop_Finish_Date_Time__c = DateTime.newInstance(2015, 10, 20),
        Project_Completed__c = true,
        Complete__c = true
      );
      
      Project__c project3 = new Project__c(
        Event_Name__c = 'Test project 3',
        Opportunity__c = opp.Id,
        Workshop_Start_Date_Time__c = DateTime.newInstance(2016, 10, 10),
        Workshop_Finish_Date_Time__c = DateTime.newInstance(2016, 10, 20),
        Project_Completed__c = true,
        Complete__c = true 
      );
      
      List<Project__c> projects = new List<Project__c>{project1, project2, project3};
      insert projects;
      
      Test.startTest();
      
      List<Map<String, Object>> pgcList = ProjectManagementChart.getAllProjects();
      
      Test.stopTest();
      
      System.assert(pgcList.size() > 0);
    }
    
    static testMethod void testGetColorCodes()
  {
    Test.startTest();
      Map<String, String> cc = ProjectManagementChart.getColorCodes();
    
    
    System.assertNotEquals(null, cc);
        
    CustomColorCodes__c createCC = new CustomColorCodes__c();
    createCC.put('Name', 'ColourCodes');
    createCC.put('Derig__c', 'red');
    createCC.put('Event__c', 'blue');
    createCC.put('Install__c', 'orange');
    createCC.put('Collection__c', 'black');
    createCC.put('Workshop__c', 'green');
    createCC.put('Travel__c', 'gray');
    createCC.put('Signoff__c', 'pink');
    insert createCC;
  
      Map<String, String> cc1 = ProjectManagementChart.getColorCodes();
    Test.stopTest();    
    
    System.assertNotEquals(null, cc1);
  
  }
  
  static testMethod void testGetAllPipelineOpportunities()
  {
    Account acc = new Account(Name='Test Account');
      insert acc;
      
      Opportunity opp1 = new Opportunity(Name = 'Test Opp1', AccountId=acc.Id, StageName='Proposal', CloseDate=Date.newInstance(2016, 10,10),Expected_Install_Month__c = 'June', Year__c = String.valueOf(System.today().Year()));
      Opportunity opp2 = new Opportunity(Name = 'Test Opp2', AccountId=acc.Id, StageName='Closed Lost', Lost_Reason__c = 'Test', CloseDate=Date.newInstance(2016, 12,10),Expected_Install_Month__c = 'June', Year__c = String.valueOf(System.today().Year()));
      Opportunity opp3 = new Opportunity(Name = 'Test Opp3', AccountId=acc.Id, StageName='Needs Analysis', CloseDate=Date.newInstance(2016, 11,10),Expected_Install_Month__c = 'June', Year__c = String.valueOf(System.today().Year()));
      Opportunity opp4 = new Opportunity(Name = 'Test Opp4', AccountId=acc.Id, StageName='Closed Won', CloseDate=System.today(), Expected_Install_Month__c = 'June', Year__c = String.valueOf(System.today().Year()));
      insert new List<Opportunity> {opp1, opp2, opp3, opp4};
      
      Test.startTest();
        List<ProjectManagementChart.OpportunityRecords> oppRecords = ProjectManagementChart.getAllPipelineOpportunities();
      Test.stopTest();
      
      System.assertEquals(2, oppRecords.size());
  }
}