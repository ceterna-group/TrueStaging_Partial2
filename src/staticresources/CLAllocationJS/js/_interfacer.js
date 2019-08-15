// call remoting with an action and optional obj to pass through
var _apex = function (action, obj) {
  // form of a promise
  return new Promise(function (success, fail) {
    // if action is 'NA' skip remoting, used for local dev
    if (action == 'NA') {
      return success('')
    }
    // if there is an obj, pass it, else dont
    if (obj) {
      Visualforce.remoting.Manager.invokeAction(action, obj, function (res) {
        if (res == 'Error') {
          _log(action + ' failed', 'err');
          return fail();
        }
        success(res);
      })
    } else {
      Visualforce.remoting.Manager.invokeAction(action, function (res) {
        if (res == 'Error') {
          _log(action + ' failed', 'err');
          return fail();
        }
        success(res);
      })
    }
  })
}

// this allows for an interface between the back-end and the front-end
// must be added within an open script tag on the VF page in order to 
// access the visualforce object
var interfacer = {
  // called from the front-end, sets the back-end data to the objects in data.js
  get_data: function () {
    return new Promise(function (success, fail) {
      _apex('NA').then(function (projects) {
        // db_projects = projects;
        success();
      }).catch(function () {
        fail('PM_LOAD_SOMETHING');
      })
    })
  },
  // called from the front-end, sends the back-end data it needs to upload
  set_data: function (updateCreate, deletes) {
    return new Promise(function (success, fail) {
      _apex('NA', updateCreate).then(function () {
        _apex('NA', deletes).then(function () {
          return success();
        }).catch(function () {
          fail('PM_SAVE_DELETES');
        })
      }).catch(function () {
        fail('PM_SAVE_UPDATES');
      })
    })
  }
}