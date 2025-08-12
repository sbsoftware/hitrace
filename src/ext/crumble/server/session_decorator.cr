class Crumble::Server::SessionDecorator
  def user : User?
    User.where(id: user_id).first?
  end

  def ensure_user : User
    if _user = user
      _user
    else
      _user = User.create
      update!(user_id: _user.id.value)
      _user
    end
  end
end
