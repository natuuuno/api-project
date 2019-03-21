class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]
  before_action :login_user, only: [:login]
  before_action :authenticate, :except => [:login]

  # GET /users
  def index
    @users = User.all

    render json: @users
  end

  # GET /users/1
  def show
    render json: @user
  end

  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save
      # render json: @user, status: :created, location: @user
      render json: {status: 200, message: 'ユーザー登録が完了しました'}, status: 200
    else
      # render json: @user.errors, status: :unprocessable_entity
      render json: {status: 400, message: @user.errors.full_messages }, status: 400
    end
  end

  # #has_secure_tokenログイン
  # def login
  #   login_user = User.find_by(email: user_params[:email], password: user_params[:password])
  #   if login_user
  #     render json: {access_token: login_user.token}
  #   else
  #     render json: {status: 401, message: "認証に失敗しました"}, status: 401
  #   end
  # end

  #まず秘密鍵をつくる
  #emailとpassでfind_by
  #あるならjwt エンコード（秘密鍵）
  #ないなら

  #JWTログイン
  def login
    rsa_private = OpenSSL::PKey::RSA.generate(2048) #秘密鍵生成
    data = { email: @user.email, password: @user.password } #postで送られてきた値をとる
    if data
      render json: {access_token: JWT.encode(data, Rails.application.secrets.secret_key_base, "HS256")} #dataがあったらトークン表示
    else
      render json: {status: 401, message: "認証に失敗しました"}, status: 401 #なかったらエラメ
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    def login_user
      @user = User.find_by(email: params[:email], password: params[:password])
      unless @user
        render json: {status: 401, message: "認証に失敗しました"}, status: 401
      end
    end

    def authenticate
      if request.headers["Authorization"].present?
        token = request.headers['Authorization'].split(' ').last
        @user = JWT.decode(token, Rails.application.secrets.secret_key_base, true, { algorithm: "HS256" })[0]
      else
        render json: { status: "ERROR", message: "Not Authorized" }
      end
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      params.fetch(:user, {}).permit(:name, :email, :password)
    end
end
