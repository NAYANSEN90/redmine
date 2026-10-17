# frozen_string_literal: true

require_relative '../test_helper'

class LlmChatsControllerTest < Redmine::ControllerTest
  fixtures :projects, :users, :roles, :members, :member_roles,
           :enabled_modules, :trackers, :issue_statuses, :issues,
           :enumerations, :projects_trackers

  def setup
    @project = Project.find(1)
    @project.enabled_module_names = (@project.enabled_module_names + ['ruby_llm']).uniq
    Role.find(1).add_permission! :view_llm_chats
    Role.find(1).add_permission! :manage_llm_chats
    Setting.plugin_redmine_ruby_llm = {
      'openai_api_key' => 'sk-test',
      'default_model' => 'gpt-4o-mini'
    }
    @request.session[:user_id] = 2
  end

  def test_index
    get :index, params: {project_id: @project.id}
    assert_response :success
    assert_select 'h2', text: /AI chats/
  end

  def test_new
    get :new, params: {project_id: @project.id}
    assert_response :success
  end

  def test_create_without_prompt
    ensure_model_registry!

    assert_difference 'LlmChat.count', 1 do
      post :create, params: {
        project_id: @project.id,
        llm_chat: {title: 'Planning'},
        prompt: ''
      }
    end
    chat = LlmChat.order(:id).last
    assert_redirected_to project_llm_chat_path(@project, chat)
    assert_equal 'Planning', chat.title
  end

  private

  def ensure_model_registry!
    return if RubyLLM::ActiveRecord::Model.exists?(model_id: 'gpt-4o-mini')

    RubyLLM.models.load_from_json
    RubyLLM::ActiveRecord::Model.save_to_database
  rescue StandardError
    RubyLLM::ActiveRecord::Model.create!(
      model_id: 'gpt-4o-mini',
      name: 'gpt-4o-mini',
      provider: 'openai',
      modalities: {},
      capabilities: [],
      pricing: {},
      metadata: {}
    )
  end
end
