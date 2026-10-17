# frozen_string_literal: true

namespace :redmine_ruby_llm do
  desc 'Load the RubyLLM model registry into the database'
  task load_models: :environment do
    require 'active_record/base'
    RubyLLM.models.load_from_json
    model_class = RubyLLM::ActiveRecord::Model
    model_class.save_to_database
    puts "Loaded #{model_class.count} models into the database"
  end
end
