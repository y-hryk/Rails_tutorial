require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  test "invalid signup information" do
  	get signup_path
  
    assert_no_difference 'User.count' do
    post signup_path, params: { user: { name:  "",
                                     email: "user@invalid",
                                     password:              "foo",
                                     password_confirmation: "bar" } }
    end

    assert_template 'users/new'
    # エラーのテストをする (上記 postのテスト結果がエラーになるため以下のテストが成立している)
    assert_select 'div#error_explanation'
    assert_select 'div.alert'   

  	assert_select 'form[action=?]', signup_path
  end
end