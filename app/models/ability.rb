class Ability
  include CanCan::Ability

  def initialize user
    user ||= User.new

    if user.admin?
      can :manage, :all
      cannot :create, Request
    else
      can :read, RoomType
      can :read, Review
      if user.persisted?
        can :create, Request
        can :read, Request, user_id: user.id
        can :read, Bill, request: {user_id: user.id}
        can :create, Review
      end
    end
  end
end
