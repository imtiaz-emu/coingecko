class CreateClickEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :click_events do |t|
      t.references :short_url,      null: false, foreign_key: true
      t.datetime   :clicked_at,     null: false
      t.string     :ip_address,     limit: 45
      t.string     :country,        limit: 100
      t.string     :region,         limit: 100
      t.string     :city,           limit: 100
      t.text       :user_agent
      t.text       :referrer
      t.datetime   :geo_resolved_at
      t.timestamps
    end

    add_index :click_events, [:short_url_id, :clicked_at]
    add_index :click_events, :clicked_at
    add_index :click_events, :id,
              where: "geo_resolved_at IS NULL",
              name: "idx_click_events_geo_pending"
  end
end
