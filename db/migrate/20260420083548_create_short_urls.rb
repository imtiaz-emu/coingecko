class CreateShortUrls < ActiveRecord::Migration[7.2]
  def change
    create_table :short_urls do |t|
      t.string   :short_code,       null: false, limit: 15
      t.text     :target_url,       null: false
      t.string   :title,            limit: 500
      t.datetime :title_fetched_at
      t.timestamps
    end
    add_index :short_urls, :short_code, unique: true
  end
end
