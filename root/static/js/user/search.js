function printState(state,index){
     switch(index){
     case 1:print_state(state,238);break;
     case 2:print_state(state,236);break;                                  
     default:print_state(state,index-3);
     }                              
  
     var elSel = document.getElementById('state');
     
       var elOptNew = document.createElement('option');
       elOptNew.text = 'any';
       elOptNew.value = '';
       var elOptOld = elSel.options[0];  
       try {
         elSel.add(elOptNew, elOptOld); // standards compliant; doesn't work in IE
       }
       catch(ex) {
         elSel.add(elOptNew, 0); // IE only
       }
      
       elSel.options[0].selected = true;

}   

$(document).ready(function(){
     var ele = document.getElementById("toggleText");
     var text = document.getElementById("displayText");
     
     if($.cookie('search_toggle') == '1'){
           $('#toggleText').css('display','block');
           $('#displayText').text('Hide advanced');
        }
     else{
            $('#toggleText').css('display','none'); 
            $('#displayText').text('Advanced');
       }
     
     $('#displayText').on('click',function(){     
      
       if($.cookie('search_toggle') == '1'){
           $('#toggleText').css('display','none');
           $(this).text('Advanced');
            $.cookie('search_toggle', '0', { expires: 14 });
       }
       else{
           $('#toggleText').css('display','block');
           $.cookie('search_toggle', '1', { expires: 14 });
          $(this).text('Hide advanced');
       }
     
        return false;     
     });
     
     var toggle = $.cookie('search_toggle');     
     
   
 $('#start_date').change(function(event) { 
    var time = $('#start_date').val(); 
    var date = new Date(time).format("mmmm dd,yyyy");    
    $('#start_date').val(date);
    $('.start_date').val(new Date(time).format("mm/dd/yyyy")); 
});

 $('#end_date').change(function(event) {       
    var time = $('#end_date').val(); 
    var date = new Date(time).format("mmmm dd,yyyy");    
    $('#end_date').val(date);
    $('.end_date').val(new Date(time).format("mm/dd/yyyy")); 
  });

 $("#start").click(function(){
     $("#start_date").val('');
    $(".start_date").val('');
    });

 $("#end").click(function(){     
    $("#end_date").val('');
    $(".end_date").val('');
 });    

})

