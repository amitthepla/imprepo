// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs
//= require jquery-ui.min
//= require jquery.ui.touch-punch.js
//= require lodash-2.4.1.min.js
//= require jquery.animateNumber.min.js
//= require highcharts
//= require highcharts/highcharts-more
//= require jquery.kinetic
//= require notify
//= require nprogress
//= require select2.full.min
//= require moment.min
//= require fullcalendar.min
//= require papaparse
//= require tinymce
//= require bootstrap
//= require bootstrap-switch
//= require_tree .

jQuery(document).on('page:fetch ajaxStart',   function() { NProgress.start();  });
jQuery(document).on('page:receive', function() { NProgress.set(0.7); });
jQuery(document).on('page:change ajaxStop',  function() { NProgress.done();   });
jQuery(document).on('page:restore', function() { NProgress.remove(); });


var loaded = function(){

  $('.search-btn').on('click',function(){
    console.log("i got clicked");
    $('.search-page').addClass('is-visible');
    $('.page-content').addClass('search-is-visible');
  });

  $('.close-search').on('click',function(){
    $('.search-page').removeClass('is-visible');
    $('.page-content').removeClass('search-is-visible');
  });

  $('.js-select-field[data="height-feet"], .js-select-field[data="height-inches"]').on('change keyup',function(e){
    var feet = $('[data="height-feet"]').val(),
      inches = $('[data="height-inches"]').val();
      $('#height').val(feet+'\''+inches);
  });

  $('.js-select-field[data="bra-bust"], .js-select-field[data="bra-cup"]').on('change keyup',function(e){
    var bust = $('[data="bra-bust"]').val(),
      cup = $('[data="bra-cup"]').val();
      $('#bra').val(bust+cup);
  });

  $('.js-select-field[data="pregnancy-month"], .js-input-field[data="pregnancy-year"]').on('change keyup',function(e){
    var month = $('[data="pregnancy-month"]').val(),
      year = $('[data="pregnancy-year"]').val();
      $('#pregnancy_date').val(month+'/'+year);
  });

  $('.js-select-field[data="procedure-month"], .js-input-field[data="procedure-year"]').on('change keyup',function(e){
    var month = $('[data="procedure-month"]').val(),
      year = $('[data="procedure-year"]').val();
      $('#procedure').val(month+'/'+year);
  });
    console.log("searching");


  $('.js-search').on('keyup',function(){
    $('.search-page').addClass('is-visible');
    $('.page-content').addClass('search-is-visible');
    console.log("search page is active");
    if (window.location.pathname.split("/").length > 2) {
         var searchUrl = "/leads/search.json"
       }
    else {
         var searchUrl = $(this).data('path');
       }
    console.log(searchUrl);
    var searchVal = $(this).val();
    if(searchVal.length > 2) {
  		var filter = /[-+()\/]/
      if (filter.test(searchVal)) {
  			searchVal = searchVal.replace(/[-+()\/]/g, '')
  		}
  		else {
  			searchVal = searchVal
		  }
      $('#search-results').html('');
      $.ajax({
        type: "GET",
        dataType: 'json',
        data: {term: searchVal },
        url: searchUrl,
      }).done(function( data ) {
        html = '<table id="results" class="table table-striped table-bordered"><thead style="background-color:#F9F9F9;"><tr><th><h5>Name</h5></th><th><h5>Inquired On</h5></th><th><h5>Stage</h5></th></tr></thead><tfoot style="background-color:#F9F9F9;"><tr><th><h5>Name</h5></th><th><h5>Inquired On</h5></th><th><h5>Stage</h5></th></tr></tfoot><tbody>'
        $.each(data, function( key, value ) {
          html += '<tr><td><a class="lead-link" href="/leads/'+value["lead_id"]+'">'+value["first_name"]+' '+value["last_name"]+'</a></td><td>'+ value["date"] + '</td><td>'+ value["lead_stage"] + '</td></tr>'
        });
        html += '</tbody></table>'
        if(html === '') {
          html += 'No results.'
        }
        $('#search-results').html(html);
        $("#results").DataTable({
          "paging":   false,
          "bFilter": false,
          scrollY: '50vh',
          scrollCollapse: true
        });
      });
    }
  });
};

jQuery(document).on('page:load ready turbolinks:load', loaded);


function formatBytes(bytes, decimals) {
    if (bytes == 0) return '0 KB';
    var k = 1024; // or 1024 for binary
    var sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
    var i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(decimals)) + ' ' + sizes[i];
}
