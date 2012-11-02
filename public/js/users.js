$(function() {

  // Sends the new rights order in ajax
  function send_result(element) {
    var rightsOrder = element.sortable('toArray');

    rightsOrder = $.map( rightsOrder, function(val, i) {
      return val.replace('right-','');
    });

    console.log("rights for " + element.data("user-id") + " : " + rightsOrder);
      //$.get("users/rights/" + $(this).data("user-id"), {rightOrder:rightOrder});

    console.log(element);
    //element.parent(".transient").html(rightsOrder);

    target = $("#accordion-toggle-" + element.data("user-id"));

    $.ajax({
      url: "/users/rights/" + $(this).data("user-id"),
      data: "order=" + rightsOrder,
      success: function(result) {
        target.addClass("alert-success",1000).removeClass("alert-success",1000);
      },
      error: function(result) {
        target.addClass("alert-error",1000).removeClass("alert-error",1000);
      }
    });
  }

  $(".sortable").sortable({
      placeholder: "ui-state-highlight"
  });

  $(".sortable").disableSelection();

  $( ".sortable" ).sortable({
    placeholder: "ui-state-highlight",
    update: function(event, ui) {
      send_result($(this));
    }
  });

  $(".close").click(function() {
    // Get upper ul
    var sort = $(this).parent().parent().parent();
    //Doesn't work, why ?
    //var sort = $(this).parent("ul");

    // Get parent li
    $(this).parent("li").remove();

    send_result(sort);
  });

});