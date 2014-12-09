include Nanoc3::Helpers::LinkTo
include Nanoc3::Helpers::XMLSitemap
include Nanoc3::Helpers::Rendering

def license
  if @item[:license] == "cc-by"
    '<a rel="license" href="http://creativecommons.org/licenses/by/3.0/"><img alt="Creative Commons License" style="border-width:0" src="http://i.creativecommons.org/l/by/3.0/80x15.png" /></a><br />This work by <a xmlns:cc="http://creativecommons.org/ns#" href="http://vikhyat.net/" property="cc:attributionName" rel="cc:attributionURL">Vikhyat Korrapati</a> is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/3.0/">Creative Commons Attribution 3.0 Unported License</a>.'
  else
    ""
  end
end

def items_under(text)
  items.select {|i| i.identifier =~ /^\/#{text.to_s}\/[^\/]+\/$/ }
end
