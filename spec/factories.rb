FactoryGirl.define do 
	factory :user do
		name			"Cody Schaaf"
		email			"cody@example.com"
		password  "foobar"
		password_confirmation	"foobar"
	end
end
