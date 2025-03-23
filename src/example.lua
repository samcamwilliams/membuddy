-- Create some test data structures
local function create_test_data()
    -- Create a global table with various data types
    GlobalTable = {
        small_string = "hello world",
        number = 12345,
        boolean = true,
        
        -- Nested tables
        nested = {
            level1 = {
                level2 = {
                    level3 = {
                        level4 = "deeply nested value"
                    }
                }
            }
        },
        
        -- Array with many items
        array = {},
        
        -- Table with many string keys
        string_keys = {}
    }
    
    -- Fill the array with data
    for i = 1, 1000 do
        GlobalTable.array[i] = "item " .. i
    end
    
    -- Fill the string keys table
    for i = 1, 100 do
        GlobalTable.string_keys["key_" .. i] = "value_" .. i
    end
    
    -- Create circular reference
    GlobalTable.circular = {name = "parent"}
    GlobalTable.circular.child = {name = "child", parent = GlobalTable.circular}
    GlobalTable.circular_ref = GlobalTable.circular
end

-- Run the example
local function run_example()
    print("MemBuddy Example")
    print("===============\n")
    
    -- Create test data
    create_test_data()
    
    -- Profile globals with different depth settings
    print("Profile of all globals with depth = 2:")
    local results1 = membuddy.profile({depth = 2})
    membuddy.print(results1)
    
    print("\n\nProfile of all globals with depth = 3:")
    local results2 = membuddy.profile({depth = 3})
    membuddy.print(results2)
    
    print("\n\nProfile of specific table with depth = 4:")
    local results3 = membuddy.profile(GlobalTable.nested, {depth = 4})
    membuddy.print(results3)
    
    print("\n\nProfile with no options (defaults to all globals):")
    -- You can simply call membuddy.print() to profile and print globals
    membuddy.print()
    
    print("\n\nWorking with raw results:")
    -- You can access the raw results programmatically
    local largest_item = nil
    local largest_size = 0
    
    for path, size in pairs(results2.sizes) do
        if size > largest_size then
            largest_size = size
            largest_item = path
        end
    end
    
    print("Largest memory consumer: " .. largest_item .. 
          " (" .. membuddy.format_size(largest_size) .. ")")
    
    print("\nShowing circular references:")
    for path, target in pairs(results2.circular) do
        print(string.format("    %s: %s", path, target))
    end
    
    print("\nTotal bytes used: " .. tostring(results2.totalSize))
end

run_example()