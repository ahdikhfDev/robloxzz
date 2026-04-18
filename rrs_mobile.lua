--[[
    RRS v3.1 MOBILE EDITION
    - Compact UI (50% smaller)
    - Show ALL results (tools, pickups, secrets, triggers)
    - Fixed display
    - Mobile optimized
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")

local Config = {
    MenuOpen = true,
    AutoScan = true,
    ScanInterval = 3,
    AutoPickup = false,
    PickupRadius = 25,
    AutoEquip = false,
    AntiVoid = true,
    AntiAFK = true,
    ShowDistance = true
}

local Theme = {
    MainBg = Color3.fromRGB(18, 18, 25),
    Accent = Color3.fromRGB(130, 0, 255),
    OnColor = Color3.fromRGB(0, 255, 128),
    OffColor = Color3.fromRGB(70, 70, 80),
    Gold = Color3.fromRGB(255, 215, 0),
    TextWhite = Color3.fromRGB(245, 245, 245),
    TextSub = Color3.fromRGB(150, 150, 160),
    Cyan = Color3.fromRGB(0, 255, 255),
    Warning = Color3.fromRGB(255, 200, 80)
}

local ScanResults = {Tools = {}, Pickups = {}, Secrets = {}, Triggers = {}, Logs = {}}
local State = {ScanCount = 0}

local function Log(msg) table.insert(ScanResults.Logs, msg) print(msg) end
local function GetDist(pos)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    return hrp and math.floor((pos - hrp.Position).Magnitude) or 999
end

local function ScanAll()
    ScanResults.Tools = {} ScanResults.Pickups = {} ScanResults.Secrets = {} ScanResults.Triggers = {}
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        local dist = GetDist(obj.Position)
        if dist <= 1500 then
            if obj:IsA("Tool") and obj:FindFirstChild("Handle") then
                table.insert(ScanResults.Tools, {name = obj.Name, dist = dist, obj = obj})
            elseif obj:IsA("Part") and obj:FindFirstChild("TouchInterest") then
                table.insert(ScanResults.Pickups, {name = obj.Name, dist = dist, obj = obj})
            elseif obj:IsA("Part") and obj.Transparency > 0.5 then
                table.insert(ScanResults.Secrets, {name = obj.Name, dist = dist, obj = obj})
            end
        end
    
    table.sort(ScanResults.Tools, function(a,b) return a.dist < b.dist end)
    table.sort(ScanResults.Pickups, function(a,b) return a.dist < b.dist end)
    table.sort(ScanResults.Secrets, function(a,b) return a.dist < b.dist end)
    table.sort(ScanResults.Triggers, function(a,b) return a.dist < b.dist end)
    
    State.ScanCount = State.ScanCount + 1
    Log(string.format("[%d] T:%d P:%d S:%d", State.ScanCount, #ScanResults.Tools, #ScanResults.Pickups, #ScanResults.Secrets))
end

local function DoAutoPick()
    if not Config.AutoPickup then return end
    local hrp = LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart
    if not hrp then return end
    for _, p in ipairs(ScanResults.Pickups) do
        if p.dist < Config.PickupRadius then
            firetouchinterest(hrp, p.obj, true)
            task.delay(0.05, function() firetouchinterest(hrp, p.obj, false) end)
        end
    end
end

-- MOBILE COMPACT UI (50% smaller)
local function CreateGUI()
    local Screen = Instance.new("ScreenGui")
    Screen.Name = "RRS_MOBILE"
    Screen.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 200, 0, 250) -- Compact!
    Main.Position = UDim2.new(0, 5, 0, 5)
    Main.BackgroundColor3 = Theme.MainBg
    Main.BorderSizePixel = 0
    Main.Parent = Screen
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", Main).Color = Theme.Accent

    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 28)
    Header.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    Header.Parent = Main

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -25, 1, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "⚡RRS"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 12
    Title.TextColor3 = Theme.Accent
    Title.Parent = Header

    local Status = Instance.new("TextLabel")
    Status.Size = UDim2.new(1, 0, 0, 18)
    Status.Position = UDim2.new(0, 0, 1, -18)
    Status.BackgroundTransparency = 1
    Status.Text = "Tap SCAN"
    Status.Font = Enum.Font.Code
    Status.TextSize = 9
    Status.TextColor3 = Theme.Cyan
    Status.Parent = Main

    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(1, 0, 1, -50)
    Scroll.Position = UDim2.new(0, 0, 0, 30)
    Scroll.BackgroundTransparency = 1
    Scroll.ScrollBarThickness = 3
    Scroll.ScrollBarImageColor3 = Theme.Accent
    Scroll.Parent = Main
    Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 1)

    local ResultText = Instance.new("TextLabel")
    ResultText.Size = UDim2.new(1, -15, 0, 200)
    ResultText.BackgroundTransparency = 1
    ResultText.Text = "Ready"
    ResultText.Font = Enum.Font.Code
    ResultText.TextSize = 9
    ResultText.TextColor3 = Theme.TextSub
    ResultText.TextWrapped = true
    ResultText.AutomaticSize = Enum.AutomaticSize.Y
    ResultText.TextXAlignment = Enum.TextXAlignment.Left
    ResultText.Parent = Scroll

    local ScanBtn = Instance.new("TextButton")
    ScanBtn.Size = UDim2.new(0.9, 0, 0, 22)
    ScanBtn.Position = UDim2.new(0.05, 0, 0, 32)
    ScanBtn.BackgroundColor3 = Theme.Accent
    ScanBtn.Text = "⚡SCAN"
    ScanBtn.Font = Enum.Font.GothamBold
    ScanBtn.TextSize = 10
    ScanBtn.TextColor3 = Theme.TextWhite
    ScanBtn.Parent = Main
    Instance.new("UICorner", ScanBtn).CornerRadius = UDim.new(0, 5)

    local function CreateToggle(text, y, flag)
        local cb = Instance.new("TextButton")
        cb.Size = UDim2.new(0.35, 0, 0, 16)
        cb.Position = UDim2.new(0.6, 0, 0, y)
        cb.BackgroundColor3 = Theme.OffColor
        cb.Text = text
        cb.Font = Enum.Font.GothamMedium
        cb.TextSize = 8
        cb.TextColor3 = Theme.TextWhite
        cb.Parent = Main
        Instance.new("UICorner", cb).CornerRadius = UDim.new(0, 4)
        cb.MouseButton1Click:Connect(function()
            Config[flag] = not Config[flag]
            cb.BackgroundColor3 = Config[flag] and Theme.OnColor or Theme.OffColor
        end)
    end

    CreateToggle("AP", 55, "AutoPickup")
    CreateToggle("AV", 55, "AntiVoid")
    CreateToggle("AA", 55, "AntiAFK")

    local function update()
        local txt = ""
        
        if #ScanResults.Tools > 0 then
            txt = txt .. "[TOOLS]\n"
            for i, t in ipairs(ScanResults.Tools) do
                txt = txt .. string.format("O %s (%d)\n", t.name:sub(1,12), t.dist)
            end
        end
        
        if #ScanResults.Pickups > 0 then
            txt = txt .. "\n[PICKUP]\n"
            for i, p in ipairs(ScanResults.Pickups) do
                txt = txt .. string.format("+ %s (%d)\n", p.name:sub(1,12), p.dist)
            end
        end
        
        if #ScanResults.Secrets > 0 then
            txt = txt .. "\n[SECRET]\n"
            for i, s in ipairs(ScanResults.Secrets) do
                txt = txt .. string.format("? %s (%d)\n", s.name:sub(1,12), s.dist)
            end
        end
        
        if txt == "" then txt = "Tap SCAN\nto start" end
        ResultText.Text = txt
        
        local total = #ScanResults.Tools + #ScanResults.Pickups + #ScanResults.Secrets
        Status.Text = string.format("#%d | %d items", State.ScanCount, total)
    end

    ScanBtn.MouseButton1Click:Connect(function()
        ScanBtn.Text = "..."
        pcall(function() ScanAll() end)
        pcall(function() DoAutoPick() end)
        task.delay(0.2, function()
            update()
            ScanBtn.Text = "⚡SCAN"
        end)
    end)

    -- AUTO LOOP
    task.spawn(function()
        while true do
            task.wait(Config.ScanInterval)
            if Config.MenuOpen then
                pcall(function() ScanAll() end)
                pcall(function() DoAutoPick() end)
                if Config.AntiVoid then
                    local hrp = LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart
                    if hrp and hrp.Position.Y < -300 then
                        LocalPlayer.Character:Destroy()
                    end
                end
                if Config.AntiAFK then
                    pcall(function() VirtualUser:CaptureController() VirtualUser:ClickButton2(Vector2.new(0,0)) end)
                end
            end
        end
    end)

    LocalPlayer.CharacterAdded:Connect(function() task.wait(0.5) update() end)

    Log("RRS MOBILE Ready!")
end

delay(0.2, function() pcall(CreateGUI) end)