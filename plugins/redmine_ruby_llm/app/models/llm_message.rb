# frozen_string_literal: true

class LlmMessage < ApplicationRecord
  acts_as_message chat: :llm_chat, chat_class: 'LlmChat'
end
