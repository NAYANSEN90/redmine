# frozen_string_literal: true

class LlmChatsController < ApplicationController
  menu_item :llm_chats

  before_action :find_project_by_project_id
  before_action :authorize
  before_action :ensure_ruby_llm_configured, except: [:index, :show]
  before_action :find_chat, only: [:show, :destroy]

  helper :sort
  include SortHelper

  def index
    sort_init 'updated_at', 'desc'
    sort_update %w[title created_at updated_at]

    scope = @project.llm_chats.includes(:user).order(sort_clause)
    @chat_count = scope.count
    @chat_pages = Paginator.new @chat_count, per_page_option, params['page']
    @chats = scope.limit(@chat_pages.per_page).offset(@chat_pages.offset).to_a
  end

  def show
    @messages = @chat.llm_messages.order(:created_at, :id)
  end

  def new
    @chat = @project.llm_chats.build(user: User.current)
  end

  def create
    RedmineRubyLlm.require_configuration!

    @chat = @project.llm_chats.build(chat_params)
    @chat.user = User.current
    @chat.model = RedmineRubyLlm.default_model

    if @chat.save
      prompt = params[:prompt].to_s.strip
      if prompt.present?
        @chat.with_instructions(RedmineRubyLlm.issue_assistant_instructions)
        @chat.ask(prompt)
      end
      redirect_to project_llm_chat_path(@project, @chat)
    else
      render :new, status: :unprocessable_entity
    end
  rescue RedmineRubyLlm::ConfigurationError, RubyLLM::Error => e
    flash.now[:error] = e.message
    @chat ||= @project.llm_chats.build(chat_params.merge(user: User.current))
    render :new, status: :unprocessable_entity
  end

  def destroy
    @chat.destroy
    redirect_to project_llm_chats_path(@project), notice: l(:notice_successful_delete)
  end

  private

  def find_chat
    @chat = @project.llm_chats.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def chat_params
    params.fetch(:llm_chat, {}).permit(:title)
  end

  def ensure_ruby_llm_configured
    return if RedmineRubyLlm.configured?

    flash[:error] = l(:error_llm_not_configured)
    redirect_to project_llm_chats_path(@project)
  end
end
