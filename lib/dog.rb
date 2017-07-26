class Dog

  attr_accessor :name, :breed, :id

  def initialize(args)
    @name = args[:name]
    @breed = args[:breed]
    @id = nil
    if args[:id] != nil
      @id = args[:id]
    end
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs
    SQL
    DB[:conn].execute(sql)
  end

  def self.create(args)
    name = args[:name]
    breed = args[:breed]
    doge = Dog.new(args)
    doge.save
    doge
  end

  def save
    if self.id
      self.update
    else
      sql= <<-SQL
        INSERT INTO dogs(name, breed) VALUES (? , ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
     end
    self
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed= ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.find_by_id(id)
    sql= <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL
    tuple = DB[:conn].execute(sql, id)[0]

    hash = {:id => tuple[0], :name => tuple[1], :breed => tuple[2]}
    dog = self.new(hash)
    dog
  end

  def self.find_or_create_by(args)
    name = args[:name]
    breed = args[:breed]
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1", name, breed).first
    # binding.pry
    if dog == nil || dog == []
      the_dog = self.create(args)
    else
      dog_hash = {id: dog[0], name: dog[1], breed: dog[2]}
      the_dog = Dog.new(dog_hash)
      # binding.pry
    end
    the_dog
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    result = DB[:conn].execute(sql, name)[0]
    dog = new_from_db(result)
    dog
  end

  def self.new_from_db(tuple)
    hash = {:id => tuple[0], :name => tuple[1], :breed => tuple[2]}
    dog = self.new(hash)
    dog
  end

end
