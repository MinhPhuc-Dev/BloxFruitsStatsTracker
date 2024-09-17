local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- Hàm lấy thông tin người chơi
local function getPlayerStats()
    local player = Players.LocalPlayer
    return {
        AccountName = player.Name,
        UserId = player.UserId,
        Score = 100 -- Điểm số giả định
    }
end

-- Hàm gửi thông tin đến Webhook.site
local function sendToWebhook(stats)
    -- URL Webhook.site mà bạn đã lấy ở Bước 1
    local proxyUrl = "https://webhook.site/3dae2b45-77d7-4f7b-a8ae-2e82f877e869" -- Thay bằng URL Webhook.site của bạn
    local data = {
        ["AccountName"] = stats.AccountName,
        ["UserId"] = stats.UserId,
        ["Score"] = stats.Score
    }

    -- Gửi yêu cầu POST tới Webhook.site
    local success, response = pcall(function()
        return HttpService:PostAsync(proxyUrl, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson)
    end)

    if success then
        print("Đã gửi thông tin đến Webhook.site.")
    else
        warn("Lỗi khi gửi thông tin đến Webhook.site: " .. tostring(response))
    end
end

-- Thực thi
local stats = getPlayerStats()
sendToWebhook(stats)
