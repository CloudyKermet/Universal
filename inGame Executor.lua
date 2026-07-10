-- Hacker Executor GUI v1.5 - Merged Features (Tabs + Saving + Smooth Minimize)
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Some executors allow this:
UserInputService.ModalEnabled = true

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- HWID Saving
local function getHWID()
    if gethwid then return gethwid() end
    if syn and syn.gethwid then return syn.gethwid() end
    return tostring(player.UserId)
end

local hwid = getHWID()
local saveFolder = "HackerExecutor_" .. hwid
local saveFile = saveFolder .. "/saved_tabs.json"

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HackerExecutor"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui
screenGui.IgnoreGuiInset = true  -- Add this after creating screenGui


-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 780, 0, 480)
mainFrame.Position = UDim2.new(0.5, -390, 0.5, -240)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", mainFrame).Color = Color3.fromRGB(80, 80, 120)

-- UIScale
local uiScale = Instance.new("UIScale", mainFrame)
uiScale.Scale = 0.5

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -120, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🔥 HACKER EXECUTOR"
titleLabel.TextColor3 = Color3.fromRGB(200, 180, 255)
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Buttons
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -32, 0.5, -13)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 26, 0, 26)
minBtn.Position = UDim2.new(1, -64, 0.5, -13)
minBtn.BackgroundColor3 = Color3.fromRGB(60, 130, 200)
minBtn.Text = "−"
minBtn.TextColor3 = Color3.new(1,1,1)
minBtn.TextSize = 16
minBtn.Font = Enum.Font.GothamBold
minBtn.Parent = titleBar
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

-- Dragging from anywhere
local dragging = false
local dragStart, startPos

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
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

mainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Tabs
local tabsFrame = Instance.new("Frame")
tabsFrame.Size = UDim2.new(0.22, 0, 1, -40)
tabsFrame.Position = UDim2.new(0, 8, 0, 38)
tabsFrame.BackgroundTransparency = 1
tabsFrame.Parent = mainFrame

local tabsList = Instance.new("UIListLayout", tabsFrame)
tabsList.Padding = UDim.new(0, 4)

local newTabBtn = Instance.new("TextButton")
newTabBtn.Size = UDim2.new(1, 0, 0, 32)
newTabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
newTabBtn.Text = "+ New Tab"
newTabBtn.TextColor3 = Color3.new(1,1,1)
newTabBtn.TextSize = 13
newTabBtn.Font = Enum.Font.GothamBold
newTabBtn.Parent = tabsFrame
Instance.new("UICorner", newTabBtn).CornerRadius = UDim.new(0, 6)

-- Editor
local editorBg = Instance.new("Frame")
editorBg.Size = UDim2.new(0.76, 0, 1, -48)
editorBg.Position = UDim2.new(0.23, 0, 0, 38)
editorBg.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
editorBg.BorderSizePixel = 0
editorBg.Parent = mainFrame
Instance.new("UICorner", editorBg).CornerRadius = UDim.new(0, 8)

local scriptBox = Instance.new("TextBox")
scriptBox.Size = UDim2.new(1, -8, 1, -8)
scriptBox.Position = UDim2.new(0, 4, 0, 4)
scriptBox.BackgroundTransparency = 1
scriptBox.Text = "-- Write your script here"
scriptBox.PlaceholderText = "-- Enter script..."
scriptBox.TextColor3 = Color3.fromRGB(180, 230, 180)
scriptBox.PlaceholderColor3 = Color3.fromRGB(90, 90, 110)
scriptBox.TextSize = 14
scriptBox.Font = Enum.Font.Code
scriptBox.TextXAlignment = Enum.TextXAlignment.Left
scriptBox.TextYAlignment = Enum.TextYAlignment.Top
scriptBox.MultiLine = false
scriptBox.ClearTextOnFocus = false
scriptBox.TextWrapped = false
scriptBox.Parent = editorBg

-- Bottom Buttons
local btnRow = Instance.new("Frame")
btnRow.Size = UDim2.new(0.76, 0, 0, 36)
btnRow.Position = UDim2.new(0.23, 0, 1, -42)
btnRow.BackgroundTransparency = 1
btnRow.Parent = mainFrame

local btnLayout = Instance.new("UIListLayout", btnRow)
btnLayout.FillDirection = Enum.FillDirection.Horizontal
btnLayout.Padding = UDim.new(0, 8)
btnLayout.VerticalAlignment = Enum.VerticalAlignment.Center

local execBtn = Instance.new("TextButton")
execBtn.Size = UDim2.new(0, 110, 0, 32)
execBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 90)
execBtn.Text = "▶ Execute"
execBtn.TextColor3 = Color3.new(1,1,1)
execBtn.TextSize = 14
execBtn.Font = Enum.Font.GothamBold
execBtn.Parent = btnRow
Instance.new("UICorner", execBtn).CornerRadius = UDim.new(0, 6)

local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0, 80, 0, 32)
copyBtn.BackgroundColor3 = Color3.fromRGB(50, 80, 130)
copyBtn.Text = "Copy"
copyBtn.TextColor3 = Color3.new(1,1,1)
copyBtn.TextSize = 14
copyBtn.Font = Enum.Font.GothamBold
copyBtn.Parent = btnRow
Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 6)

local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(0, 80, 0, 32)
clearBtn.BackgroundColor3 = Color3.fromRGB(80, 60, 100)
clearBtn.Text = "Clear"
clearBtn.TextColor3 = Color3.new(1,1,1)
clearBtn.TextSize = 14
clearBtn.Font = Enum.Font.GothamBold
clearBtn.Parent = btnRow
Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 6)

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.76, 0, 0, 18)
statusLabel.Position = UDim2.new(0.23, 0, 1, -18)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = ""
statusLabel.TextColor3 = Color3.fromRGB(120, 220, 120)
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = mainFrame

-- Tab Data
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
        tabs = {{name = "Tab 1", code = "-- Welcome to Hacker Executor"}}
    end
end

local function refreshTabsUI()
    for _, child in ipairs(tabsFrame:GetChildren()) do
        if child:IsA("TextButton") and child ~= newTabBtn then child:Destroy() end
    end
    for i, tab in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.BackgroundColor3 = (i == currentTab) and Color3.fromRGB(70, 70, 100) or Color3.fromRGB(40, 40, 55)
        btn.Text = tab.name
        btn.TextColor3 = Color3.new(1,1,1)
        btn.TextSize = 13
        btn.Font = Enum.Font.Gotham
        btn.Parent = tabsFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        
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

-- Status
local function showStatus(msg, color)
    statusLabel.Text = msg
    statusLabel.TextColor3 = color or Color3.fromRGB(120, 220, 120)
    task.delay(2.5, function()
        if statusLabel.Text == msg then statusLabel.Text = "" end
    end)
end

-- Buttons
execBtn.MouseButton1Click:Connect(function()
    local code = scriptBox.Text
    if code == "" or code:match("^%s*$") then
        showStatus("⚠ Nothing to execute.", Color3.fromRGB(255, 200, 60))
        return
    end
    if tabs[currentTab] then tabs[currentTab].code = code end
    saveTabs()
    
    local fn, err = loadstring(code)
    if fn then
        local success, runErr = pcall(fn)
        if success then
            showStatus("✅ Executed successfully!", Color3.fromRGB(100, 220, 130))
        else
            showStatus("❌ " .. tostring(runErr), Color3.fromRGB(255, 90, 90))
        end
    else
        showStatus("❌ " .. tostring(err), Color3.fromRGB(255, 90, 90))
    end
end)

copyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(scriptBox.Text)
        showStatus("✅ Copied to clipboard!", Color3.fromRGB(100, 180, 255))
    else
        showStatus("Clipboard not supported", Color3.fromRGB(255, 200, 60))
    end
end)

clearBtn.MouseButton1Click:Connect(function()
    scriptBox.Text = ""
    showStatus("🧹 Cleared editor", Color3.fromRGB(160, 160, 200))
end)

scriptBox:GetPropertyChangedSignal("Text"):Connect(function()
    if tabs[currentTab] then tabs[currentTab].code = scriptBox.Text end
end)

-- Smooth Minimize
local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    local targetSize = minimized and UDim2.new(0, 780, 0, 38) or UDim2.new(0, 780, 0, 480)
    TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize}):Play()
    minBtn.Text = minimized and "□" or "−"
end)

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Hover Effects
local function addHover(btn, normal, hoverColor)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = hoverColor}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = normal}):Play()
    end)
end

addHover(execBtn, Color3.fromRGB(60,180,90), Color3.fromRGB(80,210,110))
addHover(copyBtn, Color3.fromRGB(50,80,130), Color3.fromRGB(70,110,170))
addHover(clearBtn, Color3.fromRGB(80,60,100), Color3.fromRGB(110,85,140))
addHover(closeBtn, Color3.fromRGB(200,60,60), Color3.fromRGB(230,80,80))
addHover(minBtn, Color3.fromRGB(60,130,200), Color3.fromRGB(80,155,230))

-- Init
loadTabs()
refreshTabsUI()
if #tabs > 0 then scriptBox.Text = tabs[1].code or "" end

print("✅ Hacker Executor loaded with tabs + smooth features!")

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        screenGui.Enabled = not screenGui.Enabled
    end
end)
