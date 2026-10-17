# frozen_string_literal: true

require_relative '../test_helper'

class RedmineRubyLlmTest < ActiveSupport::TestCase
  def setup
    Setting.plugin_redmine_ruby_llm = {
      'openai_api_key' => '',
      'anthropic_api_key' => '',
      'default_model' => 'gpt-4o-mini'
    }
    ENV.delete('OPENAI_API_KEY')
    ENV.delete('ANTHROPIC_API_KEY')
  end

  def test_configured_with_plugin_setting
    Setting.plugin_redmine_ruby_llm = Setting.plugin_redmine_ruby_llm.merge(
      'openai_api_key' => 'sk-test'
    )
    assert RedmineRubyLlm.configured?
  end

  def test_env_overrides_plugin_setting
    Setting.plugin_redmine_ruby_llm = Setting.plugin_redmine_ruby_llm.merge(
      'openai_api_key' => 'from-settings'
    )
    ENV['OPENAI_API_KEY'] = 'from-env'
    assert_equal 'from-env', RedmineRubyLlm.openai_api_key
  ensure
    ENV.delete('OPENAI_API_KEY')
  end

  def test_require_configuration_raises_when_missing
    assert_raises RedmineRubyLlm::ConfigurationError do
      RedmineRubyLlm.require_configuration!
    end
  end
end
