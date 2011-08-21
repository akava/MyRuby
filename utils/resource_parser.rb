require 'rubygems'
require 'nokogiri'

Dir::chdir('c:/Andrew/IBA/GDYR/MESPOD/SVN_HG/MESPOD/')
Dir['**/*.resx'].each do |f_name|
  next if f_name.end_with?('de-DE.resx')

  f = File.open(f_name)
  doc = Nokogiri::XML(f)
  f.close

  doc.xpath(("//data[not(@type)]")).each do |node|
    name = node['name']
    value = node.children()[1].inner_text

     p "#{f_name};#{name};#{value}" if name.end_with?("Caption", "Text") or f_name.end_with?("UserMessage.resx", "Resources.resx")
  end
end

