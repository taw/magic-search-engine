$ ->
  $('[data-toggle="tooltip"]').tooltip()

  # If you press ANY, clear everything else, then set ANY
  # If you press non-ANY, set ANY to (nothing else is checked)
  $('input[name="advanced[rarity][]"]').change ->
    if this.value == ""
      $('input[name="advanced[rarity][]"]').prop("checked", false)
      $(this).prop("checked", true)
    else
      $("#advanced_rarity_any input").prop("checked", false)
      if $('input[name="advanced[rarity][]"]:checked').length == 0
        $("#advanced_rarity_any input").prop("checked", true)

  $('input[name="advanced[set][]"]').change ->
    if this.value == ""
      $('input[name="advanced[set][]"]').prop("checked", false)
      $(this).prop("checked", true)
    else
      $("#advanced_set_any input").prop("checked", false)
      if $('input[name="advanced[set][]"]:checked').length == 0
        $("#advanced_set_any input").prop("checked", true)

  $('input[name="advanced[block][]"]').change ->
    if this.value == ""
      $('input[name="advanced[block][]"]').prop("checked", false)
      $(this).prop("checked", true)
    else
      $("#advanced_block_any input").prop("checked", false)
      if $('input[name="advanced[block][]"]:checked').length == 0
        $("#advanced_block_any input").prop("checked", true)

  # For watermark:
  # * If you click YES/NO, clear everything else
  # * If you click something specific, clear YES/NO/ANY
  $('input[name="advanced[watermark][]"]').change ->
    if this.value == ""
      $('input[name="advanced[watermark][]"]').prop("checked", false)
      $(this).prop("checked", true)
    else if this.value == "yes" or this.value == "no"
      if this.checked
        $('input[name="advanced[watermark][]"]').prop("checked", false)
        $(this).prop("checked", true)
      else
        $('input[name="advanced[watermark][]"]').prop("checked", false)
        $("#advanced_watermark_any input").prop("checked", true)
    else
      $("#advanced_watermark_any input").prop("checked", false)
      $("#advanced_watermark_yes input").prop("checked", false)
      $("#advanced_watermark_no input").prop("checked", false)
      if $('input[name="advanced[watermark][]"]:checked').length == 0
        $("#advanced_watermark_any input").prop("checked", true)
