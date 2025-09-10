class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_cart

  private

  # Provides a session-scoped cart, creating one if needed
  def current_cart
    @current_cart ||= begin
      session[:cart_session_id] ||= SecureRandom.uuid
      Cart.find_or_create_by!(session_id: session[:cart_session_id])
    end
  end
end