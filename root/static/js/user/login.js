 $(document).ready(function(){
        
        $(".span4").keydown(function(event){
          if(event.keyCode == 13){
            event.preventDefault();
            $("#button").click();
          }
        });
        
        var remember = $.cookie('remember');
        if (remember == 'true') 
        {
            var email = Aes.Ctr.decrypt($.cookie('email'),"secret",256);
            var password = Aes.Ctr.decrypt($.cookie('password'),"secret" , 256);
            
            // autofill the fields
            $('#mail').val(email);
            $('#pass').val(password);
            $('#remember').attr("checked",true);
        }else{
            $('#remember').attr("checked",false);
        }
        
        $("#login_form").submit(function(){
          if($("#remember").attr("checked")){           
         
            var email = Aes.Ctr.encrypt($('#mail').val(),"secret" , 256);
            var password =  Aes.Ctr.encrypt($('#pass').val(),"secret" , 256);
               
            // set cookies to expire in 14 days
            $.cookie('email', email, { expires: 14 });
            $.cookie('password', password, { expires: 14 });
            $.cookie('remember', true, { expires: 14 });                
        }
        else
        {
            // reset cookies
            $.removeCookie('email');
            $.removeCookie('password');
            $.removeCookie('remember');
        }                            
       });
    });