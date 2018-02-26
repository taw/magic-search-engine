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
//= require jquery
//= require jquery_ujs
//= require popper
//= require bootstrap-sprockets
//= require_tree .

$(document).on("mouseover", ".previewable_card_name", function() {
  var preview_link = $(this).data("preview-link");
  $(this).closest(".decklist").find(".card_picture_cell").hide();
  $(this).closest(".decklist").find(".card_picture_cell[data-preview='"+preview_link+"']").show();
})
