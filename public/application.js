$(document).ready(function() {
  id = $('#id').val();
  $('#up').click(function() {
    $.post('/' + id, { rating: 1 }, function(rating) {
      $('#rating').html(rating);      
    });
    return false;
  });
  $('#down').click(function() {
    $.post('/' + id, { rating: 0 }, function(rating) {
      $('#rating').html(rating);
    });    
    return false;    
  }); 
  $('#img').imgscale({ 
      scale: 'fill',
      parent : 'body'
  });
});