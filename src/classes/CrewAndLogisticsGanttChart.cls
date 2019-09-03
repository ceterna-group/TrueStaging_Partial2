public  with sharing class CrewAndLogisticsGanttChart 
{
	public static final String fail = 'Error';
	public static final String success = 'Complete';    
	//public String passedParam1 {get; set;}
	//public String passedParam2 {get; set;}
	
	//get all the staff records that are active
	@RemoteAction
	public static List<StaffInformation> getAllStaff()
	{
		List<StaffInformation> staffInfoList = new List<StaffInformation>();
		List<Staff_List__c> staffList = [SELECT Id, Name, Status__c, Project_Roles__c, IPAF__c, Driver_s_Licence__c,
											Forklift_license__c, CNC_Operator__c, Allocation_type__c,	Secondary_Project_Role__c, Group__c,
											(SELECT RecordTypeId, Date_From__c, Date_to__c, Holiday_Confirmed_available_dates__c
											FROM Availability_Holidays__r)
										FROM Staff_List__c
										WHERE Name != NULL
										AND Status__c ='Active'];
														
		staffInfoList = buildWrapperList(staffList);														
		return staffInfoList;
	}
	
	//builds wrapper class data from staff records
	public static List<StaffInformation> buildWrapperList(List<Staff_List__c> staffList)
	{system.debug('staffList'+staffList);
		List<StaffInformation> staffInfoList = new List<StaffInformation>();
		if(staffList != null)
		{
			for(Staff_List__c staff : staffList)
			{
				StaffInformation staffInfo = new StaffInformation();
				staffInfo.staffId = staff.Id;
				staffInfo.staffName = staff.Name;
				staffInfo.projectRole = staff.Project_Roles__c;
				staffInfo.forkliftLicense = staff.Forklift_license__c;
				staffInfo.cncOperator = staff.CNC_Operator__c;
				staffInfo.allocationType = staff.Allocation_type__c;
				staffInfo.iPAF = staff.IPAF__c;
				staffInfo.driversLicense = staff.Driver_s_Licence__c;
				staffInfo.secondaryRole = staff.Secondary_Project_Role__c;
				staffInfo.groupName = staff.Group__c;
								
				List<Availability_Holidays__c> availbilityHolidaysList = staff.Availability_Holidays__r;
				List<AvailabilityInformation> aiList = new List<AvailabilityInformation>();
				if(availbilityHolidaysList != null && availbilityHolidaysList.size() > 0)                  //if freelance then availability records are when the staff is available. if employee then availability records are when the staff has booked holidays.
				{
					for(Availability_Holidays__c sobj : availbilityHolidaysList)
					{
						AvailabilityInformation availabilitySObj = new AvailabilityInformation();
						if(sobj.Holiday_Confirmed_available_dates__c != null) availabilitySObj.holidayConfirmedAvailableString = sobj.Holiday_Confirmed_available_dates__c;
						if(sobj.Date_From__c != null) availabilitySObj.dateFrom = sobj.Date_From__c.format();
						if(sobj.Date_to__c != null) availabilitySObj.dateTo = sobj.Date_to__c.format();
						
						aiList.add(availabilitySObj);						
					}
					
					if(aiList != null && !aiList.isEmpty())
					{
						staffInfo.availabilityInfoList = aiList;
					}
				}

			staffInfoList.add(staffInfo);
			}
		}		
		return staffInfoList;
	}
	
	
	//gets all the projects that are closed won and are locked
	@RemoteAction
	public static List<ProjectDetails> getAllProjects() {

		Integer months = 14;
		ProjectHistoricDateInMonths__c hd = ProjectHistoricDateInMonths__c.getInstance(UserInfo.getProfileId());

		if(hd.HistoricDateInMonths__c != null) {
			months = Integer.valueOf(hd.HistoricDateInMonths__c);
		}

		Date historicDate = (Test.isRunningTest()) ? Date.today().addYears(-20) : System.today().addMonths(-months);
		
		List<ProjectDetails> projectDetails = new List<ProjectDetails>();
		
		List<Project__c> projectList = [SELECT Id, Name, Client_Name__c, Event_Name__c, Project_Manager__c,
											Project_Manager__r.Name, Workshop_Finish_Date_Time__c, Install_Date_Time__c,
											Install_Finish_Date_Time__c, Derig_Date_Time__c	, Derig_Finish_Date_Time__c,
											Crew_Chief_1__c, Crew_Chief_1__r.Name, Event_Date_Time__c, Event_Finish_Date_Time__c,
											Workshop_Start_Date_Time__c, Crew_Chief_2__c, Crew_Chief_2__r.Name, Crew_Chief_3__c,
											Crew_Chief_3__r.Name, Lock_Dates__c, Client_Visit_Date__c, Travel_Start_Date__c,
											Travel_End_Date__c, Total_Labour_Hours_Estimate__c, Install_Year__c,
											Install_Month__c, Opportunity__r.Total_Quantity_for_Site__c,
											Opportunity__r.Total_Quantity_for_Workshop__c,Additional_Info__c,
											Install_start_Date_Time_2__c, Install_Finish_Date_Time_2__c,
											Event__c, Event_Finish_Date_Time_2__c,
											De_Rig_Start_Date_Time_2__c, Derig_Finish_Date_Time_2__c
										FROM Project__c
										WHERE (Opportunity__c != NULL)
										AND (Opportunity__r.StageName = 'Closed Won')
//										 and (Lock_Dates__c = true)
										AND (Install_Date_Time__c >= :historicDate)
										AND ((Project_Completed__c = FALSE) OR (Complete__c = FALSE))];
																 
		if(projectList != null) {
			for(Project__c proj : projectList) {
				ProjectDetails projD = new ProjectDetails();
				projD.projectId = proj.Id;
				projD.projectNumber = proj.Name;
				projD.projectAccountName = proj.Client_Name__c;
				if(proj.Event_Name__c != null) projD.projectName = proj.Event_Name__c;
				if(proj.Project_Manager__c != null) projD.PMName = proj.Project_Manager__r.Name;
				if(proj.Workshop_Start_Date_Time__c != null) projD.workshopStartDate = proj.Workshop_Start_Date_Time__c.format('dd/MM/yyyy');				
				if(proj.Workshop_Finish_Date_Time__c != null)  projD.workshopEndDate = proj.Workshop_Finish_Date_Time__c.format('dd/MM/yyyy');
				if(proj.Derig_Date_Time__c != null)  projD.derigStartDate = proj.Derig_Date_Time__c.format('dd/MM/yyyy');
				if(proj.Derig_Finish_Date_Time__c != null)  projD.derigEndDate = proj.Derig_Finish_Date_Time__c.format('dd/MM/yyyy');
				if(proj.Event_Date_Time__c != null)  projD.eventStartDate = proj.Event_Date_Time__c.format('dd/MM/yyyy');
				if(proj.Event_Finish_Date_Time__c != null)  projD.eventEndDate = proj.Event_Finish_Date_Time__c.format('dd/MM/yyyy');
				if(proj.Install_Date_Time__c != null)   projD.installStartDate = proj.Install_Date_Time__c.format('dd/MM/yyyy');
				if(proj.Install_Finish_Date_Time__c != null)   projD.installEndDate = proj.Install_Finish_Date_Time__c.format('dd/MM/yyyy');
				if(proj.Travel_Start_Date__c != null)   projD.travelStartDate = proj.Travel_Start_Date__c.format('dd/MM/yyyy');
				if(proj.Travel_End_Date__c != null)   projD.travelEndDate = proj.Travel_End_Date__c.format('dd/MM/yyyy');
				if(proj.Client_Visit_Date__c != null)   projD.clientVisitDate = proj.Client_Visit_Date__c.format();
				if(proj.Additional_Info__c != null)   projD.additionalInfo = proj.Additional_Info__c;
				if(proj.Install_Month__c != null)   projD.projectMonth = proj.Install_Month__c;
				if(proj.Install_Year__c != null)   projD.projectYear = proj.Install_Year__c;
				if(proj.Install_start_Date_Time_2__c != null)	projD.installStartDate2 = proj.Install_start_Date_Time_2__c.format('dd/MM/yyyy');
				if(proj.Install_Finish_Date_Time_2__c != null)	projD.installFinishDate2 = proj.Install_Finish_Date_Time_2__c.format('dd/MM/yyyy');
				if(proj.Event__c != null)	projD.eventStartDate2 = proj.Event__c.format('dd/MM/yyyy');
				if(proj.Event_Finish_Date_Time_2__c != null)	projD.eventFinishDate2 = proj.Event_Finish_Date_Time_2__c.format('dd/MM/yyyy');
				if(proj.De_Rig_Start_Date_Time_2__c != null)	projD.derigStartDate2 = proj.De_Rig_Start_Date_Time_2__c.format('dd/MM/yyyy');
				if(proj.Derig_Finish_Date_Time_2__c != null)	projD.derigFinishDate2 = proj.Derig_Finish_Date_Time_2__c.format('dd/MM/yyyy');
				if(proj.Total_Labour_Hours_Estimate__c != null)   projD.totalLabourHoursEstimate = String.valueOf(proj.Total_Labour_Hours_Estimate__c);
				if(proj.Total_Labour_Hours_Estimate__c != null)   projD.totalLabourHoursEstimate = String.valueOf(proj.Total_Labour_Hours_Estimate__c);
				projD.totalQuantityforSite = (proj.Opportunity__r.Total_Quantity_for_Site__c != null) ? Integer.valueOf(proj.Opportunity__r.Total_Quantity_for_Site__c) : 0;
				projD.totalQuantityforWorkshop = (proj.Opportunity__r.Total_Quantity_for_Workshop__c != null) ? Integer.valueOf(proj.Opportunity__r.Total_Quantity_for_Workshop__c) : 0;
				
				Set<String> crewChiefMembers = new Set<String>();

				if(proj.Crew_Chief_1__c != null) {
					crewChiefMembers.add(proj.Crew_Chief_1__r.Name);
				}
				
				if(proj.Crew_Chief_2__c != null) {
					crewChiefMembers.add(proj.Crew_Chief_2__r.Name);
				}
				
				if(proj.Crew_Chief_3__c != null) {
					crewChiefMembers.add(proj.Crew_Chief_3__r.Name);
				}
				
				if(!crewChiefMembers.isEmpty() && crewChiefMembers.size() > 0) {
					projD.crewChiefMembers = crewChiefMembers;
				}
				
				projectDetails.add(projD);
			}
		}
																 
		return projectDetails;
	}
	
	//gets only  bank holidays
	@RemoteAction
	public static List<CalenderInformation> getBankHolidays() {
		List<Calendar_Headlines__c> calenderHeadlineList = [SELECT Label__c, Headline_Type__c, Start_Date__c, End_Date__c
															FROM Calendar_Headlines__c
															WHERE Label__c != NULL
															AND Headline_Type__c = 'Holiday'];
		List<CalenderInformation> calenderInfoList = new List<CalenderInformation>();

		if(calenderHeadlineList != null && calenderHeadlineList.size() > 0) {
			for(Calendar_Headlines__c chl : calenderHeadlineList) {
				CalenderInformation calenderSObj 	= new CalenderInformation();
				calenderSObj.holidayName 			= chl.Label__c;
				calenderSObj.startDate 				= chl.Start_Date__c.format();
				calenderSObj.endDate 				= chl.End_Date__c.format();
				calenderInfoList.add(calenderSObj);
			}
		}
		return calenderInfoList;
	}
	
	
	//gets the colour code to display on the screen. This is retrieved from custom settings.
	@RemoteAction
	public static ColourCodes getColorCodes() {
		List<CustomColorCodes__c> colorList = CustomColorCodes__c.getAll().values();
		ColourCodes ccSobj = new ColourCodes();
	
 		if(colorList != null && colorList.size() > 0) {
			ccSobj.workshop = (colorList[0].Workshop__c != null) ? colorList[0].Workshop__c : Label.workshopDefaultColour;
			ccSobj.derig = (colorList[0].Derig__c != null) ? colorList[0].Derig__c : Label.derigDefaultColour;
			ccSobj.install = (colorList[0].Install__c != null) ? colorList[0].Install__c : Label.installDefaultColour;
			ccSobj.install2 = (colorList[0].Install__c != null) ? colorList[0].Install__c : Label.installDefaultColour;
			ccSobj.event = (colorList[0].Event__c != null) ? colorList[0].Event__c : Label.eventDefaultColour;
			ccSobj.travel = (colorList[0].Travel__c != null) ? colorList[0].Travel__c : Label.travelDefaultColour;
			ccSobj.events_Event = (colorList[0].eventEvent__c != null) ? colorList[0].eventEvent__c : Label.eventEventsDefaultColour;
			ccSobj.events_Holiday = (colorList[0].eventHoliday__c != null) ? colorList[0].eventHoliday__c : Label.eventHolidayDefaultColour;
 		} else {
			ccSobj.workshop 		= Label.workshopDefaultColour;
			ccSobj.derig 			= Label.derigDefaultColour;
			ccSobj.install 			= Label.installDefaultColour;
			ccSobj.event 			= Label.eventDefaultColour;
			ccSobj.travel 			= Label.travelDefaultColour;
			ccSobj.events_Event 	= Label.eventEventsDefaultColour;
			ccSobj.events_Holiday 	= Label.eventHolidayDefaultColour;
 		}
		return ccSobj;		
	}
	
	//gets the project time slots based on projectIds along with allocated resource.
	@RemoteAction
	public static List<ProjectTimeSlots> getAllProjectTimeSlots(List<String> projectIds) {
		
		List<ProjectTimeSlots> projTimeSlotsList 			= new List<ProjectTimeSlots>();
		List<Project_Time_Slots__c> projTimeSlotsSObjList  	= new List<Project_Time_Slots__c>();
		
		if(projectIds != null && projectIds.size() > 0) {
			projTimeSlotsSObjList = [SELECT Title__c, Type__c, Start_Time__c, Project__c, Project__r.Event_Name__c,
											Name, Id, Finish_Time__c,
											(SELECT Staff_List__c, Assigned_Role__c FROM Labour_Truck_Allocation__r)
									FROM Project_Time_Slots__c
									WHERE Project__c IN :projectIds];
		}
		
		if(projTimeSlotsSObjList != null && projTimeSlotsSObjList.size() > 0) {

			for(Project_Time_Slots__c pts : projTimeSlotsSObjList) {

				System.debug(pts.Id);
				System.debug(pts);
				ProjectTimeSlots sobj 	= new ProjectTimeSlots();
				sobj.projectId 			= pts.Project__c;
				sobj.projectTSId 		= pts.Id;

				if(pts.Project__c != null) sobj.projectName = pts.Project__r.Event_Name__c;
				if(pts.Start_Time__c != null) sobj.projTSDate = pts.Start_Time__c.date().format();
				if(pts.Start_Time__c != null) sobj.projTSStartTime = String.valueOf(pts.Start_Time__c.hour())+':'+String.valueOf(pts.Start_Time__c.minute());
				if(pts.Finish_Time__c != null) sobj.projTSFinishTime = String.valueOf(pts.Finish_Time__c.hour())+':'+String.valueOf(pts.Finish_Time__c.minute());
				if(pts.Type__c != null) sobj.projTSType = pts.Type__c;
				if(pts.Title__c != null) sobj.projTSTitle = pts.Title__c;
                
				List<Labour_Truck_Allocation__c> labourList = pts.Labour_Truck_Allocation__r;    //staff allocation object
				if(labourList != null && labourList.size() > 0) {

					List<LabourAllocation> labourAllocList = new List<LabourAllocation>();

					for(Labour_Truck_Allocation__c labourRecord : labourList) {
						LabourAllocation childObj = new LabourAllocation();
						if(labourRecord.Staff_List__c != null) childObj.staffId = labourRecord.Staff_List__c;
						if(labourRecord.Assigned_Role__c != null) childObj.assignedRole = labourRecord.Assigned_Role__c;
						labourAllocList.add(childObj);
					}
					
					if(!labourAllocList.isEmpty() && labourAllocList.size() > 0) {
						sobj.labourAllocationList = labourAllocList;
					}					
				}
				
				projTimeSlotsList.add(sobj);				
			}
		}
		
		return projTimeSlotsList;
	}

	//TIAGO MENDES && LUIS FERREIRA
	//Clone record
	public void cloneTimeSlot(){

		//System.debug(ApexPages.currentPage().getParameters().containsKey('draggedList'));

		String drag = ApexPages.currentPage().getParameters().get('draggedList');
		String drop = ApexPages.currentPage().getParameters().get('timeslot');	

		Map<String, Object> dropMap = (Map<String, Object>)JSON.deserializeUntyped(drop);
		
		Map<String, Object> dragMap = ( Map<String, Object>)JSON.deserializeUntyped(drag);
		
		List<Map<String, Object>> slot =  new List<Map<String, Object>>();
		for (Object instance : (List<Object>)dragMap.get('timeslots'))
    		slot.add((Map<String, Object>)instance);
		
		
		Project_Time_Slots__c projToClone = [SELECT Id, Project__c, Allocated_hours__c, CodeExternalID__c,
											Event_Name__c, Finish_Time__c, Number_Of_Staff__c, Name, Slot_Time__c, Start_Time__c,
											Title__c, Type__c
											FROM Project_Time_Slots__c
											WHERE Id = : String.valueOf(slot[0].get('projectTSId'))];

		//add Time slots
		List<Project_Time_Slots__c> timeslotsList = new List<Project_Time_Slots__c>();
		for (Object instance : (List<Object>)dragMap.get('timeslots')) {
			Map<String, Object> labourMap = (Map<String, Object>)instance;

			//clone
			Project_Time_Slots__c projToClone2 = projToClone.clone(false,true,true,false);
			projToClone2.CodeExternalID__c  = '';

			//get the start and finish time
			/*START DATES*/
			list<String> dates = String.valueOf(dropMap.get('date')).split('/');
			list<String> hoursStart = String.valueOf(labourMap.get('projTSStartTime')).split(':');
			list<String> hoursFinish = String.valueOf(labourMap.get('projTSFinishTime')).split(':');

			if(Integer.valueOf(hoursStart[0]) > Integer.valueOf(hoursFinish[0])){

				DateTime dtStart = DateTime.newInstance(Integer.valueOf(dates[2]), Integer.valueOf(dates[1]), Integer.valueOf(dates[0]), Integer.valueOf(hoursStart[0]), Integer.valueOf('00'), Integer.valueOf('00'));
			
				DateTime dtFinish = DateTime.newInstance(Integer.valueOf(dates[2]), Integer.valueOf(dates[1]), Integer.valueOf(dates[0]), Integer.valueOf(hoursFinish[0]), Integer.valueOf('00'), Integer.valueOf('00'));
				/*END DATES*/
				projToClone2.Start_Time__c  = dtStart; 
				projToClone2.Finish_Time__c  = dtFinish.addDays(1);

				projToClone2.Title__c  = String.valueOf(labourMap.get('projTSTitle'));
				timeslotsList.add(projToClone2);

			} else{

				DateTime dtStart = DateTime.newInstance(Integer.valueOf(dates[2]), Integer.valueOf(dates[1]), Integer.valueOf(dates[0]), Integer.valueOf(hoursStart[0]), Integer.valueOf('00'), Integer.valueOf('00'));
			
				DateTime dtFinish = DateTime.newInstance(Integer.valueOf(dates[2]), Integer.valueOf(dates[1]), Integer.valueOf(dates[0]), Integer.valueOf(hoursFinish[0]), Integer.valueOf('00'), Integer.valueOf('00'));
				/*END DATES*/
				projToClone2.Start_Time__c  = dtStart; 
				projToClone2.Finish_Time__c  = dtFinish;
				projToClone2.Title__c  = String.valueOf(labourMap.get('projTSTitle'));
				timeslotsList.add(projToClone2);
			}
		}

		//Savepoint sp = Database.setSavepoint();
		try {
			insert timeslotsList;
		} catch(Exception e) {
			//Database.rollback(sp);
			System.debug('Error:: '+ e.getMessage());
		}

		System.debug('timeslotsList');
		System.debug(timeslotsList);
		List<Id> idss = new List<Id>();
		for(Project_Time_Slots__c d: timeslotsList) {
			idss.add(d.Id);
		}
		List<Labour_Truck_Allocation__c> labourList = new List<Labour_Truck_Allocation__c>();
		Integer count = 0;
		for(Project_Time_Slots__c slots: timeslotsList) {

			for (Object instance : (List<Object>)slot[count].get('labourAllocationList')) {
				Map<String, Object> labourMap = (Map<String, Object>)instance;
				Labour_Truck_Allocation__c labour = new Labour_Truck_Allocation__c();

				labour.Project_Time_Slots__c = slots.Id;
				labour.Staff_List__c = String.valueOf(labourMap.get('staffId'));
				labour.Assigned_Role__c = String.valueOf(labourMap.get('assignedRole'));
				labourList.add(labour);
			}

			count++;
		}
		
		try {
			insert labourList;
		} catch(Exception e) {
			//Database.rollback(sp);
			System.debug('Error:: '+ e.getMessage());
		}

		System.debug('timeslotsList');
		System.debug(timeslotsList);
	}
	
	
	//Delete project time slots if the resource is allocated to different time slots
	@RemoteAction
	public static String deleteProjectTimeSlots(List<String> projectTSIds) {

		if(projectTSIds !=null && projectTSIds.size() > 0) {
            Savepoint sp = Database.setSavepoint();
            
			try {
				List<Project_Time_Slots__c> deletePTSList = [SELECT Id FROM Project_Time_Slots__c WHERE Id IN :projectTSIds];
				if(deletePTSList != null && deletePTSList.size() > 0) {
					delete deletePTSList;
				}
			} catch(Exception e) {
                Database.rollback(sp);
				System.debug('error while deleting PTS: '+e);
				return fail;
			}		
		}
		return success;
	}
	
	//update/Creating project time slots and staff allocation.
	@RemoteAction
	public static String updateCreateProjectTimeSlots(List<UpdateProjectTimeSlots> dirtyProjectTimeSlots) {

		System.debug('trying to create some timeslots');
		System.debug('objects sent to this method are ' + dirtyProjectTimeSlots);

		if(dirtyProjectTimeSlots != null && dirtyProjectTimeSlots.size() > 0) {

			system.debug('found some entries to create');

			List<String> projectTSIds 							= new List<String>();
			List<Labour_Truck_Allocation__c> childListToInsert 	= new List<Labour_Truck_Allocation__c>();
			List<Project_Time_Slots__c> parentListToInsert 		= new List<Project_Time_Slots__c>();
			
			for(UpdateProjectTimeSlots timeSlotsObj : dirtyProjectTimeSlots) {

				system.debug('iterating through a timeslot');

				//if projTSID == 'noid' then is considered as new project time slot else its a existing time slots
				if(timeSlotsObj.projTSId.toLowerCase() == 'noid') {

					system.debug('timeslot has no id');


					String uniqueId = String.valueOf(System.now().getTime());
					
					Project_Time_Slots__c parentReference = new Project_Time_Slots__c(CodeExternalID__c = uniqueId);
                    
					if( timeSlotsObj.startTime >  timeSlotsObj.finishTime){

						Project_Time_Slots__c newParentPTS = new Project_Time_Slots__c(
							Project__c 			= timeSlotsObj.projectId,
							Start_Time__c 		= Datetime.parse(timeSlotsObj.projTSDate +' '+timeSlotsObj.startTime),
							Finish_Time__c 		= Datetime.parse(timeSlotsObj.projTSDate +' '+timeSlotsObj.finishTime).addDays(1),
							Type__c 			= timeSlotsObj.projTSType,
							Title__c 			= timeSlotsObj.projTSTitle,
							CodeExternalID__c 	= uniqueId
						);

						parentListToInsert.add(newParentPTS);

					} else {
						Project_Time_Slots__c newParentPTS = new Project_Time_Slots__c(
							Project__c 			= timeSlotsObj.projectId,
							Start_Time__c 		= Datetime.parse(timeSlotsObj.projTSDate +' '+timeSlotsObj.startTime),
							Finish_Time__c 		= Datetime.parse(timeSlotsObj.projTSDate +' '+timeSlotsObj.finishTime),
							Type__c 			= timeSlotsObj.projTSType,
							Title__c 			= timeSlotsObj.projTSTitle,
							CodeExternalID__c 	= uniqueId
						);

						parentListToInsert.add(newParentPTS);
					}
				
					if(timeSlotsObj.crewMembers != null && timeSlotsObj.crewMembers.size() > 0) {
						List<CreateLabourAllocation> childList = timeSlotsObj.crewMembers;
						for(CreateLabourAllocation childLA : childList)
						{
							Labour_Truck_Allocation__c childSobj = new Labour_Truck_Allocation__c(
								Project_Time_Slots__r 	= parentReference,
								Staff_List__c 			= childLA.staffId,
								Assigned_Role__c 		= childLA.assignedRole
							);
							
							childListToInsert.add(childSobj);
						}
					}					
				}
				else {
					projectTSIds.add(timeSlotsObj.projTSId);					
				}
			}
			
			if(!projectTSIds.isEmpty()) {
				List<Labour_Truck_Allocation__c> deleteChildList = [SELECT Id, Project_Time_Slots__c
																	FROM Labour_Truck_Allocation__c
																	WHERE Project_Time_Slots__c IN :projectTSIds];
				
				if(deleteChildList != null && deleteChildList.size() > 0) delete deleteChildList;			
			}
			
			for(UpdateProjectTimeSlots existingTimeSlotsObj : dirtyProjectTimeSlots) {
				if(existingTimeSlotsObj.projTSId != '' && existingTimeSlotsObj.projTSId != null
						&& existingTimeSlotsObj.projTSId.toLowerCase() != 'noid') {
					if(existingTimeSlotsObj.crewMembers != null && existingTimeSlotsObj.crewMembers.size() > 0) {

						List<CreateLabourAllocation> childList = existingTimeSlotsObj.crewMembers;

						for(CreateLabourAllocation childLA : childList) {
							Labour_Truck_Allocation__c childSobj = new Labour_Truck_Allocation__c(
								Project_Time_Slots__c 	= existingTimeSlotsObj.projTSId,
								Staff_List__c 			= childLA.staffId,
								Assigned_Role__c 		= childLA.assignedRole
							);
							
							childListToInsert.add(childSobj);
						}
					}
				}			
			}
				
			Savepoint sp = Database.setSavepoint();
            
			try {
				if(!parentListToInsert.isEmpty())  insert parentListToInsert;
				if(!childListToInsert.isEmpty())  insert childListToInsert;					
			} catch(Exception e) {
                Database.rollback(sp);
				System.debug('error while creating project time slot: '+e);
				return fail;
			}
		}
		return success;
	}

	
	//dynamic retrieve of picklist values of assigned role
	@RemoteAction
	public static List<String> getRolePickListValues() {
		List<String> picklistValues = new List<String>();
		
		Schema.DescribeFieldResult dfr 				= Schema.SObjectType.Labour_Truck_Allocation__c.fields.Assigned_Role__c;
		List<Schema.PicklistEntry> picklistEntries 	= dfr.getPicklistValues();
		for(Schema.PicklistEntry val : picklistEntries) {
			picklistValues.add(val.getValue());
		}
		
		return picklistValues;
	}
    
	public with sharing class UpdateProjectTimeSlots
	{
		public String projectId {get; set;}
		public String projTSType {get; set;}
		public String projTSId {get; set;}
		public String projTSDate {get; set;}
		public String startTime {get; set;}
		public String finishTime {get; set;}
        public String projTSTitle {get; set;}
		public List<CreateLabourAllocation> crewMembers {get; set;}
	}
	
	public with sharing class CreateLabourAllocation
	{
		public String staffId {get; set;}
		public String assignedRole {get; set;}
	}		
	
	public with sharing class ProjectDetails {
		public String projectId {get; set;}
		public String projectName {get; set;}
		public String projectNumber {get; set;}
		public String projectAccountName {get; set;}
		public String PMName {get; set;}
		public String projectMonth {get; set;}  
		public String projectYear {get; set;}   
		public String installStartDate {get; set;}
		public String installEndDate {get; set;} 
		public String derigStartDate {get; set;}
		public String derigEndDate {get; set;}  
		public String eventStartDate {get; set;}
		public String eventEndDate {get; set;} 
		public String workshopStartDate {get; set;}
		public String workshopEndDate {get; set;} 
		public String totalLabourHoursEstimate {get; set;}
		public String travelStartDate {get; set;}
		public String travelEndDate {get; set;}	
		public String clientVisitDate {get; set;}	
		public String additionalInfo {get; set;}
		public Set<String> crewChiefMembers {get; set;}
		public Integer totalQuantityforSite {get; set;}
		public Integer totalQuantityforWorkshop {get; set;}
		public String installStartDate2 {get; set;}
		public String installFinishDate2 {get; set;}
		public String eventStartDate2 {get; set;}
		public String eventFinishDate2 {get; set;}
		public String derigStartDate2 {get; set;}
		public String derigFinishDate2 {get; set;}
	}
	
	public with sharing class StaffInformation{
		public String staffId {get; set;}
		public String staffName {get; set;}
		public String projectRole {get; set;}
		public String allocationType {get; set;}
		public Boolean forkliftLicense {get; set;}
		public Boolean cncOperator {get; set;}
		public Boolean iPAF {get; set;}
		public Boolean driversLicense {get; set;}
		public String secondaryRole {get; set;}
		public String groupName {get; set;}
		public List<AvailabilityInformation> availabilityInfoList {get; set;}
	}
	
	public with sharing class AvailabilityInformation {
		public String holidayConfirmedAvailableString {get; set;}
		public String dateFrom {get; set;}
		public String dateTo {get; set;}
	}
	
	public with sharing class CalenderInformation {
		public String holidayName {get; set;}
		public String startDate {get; set;}
		public String endDate {get; set;}
	}
	
	public with sharing class ColourCodes {
		public String workshop {get; set;}
		public String derig {get; set;}
		public String install {get; set;}
		public String install2 {get; set;}
		public String event {get; set;}
		public String travel {get; set;} 
		public String events_Event {get; set;} 
		public String events_Holiday {get; set;} 
		
	}
	
	public with sharing class ProjectTimeSlots {
		public String projectId {get; set;}
		public String projectName {get; set;}
		public String projectTSId {get; set;}
		public String projTSDate {get; set;}
		public String projTSStartTime {get; set;}
		public String projTSFinishTime {get; set;}
		public String projTSType {get; set;}
        public String projTSTitle {get; set;}
		public List<LabourAllocation> labourAllocationList {get; set;}
	}
	
	public with sharing class LabourAllocation {
		public String staffId {get; set;}
		public String assignedRole {get; set;}
	}
    
}