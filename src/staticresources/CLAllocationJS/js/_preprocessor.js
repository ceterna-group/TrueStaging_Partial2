// due to VF page creation restrictions, some vue attributes cannot be used
// within the VF page itself, e.g. v-on:click and v-bind:class are not accepted.

// To get around this, this preprocessor is called in the vue lifecycle stage of beforeCompile
// so you can add the attributes to your html before it initializes the DOM

// Also set the svg paths so our html isn't ridiculous, no alternative if you want cached SVGs that you can dynamically change the colours of!

var preprocessor = {
  process: function() {
    // set svg paths
    _el('svg-truck1').setAttribute('d', 'm81.4 46.4l-7.8-7.8c-0.4-0.4-0.9-0.6-1.4-0.6h-8.2c-1.1 0-2 0.9-2 2v16c0 0.7 0.7 1.2 1.4 0.9 1.4-0.6 3-0.9 4.6-0.9 4.5 0 8.4 2.5 10.5 6.2 0.3 0.5 1 0.7 1.5 0.3 1.2-1.1 2-2.7 2-4.5v-10.2c0-0.5-0.2-1-0.6-1.4z');
    _el('svg-truck2').setAttribute('d', 'm54 29h-34c-1.1 0-2 0.9-2 2v27c0 1.8 0.8 3.4 2 4.5 0.5 0.4 1.2 0.3 1.5-0.3 2-3.7 6-6.2 10.5-6.2 5 0 9.2 3 11.1 7.4 0.2 0.4 0.5 0.6 0.9 0.6h6c3.3 0 6-2.7 6-6v-27c0-1.1-0.9-2-2-2z');
    _el('svg-time').setAttribute('d', 'm26 2c-13.2 0-24 10.8-24 24s10.8 24 24 24 24-10.8 24-24-10.8-24-24-24z m0 42c-9.9 0-18-8.1-18-18s8.1-18 18-18 18 8.1 18 18-8.1 18-18 18z m3.4-17.8c-0.3-0.3-0.4-0.7-0.4-1.1v-9.6c0-0.8-0.7-1.5-1.5-1.5h-3c-0.8 0-1.5 0.7-1.5 1.5v12.1c0 0.4 0.2 0.8 0.4 1.1l7.4 7.4c0.6 0.6 1.5 0.6 2.1 0l2.1-2.1c0.6-0.6 0.6-1.5 0-2.1l-5.6-5.7z');
    _el('svg-close').setAttribute('d', 'm31 25.4l13-13.1c0.6-0.6 0.6-1.5 0-2.1l-2-2.1c-0.6-0.6-1.5-0.6-2.1 0l-13.1 13.1c-0.4 0.4-1 0.4-1.4 0l-13.1-13.2c-0.6-0.6-1.5-0.6-2.1 0l-2.1 2.1c-0.6 0.6-0.6 1.5 0 2.1l13.1 13.1c0.4 0.4 0.4 1 0 1.4l-13.2 13.2c-0.6 0.6-0.6 1.5 0 2.1l2.1 2.1c0.6 0.6 1.5 0.6 2.1 0l13.1-13.1c0.4-0.4 1-0.4 1.4 0l13.1 13.1c0.6 0.6 1.5 0.6 2.1 0l2.1-2.1c0.6-0.6 0.6-1.5 0-2.1l-13-13.1c-0.4-0.4-0.4-1 0-1.4z');
    // set v-attributes
    _el('control-reset').setAttribute('v-on:click.stop', "search_query = ''");
    _el('crew-reset').setAttribute('v-on:click.stop', "crewquery = ''");
    _el('control-save').setAttribute(':disabled', '!dirty');
    _el('elser').setAttribute('v-else', '');
    _el('control-save').setAttribute('v-on:click', 'save_changes()');
    /*
    _each(_els('project-specials'), function(b) {
      b.setAttribute('v-on:click', 'search_query = proj.month')
    });*/
    _each(_els('mini-reset'), function(c) {
      c.setAttribute('v-on:click.stop', "time.start_date = time.ghost_start_date, time.end_date = time.ghost_end_date, time.edited = false, reset_gantts(), check_dirty(), picker_show = false")
    });
    _each(_els('time-rows-start'), function(d) {
      d.setAttribute('v-on:click.stop', "set_date(time, time.start_date, time.ghost_start_date, 'start')")
    });
    _each(_els('time-rows-end'), function(e) {
      e.setAttribute('v-on:click.stop', "set_date(time, time.end_date, time.ghost_end_date, 'end')")
    });
    _each(_els('project-times'), function(i) {
      i.setAttribute('v-bind:class', "{ 'collapse': time.gantt_width == '0px' }")
    });
    _each(_els('project-time-slot'), function(j) {
      j.setAttribute('v-on:click.stop', "select_slot(slot)")
    });
    _each(_els('overlay'), function(a) {
      a.setAttribute('v-on:click', "slot_edit = false, deselect_timeslots()")
    });
    _each(_els('project-row'), function(a) {
      a.setAttribute('v-on:click.stop', "deselect_projs(), proj.selected_row = 'selected_row'");
    });

    //TIAGO MENDES
    _each(_els('project-time-slot'), function (j) {
      j.setAttribute('v-on:drag', "drag(slot)");
    });
    _each(_els('project-time-slot'), function (j) {
      j.setAttribute('v-on:drop', "drop(slot)");
    });
    _each(_els('project-time-wrapper'), function (j) {
      j.setAttribute('v-on:click.stop', "select_slot(slot)")
    });
    //END TIAGO MENDES

    _els('editor-close')[0].setAttribute('v-on:click',"slot_edit = false, deselect_timeslots(), save_changes()");
    _els('editor-slots')[0].setAttribute('v-on:click',"deselect_timeslots()");
    _els('slots-create')[0].setAttribute('v-on:click',"create_slot()");
    _els('editor-timeslot')[0].setAttribute('v-on:click.stop',"select_timeslot(timeslot)");
    _els('editor-btn-delete')[0].setAttribute('v-on:click',"delete_slot(timeslot)");
    _els('editor-btn-remove')[0].setAttribute('v-on:click',"remove_crew(timeslot, crew.staffId)");
    _els('crew-assign')[0].setAttribute('v-on:click',"add_crew(staff)");
    _els('editor-btn-painter')[0].setAttribute('v-on:click',"crewquery = 'Painter'");
    _els('editor-btn-crewchief')[0].setAttribute('v-on:click',"crewquery = 'CrewChief'");
    _els('editor-btn-carpenter')[0].setAttribute('v-on:click',"crewquery = 'Carpenter'");
    _els('editor-btn-labourer')[0].setAttribute('v-on:click',"crewquery = 'Labourer'");
    _els('editor-btn-fabricator')[0].setAttribute('v-on:click',"crewquery = 'Fabricator'");
    _els('editor-btn-all')[0].setAttribute('v-on:click',"crewquery = ''");
    // finished
    return _log('Preprocessor complete.');
  }
}