 function toggle() {
        var ele = document.getElementById("toggleText");
        var text = document.getElementById("displayText");
        if(ele.style.display == "block") {
              ele.style.display = "none";
        } else {
          ele.style.display = "block";
        } 
      }
      
      function ddldis() {
        document.getElementById('ddl').disabled=true;
      }
$(document).ready(function(){
    $("#submitForm").validate();    
         
     $("#cost").keydown(function(event){
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

    $("#dismiss").click(function (event){
	event.preventDefault();
	$("#warning").fadeOut("slow");
	});

    $("#addDowngrade").click(function (event) {
              event.preventDefault();
	      $('#downgrade1').find("option:selected").each(function(){
		$('#downgrade11').append('<option value="'+$(this).val()+'"> '+ $(this).text()+'</option>');});
	      $('#downgrade1').find("option:selected").each(function(){
	         $(this).remove();
		});
	  
          
        })
      $("#removeDowngrade").click(function (event) {
              event.preventDefault();
	      $('#downgrade11').find("option:selected").each(function(){
		$('#downgrade1').append('<option value="'+$(this).val()+'"> '+ $(this).text()+'</option>');});
	      $('#downgrade11').find("option:selected").each(function(){
	         $(this).remove();
		});
	  
          
        })
    $("#addUpgrade").click(function (event) {
              event.preventDefault();
	      $('#upgrade1').find("option:selected").each(function(){
		$('#upgrade11').append('<option value="'+$(this).val()+'"> '+ $(this).text()+'</option>');});
	      $('#upgrade1').find("option:selected").each(function(){
	         $(this).remove();
		});
	  
          
        })
    $("#removeUpgrade").click(function (event) {
              event.preventDefault();
	      $('#upgrade11').find("option:selected").each(function(){
		$('#upgrade1').append('<option value="'+$(this).val()+'"> '+ $(this).text()+'</option>');});
	      $('#upgrade11').find("option:selected").each(function(){
	         $(this).remove();
		});	           
        })
    
     	 $("#addSelected").click(function (event) {
              event.preventDefault();
	      $('#availableFeatures').find("option:selected").each(function(){
		$('#selectedFeatures').append('<option value="'+$(this).val()+'"> '+ $(this).text()+'</option>');});
	      $('#availableFeatures').find("option:selected").each(function(){
	         $(this).remove();
		});	            
        })
	 
	$("#removeSelected").click(function (event) {
              event.preventDefault();
	      $('#selectedFeatures').find("option:selected").each(function(){
		$('#availableFeatures').append('<option value="'+$(this).val()+'"> '+ $(this).text()+'</option>');});
	      $('#selectedFeatures').find("option:selected").each(function(){
	         $(this).remove();
		 var pid=$(this).val(); 
		 $('#activeFeatures option[value='.concat(pid).concat(']')).remove();
		});
	          
        })
	
	$("#addActive").click(function (event) {
              event.preventDefault();
	    
	      $('#selectedFeatures').find("option:selected").each(function(){
	       $('#activeFeatures option[value='.concat($(this).val()).concat(']')).remove();
	      var size=$('#activeFeatures option').size();
	      if(size == sizeOf){
		$("#warning").fadeIn("slow");
	      }else
	      $('#activeFeatures').append('<option value="'+$(this).val()+'"> '+ $(this).text()+'</option>');});	      
        })
	 
	$("#removeActive").click(function (event) {
              event.preventDefault();
	      $('#activeFeatures').find("option:selected").each(function(){
	         $(this).remove();
		});
        }) 
      
      $('#submitForm').submit(function(event) {
	
	$('#downgradableTo option').prop('selected',true);
	$('#upgradeableTo option').prop('selected',true);
	$('#activeFeatures option').prop('selected',true);
	$('#selectedFeatures option').prop('selected',true);
	$('#upgrade11 option').prop('selected',true);
        $('#downgrade11 option').prop('selected',true);
      });        
  });
  
  function addFeatures(){
	$('#displayed').show();
	$('#activeFeatures').html('');
	$('#features').find("option:selected").each(function(){
		$('#activeFeatures').append('<option value="'+$(this).val()+'"> '+ $(this).text()+'</option>');
		
		});
  };
