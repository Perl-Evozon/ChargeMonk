 $(document).ready(function(){
    
    $("#contactUs").on('click',function(){
      $(".response").remove();
      var $message = $("<div class='alert alert-success response' style='display: none; width:230px'>" + 
                       "<a class='close' data-dismiss='alert'>×</a><p id='message'></p></div>");
      $(this).parent().append($message);
      
      $.post("/contact", $('#contact').serialize(), function(data){
        console.log(data.message);
        $("#message").text(data.message);
        $(".response").fadeIn('slow');
        
      }, "json");
      
      

      return false;
      
      });
    
    });    