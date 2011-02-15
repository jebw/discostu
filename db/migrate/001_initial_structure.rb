class InitialStructure < ActiveRecord::Migration
  
  def self.up
    create_table 'artists', :force => true do |t|
      t.string :name
    end
    
    create_table 'albums', :force => true do |t|
      t.string :name
      t.integer :artist_id
      t.integer :disc_no
      t.integer :year
    end
    
    create_table 'tracks', :force => true do |t|
      t.integer :track_no
      t.string :title
      t.integer :length, :default => 0
      t.integer :playcount
      t.integer :artist_id
      t.integer :album_id
    end
    
    create_table 'genres', :force => true do |t|
      t.string :name
    end
    
    create_table 'playlist_items', :force => true do |t|
      t.integer :track_id
      t.boolean :current
      t.integer :position
    end
    
  end
  
  def self.down
    raise ActiveRecord::IrreversibleMigration, "This is the initial structure"
  end
  
end