-- Đảm bảo Fluxus Executor đang mở và kết nối với Roblox

-- Hàm lấy thông tin người chơi
local function getPlayerStats()
    local player = game.Players.LocalPlayer
    local stats = {
        AccountName = player.Name,
        Level = player:FindFirstChild("Data") and player.Data:FindFirstChild("Level") and player.Data.Level.Value or "N/A",
        Money = player:FindFirstChild("Data") and player.Data:FindFirstChild("Beli") and player.Data.Beli.Value or "N/A",
        Fragments = player:FindFirstChild("Data") and player.Data:FindFirstChild("Fragments") and player.Data.Fragments.Value or "N/A",
        FruitInventory = {}
    }

    -- Lấy danh sách trái cây nếu có
    if player:FindFirstChild("Data") and player.Data:FindFirstChild("FruitInventory") then
        for _, fruit in pairs(player.Data.FruitInventory:GetChildren()) do
            table.insert(stats.FruitInventory, fruit.Name)
        end
    else
        stats.FruitInventory = {"Không tìm thấy trái cây"}
    end

    return stats
end

-- Hàm tạo thư mục và lưu thông tin vào tệp JSON
local function saveStatsToFile(stats)
    local folderName = "MPhuc_stat"
    local fileName = folderName .. "/" .. stats.AccountName .. ".json"
    
    -- Tạo thư mục nếu chưa tồn tại
    if not isfolder(folderName) then
        makefolder(folderName)
    end

    local jsonData = game:GetService("HttpService"):JSONEncode(stats)
    local file, err = io.open(fileName, "w")
    if not file then
        warn("Không thể mở tệp để ghi: " .. err)
        return nil
    end

    file:write(jsonData)
    file:close()
    
    return fileName
end

-- Hàm gửi nội dung tệp đến webhook
local function sendFileToWebhook(fileName)
    if not fileName then
        warn("Tên tệp không hợp lệ")
        return
    end

    local webhookUrl = "https://discord.com/api/webhooks/1285079613281931316/b-kuGNqwAx4PkFDSXNBlxt9t8Fy3QLmVYkxg7rtmroMMq_z-OIw3_JHvIqdgMLfDY4zZ"
    local file, err = io.open(fileName, "r")
    if not file then
        warn("Không thể mở tệp để đọc: " .. err)
        return
    end

    local content = file:read("*all")
    file:close()

    local data = {
        ["content"] = "Thông tin người chơi",
        ["embeds"] = {{
            ["title"] = "Thông tin Blox Fruits",
            ["description"] = content
        }}
    }

    local jsonData = game:GetService("HttpService"):JSONEncode(data)
    local success, response = pcall(function()
        return game:GetService("HttpService"):PostAsync(webhookUrl, jsonData, Enum.HttpContentType.ApplicationJson)
    end)

    if not success then
        warn("Không thể gửi dữ liệu đến webhook: " .. response)
    end
end

-- Thực thi chính
local stats = getPlayerStats()
local fileName = saveStatsToFile(stats)
if fileName then
    sendFileToWebhook(fileName)
else
    warn("Không thể lưu thông tin người chơi vào tệp")
end
