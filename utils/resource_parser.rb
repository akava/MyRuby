require 'rubygems'
require 'nokogiri'
require 'resx_template'

def resources_to_csv
  Dir::chdir('c:/Andrew/IBA/GDYR/MESPOD/SVN_HG/MESPOD/')
  hash = Hash.new()

  Dir['**/*.resx'].each do |f_name|
    next if f_name.end_with?('de-DE.resx', 'de.resx', 'sl.resx')

    File.open(f_name) do |f|
      doc = Nokogiri::XML(f)

      doc.xpath(("//data[not(@type)]")).each do |node|
        name = node['name']
        value = node.children()[1].inner_text

        hash[f_name] = [] if not hash.has_key?(f_name)
        hash[f_name].push([name, value])  if name.end_with?("Caption", "Text") or f_name.end_with?("UserMessage.resx", "Resources.resx")
      end
    end
  end

  File.open("MessagesToTranslate.csv", "w") do |f|
    hash.each_pair do |f_name, val|
      val.each do |(name, value)|
        f.write("#{f_name};#{name};#{value}\n")
      end
    end
  end
end

def csv_to_resources
  hash = Hash.new()

  root =  'c:/Andrew/IBA/GDYR/MESPOD/SVN_HG/MESPOD/'
  File.open("c:/Andrew/IBA/GDYR/MESPOD/TranslatedMessages.csv") do |f|
    while (line = f.gets)
      (res_f, mess_id, _, trans) = line.split(/;/)

      hash[res_f] = [] if not hash.has_key?(res_f)
      hash[res_f].push([mess_id, trans])
    end
  end

  hash.each_pair do |key, val|
    resx_file = root + key.sub(/resx/, "sl.resx")
    File.open(resx_file, "w") do |f|
      f.write(ResxTemplate::Start)
      val.each do | (mess_id, trans)|
        f.write("  <data name=\"#{mess_id}\" xml:space=\"preserve\">\n    <value>#{trans}</value>\n  </data>\n")
      end
      f.write(ResxTemplate::End)
    end
  end
end

def append_translation
  hash_by_msg = Hash.new
  File.open("c:/Andrew/IBA/GDYR/MESPOD/TranslatedMessages.csv") do |f|
    while (line = f.gets)
      (res_f, msg_id, msg, trans) = line.split(/;/)
      id = res_f + msg_id

      hash_by_msg[msg]=trans
    end
  end

  File.open("c:/Andrew/IBA/GDYR/MESPOD/MessagesToTranslate.csv") do |fin|
  File.open("c:/Andrew/IBA/GDYR/MESPOD/MessagesToTranslate_merged.csv", "w") do |fout|
     while (line = fin.gets)
       line.sub!(/\n/,"")
       (res_f, msg_id, msg) = line.split(/;/)
       trans = ""

       trans = hash_by_msg[msg] if hash_by_msg.has_key?(msg)

       fout.write(line + ";" + trans + "\n")
     end
  end
  end
end
append_translation
#resources_to_csv
#csv_to_resources


