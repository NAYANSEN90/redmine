# frozen_string_literal: true

module RedmineRubyLlm
  class Hooks < Redmine::Hook::ViewListener
    render_on :view_issues_show_description_bottom,
              partial: 'hooks/redmine_ruby_llm/issue_assistant'

    def view_layouts_base_html_head(_context={})
      stylesheet_link_tag 'redmine_ruby_llm', plugin: 'redmine_ruby_llm'
    end
  end
end
