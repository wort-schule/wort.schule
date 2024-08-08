# frozen_string_literal: true

require "rake"

Rails.application.load_tasks

class InvokeRakeTaskJob < ApplicationJob
  def perform(task, *)
    Rake::Task[task].reenable
    Rake::Task[task].invoke(*)
  end
end
