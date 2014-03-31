var error = false;

var cssObj = {
      'color' : 'red',
      'margin-bottom' : '10px'
    };

$(document).ready(function(){   
        
      $('.validated').on('submit',function(){
        $('.error').remove();
        var $this = $(this);
        $this.find('.required').each(function(){
            var $field = $(this);
            var val = $field.val();
            if(!$field.val()){
               error = true;
               var $template = $("<div></div>");
               var $temp = $("<label class='error' style='display:none'>this field is required</label>");
              
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
        
    });    
    $('.validated_modal').on('hide',function(){
      $('.error').remove();
      var $this = $(this);     
      $this.find('.required').each(function(){
            var $field = $(this);
            var val = $field.val();
            if(!$field.val()){
               error = true;
               var $template = $("<p></p>");
               var $temp = $("<label class='error' style='display:none'>this field is required</label>");
              
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
            $this.modal('show');
            return false;
        }        
    });    
});