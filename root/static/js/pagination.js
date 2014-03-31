$(document).ready(function(){  
    
$('table.paginated').each(function() {
    
       
    var currentPage = 0;
    var numPerPage = 10;   
        
    if ((screen.width<=1400) && (screen.height<=900)) {
        numPerPage = 7;
    }
    
    var $table = $(this);
    
    $table.bind('repaginate', function() {
        $table.find('tbody tr').hide().slice(currentPage * numPerPage, (currentPage + 1) * numPerPage).show();
          $('.page-number').removeClass('active');
          $('#'+currentPage).addClass('active');
          $('.disable').click(function(event){
            event.preventDefault();
            });
          if(currentPage < numPages-1 )
             $('#last').removeClass("disabled");
             else
             $('#last').addClass("disabled");
            if(currentPage > 0 )
             $('#first').removeClass("disabled");
             else
             $('#first').addClass("disabled");
    });
    
    $table.trigger('repaginate');
    var numRows = $table.find('tbody tr').length;
    var numPages = Math.ceil(numRows / numPerPage);
    var $pager = $('.pagination');
    $pager.html('<ul id="pages"></ul>');
    $('#pages').append('<li class="disabled" id="first"><a href="#" id="back" class="disable">&laquo;</a></li>');
    
    $('#back').bind('click',function(event){
        if(currentPage>0)
            currentPage--; 
            $table.trigger('repaginate');
        });
  
    for (var page = 0; page < numPages; page++) {
        var string = '<li class="page-number" id="'+parseInt(page)+'"></li>'; 
         $('#pages').append(string);
      
       string = '#'+page;
       var $li = $(string);
        $('<a class="disable" href="#"></a>').text(page + 1).bind('click', {
            newPage: page
        }, function(event) {
            currentPage = event.data['newPage'];
            $table.trigger('repaginate');
            $(this).parent().addClass('active').siblings().removeClass('active');
            
            
           }).appendTo($($li));
    
    }
     $('#pages').append('<li id="last"><a href="#" id="forward" class="disable">&raquo;</a></li>');
     $('#forward').bind('click',function(event){
        if(currentPage < numPages-1)
            currentPage++; 
            $table.trigger('repaginate');
        })
     $('#pages').find('li.page-number:first').addClass('active');
});
});
