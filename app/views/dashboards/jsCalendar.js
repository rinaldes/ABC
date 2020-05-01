$(function() {
  var date = new Date();
  var d = date.getDate();
  var m = date.getMonth();
  var y = date.getFullYear();

  var initDrag = function (e) {
      // create an Event Object (http://arshaw.com/fullcalendar/docs/event_data/Event_Object/)
      // it doesn't need to have a start or end

      var eventObject = {
          title: $.trim(e.children().text()), // use the element's text as the event title
          description: $.trim(e.children('span').attr('data-description')),
          icon: $.trim(e.children('span').attr('data-icon')),
          className: $.trim(e.children('span').attr('class')) // use the element's children as the event class
      };
      // store the Event Object in the DOM element so we can get to it later
      e.data('eventObject', eventObject);

      // make the event draggable using jQuery UI
      e.draggable({
          zIndex: 999,
          revert: true, // will cause the event to go back to its
          revertDuration: 0 //  original position after the drag
      });
  };

  var addEvent = function (title, priority, description, icon) {
      title = title.length === 0 ? "Untitled Event" : title;
      description = description.length === 0 ? "No Description" : description;
      icon = icon.length === 0 ? " " : icon;
      priority = priority.length === 0 ? "label label-default" : priority;

      var html = $('<li><span class="' + priority + '" data-description="' + description + '" data-icon="' +
          icon + '">' + title + '</span></li>').prependTo('ul#external-events').hide().fadeIn();

      $("#event-container").effect("highlight", 800);

      initDrag(html);
  };

  /* initialize the external events
  -----------------------------------------------------------------*/

  $('#external-events > li').each(function () {
      initDrag($(this));
  });

  $('#add-event').click(function () {
      var title = $('#title').val(),
          priority = $('input:radio[name=priority]:checked').val(),
          description = $('#description').val(),
          icon = $('input:radio[name=iconselect]:checked').val();

      addEvent(title, priority, description, icon);
  });

  $('#calendar').fullCalendar({
    header: {
        left: null,
        center: 'title',
        right: null
    },
    editable: true,
    droppable: true, // this allows things to be dropped onto the calendar !!!

    drop: function (date, allDay) { // this function is called when something is dropped
        // retrieve the dropped element's stored Event Object
        var originalEventObject = $(this).data('eventObject');

        // we need to copy it, so that multiple events don't have a reference to the same object
        var copiedEventObject = $.extend({}, originalEventObject);

        // assign it the date that was reported
        copiedEventObject.start = date;
        copiedEventObject.allDay = allDay;

        // render the event on the calendar
        // the last `true` argument determines if the event "sticks" (http://arshaw.com/fullcalendar/docs/event_rendering/renderEvent/)
        $('#calendar').fullCalendar('renderEvent', copiedEventObject, true);

        // is the "remove after drop" checkbox checked?
        if ($('#drop-remove').is(':checked')) {
            // if so, remove the element from the "Draggable Events" list
            $(this).remove();
        }

    },

    eventDrop: function(event, delta, revertFunc) {
      // Reduce end date by 1 day, as fullcalendar render it 1 day ahead
      var date_end = moment(event.end).add(-1, 'd');

      $.ajax({
        type:'POST',
        url:'/dashboards/update_todolist',
        beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
        data: { id: event.id, date: event.start.format(), end_at: date_end.format() },
        success:function(json) {
          if (!json.status)
            revertFunc();
        }
      });
    },

    eventResize: function(event, delta, revertFunc) {
      // Reduce end date by 1 day, as fullcalendar render it 1 day ahead
      var date_end = moment(event.end).add(-1, 'd');

      $.ajax({
        type:'POST',
        url:'/dashboards/update_todolist',
        beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
        data: {
          id: event.id,
          date: event.start.format(),
          end_at: date_end.format()
        },
        success:function(json) {
          if (!json.status)
            revertFunc();
        }
      });
    },

    select: function (start, end, allDay) {
        var title = prompt('Event Title:');
        if (title) {
            calendar.fullCalendar('renderEvent', {
                    title: title,
                    start: start,
                    end: end,
                    allDay: allDay
                }, true // make the event "stick"
            );
        }
        calendar.fullCalendar('unselect');
    },

    events: null,

    eventRender: function (event, element, icon) {
        if (!event.description == "") {
            element.find('.fc-event-title').append("<br/><span class='ultra-light'>" + event.description +
                "</span>");
        }
        if (!event.icon == "") {
            element.find('.fc-event-title').append("<i class='air air-top-right fa " + event.icon +
                " '></i>");
        }
    },

    windowResize: function (event, ui) {
        $('#calendar').fullCalendar('render');
    }
  });

  $('#btn-prev').click(function() {
    $('#calendar').fullCalendar('prev');
  });

  $('#btn-next').click(function() {
    $('#calendar').fullCalendar('next');
  });
});
