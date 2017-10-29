class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :find_user

  def render_404
    # DPR: supposedly this will actually render a 404 page in production
    render file: "/public/404.html", status: 404
  end

  private
  def find_user
    if session[:user_id]
      @login_user = User.find_by(id: session[:user_id])
    else
      flash[:status] = :failure
      flash[:result_text] = "You must be logged in to do that"
      redirect_to root_path
    end
  end
end
