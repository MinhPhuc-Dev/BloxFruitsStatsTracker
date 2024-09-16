-- Ensure Fluxus Executor is open and connected to Roblox

-- Function to get player stats
local function getPlayerStats()
    local player = game.Players.LocalPlayer
    local stats = {
        AccountName = player.Name,
        Level = player.Data.Level.Value,
        Money = player.Data.Beli.Value,
        Fragments = player.Data.Fragments.Value,
        FruitInventory = {}
    }

    -- Get fruit inventory
    for _, fruit in pairs(player.Data.FruitInventory:GetChildren()) do
        table.insert(stats.FruitInventory, fruit.Name)
    end

    return stats
end

-- Function to send stats to Discord webhook
local function sendToDiscord(stats)
    local webhookUrl = "https://discord.com/api/webhooks/1285079613281931316/b-kuGNqwAx4PkFDSXNBlxt9t8Fy3QLmVYkxg7rtmroMMq_z-OIw3_JHvIqdgMLfDY4zZ"
    local data = {
        ["content"] = "Player Stats",
        ["embeds"] = {{
            ["title"] = "Blox Fruits Stats",
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
    game:GetService("HttpService"):PostAsync(webhookUrl, jsonData, Enum.HttpContentType.ApplicationJson)
end

-- Main execution
local stats = getPlayerStats()
sendToDiscord(stats)
