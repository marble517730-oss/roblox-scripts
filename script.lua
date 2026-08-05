local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local tpState = {
    isActive = false,
    savedCF = nil,
    conns = {}
}
local tpPerFrame = 5

local function tpCoord()
    local e = 10^19
    return (math.random() * 10) * e * (math.random(1,2) == 1 and 1 or -1)
end

local function tpDoTP()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        pcall(function()
            hrp.CFrame = CFrame.new(tpCoord(), tpCoord(), tpCoord())
        end)
    end
end

local function tpStart()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        tpState.savedCF = hrp.CFrame
    end

    tpState.conns[1] = RunService.RenderStepped:Connect(function()
        for _ = 1, tpPerFrame do
            tpDoTP()
        end
    end)

    tpState.conns[2] = RunService.Heartbeat:Connect(function()
        for _ = 1, tpPerFrame do
            tpDoTP()
        end
    end)

    tpState.conns[3] = RunService.Stepped:Connect(function()
        for _ = 1, tpPerFrame do
            tpDoTP()
        end
    end)

    task.spawn(function()
        while tpState.isActive do
            for _ = 1, tpPerFrame do
                tpDoTP()
            end
            task.wait()
        end
    end)
end

local function tpStop()
    tpState.isActive = false

    for i = 1, 3 do
        if tpState.conns[i] then
            tpState.conns[i]:Disconnect()
            tpState.conns[i] = nil
        end
    end
    tpState.conns = {}

    if tpState.savedCF then
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            pcall(function()
                hrp.CFrame = tpState.savedCF
            end)
        end
    end
end

local Window = Library:CreateWindow({
    Title = "Kill Bypass",
    Footer = "Poop HUB Extract",
    Icon = 827330977,
    ShowCustomCursor = true,
    AutoShow = true,
    NotifySide = "Right",
})

local Tab = Window:AddTab("Bypass", "shield")
local Left = Tab:AddLeftGroupbox("Kill Bypass")
local Right = Tab:AddRightGroupbox("Settings")

Left:AddToggle("KillBypass", {
    Text = "Kill Bypass ON/OFF",
    Default = false,
    Callback = function(Value)
        tpState.isActive = Value
        if Value then
            tpStart()
            Library:Notify("Kill Bypass: Enabled", 3)
        else
            tpStop()
            Library:Notify("Kill Bypass: Disabled", 3)
        end
    end
})

Right:AddSlider("KillBypassTPCount", {
    Text = "TP / Frame",
    Default = 5,
    Min = 1,
    Max = 500,
    Rounding = 0,
    Callback = function(v)
        tpPerFrame = v
    end
})

Right:AddButton({
    Text = "Stop & Reset Position",
    Func = function()
        if tpState.isActive then
            tpStop()
            tpState.isActive = false
        end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            pcall(function()
                hrp.CFrame = CFrame.new(0, 10, 0)
            end)
        end
        Library:Notify("Reset position to (0,10,0)", 3)
    end
})

local UISettings = Window:AddTab("UI Settings", "settings")
local UILeft = UISettings:AddLeftGroupbox("Theme")

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({"MenuKeybind"})
SaveManager:SetFolder("KillBypass")
ThemeManager:ApplyToGroupbox(UILeft)
SaveManager:BuildConfigSection(UISettings)

SaveManager:LoadAutoloadConfig()

Library:Notify("Kill Bypass Loaded!", 4)

print("========================================")
print("Kill Bypass - Poop HUB Extract")
print("========================================")
