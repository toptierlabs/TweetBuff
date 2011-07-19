admin = AdminUser.create( :email => "bill@stackpointerllc.com",
                          :name => "Bill Alton",
                          :password => "temp4now",
                          :password_confirmation => "temp4now")
user = User.create( :email => "bill@stackpointerllc.com",
                    :name => "Bill Alton",
                    :password => "temp4now",
                    :password_confirmation => "temp4now")