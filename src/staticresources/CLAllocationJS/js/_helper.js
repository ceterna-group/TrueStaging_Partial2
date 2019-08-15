// helper functions for vue controller
// this is so our controller isn't ridiculously fat
// used for stuff like formatting, transformations, filters, orders etc
var vh = {
  // used to turn pm and cc into abbreviated initials
  abbreviate: function (a) {
    var b = '';
    var c = typeof a == 'object' ? true : false;
    // single entry (PM)
    if (c == false) {
      d = a.split(' ');
      _each(d, function (e) {
        b += e.charAt(0);
      })
    } else {
      if (a.length == 1) {
        b += vh.abbreviate(a[0])
      } else {
        b += vh.abbreviate(a[0]) + '/' + vh.abbreviate(a[1])
      }
    }
    return b;
  },
  // returns part of a string date as a number
  strip: function (a, b) {
    return Number(a.split('/')[b]);
  },
  // turns string date into long number
  numerate: function (a) {
    var b = a.split('/')[2] + a.split('/')[1] + a.split('/')[0];
    return Number(b);
  },
  // turns long number into string date (reverse of numerate)
  daterize: function (a) {
    var b = JSON.stringify(a);
    return b.substring(6, 8) + '/' + b.substring(4, 6) + '/' + b.substring(0, 4);
  },
  // used to turn month name into number
  month_number: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"],
  // custom filter for the search box, filters projects
  filter: function (a) {
    // keep everything lowercase
    var b = vm.search_query.toLowerCase();
    // check if the query is a month
    var c = 0;
    _each(vh.month_number, function (x) {
      c += x.toLowerCase() == b ? 1 : 0
    })
    if (b == '') {
      // if the query is blank return all
      return true
    } else {
      // get all the values to search on as one string
      // if you want to search on more fields add them here!
      var d = a.name + a.project_manager + a.client + a.crew_chiefs + '' + a.number;
      e = d.toLowerCase();
      // if the search query is not in this string
      if (e.indexOf(b) == -1) {
        // but the search is a month the project is in that month
        if (c > 0 && b == a.month.toLowerCase()) {
          return true;
        } else {
          return false
        }
      } else {
        // query is in the string
        return true
      }
    }
  },
  // give a dd/mm/yyyy string, and return the day a specified number after in same format
  next_day: function (a, g) {
    var b = a.split('/')[2] + '/' + a.split('/')[1] + '/' + a.split('/')[0];
    var c = new Date(b);
    var d = new Date(c.setDate(c.getDate() + g))
    var e = d.toString()
    var f = e.split(' ')[2] + '/' + _date.monthNumber[e.split(' ')[1]] + '/' + e.split(' ')[3];
    return f;
  },
  // custom filter that checks availability for crew members based on the day and the selected slot 
  // and then on the timeslot as well because it's awesome
  check_availability: function (a) {
    var slot = vm.selected_slot;
    var date = slot.date;
    var choice = true;
    a.available = true;
    var selected_range = '';
    a.reason = 'Available.';
    // for each date in the crew members availability
    if (a.availabilityInfoList) {
      _each(a.availabilityInfoList, function (b) {
        var range = [];
        var raw_range = _date.getDatesBetween(b.dateFrom, b.dateTo);
        _each(raw_range, function (c) {
          range.push(c.Id);
        })
        var counter = 0;
        for (var c = 0; c < range.length; c++) {
          if (a.allocationType == 'Employee' || a.allocationType == 'Truck') {
            // if the date matches the current date
            // employee is on holiday
            if (range[c] == date) {
              counter += 1;
            }
          }
          if (a.allocationType == 'Freelance') {
            // if the date matches the current date
            // freelance is available
            if (range[c] == date) {
              counter += 1;
            }
          }
        }
        if (a.allocationType == 'Employee' || a.allocationType == 'Truck') {
          choice = counter != 0 ? false : true;
          if (choice == false) {
            selected_range = b.dateFrom + ' to ' + b.dateTo;
            a.reason = 'On holiday from ' + selected_range;
            a.available = choice;
          }
        }
        if (a.allocationType == 'Freelance') {
          choice = counter == 0 ? false : true;
        }
      })
    }
    if (choice == false && a.allocationType == 'Freelance') {
      a.reason = 'No contracts for this day.';
      a.available = choice;
    }

    // now check timeslots
    if (vm.selected_timeslot != '') {
      // get selected timeslot
      var timeslot = vm.selected_timeslot;
      // for start and end time create a range of time strings
      var start1 = Number(timeslot.projTSStartTime.split(':')[0]);
      var end1 = Number(timeslot.projTSFinishTime.split(':')[0]);
      var selected_range = [];

      if (end1 > start1){
        for (var d = start1; d < end1; d++) {
          var digits1 = d < 10 ? '0' + d : d;
          var string1 = digits1 + ':00';
          selected_range.push(string1);
        }
      } else{
        for (var d = end1; d < start1; d++) {
          var digits1 = d < 10 ? '0' + d : d;
          var string1 = digits1 + ':00';
          selected_range.push(string1);
        }
      }
      
      // for each timeslot
      _each(vm.timeslots, function (e) {
        if (e.projTSDate == timeslot.projTSDate) {
          // get the timeslot string range
          var start2 = Number(e.projTSStartTime.split(':')[0]);
          var end2 = Number(e.projTSFinishTime.split(':')[0]);
          var timeslot_range = [];
          if(end2 > start2){
            for (var h = start2; h < end2; h++) {
              var digits2 = h < 10 ? '0' + h : h;
              var string2 = digits2 + ':00';
              timeslot_range.push(string2);
            }
          } else{
            for (var h = end2; h < start2; h++) {
              var digits2 = h < 10 ? '0' + h : h;
              var string2 = digits2 + ':00';
              timeslot_range.push(string2);
            }
          }
          
          // for each labour allocation
          _each(e.labourAllocationList, function (f) {
            // if we have a match to this current crew member

            var isDummy = f.name.includes('Dummy');
            if (f.staffId == a.staffId && !isDummy){
              _each(selected_range, function (g) {
                if (timeslot_range.indexOf(g) != -1) {
                  a.available = false;
                  a.reason = 'Working ' + e.projTSStartTime + ' - ' + e.projTSFinishTime + ' on ' + e.projectName + ' (' + e.projTSType + ')';
                }
              })
            }
          })
        }
      })
    }
    var crewsearch = vm.crewquery.toLowerCase();
    var matchstring = (a.staffName + a.allocationType + a.projectRole + a.secondaryRole).toLowerCase().replace(/ /g, '');
    if (crewsearch != '') {
      if (crewsearch == 'cnc' && a.cncOperator == true) {
        return true;
      }
      if (crewsearch == 'forklift' && a.forkliftLicense == true) {
        return true;
      }
      if (crewsearch == 'driving' && a.cncOperator == true) {
        return true;
      }
      if (crewsearch == 'driver' && a.driversLicense == true) {
        return true;
      }
      if (crewsearch == 'ipaf' && a.iPAF == true) {
        return true;
      }
      if (matchstring.indexOf(crewsearch) != -1) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }

  },
  // sets all the day totals along the top, based on all matching timeslots
  set_totals: function () {
    // for each day
    _each(vm.days, function (a) {

        // find the timeslots matching
        var timeslots = _find(vm.timeslots, {
          projTSDate: a.Id
        })
        
        var total = 0;
        // for each timeslot, get the total hours not including trucks
        if (timeslots[0] != undefined) {
          total += vh.total_get(timeslots)
        }
        a.Total = total;

      })
      // for each project
    _each(vm.projects, function (a) {
      // find the timeslots matching
      var timeslots = _find(vm.timeslots, {
        projectId: a.salesforce_id
      });
      var workshop_total = 0;
      var onsite_total = 0;
      // for each timeslot, get the total hours not including trucks
      if (timeslots[0] != undefined) {
        workshop_total += vh.total_get(timeslots, 'Workshop');
        onsite_total += vh.total_get(timeslots, 'Site');
      }
      a.total_hours = workshop_total + onsite_total;
      a.workshop_actual = workshop_total;
      a.onsite_actual = onsite_total;
    })
  },
  // used for setting totals
  total_get: function (timeslots, type) {
    total = 0;
    if (type == 'Workshop') {
    // for each timeslot, get the total hours not including trucks
      _each(timeslots, function (b) {
        if (b.toDelete == false && b.projTSType == 'Workshop') {
          var totalPeople = 0;
          if (b.labourAllocationList) {
            _each(b.labourAllocationList, function (c) {
              if (c.assignedRole != 'Transport') {
                totalPeople += 1;
              }
            })
          }
          if ((b.projTSFinishTime && b.projTSStartTime) && (Number(b.projTSFinishTime.split(':')[0]) > Number(b.projTSStartTime.split(':')[0]))) {
              var timeDifference = Number(b.projTSFinishTime.split(':')[0]) - Number(b.projTSStartTime.split(':')[0]);
              total += (timeDifference * totalPeople);
            
          } else{
              var timeDifference = 24 - Number(b.projTSStartTime.split(':')[0]) + Number(b.projTSFinishTime.split(':')[0]); 
              total += (timeDifference * totalPeople);
        
          }
         
        }
      })
    } else {
      _each(timeslots, function (b) {
        if (b.toDelete == false && b.projTSType !== 'Workshop') {
          var totalPeople = 0;
          if (b.labourAllocationList) {
            _each(b.labourAllocationList, function (c) {
              if (c.assignedRole != 'Transport') {
                totalPeople += 1;
              }
            })
          }
          if ((b.projTSFinishTime && b.projTSStartTime) && (Number(b.projTSFinishTime.split(':')[0]) > Number(b.projTSStartTime.split(':')[0]))) {
    
              var timeDifference = Number(b.projTSFinishTime.split(':')[0]) - Number(b.projTSStartTime.split(':')[0]);
              total += (timeDifference * totalPeople);

          } else{

              var timeDifference = 24 - Number(b.projTSStartTime.split(':')[0]) + Number(b.projTSFinishTime.split(':')[0]);
              total += (timeDifference * totalPeople);
          }
    
        }
      })
    }
    return total;
  },

  
  // reset day slot totals and strings

  redo_slots: function () {
    // for each project slot
    _each(vm.projects, function (a) {
      if (a.types) {
        _each(vm.types, function (b) {
          if (a.types[b]) {
            if (a.types[b].slots) {
              _each(a.types[b].slots, function (c) {
                // set a total people variable initally to 0;
                // set some variables to defaults
                var workers = [];
                var stringWorkers = '';
                var truck = false;
                var total_hours = 0;
                var truck_no = 0;
                var s_titles = [];
                var s_title = '';
                _each(c.timeslots, function (d) {
                    if (d.toDelete == false) {
                      var total_people = 0;
                      // for each person allocated to the slot
                      _each(d.labourAllocationList, function (z) {
                          // find their related staff credentials
                          var worker = _find(vm.staff, {
                              staffId: z.staffId
                            })
                            // if there are workers
                          if (worker !== 'NO MATCH') {
                            // if there is a truck, set truck to true, and add to the truck number
                            // push the name and add to people total
                            _each(worker, function (v) {
                              if (v.allocationType == 'Truck') {
                                truck = true;
                                truck_no += 1
                              }
                              workers.push(v.staffName);
                              if (v.allocationType != 'Truck') {
                                total_people += 1
                              }
                            })
                          } else {
                            // if user has been set inactive we have nothing on them
                            workers.push('INACTIVE USER');
                          }
                        })
                        // work out the hours of the timeslot, then times by the number of people (not trucks)
                        

                      if((Number(d.projTSFinishTime.split(':')[0]) > Number(d.projTSStartTime.split(':')[0]))){

                        var difference = Number(d.projTSFinishTime.split(':')[0]) - Number(d.projTSStartTime.split(':')[0]);
                        total_hours += (difference * total_people);

                      }else {
                        var difference = 24 - Number(d.projTSStartTime.split(':')[0]) + Number(d.projTSFinishTime.split(':')[0]);
                        total_hours += (difference * total_people);
                      }

                      if(d.projTSTitle){
            
                        s_title = d.projTSTitle;
                        s_titles.push(s_title);
                        
                      }
                      
                    }
                  })

                   // for each of the s_titles we pushed, dedupe them and get the length;
                var allTitles = _solo(s_titles);
                var allTitlesLength = allTitles.length;

                if(allTitles.length > 1){
                  s_title = '';
                  // for each s_title, create a list of s_titles to show on the slot, adding commas if needed
                  for (var t = 0; t < allTitlesLength; t++) {
                    var comma = t == allTitles.length - 1 ? '' : ', ';
                    s_title += allTitles[t] + comma;
                  }
                }else{
                  s_title == allTitles[0];
                }

                  // for each of the worker names we pushed, dedupe them and get the length;
                var allWorkers = _solo(workers);
                var allWorkersLength = allWorkers.length;
                // for each worker, create a list of names to show on the slot, adding commas if needed
                for (var w = 0; w < allWorkersLength; w++) {
                  var comma = w == 0 && allWorkers.length == 1 || w == allWorkers.length - 1 ? '' : ', ';
                  stringWorkers += allWorkers[w] + comma;
                }
                c.truck = truck;
                c.truck_total = truck_no;
                c.total = total_hours;
                c.workerlist = stringWorkers;
                c.slot_title = s_title;
              })

            }
          }
        })
      }
    })
    vh.redo_totals();
  },
  // sets all the day and project totals
  redo_totals: function () {
    var cells = document.getElementsByClassName('cell-balance');
    // console.log(cells)
    for (var w = 0; w < cells.length; w++) {
      console.log(cells[w].innerText);
      if (Number(cells[w].innerText) < 0) {
        cells[w].className = 'cell-balance error-text'
      } else {
        cells[w].className = 'cell-balance'
      }
    }
    // for each day, check all the project timeslots
    _each(vm.days, function (x) {
      var daytotal = 0;
      _each(vm.projects, function (a) {
        var projtotal = 0;
        var workshop_total = 0;
        var onsite_total = 0;
        if (a.types) {
          _each(vm.types, function (b) {
            if (a.types[b]) {
              if (a.types[b].slots) {
                _each(a.types[b].slots, function (c) {
                  if (c.timeslots) {
                    // for each timeslot, if the date matches the day, add to day total, else just add to proj total
                    _each(c.timeslots, function (d) {
                      var totalPeople = 0;
                      if (d.labourAllocationList) {
                        _each(d.labourAllocationList, function (e) {
                          if (e.assignedRole != 'Transport') {
                            totalPeople += 1;
                          }
                        })
                      }
                      if ((d.projTSFinishTime && d.projTSStartTime) && ((Number(d.projTSFinishTime.split(':')[0]) > Number(d.projTSStartTime.split(':')[0])))) {

                          var timeDifference = Number(d.projTSFinishTime.split(':')[0]) - Number(d.projTSStartTime.split(':')[0]);
                         
                          if (b == 'workshop') {
                            workshop_total += (timeDifference * totalPeople);
                          } else {
                            onsite_total += (timeDifference * totalPeople);
                          }

                          projtotal += (timeDifference * totalPeople);
                          daytotal += c.date == x.Id ? (timeDifference * totalPeople) : 0;

                      } else{

                          var timeDifference = 24 - Number(d.projTSStartTime.split(':')[0]) + Number(d.projTSFinishTime.split(':')[0]);
                          
                          if (b == 'workshop') {
                            workshop_total += (timeDifference * totalPeople);
                          } else {
                            onsite_total += (timeDifference * totalPeople);
                          }

                          projtotal += (timeDifference * totalPeople);
                          daytotal += c.date == x.Id ? (timeDifference * totalPeople) : 0;
                      }
                    
                    })
                  }
                })
              }
            }
          })
        }
        a.total_hours = projtotal;
        a.workshop_actual = workshop_total;
        a.onsite_actual = onsite_total;
      })
      x.Total = daytotal;
    })
  }
}