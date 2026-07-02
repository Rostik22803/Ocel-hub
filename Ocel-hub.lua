-- =============================================================================
-- DOORS LOCAL MEGA HUB v12.3 (CORE GUI + INSTANT INTERACT)
-- =============================================================================

local oldGui = game:GetService("CoreGui"):FindFirstChild("DoorsLocalMegaHubFinal")
if oldGui then oldGui:Destroy() end

_G.InstantInteract = false

-- Создание интерфейса в CoreGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DoorsLocalMegaHubFinal"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 380)
MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, 0, 1, -40)
ScrollingFrame.Position = UDim2.new(0, 0, 0, 35)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 480)
ScrollingFrame.ScrollBarThickness = 4
ScrollingFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollingFrame
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- =============================================================================
-- INSTANT INTERACT LOGIC
-- =============================================================================
local function SetInteractSpeed(enabled)
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            obj.HoldDuration = enabled and 0 or 0.5 -- 0.5 стандарт для большинства дверей
        end
    end
end

-- Следим за новыми комнатами/объектами
workspace.DescendantAdded:Connect(function(desc)
    if desc:IsA("ProximityPrompt") and _G.InstantInteract then
        desc.HoldDuration = 0
    end
end)

-- =============================================================================
-- КНОПКИ
-- =============================================================================
local function CreateToggle(name, varName)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 210, 0, 36)
    Btn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
    Btn.Text = name .. ": ВЫКЛ"
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.SourceSansBold
    Btn.TextSize = 13
    Btn.Parent = ScrollingFrame
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    
    Btn.MouseButton1Click:Connect(function()
        _G[varName] = not _G[varName]
        if _G[varName] then
            Btn.Text = name .. ": ВКЛ"
            Btn.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
            if varName == "InstantInteract" then SetInteractSpeed(true) end
        else
            Btn.Text = name .. ": ВЫКЛ"
            Btn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
            if varName == "InstantInteract" then SetInteractSpeed(false) end
        end
    end)
end

CreateToggle("Instant Interact", "InstantInteract")
