def code(*args, &block)
  buffer = eval('_erbout', block.binding)
  lang = args.first || :ruby
  pos = buffer.length
  block.call(*args)

  data = buffer[pos..-1].split("\n")
  data.shift while data[0] == ""
  indentlevel = data[0].match(/^\s*/)[0].length
  data = data.map {|l| l[indentlevel..-1] }.join("\n")

  buffer[pos..-1] = codify(data, lang)
end

def codify(str, lang)
  lang ||= 'ruby'
  html_coded = ''
  
  open("|pygmentize -O linenos=1,prestyles=1 -f html -l #{lang}", "w+") do |f|
    f.puts(str)
    f.close_write
    html_coded = f.read
  end
  
  if html_coded.empty?
    html_coded = "<pre><code>#{str.strip}</code></pre>"
  end
  
  "<div class='highlighted'><code>(#{lang.capitalize})</code>#{html_coded.strip}</div>"
end

