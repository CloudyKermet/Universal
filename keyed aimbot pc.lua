local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Aimbot Variables
local aimlock = false
local teamcheck = false
local wallcheck = false
local friendcheck = false
local aimpart = "Head"
local smoothness = 0.2
local verticalOffset = 0

local Target = nil
local HoldingTrigger = false
local OriginalCameraType = Camera.CameraType

-- UI Setup
local Window = Rayfield:CreateWindow({
   Name = "VoidX",
   LoadingTitle = "By Kermet",
   LoadingSubtitle = "Aimbot Edition",
   ShowText = "Rayfield",
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,
   Discord = {
      Enabled = true,
      Invite = "MqvCGQCcxm",
      RememberJoins = true
   },
    KeySystem = true,
   KeySettings = {
      Title = "VoidX Keysystem",
      Subtitle = "KermetDevelopment",
      Note = "KermetDevelopment",
      FileName = "Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"admin", "G71L-47CU-27KX-NBPZ"}
   }
})

local Tab1 = Window:CreateTab("Combat", 4483362458)

-- Live Offset Label
local offsetLabel = Tab1:CreateLabel("Vertical Offset: 0 px")

-- Aimbot Functions
local function IsVisible(targetPart)
    if not wallcheck then return true end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    local ray = Ray.new(root.Position, (targetPart.Position - root.Position).Unit * (targetPart.Position - root.Position).Magnitude)
    local hit, _ = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
    return hit == nil or hit:IsDescendantOf(targetPart.Parent)
end

local function GetClosestToCenter()
    local closest = nil
    local closestDist = 9999
    local screenCenter = Camera.ViewportSize / 2

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local char = plr.Character
            local hum = char:FindFirstChild("Humanoid")
            local part = char:FindFirstChild(aimpart)
            
            if hum and hum.Health > 0 and part then
                if teamcheck and plr.Team == LocalPlayer.Team then continue end
                local plrFromChar = Players:GetPlayerFromCharacter(char)
                if friendcheck and plrFromChar and LocalPlayer:IsFriendsWith(plrFromChar.UserId) then continue end
                if not IsVisible(part) then continue end
                
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = part
                    end
                end
            end
        end
    end
    return closest
end

-- Input Handling (PC - Right Mouse Button)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then  -- Right Click
        HoldingTrigger = true
        OriginalCameraType = Camera.CameraType
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then  -- Right Click
        HoldingTrigger = false
        Target = nil
        Camera.CameraType = OriginalCameraType
    end
end)

-- Main Aimbot Loop with Vertical Offset
RunService.RenderStepped:Connect(function()
    if not aimlock or not HoldingTrigger then
        Target = nil
        return
    end

    if not Target or not Target.Parent or (Target.Parent:FindFirstChild("Humanoid") and Target.Parent.Humanoid.Health <= 0) then
        Target = GetClosestToCenter()
    end

    if Target then
        local targetPos = Target.Position
            
        -- Apply vertical pixel offset
        if verticalOffset ~= 0 then
            local screenPos = Camera:WorldToViewportPoint(targetPos)
            local offsetPos = Vector3.new(screenPos.X, screenPos.Y - verticalOffset, screenPos.Z)
            local worldRay = Camera:ViewportPointToRay(offsetPos.X, offsetPos.Y)
            targetPos = Camera.CFrame.Position + worldRay.Direction * (targetPos - Camera.CFrame.Position).Magnitude
        end
            
        local newCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
        
        if smoothness <= 0 then
            Camera.CFrame = newCFrame
        else
            Camera.CFrame = Camera.CFrame:Lerp(newCFrame, smoothness)
        end
    end 
end)

-- Update Offset Label
RunService.Heartbeat:Connect(function()
    offsetLabel:Set("Vertical Offset: " .. verticalOffset .. " px")
end)

-- UI Elements
Tab1:CreateToggle({
   Name = "Aimlock (Right Click)",
   CurrentValue = false,
   Flag = "Aimlock",
   Callback = function(Value)
      aimlock = Value
   end,
})

Tab1:CreateToggle({
   Name = "Wall Check",
   CurrentValue = false,
   Flag = "WallCheck",
   Callback = function(Value)
      wallcheck = Value
   end,
})

Tab1:CreateToggle({
   Name = "Team Check",
   CurrentValue = false,
   Flag = "TeamCheck",
   Callback = function(Value)
      teamcheck = Value
   end,
})

Tab1:CreateToggle({
   Name = "Friend Check",
   CurrentValue = false,
   Flag = "FriendCheck",
   Callback = function(Value)
      friendcheck = Value
   end,
})

Tab1:CreateSlider({
   Name = "Smoothness",
   Range = {0, 1},
   Increment = 0.05,
   CurrentValue = smoothness,
   Flag = "Smoothness",
   Callback = function(Value)
      smoothness = Value
   end,
})

Tab1:CreateSlider({
   Name = "Vertical Offset (Pixels)",
   Range = {-100, 100},
   Increment = 1,
   CurrentValue = verticalOffset,
   Flag = "VerticalOffset",
   Callback = function(Value)
      verticalOffset = Value
   end,
})

Tab1:CreateDropdown({
   Name = "Aim Part",
   Options = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"},
   CurrentOption = {aimpart},
   Flag = "AimPart",
   Callback = function(Option)
      aimpart = Option[1]
   end,
})
