$(document).ready(function() {
    /*payment type switch button script*/
   $('.init').addClass('active');
  
   $('.payment-type').on('change',function(){
      
      var $this = $(this);
      var id = $this.attr('id');
     if(id == "external"){
      $('#payment-box').fadeOut('slow');
     }else{
      $('#payment-box').fadeIn('slow');
     }
      $.post('payment_type',{'payment': $this.val()},function(data){}); 
   });
    
   $('#current').parent().find('.keys').css('display','block');  
  
  $('.theButton').on('click',function(){
   var $this = $(this);
   $('.keys').css('display','none');
   $this.parent().find('.keys').fadeIn('fast');
  
   });
  
   $('.payment').on('change',function(){
    var $this = $(this);
    $('.theButton').removeClass('active');
    $this.parent().parent().find('.theButton').addClass('active');
    $('.keys').css('display','none');
    $this.parent().find('.keys').fadeIn('fast');
   });   

});