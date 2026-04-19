--[[
    THIRTY COMBO EDITION BY AKF - ALL IN ONE
    - COMBINED: V13 + OWL V2 + V18.6
    - UI: Tabbed, Draggable, Purple Theme
    - TABS: Combat, Movement, Fishing, Ghost, Protect, System
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")

--------------------------------------------------------------------------------
-- 1. CONFIGURATION
--------------------------------------------------------------------------------
local Config = {
    MenuOpen = true, TeamCheck = true,
    
    -- COMBAT
    Aimbot = false, Smoothness = 0.5, FOV = 250,
    ESP = false, HitboxExpander = false, HitboxSize = 15, Reach = false,
    
    -- MOVEMENT
    Speed = false, SpeedMultiplier = 50, Jump = false, Noclip = false, Fly = false, FlySpeed = 60,
    
    -- FISHING
    AutoFish = false, FishDelay = 2.5, JesusMode = false, SellCFrame = nil,
    
    -- GHOST
    Fullbright = false, Invisible = false,
    
    -- PROTECT
    AdminDetect = false, VisualRadar = false, AutoHop = false,
    
    -- SYSTEM
    SavedCFrame = nil
}

local Theme = {
    MainBg = Color3.fromRGB(15, 15, 20),
    HeaderBg = Color3.fromRGB(22, 22, 28),
    TabBg = Color3.fromRGB(28, 28, 35),
    ButtonBg = Color3.fromRGB(35, 35, 45),
    Accent = Color3.fromRGB(130, 0, 255),
    OnColor = Color3.fromRGB(0, 255, 128),
    OffColor = Color3.fromRGB(80, 80, 80),
    Danger = Color3.fromRGB(255, 60, 80),
    Safe = Color3.fromRGB(0, 200, 100),
    TextWhite = Color3.fromRGB(250, 250, 250),
    TextSub = Color3.fromRGB(160, 160, 160)
}

local PlayerData = {}
local WaterPad = Instance.new("Part", Workspace)
WaterPad.Size = Vector3.new(15, 1, 15)
WaterPad.Anchored = true
WaterPad.CanCollide = true
WaterPad.Transparency = 0.5
WaterPad.Material = Enum.Material.Glass
WaterPad.BrickColor = BrickColor.new("Cyan")
WaterPad.Position = Vector3.new(0, -9999, 0)

local DefaultWS = 16

--------------------------------------------------------------------------------
-- 2. UI ENGINE
--------------------------------------------------------------------------------
local function CreateGUI()
    local UI_Target = LocalPlayer:WaitForChild("PlayerGui")
    if UI_Target:FindFirstChild("THIRPY_COMBO") then UI_Target.THIRPY_COMBO:Destroy() end

    local Screen = Instance.new("ScreenGui"); Screen.Name = "THIRPY_COMBO"; Screen.ResetOnSpawn = false; Screen.Parent = UI_Target

    local FloatingBtn = Instance.new("TextButton")
    FloatingBtn.Size = UDim2.new(0, 50, 0, 50); FloatingBtn.Position = UDim2.new(0, 20, 0.5, -25)
    FloatingBtn.BackgroundColor3 = Theme.MainBg
    FloatingBtn.Text = "THIR"; FloatingBtn.Font = Enum.Font.GothamBlack; FloatingBtn.TextSize = 14
    FloatingBtn.TextColor3 = Theme.Accent; FloatingBtn.Visible = false; FloatingBtn.Parent = Screen
    Instance.new("UICorner", FloatingBtn).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", FloatingBtn).Color = Theme.Accent; Instance.new("UIStroke", FloatingBtn).Thickness = 2

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 360, 0, 500); MainFrame.Position = UDim2.new(0.5, -180, 0.5, -250)
    MainFrame.BackgroundColor3 = Theme.MainBg; MainFrame.BorderSizePixel = 0; MainFrame.ClipsDescendants = true
    MainFrame.Parent = Screen
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)
    Instance.new("UIStroke", MainFrame).Color = Theme.Accent; Instance.new("UIStroke", MainFrame).Thickness = 2

    local Header = Instance.new("Frame"); Header.Size = UDim2.new(1, 0, 0, 50); Header.BackgroundColor3 = Theme.HeaderBg; Header.Parent = MainFrame

    local Title = Instance.new("TextLabel"); Title.Size = UDim2.new(1, -60, 1, 0); Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1; Title.Text = "THIRPY COMBO"; Title.Font = Enum.Font.GothamBlack; Title.TextSize = 16
    Title.TextColor3 = Theme.Accent; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.Parent = Header

    local CloseBtn = Instance.new("TextButton"); CloseBtn.Size = UDim2.new(0, 50, 1, 0); CloseBtn.Position = UDim2.new(1, -50, 0, 0)
    CloseBtn.BackgroundTransparency = 1; CloseBtn.Text = "X"; CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 16
    CloseBtn.TextColor3 = Theme.TextSub; CloseBtn.Parent = Header

    local TabContainer = Instance.new("Frame"); TabContainer.Size = UDim2.new(1, 0, 0, 35); TabContainer.Position = UDim2.new(0, 0, 0, 50)
    TabContainer.BackgroundColor3 = Theme.TabBg; TabContainer.Parent = MainFrame
    local TabList = Instance.new("UIListLayout", TabContainer); TabList.FillDirection = Enum.FillDirection.Horizontal; TabList.SortOrder = Enum.SortOrder.LayoutOrder

    local ContentArea = Instance.new("ScrollingFrame"); ContentArea.Size = UDim2.new(1, 0, 1, -85); ContentArea.Position = UDim2.new(0, 0, 0, 85)
    ContentArea.BackgroundTransparency = 1; ContentArea.ScrollBarThickness = 2; ContentArea.ScrollBarImageColor3 = Theme.Accent
    ContentArea.AutomaticCanvasSize = Enum.AutomaticSize.Y; ContentArea.Parent = MainFrame
    Instance.new("UIListLayout", ContentArea).Padding = UDim.new(0, 8); Instance.new("UIListLayout", ContentArea).HorizontalAlignment = Enum.HorizontalAlignment.Center
    Instance.new("UIPadding", ContentArea).PaddingTop = UDim.new(0, 10)

    local function MakeDraggable(obj, target)
        local dT, dI, dS, sP
        obj.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dT = true; dS = i.Position; sP = target.Position end end)
        obj.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement then dI = i end end)
        UserInputService.InputChanged:Connect(function(i) if i == dI and dT then local d = i.Position - dS; target.Position = UDim2.new(sP.X.Scale, sP.X.Offset + d.X, sP.Y.Scale, sP.Y.Offset + d.Y) end end)
    end
    MakeDraggable(Header, MainFrame); MakeDraggable(FloatingBtn, FloatingBtn)

    local isAnim = false
    CloseBtn.MouseButton1Click:Connect(function() if isAnim then return end; isAnim = true; Config.MenuOpen = false
        MainFrame:TweenSize(UDim2.new(0, 0, 0, 0), "In", "Back", 0.3, true, function() MainFrame.Visible = false; FloatingBtn.Visible = true; isAnim = false end)
    end)
    FloatingBtn.MouseButton1Click:Connect(function() if isAnim then return end; isAnim = true; Config.MenuOpen = true
        FloatingBtn.Visible = false; MainFrame.Visible = true
        MainFrame:TweenSize(UDim2.new(0, 360, 0, 500), "Out", "Back", 0.4, true, function() isAnim = false end)
    end)

    local Tabs = {}; local firstTab = true
    local function CreateTab(name)
        local TabBtn = Instance.new("TextButton"); TabBtn.Size = UDim2.new(0.165, 0, 1, 0); TabBtn.BackgroundTransparency = 1
        TabBtn.Text = name; TabBtn.Font = Enum.Font.GothamBold; TabBtn.TextSize = 11; TabBtn.TextColor3 = Theme.TextSub; TabBtn.Parent = TabContainer
        local Ind = Instance.new("Frame"); Ind.Size = UDim2.new(0.6, 0, 0, 3); Ind.Position = UDim2.new(0.2, 0, 1, -3)
        Ind.BackgroundColor3 = Theme.Accent; Ind.BackgroundTransparency = 1; Ind.Parent = TabBtn; Instance.new("UICorner", Ind).CornerRadius = UDim.new(1, 0)

        local Scroll = Instance.new("ScrollingFrame"); Scroll.Size = UDim2.new(1, 0, 1, 0); Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 2
        Scroll.ScrollBarImageColor3 = Theme.Accent; Scroll.Visible = false; Scroll.Parent = ContentArea
        Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 8)

        table.insert(Tabs, {Btn = TabBtn, Ind = Ind, Content = Scroll})
        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Tabs) do v.Content.Visible = false; TweenService:Create(v.Btn, TweenInfo.new(0.2), {TextColor3 = Theme.TextSub}):Play(); TweenService:Create(v.Ind, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play() end
            Scroll.Visible = true; TweenService:Create(TabBtn, TweenInfo.new(0.2), {TextColor3 = Theme.TextWhite}):Play(); TweenService:Create(Ind, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
        end)
        if firstTab then Scroll.Visible = true; TabBtn.TextColor3 = Theme.TextWhite; Ind.BackgroundTransparency = 0; firstTab = false end
        return Scroll
    end

    local function AddToggle(parent, text, flag, callback)
        local Btn = Instance.new("Frame"); Btn.Size = UDim2.new(0.9, 0, 0, 40); Btn.BackgroundColor3 = Theme.ButtonBg; Btn.Parent = parent
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
        local Stroke = Instance.new("UIStroke", Btn); Stroke.Color = Theme.OffColor; Stroke.Thickness = 1
        local Txt = Instance.new("TextLabel"); Txt.Size = UDim2.new(1, -50, 1, 0); Txt.Position = UDim2.new(0, 10, 0, 0)
        Txt.BackgroundTransparency = 1; Txt.Text = text; Txt.Font = Enum.Font.GothamMedium; Txt.TextSize = 12
        Txt.TextColor3 = Theme.TextWhite; Txt.TextXAlignment = Enum.TextXAlignment.Left; Txt.Parent = Btn
        local Dot = Instance.new("Frame"); Dot.Size = UDim2.new(0, 12, 0, 12); Dot.Position = UDim2.new(1, -22, 0.5, -6)
        Dot.BackgroundColor3 = Config[flag] and Theme.OnColor or Theme.OffColor; Dot.Parent = Btn; Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
        local Click = Instance.new("TextButton"); Click.Size = UDim2.new(1, 0, 1, 0); Click.BackgroundTransparency = 1; Click.Text = ""; Click.Parent = Btn

        Click.MouseButton1Click:Connect(function()
            Config[flag] = not Config[flag]; local st = Config[flag]
            if st then Stroke.Color = Theme.OnColor; Dot.BackgroundColor3 = Theme.OnColor else Stroke.Color = Theme.OffColor; Dot.BackgroundColor3 = Theme.OffColor end
            if callback then callback(st) end
        end)
    end

    local function AddAction(parent, text, callback, isDanger)
        local Btn = Instance.new("Frame"); Btn.Size = UDim2.new(0.9, 0, 0, 40); Btn.BackgroundColor3 = Theme.ButtonBg; Btn.Parent = parent
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
        if isDanger then Instance.new("UIStroke", Btn).Color = Theme.Danger end
        local Txt = Instance.new("TextLabel"); Txt.Size = UDim2.new(1, 0, 1, 0)
        Txt.BackgroundTransparency = 1; Txt.Text = text; Txt.Font = Enum.Font.GothamBold; Txt.TextSize = 12
        Txt.TextColor3 = isDanger and Theme.Danger or Theme.Accent; Txt.TextXAlignment = Enum.TextXAlignment.Center; Txt.Parent = Btn
        local Click = Instance.new("TextButton"); Click.Size = UDim2.new(1, 0, 1, 0); Click.BackgroundTransparency = 1; Click.Text = ""; Click.Parent = Btn
        Click.MouseButton1Click:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Accent}):Play()
            task.delay(0.1, function() TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.ButtonBg}):Play() end)
            if callback then callback() end
        end)
    end

    -- TABS
    local TabCombat = CreateTab("COMBAT")
    local TabMove = CreateTab("MOVEMENT")
    local TabFish = CreateTab("FISHING")
    local TabGhost = CreateTab("GHOST")
    local TabProtect = CreateTab("PROTECT")
    local TabSys = CreateTab("SYSTEM")

    -- COMBAT TAB
    AddToggle(TabCombat, "Auto-Aim", "Aimbot")
    AddToggle(TabCombat, "ESP", "ESP")
    AddToggle(TabCombat, "Hitbox Expander", "HitboxExpander")
    AddToggle(TabCombat, "Melee Reach", "Reach")

    -- MOVEMENT TAB
    AddToggle(TabMove, "Speed Hack", "Speed")
    AddToggle(TabMove, "Infinite Jump", "Jump")
    AddToggle(TabMove, "Fly Hack", "Fly")
    AddToggle(TabMove, "Noclip", "Noclip")

    -- FISHING TAB
    AddToggle(TabFish, "Auto-Fish", "AutoFish")
    AddToggle(TabFish, "Jesus Mode", "JesusMode")
    AddAction(TabFish, "📌 Set Sell Point", function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then Config.SellCFrame = hrp.CFrame end
    end)
    AddAction(TabFish, "💰 TP ke Sell", function()
        if Config.SellCFrame then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then TweenService:Create(hrp, TweenInfo.new(1, Enum.EasingStyle.Linear), {CFrame = Config.SellCFrame}):Play() end
        end
    end)

    -- GHOST TAB
    AddToggle(TabGhost, "Fullbright", "Fullbright", function(v)
        if v then Lighting.Ambient = Color3.new(1,1,1); Lighting.OutdoorAmbient = Color3.new(1,1,1); Lighting.Brightness = 2
        else Lighting.Ambient = Color3.fromRGB(127,127,127); Lighting.OutdoorAmbient = Color3.fromRGB(127,127,127); Lighting.Brightness = 1 end
    end)
    AddToggle(TabGhost, "Invisible", "Invisible", function(v)
        local char = LocalPlayer.Character; if not char then return end
        if v then for _, p in pairs(char:GetDescendants()) do if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = 1 elseif p:IsA("Decal") then p.Transparency = 1 end end
        else for _, p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then p.Transparency = 0 elseif p:IsA("Decal") then p.Transparency = 0 end end end
    end)

    -- PROTECT TAB
    AddToggle(TabProtect, "Admin Detection", "AdminDetect")
    AddToggle(TabProtect, "Visual Radar (ESP)", "VisualRadar")
    AddToggle(TabProtect, "Auto-Evade (Hop)", "AutoHop")

    -- SYSTEM TAB
    AddAction(TabSys, "📌 Save Waypoint", function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then Config.SavedCFrame = hrp.CFrame end
    end)
    AddAction(TabSys, "⚡ TP ke Waypoint", function()
        if Config.savedCFrame then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = Config.savedCFrame end
        end
    end)
    AddAction(TabSys, "🌐 Server Hop", function()
        TeleportService:Teleport(game.PlaceId)
    end, true)
    AddAction(TabSys, "🔄 Rejoin", function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end)

    return Screen
end

CreateGUI()

--------------------------------------------------------------------------------
-- 3. LOGIC: ESP
--------------------------------------------------------------------------------
local ESP_Folder = Instance.new("Folder"); ESP_Folder.Name = "THIRPY_ESP"
ESP_Folder.Parent = Workspace

local FOV_Box = Instance.new("Frame")
FOV_Box.BackgroundTransparency = 1; FOV_Box.BorderColor3 = Theme.Accent; FOV_Box.BorderSizePixel = 2; FOV_Box.Visible = false
FOV_Box.ZIndex = 100; FOV_Box.Parent = LocalPlayer:WaitForChild("PlayerGui")

local function IsEnemy(p)
    if not Config.TeamCheck then return true end
    if p.Team == nil or p.Team ~= LocalPlayer.Team then return true end
    return false
end

task.spawn(function()
    while true do
        ESP_Folder:ClearAllChildren()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and IsEnemy(p) then
                if Config.ESP then
                    local hl = Instance.new("Highlight")
                    hl.Adornee = p.Character; hl.FillColor = Theme.Accent; hl.FillTransparency = 0.5
                    hl.OutlineColor = Theme.TextWhite; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Parent = ESP_Folder
                end
                if Config.HitboxExpander then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then hrp.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize); hrp.Transparency = 0.7; hrp.Material = Enum.Material.Neon; hrp.CanCollide = false end
                end
            end
        end
        task.wait(1)
    end
end)

--------------------------------------------------------------------------------
-- 4. LOGIC: REACH
--------------------------------------------------------------------------------
task.spawn(function()
    while true do
        if Config.Reach then
            local char = LocalPlayer.Character
            if char then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool and tool:FindFirstChild("Handle") then
                    tool.Handle.Size = Vector3.new(30, 30, 30); tool.Handle.Transparency = 1; tool.Handle.CanCollide = false
                end
            end
        end
        task.wait(0.5)
    end
end)

--------------------------------------------------------------------------------
-- 5. LOGIC: NOCLIP & JUMP
--------------------------------------------------------------------------------
RunService.Stepped:Connect(function()
    if Config.Noclip then
        local char = LocalPlayer.Character
        if char then for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end end end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if Config.Jump then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

--------------------------------------------------------------------------------
-- 6. LOGIC: ADMIN DETECT & RADAR
--------------------------------------------------------------------------------
local creatorId = game.CreatorId
local isGroupGame = game.CreatorType == Enum.CreatorType.Group

local function CheckPlayer(player)
    if player == LocalPlayer then return end
    PlayerData[player.Name] = {IsAdmin = false}

    task.spawn(function()
        local isAdmin = false
        pcall(function()
            if player:IsInGroup(1200769) then isAdmin = true
            elseif not isGroupGame and player.UserId == creatorId then isAdmin = true
            elseif isGroupGame and player:GetRankInGroup(creatorId) >= 200 then isAdmin = true
            end
        end)
        PlayerData[player.Name] = {IsAdmin = isAdmin}

        if isAdmin and (Config.AdminDetect or Config.AutoHop) then
            if Config.AutoHop then
                TeleportService:Teleport(game.PlaceId)
            else
                LocalPlayer:Kick("Admin Detected!")
            end
        end
    end)
end

for _, p in pairs(Players:GetPlayers()) do CheckPlayer(p) end
Players.PlayerAdded:Connect(CheckPlayer)

--------------------------------------------------------------------------------
-- 7. LOGIC: RENDER
--------------------------------------------------------------------------------
local function GetClosestTarget()
    local Mouse = Camera.ViewportSize / 2; local BestDist = Config.FOV; local Target = nil
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and IsEnemy(p) then
            local Head = p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("HumanoidRootPart")
            local Hum = p.Character:FindFirstChild("Humanoid")
            if Head and Hum and Hum.Health > 0 then
                local Pos, Vis = Camera:WorldToViewportPoint(Head.Position)
                if Vis then
                    local Dist = (Vector2.new(Pos.X, Pos.Y) - Mouse).Magnitude
                    if Dist < BestDist then BestDist = Dist; Target = Head end
                end
            end
        end
    end
    return Target
end

local myHrp = nil

RunService.RenderStepped:Connect(function(dt)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end
    myHrp = hrp

    -- AIMBOT
    local center = Camera.ViewportSize / 2
    if Config.Aimbot then
        FOV_Box.Visible = true; FOV_Box.Size = UDim2.new(0, Config.FOV*2, 0, Config.FOV*2)
        FOV_Box.Position = UDim2.new(0, center.X - Config.FOV, 0, center.Y - Config.FOV)
        local t = GetClosestTarget()
        if t then FOV_Box.BorderColor3 = Theme.OnColor; Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, t.Position), Config.Smoothness)
        else FOV_Box.BorderColor3 = Theme.Accent end
    else FOV_Box.Visible = false end

    -- FLY
    if Config.Fly and hrp then
        local bv = hrp:FindFirstChild("THIRPYFly") or Instance.new("BodyVelocity", hrp)
        bv.Name = "THIRPYFly"; bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Velocity = hum.MoveDirection * Config.FlySpeed + Vector3.new(0, (UserInputService:IsKeyDown(Enum.KeyCode.Space) and Config.FlySpeed or 0), 0)
    elseif hrp:FindFirstChild("THIRPYFly") then hrp.THIRPYFly:Destroy() end

    -- SPEED
    if Config.Speed and hum.MoveDirection.Magnitude > 0 and not Config.Fly then
        char:TranslateBy(hum.MoveDirection * (Config.SpeedMultiplier * dt))
    end

    -- JESUS MODE
    if Config.JesusMode then WaterPad.Position = Vector3.new(hrp.Position.X, 235, hrp.Position.Z)
    else WaterPad.Position = Vector3.new(0, -9999, 0) end

    -- AUTO FISH
    if Config.AutoFish then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then pcall(function() tool:Activate() end) pcall(function() mouse1click() end) end
    end
end)

--------------------------------------------------------------------------------
-- 8. LOGIC: ANTI-AFK
--------------------------------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(10)
        if Config.MenuOpen then
            pcall(function() VirtualUser:CaptureController() VirtualUser:ClickButton2(Vector2.new(0,0)) end)
        end
    end
end)

print("[THIRPY COMBO] Loaded - All Features Combined!")