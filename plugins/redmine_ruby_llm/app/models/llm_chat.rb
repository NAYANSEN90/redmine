# frozen_string_literal: true

class LlmChat < ApplicationRecord
  acts_as_chat messages: :llm_messages, message_class: 'LlmMessage'

  belongs_to :project
  belongs_to :user

  validates :title, length: {maximum: 255}, allow_blank: true

  scope :visible, ->(user=User.current) {
    joins(:project).where(Project.allowed_to_condition(user, :view_llm_chats))
  }

  before_validation :assign_default_title, on: :create

  def display_title
    title.presence || "Chat ##{id}"
  end

  private

  def assign_default_title
    self.title = 'New chat' if title.blank?
  end
end
