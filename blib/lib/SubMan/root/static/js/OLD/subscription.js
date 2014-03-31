$(document).ready(function() {
    $('.carousel').carousel({ interval: 5000 });
    $('.modal').css({
        width: 'auto',
        'margin-left': function () {
            return -($(this).width() / 2);
        }
    });
    
    $.extend($.fn.datepicker.defaults, {
      parse: function (string) {
        var matches;
        if ((matches = string.match(/^(\d{2,2})\/(\d{2,2})\/(\d{4,4})$/))) {
          return new Date(matches[3], matches[1] - 1, matches[2]);
        } else {
          return null;
        }
      },
      format: function (date) {
        var
          month = (date.getMonth() + 1).toString(),
          dom = date.getDate().toString();
        if (month.length === 1) {
          month = "0" + month;
        }
        if (dom.length === 1) {
          dom = "0" + dom;
        }
        return month + "/" + dom + "/" + date.getFullYear();
      }
    });
    
    $('.tooltips').tooltip();
    $("a[rel=popover]").popover();
    $("a[rel=popover]").on("click",function(){
        return false;
        });
    // Character counter for form fields.
    $(".char-count").charCount({
        allowed: 200,
        warning: 200,
        counterText: 'Characters left: '
    });
});