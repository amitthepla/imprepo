  var taggd, x, y, firstLoad = true;
  var options = {
    align: {
      x: 'center',
      y: 'center'
    },
    offset: {
      left: 0,
      top: 30
    },
    handlers: {
      mouseenter: 'show',
      mouseleave: 'hide'
    }
  };

  $(document).on("ready page:load load turbolinks:load",function () {
    $request = null;
    var injectionProcedure = $("#face-injection-procedure");

    //  Fancybox
    $(".fancybox").fancybox();

    // date picker
    $('.datepicker').datepicker({
      format: "mm/dd/yyyy",
      autoclose: true
    });

    $('.digg_pagination[remote=true] a').on("click", function () {
      var stage_id = getUrlParameter(this.href, "stage_id");
      if ($request != null) {
        $request.abort();
        $request = null;
      }
      $request = $.get(this.href, function (data) {
        $("#stage_" + stage_id).html(data);
      });
      return false;
    });

    injectionProcedure.click(function (e) {
      if (firstLoad) {
        return false;
      }
      var offset = $(this).offset();
      x = ((e.pageX - offset.left) / $(this).width());
      y = ((e.pageY - offset.top) / $(this).height());
      $("#modalInjectionProcedure").modal("show");
    });

    $("#btn-done").on("click", function (e) {
      e.preventDefault();
      var procedure_id = $("#procedure_id");
      var treatment_procedures = $("#treatment-procedures");
      var treatment_coordinates = $("#treatment-coordinates");
      var treatment_quantity = $("#treatment-quantity");
      var quantity = $("#quantity").val();
      var unit = $("#measurement").find("option:selected").text();
      treatment_procedures.val(treatment_procedures.val() + "," + procedure_id.val());
      treatment_coordinates.val(treatment_coordinates.val() + "&" + (x + "," + y));
      treatment_quantity.val(treatment_quantity.val() + "," + quantity + ":" + unit);
      $("#modalInjectionProcedure").modal("hide");
      taggd.addData({x: x, y: y, text: procedure_id.find("option:selected").text(), quantity: quantity, unit: unit});
      $("#quantity").val('');
      $("#measurement").val('');
    });

    $("#cancel-treatment").on("click", function (e) {
      e.preventDefault();
      $("#into-text").hide();
      $(".timeline-panel").removeClass("active-panel");
      taggd.setData([]);
      $("#new-treatment-form").hide();
      $("#treatment-form")[0].reset();
      $("#treatment-procedures").val('');
      $("#treatment-coordinates").val('');
      $("#treatment-quantity").val('');
      $("#quantity").val('');
      $("#measurement").val('');
      $("#previous-procedures").show();
    });

    $("#add-treatment").on("click", function (e) {
      e.preventDefault();
      firstLoad = false;
      $("#ip-div").css("opacity", 1);
      $("#into-text").show();
      taggd.setData([]);
      $("#previous-procedures").hide();
      $("#new-treatment-form").show();
    });

    $(".btn-treatment").on("click", function (e) {
      e.preventDefault();
      firstLoad = false;
      $("#ip-div").css("opacity", 1);
      $(".timeline-panel").removeClass("active-panel");
      $(this).next(".timeline-panel").addClass("active-panel");
      taggd.setData([]);
      var id = $(this).data("id");
      $.ajax({
        url: "/get_coordinates/" + id,
        type: 'GET',
        success: function (res) {
          $.each(JSON.parse(res.data), function (index, value) {
            taggd.addData(value);
          });

        }
      });
    });



  });

  var getUrlParameter = function getUrlParameter(url, sParam) {
    var sPageURL = decodeURIComponent(url),
        sURLVariables = sPageURL.split('&'),
        sParameterName,
        i;

    for (i = 0; i < sURLVariables.length; i++) {
      sParameterName = sURLVariables[i].split('=');

      if (sParameterName[0] === sParam) {
        return sParameterName[1] === undefined ? true : sParameterName[1];
      }
    }
  };

  function countChar(val) {
    var len = val.value.length;
    if (len >= 1600) {
      val.value = val.value.substring(0, 1600);
    } else {
      $('#charNum').text(1600 - len);
    }
  }
