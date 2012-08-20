$(document).ready(function() {
    $("input[name=preferA]").hover(
      function() {
          $(".listA").addClass("alert").addClass("alert-info");          
      },
      function() {
          $(".listA").removeClass("alert").removeClass("alert-info");
      }
    );
    
    $("input[name=preferB]").hover(
      function() {
          $(".listB").addClass("alert").addClass("alert-info");          
      },
      function() {
          $(".listB").removeClass("alert").removeClass("alert-info");
      }
    );
});


