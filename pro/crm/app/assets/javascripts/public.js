// # Place all the behaviors and hooks related to the matching controller here.
// # All this logic will automatically be available in application.js.
// # You can use CoffeeScript in this file: http://coffeescript.org/

//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require lodash-2.4.1.min.js
//= require bootstrap-datepicker
//= require map-highlight
//= require bootstrap-slider-new

jQuery(document).on('ready page:change',function(){
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
});
