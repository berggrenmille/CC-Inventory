-- startup.lua
-- fetch dependency
shell.run("wget run https://basalt.madefor.cc/install.lua release latest.lua")

local baseUrl = "https://raw.githubusercontent.com/berggrenmille/CC-Inventory/main/"

-- List of files to download
local files = {
    "main.lua",
    "globals.lua",
    "inventory.lua",
    "network.lua",
    "gui.lua",
    "utils.lua"
}

-- Function to download a file with error handling
local function downloadFile(file)
    local url = baseUrl .. file
    print("Downloading " .. file .. " from " .. url)
    local success, message = pcall(function()
        shell.run("rm", file)
        shell.run("wget", url, file)
    end)

    if not success then
        print("Failed to download " .. file .. ": " .. message)
    end
end

-- Download each file
for _, file in ipairs(files) do
    downloadFile(file)
end

-- Run main.lua after downloading all files
shell.run("main.lua")
