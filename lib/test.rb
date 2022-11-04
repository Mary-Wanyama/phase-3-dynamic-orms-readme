# require_relative "../config/environment.rb"
require 'active_support/inflector'

class songs
    def self.table_name
        self.to_s.downcase.pluralize 
        #self is the current class name, accompanying methods make the name suitable for the database table
    end
    def column_names
         
        #returns the names of the columns in the table
        DB[:conn].results_as_hash=true
        sql = "PRAGMA table_info('#{table_name}')"
        table_info.each do |column| 
            column_names << column["name"]
        end

        column_name.compact
        #compact gets rid of any nil values in the array
    end

    self.column_names.each  do |col_name|
        attr_accessor col_name.to_sym
    end

    def initialize(options={})
        options.each do |property, value|
            self.send("#{property}=", value)
        end
    end
      def table_name_for_insert 
        self.class.table_name
      end
      def column_names_for_insert
        self.class.column_names.delete_in {|col| col=="id"}.join(", ")
      end
      def values_for_insert
        values = []
        self.class.column_names.each do |col_name|
          values << "'#{send(col_name)}'" unless send(col_name).nil?
        end
        values.join(", ")
      end
      def save
        DB[:conn].execute("INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (?)", [values_for_insert])
      
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
      end
      def self.find_by_name(name)
        sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
        DB[:conn].execute(sql)
      end
end