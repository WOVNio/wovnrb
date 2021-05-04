class PagesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def show
    render file: "#{Rails.root}/public/#{params[:page]}.html", layout: false
  end
end
