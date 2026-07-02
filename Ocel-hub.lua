-- =============================================================================
-- DOORS LOCAL MEGA HUB v16.0 (ABSOLUTE CLIENT DEFUSE)
-- =============================================================================

local oldGui = game:GetService("CoreGui"):FindFirstChild("DoorsLocalMegaHubFinal")
if oldGui then oldGui:Destroy() end

-- Глобальные настройки
_G.DoorEspEnabled = false
_G.MonsterEspEnabled = false
_G.ItemEspEnabled = false
_G.HidingEspEnabled = false
_G.NotificationsEnabled = true 

-- Стопроцентные тумблеры (Клиентские)
_G.AntiA90 = false
_G.AntiScreech = false
_G.AntiSnare = false
_G.AntiTimothy = false
_G.AntiGiggle = false
_G.AntiEyes = false

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Цвета обводок и кастомного текста
local Colors = {
    Door = Color3.fromRGB(0, 255, 100),     
    Monster = Color3.fromRGB(255, 50, 50),  
    Item = Color3.fromRGB(255, 200, 0),     
    Hiding = Color3.fromRGB(0, 180, 255),
    TextNotif = Color3.fromRGB(240, 240, 240),
    AntiA90 = Color3.fromRGB(255, 0, 128),
    AntiScreech = Color3.fromRGB(170, 0, 255),
    AntiSnare = Color3.fromRGB(0, 255, 150),
    AntiTimothy = Color3.fromRGB(255, 100, 0),
    AntiGiggle = Color3.fromRGB(0, 150, 255),
    AntiEyes = Color3.fromRGB(0, 255, 255)
}

local ColorPalette = {
    Color3.fromRGB(0, 255, 100), Color3.fromRGB(255, 50, 50), Color3.fromRGB(255, 200, 0),
    Color3.fromRGB(0, 180, 255), Color3.fromRGB(255, 0, 255), Color3.fromRGB(255, 255, 255),
    Color3.fromRGB(255, 128, 0), Color3.fromRGB(170, 0, 255), Color3.fromRGB(0, 255, 255),
    Color3.fromRGB(150, 255, 0), Color3.fromRGB(255, 100, 150)
}

local MonsterNames = {
    ["RushMoving"] = "Раш 🏃‍♂️", ["AmbushMoving"] = "Амбуш ⚡", ["Eyes"] = "Глаза 👀",
    ["SeekMoving"] = "Сик 👁️", ["Figure"] = "Фигура 👤", ["A60"] = "A-60 🔴",
    ["A120"] = "A-120 ⭕", ["GiggleCeiling"] = "Гиггл 💢", ["Grumble"] = "Грамбл 👾"
}

local function GetCurrentRoomNumber()
    if LocalPlayer and LocalPlayer:GetAttribute("CurrentRoom") then
        return tonumber(LocalPlayer:GetAttribute("CurrentRoom"))
    end
    return 0
end

-- =============================================================================
-- ПОТОК СТОПРОЦЕНТНОЙ ЗАЩИТЫ (Прямое вырезание логики на клиенте)
-- =============================================================================
task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            local char = LocalPlayer.Character
            if not char then return end
            
            -- Блокировка Скрича и Гиггла (удаляем их физические атаки с головы персонажа)
            if _G.AntiScreech or _G.AntiGiggle then
                local head = char:FindFirstChild("Head")
                if head then
                    for _, bug in pairs(head:GetChildren()) do
                        if (_G.AntiScreech and (bug.Name == "Screech" or bug.Name == "ScreechSuck")) or 
                           (_G.AntiGiggle and (bug.Name == "Giggle" or bug.Name == "GiggleBug")) then
                            bug:Destroy()
                        end
                    end
                end
            end
            
            -- Блокировка А-90 (Если появляется на экране — мгновенно фризим координаты, игра думает что мы стоим)
            if _G.AntiA90 and (LocalPlayer.PlayerGui:FindFirstChild("A90") or MainFrame.Parent:FindFirstChild("A90")) then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    root.Velocity = Vector3.new(0,0,0)
                    root.RotVelocity = Vector3.new(0,0,0)
                end
            end
        end)
    end
end)

-- Слежка за объектами в мире (Глаза, Капканы, Тимоти)
local function ManageBypassOnObject(child)
    pcall(function()
        -- Стопроцентный Анти-Айс (Глаза)
        if child.Name == "Eyes" and _G.AntiEyes then
            task.wait(0.1)
            -- Стираем ремоут нанесения урона внутри самих Глаз
            local remote = child:FindFirstChild("LookAt") or child:FindFirstChildOfClass("RemoteEvent")
            if remote then remote:Destroy() end
            -- Ослепляем его хитбокс
            if child:FindFirstChild("Core") then child.Core:Destroy() end
        end
        
        -- Ловушки Снайр (Капканы в Greenhouse)
        if child.Name == "Snare" and _G.AntiSnare then
            task.wait(0.1)
            for _, p in pairs(child:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false p.Size = Vector3.new(0,0,0) end
            end
        end
    end)
end

workspace.ChildAdded:Connect(ManageBypassOnObject)
if workspace:FindFirstChild("CurrentRooms") then
    workspace.CurrentRooms.DescendantAdded:Connect(ManageBypassOnObject)
end

-- Хук на сундуки (Анти Тимоти)
local function HookChests(asset)
    if asset.Name == "ChestBox" and _G.AntiTimothy then
        local timothy = asset:FindFirstChild("Timothy") or asset:FindFirstChild("Spider")
        if timothy then timothy:Destroy() end
    end
end
workspace.DescendantAdded:Connect(HookChests)

-- =============================================================================
-- ИНТЕРФЕЙС И ОВЕРЛЕИ
-- =============================================================================
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

local ClipFrame = Instance.new("Frame")
ClipFrame.Size = UDim2.new(1, 0, 1, 0)
ClipFrame.BackgroundTransparency = 1
ClipFrame.ClipsDescendants = true
ClipFrame.Parent = MainFrame
Instance.new("UICorner", ClipFrame).CornerRadius = UDim.new(0, 8)

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, 0, 1, -40)
ScrollingFrame.Position = UDim2.new(0, 0, 0, 35)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 480)
ScrollingFrame.ScrollBarThickness = 4
ScrollingFrame.Parent = ClipFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollingFrame
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local HeaderFrame = Instance.new("Frame")
HeaderFrame.Size = UDim2.new(1, 0, 0, 35)
HeaderFrame.BackgroundTransparency = 1
HeaderFrame.Parent = ClipFrame

local LogoLabel = Instance.new("TextLabel")
LogoLabel.Size = UDim2.new(0, 150, 1, 0)
LogoLabel.Position = UDim2.new(0, 12, 0, 0)
LogoLabel.Text = "Ocel-hub"
LogoLabel.TextColor3 = Colors.TextNotif
LogoLabel.Font = Enum.Font.SourceSansBold
LogoLabel.TextSize = 16
LogoLabel.TextXAlignment = Enum.TextXAlignment.Left
LogoLabel.BackgroundTransparency = 1
LogoLabel.Parent = HeaderFrame

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 25, 0, 25)
MinimizeBtn.Position = UDim2.new(1, -30, 0, 5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.Parent = HeaderFrame
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 4)

local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MinimizeBtn.Text = "+"
        ClipFrame:TweenSize(UDim2.new(1, 0, 0, 35), "Out", "Quart", 0.2, true)
        MainFrame:TweenSize(UDim2.new(0, 240, 0, 35), "Out", "Quart", 0.2, true)
    else
        MinimizeBtn.Text = "—"
        ClipFrame:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Quart", 0.2, true)
        MainFrame:TweenSize(UDim2.new(0, 240, 0, 380), "Out", "Quart", 0.2, true)
    end
end)

local function CreateEspControl(name)
    local RowFrame = Instance.new("Frame")
    RowFrame.Size = UDim2.new(0, 210, 0, 36)
    RowFrame.BackgroundTransparency = 1
    RowFrame.Parent = ScrollingFrame
    
    local MainBtn = Instance.new("TextButton")
    MainBtn.Size = UDim2.new(1, 0, 1, 0)
    MainBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
    MainBtn.Text = name .. ": ВЫКЛ"
    MainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MainBtn.Font = Enum.Font.SourceSansBold
    MainBtn.TextSize = 13
    MainBtn.Parent = RowFrame
    Instance.new("UICorner", MainBtn).CornerRadius = UDim.new(0, 6)
    return MainBtn
end

local DoorButton = CreateEspControl("ESP ДВЕРЕЙ")
local MonsterButton = CreateEspControl("ESP МОНСТРОВ")
local ItemButton = CreateEspControl("ESP ПРЕДМЕТОВ")
local HidingButton = CreateEspControl("ESP УКРЫТИЙ")

-- Переключатели 100% Клиентских Байпасов
local EyesButton = CreateEspControl("АНТИ ГЛАЗА")
local A90Button = CreateEspControl("АНТИ А-90")
local ScreechButton = CreateEspControl("АНТИ СКРИЧ")
local SnareButton = CreateEspControl("АНТИ КАПКАН")
local TimothyButton = CreateEspControl("АНТИ ТИМОТИ")
local GiggleButton = CreateEspControl("АНТИ ГИГГЛ")

-- =============================================================================
-- ESP СКАНИРОВАНИЕ
-- =============================================================================
local function ApplyESP(object, color, text, id)
    if not object then return end
    local billboard = object:FindFirstChild("LocalText_" .. id)
    local highlight = object:FindFirstChild("LocalHighlight_" .. id)
    if billboard and highlight then return end
    
    local highlightInstance = Instance.new("Highlight")
    highlightInstance.Name = "LocalHighlight_" .. id
    highlightInstance.FillColor = color
    highlightInstance.FillTransparency = 0.6
    highlightInstance.Adornee = object
    highlightInstance.Parent = object
    
    local bGui = Instance.new("BillboardGui")
    bGui.Name = "LocalText_" .. id
    bGui.Size = UDim2.new(0, 160, 0, 40)
    bGui.AlwaysOnTop = true
    bGui.StudsOffset = Vector3.new(0, 2.5, 0)
    bGui.Parent = object
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color 
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 15
    label.Parent = bGui
end

local function RemoveESP(object, id)
    if not object then return end
    local highlight = object:FindFirstChild("LocalHighlight_" .. id)
    local billboard = object:FindFirstChild("LocalText_" .. id)
    if highlight then highlight:Destroy() end
    if billboard then billboard:Destroy() end
end

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local rooms = workspace:FindFirstChild("CurrentRooms")
            local currentRoomNum = GetCurrentRoomNumber()
            if rooms then
                for _, room in pairs(rooms:GetChildren()) do
                    local roomNum = tonumber(room.Name) or 0
                    
                    -- Двери
                    local door = room:FindFirstChild("Door")
                    if door then
                        local actualDoor = door:FindFirstChild("Door") or door
                        if roomNum < currentRoomNum then RemoveESP(actualDoor, "Door")
                        elseif _G.DoorEspEnabled then
                            ApplyESP(actualDoor, Colors.Door, "🚪 Дверь " .. tostring(roomNum + 1), "Door")
                        else RemoveESP(actualDoor, "Door") end
                    end
                    
                    -- Лут и шкафы
                    for _, asset in pairs(room:GetDescendants()) do
                        if roomNum < currentRoomNum then
                            RemoveESP(asset, "Item") RemoveESP(asset, "Hiding")
                        else
                            if _G.ItemEspEnabled and (asset.Name == "KeyObtain" or asset.Name == "LeverForGate" or asset.Name == "LiveHintBook") then
                                ApplyESP(asset, Colors.Item, "⭐ Ключевой Предмет", "Item")
                            elseif _G.HidingEspEnabled and (asset.Name == "Wardrobe" or asset.Name == "Bed") then
                                ApplyESP(asset, Colors.Hiding, "🛏️ Укрытие", "Hiding")
                            end
                        end
                    end
                end
            end
            
            -- Монстры
            if _G.MonsterEspEnabled then
                for _, child in pairs(workspace:GetChildren()) do
                    if MonsterNames[child.Name] then ApplyESP(child, Colors.Monster, child.Name, "Monster") end
                end
            end
        end)
    end
end)

-- Логика кнопок
local function HandleToggle(btn, varName)
    _G[varName] = not _G[varName]
    if _G[varName] then
        btn.Text = string.split(btn.Text, ":")[1] .. ": ВКЛ"
        btn.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
    else
        btn.Text = string.split(btn.Text, ":")[1] .. ": ВЫКЛ"
        btn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
    end
end

DoorButton.MouseButton1Click:Connect(function() HandleToggle(DoorButton, "DoorEspEnabled") end)
MonsterButton.MouseButton1Click:Connect(function() HandleToggle(MonsterButton, "MonsterEspEnabled") end)
ItemButton.MouseButton1Click:Connect(function() HandleToggle(ItemButton, "ItemEspEnabled") end)
HidingButton.MouseButton1Click:Connect(function() HandleToggle(HidingButton, "HidingEspEnabled") end)

EyesButton.MouseButton1Click:Connect(function() HandleToggle(EyesButton, "AntiEyes") end)
A90Button.MouseButton1Click:Connect(function() HandleToggle(A90Button, "AntiA90") end)
ScreechButton.MouseButton1Click:Connect(function() HandleToggle(ScreechButton, "AntiScreech") end)
SnareButton.MouseButton1Click:Connect(function() HandleToggle(SnareButton, "AntiSnare") end)
TimothyButton.MouseButton1Click:Connect(function() HandleToggle(TimothyButton, "AntiTimothy") end)
GiggleButton.MouseButton1Click:Connect(function() HandleToggle(GiggleButton, "AntiGiggle") end)
