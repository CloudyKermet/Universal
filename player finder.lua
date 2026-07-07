local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

--// Main Function - Call this from your own GUI
local function FindAndJoinPlayer(username: string)
    username = username:match("^%s*(.-)%s*$") -- trim whitespace
    
    if username == "" then
        warn("Please enter a username")
        return false, "No username provided"
    end

    print("🔍 Resolving username:", username)

    -- Get UserId
    local userId
    local success, err = pcall(function()
        userId = Players:GetUserIdFromNameAsync(username)
    end)

    if not success or not userId then
        console:Log("Not Found!", "ERROR")

        return false, "Invalid username"
    end

    print("✅ Found UserId:", userId)

    -- Fast method (most reliable & quickest)
    print("⚡ Trying quick join...")
    local fastSuccess, placeId, jobId = pcall(function()
        local info = TeleportService:GetPlayerPlaceInstanceAsync(userId)
        return info.PlaceId, info.JobId
    end)

    if fastSuccess and placeId == PlaceId and jobId then
        print("✅ Player found in current game! Joining server...")
        TeleportService:TeleportToPlaceInstance(placeId, jobId, LocalPlayer)
        return true, "Quick join successful"
    end

    -- Fallback: Scan public servers using headshot comparison
    print("🔎 Quick join failed, scanning public servers...")

    local targetHeadshot
    pcall(function()
        local hs = game:HttpGet(
            "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" ..
            userId .. "&size=150x150&format=Png"
        )
        targetHeadshot = HttpService:JSONDecode(hs).data[1].imageUrl
    end)

    if not targetHeadshot then
        warn("❌ Failed to get target player headshot")
        return false, "Failed to fetch avatar"
    end

    local cursor = ""
    local maxPages = 25

    for page = 1, maxPages do
        print("Scanning page", page, "...")

        local url = string.format(
            "https://games.roblox.com/v1/games/%d/servers/Public?limit=100&cursor=%s",
            PlaceId, cursor
        )

        local serversSuccess, serversData = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)

        if not serversSuccess or not serversData or not serversData.data then
            break
        end

        for _, server in ipairs(serversData.data) do
            if server.playerTokens then
                for _, token in ipairs(server.playerTokens) do
                    local batchBody = HttpService:JSONEncode({
                        {
                            requestId = server.id,
                            token = token,
                            type = "AvatarHeadshot",
                            size = "150x150",
                            format = "Png"
                        }
                    })

                    local thumbSuccess, thumbData = pcall(function()
                        return HttpService:JSONDecode(
                            game:HttpPost("https://thumbnails.roblox.com/v1/batch", batchBody)
                        )
                    end)

                    if thumbSuccess and thumbData and thumbData.data and thumbData.data[1] then
                        if thumbData.data[1].imageUrl == targetHeadshot then
                            print("✅ Player found! Joining server:", server.id)
                            TeleportService:TeleportToPlaceInstance(PlaceId, server.id, LocalPlayer)
                            return true, "Found via server scan"
                        end
                    end
                end
            end
        end

        cursor = serversData.nextPageCursor
        if not cursor then break end

        task.wait(0.7) -- Rate limit friendly
    end

    warn("❌ Player not found in any public server")
    return false, "Player not found"
end

-- Example usage (remove or comment out):
-- FindAndJoinPlayer("SomeUsername")

print("✅ Better Player Server Joiner (headless) loaded!")


local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/gustaslaoq/ui-library/refs/heads/main/library.lua"))()

local ui = Lib.new({
    AppName     = "Player Finder",
    AppSubtitle = "v1",
    AppVersion  = "1.0",
    Pages = {
        { Name = "Main" },
    },
})

local input = ui:AddInput(1, "Player Name", "Enter username...", function(text, enter)
    if enter then
        local username = text
    FindAndJoinPlayer(username)
    end
end)

local console = ui:AddLogConsole(1, 220)
