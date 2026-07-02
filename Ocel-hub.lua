-- =============================================================================
-- DOORS LOCAL MEGA HUB v15.0 (METATABLE HOOK EDITION)
-- =============================================================================

local oldGui = game:GetService("CoreGui"):FindFirstChild("DoorsLocalMegaHubFinal")
if oldGui then oldGui:Destroy() end

-- Глобальные настройки ESP
_G.DoorEspEnabled = false
_G.MonsterEspEnabled = false
_G.ItemEspEnabled = false
_G.HidingEspEnabled = false
_G.NotificationsEnabled = true 

-- Флаги байпасов (Блокировка отправки данных на сервер)
_G.Bypasses = {
    ["A90"] = false,
    ["A-90"] = false,
    ["Screech"] = false,
    ["Snare"] = false,
    ["Timothy"] = false,
    ["Giggle"] = false
}

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
    AntiGiggle = Color3.fromRGB(0, 150, 255)
}

local ColorPalette = {
    Color3.fromRGB(0, 255, 100), Color3.fromRGB(255, 50, 50), Color3.fromRGB(255, 200, 0),
    Color3.fromRGB(0, 180, 255), Color3.fromRGB(255, 0, 255), Color3.fromRGB(255, 255, 255),
    Color3.fromRGB(255, 128, 0), Color3.fromRGB(170, 0, 255), Color3.fromRGB(0, 255, 255),
    Color3.fromRGB(150, 255, 0), Color3.fromRGB(255, 100, 150), Color3.fromRGB(0, 50, 200)
}

local MonsterNames = {
    ["RushMoving"] = "Раш 🏃‍♂️", ["AmbushMoving"] = "Амбуш ⚡", ["Eyes"] = "Глаза 👀",
    ["SeekMoving"] = "Сик 👁️", ["Figure"] = "Фигура 👤", ["A60"] = "A-60 🔴",
    ["A120"] = "A-120 ⭕", ["GiggleCeiling"] = "Гиггл 💢", ["Grumble"] = "Грамбл 👾"
}

-- =============================================================================
-- ЗАЩИТА: МЕТАХУК ДЛЯ БАЙПАСОВ (Решает проблему нерабочих анти-существ)
-- =============================================================================
local RawMetatable = getrawmetatable(game)
local OldNamecall = RawMetatable.__namecall
setreadonly(RawMetatable, false)

RawMetatable.__namecall = newcclosure(function(Self, ...)
    local Method = getnamecallmethod()
    local Args = {...}
    
    if (Method == "FireServer" or Method == "fireServer") and Self and Self.ClassName == "RemoteEvent" then
        if _G.Bypasses[Self.Name] then
            -- Игра думает, что отправила эвент, но мы его глушим. Защита Doors не видит подвоха!
            return nil
        end
    end
    return OldNamecall(Self, ...)
end)
setreadonly(RawMetatable, true)

local function GetCurrentRoomNumber()
    local player = game:GetService("Players").LocalPlayer
    if player and player:GetAttribute("CurrentRoom") then
        return tonumber(player:GetAttribute("CurrentRoom"))
    end
    return 0
end

local ActiveLogoLabel = nil
local ActiveNotifications = {} 

-- =============================================================================
-- 1. ИНТЕРФЕЙС И УВЕДОМЛЕНИЯ (Фикс багов меню)
-- =============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DoorsLocalMegaHubFinal"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

local NotifContainer = Instance.new("Frame")
NotifContainer.Size = UDim2.new(0, 250, 0, 500)
NotifContainer.Position = UDim2.new(1, -260, 0, 20)
NotifContainer.BackgroundTransparency = 1
NotifContainer.Parent = ScreenGui

local NotifList = Instance.new("UIListLayout")
NotifList.Parent = NotifContainer
NotifList.Padding = UDim.new(0, 10)

local function CustomNotify(title, text)
    if not _G.NotificationsEnabled then return end 
    
    local NotifFrame = Instance.new("Frame")
    NotifFrame.Size = UDim2.new(1, 0, 0, 60)
    NotifFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    NotifFrame.BorderSizePixel = 0
    NotifFrame.Parent = NotifContainer
    Instance.new("UICorner", NotifFrame).CornerRadius = UDim.new(0, 6)
    
    local Line = Instance.new("Frame")
    Line.Size = UDim2.new(0, 4, 1, 0)
    Line.BackgroundColor3 = Colors.TextNotif 
    Line.BorderSizePixel = 0
    Line.Parent = NotifFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -15, 0, 25)
    TitleLabel.Position = UDim2.new(0, 10, 0, 2)
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Colors.TextNotif 
    TitleLabel.Font = Enum.Font.SourceSansBold
    TitleLabel.TextSize = 15
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = NotifFrame

    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(1, -15, 0, 30)
    TextLabel.Position = UDim2.new(0, 10, 0, 25)
    TextLabel.Text = text
    TextLabel.TextColor3 = Colors.TextNotif 
    TextLabel.Font = Enum.Font.SourceSansSemibold
    TextLabel.TextSize = 14
    TextLabel.BackgroundTransparency = 1
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.Parent = NotifFrame
    
    ActiveNotifications[NotifFrame] = {Line = Line, Title = TitleLabel, Text = TextLabel}

    NotifFrame.Position = UDim2.new(1, 0, 0, 0)
    NotifFrame:TweenPosition(UDim2.new(0, 0, 0, 0), "Out", "Quart", 0.3, true)
    
    task.delay(5, function()
        if NotifFrame then
            ActiveNotifications[NotifFrame] = nil 
            NotifFrame:TweenPosition(UDim2.new(1.2, 0, 0, 0), "In", "Quart", 0.3, true, function() NotifFrame:Destroy() end)
        end
    end)
end

-- Главное базовое окно (Убрали ClipsDescendants, чтобы палитра не резалась)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 380)
MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- Внутренний контейнер для обрезки контента скролла
local ClipFrame = Instance.new("Frame")
ClipFrame.Size = UDim2.new(1, 0, 1, 0)
ClipFrame.BackgroundTransparency = 1
ClipFrame.ClipsDescendants = true
ClipFrame.Parent = MainFrame
Instance.new("UICorner", ClipFrame).CornerRadius = UDim.new(0, 8)

-- Шапка меню
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
ActiveLogoLabel = LogoLabel

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 25, 0, 25)
MinimizeBtn.Position = UDim2.new(1, -30, 0, 5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.TextSize = 14
MinimizeBtn.ZIndex = 10
MinimizeBtn.Parent = HeaderFrame
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 4)

-- Скролл-контейнер (Поправлен CanvasSize и размеры кнопок)
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, 0, 1, -40)
ScrollingFrame.Position = UDim2.new(0, 0, 0, 35)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 440)
ScrollingFrame.ScrollBarThickness = 4
ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
ScrollingFrame.Parent = ClipFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollingFrame
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Палитра цветов (Теперь спавнится ПОВЕРХ основной рамки и не багается)
local PickerPanel = Instance.new("Frame")
PickerPanel.Size = UDim2.new(0, 135, 0, 330)
PickerPanel.Position = UDim2.new(0, 245, 0, 40)
PickerPanel.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
PickerPanel.BorderSizePixel = 0
PickerPanel.Visible = false
PickerPanel.Parent = MainFrame
Instance.new("UICorner", PickerPanel).CornerRadius = UDim.new(0, 6)

local PickerTitle = Instance.new("TextLabel")
PickerTitle.Size = UDim2.new(1, 0, 0, 25)
PickerTitle.Text = "ПАЛИТРА"
PickerTitle.TextColor3 = Color3.fromRGB(180, 180, 180)
PickerTitle.Font = Enum.Font.SourceSansBold
PickerTitle.TextSize = 12
PickerTitle.BackgroundTransparency = 1
PickerTitle.Parent = PickerPanel

local GridFrame = Instance.new("Frame")
GridFrame.Size = UDim2.new(1, -10, 1, -35)
GridFrame.Position = UDim2.new(0, 5, 0, 25)
GridFrame.BackgroundTransparency = 1
GridFrame.Parent = PickerPanel

local UIGridLayout = Instance.new("UIGridLayout")
UIGridLayout.Parent = GridFrame
UIGridLayout.CellSize = UDim2.new(0, 36, 0, 25)
UIGridLayout.CellPadding = UDim2.new(0, 6, 0, 6)
UIGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local currentActiveKey = nil

local function ClosePicker()
    currentActiveKey = nil
    PickerPanel.Visible = false
    MainFrame:TweenSize(UDim2.new(0, 240, 0, 380), "In", "Quart", 0.2, true)
end

local function OpenPicker(colorKey)
    if currentActiveKey == colorKey then ClosePicker() else
        currentActiveKey = colorKey
        PickerPanel.Visible = true
        MainFrame:TweenSize(UDim2.new(0, 390, 0, 380), "Out", "Quart", 0.2, true)
    end
end

local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MinimizeBtn.Text = "+"
        ClosePicker() 
        ClipFrame:TweenSize(UDim2.new(1, 0, 0, 35), "Out", "Quart", 0.2, true)
        MainFrame:TweenSize(UDim2.new(0, 240, 0, 35), "Out", "Quart", 0.2, true)
    else
        MinimizeBtn.Text = "—"
        ClipFrame:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Quart", 0.2, true)
        MainFrame:TweenSize(UDim2.new(0, 240, 0, 380), "Out", "Quart", 0.2, true)
    end
end)

for _, color in pairs(ColorPalette) do
    local cBtn = Instance.new("TextButton")
    cBtn.Text = ""
    cBtn.BackgroundColor3 = color
    cBtn.Parent = GridFrame
    Instance.new("UICorner", cBtn).CornerRadius = UDim.new(1, 0)
    cBtn.MouseButton1Click:Connect(function()
        if currentActiveKey then 
            Colors[currentActiveKey] = color
            if currentActiveKey == "TextNotif" then
                if ActiveLogoLabel then ActiveLogoLabel.TextColor3 = color end
                for _, data in pairs(ActiveNotifications) do
                    if data.Line then data.Line.BackgroundColor3 = color end
                    if data.Title then data.Title.TextColor3 = color end
                    if data.Text then data.Text.TextColor3 = color end
                end
            end
            ClosePicker() 
        end
    end)
end

local function CreateEspControl(name, colorKey)
    local RowFrame = Instance.new("Frame")
    RowFrame.Size = UDim2.new(0, 210, 0, 36)
    RowFrame.BackgroundTransparency = 1
    RowFrame.Parent = ScrollingFrame
    
    local MainBtn = Instance.new("TextButton")
    MainBtn.Size = UDim2.new(0, 165, 0, 36)
    MainBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
    MainBtn.Text = name .. ": ВЫКЛ"
    MainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MainBtn.Font = Enum.Font.SourceSansBold
    MainBtn.TextSize = 13
    MainBtn.Parent = RowFrame
    Instance.new("UICorner", MainBtn).CornerRadius = UDim.new(0, 6)

    local GearBtn = Instance.new("TextButton")
    GearBtn.Size = UDim2.new(0, 36, 0, 36)
    GearBtn.Position = UDim2.new(0, 172, 0, 0)
    GearBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    GearBtn.Text = "⚙️"
    GearBtn.TextSize = 14
    GearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    GearBtn.Parent = RowFrame
    Instance.new("UICorner", GearBtn).CornerRadius = UDim.new(0, 6)

    GearBtn.MouseButton1Click:Connect(function() 
        if not isMinimized then OpenPicker(colorKey) end 
    end)
    return MainBtn
end

local DoorButton = CreateEspControl("ESP ДВЕРЕЙ", "Door")
local MonsterButton = CreateEspControl("ESP МОНСТРОВ", "Monster")
local ItemButton = CreateEspControl("ESP ПРЕДМЕТОВ", "Item")
local HidingButton = CreateEspControl("ESP УКРЫТИЙ", "Hiding")
local NotifToggleButton = CreateEspControl("УВЕДОМЛЕНИЯ", "TextNotif")

-- Секция анти-существ
local A90Button = CreateEspControl("АНТИ А-90", "AntiA90")
local ScreechButton = CreateEspControl("АНТИ СКРИЧ", "AntiScreech")
local SnareButton = CreateEspControl("АНТИ КАПКАН", "AntiSnare")
local TimothyButton = CreateEspControl("АНТИ ТИМОТИ", "AntiTimothy")
local GiggleButton = CreateEspControl("АНТИ ГИГГЛ", "AntiGiggle")

NotifToggleButton.Text = "УВЕДОМЛЕНИЯ: ВКЛ"
NotifToggleButton.BackgroundColor3 = Color3.fromRGB(40, 150, 40)

-- =============================================================================
-- 2. ESP ENGINE
-- =============================================================================
local function ApplyESP(object, color, text, id)
    if not object then return end
    local billboard = object:FindFirstChild("LocalText_" .. id)
    local highlight = object:FindFirstChild("LocalHighlight_" .. id)
    
    if billboard and highlight then
        local label = billboard:FindFirstChildOfClass("TextLabel")
        if label then label.Text = text label.TextColor3 = color end
        highlight.FillColor = color
        return 
    end
    
    local highlightInstance = Instance.new("Highlight")
    highlightInstance.Name = "LocalHighlight_" .. id
    highlightInstance.FillColor = color
    highlightInstance.FillTransparency = 0.6
    highlightInstance.OutlineColor = Color3.fromRGB(255, 255, 255)
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

-- Циклы сканирования комнат и предметов
task.spawn(function()
    while task.wait(0.4) do
        pcall(function()
            local rooms = workspace:FindFirstChild("CurrentRooms")
            local currentRoomNum = GetCurrentRoomNumber()
            if rooms then
                for _, room in pairs(rooms:GetChildren()) do
                    local roomNum = tonumber(room.Name) or 0
                    local door = room:FindFirstChild("Door")
                    if door then
                        local actualDoor = door:FindFirstChild("Door") or door
                        if roomNum < currentRoomNum then
                            RemoveESP(actualDoor, "Door")
                        elseif _G.DoorEspEnabled then
                            local correctedName = tostring(roomNum + 1)
                            local isLocked = door:FindFirstChild("Lock") or door:FindFirstChild("KeyLock")
                            local espColor = Colors.Door
                            local espText = "🚪 Дверь " .. correctedName
                            if isLocked then
                                espColor = Color3.fromRGB(255, 50, 50)
                                espText = "🔒 Закрытая Дверь " .. correctedName
                            end
                            ApplyESP(actualDoor, espColor, espText, "Door")
                        else RemoveESP(actualDoor, "Door") end
                    end
                end
            end
        end)
    end
end)

task.spawn(function()
    while task.wait(0.3) do
        pcall(function()
            if _G.MonsterEspEnabled then
                for _, child in pairs(workspace:GetChildren()) do
                    if MonsterNames[child.Name] then ApplyESP(child, Colors.Monster, "⚠️ " .. MonsterNames[child.Name], "Monster") end
                end
            else
                for _, child in pairs(workspace:GetChildren()) do RemoveESP(child, "Monster") end
            end
        end)
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local rooms = workspace:FindFirstChild("CurrentRooms")
            local currentRoomNum = GetCurrentRoomNumber()
            if rooms then
                for _, room in pairs(rooms:GetChildren()) do
                    local roomNum = tonumber(room.Name) or 0
                    for _, asset in pairs(room:GetDescendants()) do
                        if roomNum < currentRoomNum then
                            RemoveESP(asset, "Item")
                        elseif _G.ItemEspEnabled then
                            if asset.Name == "KeyObtain" then ApplyESP(asset, Colors.Item, "🔑 Ключ", "Item")
                            elseif asset.Name == "LeverForGate" then ApplyESP(asset, Colors.Item, "⚙️ Рычаг", "Item")
                            elseif asset.Name == "LiveHintBook" then ApplyESP(asset, Colors.Item, "📘 Книга", "Item")
                            elseif asset.Name == "GoldPile" then ApplyESP(asset, Colors.Item, "💰 Золото", "Item")
                            elseif asset.Name == "LiveFuseElement" then ApplyESP(asset, Colors.Item, "🔋 Предохранитель", "Item")
                            elseif asset.Name == "ChestBox" or asset.Name == "ChestBoxLocked" then
                                local label = asset.Name == "ChestBoxLocked" and "🔒 Закрытый Сундук" or "📦 Сундук"
                                ApplyESP(asset, Colors.Item, label, "Item")
                            end
                        else RemoveESP(asset, "Item") end
                    end
                end
            end
        end)
    end
end)

task.spawn(function()
    while task.wait(0.6) do
        pcall(function()
            local rooms = workspace:FindFirstChild("CurrentRooms")
            local currentRoomNum = GetCurrentRoomNumber()
            if rooms then
                for _, room in pairs(rooms:GetChildren()) do
                    local roomNum = tonumber(room.Name) or 0
                    for _, asset in pairs(room:GetDescendants()) do
                        if roomNum < currentRoomNum then
                            RemoveESP(asset, "Hiding")
                        elseif _G.HidingEspEnabled then
                            if asset.Name == "Wardrobe" then ApplyESP(asset, Colors.Hiding, "🚪 Шкаф", "Hiding")
                            elseif asset.Name == "Bed" then ApplyESP(asset, Colors.Hiding, "🛏️ Кровать", "Hiding") end
                        else RemoveESP(asset, "Hiding") end
                    end
                end
            end
        end)
    end
end)

workspace.ChildAdded:Connect(function(child)
    pcall(function()
        if MonsterNames[child.Name] then
            CustomNotify("🚨 ОБНАРУЖЕН МОНСТР!", "В игру зашел: " .. MonsterNames[child.Name])
            if _G.MonsterEspEnabled then
                task.wait(0.1)
                ApplyESP(child, Colors.Monster, "⚠️ " .. MonsterNames[child.Name], "Monster")
            end
        end
    end)
end)

-- =============================================================================
-- 3. КНОПКИ И ПЕРЕКЛЮЧЕНИЕ СОСТОЯНИЙ ХУКА
-- =============================================================================
local function ToggleState(btn, varName, isBypass, textOn, textOff)
    if isBypass then
        _G.Bypasses[varName] = not _G.Bypasses[varName]
        if varName == "A90" then _G.Bypasses["A-90"] = _G.Bypasses["A90"] end -- Синхрон для А-90
        
        if _G.Bypasses[varName] then
            btn.Text = textOn
            btn.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
            CustomNotify("BYPASS", varName .. " заблокирован!")
        else
            btn.Text = textOff
            btn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
        end
    else
        _G[varName] = not _G[varName]
        if _G[varName] then
            btn.Text = textOn
            btn.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
        else
            btn.Text = textOff
            btn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
        end
    end
end

DoorButton.MouseButton1Click:Connect(function() ToggleState(DoorButton, "DoorEspEnabled", false, "ESP ДВЕРЕЙ: ВКЛ", "ESP ДВЕРЕЙ: ВЫКЛ") end)
MonsterButton.MouseButton1Click:Connect(function() ToggleState(MonsterButton, "MonsterEspEnabled", false, "ESP МОНСТРОВ: ВКЛ", "ESP МОНСТРОВ: ВЫКЛ") end)
ItemButton.MouseButton1Click:Connect(function() ToggleState(ItemButton, "ItemEspEnabled", false, "ESP ПРЕДМЕТОВ: ВКЛ", "ESP ПРЕДМЕТОВ: ВЫКЛ") end)
HidingButton.MouseButton1Click:Connect(function() ToggleState(HidingButton, "HidingEspEnabled", false, "ESP УКРЫТИЙ: ВКЛ", "ESP УКРЫТИЙ: ВЫКЛ") end)
NotifToggleButton.MouseButton1Click:Connect(function() ToggleState(NotifToggleButton, "NotificationsEnabled", false, "УВЕДОМЛЕНИЯ: ВКЛ", "УВЕДОМЛЕНИЯ: ВЫКЛ") end)

-- Переключатели хуков для существ
A90Button.MouseButton1Click:Connect(function() ToggleState(A90Button, "A90", true, "АНТИ А-90: ВКЛ", "АНТИ А-90: ВЫКЛ") end)
ScreechButton.MouseButton1Click:Connect(function() ToggleState(ScreechButton, "Screech", true, "АНТИ СКРИЧ: ВКЛ", "АНТИ СКРИЧ: ВЫКЛ") end)
SnareButton.MouseButton1Click:Connect(function() ToggleState(SnareButton, "Snare", true, "АНТИ КАПКАН: ВКЛ", "АНТИ КАПКАН: ВЫКЛ") end)
TimothyButton.MouseButton1Click:Connect(function() ToggleState(TimothyButton, "Timothy", true, "АНТИ ТИМОТИ: ВКЛ", "АНТИ ТИМОТИ: ВЫКЛ") end)
GiggleButton.MouseButton1Click:Connect(function() ToggleState(GiggleButton, "Giggle", true, "АНТИ ГИГГЛ: ВКЛ", "АНТИ ГИГГЛ: ВЫКЛ") end)

CustomNotify("SYSTEM", "Ocel-hub v15.0 успешно запущен. Хук активен!")    AntiGiggle = Color3.fromRGB(0, 150, 255)
}

local ColorPalette = {
    Color3.fromRGB(0, 255, 100), Color3.fromRGB(255, 50, 50), Color3.fromRGB(255, 200, 0),
    Color3.fromRGB(0, 180, 255), Color3.fromRGB(255, 0, 255), Color3.fromRGB(255, 255, 255),
    Color3.fromRGB(255, 128, 0), Color3.fromRGB(170, 0, 255), Color3.fromRGB(0, 255, 255),
    Color3.fromRGB(150, 255, 0), Color3.fromRGB(255, 100, 150), Color3.fromRGB(0, 50, 200)
}

local MonsterNames = {
    ["RushMoving"] = "Раш 🏃‍♂️", ["AmbushMoving"] = "Амбуш ⚡", ["Eyes"] = "Глаза 👀",
    ["SeekMoving"] = "Сик 👁️", ["Figure"] = "Фигура 👤", ["A60"] = "A-60 🔴",
    ["A120"] = "A-120 ⭕", ["GiggleCeiling"] = "Гиггл 💢", ["Grumble"] = "Грамбл 👾"
}

-- Универсальная функция обхода из твоего сурса
local function ToggleRemote(name, state)
    if not Remotes then return end
    local remote = Remotes:FindFirstChild(name) or _G[name .. "_Storage"]
    if state then
        if remote then
            _G[name .. "_Storage"] = remote
            remote.Parent = nil
        end
    else
        local storage = _G[name .. "_Storage"]
        if storage then
            storage.Parent = Remotes
        end
    end
end

local function GetCurrentRoomNumber()
    local player = game:GetService("Players").LocalPlayer
    if player and player:GetAttribute("CurrentRoom") then
        return tonumber(player:GetAttribute("CurrentRoom"))
    end
    return 0
end

local ActiveLogoLabel = nil
local ActiveNotifications = {} 

-- =============================================================================
-- 1. ИНТЕРФЕЙС И УВЕДОМЛЕНИЯ
-- =============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DoorsLocalMegaHubFinal"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

local NotifContainer = Instance.new("Frame")
NotifContainer.Size = UDim2.new(0, 250, 0, 500)
NotifContainer.Position = UDim2.new(1, -260, 0, 20)
NotifContainer.BackgroundTransparency = 1
NotifContainer.Parent = ScreenGui

local NotifList = Instance.new("UIListLayout")
NotifList.Parent = NotifContainer
NotifList.Padding = UDim.new(0, 10)

local function CustomNotify(title, text)
    if not _G.NotificationsEnabled then return end 
    
    local NotifFrame = Instance.new("Frame")
    NotifFrame.Size = UDim2.new(1, 0, 0, 60)
    NotifFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    NotifFrame.BorderSizePixel = 0
    NotifFrame.Parent = NotifContainer
    Instance.new("UICorner", NotifFrame).CornerRadius = UDim.new(0, 6)
    
    local Line = Instance.new("Frame")
    Line.Size = UDim2.new(0, 4, 1, 0)
    Line.BackgroundColor3 = Colors.TextNotif 
    Line.BorderSizePixel = 0
    Line.Parent = NotifFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -15, 0, 25)
    TitleLabel.Position = UDim2.new(0, 10, 0, 2)
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Colors.TextNotif 
    TitleLabel.Font = Enum.Font.SourceSansBold
    TitleLabel.TextSize = 15
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = NotifFrame

    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(1, -15, 0, 30)
    TextLabel.Position = UDim2.new(0, 10, 0, 25)
    TextLabel.Text = text
    TextLabel.TextColor3 = Colors.TextNotif 
    TextLabel.Font = Enum.Font.SourceSansSemibold
    TextLabel.TextSize = 14
    TextLabel.BackgroundTransparency = 1
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.Parent = NotifFrame
    
    ActiveNotifications[NotifFrame] = {Line = Line, Title = TitleLabel, Text = TextLabel}

    NotifFrame.Position = UDim2.new(1, 0, 0, 0)
    NotifFrame:TweenPosition(UDim2.new(0, 0, 0, 0), "Out", "Quart", 0.3, true)
    
    task.delay(5, function()
        if NotifFrame then
            ActiveNotifications[NotifFrame] = nil 
            NotifFrame:TweenPosition(UDim2.new(1.2, 0, 0, 0), "In", "Quart", 0.3, true, function() NotifFrame:Destroy() end)
        end
    end)
end

-- Главное окно меню (Увеличена высота под новые байпасы)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 440)
MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- Шапка меню
local HeaderFrame = Instance.new("Frame")
HeaderFrame.Size = UDim2.new(1, 0, 0, 35)
HeaderFrame.BackgroundTransparency = 1
HeaderFrame.Parent = MainFrame

-- Надпись Ocel-hub
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
ActiveLogoLabel = LogoLabel

-- Кнопка Свернуть/Развернуть
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 25, 0, 25)
MinimizeBtn.Position = UDim2.new(1, -30, 0, 5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.TextSize = 14
MinimizeBtn.ZIndex = 10
MinimizeBtn.Parent = HeaderFrame
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 4)

-- Контейнер для кнопок (Прокрутка, чтобы меню не взрывалось)
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, 0, 1, -40)
ScrollingFrame.Position = UDim2.new(0, 0, 0, 35)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 430) -- Размер контента
ScrollingFrame.ScrollBarThickness = 3
ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
ScrollingFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollingFrame
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Встроенная палитра цветов
local PickerPanel = Instance.new("Frame")
PickerPanel.Size = UDim2.new(0, 135, 0, 390)
PickerPanel.Position = UDim2.new(0, 245, 0, 40)
PickerPanel.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
PickerPanel.BorderSizePixel = 0
PickerPanel.Visible = false
PickerPanel.Parent = MainFrame
Instance.new("UICorner", PickerPanel).CornerRadius = UDim.new(0, 6)

local PickerTitle = Instance.new("TextLabel")
PickerTitle.Size = UDim2.new(1, 0, 0, 25)
PickerTitle.Text = "ПАЛИТРА"
PickerTitle.TextColor3 = Color3.fromRGB(180, 180, 180)
PickerTitle.Font = Enum.Font.SourceSansBold
PickerTitle.TextSize = 12
PickerTitle.BackgroundTransparency = 1
PickerTitle.Parent = PickerPanel

local GridFrame = Instance.new("Frame")
GridFrame.Size = UDim2.new(1, -10, 1, -35)
GridFrame.Position = UDim2.new(0, 5, 0, 25)
GridFrame.BackgroundTransparency = 1
GridFrame.Parent = PickerPanel

local UIGridLayout = Instance.new("UIGridLayout")
UIGridLayout.Parent = GridFrame
UIGridLayout.CellSize = UDim2.new(0, 36, 0, 25)
UIGridLayout.CellPadding = UDim2.new(0, 6, 0, 6)
UIGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local currentActiveKey = nil

local function ClosePicker()
    currentActiveKey = nil
    PickerPanel.Visible = false
    MainFrame:TweenSize(UDim2.new(0, 240, 0, 440), "In", "Quart", 0.25, true)
end

local function OpenPicker(colorKey)
    if currentActiveKey == colorKey then ClosePicker() else
        currentActiveKey = colorKey
        PickerPanel.Visible = true
        MainFrame:TweenSize(UDim2.new(0, 390, 0, 440), "Out", "Quart", 0.25, true)
    end
end

-- Логика кнопки Свернуть
local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MinimizeBtn.Text = "+"
        ClosePicker() 
        MainFrame:TweenSize(UDim2.new(0, 240, 0, 35), "Out", "Quart", 0.25, true)
    else
        MinimizeBtn.Text = "—"
        MainFrame:TweenSize(UDim2.new(0, 240, 0, 440), "Out", "Quart", 0.25, true)
    end
end)

for _, color in pairs(ColorPalette) do
    local cBtn = Instance.new("TextButton")
    cBtn.Text = ""
    cBtn.BackgroundColor3 = color
    cBtn.Parent = GridFrame
    Instance.new("UICorner", cBtn).CornerRadius = UDim.new(1, 0)
    cBtn.MouseButton1Click:Connect(function()
        if currentActiveKey then 
            Colors[currentActiveKey] = color
            if currentActiveKey == "TextNotif" then
                if ActiveLogoLabel then ActiveLogoLabel.TextColor3 = color end
                for _, data in pairs(ActiveNotifications) do
                    if data.Line then data.Line.BackgroundColor3 = color end
                    if data.Title then data.Title.TextColor3 = color end
                    if data.Text then data.Text.TextColor3 = color end
                end
            end
            ClosePicker() 
        end
    end)
end

-- Конструктор строк управления
local function CreateEspControl(name, colorKey)
    local RowFrame = Instance.new("Frame")
    RowFrame.Size = UDim2.new(0, 210, 0, 36)
    RowFrame.BackgroundTransparency = 1
    RowFrame.Parent = ScrollingFrame
    
    local MainBtn = Instance.new("TextButton")
    MainBtn.Size = UDim2.new(0, 165, 0, 36)
    MainBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
    MainBtn.Text = name .. ": ВЫКЛ"
    MainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MainBtn.Font = Enum.Font.SourceSansBold
    MainBtn.TextSize = 13
    MainBtn.Parent = RowFrame
    Instance.new("UICorner", MainBtn).CornerRadius = UDim.new(0, 6)

    local GearBtn = Instance.new("TextButton")
    GearBtn.Size = UDim2.new(0, 36, 0, 36)
    GearBtn.Position = UDim2.new(0, 172, 0, 0)
    GearBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    GearBtn.Text = "⚙️"
    GearBtn.TextSize = 14
    GearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    GearBtn.Parent = RowFrame
    Instance.new("UICorner", GearBtn).CornerRadius = UDim.new(0, 6)

    GearBtn.MouseButton1Click:Connect(function() 
        if not isMinimized then OpenPicker(colorKey) end 
    end)
    return MainBtn
end

local DoorButton = CreateEspControl("ESP ДВЕРЕЙ", "Door")
local MonsterButton = CreateEspControl("ESP МОНСТРОВ", "Monster")
local ItemButton = CreateEspControl("ESP ПРЕДМЕТОВ", "Item")
local HidingButton = CreateEspControl("ESP УКРЫТИЙ", "Hiding")
local NotifToggleButton = CreateEspControl("УВЕДОМЛЕНИЯ", "TextNotif")

-- Секция Байпасов
local A90Button = CreateEspControl("АНТИ А-90", "AntiA90")
local ScreechButton = CreateEspControl("АНТИ СКРИЧ", "AntiScreech")
local SnareButton = CreateEspControl("АНТИ КАПКАН", "AntiSnare")
local TimothyButton = CreateEspControl("АНТИ ТИМОТИ", "AntiTimothy")
local GiggleButton = CreateEspControl("АНТИ ГИГГЛ", "AntiGiggle")

NotifToggleButton.Text = "УВЕДОМЛЕНИЯ: ВКЛ"
NotifToggleButton.BackgroundColor3 = Color3.fromRGB(40, 150, 40)

-- =============================================================================
-- 2. ESP ENGINE
-- =============================================================================
local function ApplyESP(object, color, text, id)
    if not object then return end
    local billboard = object:FindFirstChild("LocalText_" .. id)
    local highlight = object:FindFirstChild("LocalHighlight_" .. id)
    
    if billboard and highlight then
        local label = billboard:FindFirstChildOfClass("TextLabel")
        if label then 
            label.Text = text
            label.TextColor3 = color 
        end
        highlight.FillColor = color
        return 
    end
    
    local highlightInstance = Instance.new("Highlight")
    highlightInstance.Name = "LocalHighlight_" .. id
    highlightInstance.FillColor = color
    highlightInstance.FillTransparency = 0.6
    highlightInstance.OutlineColor = Color3.fromRGB(255, 255, 255)
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

-- =============================================================================
-- 3. ЦИКЛЫ СКАНИРОВАНИЯ И АВТО-ОЧИСТКИ
-- =============================================================================

task.spawn(function()
    while task.wait(0.4) do
        pcall(function()
            local rooms = workspace:FindFirstChild("CurrentRooms")
            local currentRoomNum = GetCurrentRoomNumber()
            if rooms then
                for _, room in pairs(rooms:GetChildren()) do
                    local roomNum = tonumber(room.Name) or 0
                    local door = room:FindFirstChild("Door")
                    if door then
                        local actualDoor = door:FindFirstChild("Door") or door
                        if roomNum < currentRoomNum then
                            RemoveESP(actualDoor, "Door")
                        elseif _G.DoorEspEnabled then
                            local correctedName = tostring(roomNum + 1)
                            local isLocked = door:FindFirstChild("Lock") or door:FindFirstChild("KeyLock")
                            local espColor = Colors.Door
                            local espText = "🚪 Дверь " .. correctedName
                            if isLocked then
                                espColor = Color3.fromRGB(255, 50, 50)
                                espText = "🔒 Закрытая Дверь " .. correctedName
                            end
                            ApplyESP(actualDoor, espColor, espText, "Door")
                        else RemoveESP(actualDoor, "Door") end
                    end
                end
            end
        end)
    end
end)

task.spawn(function()
    while task.wait(0.3) do
        pcall(function()
            if _G.MonsterEspEnabled then
                for _, child in pairs(workspace:GetChildren()) do
                    if MonsterNames[child.Name] then ApplyESP(child, Colors.Monster, "⚠️ " .. MonsterNames[child.Name], "Monster") end
                end
            else
                for _, child in pairs(workspace:GetChildren()) do RemoveESP(child, "Monster") end
            end
        end)
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local rooms = workspace:FindFirstChild("CurrentRooms")
            local currentRoomNum = GetCurrentRoomNumber()
            if rooms then
                for _, room in pairs(rooms:GetChildren()) do
                    local roomNum = tonumber(room.Name) or 0
                    for _, asset in pairs(room:GetDescendants()) do
                        if roomNum < currentRoomNum then
                            RemoveESP(asset, "Item")
                        elseif _G.ItemEspEnabled then
                            if asset.Name == "KeyObtain" then ApplyESP(asset, Colors.Item, "🔑 Ключ", "Item")
                            elseif asset.Name == "LeverForGate" then ApplyESP(asset, Colors.Item, "⚙️ Рычаг", "Item")
                            elseif asset.Name == "LiveHintBook" then ApplyESP(asset, Colors.Item, "📘 Книга", "Item")
                            elseif asset.Name == "GoldPile" then ApplyESP(asset, Colors.Item, "💰 Золото", "Item")
                            elseif asset.Name == "LiveFuseElement" then ApplyESP(asset, Colors.Item, "🔋 Предохранитель", "Item")
                            elseif asset.Name == "ChestBox" or asset.Name == "ChestBoxLocked" then
                                local label = asset.Name == "ChestBoxLocked" and "🔒 Закрытый Сундук" or "📦 Сундук"
                                ApplyESP(asset, Colors.Item, label, "Item")
                            end
                        else RemoveESP(asset, "Item") end
                    end
                end
            end
        end)
    end
end)

task.spawn(function()
    while task.wait(0.6) do
        pcall(function()
            local rooms = workspace:FindFirstChild("CurrentRooms")
            local currentRoomNum = GetCurrentRoomNumber()
            if rooms then
                for _, room in pairs(rooms:GetChildren()) do
                    local roomNum = tonumber(room.Name) or 0
                    for _, asset in pairs(room:GetDescendants()) do
                        if roomNum < currentRoomNum then
                            RemoveESP(asset, "Hiding")
                        elseif _G.HidingEspEnabled then
                            if asset.Name == "Wardrobe" then ApplyESP(asset, Colors.Hiding, "🚪 Шкаф", "Hiding")
                            elseif asset.Name == "Bed" then ApplyESP(asset, Colors.Hiding, "🛏️ Кровать", "Hiding") end
                        else RemoveESP(asset, "Hiding") end
                    end
                end
            end
        end)
    end
end)

workspace.ChildAdded:Connect(function(child)
    pcall(function()
        if MonsterNames[child.Name] then
            CustomNotify("🚨 ОБНАРУЖЕН МОНСТР!", "В игру зашел: " .. MonsterNames[child.Name])
            if _G.MonsterEspEnabled then
                task.wait(0.1)
                ApplyESP(child, Colors.Monster, "⚠️ " .. MonsterNames[child.Name], "Monster")
            end
        end
    end)
end)

-- =============================================================================
-- 4. УПРАВЛЕНИЕ КНОПКАМИ И БАЙПАСАМИ
-- =============================================================================
local function ToggleState(btn, flagName, textOn, textOff)
    _G[flagName] = not _G[flagName]
    if _G[flagName] then
        btn.Text = textOn
        btn.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
    else
        btn.Text = textOff
        btn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
    end
end

DoorButton.MouseButton1Click:Connect(function() ToggleState(DoorButton, "DoorEspEnabled", "ESP ДВЕРЕЙ: ВКЛ", "ESP ДВЕРЕЙ: ВЫКЛ") end)
MonsterButton.MouseButton1Click:Connect(function() ToggleState(MonsterButton, "MonsterEspEnabled", "ESP МОНСТРОВ: ВКЛ", "ESP МОНСТРОВ: ВЫКЛ") end)
ItemButton.MouseButton1Click:Connect(function() ToggleState(ItemButton, "ItemEspEnabled", "ESP ПРЕДМЕТОВ: ВКЛ", "ESP ПРЕДМЕТОВ: ВЫКЛ") end)
HidingButton.MouseButton1Click:Connect(function() ToggleState(HidingButton, "HidingEspEnabled", "ESP УКРЫТИЙ: ВКЛ", "ESP УКРЫТИЙ: ВЫКЛ") end)
NotifToggleButton.MouseButton1Click:Connect(function() ToggleState(NotifToggleButton, "NotificationsEnabled", "УВЕДОМЛЕНИЯ: ВКЛ", "УВЕДОМЛЕНИЯ: ВЫКЛ") end)

-- Клики по кнопкам байпасов
A90Button.MouseButton1Click:Connect(function()
    ToggleState(A90Button, "AntiA90Enabled", "АНТИ А-90: ВКЛ", "АНТИ А-90: ВЫКЛ")
    ToggleRemote("A90", _G.AntiA90Enabled)
    ToggleRemote("A-90", _G.AntiA90Enabled)
    if _G.AntiA90Enabled then CustomNotify("BYPASS", "А-90 успешно отключен!") end
end)

ScreechButton.MouseButton1Click:Connect(function()
    ToggleState(ScreechButton, "AntiScreechEnabled", "АНТИ СКРИЧ: ВКЛ", "АНТИ СКРИЧ: ВЫКЛ")
    ToggleRemote("Screech", _G.AntiScreechEnabled)
    if _G.AntiScreechEnabled then CustomNotify("BYPASS", "Скрич успешно отключен!") end
end)

SnareButton.MouseButton1Click:Connect(function()
    ToggleState(SnareButton, "AntiSnareEnabled", "АНТИ КАПКАН: ВКЛ", "АНТИ КАПКАН: ВЫКЛ")
    ToggleRemote("Snare", _G.AntiSnareEnabled)
    if _G.AntiSnareEnabled then CustomNotify("BYPASS", "Капканы (Snare) отключены!") end
end)

TimothyButton.MouseButton1Click:Connect(function()
    ToggleState(TimothyButton, "AntiTimothyEnabled", "АНТИ ТИМОТИ: ВКЛ", "АНТИ ТИМОТИ: ВЫКЛ")
    ToggleRemote("Timothy", _G.AntiTimothyEnabled)
    if _G.AntiTimothyEnabled then CustomNotify("BYPASS", "Тимоти успешно отключен!") end
end)

GiggleButton.MouseButton1Click:Connect(function()
    ToggleState(GiggleButton, "AntiGiggleEnabled", "АНТИ ГИГГЛ: ВКЛ", "АНТИ ГИГГЛ: ВЫКЛ")
    ToggleRemote("Giggle", _G.AntiGiggleEnabled)
    if _G.AntiGiggleEnabled then CustomNotify("BYPASS", "Гиггл больше не нападет!") end
end)

CustomNotify("SYSTEM", "Ocel-hub v14.0 загружен! Все байпасы готовы.")local function GetCurrentRoomNumber()
    local player = game:GetService("Players").LocalPlayer
    if player and player:GetAttribute("CurrentRoom") then
        return tonumber(player:GetAttribute("CurrentRoom"))
    end
    return 0
end

local ActiveLogoLabel = nil
local ActiveNotifications = {} -- Таблица для хранения ссылок на активные плашки

-- =============================================================================
-- 1. ИНТЕРФЕЙС И УВЕДОМЛЕНИЯ
-- =============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DoorsLocalMegaHubFinal"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

local NotifContainer = Instance.new("Frame")
NotifContainer.Size = UDim2.new(0, 250, 0, 500)
NotifContainer.Position = UDim2.new(1, -260, 0, 20)
NotifContainer.BackgroundTransparency = 1
NotifContainer.Parent = ScreenGui

local NotifList = Instance.new("UIListLayout")
NotifList.Parent = NotifContainer
NotifList.Padding = UDim.new(0, 10)

local function CustomNotify(title, text)
    if not _G.NotificationsEnabled then return end 
    
    local NotifFrame = Instance.new("Frame")
    NotifFrame.Size = UDim2.new(1, 0, 0, 60)
    NotifFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    NotifFrame.BorderSizePixel = 0
    NotifFrame.Parent = NotifContainer
    Instance.new("UICorner", NotifFrame).CornerRadius = UDim.new(0, 6)
    
    local Line = Instance.new("Frame")
    Line.Size = UDim2.new(0, 4, 1, 0)
    Line.BackgroundColor3 = Colors.TextNotif 
    Line.BorderSizePixel = 0
    Line.Parent = NotifFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -15, 0, 25)
    TitleLabel.Position = UDim2.new(0, 10, 0, 2)
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Colors.TextNotif 
    TitleLabel.Font = Enum.Font.SourceSansBold
    TitleLabel.TextSize = 15
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = NotifFrame

    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(1, -15, 0, 30)
    TextLabel.Position = UDim2.new(0, 10, 0, 25)
    TextLabel.Text = text
    TextLabel.TextColor3 = Colors.TextNotif 
    TextLabel.Font = Enum.Font.SourceSansSemibold
    TextLabel.TextSize = 14
    TextLabel.BackgroundTransparency = 1
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.Parent = NotifFrame
    
    -- Привязываем элементы к этой плашке
    ActiveNotifications[NotifFrame] = {Line = Line, Title = TitleLabel, Text = TextLabel}

    NotifFrame.Position = UDim2.new(1, 0, 0, 0)
    NotifFrame:TweenPosition(UDim2.new(0, 0, 0, 0), "Out", "Quart", 0.3, true)
    
    task.delay(5, function()
        if NotifFrame then
            ActiveNotifications[NotifFrame] = nil 
            NotifFrame:TweenPosition(UDim2.new(1.2, 0, 0, 0), "In", "Quart", 0.3, true, function() NotifFrame:Destroy() end)
        end
    end)
end

-- Главное окно меню
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 250)
MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- Шапка меню
local HeaderFrame = Instance.new("Frame")
HeaderFrame.Size = UDim2.new(1, 0, 0, 35)
HeaderFrame.BackgroundTransparency = 1
HeaderFrame.Parent = MainFrame

-- Надпись Ocel-hub
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
ActiveLogoLabel = LogoLabel

-- Кнопка Свернуть/Развернуть
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 25, 0, 25)
MinimizeBtn.Position = UDim2.new(1, -30, 0, 5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.TextSize = 14
MinimizeBtn.ZIndex = 10
MinimizeBtn.Parent = HeaderFrame
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 4)

-- Контейнер для кнопок
local ButtonContainer = Instance.new("Frame")
ButtonContainer.Size = UDim2.new(0, 240, 0, 210)
ButtonContainer.Position = UDim2.new(0, 0, 0, 35)
ButtonContainer.BackgroundTransparency = 1
ButtonContainer.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ButtonContainer
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Встроенная палитра цветов
local PickerPanel = Instance.new("Frame")
PickerPanel.Size = UDim2.new(0, 135, 0, 200)
PickerPanel.Position = UDim2.new(0, 245, 0, 40)
PickerPanel.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
PickerPanel.BorderSizePixel = 0
PickerPanel.Visible = false
PickerPanel.Parent = MainFrame
Instance.new("UICorner", PickerPanel).CornerRadius = UDim.new(0, 6)

local PickerTitle = Instance.new("TextLabel")
PickerTitle.Size = UDim2.new(1, 0, 0, 25)
PickerTitle.Text = "ПАЛИТРА"
PickerTitle.TextColor3 = Color3.fromRGB(180, 180, 180)
PickerTitle.Font = Enum.Font.SourceSansBold
PickerTitle.TextSize = 12
PickerTitle.BackgroundTransparency = 1
PickerTitle.Parent = PickerPanel

local GridFrame = Instance.new("Frame")
GridFrame.Size = UDim2.new(1, -10, 1, -35)
GridFrame.Position = UDim2.new(0, 5, 0, 25)
GridFrame.BackgroundTransparency = 1
GridFrame.Parent = PickerPanel

local UIGridLayout = Instance.new("UIGridLayout")
UIGridLayout.Parent = GridFrame
UIGridLayout.CellSize = UDim2.new(0, 36, 0, 25)
UIGridLayout.CellPadding = UDim2.new(0, 6, 0, 6)
UIGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local currentActiveKey = nil

local function ClosePicker()
    currentActiveKey = nil
    PickerPanel.Visible = false
    MainFrame:TweenSize(UDim2.new(0, 240, 0, 250), "In", "Quart", 0.25, true)
end

local function OpenPicker(colorKey)
    if currentActiveKey == colorKey then ClosePicker() else
        currentActiveKey = colorKey
        PickerPanel.Visible = true
        MainFrame:TweenSize(UDim2.new(0, 390, 0, 250), "Out", "Quart", 0.25, true)
    end
end

-- Логика кнопки Свернуть
local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MinimizeBtn.Text = "+"
        ClosePicker() 
        MainFrame:TweenSize(UDim2.new(0, 240, 0, 35), "Out", "Quart", 0.25, true)
    else
        MinimizeBtn.Text = "—"
        MainFrame:TweenSize(UDim2.new(0, 240, 0, 250), "Out", "Quart", 0.25, true)
    end
end)

for _, color in pairs(ColorPalette) do
    local cBtn = Instance.new("TextButton")
    cBtn.Text = ""
    cBtn.BackgroundColor3 = color
    cBtn.Parent = GridFrame
    Instance.new("UICorner", cBtn).CornerRadius = UDim.new(1, 0)
    cBtn.MouseButton1Click:Connect(function()
        if currentActiveKey then 
            Colors[currentActiveKey] = color
            
            -- Проверяем перекраску уведомлений по правильному ключу
            if currentActiveKey == "TextNotif" then
                if ActiveLogoLabel then ActiveLogoLabel.TextColor3 = color end
                for _, data in pairs(ActiveNotifications) do
                    if data.Line then data.Line.BackgroundColor3 = color end
                    if data.Title then data.Title.TextColor3 = color end
                    if data.Text then data.Text.TextColor3 = color end
                end
            end
            ClosePicker() 
        end
    end)
end

-- Конструктор строк управления
local function CreateEspControl(name, colorKey)
    local RowFrame = Instance.new("Frame")
    RowFrame.Size = UDim2.new(0, 220, 0, 36)
    RowFrame.BackgroundTransparency = 1
    RowFrame.Parent = ButtonContainer
    
    local MainBtn = Instance.new("TextButton")
    MainBtn.Size = UDim2.new(0, 175, 0, 36)
    MainBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
    MainBtn.Text = name .. ": ВЫКЛ"
    MainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MainBtn.Font = Enum.Font.SourceSansBold
    MainBtn.TextSize = 13
    MainBtn.Parent = RowFrame
    Instance.new("UICorner", MainBtn).CornerRadius = UDim.new(0, 6)

    local GearBtn = Instance.new("TextButton")
    GearBtn.Size = UDim2.new(0, 36, 0, 36)
    GearBtn.Position = UDim2.new(0, 182, 0, 0)
    GearBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    GearBtn.Text = "⚙️"
    GearBtn.TextSize = 14
    GearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    GearBtn.Parent = RowFrame
    Instance.new("UICorner", GearBtn).CornerRadius = UDim.new(0, 6)

    GearBtn.MouseButton1Click:Connect(function() 
        if not isMinimized then OpenPicker(colorKey) end 
    end)
    return MainBtn
end

local DoorButton = CreateEspControl("ESP ДВЕРЕЙ", "Door")
local MonsterButton = CreateEspControl("ESP МОНСТРОВ", "Monster")
local ItemButton = CreateEspControl("ESP ПРЕДМЕТОВ", "Item")
local HidingButton = CreateEspControl("ESP УКРЫТИЙ", "Hiding")
local NotifToggleButton = CreateEspControl("УВЕДОМЛЕНИЯ", "TextNotif")

NotifToggleButton.Text = "УВЕДОМЛЕНИЯ: ВКЛ"
NotifToggleButton.BackgroundColor3 = Color3.fromRGB(40, 150, 40)

-- =============================================================================
-- 2. ESP ENGINE
-- =============================================================================
local function ApplyESP(object, color, text, id)
    if not object then return end
    local billboard = object:FindFirstChild("LocalText_" .. id)
    local highlight = object:FindFirstChild("LocalHighlight_" .. id)
    
    if billboard and highlight then
        local label = billboard:FindFirstChildOfClass("TextLabel")
        if label then 
            label.Text = text
            label.TextColor3 = color 
        end
        highlight.FillColor = color
        return 
    end
    
    local highlightInstance = Instance.new("Highlight")
    highlightInstance.Name = "LocalHighlight_" .. id
    highlightInstance.FillColor = color
    highlightInstance.FillTransparency = 0.6
    highlightInstance.OutlineColor = Color3.fromRGB(255, 255, 255)
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

-- =============================================================================
-- 3. ЦИКЛЫ СКАНИРОВАНИЯ И АВТО-ОЧИСТКИ
-- =============================================================================

task.spawn(function()
    while task.wait(0.4) do
        pcall(function()
            local rooms = workspace:FindFirstChild("CurrentRooms")
            local currentRoomNum = GetCurrentRoomNumber()
            if rooms then
                for _, room in pairs(rooms:GetChildren()) do
                    local roomNum = tonumber(room.Name) or 0
                    local door = room:FindFirstChild("Door")
                    if door then
                        local actualDoor = door:FindFirstChild("Door") or door
                        if roomNum < currentRoomNum then
                            RemoveESP(actualDoor, "Door")
                        elseif _G.DoorEspEnabled then
                            local correctedName = tostring(roomNum + 1)
                            local isLocked = door:FindFirstChild("Lock") or door:FindFirstChild("KeyLock")
                            local espColor = Colors.Door
                            local espText = "🚪 Дверь " .. correctedName
                            if isLocked then
                                espColor = Color3.fromRGB(255, 50, 50)
                                espText = "🔒 Закрытая Дверь " .. correctedName
                            end
                            ApplyESP(actualDoor, espColor, espText, "Door")
                        else RemoveESP(actualDoor, "Door") end
                    end
                end
            end
        end)
    end
end)

task.spawn(function()
    while task.wait(0.3) do
        pcall(function()
            if _G.MonsterEspEnabled then
                for _, child in pairs(workspace:GetChildren()) do
                    if MonsterNames[child.Name] then ApplyESP(child, Colors.Monster, "⚠️ " .. MonsterNames[child.Name], "Monster") end
                end
            else
                for _, child in pairs(workspace:GetChildren()) do RemoveESP(child, "Monster") end
            end
        end)
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local rooms = workspace:FindFirstChild("CurrentRooms")
            local currentRoomNum = GetCurrentRoomNumber()
            if rooms then
                for _, room in pairs(rooms:GetChildren()) do
                    local roomNum = tonumber(room.Name) or 0
                    for _, asset in pairs(room:GetDescendants()) do
                        if roomNum < currentRoomNum then
                            RemoveESP(asset, "Item")
                        elseif _G.ItemEspEnabled then
                            if asset.Name == "KeyObtain" then ApplyESP(asset, Colors.Item, "🔑 Ключ", "Item")
                            elseif asset.Name == "LeverForGate" then ApplyESP(asset, Colors.Item, "⚙️ Рычаг", "Item")
                            elseif asset.Name == "LiveHintBook" then ApplyESP(asset, Colors.Item, "📘 Книга", "Item")
                            elseif asset.Name == "GoldPile" then ApplyESP(asset, Colors.Item, "💰 Золото", "Item")
                            elseif asset.Name == "LiveFuseElement" then ApplyESP(asset, Colors.Item, "🔋 Предохранитель", "Item")
                            elseif asset.Name == "ChestBox" or asset.Name == "ChestBoxLocked" then
                                local label = asset.Name == "ChestBoxLocked" and "🔒 Закрытый Сундук" or "📦 Сундук"
                                ApplyESP(asset, Colors.Item, label, "Item")
                            end
                        else RemoveESP(asset, "Item") end
                    end
                end
            end
        end)
    end
end)

task.spawn(function()
    while task.wait(0.6) do
        pcall(function()
            local rooms = workspace:FindFirstChild("CurrentRooms")
            local currentRoomNum = GetCurrentRoomNumber()
            if rooms then
                for _, room in pairs(rooms:GetChildren()) do
                    local roomNum = tonumber(room.Name) or 0
                    for _, asset in pairs(room:GetDescendants()) do
                        if roomNum < currentRoomNum then
                            RemoveESP(asset, "Hiding")
                        elseif _G.HidingEspEnabled then
                            if asset.Name == "Wardrobe" then ApplyESP(asset, Colors.Hiding, "🚪 Шкаф", "Hiding")
                            elseif asset.Name == "Bed" then ApplyESP(asset, Colors.Hiding, "🛏️ Кровать", "Hiding") end
                        else RemoveESP(asset, "Hiding") end
                    end
                end
            end
        end)
    end
end)

workspace.ChildAdded:Connect(function(child)
    pcall(function()
        if MonsterNames[child.Name] then
            CustomNotify("🚨 ОБНАРУЖЕН МОНСТР!", "В игру зашел: " .. MonsterNames[child.Name])
            if _G.MonsterEspEnabled then
                task.wait(0.1)
                ApplyESP(child, Colors.Monster, "⚠️ " .. MonsterNames[child.Name], "Monster")
            end
        end
    end)
end)

-- =============================================================================
-- 4. УПРАВЛЕНИЕ КНОПКАМИ И ТУМБЛЕРАМИ
-- =============================================================================
local function ToggleState(btn, flagName, textOn, textOff)
    _G[flagName] = not _G[flagName]
    if _G[flagName] then
        btn.Text = textOn
        btn.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
    else
        btn.Text = textOff
        btn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
    end
end

DoorButton.MouseButton1Click:Connect(function() ToggleState(DoorButton, "DoorEspEnabled", "ESP ДВЕРЕЙ: ВКЛ", "ESP ДВЕРЕЙ: ВЫКЛ") end)
MonsterButton.MouseButton1Click:Connect(function() ToggleState(MonsterButton, "MonsterEspEnabled", "ESP МОНСТРОВ: ВКЛ", "ESP МОНСТРОВ: ВЫКЛ") end)
ItemButton.MouseButton1Click:Connect(function() ToggleState(ItemButton, "ItemEspEnabled", "ESP ПРЕДМЕТОВ: ВКЛ", "ESP ПРЕДМЕТОВ: ВЫКЛ") end)
HidingButton.MouseButton1Click:Connect(function() ToggleState(HidingButton, "HidingEspEnabled", "ESP УКРЫТИЙ: ВКЛ", "ESP УКРЫТИЙ: ВЫКЛ") end)
NotifToggleButton.MouseButton1Click:Connect(function() ToggleState(NotifToggleButton, "NotificationsEnabled", "УВЕДОМЛЕНИЯ: ВКЛ", "УВЕДОМЛЕНИЯ: ВЫКЛ") end)

CustomNotify("SYSTEM", "Ocel-hub v12.3 успешно запущен!")
