# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w( public.css public.js )
# Rails.application.config.assets.precompile += %w( bootstrap.css bootstrap-timepicker.css bootstrap-wysihtml5.css datepicker.css endless-landing.css endless-landing.min.css endless-skin.css endless.css endless.min.css font-awesome.css font-awesome.min.css fullcalendar.css fullcalendar.print.css jcarousel.responsive.css jquery.dataTables_themeroller.css jquery.dataTables.css jquery.tagsinput.css morris.css pace.css prettify.css slider.css wysiwyg-color.css )
# Rails.application.config.assets.precompile += %w( bootstrap.js bootstrap.min.js bootstrap-datepicker.js bootstrap-slider.js bootstrap-timepicker.js bootstrap-wysihtml5.js chosen.jquery.js dropzone.js endless.js fullcalendar.js holder.js jcarousel.responsive.js jquery-1.10.2.js jquery.colorbox.js jquery.cookie.js jquery.dataTables.js jquery.flot.js jquery.gritter.js jquery.jcarousel.js jquery.localscroll.js jquery.maskedinput.js jquery.minicolors.js jquery.nestable.js jquery.popupoverlay.js jquery.resize.js jquery.scrollTo.js jquery.slimscroll.js jquery.sparkline.js jquery.tagsinput.js less-1.5.1.js modernizr.js morris.js pace.js parsley.js rapheal.js run_prettify.js waypoints.js wysihtml5-0.3.0.js )
