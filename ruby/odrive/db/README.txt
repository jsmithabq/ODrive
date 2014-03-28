
To use the manual utilities from within this directory ('./ruby/odrive/db')
include the ODrive base directory ('./ruby/odrive') , e.g.:

jsmith@sage:~/.../ODrive/ruby/odrive/db$ ruby -I .. user_db_display_users.rb
userid, password, name, password_hint, password_stale, style, cloud_host, cloud_tenant, cloud_user, cloud_password
1: admin, 91608911a1ef6ec3c89c5b3cce2b3dd6, Administrator The Great, (none), false, default, (no cloud host), (no cloud tenant), (no cloud user), (no cloud password)
...

