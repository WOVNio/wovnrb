class RedirectsController < ApplicationController
  def show
    redirect_to '/redirection_target'
  end
end
