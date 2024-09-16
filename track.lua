-- Ensure Fluxus Executor is open and connected to Roblox

-- Function to get player stats
local function getPlayerStats()
    local player = game.Players.LocalPlayer
    local stats = {
        AccountName = player.Name,
        Level = player:FindFirstChild("Data") and player.Data:FindFirstChild("Level") and player.Data.Level.Value or "N/A",
        Money = player:FindFirstChild("Data") and player.Data:FindFirstChild("Beli") and player.Data.Beli.Value or "N/A",
        Fragments = player:FindFirstChild("Data") and player.Data:FindFirstChild("Fragments") and player.Data.Fragments.Value or "N/A",
        FruitInventory = {}
    }

    -- Get fruit inventory if available
    if player:FindFirstChild("Data") and player.Data:FindFirstChild("FruitInventory") then
        for _, fruit in pairs(player.Data.FruitInventory:GetChildren()) do
            table.insert(stats.FruitInventory, fruit.Name)
        end
    else
        stats.FruitInventory = {"No fruits found"}
    end

    return stats
end

-- Function to create folder and save stats to a text file
local function saveStatsToFile(stats)
    local folderName = "MPhuc-stat"
    local fileName = folderName .. "/" .. stats.AccountName .. ".txt"
    
    -- Create folder if it doesn't exist
    if not isfolder(folderName) then
        makefolder(folderName)
    end

    local file = io.open(fileName, "w")
    if file then
        file:write("Account Name: " .. stats.AccountName .. "\n")
        file:write("Level: " .. stats.Level .. "\n")
        file:write("Money: " .. stats.Money .. "\n")
        file:write("Fragments: " .. stats.Fragments .. "\n")
        file:write("Fruit Inventory: " .. table.concat(stats.FruitInventory, ", ") .. "\n")
        file:close()
    else
        warn("Failed to open file for writing")
    end
    return fileName
end

-- Function to send file contents to webhook
local function sendFileToWebhook(fileName)
    local webhookUrl = "https://discord.com/api/webhooks/1285079613281931316/b-kuGNqwAx4PkFDSXNBlxt9t8Fy3QLmVYkxg7rtmroMMq_z-OIw3_JHvIqdgMLfDY4zZ"
    local file = io.open(fileName, "r")
    if file then
        local content = file:read("*all")
        file:close()

        local data = {
            ["content"] = "Player Information",
            ["embeds"] = {{
                ["title"] = "Blox Fruits Info",
                ["description"] = content
            }}
        }

        local jsonData = game:GetService("HttpService"):JSONEncode(data)
        local success, response = pcall(function()
            return game:GetService("HttpService"):PostAsync(webhookUrl, jsonData, Enum.HttpContentType.ApplicationJson)
        end)

        if not success then
            warn("Failed to send data to webhook: " .. response)
        end
    else
        warn("Failed to open file for reading")
    end
end

-- Main execution
local stats = getPlayerStats()
local fileName = saveStatsToFile(stats)
sendFileToWebhook(fileName)
