require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'UniversalDetector'

output = ""

range = (40458..40509)
# range = [40458]

File.open("Honor.txt", 'w') do |f|
  range.each  do |id|
    url =   "http://notabenoid.com/book/12477/#{id}/ready?algorithm=0&untr=o&format=h"
    p url

    begin
    doc = Nokogiri::HTML(open(url))
    content = doc.xpath(("//*[@id='content']"))



    f.write( content.inner_text + "\n")
    rescue StandardError => ex
        p "#{id} not found"
    end
  end
end
