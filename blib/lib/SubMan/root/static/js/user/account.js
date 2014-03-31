function printState(state,index){
      switch(index){
	case 1:print_state(state,238);break;
	case 2:print_state(state,236);break;                                  
	default:
	     print_state(state,index-3);
       }
}

$(function()
     {
       $("#datepicker").datepicker();
     });

if (window.location.protocol === 'file:') {
        alert("stripe.js does not work when included in pages served over file:// URLs. Try serving this page over a webserver. Contact support@stripe.com if you need assistance.");
    }

/*variables used for the toogle product details function*/     
toogle = false; 
var before;

 
function stripeResponseHandler(status, response) {
	 if (response.error) {
	   alert(response.error);
	     // re-enable the submit button
	     $('.submit-button').removeAttr("disabled");
	     // show the errors on the form
	     $(".payment-errors").html(response.error.message);
	 } else {
	     var form$ = $("#payment-form");
	     // token contains id, last4, and card type
	     var token = response['id'];
	     // insert the token into the form so it gets submitted to the server
	     form$.append("<input type='hidden' name='stripeToken' value='" + token + "' />");
	     // Clear the credit card details so that they don't touch your servers
	     $('.card-number, .card-cvc, .card-expiry-month, .card-expiry-year').val('');
	     // and submit
	     form$.get(0).submit();
	 }
     }


$(document).ready(function(){ 
  $("#payment-form").submit(function(event) {
    // disable the submit button to prevent repeated clicks
    $('.submit-button').attr("disabled", "disabled");
    // createToken returns immediately - the supplied callback submits the form if there are no errors
    Stripe.createToken({
	number: $('.card-number').val(),
	cvc: $('.card-cvc').val(),
	exp_month: $('.card-expiry-month').val(),
	exp_year: $('.card-expiry-year').val()
    }, stripeResponseHandler);
    return false; // submit from callback
  });
 
$('.billed_products').on('click','a.product',function(){
 console.log(before);
 var $this = $(this);
 var $target = $('#'+$this.attr('target'));
 $('.info').css('display','none');
 
 if(before == $this.attr('target') ){
     if(toogle)
     {
       $target.fadeIn('slow');
       toogle=false;
     }
     else{
       toogle = true;
     }
 }else{
   $target.fadeIn('slow');
     toogle = false;
 }
before = $(this).attr('target');
 return false;
 });
 
 
 
 $('#upload_photo').on('click',function(){
  
   return false;
   })
 
 
 $('.photo').error(function(event){
	       $(this).attr('src','/assets/img/unknown-user.gif');
	 });
	 
     
    $("#button").click(function(event){      
     event.preventDefault();
     var mail = $(this).attr('param');
      $.post(
       "/send_recover_mail",
       { email: mail },
	function() {
	 $("#li").fadeIn("slow");            
	 }
	 )        
     });
     $(".tip").hover(function(){
	 $(".tip").tooltip('show');},
	 function(){
	 $(".tip").tooltip('hide');})
 
 
/*only digits on phone input*/ 
   $(".phone").keydown(function(event){
    if(event.shiftKey)
{
     event.preventDefault();
}
/*backspace delete tab left arrow right arrow*/
if (event.keyCode == 46 || event.keyCode == 8 || event.keyCode == 190 || event.keyCode == 37 || event.keyCode == 39)    {
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
 
 
 $("#close_alert").click(function(event){
   event.preventDefault();
   $("#li").fadeOut("slow");
   });
 

 
 $('#datepicker').change(function(event) {
     var time = $('#datepicker').val(); 
     var date = new Date(time).format("mmmm dd,yyyy");    
     $('#datepicker').val(date);
     $('.copy').val(new Date(time).format("mm/dd/yyyy"));
 });

 
});