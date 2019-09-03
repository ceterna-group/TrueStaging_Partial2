var draggedSlot;
// create a vue controller with a variable to easily reference methods/vars
var vm = new Vue({
  // element id for app to sit it
  el: '#vm',
  // app data 
  data: {
    loaded: false,
    projects: [],
    types: ['workshop', 'travel', 'install', 'event', 'derig', 'drawing'],
    days: [],
    colors: {},
    events: [],
    staff: [],
    timeslots: [],
    roles: [],
    secroles: [],
    unquoted: [],
    search_query: '',
    crewquery: '',
    dirty: false,
    selected_slot: {},
    times: ['00:00', '01:00', '02:00', '03:00', '04:00', '05:00', '06:00', '07:00', '08:00', '09:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00', '16:00', '17:00', '18:00', '19:00', '20:00', '21:00', '22:00', '23:00'/*, '24:00'*/],
    start_time: '08:00',
    end_time: '18:00',
    title:'',
    selected_timeslot: '',
    slot_edit: false,
    save_text: 'Save',
    saveScrollLeft: '',
    saveScrollTop: '',
    error: false,
    error_code: ''
  },
  // functions run when specific data is changed
  watch: {
    'search_query': function () {
      vm.keep_scroll();
    }
  },
  // app functions
  methods: {
    // replace bits
    replacer: function(val) {
      return val.replace(/&amp;/g, '&').replace(/&quot;/g, '"').replace(/&#39;/g, "'");
    },
    // processes the project data given
    process_data: function () {
      // empty array to populate with any dates
      var dArr = [];
      // empty array to populate with possible months
      var mArr = [];
      // set colors
      vm.colors = db_colors;
      vm.roles = db_roles;
      vm.secroles = db_secroles;
      // add the fields 'available' and 'reason' to the staff data given
      // we use these to show if staff are not available, and why not
      // console.log('staff');
      // console.log(db_staff);
      _each(db_staff, function (t) {
        var stObj = {
          allocationType: t.allocationType,
          cncOperator: t.cncOperator,
          forkliftLicense: t.forkliftLicense,
          projectRole: t.projectRole,
          secondaryRole : t.secondaryRole,
          staffId: t.staffId,
          staffName: t.staffName,
          availabilityInfoList: t.availabilityInfoList,
          available: true,
          groupName: t.groupName,
          driversLicense: t.driversLicense,
          iPAF: t.iPAF,
          reason: 'Available.'
        }
        vm.staff.push(stObj);
      })
      // add some more fields to the timeslots to make our life easier
      // console.log('slots');
      _each(db_timeslots, function (q) {
        // for each labour allocation if there is one
        q['selected'] = false;
        q['toCreate'] = false;
        q['toUpdate'] = false;
        q['toDelete'] = false;
        if (q.labourAllocationList) {
          _each(q.labourAllocationList, function (p) {
            // find the matching staff person
            var matching_person = _find(db_staff, {
              staffId: p.staffId
            })
            if (matching_person[0] && matching_person[0] != undefined) {
              p['name'] = matching_person[0].staffName;
              p['role'] = matching_person[0].projectRole;
              p['secrole'] = matching_person[0].secondaryRole;
              p['cnc'] = matching_person[0].cncOperator;
              p['forklift'] = matching_person[0].forkliftLicense;
              p['type'] = matching_person[0].allocationType;
            } else {
              p['name'] = 'Inactive User';
              p['role'] = 'VOID';
              p['secrole'] = 'VOID';
              p['cnc'] = 'VOID';
              p['forklift'] = 'VOID';
              p['type'] = 'VOID';
            }
          })
        }
      })

      vm.timeslots = db_timeslots;
      // set save text in case we're refreshing from saving
      vm.save_text = 'Save';
      // console.log('projs', db_projects);
      _each(db_projects, function (a) {
        // empty object to populate with project fields
        var nObj = {};
        // fields to use/set directly
        nObj['salesforce_id'] = a.projectId ? a.projectId : 'VOID';
        nObj['client'] = a.projectAccountName ? a.projectAccountName : 'VOID';
        nObj['name'] = a.projectName ? a.projectName.replace(/&amp;/g, '&') : 'VOID';
        nObj['number'] = a.projectNumber ? a.projectNumber : 'VOID';
        nObj['additional_info'] = a.additionalInfo ? a.additionalInfo : '';
        // calulate this in a seperate function so we can recall
        nObj['total_hours'] = 0;
        nObj['client_date'] = a.clientVisitDate ? a.clientVisitDate : 'No Date Given';
        nObj['onsite_estimate'] = a.totalQuantityforSite ? a.totalQuantityforSite : 0;
        nObj['onsite_actual'] = 0;
        nObj['workshop_estimate'] = a.totalQuantityforWorkshop ? a.totalQuantityforWorkshop : 0;
        nObj['workshop_actual'] = 0;
        // check if the derig end date is past today
        var past = a.derigEndDate ? _date.checkPast(a.derigEndDate, _date.getToday()) : false;
        nObj['past'] = past;
        // if past, lock the project too
        nObj['seperator'] = false;
        nObj['selected_row'] = 'not_selected';
        // used to make sure seperators are before projects
        if (a.installStartDate) {
          var overide_date = a.installStartDate;
          var overide_month = _date.monthString[Number(overide_date.split('/')[1]) - 1];
          var overide_year = overide_date.split('/')[2];
          nObj['month'] = overide_month;
          nObj['year'] = overide_year;
          // used to make sure seperators are before projects
          var numb = vh.month_number.indexOf(overide_month);
          var newnumb = numb < 10 ? '0' + numb : numb;
          nObj['order_month'] = overide_year + "" + newnumb + "1";
          mArr.push(overide_month + ' ' + overide_year);
        } else {
          // otherwise use the given month and year fields, if they have one
          nObj['month'] = a.projectMonth ? a.projectMonth : 'VOID';
          nObj['year'] = a.projectYear ? a.projectYear : 'VOID';
          // used to make sure seperators are before projects
          var numb = a.projectMonth ? vh.month_number.indexOf(a.projectMonth) : 0;
          var newnumb = numb < 10 ? '0' + numb : numb;
          nObj['order_month'] = a.projectMonth && a.projectYear ? a.projectYear + "" + newnumb + "1" : 9999;
          if (a.projectMonth && a.projectYear) {
            mArr.push(a.projectMonth + ' ' + a.projectYear);
          }
        }
        nObj['order_install'] = a.installStartDate ? vh.numerate(a.installStartDate) : vh.numerate('99/99/9999');
        // abbreviate pm and cc to initials
        nObj['project_manager'] = a.PMName ? vh.abbreviate(a.PMName) : 'VOID';
        nObj['crew_chiefs'] = a.crewChiefMembers ? vh.abbreviate(a.crewChiefMembers) : 'VOID';
        // if there are no dates at all, set a boolean for it for later
        var counter = 0;
        // console.log('types 1');
        _each(vm.types, function (c) {
          counter += a[c + 'StartDate'] && a[c + 'EndDate'] ? 1 : 0
        });
        nObj['no_dates'] = counter == 0 ? 'nodates' : 'dates';
        // set a container object for all dates (allows v-for loop for types)
        var dObj = {}
        // set the date object fields
        // console.log('types 2');
        _each(vm.types, function (b) {
          // create empty object to populate for each type
          var tObj = {};
          // these two will be populated later
          tObj['type'] = b;
          tObj['edited'] = false;
          tObj['color'] = vm.colors[b];
          // get these later!
          tObj['left_position'] = '';
          // set start and end dates for each type object
          tObj['start_date'] = a[b + 'StartDate'] ? a[b + 'StartDate'] : '99/99/9999';
          tObj['end_date'] = a[b + 'EndDate'] ? a[b + 'EndDate'] : '00/00/0000';
          // set the width of the block based on the distance of the start and end
          tObj['slots'] = [];
          // work out the number of days that the type ranges

          // var daysLength = a[b + 'StartDate'] ? _date.getDatesBetween(a[b + 'StartDate'], a[b + 'EndDate']).length : 0 + 'px';

          var daysLength = a[b + 'StartDate'] ? _date.getDatesBetween(a[b + 'StartDate'], a[b + 'EndDate']).length : 0;

          // var daysLength = a[b + 'StartDate'] ? 50 : 0;

          // var daysLength = 5;
          // for each of these days we create a slot

          // var earliestDate = vh.daterize(Math.min.apply(Math, _solo(dArr)));
          // var latestDate = vh.daterize(Math.max.apply(Math, _solo(dArr)));


          // console.log('timeslots is ');
          // console.log(vm.timeslots);

          for (var x = 0; x < daysLength; x++) {
            // for (var x = 0; x < 100; x++) {
            // get the start date, type, id, title
            var startDate     = a[b + 'StartDate'];
            var slot_type     = b.charAt(0).toUpperCase() + b.slice(1);
            var slot_id       = a.projectId ? a.projectId : 'VOID';
            var slot_project  = a.projectName ? a.projectName : 'VOID';
            // calculate the day of the slot, based on start date + number of the loop


            // console.log('timeslot');
            // console.log(vm.timeslots);


            var next_day = vh.next_day(startDate, x);
            // find where there is a timeslot matching the id, type and date combination
            var time_slots = _find(vm.timeslots, {
              projectId: slot_id,
              projTSType: slot_type,
              projTSDate: next_day
            });



            // set some variables to defaults
            var workers       = [];
            var stringWorkers = '';
            var truck         = false;
            var total_hours   = 0;
            var truck_no      = 0;
            var s_title       = '';

            // if there are timeslots
            if (time_slots !== 'NO MATCH') {
              // for each timeslot
              // console.log('slots 2');
              _each(time_slots, function (y) {

                // console.log('slot for');
                // console.log(y.projectName);

                if (y.toDelete === false) {
                  // set a total people variable initally to 0;
                  var total_people = 0;
                  // for each person allocated to the slot

                  // THIS WILL BREAK HERE IF NO LIST
                  if (y.labourAllocationList) {
                    //
                  } else {
                    console.error('NO LABOUR ALLOCATION LISTS :(');
                  }
                  _each(y.labourAllocationList, function (z) {
                    // find their related staff credentials
                    var worker = _find(vm.staff, {
                      staffId: z.staffId
                    });
                    // if there are workers
                    if (worker !== 'NO MATCH') {
                      // if there is a truck, set truck to true, and add to the truck number
                      // push the name and add to people total
                      // console.log('workers');
                      _each(worker, function (v) {
                        if (v.allocationType === 'Truck') {
                          truck = true;
                          truck_no += 1
                        }
                        workers.push(v.staffName);
                        if (v.allocationType !== 'Truck') {
                          total_people += 1
                        }
                      })
                    } else {
                      // if user has been set inactive we have nothing on them
                      workers.push('INACTIVE USER');
                    }
                  });
                  // work out the hours of the timeslot, then times by the number of people (not trucks)
                  if((Number(y.projTSFinishTime.split(':')[0]) > Number(y.projTSStartTime.split(':')[0]))){

                    var difference = Number(y.projTSFinishTime.split(':')[0]) - Number(y.projTSStartTime.split(':')[0]);
                    total_hours += difference * total_people;

                  } else {

                    var difference = 24.00 - Number(y.projTSStartTime.split(':')[0]) + Number(y.projTSFinishTime.split(':')[0]);
                    total_hours += difference * total_people;
                  }

                  if(y.projTSTitle){
                    s_title = y.projTSTitle;
                  }
                }
              });

              // for each of the worker names we pushed, dedupe them and get the length;
              var allWorkers = _solo(workers);
              var allWorkersLength = allWorkers.length;
              // for each worker, create a list of names to show on the slot, adding commas if needed
              for (var w = 0; w < allWorkersLength; w++) {
                var comma = w === 0 && allWorkers.length === 1 || w === allWorkers.length - 1 ? '' : ', ';
                stringWorkers += allWorkers[w] + comma;
              }
            } else {
              // if no timeslots, set blank
              time_slots = [];
            }
            // create an object for the slot, and push to the project's type's slots
            var sObj = {
              type: b,
              truck: truck,
              truck_total: truck_no,
              date: next_day,
              project: slot_id,
              project_name: slot_project,
              total: total_hours,
              timeslots: time_slots,

              slot_title: s_title,
              workerlist: stringWorkers,

              // todo: NEW
              margin_left: '100px',
              slots_mini : 'something'

            };
            tObj['slots'].push(sObj);
          }
          // get the width of the type slot
          tObj['gantt_width'] = a[b + 'StartDate'] ?
              _date.getDatesBetween(a[b + 'StartDate'], a[b + 'EndDate']).length === 0 ?
                  100 + 'px' : (_date.getDatesBetween(a[b + 'StartDate'], a[b + 'EndDate']).length) * 200 + 'px' : 0 + 'px';
          // if there was a date, add it to a list of all dates
          if (a[b + 'StartDate']) {
            dArr.push(vh.numerate(tObj['start_date']), vh.numerate(tObj['end_date']));
          }
          // add to project object
          dObj[b] = tObj;
        });
        nObj['types'] = dObj;
        // push new project to vue
        vm.projects.push(nObj);
      })

      // console.log(vm.projects);
      // console.log(vm.staff);

      // create an empty project for each possibly month to use as seperators
      // console.log('solo');
      _each(_solo(mArr), function (a) {
        fObj = {};
        // set month, year, and set that its a seperator for css purposes
        fObj['month'] = a.split(' ')[0];
        fObj['year'] = a.split(' ')[1];
        fObj['seperator'] = true;
        var numb = vh.month_number.indexOf(a.split(' ')[0]);
        var newnumb = numb < 10 ? '0' + numb : numb;
        fObj['order_month'] = a.split(' ')[1] + "" + newnumb + "0";
        // push to projects
        vm.projects.push(fObj);
      })
      // from the list of all dates calculate our date range
      var earliestDate = vh.daterize(Math.min.apply(Math, _solo(dArr)));
      var latestDate = vh.daterize(Math.max.apply(Math, _solo(dArr)));
      // set an array for each day in the range, will be used to create columns later
      vm.days = dArr.length == 0 ? [] : _date.getDatesBetween(earliestDate, latestDate);
      // calculate totals hours for each project from all timeslots
      vh.set_totals();
      // set dates wrapper to width of all days
      _el('date-column-wrapper').style.width = vm.days.length != 0 ? vm.days.length * 200 + 'px' : '0px';
      _el('events-scroll').style.width = vm.days.length != 0 ? vm.days.length * 200 + 'px' : '0px';
      // 300 to compensate for left sidebar
      _el('project-row-time-wrapper').style.width = vm.days.length != 0 ? vm.days.length * 200 + 'px' : '0px';
      // format events
      // console.log('holidays');
      _each(db_holidays, function (c) {
        // create empty event object
        eObj = {};
        eObj['name'] = c.holidayName ? c.holidayName : 'VOID';
        eObj['start_date'] = c.startDate ? c.startDate : 'VOID';
        eObj['end_date'] = c.endDate ? c.endDate : 'VOID';
        eObj['color'] = vm.colors['events_' + 'Holiday'];
        // set this later
        eObj['left_position'] = '';
        // set the width of the block based on the distance of the start and end
        eObj['gantt_width'] = c.startDate ?
            _date.getDatesBetween(c.startDate, c.endDate).length == 0 ?
                100 + 'px' : (_date.getDatesBetween(c.startDate, c.endDate).length) * 200 + 'px' : 0 + 'px';
        vm.events.push(eObj);
      })
      _log('Processing complete.');
      vm.check_loaded();
    },
    // check columns have loaded before we mess with them
    check_loaded: function () {
      var lastDay = vm.days.length != 0 ? vm.days[vm.days.length - 1].Id : 'vm';
      // checks existance of the last day column
      // as need to make sure the element exists before setting pos
      setTimeout(function () {
        if (_el(lastDay) == null) {
          vm.check_loaded();
        } else {
          vm.generate_gantts();
        }
      }, 100)
    },
    // generates position and length of each blocks
    generate_gantts: function () {
      _log('Generating dates...');
      // create a day measure to check agaisn't via date ids
      var dayMeasures = [];
      _each(vm.days, function (a) {
        dayMeasures[a.Id] = _el(a.Id).offsetLeft;
        a.Today = a.Id == _date.getToday() ? true : false;
      })
      // for each projects' types' startdate, set the matching day measure position
      _each(vm.projects, function (b) {
        _each(vm.types, function (c) {
          if (b.types) {
            // compensate size
            b.types[c].left_position = dayMeasures[b.types[c].start_date] - 341 + 'px';
          }
        })
      })
      // for each events startdate, set the matching day measure position
      _each(vm.events, function (d) {
        if (d.start_date) {
          if (dayMeasures[d.start_date] != undefined) {
            d.left_position = Number(dayMeasures[d.start_date]) - 341 + 'px';
          } else {
            d.left_position = -9999 + 'px';
          }
        }
      })
      // set scroll
      vm.keep_scroll();
      // set today position

      if(!vm.saveScrollLeft){
        vm.set_today();
      } else {
        vm.set_prev_scroll();
      }
      // load totals vs
      // todo: changed
      // vh.redo_slots();



      // 'load' frontend
      // 'load' frontend
      setTimeout(function () {
        vm.loaded = true;
        // console.log(vm);
        _log('Load complete.');

        var acc = document.getElementsByClassName("project-specials");
        for (var i = 0; i < acc.length; i++) {

          acc[i].addEventListener("click", handleCollapse, false);
        }

        /*var detailsProject = document.getElementsByClassName("detailCollapse");
        for (var i = 0; i < detailsProject.length; i++) {

          detailsProject[i].addEventListener("click", closeProjectDetail, false);
        }

        function closeProjectDetail() {
          var month = this.innerHTML.split(' ').join('');
          var months = document.getElementsByClassName('detailCollapse');

          for(var j = 0; j < months.length; j++) {

            if(months[j].parentNode.parentNode.parentNode.classList.contains("selected_row")) {
              months[j].parentNode.parentNode.parentNode.classList.remove("selected_row");
              months[j].parentNode.parentNode.parentNode.classList.add("not_selected");
              break;
            }
          }
        }*/
        var dragItems = document.querySelectorAll('[draggable=true]');

        for (var i = 0; i < dragItems.length; i++) {
          addEvent(dragItems[i], 'dragstart', function (event) {
            // store the ID of the element, and collect it on the drop later on


            console.log('setting following id ' + this.id);

            event.dataTransfer.setData('Text', this.id);
          });
        }
        function handleCollapse() {

          var month = this.innerHTML.split(' ').join('');
          var collapse = true;
          var months = document.getElementsByClassName(month.trim() + 'projectCollapse');
          for(var j = 0; j < months.length; j++) {

            if(months[j].parentNode.parentNode.parentNode.classList.contains("selected_row")) {
              months[j].parentNode.parentNode.parentNode.classList.remove("selected_row");
              months[j].parentNode.parentNode.parentNode.classList.add("not_selected");
              collapse = false;
              break;
            }
          }

          if(collapse) {

            for(var j = 0; j < months.length; j++) {
              months[j].parentNode.parentNode.parentNode.classList.toggle("projectCollapse");
            }

            var months = document.getElementsByClassName(month.trim() + 'slotsCollapse');
            for(var j = 1; j < months.length; j++) {
              months[j].classList.toggle("slotsCollapse");
            }
          }
        }
      }, 500);
    },
    // resets gantts after changes
    reset_gantts: function () {
      // _log('Recalculating gantts...');
      // create a day measure to check agaisn't via date ids
      var dayMeasures = [];
      _each(vm.days, function (a) {
        dayMeasures[a.Id] = _el(a.Id).offsetLeft;
        a.Today = a.Id == _date.getToday() ? true : false;
      })
      // for each projects' types' startdate, set the matching day measure position
      _each(vm.projects, function (b) {
        _each(vm.types, function (c) {
          if (b.types) {
            // compensate size
            b.types[c].gantt_width = b.types[c].start_date != '99/99/9999' ?
                _date.getDatesBetween(b.types[c].start_date, b.types[c].end_date).length == 0 ?
                    100 + 'px' : (_date.getDatesBetween(b.types[c].start_date, b.types[c].end_date).length) * 200 + 'px' : 0 + 'px';
            b.types[c].left_position = dayMeasures[b.types[c].start_date] - 341 + 'px';
          }
        })
      })
      // _log('Recalculation complete.');
    },
    // on scroll functions
    keep_scroll: function () {
      // keeps the dates and the projects scrolling inline
      _el('dates-wrapper').scrollLeft = _el('project-scroll').scrollLeft;
      _el('events-wrapper').scrollLeft = _el('project-scroll').scrollLeft;
      _el('project-row-detail-wrapper').scrollTop = _el('project-scroll').scrollTop;
    },
    // sets a scroll to the first date in the project
    set_scroll: function (project) {
      if (project.is_locked != true && project.no_dates == 'dates') {
        var firstdate = '';
        // get the first valid date in a project
        _each(vm.types, function (a) {
          if (project.types[a].start_date && firstdate == '') {
            if (project.types[a].start_date != '99/99/9999') {
              firstdate = project.types[a].start_date
            }
          }
        })
        var startnumber = _el('project-scroll').scrollLeft;
        var newnumber = _el(firstdate).offsetLeft - 306;
        var startvalue = (Math.ceil(startnumber / 10) * 10);
        var newvalue = (Math.ceil(newnumber / 10) * 10);
        // loops used here to create a 'smooth' scroll to the project, rather than instant
        var startnum = startnumber > newnumber ? newvalue : startvalue;
        var endnum = startnumber > newnumber ? startvalue : newvalue;
        for (var a = startnum; a < endnum; a++) {
          function aloop() {
            setTimeout(function () {
              document.getElementById('project-scroll').scrollLeft += startnumber > newnumber ? -1 : 1;
            }, 4);
          }
          aloop();
        }
      }
    },
    // sets the scroll position to today and the month
    set_today: function () {
      // get the day
      var today = _date.getToday();
      // get todays month
      var month = _date.monthString[Number(today.split('/')[1]) - 1];
      // check agaisn't elements with class of 'monthyear'
      var elclass = month + Number(today.split('/')[2]);
      var matching = _els(elclass);
      // if there are matching set offset top scroll to match
      if (matching[0] !== undefined) {
        _el('project-scroll').scrollTop = matching[0].offsetTop;
      }
      // if there is a column for today, set the left scroll to match
      if (_el(today)) {
        _el('project-scroll').scrollLeft = _el(today).offsetLeft - 301;
        vm.keep_scroll();
      }
    },
    // custom filter for the search box
    filter_projects: function (a) {
      return vh.filter(a);
    },

    set_prev_scroll: function(){
      _el('project-scroll').scrollLeft =  vm.saveScrollLeft;
      _el('project-scroll').scrollTop = vm.saveScrollTop;

      // console.log(vm.saveScrollLeft);
      // console.log(vm.saveScrollTop);

    },

    // select a day slot
    select_slot: function (slot) {
      vm.selected_slot = slot;
      vm.slot_edit = true;
    },
    // select a timeslot
    select_timeslot: function (timeslot) {
      vm.deselect_timeslots();
      timeslot.selected = true;
      vm.selected_timeslot = timeslot;
    },
    // deselect timeslots
    deselect_timeslots: function () {
      _each(vm.timeslots, function (a) {
        a.selected = false;
      });
      _each(vm.selected_slot.timeslots, function (b) {
        b.selected = false;
      });
      vm.selected_timeslot = '';
    },
    // deselects all projs
    deselect_projs: function () {
      _each(vm.projects, function(a) {
        a.selected_row = 'not_selected';
      })
    },
    // filter crew members by availability
    check_available: function (a) {
      return vh.check_availability(a);
    },

    //TIAGO MENDES
    drag: function(timeslot) {
      draggedSlot = timeslot;
      // console.log('timeslot::: ' + JSON.stringify(draggedSlot));
    },

    drop: function (timeslot) {
      //draggedSlot = timeslot;
      // console.log('drag ds::: ' + JSON.stringify(draggedSlot));
      // console.log('drop ts::: ' + JSON.stringify(timeslot));

      console.log('clone time slot method called ');
      console.log(arguments.caller);

      cloneTimeSlot(JSON.stringify(draggedSlot), JSON.stringify(timeslot));
    },
    //END TIAGO MENDES

    // create a new timeslot for the selected slot based on the times given
    create_slot: function () {
      var newtimeslot = {
        projectId: vm.selected_slot.project,
        projectTSId: "NOID",
        projectName: vm.selected_slot.project_name,
        projTSType: vm.selected_slot.type.charAt(0).toUpperCase() + vm.selected_slot.type.slice(1),
        projTSTitle: vm.title,
        projTSDate: vm.selected_slot.date,
        projTSStartTime: vm.start_time,
        projTSFinishTime: vm.end_time,
        selected: false,
        toCreate: true,
        toUpdate: false,
        toDelete: false,
        labourAllocationList: []
      }
      vm.selected_slot.timeslots.push(newtimeslot);
      vm.timeslots.push(newtimeslot);
      vh.redo_slots();
      vm.dirty = true;
    },
    // removes a crew member from a timeslot
    remove_crew: function (timeslot, id) {
      if (timeslot.labourAllocationList) {
        _each(timeslot.labourAllocationList, function (a, b) {
          if (a) {
            if (a.staffId === id) {
              timeslot.labourAllocationList.splice(b, 1);
            }
          }
        })
      }
      // mark edit
      timeslot.toUpdate = true;
      vh.redo_slots();
      vm.dirty = true;
    },
    // adds a crew member to a timeslot
    add_crew: function (crew) {
      // console.log(crew, vm.roles.indexOf(crew.projectRole));
      // console.log(crew, vm.secroles.indexOf(crew.secondaryRole));

      var newcrew = {
        name: crew.staffName,
        role: vm.roles.indexOf(crew.projectRole) !== -1 ? crew.projectRole : vm.roles[0],
        secrole: vm.secroles.indexOf(crew.secondaryRole) !== -1 ? crew.secondaryRole : vm.secroles[0],
        cnc: crew.cncOperator,
        forklift: crew.forkliftLicense,
        type: crew.allocationType,
        staffId: crew.staffId,
        assignedRole: crew.projectRole ? crew.projectRole : 'Transport',
      };
      vm.selected_timeslot.labourAllocationList.push(newcrew);
      vm.selected_timeslot.toUpdate = true;
      vh.redo_slots();
      vm.dirty = true;
    },
    // adds a crew member to a timeslot
    override_crew: function (crew) {
      // console.log(crew, vm.roles.indexOf(crew.projectRole));
      // console.log(crew, vm.secroles.indexOf(crew.secondaryRole));

      var newcrew = {
        name: crew.staffName,
        role: vm.roles.indexOf(crew.projectRole) !== -1 ? crew.projectRole : vm.roles[0],
        secrole: vm.secroles.indexOf(crew.secondaryRole) !== -1 ? crew.secondaryRole : vm.secroles[0],
        cnc: crew.cncOperator,
        forklift: crew.forkliftLicense,
        type: crew.allocationType,
        staffId: crew.staffId,
        assignedRole: crew.projectRole ? crew.projectRole : 'Transport',
      };
      vm.selected_timeslot.labourAllocationList.push(newcrew);
      vm.selected_timeslot.toUpdate = true;
      vh.redo_slots();
      vm.dirty = true;
    },
    delete_slot: function(timeslot) {
      timeslot.toDelete = true;
      timeslot.selected = false;
      timeslot.labourAllocationList = [];
      var corresponding = _find(vm.timeslots, {
        projectId: timeslot.projectId,
        projTSType: timeslot.projTSType,
        projTSTitle: timeslot.projTSTitle,
        projTSDate: timeslot.projTSDate,
        projTSStartTime: timeslot.projTSStartTime,
        projTSFinishTime: timeslot.projTSFinishTime
      })
      corresponding[0].toDelete = true;
      corresponding[0].selected = false;
      corresponding[0].labourAllocationList = [];
      vh.redo_slots();
      vm.dirty = true;

    },
    // find edited projects and group them to send to the interfacer
    save_changes: function () {
      vm.saveScrollLeft = _el('project-scroll').scrollLeft;
      vm.saveScrollTop = _el('project-scroll').scrollTop;

      vm.save_text = 'Saving';
      var updated_create_array = [];
      var delete_array = [];
      _each(vm.projects, function(a) {
        if (a.types) {
          _each(vm.types, function(b) {
            if (a.types[b].slots) {
              _each(a.types[b].slots, function(c) {
                _each(c.timeslots, function(d) {
                  if (d.toUpdate == true && d.projectTSId != 'NOID') {
                    var crewObj = [];
                    _each(d.labourAllocationList, function(e) {
                      crewObj.push({
                        staffId: e.staffId,
                        assignedRole: e.assignedRole
                      })
                    })
                    var pushObj = {
                      projectId: d.projectId,
                      projTSId: d.projectTSId,
                      projTSType: d.projTSType,
                      projTSTitle: d.projTSTitle,
                      projTSDate: d.projTSDate,
                      startTime: d.projTSStartTime,
                      finishTime: d.projTSFinishTime,
                      crewMembers: crewObj
                    }
                    if (pushObj.crewMembers.length == 0) {
                      // dont push
                    } else {
                      updated_create_array.push(pushObj);
                    }
                  }
                  if (d.toCreate == true && d.projectTSId == 'NOID' && d.toDelete == false) {
                    var crewObj = [];
                    _each(d.labourAllocationList, function(e) {
                      crewObj.push({
                        staffId: e.staffId,
                        assignedRole: e.assignedRole
                      })
                    })
                    var pushObj = {
                      projectId: d.projectId,
                      projTSId: 'NOID',
                      projTSType: d.projTSType,
                      projTSTitle: d.projTSTitle,
                      projTSDate: d.projTSDate,
                      startTime: d.projTSStartTime,
                      finishTime: d.projTSFinishTime,
                      crewMembers: crewObj
                    }
                    if (pushObj.crewMembers.length == 0) {
                      // dont push
                    } else {
                      updated_create_array.push(pushObj);
                    }
                  }
                  if (d.toDelete == true && d.projectTSId != 'NOID') {
                    delete_array.push(d.projectTSId);
                  }
                })
              })
            }
          })
        }
      });
      // console.log('update/create', updated_create_array);
      // console.log('delete', delete_array);
      // call the interfacer and send our object to upsert
      interfacer.set_data(updated_create_array, delete_array).then(function () {
        // _log('Projects upserted, refreshing...');
        vm.save_text = 'Saved!';
        // refresh
        vm.refresh_all();
      }).catch(function (code) {
        vm.error = true;
        vm.error_code = code;
      })
    },
    // calls a refresh from the get data point
    refresh_all: function () {
      // call get data
      interfacer.get_data().then(function () {
        //reset vars
        vm.loaded = false;
        vm.projects = [];
        vm.timeslots = [];
        vm.colors = {};
        vm.days = [];
        vm.staff = [];
        vm.roles = [];
        vm.save_text = 'Save';
        vm.days = [];
        vm.events = [];
        vm.unquoted = [];
        vm.dirty = false;
        vm.search_query = '';
        vm.crewquery = '';
        vm.dirty = false;
        vm.selected_slot = {};
        vm.start_time = '08:00';
        vm.end_time = '18:00';
        vm.title = '';
        vm.selected_timeslot = '';
        vm.slot_edit = false;
        vm.save_text = 'Save';
        vm.error = false;
        vm.error_code = '';
        // call refresh
        vm.process_data();
      }).catch(function (code) {
        vm.loaded = true;
        vm.error = true;
        vm.error_code = code;
      })
    },

    // filter out html gump
    filter_uri: function(val) {
      return this.replacer(val);
    },

    tfhour: function(val) {
      var lhs = val.split(':')[0];
      var rhs = val.split(':')[1];
      var lv = lhs.length == 1 ? '0' + lhs : lhs;
      var rv = '00';
      return lv + ':' + rv;
    }
  },
  // called when ready
  ready: function () {
    // load in the data
    this.refresh_all();
  },
  // called before dom compile
  beforeCompile: function () {
    // run the preprocessor
    preprocessor.process();
  },
})