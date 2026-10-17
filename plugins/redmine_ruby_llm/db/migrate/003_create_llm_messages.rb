# frozen_string_literal: true

class CreateLlmMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :llm_messages do |t|
      t.references :llm_chat, null: false, foreign_key: {to_table: :llm_chats}
      t.string :role, null: false
      t.text :content
      t.boolean :cache_until_here, null: false, default: false
      t.string :cache_ttl
      t.text :thinking_text
      t.text :thinking_signature
      t.json :citations
      t.json :server_tool_calls
      t.json :raw_content
      t.json :raw_reasoning
      t.string :finish_reason
      t.timestamps
    end
  end
end
