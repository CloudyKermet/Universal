local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local plr = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local success, info = pcall(function()
    return MarketplaceService:GetProductInfo(game.PlaceId)
end)

local Window = WindUI:CreateWindow({
    Title = "Cheat Engine", -- window title
    Author = "by KermetDevelopment", -- window subtitle. optional
    Folder = "CECK",    
    
    User = { 
        Enabled = true,
        Anonymous = false, 
    },
})

local CFrame = nil

Window:Tag({
    Title = info.Name,
    Color = Color3.fromRGB(100, 200, 100)
})

local Tab1 = Window:Tab({
    Title = "Home",
})
Tab1:Select()

local codebox1 = Tab1:Code({
    Title = "Current CFrame",
    Code = "nil"
})

Tab1:Button({
    Title = "Update Current CFrame",
    Callback = function()
    CFrame = plr.Character.HumanoidRootPart.CFrame.Position
    codebox1:SetCode(tostring(CFrame))
    end
})

Tab2:Button({
    Title = "Goto Current CFrame",
    Callback = function()
    plr.Character.HumanoidRootPart.CFrame.Position = CFrame
    end
})




