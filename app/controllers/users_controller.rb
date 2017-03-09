class UsersController < ApplicationController

  def show
  		@user = User.find(params[:id])
  	  	logger.debug { @user.inspect }
  	  	logger.debug { ">>> #{params.inspect}" }
  end

  def new
  	@user = User.new
  end

  def create
  	@user = User.new(user_params)
  	if @user.save

  	else
  		render 'new'
  	end
  end

  private

    def user_params

  		logger.debug { ">>> inputParams  #{params.inspect}"  }
    	params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
  
end
