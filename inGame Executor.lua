-- Hacker Executor GUI v1.3 - Drag from ANYWHERE + Centered Spawn
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- HWID + Save
local function getHWID()
    if gethwid then return gethwid() end
    if syn and syn.gethwid then return syn.gethwid() end
    return tostring(player.UserId)
end

local hwid = getHWID()
local saveFolder = "HackerExecutor_" .. hwid
local saveFile = saveFolder .. "/saved_tabs.json"

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HackerExecutor"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Floating Restore Button
local minimizeRestoreBtn = Instance.new("TextButton")
minimizeRestoreBtn.Size = UDim2.new(0, 200, 0, 55)
minimizeRestoreBtn.Position = UDim2.new(0.5, -100, 0.2, 0)
minimizeRestoreBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 120)
minimizeRestoreBtn.Text = "Open"
minimizeRestoreBtn.TextColor3 = Color3.new(1,1,1)
minimizeRestoreBtn.TextScaled = true
minimizeRestoreBtn.Font = Enum.Font.SourceSansBold
minimizeRestoreBtn.Visible = false
minimizeRestoreBtn.Active = true
minimizeRestoreBtn.Draggable = true
minimizeRestoreBtn.Parent = screenGui
Instance.new("UICorner", minimizeRestoreBtn).CornerRadius = UDim.new(0, 12)

-- Main Frame (now draggable from anywhere)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 820, 0, 520)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Center it on screen every time
mainFrame.Position = UDim2.new(0.5, -410, 0.5, -260)

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", mainFrame).Thickness = 2
Instance.new("UIStroke", mainFrame).Color = Color3.fromRGB(0, 255, 150)

-- UIScale
local uiScale = Instance.new("UIScale", mainFrame)
uiScale.Scale = 0.5

-- Title Bar (visual only now)
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -150, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Executor"
titleLabel.TextColor3 = Color3.new(1,1,1)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Parent = titleBar

-- Buttons
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 32, 0, 32)
minimizeBtn.Position = UDim2.new(1, -75, 0, 6)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = Color3.new(1,1,1)
minimizeBtn.TextScaled = true
minimizeBtn.Font = Enum.Font.SourceSansBold
minimizeBtn.Parent = titleBar
Instance.new("UICorner", minimizeBtn)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -38, 0, 6)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn)

-- === DRAG FROM ANYWHERE ===
local dragging = false
local dragStart
local startPos

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

mainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Tabs Frame
local tabsFrame = Instance.new("Frame")
tabsFrame.Size = UDim2.new(0.22, 0, 1, -45)
tabsFrame.Position = UDim2.new(0, 0, 0, 45)
tabsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
tabsFrame.BorderSizePixel = 0
tabsFrame.Parent = mainFrame

Instance.new("UIListLayout", tabsFrame).Padding = UDim.new(0, 5)

local newTabBtn = Instance.new("TextButton")
newTabBtn.Size = UDim2.new(1, -10, 0, 40)
newTabBtn.Position = UDim2.new(0, 5, 1, -50)
newTabBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
newTabBtn.Text = "+ New Tab"
newTabBtn.TextColor3 = Color3.new(1,1,1)
newTabBtn.TextScaled = true
newTabBtn.Font = Enum.Font.SourceSansBold
newTabBtn.Parent = tabsFrame
Instance.new("UICorner", newTabBtn)

-- Editor
local editorFrame = Instance.new("Frame")
editorFrame.Size = UDim2.new(0.78, 0, 1, -45)
editorFrame.Position = UDim2.new(0.22, 0, 0, 45)
editorFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
editorFrame.BorderSizePixel = 0
editorFrame.Parent = mainFrame
Instance.new("UICorner", editorFrame)

local scriptBox = Instance.new("TextBox")
scriptBox.Size = UDim2.new(1, -20, 1, -90)
scriptBox.Position = UDim2.new(0, 10, 0, 10)
scriptBox.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
scriptBox.TextColor3 = Color3.fromRGB(240, 240, 240)
scriptBox.PlaceholderText = "-- Write your Lua script here...\n-- Drag the window from anywhere"
scriptBox.ClearTextOnFocus = false
scriptBox.MultiLine = true
scriptBox.Font = Enum.Font.SourceSans
scriptBox.TextSize = 16
scriptBox.TextXAlignment = Enum.TextXAlignment.Left
scriptBox.TextYAlignment = Enum.TextYAlignment.Top
scriptBox.Parent = editorFrame
Instance.new("UICorner", scriptBox)

-- Bottom Buttons
local buttonFrame = Instance.new("Frame")
buttonFrame.Size = UDim2.new(1, 0, 0, 70)
buttonFrame.Position = UDim2.new(0, 0, 1, -70)
buttonFrame.BackgroundTransparency = 1
buttonFrame.Parent = editorFrame

local executeBtn = Instance.new("TextButton")
executeBtn.Size = UDim2.new(0.32, 0, 0.75, 0)
executeBtn.Position = UDim2.new(0.04, 0, 0.12, 0)
executeBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
executeBtn.Text = "EXECUTE"
executeBtn.TextColor3 = Color3.new(1,1,1)
executeBtn.TextScaled = true
executeBtn.Font = Enum.Font.SourceSansBold
executeBtn.Parent = buttonFrame
Instance.new("UICorner", executeBtn)

local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0.32, 0, 0.75, 0)
copyBtn.Position = UDim2.new(0.38, 0, 0.12, 0)
copyBtn.BackgroundColor3 = Color3.fromRGB(60, 110, 220)
copyBtn.Text = "COPY"
copyBtn.TextColor3 = Color3.new(1,1,1)
copyBtn.TextScaled = true
copyBtn.Font = Enum.Font.SourceSansBold
copyBtn.Parent = buttonFrame
Instance.new("UICorner", copyBtn)

local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(0.22, 0, 0.75, 0)
clearBtn.Position = UDim2.new(0.72, 0, 0.12, 0)
clearBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
clearBtn.Text = "CLEAR"
clearBtn.TextColor3 = Color3.new(1,1,1)
clearBtn.TextScaled = true
clearBtn.Font = Enum.Font.SourceSansBold
clearBtn.Parent = buttonFrame
Instance.new("UICorner", clearBtn)

-- Tab Management
local tabs = {}
local currentTab = 1

local function saveTabs()
    pcall(function()
        if makefolder then makefolder(saveFolder) end
        local data = {tabs = {}}
        for _, t in ipairs(tabs) do
            table.insert(data.tabs, {name = t.name, code = t.code or ""})
        end
        if writefile then writefile(saveFile, HttpService:JSONEncode(data)) end
    end)
end

local function loadTabs()
    pcall(function()
        if isfile and isfile(saveFile) then
            local data = HttpService:JSONDecode(readfile(saveFile))
            tabs = data.tabs or {}
        end
    end)
    if #tabs == 0 then
        tabs = {{name = "Tab 1", code = "-- Drag me from anywhere!\nprint(\"Hacker Executor Loaded\")"}}
    end
end

local function refreshTabsUI()
    for _, child in ipairs(tabsFrame:GetChildren()) do
        if child:IsA("TextButton") and child ~= newTabBtn then child:Destroy() end
    end
    for i, tab in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 38)
        btn.BackgroundColor3 = (i == currentTab) and Color3.fromRGB(0, 120, 180) or Color3.fromRGB(40, 40, 55)
        btn.Text = tab.name
        btn.TextColor3 = Color3.new(1,1,1)
        btn.TextScaled = true
        btn.Font = Enum.Font.SourceSansBold
        btn.Parent = tabsFrame
        Instance.new("UICorner", btn)
        
        btn.MouseButton1Click:Connect(function()
            currentTab = i
            scriptBox.Text = tabs[i].code or ""
            refreshTabsUI()
        end)
    end
end

local function createNewTab()
    table.insert(tabs, {name = "Tab " .. (#tabs + 1), code = ""})
    currentTab = #tabs
    scriptBox.Text = ""
    refreshTabsUI()
    saveTabs()
end

newTabBtn.MouseButton1Click:Connect(createNewTab)

-- Button Functions
executeBtn.MouseButton1Click:Connect(function()
    local code = scriptBox.Text
    if code and #code > 3 and tabs[currentTab] then
        tabs[currentTab].code = code
        saveTabs()
        pcall(function() loadstring(code)() end)
    end
end)

copyBtn.MouseButton1Click:Connect(function()
    if setclipboard then setclipboard(scriptBox.Text) end
end)

clearBtn.MouseButton1Click:Connect(function()
    scriptBox.Text = ""
end)

scriptBox:GetPropertyChangedSignal("Text"):Connect(function()
    if tabs[currentTab] then tabs[currentTab].code = scriptBox.Text end
end)

-- Minimize
local isMinimized = false
local function toggleMinimize()
    isMinimized = not isMinimized
    mainFrame.Visible = not isMinimized
    minimizeRestoreBtn.Visible = isMinimized
end

minimizeBtn.MouseButton1Click:Connect(toggleMinimize)
minimizeRestoreBtn.MouseButton1Click:Connect(toggleMinimize)

-- Init
loadTabs()
refreshTabsUI()
if #tabs > 0 then scriptBox.Text = tabs[1].code or "" end

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        screenGui.Enabled = not screenGui.Enabled
    end
end)
