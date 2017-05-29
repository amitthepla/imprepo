require 'rubygems'
require 'sitemap_generator'

SitemapGenerator::Sitemap.default_host = 'https://www.wakeupsales.com/'
SitemapGenerator::Sitemap.create do
  add '/', :changefreq => 'daily', :priority => 1.0
  add '/users/sign-in', :changefreq => 'always', :priority => 0.8
  add '/users/sign-up', :changefreq => 'always', :priority => 0.8
  add '/about-us', :changefreq => 'always', :priority => 0.8
  add '/integration', :changefreq => 'always', :priority => 0.8
  add '/features', :changefreq => 'always', :priority => 0.8
  add '/security', :changefreq => 'always', :priority => 0.8
  add '/product-updates', :changefreq => 'always', :priority => 0.8
  add '/roadmap', :changefreq => 'always', :priority => 0.8
  add '/report-a-bug', :changefreq => 'always', :priority => 0.8
  add '/awards-and-recognitions', :changefreq => 'always', :priority => 0.8
  add '/contact-us', :changefreq => 'always', :priority => 0.8
  add '/pricing', :changefreq => 'always', :priority => 0.8
  add '/privacy', :changefreq => 'always', :priority => 0.8
  add '/terms', :changefreq => 'always', :priority => 0.8
end
# SitemapGenerator::Sitemap.ping_search_engines 