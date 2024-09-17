local HttpService = game:GetService("HttpService")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

-- Thay thế getPlayerStats() bằng cách lấy dữ liệu người chơi thực tế
local function getPlayerStats(player)
    return {
        AccountName = player.Name,
        Score = 100 -- Ví dụ điểm số, thay đổi theo dữ liệu thực tế
    }
end

-- Hàm lưu thông tin vào DataStore
local function saveStatsToDataStore(stats)
    local dataStore = DataStoreService:GetDataStore("PlayerStatsDataStore")
    local success, err = pcall(function()
        dataStore:SetAsync(stats.AccountName, stats)
    end)
    if not success then
        warn("Lỗi khi lưu dữ liệu vào DataStore: " .. tostring(err))
        return nil
    end
    return stats.AccountName
end

-- Hàm gửi thông tin đến webhook
local function sendToWebhook(stats)
    local webhookUrl = "https://discord.com/api/webhooks/1285247042230157437/WD8AGGxsVjswhx82mNf4spBFg5FmL-UkaQBAyOF2V4_zpUUQTL4cDUO0a6lkXfsvJKYZ"
    local embed = {
        ["title"] = "Thông tin người chơi",
        ["description"] = "Tên tài khoản: " .. stats.AccountName .. "\nĐiểm số: " .. stats.Score,
        ["color"] = 0x00FF00
    }
    local data = {
        ["embeds"] = { embed }
    }
    local response = HttpService:PostAsync(webhookUrl, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson)
    if response then
        print("Đã gửi thông tin đến Discord.")
    else
        warn("Lỗi khi gửi thông tin đến Discord.")
    end
end

-- Thực thi chính
local player = Players.LocalPlayer or Players:GetPlayers()[1] -- Thay đổi cách lấy người chơi theo nhu cầu
local stats = getPlayerStats(player)
local key = saveStatsToDataStore(stats)
if key then
    sendToWebhook(stats)
else
    warn("Không thể lưu thông tin người chơi vào DataStore.")
end
