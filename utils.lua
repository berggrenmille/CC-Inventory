local function store(filename, object)
    -- Open the file in write mode
    local file = fs.open(filename, "w")
    if not file then
        error("Failed to open file for writing: " .. filename)
    end

    -- Use textutils.serialize to convert the object to a string
    local serializedObject = textutils.serialize(object)

    -- Write the serialized string to the file
    file.write(serializedObject)
    file.close()
end

-- Function to load a Lua object from a file
local function load(filename)
    -- Open the file in read mode
    local file = fs.open(filename, "r")
    if not file then
        store(filename, {})
        file = fs.open(filename, "r")
    end

    -- Read the entire file contents
    local serializedObject = file.readAll()
    file.close()

    -- Use textutils.unserialize to convert the string back to an object
    local object = textutils.unserialize(serializedObject)
    if not object then
        error("Failed to deserialize object from file: " .. filename)
    end

    return object
end

return {
    store = store,
    load = load
}
