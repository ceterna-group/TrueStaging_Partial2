@isTest
private class AfterProjectTriggerTest 
{
	static testMethod void testProjectLockDates()
    {
        
    	Project__c project1 = createProject();
    	Map<String, Id> staffMap = createStaffList();
    	
//    	Project_Time_Slots__c pts1 = new Project_Time_Slots__c(
//    		Type__c = 'Drawing',
//    		Start_Time__c = Datetime.newInstance( 2016, 7, 1, 8, 0, 0),
//    		Finish_Time__c = Datetime.newInstance( 2016, 7, 1, 14, 0, 0),
//    		Project__c = project1.Id
//    	);
//
//    	Project_Time_Slots__c pts2 = new Project_Time_Slots__c(
//    		Type__c = 'Drawing',
//    		Start_Time__c = Datetime.newInstance( 2016, 7, 1, 14, 0, 0),
//    		Finish_Time__c = Datetime.newInstance( 2016, 7, 1, 20, 0, 0),
//    		Project__c = project1.Id
//    	);
//
//
////    	insert new List<Project_Time_Slots__c> { pts1, pts2 };
//
//		Labour_Truck_Allocation__c  lta1 = new Labour_Truck_Allocation__c(
//    		Staff_List__c = staffMap.get('Employee person 1'),
//    		Project_Time_Slots__c = pts1.Id,
//    		Assigned_Role__c = 'Labour'
//    	);
//
//    	Labour_Truck_Allocation__c  lta2 = new Labour_Truck_Allocation__c(
//    		Staff_List__c = staffMap.get('Employee person 2'),
//    		Project_Time_Slots__c = pts2.Id,
//    		Assigned_Role__c = 'Crew Chief'
//    	);
//
//    	insert new List<Labour_Truck_Allocation__c> { lta1, lta2 };
    	
    	Test.startTest();
    	
    	try
    	{
    		project1.Lock_Dates__c = true;
    		update project1;
    	}
    	catch(Exception e)
    	{
    		System.assert(false, e);
    	}
    	
    	List<Project_Time_Slots__c> projectTSList = [Select Id, Project__c from Project_Time_Slots__c where Project__c = :project1.Id];
//    	System.assertEquals(2, projectTSList.size());
    	
    	try
    	{
    		project1.Drawing_Completion_Date_Time__c = DateTime.newInstance(2016, 06, 19);
    		update project1;
    	}
    	catch(Exception e)
    	{
    		System.assert(false, e);
    	}
    	
    	List<Project_Time_Slots__c> projectTSList1 = [Select Id, Project__c from Project_Time_Slots__c where Project__c = :project1.Id];
//    	System.assertEquals(2, projectTSList1.size());
    	
    	try
    	{
    		project1.Lock_Dates__c = false;
    		update project1;
    	}
    	catch(Exception e)
    	{
    		System.assert(false, e);
    	}
    	
    	Test.stopTest();
    	
    	List<Project_Time_Slots__c> projectTSList2 = [Select Id, Project__c from Project_Time_Slots__c where Project__c = :project1.Id];
    	System.assertEquals(0, projectTSList2.size());
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
	    	Travel_Start_Date__c = DateTime.newInstance(2016, 07, 21),
	    	Travel_End_Date__c = DateTime.newInstance(2016, 07, 22),
	    	Sign_off_Date_Time__c = DateTime.newInstance(2016, 07, 08),
	    	Drawing_Completion_Date_Time__c = DateTime.newInstance(2016, 06, 18)
    	);
    	
    	insert project1;
    	
    	return project1;
    }
    
    public static Map<String, Id> createStaffList()
    {
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
		
		insert new List<Staff_List__c>{staffSobj1, staffSobj2};
		
		Map<String, Id> staffMap = new Map<String, Id>{ 'Employee person 1' => staffSobj1.Id, 'Employee person 2' => staffSobj2.Id};
		return staffMap;
    }
}