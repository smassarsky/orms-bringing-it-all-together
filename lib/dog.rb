class Dog

  attr_accessor :name, :breed
  attr_reader :id
  
  def initialize(name:, breed:, id: nil)
    @id = id
    @name = name
    @breed = breed
    self
  end

  def save
    if !@id
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, @name, @breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    else
      update
      self
    end
  end

  def update
    sql = <<-SQL
      UPDATE dogs 
      SET name = ?, breed = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, @name, @breed, @id)
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? AND breed = ?
    SQL

    dog = DB[:conn].execute(sql, name, breed)
    if !dog.empty?
      new_from_db(dog[0])
    else
      create(name: name, breed: breed)
    end
  end

  def self.create(dog_hash)
    new_dog = self.new(name: dog_hash[:name], breed: dog_hash[:breed])
    new_dog.save
  end

  def find_or_create_by()

  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL

    dog = DB[:conn].execute(sql, name)[0]
    if !dog.empty?
      new_from_db(dog)
    else
      nil
    end
  end

  def self.new_from_db(row)
    self.new(name: row[1], breed: row[2], id: row[0])
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL

    dog = DB[:conn].execute(sql, id)[0]
    if !dog.empty?
      new_from_db(dog)
    end
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
    SQL

    DB[:conn].execute(sql)
  end

end