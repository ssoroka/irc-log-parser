require 'mechanize'

task :grab_latest do
  ROR_LOG_SITE = "http://thesaq.com/rubyonrails/"
  puts "Downloading latest ruby log"
  mech = WWW::Mechanize.new
  page = mech.get(ROR_LOG_SITE)
  url = page.links.select {|l| l.href =~ /ror/}.first.to_s
  filename = url.split('/').last # just in case there's more than one folder? :)
  system "curl -0 #{ROR_LOG_SITE + url} > #{filename}"
end
