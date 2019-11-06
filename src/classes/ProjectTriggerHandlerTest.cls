@IsTest
public with sharing class ProjectTriggerHandlerTest {

    //testSetup used for creating common test records that are available for all test methods in this class.

    public static Project__c createProject()
    {
        Account acc = new Account(Name='Test Account');
        insert acc;

        Opportunity opp = new Opportunity(Name = 'Test Opp', AccountId=acc.Id, StageName='Closed Won', CloseDate=System.today(), Expected_Install_Month__c = 'June', Year__c = String.valueOf(System.today().Year()));
        insert opp;

        Project__c project1 = new Project__c(
                Event_Name__c = 'Test project 1',
                Opportunity__c = opp.Id,
                Derig_Date_Time__c = DateTime.now(),
                Derig_Finish_Date_Time__c = DateTime.now().addDays(5),
                Event_Date_Time__c = DateTime.now(),
                Event_Finish_Date_Time__c = DateTime.now().addDays(5),
                Install_Date_Time__c = DateTime.now(),
                Install_Finish_Date_Time__c = DateTime.now().addDays(5),
                Workshop_Start_Date_Time__c = DateTime.now(),
                Workshop_Finish_Date_Time__c = DateTime.now().addDays(5),
                Travel_Start_Date__c = DateTime.now(),
                Travel_End_Date__c = DateTime.now().addDays(5),
                Sign_off_Date_Time__c = DateTime.now(),
                Drawing_Completion_Date_Time__c = DateTime.now().addDays(5)
        );

        insert project1;
        return project1;
    }


    @IsTest
    public static void checkBookingOverrideTest(){


        Project__c project1 = createProject();

        Project_Time_Slots__c pts1 = new Project_Time_Slots__c(
                Type__c = 'Derig',
                Start_Time__c = Datetime.now(),
                Finish_Time__c = Datetime.now().addDays(6),
                Project__c = project1.Id
        );
        insert pts1;

        Staff_List__c staffSobj1 = new Staff_List__c(
                Name = 'Employee person 1',
                Forklift_license__c = true,
                Forklift_Licence_Expiry_Date__c = Date.today(),
                CNC_Operator__c = false,
                Project_Roles__c = 'Labour',
                Status__c = 'Active',
                Allocation_type__c = 'Employee'
        );

        insert new List<Staff_List__c>{staffSobj1};

        Map<String, Id> staffMap = new Map<String, Id>{ 'Employee person 1' => staffSobj1.Id};

        Labour_Truck_Allocation__c  lta1 = new Labour_Truck_Allocation__c(
                Staff_List__c = staffMap.get('Employee person 1'),
                Project_Time_Slots__c = pts1.Id,
                Assigned_Role__c = 'Labour'
        );

        insert new List<Labour_Truck_Allocation__c> { lta1 };

        System.assertEquals(1, [SELECT Email_Sent__c FROM Project_Time_Slots__c WHERE Email_Sent__c = TRUE AND Id = : pts1.Id LIMIT 1].size());
        System.assertEquals(1, [SELECT Type__c FROM Project_Time_Slots__c WHERE Type__c = 'Derig' AND Id = : pts1.Id LIMIT 1].size());

        pts1.Start_Time__c = Datetime.newInstance( 2019, 7, 5, 14, 0, 0);
        update pts1;

        System.assertEquals(false, pts1.Email_Sent__c);

    }

}