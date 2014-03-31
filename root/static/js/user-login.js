  $(document).ready(function(){
    
    $(".span4").keydown(function(event){
      if(event.keyCode == 13){
        event.preventDefault();
		//$("#button").click();
		user_login();
      }
    });	
   });

   function user_login() {
		$('.error').remove();
        var $this = $("#login-window");
        $this.find('.required').each(function(){
            var $field = $(this);
            var val = $field.val();
            if(!$field.val()){
               error = true;
               var $template = $("<div></div>");
               var $temp = $("<label class='error' style='display:none'>"+ $field.attr('name') + " field is required</label>");

               $template.append($field.clone());
               $template.append($temp);
               $field.replaceWith($template);
            }
            });        
                var $error = $('.error');
               $error.css(cssObj);
        if(error){
            error = false;
            $('.error').fadeIn('slow');
            return false;
        }
		
        $.ajax( {
            url:  '/api/subscriptions/login',
            type: 'POST',
            data: {
                email:      $("#mail").val(),
                password:   $("#pass").val(),
                remember:   $("#remember").val()
            },
            statusCode: {
                200: function () {
                    location.replace('/');
                    return;
                },
                401: function (response) {
                    $("#login-window").html(response.responseText);
                    return;
                }
            }
        });

        return;
	}
  
