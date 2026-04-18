--[[
    RRS v3.0 OVERPOWERED EDITION
    - Auto-Detect + Auto-Interact
    - Auto-Pickup, Tool Hunter, Secret Scanner
    - Trigger Auto-fire, Teleport, Anti-Void
    - Distance ranking, Rarity stars
    - FULL FEATURE: KICK RISK INCLUDED
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")

local Config = {
    MenuOpen = true,
    AutoScan = true,
    ScanInterval = 3,
    
    -- AUTO-INTERACT FEATURES (OP)
    AutoPickup = true,
    PickupRadius = 30,
    AutoEquip = true,
    AutoTrigger = false,
    AutoTeleport = false, -- HIGH RISK - enable manually
    AntiVoid = true,
    AntiVoidY = -300,
    AntiAFK = true,
    
    -- Filters
    ShowTools = true,
    ShowPickups = true,
    ShowSecrets = true,
    ShowTriggers = true,
    ShowNPCs = true,
    
    -- Display
    ShowDistance = true,
    RarityStars = true
}

local Theme = {
    MainBg = Color3.fromRGB(18, 18, 25),
    HeaderBg = Color3.fromRGB(25, 25, 32),
    ButtonBg = Color3.fromRGB(40, 40, 50),
    Accent = Color3.fromRGB(130, 0, 255),
    OnColor = Color3.fromRGB(0, 255, 128),
    OffColor = Color3.fromRGB(70, 70, 80),
    Warning = Color3.fromRGB(255, 200, 80),
    Danger = Color3.fromRGB(255, 60, 80),
    Gold = Color3.fromRGB(255, 215, 0),
    TextWhite = Color3.fromRGB(245, 245, 245),
    TextSub = Color3.fromRGB(150, 150, 160),
    Cyan = Color3.fromRGB(0, 255, 255)
}

local ScanResults = {
    Tools = {},
    Pickups = {},
    Secrets = {},
    Triggers = {},
    NPCs = {},
    Spawns = {},
    Logs = {}
}
local State = {ScanCount = 0, IsScanning = false, BestTool = nil}

local function Log(level, cat, msg)
    local entry = string.format("[%s] [%s] %s", cat, level, msg)
    table.insert(ScanResults.Logs, entry)
    print(entry)
end

-- CORE SCANNER
local function GetDistance(pos)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return 9999 end
    return (pos - hrp.Position).Magnitude
end

local function GetRarity(name)
    name = name:lower()
    if name:find("diamond") or name:find("legendary") or name:find("epic") then return "★★★★★"
    elseif name:find("gold") or name:find("rare") or name:find("ruby") then return "★★★★"
    elseif name:find("silver") or name:find("uncommon") then return "★★★"
    elseif name:find("bronze") or name:find("common") then return "★★"
    else return "★"
    end
end

local function ScanAll()
    Log("INFO", "SCAN", "=== OVERPOWERED SCAN ===")
    
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local myPos = hrp and hrp.Position or Vector3.new(0, 0, 0)
    
    ScanResults.Tools = {}
    ScanResults.Pickups = {}
    ScanResults.Secrets = {}
    ScanResults.Triggers = {}
    ScanResults.NPCs = {}
    ScanResults.Spawns = {}
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        -- TOOLS
        if Config.ShowTools and obj:IsA("Tool") and obj:FindFirstChild("Handle") then
            local dist = GetDistance(obj.Position)
            local rarity = GetRarity(obj.Name)
            table.insert(ScanResults.Tools, {
                name = obj.Name,
                pos = obj.Position,
                dist = dist,
                rarity = rarity,
                obj = obj
            })
        end
        
        -- PICKUPS (TouchInterest)
        if Config.ShowPickups and obj:IsA("Part") and obj:FindFirstChild("TouchInterest") then
            local dist = GetDistance(obj.Position)
            table.insert(ScanResults.Pickups, {
                name = obj.Name,
                pos = obj.Position,
                dist = dist,
                obj = obj
            })
        end
        
        -- SECRETS (Hidden/transparent parts)
        if Config.ShowSecrets and obj:IsA("Part") then
            if obj.Transparency > 0.5 or obj.CanCollide == false then
                local dist = GetDistance(obj.Position)
                table.insert(ScanResults.Secrets, {
                    name = obj.Name,
                    pos = obj.Position,
                    dist = dist,
                    transp = obj.Transparency,
                    obj = obj
                })
            end
        end
        
        -- TRIGGERS
        if Config.ShowTriggers and obj:IsA("Part") and obj:FindFirstChild("TouchInterest") then
            local dist = GetDistance(obj.Position)
            table.insert(ScanResults.Triggers, {
                name = obj.Name,
                pos = obj.Position,
                dist = dist,
                obj = obj
            })
        end
        
        -- NPCS
        if Config.ShowNPCs and obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
            if not Players:GetPlayerFromCharacter(obj) then
                local dist = GetDistance(obj.Position)
                local hp = obj.Humanoid.Health
                table.insert(ScanResults.NPCs, {
                    name = obj.Name,
                    pos = obj.Position,
                    dist = dist,
                    health = hp,
                    obj = obj
                })
            end
        end
        
        -- SPAWNS
        if obj:IsA("SpawnLocation") then
            local dist = GetDistance(obj.Position)
            table.insert(ScanResults.Spawns, {
                name = obj.Name,
                pos = obj.Position,
                dist = dist,
                obj = obj
            })
        end
    end
    
    -- Sort by distance
    local function sortByDist(a, b) return a.dist < b.dist end
    table.sort(ScanResults.Tools, sortByDist)
    table.sort(ScanResults.Pickups, sortByDist)
    table.sort(ScanResults.Secrets, sortByDist)
    table.sort(ScanResults.Triggers, sortByDist)
    
    -- Find best tool
    State.BestTool = ScanResults.Tools[1]
    
    local total = #ScanResults.Tools + #ScanResults.Pickups + #ScanResults.Secrets + #ScanResults.Triggers
    Log("INFO", "SCAN", string.format("Found: %d tools, %d pickups, %d secrets, %d triggers", 
        #ScanResults.Tools, #ScanResults.Pickups, #ScanResults.Secrets, #ScanResults.Triggers))
    
    State.ScanCount = State.ScanCount + 1
end

-- AUTO FUNCTIONS
local function DoAutoPickup()
    if not Config.AutoPickup then return end
    
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local char = LocalPlayer.Character
    
    -- Auto grab pickups
    for _, pickup in ipairs(ScanResults.Pickups) do
        if pickup.dist < Config.PickupRadius then
            -- Touch the pickup
            firetouchinterest(char.HumanoidRootPart, pickup.obj, true)
            task.delay(0.1, function()
                firetouchinterest(char.HumanoidRootPart, pickup.obj, false)
            end)
            Log("SUCCESS", "AUTO", "Grabbed: " .. pickup.name)
        end
    end
end

local function DoAutoEquip()
    if not Config.AutoEquip or not State.BestTool then return end
    
    local char = LocalPlayer.Character
    if char then
        local tool = char:FindFirstChild(State.BestTool.name)
        if tool then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then
                humanoid:EquipTool(tool)
                Log("SUCCESS", "AUTO", "Equipped: " .. State.BestTool.name)
            end
        end
    end
end

local function DoAutoTrigger()
    if not Config.AutoTrigger then return end
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    for _, trigger in ipairs(ScanResults.Triggers) do
        if trigger.dist < 10 then
            firetouchinterest(hrp, trigger.obj, true)
            task.delay(0.1, function()
                firetouchinterest(hrp, trigger.obj, false)
            end)
            Log("SUCCESS", "AUTO", "Triggered: " .. trigger.name)
        end
    end
end

local function DoAntiVoid()
    if not Config.AntiVoid then return end
    
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    if hrp.Position.Y < Config.AntiVoidY then
        -- Respawn
        LocalPlayer.Character:Destroy()
        Log("WARN", "ANTIVOID", "Respawning...")
    end
end

local function DoAntiAFK()
    if not Config.AntiAFK then return end
    
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
end

-- TELEPORT (HIGH RISK)
local function TeleportTo(pos)
    if not Config.AutoTeleport then return end
    
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(pos)
        Log("SUCCESS", "TP", "Teleported!")
    end
end

-- PREMIUM UI
local function CreateGUI()
    local UI = LocalPlayer:WaitForChild("PlayerGui")
    if UI:FindFirstChild("RRS_OP") then UI.RRS_OP:Destroy() end

    local Screen = Instance.new("ScreenGui")
    Screen.Name = "RRS_OP"
    Screen.Parent = UI

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 400, 0, 500)
    Main.Position = UDim2.new(0.5, -200, 0.5, -250)
    Main.BackgroundColor3 = Theme.MainBg
    Main.ClipsDescendants = true
    Main.Parent = Screen
    
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)
    Instance.new("UIStroke", Main).Color = Theme.Accent

    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 45)
    Header.BackgroundColor3 = Theme.HeaderBg
    Header.Parent = Main

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -50, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "RRS v3.0 OP"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextColor3 = Theme.Accent
    Title.Parent = Header

    local Status = Instance.new("TextLabel")
    Status.Size = UDim2.new(0.5, 0, 1, 0)
    Status.Position = UDim2.new(0.5, 0, 0, 0)
    Status.BackgroundTransparency = 1
    Status.Text = "READY"
    Status.Font = Enum.Font.Code
    Status.TextSize = 11
    Status.TextColor3 = Theme.Cyan
    Status.Parent = Header

    local function CreateToggle(text, y, flag)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0.42, 0, 0, 28)
        frame.Position = UDim2.new(0.04, 0, 0, 50 + y * 30)
        frame.BackgroundColor3 = Theme.ButtonBg
        frame.Parent = Main
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
        
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -30, 1, 0)
        lbl.Position = UDim2.new(0, 5, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 10
        lbl.TextColor3 = Theme.TextWhite
        lbl.Parent = frame
        
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 10, 0, 10)
        dot.Position = UDim2.new(1, -18, 0.5, -5)
        dot.BackgroundColor3 = Theme.OffColor
        dot.Parent = frame
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.Parent = frame
        
        btn.MouseButton1Click:Connect(function()
            Config[flag] = not Config[flag]
            dot.BackgroundColor3 = Config[flag] and Theme.OnColor or Theme.OffColor
            if flag == "AutoPickup" or flag == "AutoEquip" or flag == "AutoTrigger" then
                Status.Text = Config[flag] and "AUTO MODE" or "MANUAL"
            end
        end)
        
        return frame, dot
    end

    CreateToggle("Auto-Pickup", 0, "AutoPickup")
    CreateToggle("Auto-Equip", 1, "AutoEquip")
    CreateToggle("Auto-Trigger", 2, "AutoTrigger")
    CreateToggle("Teleport", 3, "AutoTeleport")
    CreateToggle("Anti-Void", 4, "AntiVoid")
    CreateToggle("Anti-AFK", 5, "AntiAFK")

    -- SCAN BUTTON
    local ScanBtn = Instance.new("TextButton")
    ScanBtn.Size = UDim2.new(0.42, 0, 0, 35)
    ScanBtn.Position = UDim2.new(0.54, 0, 0, 50)
    ScanBtn.BackgroundColor3 = Theme.Accent
    ScanBtn.Text = "⚡ SCAN"
    ScanBtn.Font = Enum.Font.GothamBold
    ScanBtn.TextSize = 14
    ScanBtn.TextColor3 = Theme.TextWhite
    ScanBtn.Parent = Main
    Instance.new("UICorner", ScanBtn).CornerRadius = UDim.new(0, 8)

    -- FILTER TABS
    local function CreateTab(text, x, y, flag)
        local tab = Instance.new("TextButton")
        tab.Size = UDim2.new(0, 60, 0, 22)
        tab.Position = UDim2.new(0.04 + x * 62, 0, 0, 50 + y * 30 + 35)
        tab.BackgroundColor3 = Theme.ButtonBg
        tab.Text = text
        tab.Font = Enum.Font.GothamMedium
        tab.TextSize = 10
        tab.TextColor3 = Theme.TextWhite
        tab.Parent = Main
        Instance.new("UICorner", tab).CornerRadius = UDim.new(0, 5)
        
        tab.MouseButton1Click:Connect(function()
            Config[flag] = not Config[flag]
            tab.BackgroundColor3 = Config[flag] and Theme.Accent or Theme.ButtonBg
        end)
        
        return tab
    end

    CreateTab("Tools", 0, 7, "ShowTools")
    CreateTab("Pickups", 1, 7, "ShowPickups")
    CreateTab("Secrets", 2, 7, "ShowSecrets")
    CreateTab("Triggers", 3, 7, "ShowTriggers")

    -- RESULTS
    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(0.92, 0, 1, -300)
    Scroll.Position = UDim2.new(0.04, 0, 0, 280)
    Scroll.BackgroundTransparency = 1
    Scroll.ScrollBarThickness = 4
    Scroll.ScrollBarImageColor3 = Theme.Accent
    Scroll.Parent = Main

    Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 2)
    Instance.new("UIPadding", Scroll).PaddingTop = UDim.new(0, 5)

    local ResultText = Instance.new("TextLabel")
    ResultText.Size = UDim2.new(1, -20, 0, 350)
    ResultText.BackgroundTransparency = 1
    ResultText.Text = "Click SCAN to start..."
    ResultText.Font = Enum.Font.Code
    ResultText.TextSize = 10
    ResultText.TextColor3 = Theme.TextSub
    ResultText.TextWrapped = true
    ResultText.AutomaticSize = Enum.AutomaticSize.Y
    ResultText.TextXAlignment = Enum.TextXAlignment.Left
    ResultText.Parent = Scroll

    -- DRAG
    local dragging, dragInput, dragStart, startPos
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = Main.Position
        end
    end)
    Header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- UPDATE
    local function updateResults()
        local txt = ""
        
        if #ScanResults.Tools > 0 and Config.ShowTools then
            txt = txt .. "=== TOOLS ===\n"
            for i, t in ipairs(ScanResults.Tools) do
                local rarity = Config.RarityStars and t.rarity or ""
                txt = txt .. string.format("%s %s (%.1f)\n", rarity, t.name, t.dist)
            end
            txt = txt .. "\n"
        end
        
        if #ScanResults.Pickups > 0 and Config.ShowPickups then
            txt = txt .. "=== PICKUPS ===\n"
            for i, p in ipairs(ScanResults.Pickups) do
                txt = txt .. string.format("[%d] %s (%.1f)\n", i, p.name, p.dist)
            end
            txt = txt .. "\n"
        end
        
        if #ScanResults.Secrets > 0 and Config.ShowSecrets then
            txt = txt .. "=== SECRETS ===\n"
            for i, s in ipairs(ScanResults.Secrets) do
                txt = txt .. string.format("? %s (%.1f)\n", s.name, s.dist)
            end
            txt = txt .. "\n"
        end
        
        if #ScanResults.Triggers > 0 and Config.ShowTriggers then
            txt = txt .. "=== TRIGGERS ===\n"
            for i, t in ipairs(ScanResults.Triggers) do
                txt = txt .. string.format("⚡ %s (%.1f)\n", t.name, t.dist)
            end
            txt = txt .. "\n"
        end
        
        if txt == "" then txt = "No items found. Click SCAN." end
        ResultText.Text = txt
        
        local total = #ScanResults.Tools + #ScanResults.Pickups + #ScanResults.Secrets + #ScanResults.Triggers
        Status.Text = string.format("Scan #%d • %d items", State.ScanCount, total)
    end

    -- SCAN ACTION
    ScanBtn.MouseButton1Click:Connect(function()
        ScanBtn.Text = "⏳ SCANNING..."
        
        pcall(function() ScanAll() end)
        pcall(function() DoAutoPickup() end)
        pcall(function() DoAutoEquip() end)
        pcall(function() DoAutoTrigger() end)
        
        task.delay(0.3, function()
            updateResults()
            ScanBtn.Text = "⚡ SCAN"
        end)
    end)

    -- AUTO SCAN LOOP
    task.spawn(function()
        while true do
            task.wait(Config.ScanInterval)
            if Config.AutoScan and Config.MenuOpen then
                pcall(function() ScanAll() end)
                pcall(function() DoAutoPickup() end)
                pcall(function() DoAutoEquip() end)
                pcall(function() DoAntiVoid() end)
                pcall(function() DoAntiAFK() end)
                pcall(function() updateResults() end)
            end
        end
    end)

    -- CHAR ADDED
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        pcall(function() ScanAll() end)
    end)

    Log("SUCCESS", "INIT", "RRS v3.0 OVERPOWERED Loaded!")
end

delay(0.3, function() pcall(function() CreateGUI() end) end)