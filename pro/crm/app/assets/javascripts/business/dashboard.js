
// jQuery(document).on('ready page:change',function(){
// 	$( ".widget-list .pep" ).draggable({
// 	  appendTo: "body",
// 	  helper: "clone",
// 	  containment: ".wrapper", scroll: false
// 	});
// 	$( ".drop-zone" ).droppable({
// 	  activeClass: "ui-state-default",
// 	  hoverClass: "ui-state-hover",
// 	  accept: ":not(.ui-sortable-helper)",
// 	  drop: function( event, ui ) {
// 		var panelID = '#'+ui.draggable.data('panel');
// 		$('.panel').removeClass('is-active');
// 		$( this ).find( ".placeholder" ).remove();
// 		$('.widget-display').addClass('loading');
// 		$('.widget-display .widget-chart').html('');
// 		$(panelID).find('.js-counter').each(function(index){
// 		  $(this).text('0');
// 		});
// 		if(ui.draggable.data('secured')){
// 			$(panelID).addClass('is-blurry');
// 			showPinPanel();
// 		}
// 		setTimeout(function(){
// 		  switchTab(panelID);
// 		  var widgetType = ui.draggable.data('widget'),
// 			  widgetData = ui.draggable.data('path');
//
// 		  $('.widget-display').removeClass('loading');
// 		  $('.widget-display .widget-chart').html( ui.draggable.text() + ' Loaded' );
// 		  switch (ui.draggable.data('widget')) {
// 			case "pie":
// 				getChartData(loadPieWidget,widgetData);
// 			  break;
// 			case "line":
// 				getChartData(loadLineWidget,widgetData);
// 			  break;
// 			case "bar":
// 				getChartData(loadBarWidget,widgetData);
// 			  break;
// 			case "column":
// 				getChartData(loadColumnWidget,widgetData);
// 			  break;
// 			case "spider":
// 				getChartData(loadSpiderWidget,widgetData);
// 			  break;
// 			case "stacked":
// 				getChartData(loadStackedWidget,widgetData);
// 			  break;
// 			case "funnel":
// 				getChartData(loadFunnelWidget,widgetData);
// 			  break;
// 			default:
// 			  console.log("Sorry");
// 		  }
// 		},1000);
// 	  }
// 	});
// 	$('#content-scroller').kinetic({cursor: '-webkit-grab'});
// 	var pinCounter = 0;
// 	$('.pinPad li').on('click',function(){
// 		pinCounter++
// 		var currentVal = $('.pinInput').val();
// 		$('.pinInput').val( currentVal + $(this).text() );
// 		if(pinCounter === 4) {
// 			$.ajax({
// 			  type: "POST",
// 			  url: '/auth/pin',
// 			  data: {'code':$('.pinInput').val()},
// 			  dataType: 'json'
// 			}).done(function(){
// 				hidePinPanel();
// 			})
// 			pinCounter = 0;
// 		}
//
// 	});
//   });
//
// function showPinPanel() {
// 	$('#pinPanel').show();
// }
// function hidePinPanel() {
// 	$('#pinPanel').hide();
// 	$('.panel').removeClass('is-blurry');
// 	$('.pinInput').val('');
// }
//
// function launchFullscreen(element) {
//   if(element.requestFullscreen) {
// 	element.requestFullscreen();
//   } else if(element.mozRequestFullScreen) {
// 	element.mozRequestFullScreen();
//   } else if(element.webkitRequestFullscreen) {
// 	element.webkitRequestFullscreen();
//   } else if(element.msRequestFullscreen) {
// 	element.msRequestFullscreen();
//   }
// }
//
// jQuery(document).on('webkitfullscreenchange mozfullscreenchange fullscreenchange MSFullscreenChange',function(e){
// 	var isFullScreen = document.fullScreen || document.mozFullScreen || document.webkitIsFullScreen;
// 	if(isFullScreen){
// 		$('body').addClass('is-fullscreen')
// 	} else {
// 		$('body').removeClass('is-fullscreen');
// 	}
// });
//
// function switchTab(tab){
//   var tab = $(tab), options;
//   tab.addClass('is-active');
//   if(tab.find('.js-counter').length > 1){
// 	tab.find('.js-counter').each(function(index){
// 	  if($(this).attr('data-format')) {
// 		options = { number: $(this).attr('data-total'), numberStep: $.animateNumber.numberStepFactories.separator(',') };
// 	  } else {
// 		options = { number: $(this).attr('data-total') };
// 	  }
// 	  $(this).animateNumber(options, 2000);
// 	});
//   }
// }
//
//
// function getChartData(widget,path) {
//   $.ajax({
// 	url: path,
// 	type: 'GET',
// 	dataType: 'json',
// 	cache: false
//   }).done(function(data){
// 	var chartOptions = _.has(data[0],'options') ? data[0].options : [],
// 		chartSeries = _.has(data[1],'series') ? data[1].series : [],
// 		chartDrillDown = _.has(data[2],'drillDown') ? data[2].drillDown : []
// 	loadLineWidgetSummary(chartSeries);
// 	if(chartOptions) {
// 	  widget(chartOptions,chartSeries,chartDrillDown);
// 	} else {
// 	  widget(chartSeries);
// 	}
//
//   }).fail(function(){
// 	console.log('There was a problem');
//   });
// }
//
//  // Build the chart
// function loadPieWidget(options,data){
// 		$('.panel.is-active .widget-chart').highcharts({
// 			chart: {
// 				plotBackgroundColor: null,
// 				plotBorderWidth: null,
// 				plotShadow: false
// 			},
// 			title: {
// 				text: options[0].title
// 			},
// 			tooltip: {
// 				pointFormat: '{point.percentage:.1f}% <br/> Revenue: <b>${point.y}</b>'
// 			},
// 			plotOptions: {
// 				pie: {
// 					allowPointSelect: true,
// 					cursor: 'pointer',
// 				dataLabels: {
// 					enabled: true,
// 					format: '<b>{point.name}</b>: {point.percentage:.1f} %',
// 					style: {
// 						color: (Highcharts.theme && Highcharts.theme.contrastTextColor) || 'black'
// 					}
// 				}
// 				}
// 			},
// 			credits: {
// 			  enabled: false
// 			},
// 			series: data
// 		});
// }
//
// function loadLineWidget(options,data) {
//   $('.panel.is-active .widget-chart').highcharts({
// 		title: {
// 			text: options[0].title,
// 			x: -20 //center
// 		},
// 		subtitle: {
// 			text: options[0].subTitle,
// 			x: -20
// 		},
// 		xAxis: {
// 			categories: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
// 				'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
// 		},
// 		yAxis: {
// 			title: {
// 				text: options[0].yAxisLabel
// 			},
// 			plotLines: [{
// 				value: 0,
// 				width: 1,
// 				color: '#808080'
// 			}]
// 		},
// 		tooltip: {
// 			valueSuffix: options[0].tooltipValueSuffix
// 		},
// 		legend: {
// 			layout: 'vertical',
// 			align: 'right',
// 			verticalAlign: 'middle',
// 			borderWidth: 0
// 		},
// 		plotOptions: {
// 			series: {
// 				events: {
// 					legendItemClick: function(e) {
// 						// Upon cmd-click of a legend item, rather than toggling visibility, we want to hide all other items.
// 						var hideAllOthers = e.browserEvent.metaKey;
// 						if (hideAllOthers) {
// 							var seriesIndex = this.index;
// 							var series = this.chart.series;
//
// 							for (var i = 0; i < series.length; i++) {
// 								// rather than calling 'show()' and 'hide()' on the series', we use setVisible and then
// 								// call chart.redraw --- this is significantly faster since it involves fewer chart redraws
// 								if (series[i].index === seriesIndex) {
// 									if (!series[i].visible) series[i].setVisible(true, false);
// 								} else {
// 									if (series[i].visible) series[i].setVisible(false, false);
// 								}
// 							}
// 							this.chart.redraw();
//
//
// 							return false;
// 						}
// 					}
// 				}
// 			}
// 		  },
// 		series: data
// 	});
//
// }
//
// function loadLineWidgetSummary(data)
// {
//
//
// 	var cList = $('#income').find('ul.widget-stats-wrapper');
//
// 	cList.html("")
// 	var series_year = data;
// 	$.each(series_year, function(i)
// 	{
// 		var li = $('<li/>')
// 			.text(series_year[i]["name"] + " (Millions)")
// 			.appendTo(cList);
//
// 		var inner_ul = $('<ul/>')
// 			.appendTo(li);
// 		var inner_li = $('<li/>')
// 			.appendTo(inner_ul);
// 		var sumvalue = parseInt(series_year[i]["sum"]);
// 		var valueinmillion = (sumvalue/1000000.0).toFixed(2)
// 		var span =  $('<span/>')
// 			.addClass("js-counter")
// 			.attr("data-format","currency")
// 			.attr("data-total",series_year[i]["sum"])
// 			.text(valueinmillion)
// 			.appendTo(inner_li);
// 	});
//
// 	//$("#income").find('.widget-stats').html("");
// 	//alert( $('#income').find('ul.widget-stats-wrapper').html())
// 	$("#income").find('.widget-stats').append(cList);
// }
// function loadBarWidget(data){
//   $('.panel.is-active .widget-chart').highcharts({
// 		chart: {
// 			type: 'bar'
// 		},
// 		title: {
// 			text: 'Historic World Population by Region'
// 		},
// 		subtitle: {
// 			text: 'Source: Wikipedia.org'
// 		},
// 		xAxis: {
// 			categories: ['Africa', 'America', 'Asia', 'Europe', 'Oceania'],
// 			title: {
// 				text: null
// 			}
// 		},
// 		yAxis: {
// 			min: 0,
// 			title: {
// 				text: 'Population (millions)',
// 				align: 'high'
// 			},
// 			labels: {
// 				overflow: 'justify'
// 			}
// 		},
// 		tooltip: {
// 			valueSuffix: ' millions'
// 		},
// 		plotOptions: {
// 			bar: {
// 				dataLabels: {
// 					enabled: true
// 				}
// 			}
// 		},
//         legend: {
//             layout: 'vertical',
//             align: 'right',
//             verticalAlign: 'middle',
//             borderWidth: 0
//         },
// 		//legend: {
// 		//	layout: 'vertical',
// 		//	align: 'right',
// 		//	verticalAlign: 'top',
// 		//	x: -40,
// 		//	y: 100,
// 		//	floating: true,
// 		//	borderWidth: 1,
// 		//	backgroundColor: ((Highcharts.theme && Highcharts.theme.legendBackgroundColor) || '#FFFFFF'),
// 		//	shadow: true
// 		//},
// 		credits: {
// 			enabled: false
// 		},
// 		series: data
// 	});
// }
//
// function loadColumnWidget(options,chartData,drilldownSeries){
//   $('.panel.is-active .widget-chart').highcharts({
// 		chart: {
// 			type: 'column'
// 		},
// 		title: {
// 			text: options[0].title
// 		},
// 		subtitle: {
// 			text: options[0].subTitle
// 		},
// 		xAxis: {
// 		  categories: options[0].xAxisCategories,
// 		  type: 'category'
// 		},
// 		yAxis: {
// 			min: 0,
// 			title: {
// 				text: options[0].yAxisLabel,
// 				align: 'middle'
// 			},
// 			labels: {
// 				overflow: 'justify'
// 			},
// 			stackLabels: {
//
// 			}
// 		},
// 		plotOptions: {
// 			series: {
// 				dataLabels: {
// 					enabled: options[0].dataLabels,
// 					format: options[0].dataLabelsFormat
// 				}
// 			}
// 		},
//         //legend: {
//         //    layout: 'vertical',
//         //    align: 'right',
//         //    verticalAlign: 'middle',
//         //    borderWidth: 0
//         //},
// 		//legend: {
// 		//	layout: 'vertical',
// 		//	align: 'right',
// 		//	verticalAlign: 'top',
// 		//	x: -40,
// 		//	y: 100,
// 		//	floating: true,
// 		//	borderWidth: 1,
// 		//	backgroundColor: ((Highcharts.theme && Highcharts.theme.legendBackgroundColor) || '#FFFFFF'),
// 		//	shadow: true
// 		//},
// 		credits: {
// 			enabled: false
// 		},
// 		series: chartData,
// 		drilldown: {
// 		  series: drilldownSeries
// 		}
// 	});
// }
//
//
// function loadSpiderWidget(data){
//   $('.panel.is-active .widget-chart').highcharts({
//
// 		chart: {
// 			polar: true,
// 			type: 'line'
// 		},
//
// 		title: {
// 			text: 'Budget vs spending',
// 			x: -80
// 		},
//
// 		pane: {
// 			size: '80%'
// 		},
//
// 		xAxis: {
// 			categories: ['Sales', 'Marketing', 'Development', 'Customer Support',
// 					'Information Technology', 'Administration'],
// 			tickmarkPlacement: 'on',
// 			lineWidth: 0
// 		},
//
// 		yAxis: {
// 			gridLineInterpolation: 'polygon',
// 			lineWidth: 0,
// 			min: 0
// 		},
//
// 		tooltip: {
// 			shared: true,
// 			pointFormat: '<span style="color:{series.color}">{series.name}: <b>${point.y:,.0f}</b><br/>'
// 		},
//
// 		legend: {
// 			align: 'right',
// 			verticalAlign: 'top',
// 			y: 70,
// 			layout: 'vertical'
// 		},
//
// 		series: data
//
// 	});
// }
//
//
// function loadFunnelWidget(data) {
//   $('.panel.is-active .widget-chart').highcharts({
// 		chart: {
// 			type: 'funnel',
// 			marginRight: 100
// 		},
// 		title: {
// 			text: 'Sales funnel',
// 			x: -50
// 		},
// 		plotOptions: {
// 			series: {
// 				dataLabels: {
// 					enabled: true,
// 					format: '<b>{point.name}</b> ({point.y:,.0f})',
// 					color: (Highcharts.theme && Highcharts.theme.contrastTextColor) || 'black',
// 					softConnector: true
// 				},
// 				neckWidth: '30%',
// 				neckHeight: '25%'
//
// 				//-- Other available options
// 				// height: pixels or percent
// 				// width: pixels or percent
// 			}
// 		},
// 		legend: {
// 			enabled: false
// 		},
// 		series: data
// 	});
// }
//
// function loadStackedWidget(options,data) {
//   $('.panel.is-active .widget-chart').highcharts({
// 		chart: {
// 			type: 'column'
// 		},
// 		title: {
// 			text: options[0].title
// 		},
// 		xAxis: {
// 			categories: ['January', 'Febuary', 'March', 'April', 'May', 'June', 'July', 'August', 'September','October','November','December']
// 		},
// 		yAxis: {
// 			min: 0,
// 			title: {
// 				text: options[0].yAxisLabel
// 			},
// 			stackLabels: {
// 				enabled: false,
// 				style: {
// 					fontWeight: 'bold',
// 					color: (Highcharts.theme && Highcharts.theme.textColor) || 'gray'
// 				}
// 			}
// 		},
//
// 		tooltip: {
// 			formatter: function () {
// 				return '<b>' + this.x + '</b><br/>' +
// 					this.series.name + ': ' + this.y + '<br/>'
// 			}
// 		},
// 		plotOptions: {
// 			column: {
// 				stacking: 'normal',
// 				dataLabels: {
// 					enabled: true,
// 					color: (Highcharts.theme && Highcharts.theme.dataLabelsColor) || 'white',
// 					style: {
// 						textShadow: '0 0 3px black, 0 0 3px black'
// 					}
// 				}
// 			}
// 		},
// 		series: data
// 	});
// }
//
//
//
//
//
//
// /**
//  * Dark theme for Highcharts JS
//  * @author Torstein Honsi
//  */
//
// // Load the fonts
// Highcharts.createElement('link', {
//    href: 'https://fonts.googleapis.com/css?family=Unica+One',
//    rel: 'stylesheet',
//    type: 'text/css'
// }, null, document.getElementsByTagName('head')[0]);
//
// Highcharts.theme = {
//    colors: ["#2b908f", "#90ee7e", "#f45b5b", "#7798BF", "#aaeeee", "#ff0066", "#eeaaee",
// 	  "#55BF3B", "#DF5353", "#7798BF", "#aaeeee"],
//    chart: {
// 	  backgroundColor: {
// 		 linearGradient: { x1: 0, y1: 0, x2: 1, y2: 1 },
// 		 stops: [
// 			[0, '#2a2a2b'],
// 			[1, '#3e3e40']
// 		 ]
// 	  },
// 	  style: {
// 		 fontFamily: "sans-serif"
// 	  },
// 	  plotBorderColor: '#606063'
//    },
//    title: {
// 	  style: {
// 		 color: '#E0E0E3',
// 		 textTransform: 'uppercase',
// 		 fontSize: '20px'
// 	  }
//    },
//    subtitle: {
// 	  style: {
// 		 color: '#E0E0E3',
// 		 textTransform: 'uppercase'
// 	  }
//    },
//    xAxis: {
// 	  gridLineColor: '#707073',
// 	  labels: {
// 		 style: {
// 			color: '#E0E0E3'
// 		 }
// 	  },
// 	  lineColor: '#707073',
// 	  minorGridLineColor: '#505053',
// 	  tickColor: '#707073',
// 	  title: {
// 		 style: {
// 			color: '#A0A0A3'
//
// 		 }
// 	  }
//    },
//    yAxis: {
// 	  gridLineColor: '#707073',
// 	  labels: {
// 		 style: {
// 			color: '#E0E0E3'
// 		 }
// 	  },
// 	  lineColor: '#707073',
// 	  minorGridLineColor: '#505053',
// 	  tickColor: '#707073',
// 	  tickWidth: 1,
// 	  title: {
// 		 style: {
// 			color: '#A0A0A3'
// 		 }
// 	  }
//    },
//    tooltip: {
// 	  backgroundColor: 'rgba(0, 0, 0, 0.85)',
// 	  style: {
// 		 color: '#F0F0F0'
// 	  }
//    },
//    plotOptions: {
// 	  series: {
// 		 dataLabels: {
// 			color: '#B0B0B3'
// 		 },
// 		 marker: {
// 			lineColor: '#333'
// 		 }
// 	  },
// 	  boxplot: {
// 		 fillColor: '#505053'
// 	  },
// 	  candlestick: {
// 		 lineColor: 'white'
// 	  },
// 	  errorbar: {
// 		 color: 'white'
// 	  }
//    },
//    legend: {
// 	  itemStyle: {
// 		 color: '#E0E0E3'
// 	  },
// 	  itemHoverStyle: {
// 		 color: '#FFF'
// 	  },
// 	  itemHiddenStyle: {
// 		 color: '#606063'
// 	  }
//    },
//    credits: {
// 	  style: {
// 		 color: '#666'
// 	  }
//    },
//    labels: {
// 	  style: {
// 		 color: '#707073'
// 	  }
//    },
//
//    drilldown: {
// 	  activeAxisLabelStyle: {
// 		 color: '#F0F0F3'
// 	  },
// 	  activeDataLabelStyle: {
// 		 color: '#F0F0F3'
// 	  }
//    },
//
//    navigation: {
// 	  buttonOptions: {
// 		 symbolStroke: '#DDDDDD',
// 		 theme: {
// 			fill: '#505053'
// 		 }
// 	  }
//    },
//
//    // scroll charts
//    rangeSelector: {
// 	  buttonTheme: {
// 		 fill: '#505053',
// 		 stroke: '#000000',
// 		 style: {
// 			color: '#CCC'
// 		 },
// 		 states: {
// 			hover: {
// 			   fill: '#707073',
// 			   stroke: '#000000',
// 			   style: {
// 				  color: 'white'
// 			   }
// 			},
// 			select: {
// 			   fill: '#000003',
// 			   stroke: '#000000',
// 			   style: {
// 				  color: 'white'
// 			   }
// 			}
// 		 }
// 	  },
// 	  inputBoxBorderColor: '#505053',
// 	  inputStyle: {
// 		 backgroundColor: '#333',
// 		 color: 'silver'
// 	  },
// 	  labelStyle: {
// 		 color: 'silver'
// 	  }
//    },
//
//    navigator: {
// 	  handles: {
// 		 backgroundColor: '#666',
// 		 borderColor: '#AAA'
// 	  },
// 	  outlineColor: '#CCC',
// 	  maskFill: 'rgba(255,255,255,0.1)',
// 	  series: {
// 		 color: '#7798BF',
// 		 lineColor: '#A6C7ED'
// 	  },
// 	  xAxis: {
// 		 gridLineColor: '#505053'
// 	  }
//    },
//
//    scrollbar: {
// 	  barBackgroundColor: '#808083',
// 	  barBorderColor: '#808083',
// 	  buttonArrowColor: '#CCC',
// 	  buttonBackgroundColor: '#606063',
// 	  buttonBorderColor: '#606063',
// 	  rifleColor: '#FFF',
// 	  trackBackgroundColor: '#404043',
// 	  trackBorderColor: '#404043'
//    },
//
//    // special colors for some of the
//    legendBackgroundColor: 'rgba(0, 0, 0, 0.5)',
//    background2: '#505053',
//    dataLabelsColor: '#B0B0B3',
//    textColor: '#C0C0C0',
//    contrastTextColor: '#F0F0F3',
//    maskColor: 'rgba(255,255,255,0.3)'
// };
//
// // Apply the theme
// //Highcharts.setOptions(Highcharts.theme);
