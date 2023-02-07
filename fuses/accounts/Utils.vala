ListStore get_account_list_store () {
  var list = new ListStore (typeof (Act.User));
  var user_manager = Act.UserManager.get_default ();

  user_manager.list_users ().foreach ((user) => {
    list.append (user);
  });

  user_manager.user_added.connect ((user) => {
    list.append (user);
  });

  user_manager.user_removed.connect ((removed_user) => {
    uint position;
    var user_found = list.find_with_equal_func (
      removed_user,
      (u1, u2) => ((Act.User)u1).uid == ((Act.User)u2).uid,
      out position
    );

    if (user_found) list.remove (position);
  });

  return list;
}

void create_user (string username,
                  string fullname,
                  string password,
                  Act.UserAccountType user_type,
                  string? avatar_path) {
  var user_manager = Act.UserManager.get_default ();
  Act.User user;
  try {
    user = user_manager.create_user (username, fullname, user_type);
  } catch (Error e) {
    critical ("Failed to create user %s: %s", username, e.message);
    return;
  }

  user.set_password (password, "");

  if (avatar_path != null) {
    user.set_icon_file (avatar_path);
  }
}
