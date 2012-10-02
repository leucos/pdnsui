/*
$(document).ready(function(){
  $("#cg-recordname").keyup(function(e){
    $.ajax({
      url: window.location.origin + "/records/find/" + $("#in-recordname").val(),
      dataType: 'json',
      success: function(result){
        console.log(result);
        if(result.user != null){
          $("#cg-recordname").removeClass("success");
          $("#cg-recordname").addClass("warning");
          $("#cg-recordhelp").html("A record entry of type " + + " already exists");
        }
        else{
          $("#cg-recordname").removeClass("warning");
          $("#cg-recordname").addClass("success");
          $("#cg-recordhelp").html("Username available.");
        }
      }
    });
  });
*/

  $('#search').typeahead({
    items: 15,
    matcher: function(arg) {
      return true;
    },
    updater:function (item) {
        item = item.replace(/^.*\[/,'');
        item = item.replace(/\].*$/,'');

        location.href = "/records/" + item;

        return item;
    },
    onselect: function(obj) {
      console.log("In onselect");
      console.log(obj);
    },
    source: function(query, process) {
      if ($("#search").val().length < 3) {
       return;
      }
      console.log(window.location.origin + "/api/records/search/" + query.replace(/ /g,'/'));

      $.ajax({
        url: window.location.origin + "/api/records/search/" + query.replace(/ /g,'/'),
        dataType: 'json',
        type: 'POST',
        data: 'limit=15',
        success: function(data){
          console.log(data);

          var return_list = [], i = data.length;
          while (i--) {
            //return_list[i] = {  id: data[i].id,
            //                    value: data[i].name + ' ' + data[i].type + ':' + data[i].content };
            // return_list[i] = data[i].name;
            return_list[i] =  data[i].name + " (" + data[i].type + ") [" + data[i].id + "]";
            //return_list[i] = "<a class=\"search-result\" href=\"/records/" + data[i].id + "\">" + data[i].name + "</a>";
          }
          process(return_list);
        }
      });
    }
  });

});
