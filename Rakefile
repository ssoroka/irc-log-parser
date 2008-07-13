require 'mechanize'

task :grab_latest do
  ROR_LOG_SITE = "http://thesaq.com/rubyonrails/"
  puts "Downloading latest ruby log"
  mech = WWW::Mechanize.new
  page = mech.get(ROR_LOG_SITE)
  url = page.links.select {|l| l.href =~ /ror/}.first
  system "curl -0 #{ROR_LOG_SITE + url.to_s}"
end
