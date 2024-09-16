local HttpService = game:GetService("HttpService")

-- Hàm kiểm tra quyền truy cập
local function checkPermissions(folderPath)
    local file, err = io.open(folderPath .. "/test.txt", "w")
    if not file then
        warn("Không có quyền ghi vào thư mục: " .. err)
        return false
    end
    file:close()
    os.remove(folderPath .. "/test.txt")
    return true
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

    -- Kiểm tra quyền truy cập
    if not checkPermissions(folderPath) then
        return nil
    end

    local jsonData = HttpService:JSONEncode(stats)
    local file, err
    repeat
        file, err = io.open(fileName, "w")
        if not file then
            warn("Không thể mở tệp để ghi: " .. tostring(err))
        else
            local success, writeErr = pcall(function()
                file:write(jsonData)
            end)
            if not success then
                warn("Lỗi khi ghi vào tệp: " .. tostring(writeErr))
                file:close()
                file = nil
            else
                file:close()
            end
        end
    until file

    return fileName
end

-- Thực thi chính
local stats = getPlayerStats()
local fileName = saveStatsToFile(stats)
if fileName then
    sendFileToWebhook(fileName)
else
    warn("Không thể lưu thông tin người chơi vào tệp")
end
