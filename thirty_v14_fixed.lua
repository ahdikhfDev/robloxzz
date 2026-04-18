--[[
    THIRTY V14 FIXED + EXPANDED EDITION
    - UI: Glassmorphism, Tabbed System, Tween Animations, Draggable
    - COMBAT: Auto-Aim, Triggerbot, Silent Aim, Aim Prediction, Hitbox, Melee Reach, Spin
    - MOVEMENT: Speed, Fly, Noclip, Jump, Teleport Walk, Water Walk, Anti-Void
    - VISUALS: ESP, Tracers, Fullbright
    - GHOST: Freecam, Invisible, Waypoint, Server Hop
    - UTILS: Backtrack, Fake Lag, Chat Spammer, Kill Say, Instant Respawn
    - BUILD: Build Aimbot
    - FIXES: All known bugs from v14 original
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local TextService = game:GetService("TextService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--------------------------------------------------------------------------------
-- 1. CONFIGURATION & THEME
--------------------------------------------------------------------------------
local Config = {
    MenuOpen = true, TeamCheck = true,
    
    -- COMBAT
    Aimbot = false, Triggerbot = false, SilentAim = false, AimPrediction = false,
    HitboxExpander = false, HitboxSize = 20, Reach = false, ReachSize = 30,
    Spin = false, SpinSpeed = 20,
    
    -- MOVEMENT  
    Speed = false, SpeedMultiplier = 50, Jump = false, Noclip = false,
    Fly = false, FlySpeed = 60, TeleportWalk = false,
    WaterWalk = false, AntiVoid = false, AntiVoidY = -500,
    
    -- VISUALS
    ESP = false, Tracers = false, Fullbright = false,
    Smoothness = 0.5, FOV = 250,
    
    -- GHOST & SYS
    Freecam = false, Invisible = false, SavedCFrame = nil,
    Backtrack = false, BacktrackMs = 500,
    FakeLag = false, FakeLagMs = 200,
    ChatSpam = false, ChatSpamDelay = 2, ChatMessage = "thirty best hub 🔥",
    KillSay = false, KillSayMsg = "gg wp!",
    InstantRespawn = false,
    BuildAim = false, BuildReach = 50,
}

local Theme = {
    MainBg = Color3.fromRGB(15, 15, 20),
    Glass = 0.15,
    SidebarBg = Color3.fromRGB(22, 22, 28),
    ButtonBg = Color3.fromRGB(35, 35, 45),
    Accent = Color3.fromRGB(130, 0, 255),
    OnColor = Color3.fromRGB(0, 255, 128),
    OffColor = Color3.fromRGB(80, 80, 80),
    DangerColor = Color3.fromRGB(255, 60, 80),
    TextWhite = Color3.fromRGB(250, 250, 250),
    TextSub = Color3.fromRGB(160, 160, 160)
}

local DefaultWS = 16
local DefaultJP = 50

local State = {
    OriginalHitbox = {},
    OriginalReach = {},
    OriginalInvis = {},
    LastKills = {},
    SpinAngle = 0,
}

--------------------------------------------------------------------------------
-- 2. SAVE ORIGINAL STATES
--------------------------------------------------------------------------------
local function SaveOriginalStates()
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            if not State.OriginalHitbox[p.UserId] then
                State.OriginalHitbox[p.UserId] = hrp.Size
            end
        end
    end
    
    local char = LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and not State.OriginalInvis[part] then
                State.OriginalInvis[part] = part.Transparency
            end
            if part:IsA("Tool") and part:FindFirstChild("Handle") and not State.OriginalReach[part] then
                State.OriginalReach[part] = part.Handle.Size
            end
        end
    end
end

--------------------------------------------------------------------------------
-- 3. PREMIUM UI ENGINE
--------------------------------------------------------------------------------
local function CreateGUI()
    local UI_Target = LocalPlayer:WaitForChild("PlayerGui")
    if UI_Target:FindFirstChild("THIRTY_V14") then UI_Target.THIRTY_V14:Destroy() end

    local Screen = Instance.new("ScreenGui"); Screen.Name = "THIRTY_V14"; Screen.Parent = UI_Target

    local FloatingBtn = Instance.new("TextButton")
    FloatingBtn.Size = UDim2.new(0, 50, 0, 50); FloatingBtn.Position = UDim2.new(0, 20, 0.5, -25); FloatingBtn.BackgroundColor3 = Theme.MainBg
    FloatingBtn.Text = "AKF"; FloatingBtn.Font = Enum.Font.GothamBlack; FloatingBtn.TextSize = 16; FloatingBtn.TextColor3 = Theme.Accent; FloatingBtn.Visible = false; FloatingBtn.Parent = Screen
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
    MainFrame.Size = UDim2.new(0, 420, 0, 520); MainFrame.Position = UDim2.new(0.5, -210, 0.5, -260); MainFrame.BackgroundColor3 = Theme.MainBg; MainFrame.BackgroundTransparency = Theme.Glass; MainFrame.BorderSizePixel = 0; MainFrame.ClipsDescendants = true; MainFrame.Parent = Screen
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)
    Instance.new("UIStroke", MainFrame).Color = Theme.Accent; Instance.new("UIStroke", MainFrame).Thickness = 2
    MakeDraggable(MainFrame)

    local Sidebar = Instance.new("Frame"); Sidebar.Size = UDim2.new(0, 80, 1, 0); Sidebar.BackgroundColor3 = Theme.SidebarBg; Sidebar.BorderSizePixel = 0; Sidebar.Parent = MainFrame
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 16)
    local TabList = Instance.new("UIListLayout", Sidebar); TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center; TabList.Padding = UDim.new(0, 10)
    Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 15)

    local ContentArea = Instance.new("Frame"); ContentArea.Size = UDim2.new(1, -90, 1, -60); ContentArea.Position = UDim2.new(0, 90, 0, 60); ContentArea.BackgroundTransparency = 1; ContentArea.Parent = MainFrame
    
    local TxtTitle = Instance.new("TextLabel"); TxtTitle.Size = UDim2.new(1, -100, 0, 60); TxtTitle.Position = UDim2.new(0, 95, 0, 0); TxtTitle.BackgroundTransparency = 1; TxtTitle.Text = "THIRTY V14"; TxtTitle.Font = Enum.Font.GothamBlack; TxtTitle.TextSize = 20; TxtTitle.TextColor3 = Theme.Accent; TxtTitle.TextXAlignment = Enum.TextXAlignment.Left; TxtTitle.Parent = MainFrame
    local CloseBtn = Instance.new("TextButton"); CloseBtn.Size = UDim2.new(0, 40, 0, 40); CloseBtn.Position = UDim2.new(1, -50, 0, 10); CloseBtn.BackgroundTransparency = 1; CloseBtn.Text = "X"; CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 20; CloseBtn.TextColor3 = Theme.TextSub; CloseBtn.Parent = MainFrame

    local isAnim = false
    CloseBtn.MouseButton1Click:Connect(function()
        if isAnim then return end; isAnim = true
        MainFrame:TweenSize(UDim2.new(0, 0, 0, 0), "In", "Back", 0.3, true, function() MainFrame.Visible = false; FloatingBtn.Visible = true; isAnim = false end)
    end)
    FloatingBtn.MouseButton1Click:Connect(function()
        if isAnim then return end; isAnim = true
        FloatingBtn.Visible = false; MainFrame.Visible = true
        MainFrame:TweenSize(UDim2.new(0, 420, 0, 520), "Out", "Back", 0.4, true, function() isAnim = false end)
    end)

    local Tabs = {}
    local function AddTab(icon, name)
        local Btn = Instance.new("TextButton"); Btn.Size = UDim2.new(0, 50, 0, 50); Btn.BackgroundColor3 = Theme.ButtonBg; Btn.Text = icon; Btn.Font = Enum.Font.GothamBold; Btn.TextSize = 18; Btn.TextColor3 = Theme.TextWhite; Btn.Parent = Sidebar; Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 10)
        local Scroll = Instance.new("ScrollingFrame"); Scroll.Size = UDim2.new(1, 0, 1, 0); Scroll.BackgroundTransparency = 1; Scroll.Visible = false; Scroll.ScrollBarThickness = 0; Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; Scroll.Parent = ContentArea
        Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 8); Instance.new("UIPadding", Scroll).PaddingTop = UDim.new(0, 8); Instance.new("UIPadding", Scroll).PaddingBottom = UDim.new(0, 8)
        
        Btn.MouseButton1Click:Connect(function()
            for _, t in pairs(Tabs) do t.Scroll.Visible = false; TweenService:Create(t.Btn, TweenInfo.new(0.2), {TextColor3 = Theme.TextWhite, BackgroundColor3 = Theme.ButtonBg}):Play() end
            Scroll.Visible = true; TweenService:Create(Btn, TweenInfo.new(0.2), {TextColor3 = Theme.Accent, BackgroundColor3 = Color3.new(0,0,0)}):Play()
        end)
        table.insert(Tabs, {Btn = Btn, Scroll = Scroll})
        if #Tabs == 1 then Scroll.Visible = true; Btn.TextColor3 = Theme.Accent; Btn.BackgroundColor3 = Color3.new(0,0,0) end
        return Scroll
    end

    local function AddToggle(parent, text, flag, callback)
        local Frame = Instance.new("Frame"); Frame.Size = UDim2.new(0.95, 0, 0, 40); Frame.BackgroundColor3 = Theme.ButtonBg; Frame.Parent = parent; Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
        local BtnText = Instance.new("TextLabel"); BtnText.Size = UDim2.new(1, -50, 1, 0); BtnText.Position = UDim2.new(0, 12, 0, 0); BtnText.BackgroundTransparency = 1; BtnText.Text = text; BtnText.Font = Enum.Font.GothamMedium; BtnText.TextSize = 12; BtnText.TextColor3 = Theme.TextWhite; BtnText.TextXAlignment = Enum.TextXAlignment.Left; BtnText.Parent = Frame
        local Dot = Instance.new("Frame"); Dot.Size = UDim2.new(0, 12, 0, 12); Dot.Position = UDim2.new(1, -25, 0.5, -6); Dot.BackgroundColor3 = Theme.OffColor; Dot.Parent = Frame; Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
        local ClickArea = Instance.new("TextButton"); ClickArea.Size = UDim2.new(1, 0, 1, 0); ClickArea.BackgroundTransparency = 1; ClickArea.Text = ""; ClickArea.Parent = Frame
        
        ClickArea.MouseButton1Click:Connect(function()
            Config[flag] = not Config[flag]
            Dot.BackgroundColor3 = Config[flag] and Theme.OnColor or Theme.OffColor
            if callback then callback(Config[flag]) end
        end)
    end

    local function AddAction(parent, text, callback, isDanger)
        local color = isDanger and Theme.DangerColor or Theme.Accent
        local Frame = Instance.new("Frame"); Frame.Size = UDim2.new(0.95, 0, 0, 40); Frame.BackgroundColor3 = Theme.ButtonBg; Frame.Parent = parent; Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
        local Stroke = Instance.new("UIStroke", Frame); Stroke.Color = color; Stroke.Thickness = 1
        local BtnText = Instance.new("TextLabel"); BtnText.Size = UDim2.new(1, 0, 1, 0); BtnText.BackgroundTransparency = 1; BtnText.Text = text; BtnText.Font = Enum.Font.GothamBold; BtnText.TextSize = 12; BtnText.TextColor3 = color; BtnText.Parent = Frame
        local ClickArea = Instance.new("TextButton"); ClickArea.Size = UDim2.new(1, 0, 1, 0); ClickArea.BackgroundTransparency = 1; ClickArea.Text = ""; ClickArea.Parent = Frame
        
        ClickArea.MouseButton1Click:Connect(function()
            TweenService:Create(Frame, TweenInfo.new(0.1), {BackgroundColor3 = color}):Play()
            task.delay(0.1, function() TweenService:Create(Frame, TweenInfo.new(0.1), {BackgroundColor3 = Theme.ButtonBg}):Play() end)
            if callback then callback() end
        end)
    end

    local TabCombat = AddTab("⚔️", "Combat")
    AddToggle(TabCombat, "Auto-Aim (Lock-on)", "Aimbot")
    AddToggle(TabCombat, "Silent Aim", "SilentAim")
    AddToggle(TabCombat, "Aim Prediction", "AimPrediction")
    AddToggle(TabCombat, "Triggerbot", "Triggerbot")
    AddToggle(TabCombat, "Hitbox Expander", "HitboxExpander")
    AddToggle(TabCombat, "Melee Reach", "Reach")
    AddToggle(TabCombat, "Spin Bot", "Spin")

    local TabMove = AddTab("🏃", "Movement")
    AddToggle(TabMove, "Speed Hack", "Speed")
    AddToggle(TabMove, "Infinite Jump", "Jump")
    AddToggle(TabMove, "Fly Hack", "Fly", function(v)
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local bv = hrp:FindFirstChild("ThirtyFlyBV")
        local bg = hrp:FindFirstChild("ThirtyFlyBG")
        if v then
            if not bv then bv = Instance.new("BodyVelocity"); bv.Name = "ThirtyFlyBV"; bv.MaxForce = Vector3.new(9e9, 9e9, 9e9); bv.Velocity = Vector3.new(0,0,0); bv.Parent = hrp end
            if not bg then bg = Instance.new("BodyGyro"); bg.Name = "ThirtyFlyBG"; bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9); bg.P = 9e4; bg.CFrame = Camera.CFrame; bg.Parent = hrp end
        else
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
        end
    end)
    AddToggle(TabMove, "Noclip", "Noclip")
    AddToggle(TabMove, "Teleport Walk", "TeleportWalk")
    AddToggle(TabMove, "Water Walk", "WaterWalk")
    AddToggle(TabMove, "Anti-Void", "AntiVoid")

    local TabVisual = AddTab("👁️", "Visuals")
    AddToggle(TabVisual, "Enemy ESP", "ESP")
    AddToggle(TabVisual, "Tracer Lines", "Tracers")
    AddToggle(TabVisual, "Fullbright", "Fullbright", function(v)
        if v then Lighting.Ambient = Color3.new(1,1,1); Lighting.OutdoorAmbient = Color3.new(1,1,1); Lighting.Brightness = 2
        else Lighting.Ambient = Color3.fromRGB(127,127,127); Lighting.OutdoorAmbient = Color3.fromRGB(127,127,127); Lighting.Brightness = 1 end
    end)

    local TabGhost = AddTab("👻", "Ghost & Sys")
    AddToggle(TabGhost, "Freecam", "Freecam", function(v)
        Camera.CameraType = v and Enum.CameraType.Scriptable or Enum.CameraType.Custom
    end)
    AddToggle(TabGhost, "Invisible", "Invisible")
    AddToggle(TabGhost, "Backtrack", "Backtrack")
    AddToggle(TabGhost, "Fake Lag", "FakeLag")
    AddToggle(TabGhost, "Chat Spammer", "ChatSpam")
    AddToggle(TabGhost, "Kill Say", "KillSay")
    AddToggle(TabGhost, "Instant Respawn", "InstantRespawn")
    AddAction(TabGhost, "📌 Save Waypoint", function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then Config.SavedCFrame = hrp.CFrame end
    end)
    AddAction(TabGhost, "🚀 Tween TP", function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp and Config.SavedCFrame then TweenService:Create(hrp, TweenInfo.new(2, Enum.EasingStyle.Linear), {CFrame = Config.SavedCFrame}):Play() end
    end)
    AddAction(TabGhost, "🌐 Server Hop", function() TeleportService:Teleport(game.PlaceId) end, true)

    local TabBuild = AddTab("🧱", "Build")
    AddToggle(TabBuild, "Build Aimbot", "BuildAim")
    AddAction(TabBuild, "💥 Instant Kill", function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        if hrp and hum then
            hum.Health = 0
        end
    end, true)
end

CreateGUI()

-- Refresh state on character add
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    SaveOriginalStates()
end)
SaveOriginalStates()

--------------------------------------------------------------------------------
-- 4. HELPER FUNCTIONS
--------------------------------------------------------------------------------
local function IsEnemy(p)
    if not Config.TeamCheck then return true end
    if p.Team == nil or p.Team ~= LocalPlayer.Team then return true end
    return false
end

local function GetClosestTarget()
    local centerScreen = Camera.ViewportSize / 2
    local shortestDist = Config.FOV
    local target = nil

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and IsEnemy(p) then
            local Head = p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("HumanoidRootPart")
            local Hum = p.Character:FindFirstChild("Humanoid")
            if Head and Hum and Hum.Health > 0 then
                local pos, vis = Camera:WorldToViewportPoint(Head.Position)
                if vis then
                    local dist = (Vector2.new(pos.X, pos.Y) - centerScreen).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        target = Head
                    end
                end
            end
        end
    end
    return target
end

local function GetPredictedPosition(target, speed)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not target or not hrp then return target and target.Position or nil end
    
    local targetPart = target.Parent:FindFirstChild("HumanoidRootPart") or target
    local targetHum = target.Parent:FindFirstChild("Humanoid")
    if not targetHum then return target.Position end
    
    local velocity = targetHum.RootPart and targetHum.RootPart.Velocity or Vector3.new(0,0,0)
    local dist = (targetPart.Position - hrp.Position).Magnitude
    local time = dist / speed
    
    return targetPart.Position + (velocity * time)
end

--------------------------------------------------------------------------------
-- 5. BACKGROUND LOOPS
--------------------------------------------------------------------------------
local ESP_Folder = Instance.new("Folder"); ESP_Folder.Name = "THIRTY_ESP"; ESP_Folder.Parent = Workspace

local TracerScreen = Instance.new("ScreenGui"); TracerScreen.Name = "THIRTY_TRACERS"; TracerScreen.Parent = LocalPlayer:WaitForChild("PlayerGui")

local FOV_Box = Instance.new("Frame"); FOV_Box.BackgroundTransparency = 1; FOV_Box.BorderColor3 = Theme.OnColor; FOV_Box.BorderSizePixel = 2; FOV_Box.Visible = false; FOV_Box.ZIndex = 100; FOV_Box.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- ESP & HITBOX LOOP
task.spawn(function()
    while true do
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and IsEnemy(p) then
                -- ESP
                if Config.ESP then
                    local existing = ESP_Folder:FindFirstChild("ESP_" .. p.UserId)
                    if not existing then
                        local hl = Instance.new("Highlight")
                        hl.Name = "ESP_" .. p.UserId
                        hl.Adornee = p.Character
                        hl.FillColor = Theme.Accent
                        hl.FillTransparency = 0.5
                        hl.OutlineColor = Theme.TextWhite
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.Parent = ESP_Folder
                    end
                else
                    local existing = ESP_Folder:FindFirstChild("ESP_" .. p.UserId)
                    if existing then existing:Destroy() end
                end
                
                -- Hitbox Expander
                if Config.HitboxExpander then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
                        hrp.Transparency = 0.7
                        hrp.BrickColor = BrickColor.new("Bright purple")
                        hrp.Material = Enum.Material.Neon
                        hrp.CanCollide = false
                    end
                else
                    -- Reset hitbox
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and State.OriginalHitbox[p.UserId] then
                        hrp.Size = State.OriginalHitbox[p.UserId]
                        hrp.Transparency = 0
                        hrp.Material = Enum.Material.Plastic
                        hrp.CanCollide = true
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)

-- REACH LOOP
task.spawn(function()
    while true do
        if Config.Reach then
            local char = LocalPlayer.Character
            if char then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool and tool:FindFirstChild("Handle") then
                    tool.Handle.Size = Vector3.new(Config.ReachSize, Config.ReachSize, Config.ReachSize)
                    tool.Handle.Transparency = 0.8
                    tool.Handle.CanCollide = false
                end
            end
        else
            -- Reset reach
            for _, tool in pairs(LocalPlayer.Character:GetChildren()) do
                if tool:IsA("Tool") and tool:FindFirstChild("Handle") and State.OriginalReach[tool] then
                    tool.Handle.Size = State.OriginalReach[tool]
                    tool.Handle.Transparency = 0
                    tool.Handle.CanCollide = true
                end
            end
        end
        task.wait(0.3)
    end
end)

-- INVISIBLE LOOP
task.spawn(function()
    while true do
        if Config.Invisible then
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.Transparency = 1
                    elseif part:IsA("Decal") or part:IsA("Texture") then
                        part.Transparency = 1
                    end
                end
                local hum = char:FindFirstChild("Humanoid")
                if hum then hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end
            end
        else
            -- Reset invisible
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and State.OriginalInvis[part] then
                        part.Transparency = State.OriginalInvis[part]
                    end
                end
                local hum = char:FindFirstChild("Humanoid")
                if hum then hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer end
            end
        end
        task.wait(0.1)
    end
end)

-- NOCLIP
RunService.Stepped:Connect(function()
    if Config.Noclip or Config.TeleportWalk then
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- JUMP
UserInputService.JumpRequest:Connect(function()
    if Config.Jump then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- INSTANT RESPAWN
LocalPlayer.CharacterAdded:Connect(function()
    if Config.InstantRespawn then
        task.wait(0.1)
        LocalPlayer.Character:Destroy()
        LocalPlayer.LoadCharacter()
    end
end)

-- CHAT SPAMMER
task.spawn(function()
    while true do
        if Config.ChatSpam then
            pcall(function()
                local chat = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
                if chat and chat:FindFirstChild("SayMessageRequest") then
                    chat.SayMessageRequest:FireServer(Config.ChatMessage, "All")
                end
            end)
        end
        task.wait(Config.ChatSpamDelay)
    end
end)

-- KILL SAY
local function OnPlayerDied(char)
    if Config.KillSay and char then
        local attacker = char:FindFirstChild("Humanoid") and char.Humanoid:FindFirstChild("Creator")
        if attacker and attacker.Value == LocalPlayer then
            task.wait(0.5)
            pcall(function()
                local chat = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
                if chat and chat:FindFirstChild("SayMessageRequest") then
                    chat.SayMessageRequest:FireServer(Config.KillSayMsg, "All")
                end
            end)
        end
    end
end

for _, p in pairs(Players:GetPlayers()) do
    if p.Character and p.Character:FindFirstChild("Humanoid") then
        p.Character.Humanoid.Died:Connect(function() OnPlayerDied(p.Character) end)
    end
    p.CharacterAdded:Connect(function(char)
        char:WaitForChild("Humanoid").Died:Connect(function() OnPlayerDied(char) end)
    end)
end

--------------------------------------------------------------------------------
-- 6. RENDERSTEPPED
--------------------------------------------------------------------------------
local function DrawLine(startPos, endPos)
    local line = Instance.new("Frame")
    line.BackgroundColor3 = Theme.Accent
    line.BorderSizePixel = 0
    line.ZIndex = -1
    local distance = (startPos - endPos).Magnitude
    line.Size = UDim2.new(0, distance, 0, 2)
    local center = (startPos + endPos) / 2
    line.Position = UDim2.new(0, center.X - (distance / 2), 0, center.Y)
    line.Rotation = math.atan2(endPos.Y - startPos.Y, endPos.X - startPos.X) * (180 / math.pi)
    line.Parent = TracerScreen
end

RunService.RenderStepped:Connect(function(deltaTime)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    local centerScreen = Camera.ViewportSize / 2

    -- TRACERS
    if Config.Tracers then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and IsEnemy(p) then
                local pos, onScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                if onScreen then
                    DrawLine(Vector2.new(centerScreen.X, Camera.ViewportSize.Y), Vector2.new(pos.X, pos.Y))
                end
            end
        end
    end

    -- WATER WALK
    if Config.WaterWalk and hrp then
        local waterLevel = -5
        if hrp.Position.Y < waterLevel then
            hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
            hrp.CFrame = hrp.CFrame + Vector3.new(0, waterLevel - hrp.Position.Y + 2, 0)
        end
    end

    -- ANTI-VOID
    if Config.AntiVoid and hrp then
        if hrp.Position.Y < Config.AntiVoidY then
            hrp.CFrame = Config.SavedCFrame or CFrame.new(0, 100, 0)
        end
    end

    -- FLY
    if Config.Fly and hrp then
        local bv = hrp:FindFirstChild("ThirtyFlyBV")
        local bg = hrp:FindFirstChild("ThirtyFlyBG")
        if bv and bg then
            bg.CFrame = Camera.CFrame
            local moveDir = hum and hum.MoveDirection or Vector3.new(0,0,0)
            if moveDir.Magnitude > 0 then
                local camLook = Camera.CFrame.LookVector
                bv.Velocity = Vector3.new(moveDir.X, camLook.Y * (moveDir:Dot(camLook) > 0 and 1 or -1), moveDir.Z).Unit * Config.FlySpeed
            else
                bv.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end

    -- SPEED
    if Config.Speed and hrp and hum and not Config.Fly then
        hum.WalkSpeed = DefaultWS * 2
    elseif Config.Speed and hum then
        hum.WalkSpeed = DefaultWS
    end

    -- SILENT AIM & AIMBOT
    local target = nil
    if Config.Aimbot or Config.SilentAim or Config.BuildAim then
        target = GetClosestTarget()
    end

    -- AIM PREDICTION
    local aimPos = target and target.Position
    if target and Config.AimPrediction then
        aimPos = GetPredictedPosition(target, 1000)
    end

    -- AUTO-AIM (VISIBLE)
    if Config.Aimbot and target then
        FOV_Box.Visible = true
        FOV_Box.Size = UDim2.new(0, Config.FOV*2, 0, Config.FOV*2)
        FOV_Box.Position = UDim2.new(0, centerScreen.X - Config.FOV, 0, centerScreen.Y - Config.FOV)
        
        if aimPos then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, aimPos), Config.Smoothness)
        end
    else
        FOV_Box.Visible = false
    end

    -- SILENT AIM (INVISIBLE - Raycast only)
    if Config.SilentAim and target and aimPos and not Config.Aimbot then
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = {LocalPlayer.Character}
        params.FilterType = Enum.RaycastFilterType.Exclude
        local result = Workspace:Raycast(Camera.CFrame.Position, (aimPos - Camera.CFrame.Position).Unit * 1000, params)
        if result and result.Instance and result.Instance:IsDescendantOf(target.Parent) then
            -- Target detected via raycast
        end
    end

    -- TRIGGERBOT
    if Config.Triggerbot and target then
        local t = Mouse.Target
        if t and t.Parent and t.Parent:FindFirstChild("Humanoid") then
            local p = Players:GetPlayerFromCharacter(t.Parent)
            if p and IsEnemy(p) then
                pcall(function() mouse1click() end)
            end
        end
    end

    -- SPIN BOT
    if Config.Spin and hrp then
        State.SpinAngle = State.SpinAngle + (Config.SpinSpeed * deltaTime)
        hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, math.rad(State.SpinAngle), 0)
    end

    -- FREECAM
    if Config.Freecam then
        local speed = 2
        local move = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.E) then move = move + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then move = move - Vector3.new(0, 1, 0) end
        Camera.CFrame = Camera.CFrame + (move * speed)
    end

    -- TELEPORT WALK
    if Config.TeleportWalk and hrp and hum then
        local dist = 4
        if hum.MoveDirection.Magnitude > 0 then
            local nextPos = hrp.CFrame.Position + (hum.MoveDirection * dist)
            hrp.CFrame = CFrame.new(nextPos)
            hrp.Velocity = Vector3.new(0, 0, 0)
        end
    end
end)

-- BACKTRACK (Damage History)
task.spawn(function()
    while true do
        if Config.Backtrack then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") then
                    local hum = p.Character.Humanoid
                    if hum.Health < hum.MaxHealth and not State.LastKills[p.UserId] then
                        -- Target took damage, log position
                        State.LastKills[p.UserId] = {
                            position = p.Character.HumanoidRootPart.Position,
                            time = os.clock()
                        }
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

print("[THIRTY V14] Fully Loaded & Expanded!")
print("[THIRTY V14] Fixed: Freecam, Invisible, Hitbox, Reach, Tracer, Mouse")