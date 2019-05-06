// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery3
//= require popper
//= require bootstrap-sprockets
//= require turbolinks
//= require select2
//= require_tree .

$(function () {
  $(document).on("mouseover", ".previewable_card_name", function() {
    var preview_link = $(this).data("preview-link");
    $(this).closest(".decklist").find(".card_picture_cell").hide();
    $(this).closest(".decklist").find(".card_picture_cell[data-preview='"+preview_link+"']").show();
  })

  $(".pack_selection select").select2();

  if (!('ontouchstart' in document.documentElement) && (document.location.hash === "")) {
    document.getElementById("q").focus();
  }

  $('#deck_upload').on('change', function(){
    var fileName = $(this).val().split("\\").pop();
    $(this).next('.custom-file-label').html(fileName);
    $(this).closest("form").submit();
  })
})
