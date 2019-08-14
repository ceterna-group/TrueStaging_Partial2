@isTest
private class CrewAndLogisticsGanttChartTest 
{
    static testMethod void testGetAllStaff()
    {
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
        
        Availability_Holidays__c availHol2 = new Availability_Holidays__c( 
            Date_From__c= Date.newInstance( 2016, 06, 01), 
            Date_to__c = Date.newInstance( 2016, 06, 30), 
            Holiday_Confirmed_available_dates__c = 'Holiday/Absence', 
            Staff_List__c = staffSobj2.Id
        );
        
        Availability_Holidays__c availHol3 = new Availability_Holidays__c( 
            Date_From__c= Date.newInstance( 2016, 06, 01), 
            Date_to__c = Date.newInstance( 2016, 06, 30), 
            Holiday_Confirmed_available_dates__c = 'Confirmed Available (freelance only)', 
            Staff_List__c = staffSobj3.Id
        );
        
        insert new List<Availability_Holidays__c>{ availHol2, availHol3 };
        
        Test.startTest();
            List<CrewAndLogisticsGanttChart.StaffInformation> staffInfoList = CrewAndLogisticsGanttChart.getAllStaff();     
        Test.stopTest();
        
        System.assertEquals(3, staffInfoList.size());
        
        for(CrewAndLogisticsGanttChart.StaffInformation staff : staffInfoList)
        {
            if(staff.staffId == staffSobj1.Id)
            {
                System.assertEquals('Employee person 1', staff.staffName);
                System.assertEquals(null, staff.availabilityInfoList);
            }
            if(staff.staffId == staffSobj2.Id)
            {
                System.assertEquals('Employee person 2', staff.staffName);
                System.assertNotEquals(null, staff.availabilityInfoList);
                System.assertEquals(1, staff.availabilityInfoList.size());
            }
            if(staff.staffId == staffSobj3.Id)
            {
                System.assertEquals('Freelance person 1', staff.staffName);
                System.assertNotEquals(null, staff.availabilityInfoList);
                System.assertEquals(1, staff.availabilityInfoList.size());
            }           
        }
    }
    
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
            Project_Roles__c = 'Crew Chief',
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
            Travel_Start_Date__c = DateTime.newInstance(2016, 07, 06),
            Travel_End_Date__c = DateTime.newInstance(2016, 07, 07),
            Client_Visit_Date__c = Date.newInstance(2016, 08, 01),
            Truck_Loading_Date_Time__c = DateTime.newInstance(2016, 07, 23),
            Sign_off_Date_Time__c = DateTime.newInstance(2016, 07, 01),
            Drawing_Completion_Date_Time__c = DateTime.newInstance(2016, 07, 01),
            Crew_Chief_1__c = staffSobj1.Id,
            Crew_Chief_2__c = staffSobj2.Id,
            Crew_Chief_3__c = staffSobj3.Id,
            Additional_Info__c = 'Client visit date information',
            Lock_Dates__c = true
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
            Workshop_Finish_Date_Time__c = DateTime.newInstance(2016, 10, 20),
            Additional_Info__c = 'Client visit date information',
            Lock_Dates__c = false
        );
        
        insert new List<Project__c>{ project1, project2 };
        
        Test.startTest();
            List<CrewAndLogisticsGanttChart.ProjectDetails> projectList = CrewAndLogisticsGanttChart.getAllProjects();
        Test.stopTest();
        
        //System.assertEquals(1 , projectList.size());
        
        //System.assertEquals( 'Test project 1', projectList[0].projectName);
    }
    
    static testMethod void testGetBankHolidays()
    {
        Calendar_Headlines__c hol1 = new Calendar_Headlines__c(
        Label__c = 'Bank holiday1',
        Start_Date__c = Date.newInstance(2016, 12, 25),
        End_Date__c = Date.newInstance(2016, 12, 25),
        Headline_Type__c = 'Holiday'        
        );
        
        Calendar_Headlines__c hol2 = new Calendar_Headlines__c(
        Label__c = 'Event1',
        Start_Date__c = Date.newInstance(2016, 10, 21),
        End_Date__c = Date.newInstance(2016, 10, 25),
        Headline_Type__c = 'Event'      
        );
        
        insert new List<Calendar_Headlines__c>{ hol1, hol2 };
        
        Test.startTest();
            List<CrewAndLogisticsGanttChart.CalenderInformation> calenderInfoList = CrewAndLogisticsGanttChart.getBankHolidays();
        Test.stopTest();
        
        System.assertEquals(1, calenderInfoList.size());    
    }
    
    static testMethod void testGetColorCodes()
    {
        Test.startTest();
            CrewAndLogisticsGanttChart.ColourCodes cc = CrewAndLogisticsGanttChart.getColorCodes();
        
        
        System.assertNotEquals(null, cc);
                
        CustomColorCodes__c createCC = new CustomColorCodes__c();
        createCC.Name = 'ColourCodes';
        createCC.Derig__c = 'red';
        createCC.Event__c = 'blue';
        createCC.Install__c = 'orange';
        createCC.Travel__c  = 'yellow';
        createCC.Workshop__c = 'green';
        createCC.eventEvent__c = 'grey';
        createCC.eventHoliday__c = 'white';
        insert createCC;    
        
    
            CrewAndLogisticsGanttChart.ColourCodes cc1 = CrewAndLogisticsGanttChart.getColorCodes();
        Test.stopTest();        
        
        System.assertNotEquals(null, cc1);
    
    }
    
    static testMethod void testGetRolePickListValues()
    {
        Test.startTest();
            List<String> picklistValues = CrewAndLogisticsGanttChart.getRolePickListValues();
        Test.stopTest();
        
        System.assertNotEquals(null, picklistValues.size());
    }
    
    static testMethod void testGetAllProjectTimeSlots()
    {       
        Project__c project1 = createProject();
        
        Project_Time_Slots__c pts1 = new Project_Time_Slots__c(
            Type__c = 'Drawing',
            TiTle__c = 'Test',
            Start_Time__c = Datetime.newInstance( 2016, 7, 1, 8, 0, 0),
            Finish_Time__c = Datetime.newInstance( 2016, 7, 1, 14, 0, 0),
            Project__c = project1.Id
        );
        
        Project_Time_Slots__c pts2 = new Project_Time_Slots__c(
            Type__c = 'Drawing',
            TiTle__c = 'Test',
            Start_Time__c = Datetime.newInstance( 2016, 7, 1, 14, 0, 0),
            Finish_Time__c = Datetime.newInstance( 2016, 7, 1, 20, 0, 0),
            Project__c = project1.Id
        );
        
        Project_Time_Slots__c pts3 = new Project_Time_Slots__c(
            Type__c = 'Workshop',
            TiTle__c = 'Test',
            Start_Time__c = Datetime.newInstance( 2016, 7, 10, 8, 0, 0),
            Finish_Time__c = Datetime.newInstance( 2016, 7, 10, 14, 0, 0),
            Project__c = project1.Id
        );
        
        insert new List<Project_Time_Slots__c> { pts1, pts2, pts3 };
        
        Staff_List__c staffSobj1 = new Staff_List__c( 
            Name = 'Employee person 1',
            Forklift_license__c = true,
            Forklift_Licence_Expiry_Date__c = Date.newInstance(2016, 10, 21),
            CNC_Operator__c = false,
            Project_Roles__c = 'Labour',
            Status__c = 'Active',
            Allocation_type__c = 'Employee'          
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
        
        
        Labour_Truck_Allocation__c  lta1 = new Labour_Truck_Allocation__c(
            Staff_List__c = staffSobj1.Id,
            Project_Time_Slots__c = pts1.Id,
            Assigned_Role__c = 'Labour'
        );
        
        Labour_Truck_Allocation__c  lta2 = new Labour_Truck_Allocation__c(
            Staff_List__c = staffSobj2.Id,
            Project_Time_Slots__c = pts2.Id,
            Assigned_Role__c = 'Crew Chief'
        );
        
        Labour_Truck_Allocation__c  lta3 = new Labour_Truck_Allocation__c(
            Staff_List__c = staffSobj3.Id,
            Project_Time_Slots__c = pts3.Id,
            Assigned_Role__c = 'Carpenter'
        );
        
        insert new List<Labour_Truck_Allocation__c> { lta1, lta2, lta3 };
        
        Test.startTest();
            List<CrewAndLogisticsGanttChart.ProjectTimeSlots> projectTSList = CrewAndLogisticsGanttChart.getAllProjectTimeSlots( new List<String> { project1.Id});
        Test.stopTest();
        
        System.assertEquals(3, projectTSList.size());
        
        for(CrewAndLogisticsGanttChart.ProjectTimeSlots projTS : projectTSList)
        {
            if(projTS.projectTSId == pts1.Id)
            {
                System.assertEquals(project1.Id, projTS.projectId);
                System.assertEquals(project1.Event_Name__c, projTS.projectName);
                System.assertEquals(Date.newInstance( 2016, 7, 1).format(), projTS.projTSDate);
                System.assertEquals('8:0', projTS.projTSStartTime);
                System.assertEquals('14:0', projTS.projTSFinishTime);
                System.assertEquals( 'Drawing', projTS.projTSType);
                System.assertEquals( 'Test', projTS.projTSTitle);
                System.assertNotEquals(null, projTS.labourAllocationList);
                System.assertEquals(1, projTS.labourAllocationList.size());
                System.assertEquals(staffSobj1.Id, projTS.labourAllocationList[0].staffId);
                System.assertEquals('Labour', projTS.labourAllocationList[0].assignedRole);
            }
            
            if(projTS.projectTSId == pts2.Id)
            {
                System.assertEquals(project1.Id, projTS.projectId);
                System.assertEquals(project1.Event_Name__c, projTS.projectName);
                System.assertEquals(Date.newInstance( 2016, 7, 1).format(), projTS.projTSDate);
                System.assertEquals('14:0', projTS.projTSStartTime);
                System.assertEquals('20:0', projTS.projTSFinishTime);
                System.assertEquals( 'Drawing', projTS.projTSType);
                System.assertEquals( 'Test', projTS.projTSTitle);
                System.assertNotEquals(null, projTS.labourAllocationList);
                System.assertEquals(1, projTS.labourAllocationList.size());
                System.assertEquals(staffSobj2.Id, projTS.labourAllocationList[0].staffId);
                System.assertEquals('Crew Chief', projTS.labourAllocationList[0].assignedRole);
            }
            
            if(projTS.projectTSId == pts3.Id)
            {
                System.assertEquals(project1.Id, projTS.projectId);
                System.assertEquals(project1.Event_Name__c, projTS.projectName);
                System.assertEquals(Date.newInstance( 2016, 7, 10).format(), projTS.projTSDate);
                System.assertEquals('8:0', projTS.projTSStartTime);
                System.assertEquals('14:0', projTS.projTSFinishTime);
                System.assertEquals( 'Workshop', projTS.projTSType);
                System.assertEquals( 'Test', projTS.projTSTitle);
                System.assertNotEquals(null, projTS.labourAllocationList);
                System.assertEquals(1, projTS.labourAllocationList.size());
                System.assertEquals(staffSobj3.Id, projTS.labourAllocationList[0].staffId);
                System.assertEquals('Carpenter', projTS.labourAllocationList[0].assignedRole);
            }
        }
    }
    
    static testMethod void testDeleteProjectTimeSlots()
    {
        Project__c project1 = createProject();
        
        Staff_List__c staffSobj1 = new Staff_List__c( 
            Name = 'Employee person 1',
            Forklift_license__c = true,
            Forklift_Licence_Expiry_Date__c = Date.newInstance(2016, 10, 21),
            CNC_Operator__c = false,
            Project_Roles__c = 'Labour',
            Status__c = 'Active',
            Allocation_type__c = 'Employee'          
        );
        insert staffSobj1;
        
        Project_Time_Slots__c pts1 = new Project_Time_Slots__c(
            Type__c = 'Drawing',
            Title__c = 'Test',
            Start_Time__c = Datetime.newInstance( 2016, 7, 1, 8, 0, 0),
            Finish_Time__c = Datetime.newInstance( 2016, 7, 1, 14, 0, 0),
            Project__c = project1.Id
        );
        insert pts1;
        
        Labour_Truck_Allocation__c  lta1 = new Labour_Truck_Allocation__c(
            Staff_List__c = staffSobj1.Id,
            Project_Time_Slots__c = pts1.Id,
            Assigned_Role__c = 'Labour'
        );
        insert lta1;
        
        Test.startTest();
            String success = CrewAndLogisticsGanttChart.deleteProjectTimeSlots( new List<String> { pts1.Id});
        Test.stopTest();
        
        System.assertEquals('Complete', success);
        
    }
    
    static testMethod void testUpdateCreateProjectTimeSlots()
    {
        Project__c project1 = createProject();
        
        Project_Time_Slots__c pts1 = new Project_Time_Slots__c(
            Type__c = 'Drawing',
            Title__c = 'Test',
            Start_Time__c = Datetime.newInstance( 2016, 7, 1, 8, 0, 0),
            Finish_Time__c = Datetime.newInstance( 2016, 7, 1, 14, 0, 0),
            Project__c = project1.Id
        );
        
        Project_Time_Slots__c pts2 = new Project_Time_Slots__c(
            Type__c = 'Drawing',
            Title__c = 'Test',
            Start_Time__c = Datetime.newInstance( 2016, 7, 1, 14, 0, 0),
            Finish_Time__c = Datetime.newInstance( 2016, 7, 1, 20, 0, 0),
            Project__c = project1.Id
        );
        
        insert new List<Project_Time_Slots__c> {pts1, pts2};
        
        Staff_List__c staffSobj1 = new Staff_List__c( 
            Name = 'Employee person 1',
            Forklift_license__c = true,
            Forklift_Licence_Expiry_Date__c = Date.newInstance(2016, 10, 21),
            CNC_Operator__c = false,
            Project_Roles__c = 'Labour',
            Status__c = 'Active',
            Allocation_type__c = 'Employee'          
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
        
        Staff_List__c staffSobj4 = new Staff_List__c( 
            Name = 'Freelance person 2',
            Forklift_license__c = false,
            CNC_Operator__c = false,
            Project_Roles__c = 'Carpenter',
            Status__c = 'Active',
            Allocation_type__c = 'Freelance'             
        );
        
        insert new List<Staff_List__c>{staffSobj1, staffSobj2, staffSobj3, staffSobj4};     
        
        Labour_Truck_Allocation__c  lta1 = new Labour_Truck_Allocation__c(
            Staff_List__c = staffSobj1.Id,
            Project_Time_Slots__c = pts1.Id,
            Assigned_Role__c = 'Labour'
        );
        
        Labour_Truck_Allocation__c  lta2 = new Labour_Truck_Allocation__c(
            Staff_List__c = staffSobj2.Id,
            Project_Time_Slots__c = pts2.Id,
            Assigned_Role__c = 'Carpenter'
        );
        
        insert new List<Labour_Truck_Allocation__c>{lta1, lta2};
        
        CrewAndLogisticsGanttChart.UpdateProjectTimeSlots updateProj1 = new CrewAndLogisticsGanttChart.UpdateProjectTimeSlots();
        updateProj1.projectId = project1.Id;
        updateProj1.projTSType = 'Workshop';
        updateProj1.projTSTitle = 'Title';
        updateProj1.projTSId = 'noid';
        updateProj1.projTSDate = Date.newInstance(2016, 07, 10).format();
        updateProj1.startTime = '08:00';
        updateProj1.finishTime = '14:00';
        
        CrewAndLogisticsGanttChart.CreateLabourAllocation allocation1 = new CrewAndLogisticsGanttChart.CreateLabourAllocation();
        allocation1.staffId = staffSobj3.Id;
        allocation1.assignedRole = 'Carpenter';
        updateProj1.crewMembers = new List<CrewAndLogisticsGanttChart.CreateLabourAllocation>{allocation1};
        
        CrewAndLogisticsGanttChart.UpdateProjectTimeSlots updateProj2 = new CrewAndLogisticsGanttChart.UpdateProjectTimeSlots();
        updateProj2.projectId = project1.Id;
        updateProj2.projTSType = 'Drawing';
        updateProj2.projTSTitle = 'Title';
        updateProj2.projTSId = pts2.Id;
        updateProj2.projTSDate = Date.newInstance(2016, 07, 01).format();
        updateProj2.startTime = '14:00';
        updateProj2.finishTime = '20:00';
        
        CrewAndLogisticsGanttChart.CreateLabourAllocation allocation2 = new CrewAndLogisticsGanttChart.CreateLabourAllocation();
        allocation2.staffId = staffSobj4.Id;
        allocation2.assignedRole = 'Carpenter';
        updateProj2.crewMembers = new List<CrewAndLogisticsGanttChart.CreateLabourAllocation>{allocation2};
        
        List<CrewAndLogisticsGanttChart.UpdateProjectTimeSlots> updatePTSList = new List<CrewAndLogisticsGanttChart.UpdateProjectTimeSlots>{updateProj1, updateProj2};
        
        Test.startTest();
            String success = CrewAndLogisticsGanttChart.updateCreateProjectTimeSlots(updatePTSList);
        Test.stopTest();
        
        System.assertEquals('Complete', success);
        
        List<Project_Time_Slots__c> newProjectTS  = [Select Id, Name, Type__c, Title__c, Start_Time__c, Project__c, Finish_Time__c, (Select Assigned_Role__c, Id, Name, Project_Time_Slots__c, Staff_List__c from Labour_Truck_Allocation__r) from Project_Time_Slots__c];
        
        System.assertEquals(3, newProjectTS.size());
        
        for(Project_Time_Slots__c existingPTS : newProjectTS)
        {
            if(existingPTS.Type__c == 'Workshop')
            {
                System.assertEquals(project1.Id, existingPTS.Project__c);
                System.assertEquals(DateTime.newInstance(2016, 07, 10, 8, 0, 0), existingPTS.Start_Time__c);
                System.assertEquals(DateTime.newInstance(2016, 07, 10, 14, 0, 0), existingPTS.Finish_Time__c);
                System.assertNotEquals(null, existingPTS.Labour_Truck_Allocation__r);
                System.assertEquals(1, existingPTS.Labour_Truck_Allocation__r.size());
                System.assertEquals(staffSobj3.Id, existingPTS.Labour_Truck_Allocation__r[0].Staff_List__c);
            }
            
            if(existingPTS.Id == pts2.Id)
            {
                System.assertEquals(project1.Id, existingPTS.Project__c);
                System.assertEquals(DateTime.newInstance(2016, 07, 1, 14, 0, 0), existingPTS.Start_Time__c);
                System.assertEquals(DateTime.newInstance(2016, 07, 1, 20, 0, 0), existingPTS.Finish_Time__c);
                System.assertNotEquals(null, existingPTS.Labour_Truck_Allocation__r);
                System.assertEquals(1, existingPTS.Labour_Truck_Allocation__r.size());
                System.assertEquals(staffSobj4.Id, existingPTS.Labour_Truck_Allocation__r[0].Staff_List__c);
            }
        }
    }
    
    public static Project__c createProject()
    {
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
            Drawing_Completion_Date_Time__c = DateTime.newInstance(2016, 07, 01),
            Client_Visit_Date__c = Date.newInstance(2016, 08, 01),
            Additional_Info__c = 'client visit date information',
            Lock_Dates__c = true
        );
        
        insert project1;
        
        Project__c newProject = [Select Id, Name, Event_Name__c from Project__c limit 1];
        return newProject;
    }

}