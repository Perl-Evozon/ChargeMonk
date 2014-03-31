$(document).ready(function() {
    $('.datepicker').datepicker();
});

function goBack(){
    window.history.go(-1)
}

function refresh_select2() {
    $('select').select2();

    // initialize 'select' with first option when nothing is selected
    $('.select2-container a span').each(function() {
        if ( $(this).text() == '') {
            $(this).text( $(this).parent().parent().parent().find('select option:first').text() );
        }
    });
};

