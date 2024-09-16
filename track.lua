local HttpService = game:GetService("HttpService")

-- Hàm đọc tệp JSON
local function readJsonFile(filePath)
    local file, err = io.open(filePath, "r")
    if not file then
        warn("Không thể mở tệp để đọc: " .. err)
        return nil
    end

    local content = file:read("*all")
    file:close()

    local data, pos, err = pcall(function()
        return HttpService:JSONDecode(content)
    end)
    if not data then
        warn("Lỗi khi phân tích tệp JSON: " .. err)
        return nil
    end

    return data
end

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
    local folderPath = "/storage/emulated/0/MPhuc_stat"
    local fileName = folderPath .. "/" .. stats.AccountName .. ".json"
    
    -- Tạo thư mục nếu chưa tồn tại
    if not isfolder(folderPath) then
        local success, err = pcall(function()
            makefolder(folderPath)
        end)
        if not success then
            warn("Không thể tạo thư mục: " .. err)
            return nil
        end
    end

    local jsonData = HttpService:JSONEncode(stats)
    local file, err
    repeat
        file, err = io.open(fileName, "w")
        if not file then
            warn("Không thể mở tệp để ghi: " .. tostring(err))
        end
    until file

    local success, err = pcall(function()
        file:write(jsonData)
    end)
    if not success then
        warn("Lỗi khi ghi vào tệp: " .. tostring(err))
        file:close()
        return nil
    end

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
        warn("Không thể mở tệp để đọc: " .. tostring(err))
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

    local jsonData = HttpService:JSONEncode(data)
    local success, response = pcall(function()
        return HttpService:PostAsync(webhookUrl, jsonData, Enum.HttpContentType.ApplicationJson)
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

-- Đọc tệp JSON
local filePath = "/storage/emulated/0/MPhuc_stat/" .. stats.AccountName .. ".json"
local data = readJsonFile(filePath)
if data then
    print("Dữ liệu từ tệp JSON:")
    for k, v in pairs(data) do
        print(k, v)
    end
else
    warn("Không thể đọc tệp JSON")
end
