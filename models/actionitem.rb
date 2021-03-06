require 'tty-table'
require 'colorize'
require 'yaml'
require 'tty-link'
require 'pastel'

class ActionItem
    attr_accessor :id, :action, :category, :priority, :sub_array, :todolist, :actions_created

    @@actions_created ||= begin
    YAML.load(File.read("actionscreated.yml"))
        rescue
            []
        end

    @@todolist ||= begin
        YAML.load(File.read("todolist.yml"))
            rescue
                []
            end

    def initialize(action,category,priority)
        @action = action
        @category = category
        @priority = priority
        @id = @@actions_created.length + 1
        @@todolist << ([@id,@action,@category,@priority])
        @@actions_created << ([@id])
    rescue
        Errors.major
    end

    def to_s
        return "ID: #{@id} | Action Item: #{@action.capitalize} | Category: #{@category.capitalize} | Priority: #{@priority.capitalize} "
    end

    def self.display
        if  @@todolist.empty? == false
        puts
        table = TTY::Table.new(["  ID  ","  Action Item  ","  Category  ","  Priority  "], @@todolist.sort)
        puts table.render(:ascii) 
        else
            Errors.no_active_items
        end
    rescue
        Errors.major
    end

    def self.sub_array
        if @@todolist.empty? == false
        puts "Please enter a category or press enter to show all action items without a category"
        target = gets.strip.downcase
        sub_array = @@todolist.select { |row| row.include?(target) }
            if sub_array.empty? == false
        puts
        table = TTY::Table.new(["  ID  ","  Action Item  ","  Category  ","  Priority  "], sub_array)
        puts "Here are the action items from the #{target} category: "
        puts table.render(:ascii)
            else
                Errors.no_match_category
            end
        else
            Errors.error_no_action_items
        end
    rescue
        Errors.major
    end

    def self.edit
        if @@todolist.empty? == false
        puts "Please enter the ID of the action item you want to edit:"
        targetID = gets.strip.downcase.to_i
        sub_array = @@todolist.select { |row| row.include?(targetID) }

            if sub_array.empty? == false
                puts "Please enter the updated action item:"
                update_action = gets.strip
                puts "Please enter the updated category:"
                update_category = gets.strip
                puts "Please enter the updated priority:"
                update_priority = gets.strip
                sub_array.replace([targetID,update_action,update_category,update_priority])
                @@todolist.delete_at(targetID-1)
                @@todolist.insert(targetID-1, sub_array) 
                puts "Here is your updated action item:"
                puts "ID: #{targetID} | Action Item: #{update_action} | Category: #{update_category} | Priority: #{update_priority}"
                puts
            else
                Errors.id_not_found
            end
        else
            Errors.error_no_action_items
        end
    rescue
        Errors.major
    end

    def self.delete
        if @@todolist.empty? == false
            puts
            puts "Please enter the ID of the action item you want to delete:"
            targetID = gets.strip.to_i
                if @@todolist.flatten.include?(targetID) == true
                    puts "The action item has been deleted."
                    puts
                else 
                    Errors.id_not_found
                end 
            @@todolist.delete_if { |row| row.include?(targetID) }
        else
            Errors.error_no_action_items 
        end
    rescue
        Errors.major
    end

    def self.save
        File.open("todolist.yml", 'w') { |file| file.write(@@todolist.to_yaml) }
        File.open("actionscreated.yml", 'w') { |file| file.write(@@actions_created.to_yaml) }
    end

end