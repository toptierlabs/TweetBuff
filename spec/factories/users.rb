Factory.sequence :email do |n|
  "test#{n}@test.com"
end

Factory.define :user do |user|
  user.email {Factory.next :email}
  user.password "temp4now"
  user.password_confirmation "temp4now"
end