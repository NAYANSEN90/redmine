# frozen_string_literal: true

module RedmineRubyLlm
  module ProjectPatch
    def self.apply!
      return if ::Project.reflect_on_association(:llm_chats)

      ::Project.class_eval do
        has_many :llm_chats, dependent: :destroy
      end
    end
  end
end

RedmineRubyLlm::ProjectPatch.apply!
