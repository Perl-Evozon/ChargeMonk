function ddldis()
{
    document.getElementById('ddl').disabled=true;
}
$(document).ready(function(){
            
    $('.dec').on('click',function(){
	var $this = $(this);
	var $target = $('#'+$this.attr('target'));
	var value = $target.val();
	if(value > 0){
	    value --;
	}
	$target.val(value);
	return false;
    });
    $('.inc').on('click',function(){
	var $this = $(this);
	var $target = $('#'+$this.attr('target'));
	var value = $target.val();
	value ++;
	$target.val(value);
	return false;
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
	
	$("#dismiss").click(function (event){
	event.preventDefault();
	$("#warning").fadeOut("slow");
	});
	
	$("#addActive").click(function (event) {
              event.preventDefault();
	    
	      $('#selectedFeatures').find("option:selected").each(function(){
	       $('#activeFeatures option[value='.concat($(this).val()).concat(']')).remove();
	      var size=$('#activeFeatures option').size();
	      if(size == 5){
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
	
	
		
    
      $('#editForm').submit(function(event) {
	
      $('#downgradableTo option').prop('selected',true);
      $('#upgradeableTo option').prop('selected',true);
      $('#activeFeatures option').prop('selected',true);
      $('#selectedFeatures option').prop('selected',true);
      $('#upgrade11 option').prop('selected',true);
      $('#downgrade11 option').prop('selected',true);
      
    });
      
      
    $('#datepicker').change(function(event) {
	var time = $('#datepicker').val(); 
	var date = new Date(time).format("mmmm dd,yyyy");    
	$('#datepicker').val(date);
	$('#copy').val(new Date(time).format("yyyy-mm-dd"));
	});
     $('#datepicker1').change(function(event) {
	var time = $('#datepicker1').val(); 
	var date = new Date(time).format("mmmm dd,yyyy");    
	$('#datepicker1').val(date);
	$('#copy1').val(new Date(time).format("yyyy-mm-dd"));
	});
     $('.bool').on('change',function(){
      var $this = $(this);
      if($this.val() == 1){
	   $this.val(0);
	   $this.attr('checked',false);
	   }
      else{
	   $this.val(1);	  
	   $this.attr('checked',true);
      }
      });
  });