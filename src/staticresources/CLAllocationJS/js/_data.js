// the fake data here will be overwritten by SF data once plugged in
// and VF remoting methods called from the interfacer

var db_staff = [
  {
    allocationType: "Freelance",
    cncOperator: false,
    forkliftLicense: false,
    projectRole: "Crew Chief",
    staffId: "SID001",
    staffName: "Rebecca Joseph",
    availabilityInfoList: [
      {
        dateFrom: "01/07/2016",
        dateTo: "07/07/2016",
      }
    ]
  },
  {
    allocationType: "Employee",
    cncOperator: true,
    forkliftLicense: false,
    projectRole: "Carpenter",
    staffId: "SID002",
    staffName: "Dave Smith",
    availabilityInfoList: [
      {
        dateFrom: "10/07/2016",
        dateTo: "12/07/2016",
      },
      {
        dateFrom: "02/07/2016",
        dateTo: "04/07/2016",
      }
    ]
  },
  {
    allocationType: "Truck",
    cncOperator: false,
    forkliftLicense: false,
    projectRole: "Transport",
    staffId: "SID003",
    staffName: "Truck #1",
    availabilityInfoList: [
      {
        dateFrom: "30/06/2016",
        dateTo: "03/07/2016",
      }
    ]
  },
  {
    allocationType: "Truck",
    cncOperator: false,
    forkliftLicense: false,
    projectRole: "Transport",
    staffId: "SID004",
    staffName: "Truck #2",
    availabilityInfoList: [
      {
        dateFrom: "30/06/2016",
        dateTo: "03/07/2016",
      }
    ]
  },
  {
    allocationType: "Employee",
    cncOperator: true,
    forkliftLicense: true,
    projectRole: "Painter",
    staffId: "SID005",
    staffName: "Alan Newell"
  }
];

var db_roles = ["Labour", "Carpenter", "Crew Chief", "Painter", "Scenic", "Driver", "Apprentice", "Storesman", "Sub contractor", "Crew", "Transport"];

var db_secroles = ["Labour", "Carpenter", "Crew Chief", "Painter", "Scenic", "Driver", "Apprentice", "Storesman", "Sub contractor", "Crew", "Scenic Painter"];

var db_timeslots = [
  {
    projectId: 'SFID001',
    projectTSId: "TIMESLOTID001",
    projectName: 'Glastonbury',
    projTSType: 'Workshop',
    projTSDate: '07/07/2016',
    projTSStartTime: "11:00",
    projTSFinishTime: "16:00",
    projTSTitle: 'Test',
    labourAllocationList: [
      {
        staffId: "SID002",
        assignedRole: "Carpenter",
      },
      {
        staffId: "SID003",
        assignedRole: "Transport",
      }
    ]
  },
  {
    projectId: 'SFID001',
    projectTSId: "TIMESLOTID001",
    projectName: 'Glastonbury',
    projTSType: 'Workshop',
    projTSDate: '07/07/2016',
    projTSStartTime: "18:00",
    projTSFinishTime: "23:00",
    projTSTitle: 'Test',
    labourAllocationList: [
      {
        staffId: "SID002",
        assignedRole: "Carpenter",
      }
    ]
  },
  {
    projectId: 'SFID001',
    projectTSId: "TIMESLOTID001",
    projectName: 'Glastonbury',
    projTSType: 'Install',
    projTSDate: '09/07/2016',
    projTSStartTime: "09:00",
    projTSFinishTime: "10:00",
    projTSTitle: 'Test',
    labourAllocationList: [
      {
        staffId: "SID002",
        assignedRole: "Carpenter",
      }
    ]
  },
  {
    projectId: 'SFID001',
    projectTSId: "TIMESLOTID001",
    projectName: 'Glastonbury',
    projTSType: 'Travel',
    projTSDate: '09/07/2016',
    projTSStartTime: "12:00",
    projTSFinishTime: "15:00",
    projTSTitle: 'Test',
    labourAllocationList: [
      {
        staffId: "SID002",
        assignedRole: "Painter",
      },
      {
        staffId: "SID003",
        assignedRole: "Transport",
      },
      {
        staffId: "SID004",
        assignedRole: "Transport",
      }
    ]
  }
]

var db_projects = [
  {
    projectId: 'SFID001',
    projectAccountName: 'Glastonbury Festival',
    projectName: 'Glastonbury',
    projectNumber: '14002',
    PMName: "Harriet O'Connell",
    crewChiefMembers: ["Elliott", "Rupa Raghu", "Charlie"],
    projectMonth: 'July',
    projectYear: '2016',
    workshopStartDate: '02/07/2016',
    workshopEndDate: '08/07/2016',
    travelStartDate: '09/07/2016',
    travelEndDate: '10/07/2016',
    installStartDate: '09/07/2016',
    installStartDate2: '09/07/2016',
    installEndDate: '11/07/2016',
    eventStartDate: '12/07/2016',
    eventEndDate: '17/07/2016',
    derigStartDate: '17/07/2016',
    derigEndDate: '18/07/2016',
    clientVisitDate: "04/07/2016",
    totalLabourHoursEstimate: '30'
  },
  {
    projectId: 'SFID002',
    projectAccountName: 'Lock N Load',
    projectName: 'SW4',
    projectNumber: '13041',
    PMName: "Elliott Thurman-Newell",
    crewChiefMembers: ["Rebecca D", "Charlie Lang"],
    projectMonth: 'July',
    projectYear: '2016',
    workshopStartDate: '05/07/2016',
    workshopEndDate: '09/07/2016',
    installStartDate: '10/07/2016',
    installStartDate2: '10/07/2016',
    installEndDate: '10/07/2016',
    eventStartDate: '11/07/2016',
    eventEndDate: '14/07/2016',
    derigStartDate: '15/07/2016',
    derigEndDate: '15/07/2016',
    clientVisitDate: "08/07/2016",
    totalLabourHoursEstimate: '20'
  },
]

var db_holidays = [
  {
    startDate: "10/07/2016",
    endDate: "10/07/2016",
    holidayName: "Bank Holiday",
  }
]

var db_colors = {
  workshop: '#e9696e',
  travel: '#fbb439',
  install: '#00c6b7',
  event: '#33bce7',
  derig: '#699be1',
  events_Holiday: '#A7B8D1'
};