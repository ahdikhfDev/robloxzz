--[[
    ENIGMA HUB v12.3 (PREMIUM UI EDITION) - FIXED
    - CORE & EXPLOITS: Aimbot, ESP, Fly, Noclip, Speed, Jump
    - UI UPGRADE: Smooth Drag, Tween Animations, Auto-Layout, Modern Aesthetics
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

--------------------------------------------------------------------------------
-- 1. CONFIGURATION & THEME
--------------------------------------------------------------------------------
local Config = {
    MenuOpen = true, TeamCheck = true,
    Aimbot = false, AimKey = Enum.KeyCode.E, Smoothness = 0.5, FOV = 250,
    ESP = false, Speed = false, SpeedMultiplier = 50,
    Jump = false, Noclip = false, Fly = false, FlySpeed = 60
}

local Theme = {
    MainBg = Color3.fromRGB(15, 15, 20),
    HeaderBg = Color3.fromRGB(25, 25, 30),
    ButtonBg = Color3.fromRGB(30, 30, 35),
    ButtonHover = Color3.fromRGB(45, 45, 55),
    Accent = Color3.fromRGB(130, 0, 255),
    TextWhite = Color3.fromRGB(240, 240, 240),
    TextSub = Color3.fromRGB(150, 150, 150),
    OnColor = Color3.fromRGB(0, 255, 128),
    OffColor = Color3.fromRGB(80, 80, 80)
}

local DefaultWS = 16
local BV, BG = nil, nil

--------------------------------------------------------------------------------
-- 2. PREMIUM UI ENGINE
--------------------------------------------------------------------------------
local function CreateGUI()
    local Screen = Instance.new("ScreenGui")
    Screen.Name = "ENIGMA_SUITE"
    Screen.ResetOnSpawn = false
    Screen.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 320, 0, 480)
    MainFrame.Position = UDim2.new(0.5, -160, 0.3, 0)
    MainFrame.BackgroundColor3 = Theme.MainBg
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = Screen

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Theme.Accent
    MainStroke.Thickness = 2
    MainStroke.Parent = MainFrame

    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 50)
    Header.BackgroundColor3 = Theme.HeaderBg
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame

    local HeaderTitle = Instance.new("TextLabel")
    HeaderTitle.Size = UDim2.new(1, -60, 1, 0)
    HeaderTitle.Position = UDim2.new(0, 20, 0, 0)
    HeaderTitle.BackgroundTransparency = 1
    HeaderTitle.Text = "ENIGMA SUITE"
    HeaderTitle.Font = Enum.Font.GothamBold
    HeaderTitle.TextSize = 18
    HeaderTitle.TextColor3 = Theme.TextWhite
    HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
    HeaderTitle.Parent = Header

    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 50, 1, 0)
    MinBtn.Position = UDim2.new(1, -50, 0, 0)
    MinBtn.BackgroundTransparency = 1
    MinBtn.Text = "—"
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 14
    MinBtn.TextColor3 = Theme.TextSub
    MinBtn.Parent = Header

    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, 0, 1, -50)
    Content.Position = UDim2.new(0, 0, 0, 50)
    Content.BackgroundTransparency = 1
    Content.Parent = MainFrame

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Padding = UDim.new(0, 10)
    ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ListLayout.Parent = Content

    local Padding = Instance.new("UIPadding")
    Padding.PaddingTop = UDim.new(0, 15)
    Padding.PaddingBottom = UDim.new(0, 15)
    Padding.Parent = Content

    local dragging, dragInput, dragStart, startPos
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local function CreateToggle(text, flag, callback)
        local BtnContainer = Instance.new("Frame")
        BtnContainer.Size = UDim2.new(0.9, 0, 0, 45)
        BtnContainer.BackgroundColor3 = Theme.ButtonBg
        BtnContainer.Parent = Content

        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 8)
        BtnCorner.Parent = BtnContainer

        local BtnStroke = Instance.new("UIStroke")
        BtnStroke.Color = Theme.OffColor
        BtnStroke.Thickness = 1
        BtnStroke.Parent = BtnContainer

        local BtnText = Instance.new("TextLabel")
        BtnText.Size = UDim2.new(1, -60, 1, 0)
        BtnText.Position = UDim2.new(0, 15, 0, 0)
        BtnText.BackgroundTransparency = 1
        BtnText.Text = text
        BtnText.Font = Enum.Font.GothamMedium
        BtnText.TextSize = 14
        BtnText.TextColor3 = Theme.TextWhite
        BtnText.TextXAlignment = Enum.TextXAlignment.Left
        BtnText.Parent = BtnContainer

        local StatusIndicator = Instance.new("Frame")
        StatusIndicator.Size = UDim2.new(0, 12, 0, 12)
        StatusIndicator.Position = UDim2.new(1, -25, 0.5, -6)
        StatusIndicator.BackgroundColor3 = Theme.OffColor
        StatusIndicator.Parent = BtnContainer

        local IndCorner = Instance.new("UICorner")
        IndCorner.CornerRadius = UDim.new(1, 0)
        IndCorner.Parent = StatusIndicator

        local ClickArea = Instance.new("TextButton")
        ClickArea.Size = UDim2.new(1, 0, 1, 0)
        ClickArea.BackgroundTransparency = 1
        ClickArea.Text = ""
        ClickArea.Parent = BtnContainer

        ClickArea.MouseEnter:Connect(function()
            BtnContainer.BackgroundColor3 = Theme.ButtonHover
        end)
        ClickArea.MouseLeave:Connect(function()
            BtnContainer.BackgroundColor3 = Theme.ButtonBg
        end)

        ClickArea.Activated:Connect(function()
            Config[flag] = not Config[flag]
            local state = Config[flag]

            BtnStroke.Color = state and Theme.OnColor or Theme.OffColor
            StatusIndicator.BackgroundColor3 = state and Theme.OnColor or Theme.OffColor

            if callback then callback(state) end
        end)
    end

    local function ToggleFly(state)
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        if state then
            BV = Instance.new("BodyVelocity")
            BV.Name = "EnigmaFlyBV"
            BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            BV.Velocity = Vector3.new(0, 0, 0)
            BV.Parent = hrp

            BG = Instance.new("BodyGyro")
            BG.Name = "EnigmaFlyBG"
            BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            BG.P = 9e4
            BG.CFrame = Camera.CFrame
            BG.Parent = hrp
        else
            if BV then BV:Destroy() end
            if BG then BG:Destroy() end
            BV, BG = nil, nil
        end
    end

    CreateToggle("Aimbot (Hold E)", "Aimbot")
    CreateToggle("Enemy ESP", "ESP")
    CreateToggle("Speed Hack", "Speed")
    CreateToggle("Infinite Jump", "Jump")
    CreateToggle("Fly Hack (WASD)", "Fly", ToggleFly)
    CreateToggle("Noclip (Ghost)", "Noclip")

    MinBtn.Activated:Connect(function()
        Config.MenuOpen = not Config.MenuOpen
        if Config.MenuOpen then
            MainFrame.Size = UDim2.new(0, 320, 0, 480)
        else
            MainFrame.Size = UDim2.new(0, 320, 0, 50)
        end
    end)

    UserInputService.InputBegan:Connect(function(input, gameprocessed)
        if not gameprocessed and input.KeyCode == Enum.KeyCode.Insert then MainFrame.Visible = not MainFrame.Visible end
    end)
end

CreateGUI()

--------------------------------------------------------------------------------
-- 3. CORE LOGIC (ESP, NOCLIP, JUMP)
--------------------------------------------------------------------------------
local ESP_Folder = Instance.new("Folder")
ESP_Folder.Name = "ENIGMA_ESP"
ESP_Folder.Parent = Workspace

local FOV_Box = Instance.new("Frame")
FOV_Box.BackgroundTransparency = 1
FOV_Box.BorderColor3 = Theme.Accent
FOV_Box.BorderSizePixel = 2
FOV_Box.Visible = false
FOV_Box.ZIndex = 100
FOV_Box.Parent = LocalPlayer:WaitForChild("PlayerGui")

local function IsEnemy(p)
    if not Config.TeamCheck then return true end
    if p.Team == nil or p.Team ~= LocalPlayer.Team then return true end
    return false
end

local LastESP = 0
RunService.Heartbeat:Connect(function()
    if Config.ESP and os.clock() - LastESP > 1.5 then
        ESP_Folder:ClearAllChildren()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and IsEnemy(p) then
                local hl = Instance.new("Highlight")
                hl.Adornee = p.Character
                hl.FillColor = Theme.Accent
                hl.FillTransparency = 0.5
                hl.OutlineColor = Theme.TextWhite
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = ESP_Folder
            end
        end
        LastESP = os.clock()
    end
end)

RunService.Stepped:Connect(function()
    if Config.Noclip then
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

UserInputService.JumpRequest:Connect(function()
    if Config.Jump then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

--------------------------------------------------------------------------------
-- 4. MASTER LOOP (AIMBOT, FLY, SPEED)
--------------------------------------------------------------------------------
local function IsVisible(targetPart)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local result = Workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 1000, params)
    return result and result.Instance and result.Instance:IsDescendantOf(targetPart.Parent)
end

local function GetClosestTarget()
    local Mouse = UserInputService:GetMouseLocation()
    local BestDist = Config.FOV
    local Target = nil

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and IsEnemy(p) then
            local Head = p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("HumanoidRootPart")
            local Hum = p.Character:FindFirstChild("Humanoid")
            if Head and Hum and Hum.Health > 0 then
                local Pos, Vis = Camera:WorldToViewportPoint(Head.Position)
                if Vis then
                    local Dist = (Vector2.new(Pos.X, Pos.Y) - Mouse).Magnitude
                    if Dist < BestDist and IsVisible(Head) then
                        BestDist = Dist
                        Target = Head
                    end
                end
            end
        end
    end
    return Target
end

RunService.RenderStepped:Connect(function(deltaTime)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")

    if Config.Aimbot then
        local m = UserInputService:GetMouseLocation()
        FOV_Box.Visible = true
        FOV_Box.Size = UDim2.new(0, Config.FOV * 2, 0, Config.FOV * 2)
        FOV_Box.Position = UDim2.new(0, m.X - Config.FOV, 0, m.Y - Config.FOV)

        if UserInputService:IsKeyDown(Config.AimKey) then
            local t = GetClosestTarget()
            if t then
                FOV_Box.BorderColor3 = Theme.OnColor
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, t.Position), Config.Smoothness)
            else
                FOV_Box.BorderColor3 = Theme.Accent
            end
        end
    else
        FOV_Box.Visible = false
    end

    if Config.Fly and hrp then
        if BV and BG then
            BG.CFrame = Camera.CFrame
            local moveDir = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
            BV.Velocity = moveDir * Config.FlySpeed
        end
    end

    if Config.Speed and hum and not Config.Fly then
        hum.WalkSpeed = DefaultWS * 2
    elseif hum and not Config.Speed and hum.WalkSpeed ~= DefaultWS then
        hum.WalkSpeed = DefaultWS
    end
end)

print("ENIGMA SUITE v12.3 Loaded!")