# frozen_string_literal: true

resources :projects do
  resources :llm_chats, only: [:index, :show, :new, :create, :destroy] do
    resources :llm_messages, only: [:create]
  end
end

resources :issues do
  resource :llm_issue_assistant, only: [:create]
end
