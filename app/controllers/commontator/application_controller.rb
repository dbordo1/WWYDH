module Commontator
  class ApplicationController < ActionController::Base
    before_filter :set_user, :ensure_user
    
    rescue_from SecurityTransgression, :with => lambda { head(:forbidden) }

    def current_user
  @current_user ||= session[:user_id] && User.find(session[:user_id])
  end
  
    protected

    def security_transgression_unless(check)
      raise SecurityTransgression unless check
    end

    def set_user
      @user = Commontator.current_user_proc.call(self)
    end

    def ensure_user
      security_transgression_unless(@user && @user.is_commontator)
    end

    def set_thread
      @thread = params[:thread_id].blank? ? \
        Commontator::Thread.find(params[:id]) : \
        Commontator::Thread.find(params[:thread_id])
      security_transgression_unless @thread.can_be_read_by? @user
      commontator_set_new_comment(@thread, @user)
    end
  end
end
