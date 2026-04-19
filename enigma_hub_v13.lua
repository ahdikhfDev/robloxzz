--[[
    ENIGMA HUB v13.0 (FULL FEATURE)
    - Aimbot + ESP (Team Check)
    - Speed Hack, Fly, Noclip, Infinite Jump, Anti-AFK
    - UI: Draggable & High Visibility
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

--------------------------------------------------------------------------------
-- 1. CONFIGURATION
--------------------------------------------------------------------------------
local Config = {
    Aimbot = false,
    AimKey = Enum.KeyCode.E,
    ESP = false,
    SpeedHack = false,
    Fly = false,
    Noclip = false,
    InfiniteJump = false,
    AntiAFK = false,
    TeamCheck = true,
    FOV = 250,
    MenuOpen = true,
    FlySpeed = 50
}

local Theme = {
    Purple = Color3.fromRGB(130, 0, 255),
    Black = Color3.fromRGB(10, 10, 15),
    White = Color3.fromRGB(255, 255, 255),
    Grey = Color3.fromRGB(40, 40, 50),
    Red = Color3.fromRGB(255, 50, 50),
    Green = Color3.fromRGB(50, 255, 50),
    Cyan = Color3.fromRGB(0, 255, 255)
}

local DefaultWS = 16
local DefaultJP = 50

--------------------------------------------------------------------------------
-- 2. UI ENGINE
--------------------------------------------------------------------------------
local function CreateGUI()
    if LocalPlayer.PlayerGui:FindFirstChild("ENIGMA_HUB") then
        LocalPlayer.PlayerGui.ENIGMA_HUB:Destroy()
    end

    local Screen = Instance.new("ScreenGui")
    Screen.Name = "ENIGMA_HUB"
    Screen.ResetOnSpawn = false
    Screen.ZIndexBehavior = Enum.ZIndexBehavior.Global 
    Screen.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(0, 320, 0, 500)
    Container.Position = UDim2.new(0.5, -160, 0.3, 0)
    Container.BackgroundTransparency = 1 
    Container.Parent = Screen

    local Bg = Instance.new("Frame")
    Bg.Size = UDim2.new(1, 0, 1, 0)
    Bg.BackgroundColor3 = Theme.Black
    Bg.BackgroundTransparency = 0.1
    Bg.BorderSizePixel = 2
    Bg.BorderColor3 = Theme.Purple
    Bg.ZIndex = 1 
    Bg.Active = true
    Bg.Parent = Container

    local Header = Instance.new("TextLabel")
    Header.Text = "ENIGMA v13 :: FULL HUB"
    Header.Size = UDim2.new(1, 0, 0, 50)
    Header.BackgroundTransparency = 1
    Header.TextColor3 = Theme.Purple
    Header.Font = Enum.Font.Code
    Header.TextSize = 20
    Header.ZIndex = 10 
    Header.Parent = Container

    -- DRAG LOGIC
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        Container.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    Bg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = Container.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    Bg.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
    UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then update(input) end end)

    -- BUTTONS
    local yPos = 60
    local function CreateBtn(text, flag)
        local Btn = Instance.new("TextButton")
        Btn.Name = flag
        Btn.Parent = Container
        Btn.Text = text .. " [OFF]"
        Btn.Size = UDim2.new(0.9, 0, 0, 40)
        Btn.Position = UDim2.new(0.05, 0, 0, yPos)
        Btn.BackgroundColor3 = Theme.Grey
        Btn.TextColor3 = Theme.White
        Btn.Font = Enum.Font.Code
        Btn.TextSize = 13
        Btn.ZIndex = 20 
        
        local Stroke = Instance.new("UIStroke"); Stroke.Color = Color3.new(0,0,0); Stroke.Thickness = 2; Stroke.Parent = Btn

        Btn.Activated:Connect(function()
            Config[flag] = not Config[flag]
            if Config[flag] then
                Btn.Text = text .. " [ON]"
                Btn.BackgroundColor3 = Theme.Purple
            else
                Btn.Text = text .. " [OFF]"
                Btn.BackgroundColor3 = Theme.Grey
            end
        end)
        
        yPos = yPos + 50
        return Btn
    end

    CreateBtn("AIM ASSIST (HOLD E)", "Aimbot")
    CreateBtn("ESP (ENEMIES ONLY)", "ESP")
    CreateBtn("SPEED HACK [x2]", "SpeedHack")
    CreateBtn("FLY (SPACE TO UP)", "Fly")
    CreateBtn("NOCLIP", "Noclip")
    CreateBtn("INFINITE JUMP", "InfiniteJump")
    CreateBtn("ANTI AFK", "AntiAFK")

    -- MINIMIZE
    local MinBtn = Instance.new("TextButton")
    MinBtn.Text = "-"
    MinBtn.Size = UDim2.new(0, 40, 0, 40)
    MinBtn.Position = UDim2.new(1, -40, 0, 0)
    MinBtn.BackgroundTransparency = 1
    MinBtn.TextColor3 = Theme.White
    MinBtn.TextSize = 30
    MinBtn.ZIndex = 30
    MinBtn.Parent = Container

    MinBtn.Activated:Connect(function()
        Config.MenuOpen = not Config.MenuOpen
        if Config.MenuOpen then
            Container.Size = UDim2.new(0, 320, 0, 500); Bg.Visible = true; MinBtn.Text = "-"
            for _,v in pairs(Container:GetChildren()) do if v:IsA("TextButton") and v ~= MinBtn then v.Visible = true end end
        else
            Container.Size = UDim2.new(0, 320, 0, 50); Bg.Visible = true; MinBtn.Text = "+"
            for _,v in pairs(Container:GetChildren()) do if v:IsA("TextButton") and v ~= MinBtn then v.Visible = false end end
        end
    end)
    
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Insert then Container.Visible = not Container.Visible end
    end)
end

CreateGUI()

--------------------------------------------------------------------------------
-- 3. VISUALS (ESP)
--------------------------------------------------------------------------------
local ESP_Folder = Instance.new("Folder", Workspace)
local FOV_Box = Instance.new("Frame")
FOV_Box.BackgroundTransparency = 1
FOV_Box.BorderColor3 = Theme.Purple
FOV_Box.BorderSizePixel = 2
FOV_Box.Visible = false
FOV_Box.ZIndex = 100
FOV_Box.Parent = LocalPlayer:WaitForChild("PlayerGui")

local function IsEnemy(player)
    if not Config.TeamCheck then return true end
    if player.Team == nil then return true end
    if player.Team == LocalPlayer.Team then return false end
    return true
end

local function UpdateESP()
    ESP_Folder:ClearAllChildren()
    if not Config.ESP then return end

    local function Highlight(target, color)
        local box = Instance.new("BoxHandleAdornment")
        box.Size = Vector3.new(4, 5, 2)
        box.Adornee = target
        box.AlwaysOnTop = true
        box.ZIndex = 10
        box.Transparency = 0.5
        box.Color3 = color
        box.Parent = ESP_Folder
    end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if IsEnemy(p) then
                Highlight(p.Character.HumanoidRootPart, Theme.Red)
            end
        end
    end
    
    for _, m in pairs(Workspace:GetChildren()) do
        if m:IsA("Model") and m:FindFirstChild("Humanoid") and m:FindFirstChild("HumanoidRootPart") and not Players:GetPlayerFromCharacter(m) then
            Highlight(m.HumanoidRootPart, Theme.Cyan)
        end
    end
end

task.spawn(function()
    while true do UpdateESP() task.wait(0.5) end
end)

--------------------------------------------------------------------------------
-- 4. AIMBOT
--------------------------------------------------------------------------------
local function GetClosest()
    local Mouse = UserInputService:GetMouseLocation()
    local BestDist = Config.FOV
    local Target = nil

    local function Check(char, plr)
        if plr and not IsEnemy(plr) then return end
        
        local Head = char:FindFirstChild("Head")
        local Hum = char:FindFirstChild("Humanoid")
        if not Head or not Hum or Hum.Health <= 0 then return end
        
        local Pos, Vis = Camera:WorldToViewportPoint(Head.Position)
        if Vis then
            local Dist = (Vector2.new(Pos.X, Pos.Y) - Mouse).Magnitude
            if Dist < BestDist then
                BestDist = Dist
                Target = Head
            end
        end
    end

    for _, p in pairs(Players:GetPlayers()) do 
        if p ~= LocalPlayer and p.Character then Check(p.Character, p) end
    end
    for _, m in pairs(Workspace:GetChildren()) do
        if m:IsA("Model") and m:FindFirstChild("Humanoid") and m:FindFirstChild("HumanoidRootPart") then Check(m, nil) end
    end
    
    return Target
end

--------------------------------------------------------------------------------
-- 5. FEATURES
--------------------------------------------------------------------------------
local function SetupFeatures()
    local Char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local Hum = Char:WaitForChild("Humanoid")
    local Root = Char:WaitForChild("HumanoidRootPart")
    
    -- SPEED HACK
    task.spawn(function()
        while task.wait(0.1) do
            if Config.SpeedHack and Hum then
                Hum.WalkSpeed = DefaultWS * 2
            elseif Hum and Hum.WalkSpeed ~= DefaultWS then
                Hum.WalkSpeed = DefaultWS
            end
        end
    end)
    
    -- FLY
    local flyConn
    local BV
    
    task.spawn(function()
        while task.wait(0.1) do
            if Config.Fly and Hum and Root and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                if not BV then
                    BV = Instance.new("BodyVelocity")
                    BV.MaxForce = Vector3.new(0, math.huge, 0)
                    BV.Velocity = Vector3.new(0, Config.FlySpeed, 0)
                    BV.Parent = Root
                else
                    BV.Velocity = Vector3.new(0, Config.FlySpeed, 0)
                end
            elseif BV then
                BV:Destroy()
                BV = nil
            end
        end
    end)
    
    -- NOCLIP
    local clipConn
    task.spawn(function()
        while task.wait(0.1) do
            if Config.Noclip and Char then
                for _, part in pairs(Char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end
    end)
    
    -- INFINITE JUMP
    local ijConn
    local function enableInfJump()
        if ijConn then ijConn:Disconnect() end
        ijConn = UserInputService.InputBegan:Connect(function(input, gameprocessed)
            if gameprocessed then return end
            if input.KeyCode == Enum.KeyCode.Space and Hum and Config.InfiniteJump then
                Hum:ChangeState("Jumping")
            end
        end)
    end
    enableInfJump()
    
    -- ANTI AFK
    local afkConn
    task.spawn(function()
        while task.wait(1) do
            if Config.AntiAFK then
                local vu = game:GetService("VirtualUser")
                vu:CaptureController()
                vu:ClickButton2(Vector2.new(0,0))
            end
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    SetupFeatures()
end)

if LocalPlayer.Character then
    SetupFeatures()
end

--------------------------------------------------------------------------------
-- 6. MAIN LOOP
--------------------------------------------------------------------------------
RunService.RenderStepped:Connect(function()
    local m = UserInputService:GetMouseLocation()
    
    -- FOV Circle
    if Config.Aimbot then
        FOV_Box.Visible = true
        FOV_Box.Size = UDim2.new(0, Config.FOV*2, 0, Config.FOV*2)
        FOV_Box.Position = UDim2.new(0, m.X - Config.FOV, 0, m.Y - Config.FOV)
    else
        FOV_Box.Visible = false
    end

    -- Aimbot
    if Config.Aimbot and UserInputService:IsKeyDown(Config.AimKey) then
        local t = GetClosest()
        if t then
            FOV_Box.BorderColor3 = Theme.Green
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Position)
        else
            FOV_Box.BorderColor3 = Theme.Purple
        end
    end
end)

print("ENIGMA HUB v13.0 Loaded!")