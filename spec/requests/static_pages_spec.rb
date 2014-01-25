require 'spec_helper'
require 'helpers/static_pages_helper_spec'

describe "Static pages" do
  include LinksAndTitlesHelpers

  subject { page }

  shared_examples_for "all static pages" do
    it { should have_selector('h1', text: heading) }
    it { should have_title(full_title(page_title)) }
  end

  describe "Home page" do
    before { visit root_path }
    let(:heading)    { 'Sample App' }
    let(:page_title) { '' }

    it_should_behave_like "all static pages"
    it { should_not have_title('| Home') }

    describe "for signed_in users" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")
        FactoryGirl.create(:micropost, user: user, content: "Dolor sit amet")
        sign_in user
        visit root_path
      end

      it "should render the user's feed" do
        user.feed.each do |item|
          expect(page).to have_selector("li##{item.id}", text: item.content) 
        end
      end

      it { should have_selector("span", text: '2 microposts') }

      describe "to have 2 microposts" do
        specify { expect(user.microposts.count).to eq 2 }
        specify "then after deleting one micropost" do
          expect do
            click_link('delete', match: :first)
          end.to change { string }.from('2 microposts').to('1 micropost')
          expect(user.microposts.count).to eq 1 
        end 
      end

      describe "pagination" do
        before(:all) do
          @new_user = FactoryGirl.create(:user)
          31.times { @new_user.microposts.create(content: Faker::Lorem.sentence(5)) } 
        end
        
        after(:all)  { User.delete_all }
        after(:all)  { Micropost.delete_all }
        before { sign_in @new_user and visit root_path }
        
        it "should have pagination navigator" do 
          should have_selector('div.pagination') 
        end

        it "should list each micropost" do
          @new_user.feed.paginate(page: 1).each_with_index do |post,index|
            expect(page).to have_selector('span.content', text: post.content) unless index > 30
          end
        end
      end
    end
  end

  def string 
    page.find('span:contains("view my profile")+span').text
  end

  describe "Help page" do
    before { visit help_path }
    let(:heading)    { 'Help' }
    let(:page_title) { 'Help' }

    it_should_behave_like "all static pages"
  end

  describe "About page" do
    before { visit about_path }
    let(:heading)    { 'About' }
    let(:page_title) { 'About Us' }

    it_should_behave_like "all static pages"
  end

  describe "Contact page" do
    before { visit contact_path }
    let(:heading)    { 'Contact' }
    let(:page_title) { 'Contact' }

    it_should_behave_like "all static pages"
  end

  it "should have the right links on the layout" do
    visit root_path
    links_and_titles_hash.each do |link, title|
      check_link_and_title link, title
    end
  end
end