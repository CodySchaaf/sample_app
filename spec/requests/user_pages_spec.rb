require 'spec_helper'

describe "User pages" do

  subject { page }

  describe "index" do

    let(:user) {FactoryGirl.create(:user) }

    before(:each)  do
      sign_in user
      visit users_path
    end

    it { should have_title('All users') }
    it { should have_content('All users') }

    describe "pagination" do

      before(:all)  { 30.times { FactoryGirl.create(:user) } }
      after(:all)   { User.delete_all }

      it { should have_selector('div.pagination') }

      it "should list each user" do
        User.paginate(page: 1).each do |user|
          expect(page).to have_selector('li', text: user.name)
        end
      end
    end

    describe "delete links" do
      it { should_not have_link('delete') }

      describe "as an admin user" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          sign_in admin
          visit users_path
        end

        it { should have_link('delete', href: user_path(User.first)) }
        it "should be able to delete another user" do
          expect do
            click_link('delete', match: :first)
          end.to change(User, :count).by(-1)
        end
        it { should_not have_link('delete', href: user_path(:admin)) }
      end
    end
  end
  
  shared_examples_for "all user pages" do
    it { should have_content(content) }
    it { should have_title(title) }
  end

  describe "signup page" do
    before { visit signup_path }
    let(:content) { 'Sign up' }
    let(:title) { full_title('Sign up') }

    it_should_behave_like "all user pages"
  end


  describe "profile page" do
    let(:signed_out_user) { FactoryGirl.create(:user) }
    let!(:m_signed_out) { FactoryGirl.create(:micropost, user: signed_out_user, content: "Signed Out!") }
    let(:user) { FactoryGirl.create(:user) }
    let!(:m1) { FactoryGirl.create(:micropost, user: user, content: "Foo") }
    let!(:m2) { FactoryGirl.create(:micropost, user: user, content: "Bar") }

    before do 
      sign_in user
      visit user_path(user) 
    end
    
    describe "after signing in" do
      it { should have_content(user.name) }
      it { should have_title(user.name) }

      describe "microposts" do
        it { should have_content(m1.content) }
        it { should have_content(m2.content) }
        it { should have_content(user.microposts.count) }

        it { should have_link("delete", href: "/microposts/#{m1.id}") } 
        it { should have_link("delete", href: "/microposts/#{m2.id}") } 
      end

      describe "microposts for the signed out user" do
        before { visit user_path(signed_out_user) }

        it { should have_selector("li", text: 'Signed Out!') }
        it { should_not have_link("delete", href: "/microposts/#{m_signed_out.id}") }
      end
    end
  end

  describe "signup" do
    before { visit signup_path }
    let (:submit) { "Create my account" }

    describe "with invalid information" do

      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end

      describe "after submission" do
        before { click_button submit }
        let(:content) { 'error' }
        let(:title) { 'Sign up' }

        it_should_behave_like "all user pages"
      end
    end

    describe "with valid information" do
      let(:user) {FactoryGirl.build(:user)}
      before { valid_signup(user)}

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe 'after saving the user' do
        before { click_button submit }
        let(:new_user) { User.find_by(email: user.email) }

        context 'when new_user is submited' do
          it 'should equal user' do
            new_name = new_user.name
            expect(new_name).to eq(user.name)
          end
        end

        it { should have_link('Sign out')	}
        it { should have_title(new_user.name) }
        it { should have_selector('div.alert.alert-success', text: 'Welcome') }
      end

    end
  end

  describe "edit" do
    let(:user) {FactoryGirl.create(:user) }
    before do
      sign_in user
      visit edit_user_path(user) 
    end


    describe "page" do
      it { should have_content("Update your profile") }
      it { should have_title("Edit user") }
      it { should have_link('change', href: 'http://gravatar.com/emails') }
    end

    describe "with invalid information" do
      before { click_button "Save changes" }

      it { should have_content('error') }
    end

    describe "with valid information" do 
      let(:new_name) { "New Name" }
      let(:new_email) { "new@example.com" }
      before do
        fill_in "Name", with: new_name
        fill_in "Email", with: new_email
        fill_in "Password", with: user.password
        fill_in "Confirm Password", with: user.password
        click_button "Save changes"
      end

      it { should have_title(new_name) }
      it { should have_selector('div.alert.alert-success') }
      it { should have_link('Sign out', href: signout_path) }
      specify { expect(user.reload.name).to eq new_name }
      specify { expect(user.reload.email).to eq new_email }
    end

    describe "forbidden attributes" do
      let(:params) do
        { user: { admin: true, password: user.password,
          password_confirmation: user.password } }
        end
        before do
          sign_in user, no_capybara: true
          patch user_path(user), params
        end
        specify { expect(user.reload).not_to be_admin }
    end 
  end
end
