function printState(state,index){
         switch(index){
           case 1:print_state(state,238);break;
           case 2:print_state(state,236);break;                                  
           default:
                print_state(state,index-3);
          }
}
    
$(document).ready(function(){

   var height =  $('.sign-up').height()+80
 
   $('.details').height(height);
    
    $('#register-form').on('submit',function(){
   $('#terms-label').css('display','none');
      var ret = true;   
      if(!$('#terms').is(':checked')){
         $('#terms-label').fadeIn('slow');
         $('#terms').val('unselected');
         ret =  false;
      }else{
         $('#terms').val('selected');
      }
   
   $('#captcha-error').css('display','none');
   
 
     var url ='/captcha';
     var params = {challenge : $('#recaptcha_challenge_field').val(), response: $('#recaptcha_response_field').val()} ;   
         $.post(url,params,function(data){
                
                  if(data.answer == "no"){
                  $('#captcha-error').fadeIn('slow');
                   Recaptcha.reload();
                   ret = false;
                   }
                   
         });
         return ret;
         });
    
    
    $('.back').click(function(){
        parent.history.back();
        return false;
    });
         
      $('#datepicker').ready(function(){
      var time = $('#datepicker').val(); 
      var date = new Date(time).format("mmmm dd,yyyy");    
      $('#datepicker').val(date);
      });
   /*only digits on phone input*/ 
      $(".phone").keydown(function(event){
       if(event.shiftKey)
   {
        event.preventDefault();
   }
/*backspace delete tab left arrow right arrow*/
   if (event.keyCode == 46 || event.keyCode == 8 || event.keyCode == 9 || event.keyCode == 37 || event.keyCode == 39)    {
   }
   else {
        if (event.keyCode < 95) {
          if (event.keyCode < 48 || event.keyCode > 57) {
                event.preventDefault();
		return;
	  }
        }
        else {
              if (event.keyCode < 96 || event.keyCode > 105) {
                  event.preventDefault();
              return;
	      }
        }
      }
    
     });
    
          
    $('#datepicker').change(function(event) {
        var time = $('#datepicker').val(); 
        var date = new Date(time).format("mmmm dd,yyyy");    
	$('#datepicker').val(date);
	$('.copy').val(new Date(time).format("mm/dd/yyyy"));
    });
});