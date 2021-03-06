class ApplicationController < ActionController::Base
  before_filter :require_user
  
  protect_from_forgery
  
  helper_method :current_user, :logged_in?, :current_apprenticeship, :other_user

  def current_user
    @current_user ||= User.find_by_id(session[:user_id])
  end

  def logged_in?
    current_user != nil
  end
  
  def current_apprenticeship # Key method, show the current apprenticeship of the current user.
    Apprenticeship.find_by_id(params[:apprenticeship_id]) || Apprenticeship.find_by_id(params[:id])
  end
  
  def require_user
    redirect_to signin_url, notice: "Hmm, can you try signing in? That should probably work." unless logged_in?
  end
  
  def destroy_notifications(collection)
    collection.each do |message|
      message.notification.destroy if !message.notification.nil? && message.notification.creator != current_user
    end
  end

  def other_user
    current_user == current_apprenticeship.student ? current_apprenticeship.mentor : current_apprenticeship.student
  end

end
