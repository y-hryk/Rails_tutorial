module SessionsHelper

	# 渡されたユーザーでログインする
	def log_in(user)
		session[:user_id] = user.id

	end

	# ユーザーを永続的セッションに記憶する
	def remember(user)
		user.remember
		# permanent - 20年で期限切れになるcookies設定
		# signed    - 著名付きcookie
		cookies.permanent.signed[:user_id] = user.id
		cookies.permanent[:remember_token] = user.remember_token
	end

	# 永続的セッションを破棄する
	def forget(user)
		user.forget
		cookies.delete(:user_id)
		cookies.delete(:remember_token)

	end

	 # 渡されたユーザーがログイン済みユーザーであればtrueを返す
	def current_user?(user)
	   user == current_user
	end

	# 現在ログイン中のユーザーを返す
	def current_user

		if (user_id = session[:user_id]) 
			@current_user ||= User.find_by(id: session[:user_id])
		elsif (user_id = cookies.signed[:user_id])
			# raise       # テストがパスすれば、この部分がテストされていないことがわかる
			user = User.find_by(id: user_id)
			if user && user.authenticated?(cookies[:remember_token])
				log_in user
				@current_user = user
			end
		end
	end

	# ユーザーがログインしていればtrue, その他ならfalseを返す
	def logged_in?
		!current_user().nil?
	end

	# 現在のユーザーをログアウトする
	def log_out
		forget(current_user()) if logged_in?()
		session.delete(:user_id)
		@current_user = nil
	end


	# 記憶したURL (目視はデフォルト値)にリダイレクト
	def redirect_back_or(default)
		redirect_to(session[:forwarding_url] || default)
  		session.delete(:forwarding_url)
	end

	def store_location
		session[:forwarding_url] = request.original_url if request.get?
	end


end
