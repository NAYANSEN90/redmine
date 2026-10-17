# frozen_string_literal: true

class LlmIssueAssistantsController < ApplicationController
  before_action :find_issue
  before_action :authorize

  def create
    summary = LlmIssueAssistant.new(@issue).summarize
    flash[:notice] = l(:notice_llm_issue_summary_ready)
    flash[:llm_issue_summary] = summary
    redirect_to issue_path(@issue)
  rescue RedmineRubyLlm::ConfigurationError, RubyLLM::Error => e
    flash[:error] = e.message
    redirect_to issue_path(@issue)
  end

  private

  def find_issue
    @issue = Issue.find(params[:issue_id])
    @project = @issue.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
