 $(document).ready(function(){         
      $("#addUpgrade").click(function (event) {
              event.preventDefault();
	      
              
              $('#available').find("option:selected").each(function(){
              var size=$('#available1 option').size();
              if(size ==4){
              $("#warning").fadeIn("slow");
              }
              else{   
		$('#available1').append('<option value="'+$(this).val()+'"> '+ $(this).text()+'</option>');
                $('#available option[value='.concat($(this).val()).concat(']')).remove();
              }
              });     
                
          
        })
    $("#removeUpgrade").click(function (event) {
              event.preventDefault();
	      $('#available1').find("option:selected").each(function(){
		$('#available').append('<option value="'+$(this).val()+'"> '+ $(this).text()+'</option>');});
	      $('#available1').find("option:selected").each(function(){
	         $(this).remove();
		});
	  
          
        })
	 	
	$("#warning").click(function (event){
	event.preventDefault();
	$("#warning").fadeOut("slow");
	});
        $("#success").click(function (event){
	event.preventDefault();
	$("#success").fadeOut("slow");
	});
 

      $('#editFeatured').submit(function(event) {
        
         $('#available1 option').prop('selected',true);
      
    });

    
  });