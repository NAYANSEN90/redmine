# frozen_string_literal: true

require_relative '../test_helper'

class LlmIssueAssistantTest < ActiveSupport::TestCase
  fixtures :projects, :users, :issues, :trackers, :issue_statuses,
           :enumerations, :projects_trackers, :journals, :journal_details

  def setup
    Setting.plugin_redmine_ruby_llm = {
      'openai_api_key' => 'sk-test',
      'default_model' => 'gpt-4o-mini',
      'issue_assistant_instructions' => 'Be brief.'
    }
    User.current = User.find(2)
  end

  def test_summarize_uses_ruby_llm_chat
    issue = Issue.find(1)
    fake_response = Struct.new(:content).new('Summary text')
    fake_chat = mock('chat')
    fake_chat.stubs(:with_instructions).returns(fake_chat)
    fake_chat.stubs(:ask).returns(fake_response)
    RubyLLM.stubs(:chat).returns(fake_chat)

    summary = LlmIssueAssistant.new(issue).summarize
    assert_equal 'Summary text', summary
  end

  def test_summarize_requires_configuration
    Setting.plugin_redmine_ruby_llm = {'openai_api_key' => '', 'anthropic_api_key' => ''}
    ENV.delete('OPENAI_API_KEY')
    ENV.delete('ANTHROPIC_API_KEY')

    assert_raises RedmineRubyLlm::ConfigurationError do
      LlmIssueAssistant.new(Issue.find(1)).summarize
    end
  end
end
