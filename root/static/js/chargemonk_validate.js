$(document).ready(function() {
    $('input[class=only_digits_allowed]').on('keydown', function(event) {
        if ( (event.which < 48 || event.which > 57) && ( event.which != 8) && ( event.which != 46) && ( event.which != 9) && ( event.which != 37) && ( event.which != 39) && ( event.which != 13) ) {
            //only digits, backspace, del, tab, arrow left, arrow right, enter chars allowed
            return false;
        }
    });
});
