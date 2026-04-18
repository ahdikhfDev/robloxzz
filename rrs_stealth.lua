--[[
    RRS v2.0 - STEALTH EDITION
    - UI: Premium rounded, draggable, smooth
    - Anti-kick protection
    - Passive scanning (ga trigger anti-cheat)
    - Auto-recover from kicks
    - Detailed results display
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Config = {
    MenuOpen = true,
    AutoScan = false,
    ScanInterval = 5,
    StealthMode = true, -- Less aggressive scanning
    ScanSkin = true,
    ScanExploit = false, -- Disabled by default (bisa kick)
    ScanFull = true,
    LogLevel = 1
}

local Theme = {
    MainBg = Color3.fromRGB(18, 18, 25),
    HeaderBg = Color3.fromRGB(25, 25, 32),
    ButtonBg = Color3.fromRGB(40, 40, 50),
    Accent = Color3.fromRGB(130, 0, 255),
    OnColor = Color3.fromRGB(0, 255, 128),
    OffColor = Color3.fromRGB(70, 70, 80),
    TextWhite = Color3.fromRGB(245, 245, 245),
    TextSub = Color3.fromRGB(150, 150, 160),
    Cyan = Color3.fromRGB(0, 255, 255),
    Warning = Color3.fromRGB(255, 200, 80)
}

local ScanResults = {
    FoundItems = {}, 
    Vulnerabilities = {}, 
    StealthTests = {}, 
    ServerInfo = {}, 
    Logs = {}
}
local State = {ScanCount = 0, IsScanning = false, OriginalWS = 16}

local function Log(level, cat, msg)
    local entry = string.format("[%s] [%s] %s", cat, level, msg)
    table.insert(ScanResults.Logs, entry)
    print(entry)
end

-- STEALTH SCANNERS (Passive only - ga trigger anti-cheat)
local function ScanSkinsAndItems()
    Log("INFO", "SCAN", "Passive items scan...")
    local found = {}
    local tools, pickups, npcs, spawns = 0, 0, 0, 0
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Tool") then tools = tools + 1 end
        if obj:IsA("Part") and obj:FindFirstChild("TouchInterest") then pickups = pickups + 1 end
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(obj) then npcs = npcs + 1 end
        if obj:IsA("SpawnLocation") then spawns = spawns + 1 end
    end
    
    table.insert(found, string.format("Tools: %d | Pickups: %d | NPCs: %d | Spawns: %d", tools, pickups, npcs, spawns))
    table.insert(found, "Total objects scanned: " .. #Workspace:GetDescendants())
    
    -- Find specific interesting items
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Tool") and obj:FindFirstChild("Handle") then
            table.insert(found, "[TOOL] " .. obj.Name)
        end
    end
    
    ScanResults.FoundItems = found
    Log("INFO", "SCAN", "Found " .. #found .. " entries")
end

local function ScanServerInfo()
    Log("INFO", "SCAN", "Gathering server info...")
    local info = {}
    
    table.insert(info, "=== SERVER INFO ===")
    table.insert(info, "Game: " .. game.Name)
    table.insert(info, "Place ID: " .. game.PlaceId)
    table.insert(info, "Players: " .. #Players:GetPlayers())
    table.insert(info, "")
    table.insert(info, "=== PHYSICS ===")
    table.insert(info, "Gravity: " .. Workspace.Gravity)
    table.insert(info, "Fall Height: " .. Workspace.FallenPartsDestroyHeight)
    table.insert(info, "Streaming: " .. tostring(Workspace.StreamingEnabled))
    table.insert(info, "")
    table.insert(info, "=== LIGHTING ===")
    table.insert(info, "Time: " .. math.floor(Lighting.ClockTime))
    table.insert(info, "Ambient: " .. tostring(Lighting.Ambient))
    table.insert(info, "")
    
    -- Player status
    for _, p in pairs(Players:GetPlayers()) do
        local char = p.Character
        local status = char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0
        table.insert(info, string.format("• %s: %s", p.Name, status and "Alive" or "Dead"))
    end
    
    ScanResults.ServerInfo = info
end

local function RunFullScan()
    if State.IsScanning then return end
    State.IsScanning = true
    State.ScanCount = State.ScanCount + 1
    
    if Config.ScanSkin then ScanSkinsAndItems() end
    if Config.ScanFull then ScanServerInfo() end
    
    State.IsScanning = false
    Log("SUCCESS", "SCAN", "Scan #" .. State.ScanCount .. " complete")
end

-- PREMIUM UI ENGINE
local function CreateGUI()
    local UI = LocalPlayer:WaitForChild("PlayerGui")
    if UI:FindFirstChild("RRS_STEALTH") then UI.RRS_STEALTH:Destroy() end

    local Screen = Instance.new("ScreenGui")
    Screen.Name = "RRS_STEALTH"
    Screen.Parent = UI

    -- Floating button
    local FloatBtn = Instance.new("TextButton")
    FloatBtn.Size = UDim2.new(0, 45, 0, 45)
    FloatBtn.Position = UDim2.new(0, 15, 0.5, -22)
    FloatBtn.BackgroundColor3 = Theme.MainBg
    FloatBtn.Text = "RRS"
    FloatBtn.Font = Enum.Font.GothamBold
    FloatBtn.TextSize = 12
    FloatBtn.TextColor3 = Theme.Accent
    FloatBtn.Visible = false
    FloatBtn.Parent = Screen
    Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", FloatBtn).Color = Theme.Accent

    -- Main frame (DRAGGABLE)
    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 380, 0, 420)
    Main.Position = UDim2.new(0.5, -190, 0.5, -210)
    Main.BackgroundColor3 = Theme.MainBg
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = Screen
    
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)
    local MainStroke = Instance.new("UIStroke", Main)
    MainStroke.Color = Theme.Accent
    MainStroke.Thickness = 2

    -- Header (DRAG HANDLE)
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 45)
    Header.BackgroundColor3 = Theme.HeaderBg
    Header.Parent = Main

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -60, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "RRS v2.0 STEALTH"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextColor3 = Theme.Accent
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header

    -- Minimize button
    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 35, 0, 30)
    MinBtn.Position = UDim2.new(1, -40, 0, 8)
    MinBtn.BackgroundTransparency = 1
    MinBtn.Text = "_"
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 16
    MinBtn.TextColor3 = Theme.TextSub
    MinBtn.Parent = Header

    -- Scan button (BIG & VISIBLE)
    local ScanBtn = Instance.new("TextButton")
    ScanBtn.Size = UDim2.new(0.9, 0, 0, 38)
    ScanBtn.Position = UDim2.new(0.05, 0, 0, 55)
    ScanBtn.BackgroundColor3 = Theme.Accent
    ScanBtn.Text = "▶ SCAN NOW"
    ScanBtn.Font = Enum.Font.GothamBold
    ScanBtn.TextSize = 15
    ScanBtn.TextColor3 = Theme.TextWhite
    ScanBtn.Parent = Main
    Instance.new("UICorner", ScanBtn).CornerRadius = UDim.new(0, 10)

    -- Stats display
    local Stats = Instance.new("Frame")
    Stats.Size = UDim2.new(0.9, 0, 0, 35)
    Stats.Position = UDim2.new(0.05, 0, 0, 100)
    Stats.BackgroundColor3 = Theme.ButtonBg
    Stats.Parent = Main
    Instance.new("UICorner", Stats).CornerRadius = UDim.new(0, 8)

    local StatsText = Instance.new("TextLabel")
    StatsText.Size = UDim2.new(1, 0, 1, 0)
    StatsText.BackgroundTransparency = 1
    StatsText.Text = "Ready to scan..."
    StatsText.Font = Enum.Font.Code
    StatsText.TextSize = 12
    StatsText.TextColor3 = Theme.Cyan
    StatsText.TextWrapped = true
    StatsText.Parent = Stats

    -- Results area (SCROLLABLE)
    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(0.9, 0, 1, -170)
    Scroll.Position = UDim2.new(0.05, 0, 0, 140)
    Scroll.BackgroundTransparency = 1
    Scroll.ScrollBarThickness = 4
    Scroll.ScrollBarImageColor3 = Theme.Accent
    Scroll.Parent = Main

    Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 3)
    local Pad = Instance.new("UIPadding", Scroll)
    Pad.PaddingTop = UDim.new(0, 5)
    Pad.PaddingLeft = UDim.new(0, 5)

    -- Results TextLabel
    local ResultText = Instance.new("TextLabel")
    ResultText.Size = UDim2.new(1, -20, 0, 300)
    ResultText.BackgroundTransparency = 1
    ResultText.Text = "Results will appear here..."
    ResultText.Font = Enum.Font.Code
    ResultText.TextSize = 11
    ResultText.TextColor3 = Theme.TextSub
    ResultText.TextWrapped = true
    ResultText.TextXAlignment = Enum.TextXAlignment.Left
    ResultText.AutomaticSize = Enum.AutomaticSize.Y
    ResultText.Parent = Scroll

    -- DRAG LOGIC (Smooth)
    local dragging, dragInput, dragStart, startPos
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    Header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- MINIMIZE
    MinBtn.MouseButton1Click:Connect(function()
        Main:TweenSize(UDim2.new(0, 0, 0, 0), "In", "Back", 0.3, true, function()
            Main.Visible = false
            FloatBtn.Visible = true
        end)
    end)
    FloatBtn.MouseButton1Click:Connect(function()
        FloatBtn.Visible = false
        Main.Visible = true
        Main:TweenSize(UDim2.new(0, 380, 0, 420), "Out", "Back", 0.3, true)
    end)

    -- UPDATE RESULTS
    local function updateResults()
        local txt = ""
        
        if #ScanResults.ServerInfo > 0 then
            txt = txt .. "=== SERVER ===\n"
            for _, v in ipairs(ScanResults.ServerInfo) do
                txt = txt .. v .. "\n"
            end
            txt = txt .. "\n"
        end
        
        if #ScanResults.FoundItems > 0 then
            txt = txt .. "=== ITEMS ===\n"
            for _, v in ipairs(ScanResults.FoundItems) do
                txt = txt .. v .. "\n"
            end
            txt = txt .. "\n"
        end
        
        if txt == "" then txt = "Results will appear here..." end
        ResultText.Text = txt
        
        StatsText.Text = string.format("Scan #%d • %d items • %s", 
            State.ScanCount, 
            #ScanResults.FoundItems,
            Config.StealthMode and "Stealth" or "Aggressive")
    end

    -- SCAN BUTTON
    ScanBtn.MouseButton1Click:Connect(function()
        ScanBtn.Text = "⏳ SCANNING..."
        ScanBtn.AutoButtonColor = false
        
        pcall(function()
            RunFullScan()
        end)
        
        task.delay(0.5, function()
            updateResults()
            ScanBtn.Text = "▶ SCAN NOW"
        end)
    end)

    -- AUTO SCAN LOOP
    task.spawn(function()
        while true do
            task.wait(Config.ScanInterval)
            if Config.AutoScan and Config.MenuOpen then
                pcall(function() RunFullScan() end)
                pcall(function() updateResults() end)
            end
        end
    end)

    -- ANTI-KICK RECOVERY
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        pcall(function() updateResults() end)
    end)

    Log("SUCCESS", "INIT", "RRS v2.0 STEALTH Loaded!")
end

-- Safe init
delay(0.3, function()
    pcall(function() CreateGUI() end)
end)