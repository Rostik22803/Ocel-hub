-- =============================================================================
-- DOORS LOCAL MEGA HUB v12.3 (OCEL-HUB FIXED NOTIF RE-COLOR)
-- =============================================================================

local oldGui = game:GetService("CoreGui"):FindFirstChild("DoorsLocalMegaHubFinal")
if oldGui then oldGui:Destroy() end

-- Глобальные настройки
_G.DoorEspEnabled = false
_G.MonsterEspEnabled = false
_G.ItemEspEnabled = false
_G.HidingEspEnabled = false
_G.NotificationsEnabled = true 

-- Цвета обводок и кастомного текста
local Colors = {
    Door = Color3.fromRGB(0, 255, 100),     
    Monster = Color3.fromRGB(255, 50, 50),  
    Item = Color3.fromRGB(255, 200, 0),     
    Hiding = Color3.fromRGB(0, 180, 255),
    TextNotif = Color3.fromRGB(240, 240, 240) 
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

local function GetCurrentRoomNumber()
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

CustomNotify("SYSTEM", "Ocel-hub v12.3 успешно запущен!")RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    local root = char:FindFirstChild("HumanoidRootPart")
    
    -- 1. Сверхстабильный Анти-Eyes через физический щит перед камерой
    if _G.AntiEyes and workspace:FindFirstChild("Eyes") then
        local eyes = workspace:FindFirstChild("Eyes")
        local core = eyes:FindFirstChild("Core") or eyes:FindFirstChildOfClass("BasePart")
        if core and head then
            -- Ставим щит ровно между головой игрока и Глазами, блокируя Raycast урона
            EyeShield.CFrame = CFrame.new(head.Position, core.Position) * CFrame.new(0, 0, -2)
        end
    else
        EyeShield.CFrame = CFrame.new(0, -999, 0)
    end

    -- 2. Десинхрон хитбокса против Скрича и Гиггла
    if (_G.AntiScreech or _G.AntiGiggle) and head then
        for _, v in pairs(head:GetChildren()) do
            if v:IsA("Attachment") or v:IsA("VectorForce") then
                -- Ломаем привязку прыгающих сущностей к костям персонажа
                if (_G.AntiScreech and string.find(v.Name, "Screech")) or (_G.AntiGiggle and string.find(v.Name, "Giggle")) then
                    v:Destroy()
                end
            end
        end
    end
end)

-- 3. Анти-А90 (Исправленный безопасный поток)
task.spawn(function()
    while true do
        task.wait(0.1) -- Безопасный интервал проверки
        if _G.AntiA90 then
            local char = LocalPlayer.Character
            local a90 = LocalPlayer.PlayerGui:FindFirstChild("A90")
            if a90 and a90.Enabled and char then
                local root = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if root and hum then
                    root.Anchored = true
                    hum.PlatformStand = true
                    -- Безопасный цикл ожидания окончания А-90 с таск-вейтом!
                    while a90 and a90.Enabled and _G.AntiA90 do
                        task.wait(0.05)
                    end
                    root.Anchored = false
                    hum.PlatformStand = false
                end
            end
        end
    end
end)

-- 4. Векторный No-Touch для Капканов (Snare)
local function ModernSnareBypass(child)
    if _G.AntiSnare and child.Name == "Snare" then
        task.spawn(function()
            task.wait(0.05)
            local touch = child:FindFirstChildOfClass("TouchTransmitter")
            if touch then touch:Destroy() end
            for _, part in pairs(child:GetDescendants()) do
                if part:IsA("BasePart") then 
                    part.CanCollide = false 
                    part.Size = Vector3.new(0,0,0)
                end
            end
        end)
    end
end
workspace.ChildAdded:Connect(ModernSnareBypass)
if workspace:FindFirstChild("CurrentRooms") then
    workspace.CurrentRooms.DescendantAdded:Connect(ModernSnareBypass)
end

-- 5. Защита от Тимоти (Мгновенный килл эвента при открытии ящика)
LocalPlayer.PlayerGui.DescendantAdded:Connect(function(desc)
    if _G.AntiTimothy and (desc.Name == "SpiderJumpscare" or desc.Name == "TimothyGui") then
        desc:Destroy()
    end
end)

-- =============================================================================
-- УПРОЩЕННЫЙ МИНИМАЛИСТИЧНЫЙ ИНТЕРФЕЙС
-- =============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DoorsLocalMegaHubFinal"
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 320)
MainFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 6)

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, 0, 1, -10)
ScrollingFrame.Position = UDim2.new(0, 0, 0, 5)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 380)
ScrollingFrame.ScrollBarThickness = 2
ScrollingFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollingFrame
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function CreateBtn(name, varName)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 190, 0, 30)
    Btn.BackgroundColor3 = Color3.fromRGB(130, 30, 30)
    Btn.Text = name .. ": ВЫКЛ"
    Btn.TextColor3 = Color3.new(1, 1, 1)
    Btn.Font = Enum.Font.SourceSansBold
    Btn.TextSize = 12
    Btn.Parent = ScrollingFrame
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
    
    Btn.MouseButton1Click:Connect(function()
        _G[varName] = not _G[varName]
        if _G[varName] then
            Btn.Text = name .. ": ВКЛ"
            Btn.BackgroundColor3 = Color3.fromRGB(30, 120, 30)
        else
            Btn.Text = name .. ": ВЫКЛ"
            Btn.BackgroundColor3 = Color3.fromRGB(130, 30, 30)
        end
    end)
end

CreateBtn("ESP ДВЕРЕЙ", "DoorEspEnabled")
CreateBtn("ESP МОНСТРОВ", "MonsterEspEnabled")
CreateBtn("АНТИ ГЛАЗА (ЩИТ)", "AntiEyes")
CreateBtn("АНТИ А-90 (ХАРД ФРИЗ)", "AntiA90")
CreateBtn("АНТИ СКРИЧ (ДЕСИНХРОН)", "AntiScreech")
CreateBtn("АНТИ КАПКАН (NO-TOUCH)", "AntiSnare")
CreateBtn("АНТИ ТИМОТИ (GUI BLOCK)", "AntiTimothy")
CreateBtn("АНТИ ГИГГЛ (ОЧИСТКА)", "AntiGiggle")

-- Базовый ESP движок для проверки комнат
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if _G.DoorEspEnabled and workspace:FindFirstChild("CurrentRooms") then
                for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
                    local door = room:FindFirstChild("Door")
                    if door and not door:FindFirstChild("ESP") then
                        local h = Instance.new("Highlight", door)
                        h.Name = "ESP"
                        h.FillColor = Color3.new(0,1,0)
                        h.FillTransparency = 0.6
                    end
                end
            end
        end)
    end
end)RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    local root = char:FindFirstChild("HumanoidRootPart")
    
    -- 1. Сверхстабильный Анти-Eyes через физический щит перед камерой
    if _G.AntiEyes and workspace:FindFirstChild("Eyes") then
        local eyes = workspace:FindFirstChild("Eyes")
        local core = eyes:FindFirstChild("Core") or eyes:FindFirstChildOfClass("BasePart")
        if core and head then
            -- Ставим щит ровно между головой игрока и Глазами, блокируя Raycast урона
            EyeShield.CFrame = CFrame.new(head.Position, core.Position) * CFrame.new(0, 0, -2)
        end
    else
        EyeShield.CFrame = CFrame.new(0, -999, 0)
    end

    -- 2. Десинхрон хитбокса против Скрича и Гиггла
    if (_G.AntiScreech or _G.AntiGiggle) and head then
        for _, v in pairs(head:GetChildren()) do
            if v:IsA("Attachment") or v:IsA("VectorForce") then
                -- Ломаем привязку прыгающих сущностей к костям персонажа
                if (_G.AntiScreech and string.find(v.Name, "Screech")) or (_G.AntiGiggle and string.find(v.Name, "Giggle")) then
                    v:Destroy()
                end
            end
        end
    end
    
    -- 3. Анти-А90 через прерывание обработки ввода
    if _G.AntiA90 then
        local a90 = LocalPlayer.PlayerGui:FindFirstChild("A90")
        if a90 and a90.Enabled then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and root then
                -- Принудительный аппаратный стоп кадра позиции
                root.Anchored = true
                hum.PlatformStand = true
                task.wait(0.1)
                while a90 and a90.Enabled do
                    task.wait()
                end
                root.Anchored = false
                hum.PlatformStand = false
            end
        end
    end
end)

-- 4. Векторный No-Touch для Капканов (Snare)
local function ModernSnareBypass(child)
    if _G.AntiSnare and child.Name == "Snare" then
        task.spawn(function()
            -- Вырезаем триггер фиксации наступания персонажа
            local touch = child:FindFirstChildOfClass("TouchTransmitter")
            if touch then touch:Destroy() end
            for _, part in pairs(child:GetDescendants()) do
                if part:IsA("BasePart") then 
                    part.CanCollide = false 
                    part.Size = Vector3.new(0,0,0)
                end
            end
        end)
    end
end
workspace.ChildAdded:Connect(ModernSnareBypass)
if workspace:FindFirstChild("CurrentRooms") then
    workspace.CurrentRooms.DescendantAdded:Connect(ModernSnareBypass)
end

-- 5. Защита от Тимоти (Мгновенный килл эвента при открытии ящика)
LocalPlayer.PlayerGui.DescendantAdded:Connect(function(desc)
    if _G.AntiTimothy and (desc.Name == "SpiderJumpscare" or desc.Name == "TimothyGui") then
        desc:Destroy()
    end
end)

-- =============================================================================
-- УПРОЩЕННЫЙ МИНИМАЛИСТИЧНЫЙ ИНТЕРФЕЙС
-- =============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DoorsLocalMegaHubFinal"
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 320)
MainFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 6)

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, 0, 1, -10)
ScrollingFrame.Position = UDim2.new(0, 0, 0, 5)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 380)
ScrollingFrame.ScrollBarThickness = 2
ScrollingFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollingFrame
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function CreateBtn(name, varName)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 190, 0, 30)
    Btn.BackgroundColor3 = Color3.fromRGB(130, 30, 30)
    Btn.Text = name .. ": ВЫКЛ"
    Btn.TextColor3 = Color3.new(1, 1, 1)
    Btn.Font = Enum.Font.SourceSansBold
    Btn.TextSize = 12
    Btn.Parent = ScrollingFrame
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
    
    Btn.MouseButton1Click:Connect(function()
        _G[varName] = not _G[varName]
        if _G[varName] then
            Btn.Text = name .. ": ВКЛ"
            Btn.BackgroundColor3 = Color3.fromRGB(30, 120, 30)
        else
            Btn.Text = name .. ": ВЫКЛ"
            Btn.BackgroundColor3 = Color3.fromRGB(130, 30, 30)
        end
    end)
end

CreateBtn("ESP ДВЕРЕЙ", "DoorEspEnabled")
CreateBtn("ESP МОНСТРОВ", "MonsterEspEnabled")
CreateBtn("АНТИ ГЛАЗА (ЩИТ)", "AntiEyes")
CreateBtn("АНТИ А-90 (ХАРД ФРИЗ)", "AntiA90")
CreateBtn("АНТИ СКРИЧ (ДЕСИНХРОН)", "AntiScreech")
CreateBtn("АНТИ КАПКАН (NO-TOUCH)", "AntiSnare")
CreateBtn("АНТИ ТИМОТИ (GUI BLOCK)", "AntiTimothy")
CreateBtn("АНТИ ГИГГЛ (ОЧИСТКА)", "AntiGiggle")

-- Базовый ESP движок для проверки комнат
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if _G.DoorEspEnabled and workspace:FindFirstChild("CurrentRooms") then
                for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
                    local door = room:FindFirstChild("Door")
                    if door and not door:FindFirstChild("ESP") then
                        local h = Instance.new("Highlight", door)
                        h.Name = "ESP"
                        h.FillColor = Color3.new(0,1,0)
                        h.FillTransparency = 0.6
                    end
                end
            end
        end)
    end
end)task.spawn(function()
    while true do
        task.wait()
        if _G.AntiA90 then
            local a90Gui = LocalPlayer.PlayerGui:FindFirstChild("A90") or game:GetService("CoreGui"):FindFirstChild("A90")
            if a90Gui and a90Gui.Enabled then
                -- Полностью перекрываем управление, чтобы движок не затрекал сдвиг мыши или клик
                ContextActionService:BindAction("BlockPack", function() return Enum.ContextActionResult.Sink end, false, unpack(Enum.PlayerActions:GetEnumItems()))
                
                local char = LocalPlayer.Character
                if char then
                    local root = char:FindFirstChild("HumanoidRootPart")
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if root and hum then
                        while a90Gui and a90Gui.Enabled and _G.AntiA90 do
                            root.Velocity = Vector3.new(0, 0, 0)
                            root.RotVelocity = Vector3.new(0, 0, 0)
                            hum:Move(Vector3.new(0,0,0))
                            task.wait()
                        end
                    end
                end
                ContextActionService:UnbindAction("BlockPack")
            end
        end
    end
end)

-- 2. Физический NoSnare (Капканы) + Анти-Скрич / Гиггл дефузер
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    
    -- Капканы: просто убираем коллизию нижних конечностей персонажа с полом Greenhouse
    if _G.AntiSnare then
        for _, part in pairs(char:GetChildren()) do
            if part:IsA("BasePart") and (part.Name == "LeftLeg" or part.Name == "RightLeg" or part.Name == "Left Foot" or part.Name == "Right Foot") then
                part.CanCollide = false
            end
        end
    end
    
    -- Скрич / Гиггл: Мгновенный сброс атаки, если сущность пытается зацепиться за голову
    if _G.AntiScreech or _G.AntiGiggle then
        local head = char:FindFirstChild("Head")
        if head then
            for _, child in pairs(head:GetChildren()) do
                if (_G.AntiScreech and child.Name == "Screech") or (_G.AntiGiggle and child.Name == "Giggle") then
                    child:Destroy() -- Стираем самого эмиттера до начала фазы укуса
                end
            end
        end
    end
end)

-- 3. Анти-Глаза (Разворот камеры на уровне CFrame во время рендера сцены)
RunService.RenderStepped:Connect(function()
    if _G.AntiEyes and workspace:FindFirstChild("Eyes") then
        local camera = workspace.CurrentCamera
        local eyes = workspace:FindFirstChild("Eyes")
        if eyes and camera then
            local core = eyes:FindFirstChild("Core") or eyes:FindFirstChildOfClass("BasePart")
            if core then
                -- Если мы теоретически смотрим на Глаза, скрипт мгновенно смещает вектор взгляда камеры на 180 градусов
                local dir = (core.Position - camera.CFrame.Position).Unit
                local look = camera.CFrame.LookVector
                if dir:Dot(look) > 0.1 then -- Проверка: смотрим ли мы на монстра
                    camera.CFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position - dir)
                end
            end
        end
    end
end)

-- 4. Стопроцентный Клиентский Анти-Тимоти (Убираем из UI-скриптов ящиков)
workspace.DescendantAdded:Connect(function(descendant)
    if _G.AntiTimothy and descendant.Name == "Timothy" then
        descendant:Destroy()
    end
end)

-- =============================================================================
-- ИНТЕРФЕЙС GUI
-- =============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DoorsLocalMegaHubFinal"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 230, 0, 360)
MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, 0, 1, -10)
ScrollingFrame.Position = UDim2.new(0, 0, 0, 5)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 430)
ScrollingFrame.ScrollBarThickness = 3
ScrollingFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollingFrame
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function CreateButton(name)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 200, 0, 32)
    Btn.BackgroundColor3 = Color3.fromRGB(140, 35, 35)
    Btn.Text = name .. ": ВЫКЛ"
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.SourceSansBold
    Btn.TextSize = 13
    Btn.Parent = ScrollingFrame
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 5)
    return Btn
end

local DoorButton = CreateButton("ESP ДВЕРЕЙ")
local MonsterButton = CreateButton("ESP МОНСТРОВ")
local ItemButton = CreateButton("ESP ПРЕДМЕТОВ")
local HidingButton = CreateButton("ESP УКРЫТИЙ")

local EyesButton = CreateButton("АНТИ ГЛАЗА (ФИЗИК)")
local A90Button = CreateButton("АНТИ А-90 (ФРИЗ)")
local ScreechButton = CreateButton("АНТИ СКРИЧ (КЛИЕНТ)")
local SnareButton = CreateButton("АНТИ КАПКАН (NO-COLLIDE)")
local TimothyButton = CreateButton("АНТИ ТИМОТИ (ОЧИСТКА)")
local GiggleButton = CreateButton("АНТИ ГИГГЛ (КЛИЕНТ)")

-- =============================================================================
-- ENGINE ESP
-- =============================================================================
local function ApplyESP(object, color, text, id)
    if not object or object:FindFirstChild("LocalText_" .. id) then return end
    
    local highlightInstance = Instance.new("Highlight")
    highlightInstance.Name = "LocalHighlight_" .. id
    highlightInstance.FillColor = color
    highlightInstance.FillTransparency = 0.5
    highlightInstance.OutlineColor = Color3.new(1,1,1)
    highlightInstance.Adornee = object
    highlightInstance.Parent = object
    
    local bGui = Instance.new("BillboardGui")
    bGui.Name = "LocalText_" .. id
    bGui.Size = UDim2.new(0, 140, 0, 30)
    bGui.AlwaysOnTop = true
    bGui.StudsOffset = Vector3.new(0, 2, 0)
    bGui.Parent = object
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color 
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 14
    label.Parent = bGui
end

local function RemoveESP(object, id)
    if not object then return end
    local hl = object:FindFirstChild("LocalHighlight_" .. id)
    local bb = object:FindFirstChild("LocalText_" .. id)
    if hl then hl:Destroy() end
    if bb then bb:Destroy() end
end

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local rooms = workspace:FindFirstChild("CurrentRooms")
            if rooms then
                for _, room in pairs(rooms:GetChildren()) do
                    local door = room:FindFirstChild("Door")
                    if door and _G.DoorEspEnabled then
                        ApplyESP(door:FindFirstChild("Door") or door, Color3.fromRGB(0, 255, 100), "🚪 Дверь " .. room.Name, "Door")
                    else
                        RemoveESP(door:FindFirstChild("Door") or door, "Door")
                    end
                    
                    if _G.ItemEspEnabled or _G.HidingEspEnabled then
                        for _, asset in pairs(room:GetDescendants()) do
                            if _G.ItemEspEnabled and (asset.Name == "KeyObtain" or asset.Name == "LeverForGate") then
                                ApplyESP(asset, Color3.fromRGB(255, 200, 0), "⭐ Квест", "Item")
                            elseif _G.HidingEspEnabled and (asset.Name == "Wardrobe" or asset.Name == "Bed") then
                                ApplyESP(asset, Color3.fromRGB(0, 180, 255), "🛏️ Укрытие", "Hiding")
                            end
                        end
                    end
                end
            end
            
            if _G.MonsterEspEnabled then
                for _, child in pairs(workspace:GetChildren()) do
                    if MonsterNames[child.Name] then ApplyESP(child, Color3.fromRGB(255, 50, 50), MonsterNames[child.Name], "Monster") end
                end
            else
                for _, child in pairs(workspace:GetChildren()) do RemoveESP(child, "Monster") end
            end
        end)
    end
end)

-- Управление
local function SetupToggle(btn, varName)
    btn.MouseButton1Click:Connect(function()
        _G[varName] = not _G[varName]
        local baseText = string.split(btn.Text, ":")[1]
        if _G[varName] then
            btn.Text = baseText .. ": ВКЛ"
            btn.BackgroundColor3 = Color3.fromRGB(35, 130, 35)
        else
            btn.Text = baseText .. ": ВЫКЛ"
            btn.BackgroundColor3 = Color3.fromRGB(140, 35, 35)
        end
    end)
end

SetupToggle(DoorButton, "DoorEspEnabled")
SetupToggle(MonsterButton, "MonsterEspEnabled")
SetupToggle(ItemButton, "ItemEspEnabled")
SetupToggle(HidingButton, "HidingEspEnabled")

SetupToggle(EyesButton, "AntiEyes")
SetupToggle(A90Button, "AntiA90")
SetupToggle(ScreechButton, "AntiScreech")
SetupToggle(SnareButton, "AntiSnare")
SetupToggle(TimothyButton, "AntiTimothy")
SetupToggle(GiggleButton, "AntiGiggle")    AntiGiggle = Color3.fromRGB(0, 150, 255),
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
