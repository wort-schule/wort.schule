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

    if user.present?
      can %i[show edit update destroy], User, %i[first_name last_name avatar email password], id: user.id

      case user.role
      when "Student"
        can %i[read accept_invitation], LearningGroup
        can :read, School

        can %i[read read_students read_lists], LearningGroup, students: {id: user.id}
        can :show, School, learning_groups: {students: {id: user.id}}
        can :create, :learning_group_membership_requests

        can %i[crud add_word remove_word], List, {user:}
        can :index, :flashcard

      when "Teacher"
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

        can :read, Theme, visibility: :public
        can :crud, Theme, {user:}
        can %i[crud add_word remove_word], List, {user:}

        # User management
        can :read, User, role: "Student"
        can %i[crud invite read_students read_lists], LearningGroup, teacher_id: user.id
        can :crud, LearningGroupMembership, learning_group: {teacher_id: user.id}
        can %i[read read_teachers], School, teaching_assignments: {teacher_id: user.id}
        can %i[accept reject], :learning_group_membership_requests
        can :crud, LearningPlea, learning_group: {teacher_id: user.id}

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

        can :crud, Theme
        can %i[crud add_word remove_word], List

        # User management
        can :manage, User
        can :manage, School
        can :manage, TeachingAssignment
        can :manage, LearningGroup
        can :manage, LearningGroupMembership
        can :manage, LearningPlea
      end
    end
  end
end
