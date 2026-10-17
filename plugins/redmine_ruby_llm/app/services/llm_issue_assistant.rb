# frozen_string_literal: true

class LlmIssueAssistant
  def initialize(issue, user: User.current)
    @issue = issue
    @user = user
  end

  def summarize
    RedmineRubyLlm.require_configuration!

    chat = RubyLLM.chat(model: RedmineRubyLlm.default_model)
    chat.with_instructions(RedmineRubyLlm.issue_assistant_instructions)
    response = chat.ask(prompt)
    response.content.to_s
  end

  private

  def prompt
    journals = @issue.journals.includes(:user, :details).reorder(:created_on).last(20)
    notes = journals.filter_map do |journal|
      next if journal.notes.blank?

      "#{journal.user} (#{journal.created_on}): #{journal.notes}"
    end.join("\n\n")

    <<~PROMPT
      Summarize this Redmine issue for a teammate catching up.

      Project: #{@issue.project}
      Tracker: #{@issue.tracker}
      Status: #{@issue.status}
      Priority: #{@issue.priority}
      Assignee: #{@issue.assigned_to || 'unassigned'}
      Subject: #{@issue.subject}

      Description:
      #{@issue.description.presence || '(none)'}

      Recent notes:
      #{notes.presence || '(none)'}

      Return:
      1. A short summary (2-4 sentences)
      2. Current status and blockers
      3. Suggested next steps
    PROMPT
  end
end
