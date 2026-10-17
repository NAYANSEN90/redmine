# frozen_string_literal: true

require_relative '../test_helper'

class LlmIssueAssistantsControllerTest < Redmine::ControllerTest
  fixtures :projects, :users, :roles, :members, :member_roles,
           :enabled_modules, :trackers, :issue_statuses, :issues,
           :enumerations, :projects_trackers, :journals

  def setup
    @project = Project.find(1)
    @project.enabled_module_names = (@project.enabled_module_names + ['ruby_llm']).uniq
    Role.find(1).add_permission! :use_llm_issue_assistant
    Setting.plugin_redmine_ruby_llm = {
      'openai_api_key' => 'sk-test',
      'default_model' => 'gpt-4o-mini'
    }
    @request.session[:user_id] = 2
  end

  def test_create_summarizes_issue
    fake_response = Struct.new(:content).new('Issue overview')
    fake_chat = mock('chat')
    fake_chat.stubs(:with_instructions).returns(fake_chat)
    fake_chat.stubs(:ask).returns(fake_response)
    RubyLLM.stubs(:chat).returns(fake_chat)

    post :create, params: {issue_id: 1}

    assert_redirected_to issue_path(1)
    assert_equal 'Issue overview', flash[:llm_issue_summary]
  end
end

