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