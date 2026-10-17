# frozen_string_literal: true

require_relative 'lib/redmine_ruby_llm'

Redmine::Plugin.register :redmine_ruby_llm do
  name 'RubyLLM'
  author 'Redmine contributors'
  description 'Integrates RubyLLM for project AI chats and issue assistance'
  version '0.1.0'
  url 'https://rubyllm.com'
  requires_redmine version_or_higher: '7.0.0'

  settings default: {
    'openai_api_key' => '',
    'openai_api_base' => '',
    'anthropic_api_key' => '',
    'default_model' => 'gpt-4o-mini',
    'issue_assistant_instructions' =>
      'You are a helpful project assistant in Redmine. Summarize clearly and stay factual.'
  }, partial: 'settings/redmine_ruby_llm_settings'

  project_module :ruby_llm do
    permission :view_llm_chats, {llm_chats: [:index, :show]}, read: true
    permission :manage_llm_chats, {llm_chats: [:new, :create, :destroy], llm_messages: [:create]}
    permission :use_llm_issue_assistant, {llm_issue_assistants: [:create]}
  end

  menu :project_menu, :llm_chats,
       {controller: 'llm_chats', action: 'index'},
       caption: :label_llm_chats,
       after: :activity,
       param: :project_id
end

Rails.application.config.to_prepare do
  RedmineRubyLlm::ProjectPatch.apply!
  RedmineRubyLlm.apply_configuration!
end
