include ApplicationHelper

def valid_signin(user)
	fill_in "Email", 				with: user.email
	fill_in "Password", 		with: user.password
	click_button "Sign in"
end

def valid_signup(user)
	fill_in "Name",					with: user.name
  fill_in "Email",				with: user.email
  fill_in "Password",			with: user.password
  fill_in "Confirmation",	with: user.password_confirmation
end

def check_link_and_title(link, title)
	click_link link
	expect(page).to have_title(full_title('About Us'))
end

def check_link_and_title link, *title
	click_link link
	check_title title if title
end

RSpec::Matchers.define :check_title do |title|
	match do |page|
		expect(page).to have_title(full_title(title))
	end
end

RSpec::Matchers.define :have_error_message do |message|
	match do |page|
		expect(page).to have_selector('div.alert.alert-error', text: message)
	end
end

def sign_in(user, options={})
	if options[:no_capybara]
		 # Sign in when not using Capybara.
    remember_token = User.new_remember_token
    cookies[:remember_token] = remember_token
    user.update_attribute(:remember_token, User.encrypt(remember_token))
  else
    visit signin_path
    fill_in "Email",    with: user.email
    fill_in "Password", with: user.password
    click_button "Sign in"
  end
end
