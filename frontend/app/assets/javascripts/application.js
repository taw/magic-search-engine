// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
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

function onLoad() {
  $(document).on("mouseover", ".previewable_card_name", function() {
    var preview_link = $(this).data("preview-link");
    $(this).closest(".decklist").find(".card_picture_cell").hide();
    $(this).closest(".decklist").find(".card_picture_cell[data-preview='"+preview_link+"']").show();
  })

  $(".pack_selection select").select2();

  if(!('ontouchstart' in document.documentElement) && (document.location.hash === "")) {
    document.getElementById("q").focus();
  }

  $('#deck_upload').on('change', function(){
    var fileName = $(this).val().split("\\").pop();
    $(this).next('.custom-file-label').html(fileName);
    $(this).closest("form").submit();
  })

  // Deck export dialog. One request per format anyone actually looks at:
  // opening it asks for the format the radios start on, and picking another
  // asks for that one. A page which never opens the dialog costs nothing.
  var deckExport = null;

  function loadDeckExport() {
    var params = $("#deck_export_form").serialize();
    var pasted = $("[name=deck]").val();
    if (pasted !== undefined) {
      params += "&deck=" + encodeURIComponent(pasted);
    }
    $.post("/deck/export", params, function(data) {
      deckExport = data;
      $("#deck_export_preview").val(data.text);
      var warnings = $(".deck_export_warnings").empty();
      $.each(data.warnings, function(i, warning) {
        warnings.append($("<div>").text(warning));
      });
      warnings.toggle(data.warnings.length > 0);
    });
  }

  $("#deck_export").on("show.bs.modal", loadDeckExport);

  $("#deck_export_form").on("change", "input[name=format]", function() {
    loadDeckExport();
    if ($("#deck_export_remember").prop("checked")) {
      $.cookie("default_deck_export", this.value);
    }
  })

  $("#deck_export_remember").on("change", function() {
    if (this.checked) {
      $.cookie("default_deck_export", $("input[name=format]:checked").val());
    }
  })

  // Selecting the text is the feedback that something happened, and it is what
  // the copy acts on
  $("#deck_export_copy").on("click", function() {
    $("#deck_export_preview").select();
    document.execCommand("copy");
  })

  $("#deck_export_download").on("click", function() {
    if (!deckExport) return;
    var link = document.createElement("a");
    link.href = URL.createObjectURL(new Blob([deckExport.text], {type: "text/plain"}));
    link.download = deckExport.filename;
    link.click();
    URL.revokeObjectURL(link.href);
  })

  // Settings. Each radio group on the settings page is one cookie, named after
  // the group, so a new setting is a new group in the view and nothing here.
  // A group with no cookie keeps whatever the page marked checked.
  $(".settings input[type=radio]").each(function() {
    var saved = $.cookie(this.name);
    if (saved !== undefined) {
      $(this).prop("checked", saved === this.value);
    }
  })
  $(".settings").on("input", "input[type=radio]", function(e) {
    $.cookie(e.target.name, e.target.value);
  })
}

document.addEventListener("load", onLoad)
document.addEventListener("turbolinks:load", onLoad)
