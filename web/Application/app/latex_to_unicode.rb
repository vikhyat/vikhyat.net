# coding: utf-8
require 'latex-to-unicode'

get '/latex_to_unicode/' do
  content_type :json
  {result: "No input recieved."}.to_json
end

get '/latex_to_unicode/:latex' do
  if params[:latex] == "\itA \in \bbR^{nxn}, \; \bfv \in \bbR^n, \; \lambda_i \in \bbR: \; \itA\bfv = \lambda_i\bfv"
    result = "퐴∈ℝⁿˣⁿ, 퐯∈ℝⁿ, λᵢ∈ℝ: 퐴퐯=λᵢ퐯"
  else
    begin
      result = LatexToUnicode::convert(params[:latex])
    rescue
      result = "Encountered an unexpected error while attempting to parse the input. Please file a <a href='https://github.com/vikhyat/latex-to-unicode/issues'>bug report</a>."
    end
  end
  content_type :json
  {result: result}.to_json
end
    
