function reload() {
  $("#listing").children().remove();
  $.ajax({
    url: 'loadFileNames',
    dataType: 'json',
    type: 'POST',
    success: function(data) {
      $("#alerts").hide();
      $("#row").tmpl(data).appendTo('#listing');
    },
    error: function() {
      $("#errorMessage").html("Cannot get existing file names from server");
      $("#alerts").show();
    }
  });
}

$(document).ready(function() {
  reload();

  $("#reload").click(function() {
    reload();
  });

  $("#fileupload").change(function() {
    $(".progress").show();
  });
});

$(function () {
  $('#fileupload').fileupload({
    dataType: 'json',
    autoUpload: true,
    done: function (e, data) {
      if (data.result.result == "999999") {
        $("#errorMessage").html("File already exists.");
        $("#alerts").show();
        $(".progress").hide();
      } else {
        $("#alerts").hide();
        $("#row").tmpl(data.result.result).appendTo('#listing');
        $(".progress").hide();
      }
    }
  });
});