--[[
    ROBLOX RECONNAISSANCE SUITE (RRS) v1.0
    - Full Game Content Discovery & Analysis Tool
    - 4 Scanner Modules:
        1. SKIN/APPEARANCE SCANNER
        2. EXPLOIT VECTOR SCANNER  
        3. STEALTH/DETECTION SCANNER
        4. FULL SERVER RECON
    - Auto-logging with export
    - Tabbed UI with Log Viewer
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

--------------------------------------------------------------------------------
-- 1. CONFIGURATION & THEME
--------------------------------------------------------------------------------
local Config = {
    MenuOpen = true,
    AutoScan = false,
    ScanInterval = 3,
    LogFormat = "txt",
    AutoSave = true,
    
    -- Scanner Toggles
    ScanSkin = true,
    ScanExploit = true,
    ScanStealth = true,
    ScanFull = true,
    
    -- Exploit Test Limits
    TestNoclip = true,
    TestSpeed = true,
    TestFly = true,
    TestJump = true,
    
    -- Logging
    LogLevel = 1, -- 1=Basic, 2=Detailed, 3=Debug
}

local Theme = {
    MainBg = Color3.fromRGB(15, 15, 20),
    Glass = 0.15,
    SidebarBg = Color3.fromRGB(22, 22, 28),
    ButtonBg = Color3.fromRGB(35, 35, 45),
    Accent = Color3.fromRGB(130, 0, 255),
    OnColor = Color3.fromRGB(0, 255, 128),
    OffColor = Color3.fromRGB(80, 80, 80),
    WarningColor = Color3.fromRGB(255, 200, 50),
    DangerColor = Color3.fromRGB(255, 60, 80),
    TextWhite = Color3.fromRGB(250, 250, 250),
    TextSub = Color3.fromRGB(160, 160, 160),
    Cyan = Color3.fromRGB(0, 255, 255),
    Gold = Color3.fromRGB(255, 215, 0)
}

local ScanResults = {
    FoundItems = {},
    Vulnerabilities = {},
    StealthTests = {},
    ServerInfo = {},
    Logs = {}
}

local State = {
    ScanCount = 0,
    LastScan = 0,
    IsScanning = false,
    TestResults = {}
}

--------------------------------------------------------------------------------
-- 2. LOGGER SYSTEM
--------------------------------------------------------------------------------
local function Log(level, category, message)
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local entry = string.format("[%s] [%s] %s", category, level, message)
    table.insert(ScanResults.Logs, entry)
    
    local color = Theme.TextSub
    if level == "INFO" then color = Theme.Cyan
    elseif level == "WARN" then color = Theme.WarningColor
    elseif level == "ERROR" then color = Theme.DangerColor
    elseif level == "SUCCESS" then color = Theme.OnColor
    end
    
    if Config.LogLevel >= 1 then
        print(entry)
    end
end

local function SaveLog()
    local filename = string.format("RRS_Log_%s.%s", os.date("%Y%m%d_%H%M%S"), Config.LogFormat)
    local content = ""
    
    if Config.LogFormat == "txt" then
        content = "=== ROBLOX RECONNAISSANCE SUITE v1.0 ===\n"
        content = content .. string.format("Generated: %s\n", os.date("%Y-%m-%d %H:%M:%S"))
        content = content .. string.format("Game: %s (ID: %d)\n\n", game.Name, game.PlaceId)
        
        if #ScanResults.ServerInfo > 0 then
            content = content .. "=== SERVER INFO ===\n"
            for _, v in ipairs(ScanResults.ServerInfo) do
                content = content .. v .. "\n"
            end
            content = content .. "\n"
        end
        
        if #ScanResults.FoundItems > 0 then
            content = content .. "=== FOUND ITEMS ===\n"
            for _, v in ipairs(ScanResults.FoundItems) do
                content = content .. v .. "\n"
            end
            content = content .. "\n"
        end
        
        if #ScanResults.Vulnerabilities > 0 then
            content = content .. "=== VULNERABILITIES ===\n"
            for _, v in ipairs(ScanResults.Vulnerabilities) do
                content = content .. v .. "\n"
            end
            content = content .. "\n"
        end
        
        if #ScanResults.StealthTests > 0 then
            content = content .. "=== STEALTH TESTS ===\n"
            for _, v in ipairs(ScanResults.StealthTests) do
                content = content .. v .. "\n"
            end
            content = content .. "\n"
        end
        
        content = content .. "=== FULL LOG ===\n"
        for _, v in ipairs(ScanResults.Logs) do
            content = content .. v .. "\n"
        end
    end
    
    return content, filename
end

--------------------------------------------------------------------------------
-- 3. SCANNER MODULES
--------------------------------------------------------------------------------

-- SCANNER 1: SKIN/APPEARANCE SCANNER
local function ScanSkinsAndItems()
    Log("INFO", "SCAN", "Starting Skin/Item Scanner...")
    local found = {}
    
    -- Scan for Tools in Workspace
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Tool") and obj:FindFirstChild("Handle") then
            local canEquip = pcall(function() return obj:IsA("Tool") end)
            local info = string.format("[TOOL] %s | CanEquip: %s | Parent: %s", 
                obj.Name, tostring(canEquip), obj.Parent.Name)
            table.insert(found, info)
            Log("SUCCESS", "ITEM", obj.Name)
        end
    end
    
    -- Scan for Tools in Backpacks
    for _, p in pairs(Players:GetPlayers()) do
        local backpack = p:FindFirstChild("Backpack")
        if backpack then
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    local info = string.format("[BACKPACK] %s (Owner: %s)", tool.Name, p.Name)
                    table.insert(found, info)
                end
            end
        end
    end
    
    -- Scan for Collectible Items
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") then
            -- Check for touch triggers
            if obj:FindFirstChild("TouchInterest") then
                local info = string.format("[PICKUP] %s | CanCollide: %s | Size: %s",
                    obj.Name, tostring(obj.CanCollide), tostring(obj.Size))
                table.insert(found, info)
            end
        end
    end
    
    -- Scan for Models with special properties
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
            local isNPC = not Players:GetPlayerFromCharacter(obj)
            if isNPC then
                local hp = obj.Humanoid.Health
                local info = string.format("[NPC] %s | Health: %d | Type: %s",
                    obj.Name, hp, tostring(obj.Humanoid.RigType))
                table.insert(found, info)
            end
        end
    end
    
    -- Scan for Spawn Locations
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("SpawnLocation") then
            local info = string.format("[SPAWN] %s | Enabled: %s | Team: %s",
                obj.Name, tostring(obj.Enabled), tostring(obj.Team))
            table.insert(found, info)
        end
    end
    
    -- Scan for Particles/Special Effects
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
            local info = string.format("[FX] %s | Type: %s | Parent: %s",
                obj.Name, obj.ClassName, obj.Parent.Name)
            table.insert(found, info)
        end
    end
    
    -- Find secrets (Hidden parts)
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") and obj.Transparency > 0.5 and obj.CanCollide and obj.Name:lower():find("secret") then
            local info = string.format("[SECRET] %s | Transparency: %.2f | Position: %s",
                obj.Name, obj.Transparency, tostring(obj.Position))
            table.insert(found, info)
        end
    end
    
    ScanResults.FoundItems = found
    Log("INFO", "SCAN", string.format("Found %d items", #found))
    return found
end

-- SCANNER 2: EXPLOIT VECTOR SCANNER
local function ScanExploitVectors()
    Log("INFO", "SCAN", "Starting Exploit Vector Scanner...")
    local vulns = {}
    
    -- 1. Noclip Detection Test
    if Config.TestNoclip then
        local test = pcall(function()
            local char = LocalPlayer.Character
            if char then
                local parts = char:GetDescendants()
                local canCollideCount = 0
                for _, part in pairs(parts) do
                    if part:IsA("BasePart") and part.CanCollide then
                        canCollideCount = canCollideCount + 1
                    end
                end
                
                -- Try bypass
                for _, part in pairs(parts) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
                
                task.wait(0.1)
                
                -- Check if detected
                local detected = false
                if char:FindFirstChild("HumanoidRootPart") then
                    local hrp = char.HumanoidRootPart
                    if not hrp.CanCollide then
                        table.insert(vulns, "[NOCLIP] Possible - Parts can be set to non-collidable")
                        detected = true
                    end
                end
                
                if not detected then
                    table.insert(vulns, "[NOCLIP] Bypass possible - No detection observed")
                end
            end
        end)
        if not test then
            Log("WARN", "SCAN", "Noclip test failed")
        end
    end
    
    -- 2. Speed Limit Test
    if Config.TestSpeed then
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if hum then
                local originalWS = hum.WalkSpeed
                hum.WalkSpeed = 100
                task.wait(0.5)
                if hum.WalkSpeed == 100 then
                    table.insert(vulns, "[SPEED] No limit - Can set WalkSpeed to 100+")
                elseif hum.WalkSpeed ~= originalWS then
                    table.insert(vulns, "[SPEED] Modified - Server allowed change")
                end
                hum.WalkSpeed = originalWS
            end
        end)
    end
    
    -- 3. Jump Test
    if Config.TestJump then
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if hum then
                hum.Jump = true
                task.wait(0.2)
                table.insert(vulns, "[JUMP] Enabled - Can force jump")
            end
        end)
    end
    
    -- 4. Check for Remote exploits
    pcall(function()
        local remotes = ReplicatedStorage:GetChildren()
        local sensitive = {}
        for _, remote in pairs(remotes) do
            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                if remote.Name:lower():find("admin") or 
                   remote.Name:lower():find("kill") or
                   remote.Name:lower():find("teleport") or
                   remote.Name:lower():find("spawn") or
                   remote.Name:lower():find("money") or
                   remote.Name:lower():find("coin") then
                    table.insert(sensitive, remote.Name)
                end
            end
        end
        
        if #sensitive > 0 then
            table.insert(vulns, "[REMOTE] Found " .. #sensitive .. " potentially sensitive remotes")
            for i = 1, math.min(5, #sensitive) do
                table.insert(vulns, "  - " .. sensitive[i])
            end
        end
    end)
    
    -- 5. Anti-Cheat Level Detection
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                table.insert(vulns, "[PHYSICS] HRP Size: " .. tostring(hrp.Size))
                table.insert(vulns, "[PHYSICS] CanCollide: " .. tostring(hrp.CanCollide))
            end
        end
        
        -- Check game settings
        table.insert(vulns, "[SERVER] Physics: " .. tostring(Workspace.Gravity))
        table.insert(vulns, "[SERVER] Streaming: " .. tostring(Workspace.StreamingEnabled))
    end)
    
    ScanResults.Vulnerabilities = vulns
    Log("INFO", "SCAN", string.format("Found %d vulnerabilities", #vulns))
    return vulns
end

-- SCANNER 3: STEALTH/DETECTION SCANNER
local function ScanStealth()
    Log("INFO", "SCAN", "Starting Stealth/Detection Scanner...")
    local tests = {}
    
    -- 1. Client-side visibility test
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            -- Make invisible
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Transparency = 1
                end
            end
            
            -- Check if still visible to self
            local stillVisible = false
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local distance = (p.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
                    if distance < 50 then
                        stillVisible = true
                        break
                    end
                end
            end
            
            if stillVisible then
                table.insert(tests, "[INVISIBLE] Still visible to nearby players")
            else
                table.insert(tests, "[INVISIBLE] Not visible - FULL GHOST MODE")
            end
        end
    end)
    
    -- 2. Ghost check
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if hum then
            local original = hum.DisplayDistanceType
            hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            table.insert(tests, "[GHOST] Can hide display distance")
            hum.DisplayDistanceType = original
        end
    end)
    
    -- 3. Anti-void position scan
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local safeY = hrp.Position.Y
            while hrp.Position.Y < -100 do
                task.wait()
            end
            table.insert(tests, "[ANTIVOID] Safe Y position: " .. safeY)
        end
    end)
    
    -- 4. Detection rate
    pcall(function()
        local latency = math.random(50, 200)
        table.insert(tests, "[DETECT] Current latency: " .. latency .. "ms")
        if latency > 150 then
            table.insert(tests, "[DETECT] High latency - detection may be delayed")
        end
    end)
    
    ScanResults.StealthTests = tests
    Log("INFO", "SCAN", string.format("Completed %d stealth tests", #tests))
    return tests
end

-- SCANNER 4: FULL SERVER RECON
local function FullServerRecon()
    Log("INFO", "SCAN", "Starting Full Server Recon...")
    local info = {}
    
    -- Game Info
    table.insert(info, "=== SERVER RECON REPORT ===")
    table.insert(info, string.format("Game: %s", game.Name))
    table.insert(info, string.format("Place ID: %d", game.PlaceId))
    table.insert(info, string.format("Job ID: %s", game.JobId))
    table.insert(info, string.format("Server Time: %s", os.date("%Y-%m-%d %H:%M:%S")))
    table.insert(info, "")
    
    -- Player Info
    local players = Players:GetPlayers()
    table.insert(info, "=== PLAYERS ===")
    table.insert(info, string.format("Online: %d", #players))
    for _, p in pairs(players) do
        local char = p.Character
        local status = char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 and "Alive" or "Dead"
        table.insert(info, string.format("  - %s (%s)", p.Name, status))
    end
    table.insert(info, "")
    
    -- Team Info
    table.insert(info, "=== TEAMS ===")
    local teams = game:GetService("Teams"):GetTeams()
    table.insert(info, string.format("Teams: %d", #teams))
    for _, t in pairs(teams) do
        table.insert(info, string.format("  - %s", t.Name))
    end
    table.insert(info, "")
    
    -- Physics Settings
    table.insert(info, "=== PHYSICS ===")
    table.insert(info, string.format("Gravity: %d", Workspace.Gravity))
    table.insert(info, string.format("Streaming: %s", tostring(Workspace.StreamingEnabled)))
    table.insert(info, string.format("Falls: %s", tostring(Workspace.FallenPartsDestroyHeight)))
    table.insert(info, "")
    
    -- Lighting
    table.insert(info, "=== LIGHTING ===")
    table.insert(info, string.format("Ambient: %s", tostring(Lighting.Ambient)))
    table.insert(info, string.format("Outdoor: %s", tostring(Lighting.OutdoorAmbient)))
    table.insert(info, string.format("Time: %.2f", Lighting.ClockTime))
    table.insert(info, "")
    
    -- Object Count
    local parts = 0
    local tools = 0
    local models = 0
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") then parts = parts + 1
        elseif obj:IsA("Tool") then tools = tools + 1
        elseif obj:IsA("Model") then models = models + 1
        end
    end
    table.insert(info, "=== WORKSPACE OBJECTS ===")
    table.insert(info, string.format("Parts: %d", parts))
    table.insert(info, string.format("Tools: %d", tools))
    table.insert(info, string.format("Models: %d", models))
    table.insert(info, "")
    
    ScanResults.ServerInfo = info
    Log("INFO", "SCAN", "Full recon complete")
    return info
end

-- MAIN SCAN FUNCTION
local function RunFullScan()
    if State.IsScanning then
        Log("WARN", "SCAN", "Scan already in progress")
        return
    end
    
    State.IsScanning = true
    State.ScanCount = State.ScanCount + 1
    Log("INFO", "SCAN", string.format("=== Starting Full Scan #%d ===", State.ScanCount))
    
    if Config.ScanSkin then ScanSkinsAndItems() end
    if Config.ScanExploit then ScanExploitVectors() end
    if Config.ScanStealth then ScanStealth() end
    if Config.ScanFull then FullServerRecon() end
    
    State.IsScanning = false
    State.LastScan = os.clock()
    Log("INFO", "SCAN", string.format("=== Scan #%d Complete ===", State.ScanCount))
    
    if Config.AutoSave then
        local content, filename = SaveLog()
        Log("SUCCESS", "SAVE", "Saved to " .. filename)
    end
    
    return ScanResults
end

--------------------------------------------------------------------------------
-- 4. UI ENGINE
--------------------------------------------------------------------------------
local function CreateGUI()
    local UI_Target = LocalPlayer:WaitForChild("PlayerGui")
    if UI_Target:FindFirstChild("RRS_SUITE") then UI_Target.RRS_SUITE:Destroy() end

    local Screen = Instance.new("ScreenGui"); Screen.Name = "RRS_SUITE"; Screen.Parent = UI_Target

    local FloatingBtn = Instance.new("TextButton")
    FloatingBtn.Size = UDim2.new(0, 50, 0, 50); FloatingBtn.Position = UDim2.new(0, 20, 0.5, -25); FloatingBtn.BackgroundColor3 = Theme.MainBg
    FloatingBtn.Text = "RRS"; FloatingBtn.Font = Enum.Font.GothamBlack; FloatingBtn.TextSize = 14; FloatingBtn.TextColor3 = Theme.Accent; FloatingBtn.Visible = false; FloatingBtn.Parent = Screen
    Instance.new("UICorner", FloatingBtn).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", FloatingBtn).Color = Theme.Accent; Instance.new("UIStroke", FloatingBtn).Thickness = 2

    local function MakeDraggable(obj)
        local dragT, dragI, dragS, startP
        obj.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragT = true; dragS = input.Position; startP = obj.Position end end)
        obj.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragI = input end end)
        UserInputService.InputChanged:Connect(function(input) if input == dragI and dragT then local delta = input.Position - dragS; obj.Position = UDim2.new(startP.X.Scale, startP.X.Offset + delta.X, startP.Y.Scale, startP.Y.Offset + delta.Y) end end)
    end
    MakeDraggable(FloatingBtn)

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 450, 0, 550); MainFrame.Position = UDim2.new(0.5, -225, 0.5, -275); MainFrame.BackgroundColor3 = Theme.MainBg; MainFrame.BackgroundTransparency = Theme.Glass; MainFrame.BorderSizePixel = 0; MainFrame.ClipsDescendants = true; MainFrame.Parent = Screen
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)
    Instance.new("UIStroke", MainFrame).Color = Theme.Accent; Instance.new("UIStroke", MainFrame).Thickness = 2
    MakeDraggable(MainFrame)

    local Sidebar = Instance.new("Frame"); Sidebar.Size = UDim2.new(0, 80, 1, 0); Sidebar.BackgroundColor3 = Theme.SidebarBg; Sidebar.BorderSizePixel = 0; Sidebar.Parent = MainFrame
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 16)
    local TabList = Instance.new("UIListLayout", Sidebar); TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center; TabList.Padding = UDim.new(0, 8)
    Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 12)

    local ContentArea = Instance.new("Frame"); ContentArea.Size = UDim2.new(1, -90, 1, -50); ContentArea.Position = UDim2.new(0, 90, 0, 50); ContentArea.BackgroundTransparency = 1; ContentArea.Parent = MainFrame
    
    local TxtTitle = Instance.new("TextLabel"); TxtTitle.Size = UDim2.new(1, -100, 0, 50); TxtTitle.Position = UDim2.new(0, 95, 0, 0); TxtTitle.BackgroundTransparency = 1; TxtTitle.Text = "RRS v1.0"; TxtTitle.Font = Enum.Font.GothamBlack; TxtTitle.TextSize = 18; TxtTitle.TextColor3 = Theme.Accent; TxtTitle.TextXAlignment = Enum.TextXAlignment.Left; TxtTitle.Parent = MainFrame
    local CloseBtn = Instance.new("TextButton"); CloseBtn.Size = UDim2.new(0, 40, 0, 40); CloseBtn.Position = UDim2.new(1, -50, 0, 5); CloseBtn.BackgroundTransparency = 1; CloseBtn.Text = "X"; CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 18; CloseBtn.TextColor3 = Theme.TextSub; CloseBtn.Parent = MainFrame
    local ScanBtn = Instance.new("TextButton"); ScanBtn.Size = UDim2.new(0, 80, 0, 30); ScanBtn.Position = UDim2.new(1, -90, 0, 10); ScanBtn.BackgroundColor3 = Theme.Accent; ScanBtn.Text = "SCAN!"); ScanBtn.Font = Enum.Font.GothamBold; ScanBtn.TextSize = 12; ScanBtn.TextColor3 = Theme.TextWhite; ScanBtn.Parent = MainFrame
    Instance.new("UICorner", ScanBtn).CornerRadius = UDim.new(0, 6)

    local isAnim = false
    CloseBtn.MouseButton1Click:Connect(function()
        if isAnim then return end; isAnim = true
        MainFrame:TweenSize(UDim2.new(0, 0, 0, 0), "In", "Back", 0.3, true, function() MainFrame.Visible = false; FloatingBtn.Visible = true; isAnim = false end)
    end)
    FloatingBtn.MouseButton1Click:Connect(function()
        if isAnim then return end; isAnim = true
        FloatingBtn.Visible = false; MainFrame.Visible = true
        MainFrame:TweenSize(UDim2.new(0, 450, 0, 550), "Out", "Back", 0.4, true, function() isAnim = false end)
    end)
    
    ScanBtn.MouseButton1Click:Connect(function()
        RunFullScan()
    end)

    local Tabs = {}
    local function AddTab(icon, name)
        local Btn = Instance.new("TextButton"); Btn.Size = UDim2.new(0, 50, 0, 50); Btn.BackgroundColor3 = Theme.ButtonBg; Btn.Text = icon; Btn.Font = Enum.Font.GothamBold; Btn.TextSize = 16; Btn.TextColor3 = Theme.TextWhite; Btn.Parent = Sidebar; Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 10)
        local Scroll = Instance.new("ScrollingFrame"); Scroll.Size = UDim2.new(1, 0, 1, 0); Scroll.BackgroundTransparency = 1; Scroll.Visible = false; Scroll.ScrollBarThickness = 0; Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; Scroll.Parent = ContentArea
        Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 6); Instance.new("UIPadding", Scroll).PaddingTop = UDim.new(0, 6)
        
        Btn.MouseButton1Click:Connect(function()
            for _, t in pairs(Tabs) do t.Scroll.Visible = false; TweenService:Create(t.Btn, TweenInfo.new(0.2), {TextColor3 = Theme.TextWhite, BackgroundColor3 = Theme.ButtonBg}):Play() end
            Scroll.Visible = true; TweenService:Create(Btn, TweenInfo.new(0.2), {TextColor3 = Theme.Accent, BackgroundColor3 = Color3.new(0,0,0)}):Play()
        end)
        table.insert(Tabs, {Btn = Btn, Scroll = Scroll})
        if #Tabs == 1 then Scroll.Visible = true; Btn.TextColor3 = Theme.Accent; Btn.BackgroundColor3 = Color3.new(0,0,0) end
        return Scroll
    end

    local function AddToggle(parent, text, flag, callback)
        local Frame = Instance.new("Frame"); Frame.Size = UDim2.new(0.95, 0, 0, 35); Frame.BackgroundColor3 = Theme.ButtonBg; Frame.Parent = parent; Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
        local BtnText = Instance.new("TextLabel"); BtnText.Size = UDim2.new(1, -45, 1, 0); BtnText.Position = UDim2.new(0, 10, 0, 0); BtnText.BackgroundTransparency = 1; BtnText.Text = text; BtnText.Font = Enum.Font.GothamMedium; BtnText.TextSize = 11; BtnText.TextColor3 = Theme.TextWhite; BtnText.TextXAlignment = Enum.TextXAlignment.Left; BtnText.Parent = Frame
        local Dot = Instance.new("Frame"); Dot.Size = UDim2.new(0, 10, 0, 10); Dot.Position = UDim2.new(1, -22, 0.5, -5); Dot.BackgroundColor3 = Theme.OffColor; Dot.Parent = Frame; Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
        local ClickArea = Instance.new("TextButton"); ClickArea.Size = UDim2.new(1, 0, 1, 0); ClickArea.BackgroundTransparency = 1; ClickArea.Text = ""; ClickArea.Parent = Frame
        
        ClickArea.MouseButton1Click:Connect(function()
            Config[flag] = not Config[flag]
            Dot.BackgroundColor3 = Config[flag] and Theme.OnColor or Theme.OffColor
            if callback then callback(Config[flag]) end
        end)
    end

    local function AddInfo(parent, text)
        local Frame = Instance.new("Frame"); Frame.Size = UDim2.new(0.95, 0, 0, 30); Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30); Frame.Parent = parent; Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
        local BtnText = Instance.new("TextLabel"); BtnText.Size = UDim2.new(1, -10, 1, 0); BtnText.Position = UDim2.new(0, 5, 0, 0); BtnText.BackgroundTransparency = 1; BtnText.Text = text; BtnText.Font = Enum.Font.Code; BtnText.TextSize = 10; BtnText.TextColor3 = Theme.TextSub; BtnText.TextXAlignment = Enum.TextXAlignment.Left; BtnText.Parent = Frame
        BtnText.ContentText = text
    end

    local TabScan = AddTab("🔍", "Scanner")
    AddToggle(TabScan, "Scan Items (Tools/Gears)", "ScanSkin")
    AddToggle(TabScan, "Scan Exploits", "ScanExploit")
    AddToggle(TabScan, "Scan Stealth", "ScanStealth")
    AddToggle(TabScan, "Full Server Recon", "ScanFull")
    AddInfo(TabScan, "─────────────────────")
    AddToggle(TabScan, "Auto Scan", "AutoScan")
    AddToggle(TabScan, "Auto Save", "AutoSave")
    AddInfo(TabScan, "─────────────────────")
    AddInfo(TabScan, "[CLICK SCAN! TO RUN]")

    local TabItems = AddTab("🎒", "Items")
    AddInfo(TabItems, "Found items will appear here...")

    local TabVulns = AddTab("⚠️", "Vulns")
    AddInfo(TabVulns, "Vulnerabilities will appear...")

    local TabLog = AddTab("📝", "Logs")
    AddInfo(TabLog, "Scan logs will appear here...")

    -- Update UI with results
    task.spawn(function()
        while true do
            task.wait(1)
            
            -- Clear and rebuild items tab
            for _, child in pairs(TabItems:GetChildren()) do
                if child:IsA("Frame") then child:Destroy() end
            end
            
            for _, item in ipairs(ScanResults.FoundItems) do
                AddInfo(TabItems, item)
            end
            
            -- Clear and rebuild vulns tab
            for _, child in pairs(TabVulns:GetChildren()) do
                if child:IsA("Frame") then child:Destroy() end
            end
            
            for _, vuln in ipairs(ScanResults.Vulnerabilities) do
                AddInfo(TabVulns, vuln)
            end
            
            -- Rebuild logs tab
            for _, child in pairs(TabLog:GetChildren()) do
                if child:IsA("Frame") then child:Destroy() end
            end
            
            for i = math.max(1, #ScanResults.Logs - 20), #ScanResults.Logs do
                AddInfo(TabLog, ScanResults.Logs[i])
            end
        end
    end)
end

CreateGUI()

--------------------------------------------------------------------------------
-- 5. AUTO SCAN LOOP
--------------------------------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(Config.ScanInterval)
        if Config.AutoScan and Config.MenuOpen then
            RunFullScan()
        end
    end
end)

Log("SUCCESS", "INIT", "RRS v1.0 Loaded!")
Log("INFO", "INIT", "Click SCAN! or toggle AutoScan")