class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(id:nil, name:, breed:)
    @name = name
    @breed = breed
    @id = id
    end

    def self.create_table
    sql =  <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
    id INTEGER PRIMARY KEY,
    name TEXT,
    breed TEXT
    )
    SQL
    DB[:conn].execute(sql)
    end

    def self.drop_table
    sql= <<-SQL
    DROP TABLE IF EXISTS dogs
    SQL
    DB[:conn].execute(sql)
    end

    def save
      sql = <<-SQL
        INSERT INTO dogs (name, breed) 
        VALUES (?, ?)
      SQL
   
      DB[:conn].execute(sql, self.name, self.breed)
  
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end

    def self.create(name: , breed:)
      dog = Dog.new(name: name, breed: breed)
      dog.save
      dog
    end

    def self.new_from_db(row)
      self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_id(id)
      sql = "SELECT * FROM dogs WHERE id = ?"
      result = DB[:conn].execute(sql, id)[0]
      Dog.new_from_db(result)
    end

    def self.find_or_create_by(name:, breed:)
      dogs = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
      return self.new_from_db(dogs[0]) if !dogs.empty?
      self.create(name: name, breed: breed)
    end

    def self.find_by_name(name)
      sql = "SELECT * FROM dogs WHERE name = ?"
    result = DB[:conn].execute(sql, name)[0]
    self.new_from_db(result)
    end

    def update
      sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
      DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end