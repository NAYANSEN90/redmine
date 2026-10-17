# frozen_string_literal: true

require_relative 'redmine_ruby_llm/hooks'
require_relative 'redmine_ruby_llm/project_patch'

module RedmineRubyLlm
  class ConfigurationError < StandardError; end

  module_function

  def settings
    Setting.plugin_redmine_ruby_llm || {}
  end

  def setting(key)
    value = settings[key.to_s].to_s.strip
    value.presence
  end

  def default_model
    setting(:default_model) || 'gpt-4o-mini'
  end

  def configured?
    openai_api_key.present? || anthropic_api_key.present?
  end

  def openai_api_key
    ENV['OPENAI_API_KEY'].presence || setting(:openai_api_key)
  end

  def openai_api_base
    ENV['OPENAI_API_BASE'].presence || setting(:openai_api_base)
  end

  def anthropic_api_key
    ENV['ANTHROPIC_API_KEY'].presence || setting(:anthropic_api_key)
  end

  def issue_assistant_instructions
    setting(:issue_assistant_instructions) ||
      'You are a helpful project assistant in Redmine. Summarize clearly and stay factual.'
  end

  def apply_configuration!
    return unless defined?(RubyLLM)

    RubyLLM.configure do |config|
      config.logger = Rails.logger
      config.openai_api_key = openai_api_key if openai_api_key
      config.openai_api_base = openai_api_base if openai_api_base
      config.anthropic_api_key = anthropic_api_key if anthropic_api_key
      config.default_model = default_model
    end
  end

  def require_configuration!
    apply_configuration!
    return if configured?

    raise ConfigurationError,
          'Configure an OpenAI or Anthropic API key in Administration → Plugins → RubyLLM, ' \
          'or set OPENAI_API_KEY / ANTHROPIC_API_KEY.'
  end
end
