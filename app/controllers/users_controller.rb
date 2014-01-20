class UsersController < ApplicationController
  before_action :signed_in_user,    only: [:edit, :update, :index, :destroy]
  before_action :correct_user,      only: [:edit, :update]
  before_action :admin_user,        only: :destroy
  before_action :currently_signed_in?, only: [:new, :create]

  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params) #not final
    if @user.save
      sign_in @user
      flash[:success] = 'Welcome to the Sample App!'
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit 
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success]= "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  # def destroy
  #   User.find(params[:id]).destroy
  #   flash[:success] = "User deleted!"
  #   redirect_to users_url
  # end

  def destroy
    user_to_destroy = User.find(params[:id])
    unless user_to_destroy.admin? && current_user?(user_to_destroy)
      user_to_destroy.destroy 
      flash[:success] = "User deleted!"
      redirect_to users_url
    else
      flash[:error] = "Don't delete yourself Mr. Admin"
      redirect_to root_url
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password,
                                 :password_confirmation)
  end

  # Before filters

  def currently_signed_in?
    if signed_in?
      redirect_to root_url
    end
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end

  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end

end