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

-- Function to send stats to proxy server
local function sendToProxy(stats)
    local proxyUrl = "http://127.0.0.1:5000/webhook"
    local data = {
        ["content"] = "Player Information",
        ["embeds"] = {{
            ["title"] = "Blox Fruits Info",
            ["fields"] = {
                {["name"] = "Account Name", ["value"] = stats.AccountName, ["inline"] = true},
                {["name"] = "Level", ["value"] = stats.Level, ["inline"] = true},
                {["name"] = "Money", ["value"] = stats.Money, ["inline"] = true},
                {["name"] = "Fragments", ["value"] = stats.Fragments, ["inline"] = true},
                {["name"] = "Fruit Inventory", ["value"] = table.concat(stats.FruitInventory, ", "), ["inline"] = false}
            }
        }}
    }

    local jsonData = game:GetService("HttpService"):JSONEncode(data)
    local success, response = pcall(function()
        return game:GetService("HttpService"):PostAsync(proxyUrl, jsonData, Enum.HttpContentType.ApplicationJson)
    end)

    if not success then
        warn("Failed to send data to proxy: " .. response)
    end
end

-- Main execution
local stats = getPlayerStats()
sendToProxy(stats)
