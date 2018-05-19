require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:foobar)
  end

  test "login with invalid information" do
    get login_path
    assert_template 'cookies/new'
    post login_path, params: { cookie: { email: "", password: "" } }
    assert_template 'cookies/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end

  test "login with valid information followed by logout" do
    get login_path
    post login_path, params: { cookie: { email:    @user.email,
                                         password: 'password' } }
    assert is_logged_in?
    assert_redirected_to root_path
    follow_redirect!
    assert_template 'static_pages/home'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    # # Simulate a user clicking logout in a second window.
    delete logout_path
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path, count: 0
  end
end
