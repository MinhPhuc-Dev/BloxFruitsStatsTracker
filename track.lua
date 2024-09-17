-- Lấy các service cần thiết
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- Hàm lấy thông tin người chơi
local function getPlayerStats()
    local player = Players.LocalPlayer
    return {
        AccountName = player.Name,
        UserId = player.UserId,
        Score = 100 -- Đây là điểm số ví dụ, bạn có thể thay đổi theo ý muốn
    }
end

-- Hàm gửi thông tin đến webhook Discord
local function sendToWebhook(stats)
    local webhookUrl = "https://discord.com/api/webhooks/1285247042230157437/WD8AGGxsVjswhx82mNf4spBFg5FmL-UkaQBAyOF2V4_zpUUQTL4cDUO0a6lkXfsvJKYZ"
    local embed = {
        ["title"] = "Thông tin người chơi",
        ["description"] = "Tên tài khoản: " .. stats.AccountName .. "\nID Người dùng: " .. stats.UserId .. "\nĐiểm số: " .. stats.Score,
        ["color"] = 0x00FF00
    }
    local data = {
        ["embeds"] = { embed }
    }

    -- Gửi dữ liệu bằng PostAsync
    local success, response = pcall(function()
        return HttpService:PostAsync(webhookUrl, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson)
    end)

    if success then
        print("Đã gửi thông tin đến Discord.")
    else
        warn("Lỗi khi gửi thông tin đến Discord: " .. tostring(response))
    end
end

-- Thực thi
local stats = getPlayerStats()
sendToWebhook(stats)
