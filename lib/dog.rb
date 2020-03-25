require_relative '../config/environment'

class Dog
    attr_accessor :id, :name, :breed
    def initialize(id: nil, name:, breed:)
        @id, @name, @breed = id, name, breed
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs(id INTEGER PRIMARY KEY, name TEXT, breed TEXT);
        SQL

        DB[:conn].execute(sql)
    end

    def self.create(name:, breed:)
        dog = self.new(name: name, breed: breed)
        dog.save
        dog
    end

    def self.new_from_db(row)
        id, name, breed = row
        self.new(id: id, name: name, breed: breed)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs")
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * FROM dogs WHERE id = ? LIMIT 1
        SQL

        DB[:conn].execute(sql, id).map do |row|
            self.new_from_db(row)
        end.first # nested array so grab the first element
    end

    # def self.find_by_name(name)
    #     sql = <<-SQL
    #       SELECT *
    #       FROM dogs
    #       WHERE name = ?
    #       LIMIT 1
    #     SQL
    
    #     DB[:conn].execute(sql,name).map do |row|
    #       self.new_from_db(row)
    #     end.first
    # end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT *
            FROM dogs 
            WHERE name = ?
            LIMIT 1
        SQL

        DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ? AND breed = ?
            LIMIT 1
        SQL

        dog = DB[:conn].execute(sql, name, breed)

        if !dog.empty?
            id, name, breed = dog.first
            dog = self.new(id: id, name: name, breed: breed)
        else
            dog = self.create(name: name, breed: breed)
        end
        dog
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs(name, breed)
            VALUES (? , ?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def update
        sql = <<-SQL
            UPDATE dogs SET name = ?, breed = ? WHERE id = ?
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end