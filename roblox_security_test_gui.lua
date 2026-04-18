--[[
    ENIGMA RED TEAM SUITE - GUI Launcher
    ==================================
    Security Testing Framework untuk server Roblox Anda sendiri
    Educational security research only
--]]

local SecurityTestModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/your-repo/enigma-red-team/main/init.lua"))()

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local SubTitle = Instance.new("TextLabel")
local RunAllButton = Instance.new("TextButton")
local Phase1Button = Instance.new("TextButton")
local Phase2Button = Instance.new("TextButton")
local Phase3Button = Instance.new("TextButton")
local ResultsButton =Instance.new("TextButton")
local CloseButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")
local UIGradient = Instance.new("UIGradient")

ScreenGui.Name = "EnigmaRedTeamGUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
MainFrame.BorderSizePixel = 2
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -180)
MainFrame.Size = UDim2.new(0, 400, 0, 360)
MainFrame.Draggable = true
MainFrame.Active = true

UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local gradient = UIGradient.new()
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 0, 0))
}
gradient.Rotation = 45
gradient.Parent = MainFrame

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Position = UDim2.new(0, 0, 0, 10)
Title.Font = Enum.Font.GothamBold
Title.Text = "ENIGMA RED TEAM"
Title.TextColor3 = Color3.fromRGB(255, 0, 0)
Title.TextSize = 28
Title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
Title.TextStrokeTransparency = 0

SubTitle.Name = "SubTitle"
SubTitle.Parent = MainFrame
SubTitle.BackgroundTransparency = 1
SubTitle.Size = UDim2.new(1, 0, 0, 20)
SubTitle.Position = UDim2.new(0, 0, 0, 45)
SubTitle.Font = Enum.Font.Gotham
SubTitle.Text = "Security Testing Framework v1.0"
SubTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
SubTitle.TextSize = 12

local function createButton(name, text, posY, color)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Parent = MainFrame
    btn.BackgroundColor3 = color or Color3.fromRGB(40, 40, 40)
    btn.BorderColor3 = Color3.fromRGB(255, 0, 0)
    btn.BorderSizePixel = 1
    btn.Position = UDim2.new(0.05, 0, 0, posY)
    btn.Size = UDim2.new(0.9, 0, 0, 45)
    btn.Font = Enum.Font.GothamBold
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 16
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    return btn
end

RunAllButton = createButton("RunAllButton", "▶ RUN ALL ATTACKS", 75, Color3.fromRGB(180, 0, 0))
Phase1Button = createButton("Phase1Button", "Phase 1: Basic", 130, Color3.fromRGB(0, 100, 0))
Phase2Button = createButton("Phase2Button", "Phase 2: Intermediate", 185, Color3.fromRGB(0, 0, 150))
Phase3Button = createButton("Phase3Button", "Phase 3: Advanced", 240, Color3.fromRGB(100, 0, 100))
ResultsButton = createButton("ResultsButton", "📊 VIEW RESULTS", 295, Color3.fromRGB(80, 80, 80))
CloseButton = createButton("CloseButton", "✕ CLOSE", 350, Color3.fromRGB(100, 0, 0))

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Parent = MainFrame
StatusLabel.BackgroundTransparency = 1
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Position = UDim2.new(0, 0, 0, 60)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "Status: Ready"
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
StatusLabel.TextSize = 12

local function updateStatus(text, color)
    StatusLabel.Text = "Status: " .. text
    StatusLabel.TextColor3 = color or Color3.fromRGB(0, 255, 0)
end

RunAllButton.MouseButton1Click:Connect(function()
    updateStatus("Running all attacks...", Color3.fromRGB(255, 255, 0))
    SecurityTestModule.runAll()
    updateStatus("Complete!", Color3.fromRGB(0, 255, 0))
end)

Phase1Button.MouseButton1Click:Connect(function()
    updateStatus("Running Phase 1...", Color3.fromRGB(255, 255, 0))
    SecurityTestModule.runSpecific(1)
    updateStatus("Phase 1 Complete!", Color3.fromRGB(0, 255, 0))
end)

Phase2Button.MouseButton1Click:Connect(function()
    updateStatus("Running Phase 2...", Color3.fromRGB(255, 255, 0))
    SecurityTestModule.runSpecific(2)
    updateStatus("Phase 2 Complete!", Color3.fromRGB(0, 255, 0))
end)

Phase3Button.MouseButton1Click:Connect(function()
    updateStatus("Running Phase 3...", Color3.fromRGB(255, 255, 0))
    SecurityTestModule.runSpecific(3)
    updateStatus("Phase 3 Complete!", Color3.fromRGB(0, 255, 0))
end)

ResultsButton.MouseButton1Click:Connect(function()
    SecurityTestModule.printResults()
    updateStatus("Results displayed", Color3.fromRGB(0, 255, 255))
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

updateStatus("GUI Ready", Color3.fromRGB(0, 255, 0))

return {
    ScreenGui = ScreenGui,
    Run = function(phase)
        if phase then
            SecurityTestModule.runSpecific(phase)
        else
            SecurityTestModule.runAll()
        end
    end,
    GetResults = function()
        return SecurityTestModule.getResults()
    end
}