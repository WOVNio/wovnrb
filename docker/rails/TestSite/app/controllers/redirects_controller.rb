class RedirectsController < ApplicationController
  def show
    redirect_to '/testdir/testpage-redirect-destination.html'
  end
end
