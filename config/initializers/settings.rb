API_KEY = "174091022679493"
SECRET_KEY = "1c016c320fc44d6014aecd50d7761880"

if Rails.env.development?
  SERVER_URL = "http://localhost:3000"
else
  SERVER_URL = "http://tweetbuff.com"
end
