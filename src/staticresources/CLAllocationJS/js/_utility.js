// commonly used functions created as a set of utility functions
// @author Elliott Thurman-Newell <elliott@ceterna.com>
/*
  _date.checkPast(date1, date2)
  _date.getWholeMonth(date)
  _date.getPartialMonth(direction, date) 
  _date.getDatesBetween(date1, date2)
  _date.getToday()
  _each(array, function, opstart, opend)
  _el(id)
  _els(class)
  _find(array of objects, object to match)
  _log(value, optype)
  _solo(array)
*/

// loops through an array
// can pass through start/end numbers as c and d but
// otherwise defaults to 0 and array length
function _each(a, b, c, d) {
  "use strict";
  var e = !c ? 0 : c;
  var f = !d ? a.length : d;
  for (var g = e; g < f; g++) {
    b(a[g], g)
  }
}
// finds matching objects in an array
// can have multiple key:value pairs to match in the b object
function _find(a, b) {
  "use strict";
  var c = [];
  var d = [];
  var e = '';
  for (e in b) {
    c.push({
      f: e,
      g: b[e]
    })
  }
  _each(a, function (h) {
    var i = 0;
    var j = '';
    for (j in h) {
      _each(c, function (k) {
        if (j == k.f && h[j] == k.g) {
          i += 1
        }
      })
    }
    if (i == c.length) {
      d.push(h)
    }
  });
  var l = d[0] == undefined ? 'NO MATCH' : d;
  return l;
}
// dedupes a list
function _solo(a) {
  "use strict";
  var b = [];
  _each(a, function (c, d) {
    if (b.indexOf(c) == -1) {
      b.push(a[d])
    }
  });
  return b;
}
// log to console with timestamp
// can pass b as 'err' or 'tab' for .error and .table logs
function _log(a, b) {
  var c = new Date();
  var d = c.getHours() + ':' + c.getMinutes() + ':' + c.getSeconds() + ':' + c.getMilliseconds();
  var e = b == 'tab' ?
    console.table(a) : b == 'err' ?
    console.error(d, 'Error!', a) : b ?
    console.log(d, a, b) : console.log(d, a);
  return e;
}
// return element with provided id
function _el(a) {
  return document.getElementById(a);
}
// returns array of all elements with provided classname
function _els(a) {
  var b = [];
  var c = document.getElementsByClassName(a);
  _each(c, function (d) {
    b.push(d)
  })
  return b;
}
// functions to generate ranges of dates
// accepts dates in the format of DD/MM/YYYY
// also a couple of utlity stuff like turn months into numbers
var _date = {
  // gets the current day in the format DD/MM/YYYY
  getToday: function () {
    var a = JSON.stringify(new Date());
    var b = a.split('-')[0].split('"')[1];
    var c = a.split('-')[1];
    var d = a.split('-')[2].split('T')[0];
    return d + '/' + c + '/' + b;
  },
  // returns true if the first date is earlier than the second date
  checkPast: function (a, b) {
    c = 0;
    for (var d = 0; d < 3; d++) {
      c += Number(a.split('/')[d]) < Number(b.split('/')[d]) ? 1 : 0;
    }
    var e = c > 0 ? true : false
    return e;
  },
  // gets all the dates for a month
  getWholeMonth: function (a) {
    a = _date.flipDate(a);
    if (_date.invalid(a) == false) {
      return _log(_date.error, 'err');
    };
    var b = _date.dsplit(a);
    var c = _date.isLeap(b[0]) == true && b[1] == 2 ? true : false;
    var d = c == true ? 30 : (_date.monthLength[b[1]]) + 1;
    return _date.createLoop(b[0], b[1], 1, d);
  },
  // gets only some dates in a month
  // accepts '<' for all dates before and '>' for all dates after
  getPartialMonth: function (a, b) {
    b = _date.flipDate(b);
    if (_date.invalid(b) == false) {
      return _log(_date.error, 'err');
    };
    var c = _date.dsplit(b);
    var d = _date.isLeap(c[0]) == true && c[1] == 2 ? true : false;
    var e = a == '<' ? 1 : c[2];
    var f = a == '<' ? c[2] + 1 : d == true ? 30 : (_date.monthLength[c[1]]) + 1;
    return _date.createLoop(c[0], c[1], e, f);
  },
  // gets all the dates between the two different dates
  // date1 must be earlier than date2
  getDatesBetween: function (a, b) {
    var c = [];
    var d = _date.dsplit(a);
    var e = _date.dsplit(b);
    // same year, same month
    if (d[2] == e[2] && d[1] == e[1]) {
      var f = d[0];
      var g = e[0] + 1;
      var h = _date.createLoop(d[2], d[1], f, g);
      _each(h, function (i) {
        c.push(i);
      })
    }
    // same year, different month
    if (d[2] == e[2] && d[1] != e[1]) {
      var f = _date.getPartialMonth('>', a);
      var g = _date.getPartialMonth('<', b);
      var h = (e[1] - d[1]) - 1;
      // push first month
      _each(f, function (y) {
          c.push(y);
        })
        // if any months in between
      if (h != 0) {
        for (var z = 0; z < h; z++) {
          var i = (d[1] + 1) + z;
          var j = i < 10 ? 0 + '' + i : i;
          var k = '01' + '/' + j + '/' + d[2];
          var l = _date.getWholeMonth(k);
          _each(l, function (w) {
            c.push(w);
          })
        }
      }
      // then add final month
      _each(g, function (m) {
        c.push(m);
      })
    }
    // different years
    if (d[2] != e[2]) {
      var f = (e[2] - d[2]) - 1;
      var g = _date.getPartialMonth('>', a);
      var h = _date.getPartialMonth('<', b);
      // set range with first year range
      var i = [{
        j: d[1] + 1,
        k: 13,
        l: d[2]
      }];
      // add inbetween years if applicable
      for (var m = 0; m < f; m++) {
        i.push({
          j: 1,
          k: 13,
          l: d[2] + 1
        })
      }
      // add last year range
      i.push({
        j: 1,
        k: e[1],
        l: e[2]
      });
      // first push the first month
      _each(g, function (n) {
        c.push(n);
      })
      _each(i, function (o) {
          for (var p = o.j; p < o.k; p++) {
            var q = p < 10 ? 0 + '' + p : p;
            var r = '01' + '/' + q + '/' + o.l;
            var s = _date.getWholeMonth(r);
            _each(s, function (t) {
              c.push(t);
            })
          }
        })
        // push the last month
      _each(h, function (u) {
        c.push(u);
      })
    }
    return c;
  },
  //== Internally used functions by the main functions above ==//
  // turns JS date day names into full length
  days: {
    Mon: 'Monday',
    Tue: 'Tuesday',
    Wed: 'Wednesday',
    Thu: 'Thursday',
    Fri: 'Friday',
    Sat: 'Saturday',
    Sun: 'Sunday'
  },
  // turns JS date month names into full length
  months: {
    Jan: 'January',
    Feb: 'February',
    Mar: 'March',
    Apr: 'April',
    May: 'May',
    Jun: 'June',
    Jul: 'July',
    Aug: 'August',
    Sep: 'September',
    Oct: 'October',
    Nov: 'November',
    Dec: 'December'
  },
  // turns js month into number
  monthNumber: {
    Jan: '01',
    Feb: '02',
    Mar: '03',
    Apr: '04',
    May: '05',
    Jun: '06',
    Jul: '07',
    Aug: '08',
    Sep: '09',
    Oct: '10',
    Nov: '11',
    Dec: '12'
  },
  // turns days into numbers
  dayNumber: {
    Sunday: 1,
    Monday: 2,
    Tuesday: 3,
    Wednesday: 4,
    Thursday: 5,
    Friday: 6,
    Saturday: 7
  },
  // gets month length in days
  monthLength: ["VOID", 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31],
  // string of month
  monthString: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"],
  // returns an error message
  error: "Invalid date passed to _date obj, please send dates in the format of DD/MM/YYYY",
  // formats date as array of numbers
  dsplit: function (a) {
    var b = [];
    for (var c = 0; c < 3; c++) {
      b.push(Number(a.split('/')[c]));
    }
    return b;
  },
  // checks for pattern of YYYY/MM/DD
  invalid: function (a) {
    var b = new RegExp('^[0-9]{4}[/][0-9]{2}[/][0-9]{2}$');
    return b.test(a);
  },
  // internal use, checks leap year status
  isLeap: function (a) {
    var b = Number(a) + '/02/29';
    var c = new Date(b).getMonth() == 1;
    return c;
  },
  // internal use, turns date into right format
  flipDate: function (a) {
    return a.split('/')[2] + '/' + a.split('/')[1] + '/' + a.split('/')[0];
  },
  // internal use, creates sets of dates based on start and end days
  // (year, month, start, end)
  createLoop: function (a, b, c, d) {
    var e = [];
    var b = b < 10 ? 0 + '' + b : b;
    for (var f = c; f < d; f++) {
      var g = f < 10 ? 0 + "" + f : f;
      var h = a + '/' + b + '/' + g;
      var i = g + '/' + b + '/' + a;
      var j = new Date(h);
      e.push(_date.formatDate(j.toString(), i));
    }
    return e;
  },
  // formats date output
  // (jsdate, stringdate)
  formatDate: function (a, b) {
    var c = Number(a.split(' ')[2]);
    var d = Number(a.split(' ')[2]);
    var e = _date.days[a.split(' ')[0]];
    var f = _date.months[a.split(' ')[1]];
    var g = a.split(' ')[3];
    var h = d == 1 || d == 21 || d == 31 ? 'st' : d == 2 || d == 22 ? 'nd' : d == 3 || d == 23 ? 'rd' : 'th';
    var i = b ? b : 'none'
    // format your _date objects here!
    return {
      Day: e,
      Date: c + h,
      Month: f,
      Year: g,
      Id: i,
      Today: false,
      DateSpecial: c,
      Total: 0
    }
  },
  // convert js date to string
  convertDate: function(a) {
    var string = a.toString();
    var day = string.split(' ')[2];
    var month = _date.monthNumber[string.split(' ')[1]];
    var year = string.split(' ')[3];
    return day + '/' + month + '/' + year;
  }
}