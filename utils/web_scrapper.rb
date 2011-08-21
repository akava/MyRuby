require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'rio'


start_url = "http://ruby.learncodethehardway.org/"

doc = Nokogiri::HTML(open(start_url))
doc.xpath(("/html/body/div/section/section/ul/li/a")).each do |chapter_node|
  #<a href="/intro.html">The Hard Way Is Easier</a>
  chapter_url = start_url + chapter_node['href'][1..100]
  chapter_title = chapter_node.inner_text.gsub(/:/) {  }

  p " Saving chapter '#{chapter_title}' (#{chapter_url})"
  rio(chapter_url) > rio(chapter_title + '.html')

end


=begin
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

=end
