@isTest
private class BatchToCreateTimecardsTest {
    static testMethod void testCreateTimeCardsForWorkshoptPTS() {
    	Project__c project1 = createProject();    	
    	
    	Project_Time_Slots__c pts1 = new Project_Time_Slots__c(
    		Type__c 			= 'Workshop',
    		Start_Time__c 		= DateTime.newInstance( System.today().addDays(-1), Time.newInstance(8, 0, 0, 0)),
    		Finish_Time__c 		= DateTime.newInstance( System.today().addDays(-1), Time.newInstance(12, 0, 0, 0)),
    		Project__c 			= project1.Id
    	);    	
    	insert  pts1;
    	
    	Staff_List__c staffSobj1 = new Staff_List__c( 
			Name 				= 'Employee person 1',
			Forklift_license__c = true,
            Forklift_Licence_Expiry_Date__c = Date.newInstance(2016, 10, 21),
			CNC_Operator__c 	= false,
			Project_Roles__c 	= 'Labour',
			Status__c 			= 'Active',
			Allocation_type__c 	= 'Employee'
		);
		insert staffSobj1;
		
		Labour_Truck_Allocation__c  lta1 = new Labour_Truck_Allocation__c(
    		Staff_List__c 		= staffSobj1.Id,
    		Project_Time_Slots__c = pts1.Id,
    		Assigned_Role__c 	= 'Labour'
    	);
    	insert lta1;
    	
    	Test.startTest();
    		Id batchJobId = Database.executeBatch(new BatchToCreateTimecards(), 200);
    	Test.stopTest();
    	
    	List<Clocking_Machine_Data__c> clockingData = [SELECT Id FROM Clocking_Machine_Data__c];
    	System.assertEquals(0, clockingData.size());
    }
    
    static testMethod void testCreateTimeCardsForTruckAllocation()
    {
    	Project__c project1 = createProject();
    	
    	Project_Time_Slots__c pts1 = new Project_Time_Slots__c(
    		Type__c 			= 'Travel',
    		Start_Time__c 		= DateTime.newInstance( System.today().addDays(-1), Time.newInstance(8, 0, 0, 0)),
    		Finish_Time__c 		= DateTime.newInstance( System.today().addDays(-1), Time.newInstance(12, 0, 0, 0)),
    		Project__c 			= project1.Id
    	);    	
    	insert  pts1;
    	
    	Staff_List__c staffSobj1 = new Staff_List__c( 
			Name 				= 'Employee person 1',
			Forklift_license__c = true,
            Forklift_Licence_Expiry_Date__c = Date.newInstance(2016, 10, 21),
			CNC_Operator__c 	= false,
			Project_Roles__c 	= 'Labour',
			Status__c 			= 'Active',
			Allocation_type__c 	= 'Truck'
		);
		insert staffSobj1;
		
		Labour_Truck_Allocation__c  lta1 = new Labour_Truck_Allocation__c(
    		Staff_List__c 		= staffSobj1.Id,
    		Project_Time_Slots__c = pts1.Id,
    		Assigned_Role__c 	= 'Transport'
    	);
    	insert lta1;
    	
    	Test.startTest();
    		Id batchJobId = Database.executeBatch(new BatchToCreateTimecards(), 200);
    	Test.stopTest();
    	
    	List<Clocking_Machine_Data__c> clockingData = [Select Id from Clocking_Machine_Data__c];
    	System.assertEquals(0, clockingData.size());
    }
    
    static testMethod void testCreateTimeCardsWithOnePTS()
    {
    	Project__c project1 = createProject();
    	
    	Project_Time_Slots__c pts1 = new Project_Time_Slots__c(
    		Type__c 			= 'Travel',
    		Start_Time__c 		= Datetime.newInstance( System.today().addDays(-1), Time.newInstance(8, 0, 0, 0)),
    		Finish_Time__c 		= Datetime.newInstance( System.today().addDays(-1), Time.newInstance(12, 0, 0, 0)),
    		Project__c 			= project1.Id
    	);    	
    	insert  pts1;
    	
    	Staff_List__c staffSobj1 = new Staff_List__c( 
			Name 				= 'Truck 1',
			Forklift_license__c = true,
            Forklift_Licence_Expiry_Date__c = Date.newInstance(2016, 10, 21),
			CNC_Operator__c 	= false,
			Project_Roles__c 	= 'Labour',
			Status__c 			= 'Active',
			Allocation_type__c 	= 'Truck'
		);
		
		Staff_List__c staffSobj2 = new Staff_List__c( 
			Name 				= 'Employee person 2',
			Forklift_license__c = true,
            Forklift_Licence_Expiry_Date__c = Date.newInstance(2016, 10, 21),
			CNC_Operator__c 	= false,
			Project_Roles__c 	= 'Labour',
			Status__c 			= 'Active',
			Allocation_type__c 	= 'Employee'
		);
		insert new List<Staff_List__c>{staffSobj1, staffSobj2};
		
		Labour_Truck_Allocation__c  lta1 = new Labour_Truck_Allocation__c(
    		Staff_List__c 		= staffSobj1.Id,
    		Project_Time_Slots__c = pts1.Id,
    		Assigned_Role__c 	= 'Transport'
    	);
    	
    	Labour_Truck_Allocation__c  lta2 = new Labour_Truck_Allocation__c(
    		Staff_List__c 		= staffSobj2.Id,
    		Project_Time_Slots__c = pts1.Id,
    		Assigned_Role__c 	= 'Labour'
    	);
    	insert new List<Labour_Truck_Allocation__c> {lta1, lta2};
    	
    	Test.startTest();
    		Id batchJobId = Database.executeBatch(new BatchToCreateTimecards(), 200);
    	Test.stopTest();
    	
    	List<Clocking_Machine_Data__c> clockingData = [SELECT Id, Clock_in_Time__c, Clock_Out_Time__c,
															Project_Number__c, Staff_List__c
														FROM Clocking_Machine_Data__c];
    	System.assertEquals(1, clockingData.size());
    	System.assertEquals(DateTime.newInstance( System.today().addDays(-1), Time.newInstance(8, 0, 0, 0)), clockingData[0].Clock_in_Time__c);
    	System.assertEquals(DateTime.newInstance( System.today().addDays(-1), Time.newInstance(12, 0, 0, 0)), clockingData[0].Clock_Out_Time__c);
    	System.assertEquals(project1.Id, clockingData[0].Project_Number__c);
    	System.assertEquals(staffSobj2.Id, clockingData[0].Staff_List__c);    	
    }
    
    static testMethod void testCreateTimeCardsWithMultiPTS() {
    	Project__c project1 = createProject();
    	
    	Project_Time_Slots__c pts1 = new Project_Time_Slots__c(
    		Type__c 				= 'Install',
    		Start_Time__c 			= DateTime.newInstance( System.today().addDays(-1), Time.newInstance(8, 0, 0, 0)),
    		Finish_Time__c 			= DateTime.newInstance( System.today().addDays(-1), Time.newInstance(12, 0, 0, 0)),
    		Project__c 				= project1.Id
    	);  
    	
    	Project_Time_Slots__c pts2 = new Project_Time_Slots__c(
    		Type__c 				= 'Derig',
    		Start_Time__c 			= DateTime.newInstance( System.today().addDays(-1), Time.newInstance(14, 0, 0, 0)),
    		Finish_Time__c 			= DateTime.newInstance( System.today().addDays(-1), Time.newInstance(18, 0, 0, 0)),
    		Project__c 				= project1.Id
    	);  
    	  	
    	insert  new List<Project_Time_Slots__c>{pts1, pts2};
    	
    	Staff_List__c staffSobj1 = new Staff_List__c( 
			Name 					= 'Employee 1',
			Forklift_license__c 	= true,
            Forklift_Licence_Expiry_Date__c = Date.newInstance(2016, 10, 21),
			CNC_Operator__c 		= false,
			Project_Roles__c 		= 'Carpenter',
			Status__c 				= 'Active',
			Allocation_type__c 		= 'Employee'
		);
		
		Staff_List__c staffSobj2 = new Staff_List__c( 
			Name 					= 'Employee  2',
			Forklift_license__c 	= true,
            Forklift_Licence_Expiry_Date__c = Date.newInstance(2016, 10, 21),
			CNC_Operator__c 		= false,
			Project_Roles__c 		= 'Labour',
			Status__c 				= 'Active',
			Allocation_type__c 		= 'Freelance'
		);
		insert new List<Staff_List__c>{staffSobj1, staffSobj2};
		
		Labour_Truck_Allocation__c  lta1 = new Labour_Truck_Allocation__c(
    		Staff_List__c 			= staffSobj1.Id,
    		Project_Time_Slots__c 	= pts1.Id,
    		Assigned_Role__c 		= 'Carpenter'
    	);
    	
    	Labour_Truck_Allocation__c  lta2 = new Labour_Truck_Allocation__c(
    		Staff_List__c 			= staffSobj2.Id,
    		Project_Time_Slots__c 	= pts2.Id,
    		Assigned_Role__c 		= 'Labour'
    	);
    	insert new List<Labour_Truck_Allocation__c> {lta1, lta2};
    	
    	Test.startTest();
    		Id batchJobId = Database.executeBatch(new BatchToCreateTimecards(), 200);
    	Test.stopTest();
    	
    	List<Clocking_Machine_Data__c> clockingData = [Select Id, Clock_in_Time__c, Clock_Out_Time__c, Project_Number__c, Staff_List__c, Timecard_Type__c from Clocking_Machine_Data__c];
    	System.assertEquals(2, clockingData.size());
    	for(Clocking_Machine_Data__c timecard : clockingData)
    	{
	    	if(timecard.Staff_List__c == staffSobj1.Id)
	    	{
		    	System.assertEquals(DateTime.newInstance( System.today().addDays(-1), Time.newInstance(8, 0, 0, 0)), timecard.Clock_in_Time__c);
		    	System.assertEquals(DateTime.newInstance( System.today().addDays(-1), Time.newInstance(12, 0, 0, 0)), timecard.Clock_Out_Time__c);
		    	System.assertEquals(project1.Id, timecard.Project_Number__c);
		    	System.assertEquals('Other', timecard.Timecard_Type__c);
	    	}
	    	else
	    	{
	    		System.assertEquals(DateTime.newInstance( System.today().addDays(-1), Time.newInstance(14, 0, 0, 0)), timecard.Clock_in_Time__c);
		    	System.assertEquals(DateTime.newInstance( System.today().addDays(-1), Time.newInstance(18, 0, 0, 0)), timecard.Clock_Out_Time__c);
		    	System.assertEquals(project1.Id, timecard.Project_Number__c);
		    	System.assertEquals('Other', timecard.Timecard_Type__c);
	    	}	
    	}
    }
    
    static testMethod void testCreateTimeCardsWithOnePTSScheduler() {
    	Project__c project1 = createProject();
    	
    	Project_Time_Slots__c pts1 = new Project_Time_Slots__c(
    		Type__c 				= 'Travel',
    		Start_Time__c 			= Datetime.newInstance( System.today().addDays(-1), Time.newInstance(8, 0, 0, 0)),
    		Finish_Time__c 			= Datetime.newInstance( System.today().addDays(-1), Time.newInstance(12, 0, 0, 0)),
    		Project__c 				= project1.Id
    	);    	
    	insert  pts1;
    	
    	Staff_List__c staffSobj1 = new Staff_List__c( 
			Name 					= 'Truck 1',
			Forklift_license__c 	= true,
            Forklift_Licence_Expiry_Date__c = Date.newInstance(2016, 10, 21),
			CNC_Operator__c 		= false,
			Project_Roles__c 		= 'Labour',
			Status__c 				= 'Active',
			Allocation_type__c 		= 'Truck'
		);
		
		Staff_List__c staffSobj2 = new Staff_List__c( 
			Name 					= 'Employee person 2',
			Forklift_license__c 	= true,
            Forklift_Licence_Expiry_Date__c = Date.newInstance(2016, 10, 21),
			CNC_Operator__c 		= false,
			Project_Roles__c 		= 'Labour',
			Status__c 				= 'Active',
			Allocation_type__c 		= 'Employee'
		);
		insert new List<Staff_List__c>{staffSobj1, staffSobj2};
		
		Labour_Truck_Allocation__c  lta1 = new Labour_Truck_Allocation__c(
    		Staff_List__c 			= staffSobj1.Id,
    		Project_Time_Slots__c 	= pts1.Id,
    		Assigned_Role__c 		= 'Transport'
    	);
    	
    	Labour_Truck_Allocation__c  lta2 = new Labour_Truck_Allocation__c(
    		Staff_List__c 			= staffSobj2.Id,
    		Project_Time_Slots__c 	= pts1.Id,
    		Assigned_Role__c 		= 'Labour'
    	);
    	insert new List<Labour_Truck_Allocation__c> {lta1, lta2};
    	
    	Test.startTest();
    		BatchToCreateTimecardsScheduler.runBatch();
    	Test.stopTest();	
    }
    
    
    public static Project__c createProject()
	{
		Account acc = new Account(Name='Test Account');
    	insert acc;
    	
    	Opportunity opp = new Opportunity(
			Name 			= 'Test Opp',
			AccountId		=acc.Id,
			StageName		='Closed Won',
			CloseDate		=System.today(),
			Expected_Install_Month__c = 'June',
			Year__c 		= String.valueOf(System.today().year()));
    	insert opp;
    	
    	Project__c project1 = new Project__c(
	    	Event_Name__c 					= 'Test project 1',
	    	Opportunity__c 					= opp.Id,
	    	Derig_Date_Time__c 				= Datetime.newInstance(2016, 06, 21),
	    	Derig_Finish_Date_Time__c 		= Datetime.newInstance(2016, 06, 22),
	    	Event_Date_Time__c			 	= Datetime.newInstance(2016, 07, 24),
	    	Event_Finish_Date_Time__c 		= Datetime.newInstance(2016, 07, 25),
	    	Install_Date_Time__c 			= Datetime.newInstance(2016, 07, 02),
	    	Install_Finish_Date_Time__c 	= Datetime.newInstance(2016, 07, 03),
	    	Workshop_Start_Date_Time__c 	= Datetime.newInstance(2016, 07, 10),
	    	Workshop_Finish_Date_Time__c 	= Datetime.newInstance(2016, 07, 20),
	    	Drawing_Completion_Date_Time__c = Datetime.newInstance(2016, 07, 01),
	    	Client_Visit_Date__c 			= Date.newInstance(2016, 08, 01),
	    	Lock_Dates__c 					= true
    	);
    	
    	insert project1;
    	
    	Project__c newProject = [SELECT Id, Name, Event_Name__c FROM Project__c LIMIT 1];
    	return newProject;
	}
}