require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  def setup
  	@user = users(:michael)
  end


  test "login with incalid information" do

  	get login_path
  	assert_template 'sessions/new'

  	post login_path, params: { session: { email: "", password: "" } }
  	assert_template 'sessions/new'
  	assert_not flash.empty?
  	get root_path
    assert flash.empty?

  end


  test "login with valid information followed by logout" do

    get login_path
    post login_path, params: { session: { email:    @user.email,
                                          password: 'password' } }

	# assert is_logged_in?
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)

    # sesstionを削除
   	delete logout_path
   	# ログアウトしているかどうか確認
    assert_not is_logged_in?
    # ドキュメントルートに戻る
    assert_redirected_to root_url
    follow_redirect!

    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path,      count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end

end
 