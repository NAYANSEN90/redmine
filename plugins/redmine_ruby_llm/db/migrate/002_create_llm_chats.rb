# frozen_string_literal: true

class CreateLlmChats < ActiveRecord::Migration[8.1]
  def change
    create_table :llm_chats do |t|
      t.references :ruby_llm_model, null: false,
                   foreign_key: {to_table: :ruby_llm_models}
      t.references :project, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.boolean :cancelled, null: false, default: false
      t.timestamps
    end
  end
end
