local debug = false
local function debugPrint(...)
    if debug then
        print(...)
    end
end
local function setDebug(value)
    debug = value
end

return {
    debugPrint = debugPrint,
    setDebug = setDebug
}
