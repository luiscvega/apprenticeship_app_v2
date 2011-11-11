class ApprenticeshipsController < ApplicationController
  def index
    @apprenticeships = current_user.apprenticeships
  end
  
  def show
    @apprenticeship = current_apprenticeship
    if current_user == @apprenticeship.student
      @student = current_user
      @mentor = @apprenticeship.mentor
    else
      @student = @apprenticeship.student
      @mentor = current_user
    end
  end
end
