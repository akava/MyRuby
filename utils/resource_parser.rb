require 'rubygems'
require 'nokogiri'
require 'resx_template'

ROOT_DIR = 'c:/Andrew/IBA/GDYR/MESPOD/SVN_HG/MESPOD/'
TO_TRANSLATE_CSV =  '../../MessagesToTranslate.csv'
TRANSLATED_CSV = '../../TranslatedMessages.csv'
TO_TRANSLATE_CSV_MERGED = 'MessagesToTranslate_merged.csv'

def resources_to_csv
  Dir::chdir(ROOT_DIR)
  def_lang_list = Hash.new()

  # create default (EN) messages list
  Dir['**/*.resx'].each do |f_name|
    next if f_name.end_with?('de-DE.resx', 'de.resx', 'sl.resx')

    File.open(f_name) do |f|
      doc = Nokogiri::XML(f)

      doc.xpath(("//data[not(@type)]")).each do |node|
        name = node['name']
        value = node.children()[1].inner_text

        def_lang_list[f_name] = [] if not def_lang_list.has_key?(f_name)
        def_lang_list[f_name].push([name, value])  if (name.end_with?("Caption", "Text")) or f_name.end_with?("UserMessage.resx", "Resources.resx")
      end
    end
  end

  other_lang_list = Hash.new()
  # combine default list with other languages translations
  res_lang_regexp = /\/\S+\.([^\.]+)\.resx/
  Dir['**/*.resx'].each do |f_name|
    next if def_lang_list.has_key?(f_name)

    match = res_lang_regexp.match(f_name)
    next if match.nil?

    lang = match[1]
    def_lang_f_name = f_name.sub(/([^\.]+)\.resx/, "resx")
    File.open(f_name) do |f|
      doc = Nokogiri::XML(f)

      doc.xpath(("//data[not(@type)]")).each do |node|
        name = node['name']
        value = node.children()[1].inner_text

        other_lang_list[def_lang_f_name + "|" + name] = {} if not def_lang_list.has_key?(def_lang_f_name + "|" + name)
        other_lang_list[def_lang_f_name + "|" + name][lang] = value  if (name.end_with?("Caption", "Text")) or def_lang_f_name.end_with?("UserMessage.resx", "Resources.resx")
      end
    end
  end

  merged_list = {}
  # merging two lists
  def_lang_list.each_pair do |f_name, val|
    val.each do |(name, value)|
      langs_map =  other_lang_list[f_name + "|" + name]
      langs_map = {} if langs_map.nil?
      langs_map[:default] = value

      merged_list[f_name] = [] if merged_list[f_name].nil?
      merged_list[f_name].push([name, langs_map])
    end
  end


  File.open(TO_TRANSLATE_CSV, "w") do |f|
    f.write("File name;Resource name;EN;SL\n")
    merged_list.each_pair do |f_name, val|
      val.each do |(name, langs_map)|
        f.write("#{f_name};#{name};#{langs_map[:default]};#{langs_map["sl"]}\n")
      end
    end
  end
  return 0
end

def csv_to_resources
  hash = Hash.new()

  Dir::chdir(ROOT_DIR)
  File.open(TRANSLATED_CSV) do |f|
    while (line = f.gets)
      (res_f, mess_id, _, trans) = line.split(/;/)

      hash[res_f] = [] if not hash.has_key?(res_f)
      hash[res_f].push([mess_id, trans])
    end
  end

  hash.each_pair do |key, val|
    resx_file = key.sub(/resx/, "sl.resx")
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
    Dir::chdir(ROOT_DIR)
  File.open(TRANSLATED_CSV) do |f|
    while (line = f.gets)
      (_, _, msg, trans) = line.split(/;/)

      hash_by_msg[msg]=trans
    end
  end

   File.open(TO_TRANSLATE_CSV) do |fin|
  File.open(TO_TRANSLATE_CSV_MERGED, "w") do |fout|
     while (line = fin.gets)
       line.sub!(/\n/,"")
       (_, _, msg) = line.split(/;/)
       trans = ""

       trans = hash_by_msg[msg] if hash_by_msg.has_key?(msg)

       fout.write(line + ";" + trans + "\n")
     end
  end
  end
end
#append_translation
resources_to_csv
#csv_to_resources


