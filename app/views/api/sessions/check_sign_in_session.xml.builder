xml.instruct!
xml.Response do
  xml.sign_in_status @status
  if @status.eql?(1)
    xml.login_session_key current_user.email
  end
end