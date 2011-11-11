class ApplicationController < ActionController::Base
  protect_from_forgery
  
  helper_method :current_user, :logged_in?, :current_apprenticeship

  def current_user
    @current_user ||= User.find_by_id(session[:user_id])
  end

  def logged_in?
    current_user != nil
  end
  
  def current_apprenticeship
    Apprenticeship.find_by_id(params[:apprenticeship_id]) || Apprenticeship.find_by_id(params[:id])
  end
end
