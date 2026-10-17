# frozen_string_literal: true

class LlmMessagesController < ApplicationController
  menu_item :llm_chats

  before_action :find_project_by_project_id
  before_action :authorize
  before_action :find_chat

  def create
    RedmineRubyLlm.require_configuration!

    content = params[:content].to_s.strip
    if content.blank?
      flash[:error] = l(:error_llm_message_blank)
      redirect_to project_llm_chat_path(@project, @chat) and return
    end

    @chat.ask(content)
    redirect_to project_llm_chat_path(@project, @chat)
  rescue RedmineRubyLlm::ConfigurationError, RubyLLM::Error => e
    flash[:error] = e.message
    redirect_to project_llm_chat_path(@project, @chat)
  end

  private

  def find_chat
    @chat = @project.llm_chats.find(params[:llm_chat_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
