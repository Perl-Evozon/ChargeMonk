$(document).ready(function(){

      $('.email').typeahead({
            source: function(typeahead,query){
                 $.post("/admin/user/list/emails",{"email": $('.email').val()},
                   function(results){
                  typeahead.process( results.source);         
                 },"json"); 
            },
            items: 5,
      });
      
   
});

