# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :create, :read, :update, :destroy, to: :crud

    can :read, Noun
    can :read, Verb
    can :read, Adjective
    can :read, FunctionWord
    can :read, List, visibility: :public
    can :read, Source, visible: true
    can :read, Keyword
    can :read, Hierarchy
    can :read, Topic
    can :read, WordViewSetting, visibility: :public

    if user.present?
      can %i[show edit update destroy], User, %i[first_name last_name avatar email password word_view_setting_id], id: user.id

      can %i[read new create accept_invitation], LearningGroup
      can %i[read read_users read_lists], LearningGroup, users: {id: user.id}
      can %i[crud invite read_users read_lists generate_users], LearningGroup.with_group_admin(user)

      can :create_request, LearningGroupMembership
      can %i[crud accept_request reject_request], LearningGroupMembership, learning_group_id: LearningGroup.with_group_admin(user).pluck(:id)
      can %i[crud accept_request reject_request], LearningGroupMembership, user_id: user.id
      can %i[change_group_admin reset_password read_invitations], LearningGroupMembership, learning_group: LearningGroup.with_group_admin(user)

      can :crud, LearningPlea, learning_group: {user_id: user.id}
      can %i[crud add_word remove_word move_word create_private], List, {user_id: user.id}
      can :index, :flashcard

      can :read, Theme, visibility: :public
      can :crud, Theme, {user:}
      can :read, WordViewSetting, visibility: :public

      can :create, ImageRequest

      case user.role
      when "Lecturer"
        can :crud, Noun
        can :crud, Verb
        can :crud, Adjective
        can :crud, Source

        # Special entries
        can :crud, FunctionWord
        can :crud, Topic
        can :crud, Hierarchy
        can :crud, Prefix
        can :crud, Postfix
        can :crud, Phenomenon
        can :crud, Strategy
        can :crud, CompoundInterfix
        can :crud, CompoundPreconfix
        can :crud, CompoundPostconfix
        can :crud, CompoundPhonemreduction
        can :crud, CompoundVocalalternation

        can :read, User

        can :crud, WordViewSetting, owner: user

      when "Admin"
        can :manage, Noun
        can :manage, Verb
        can :manage, Adjective
        can :manage, Source

        # Special entries
        can :manage, FunctionWord
        can :manage, Topic
        can :manage, Hierarchy
        can :manage, Prefix
        can :manage, Postfix
        can :manage, Phenomenon
        can :manage, Strategy
        can :manage, CompoundInterfix
        can :manage, CompoundPreconfix
        can :manage, CompoundPostconfix
        can :manage, CompoundPhonemreduction
        can :manage, CompoundVocalalternation

        can :manage, Theme
        can :manage, List

        can :manage, :review
        can :manage, :word_import
        can :manage, :word_images

        # User management
        can :manage, User
        can :manage, LearningGroup
        can :manage, LearningGroupMembership
        can :manage, LearningPlea

        can :manage, :font
        can :manage, WordViewSetting
      end
    end
  end
end
