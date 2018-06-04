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
//= require turbolinks
//= require_tree .

$(document).on("mouseover", ".previewable_card_name", function() {
  var preview_link = $(this).data("preview-link");
  $(this).closest(".decklist").find(".card_picture_cell").hide();
  $(this).closest(".decklist").find(".card_picture_cell[data-preview='"+preview_link.replace("'", "\\'")+"']").show();
})

$(document).on("scroll", function() {
  for (let preview of $(".picture_preview_column .picture_preview_box")) {
    let parent = $(preview).closest(".picture_preview_column");
    let min_rel = 0;
    let max_rel = parent.height() - $(preview).height();
    let top = $(document).scrollTop() - parent.offset().top + 10;
    // Math.clamp in future js
    top = Math.min(Math.max(top, min_rel), max_rel);
    $(preview).css({ top: top });
  }
})
