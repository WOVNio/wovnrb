class CustomResponseController < ApplicationController
  skip_before_action :verify_authenticity_token 

  def make_response
    response_args_json = params[:response]
    raise ActionController::BadRequest unless response_args_json

    (response_args_json[:headers] || {}).each do |name, value|
      response.headers[name] = value
    end

    render inline: response_args_json[:body],
           status: response_args_json[:status],
           content_type: response_args_json[:content_type]
  end
end
