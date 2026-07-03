-- =============================================================================
-- AUTONOMOUS DOORS MEGA HUB (БЕЗ ЗАГРУЗКИ С GITHUB)
-- =============================================================================

local oldGui = game:GetService("CoreGui"):FindFirstChild("DoorsAutonomousMegaHub")
if oldGui then oldGui:Destroy() end

-- Глобальные настройки (из Нового текстового документа.txt)
_G.DoorEspEnabled = false
_G.MonsterEspEnabled = false
_G.ItemEspEnabled = false
_G.HidingEspEnabled = false
_G.ShowDistanceEnabled = false
_G.FullbrightEnabled = false
_G.CustomFOV = 70
_G.AntiHearingEnabled = true -- По умолчанию включен
_G.SpeedHackEnabled = false

-- Настройки из оригинального бекапа анти слух фигуры.txt
local TargetWalkspeed = 5
local Flags = {
    KeyToggle = false,
    NoSeek = false,
    InstantToggle = false,
    AutoSkip = false,
    ScreechToggle = false,
    HeartbeatWin = false,
    PredictToggle = false,
    MobToggle = true,
    AvoidRushToggle = false
}

local Colors = {
    Door = Color3.fromRGB(0, 255, 100),     
    Monster = Color3.fromRGB(255, 50, 50),  
    Item = Color3.fromRGB(255, 200, 0),     
    Hiding = Color3.fromRGB(0, 180, 255),
    TextNotif = Color3.fromRGB(240, 240, 240),
    Fullbright = Color3.fromRGB(255, 255, 255)
}

local DefaultLighting = {
    Ambient = Color3.fromRGB(0, 0, 0),
    OutdoorAmbient = Color3.fromRGB(70, 70, 70),
    Brightness = 1,
    ClockTime = 14,
    FogEnd = 100000,
    GlobalShadows = true,
}

local MonsterNames = {
    ["RushMoving"] = "Раш 🏃‍♂️", ["AmbushMoving"] = "Амбуш ⚡", ["Eyes"] = "Глаза 👀",
    ["SeekMoving"] = "Сик 👁️", ["Figure"] = "Фигура 👤", ["A60"] = "A-60 🔴",
    ["A120"] = "A-120 ⭕", ["GiggleCeiling"] = "Гиггл 💢", ["Grumble"] = "Грамбл 👾"
}

local CF = CFrame.new
local LatestRoom = game:GetService("ReplicatedStorage").GameData.LatestRoom
local ChaseStart = game:GetService("ReplicatedStorage").GameData.ChaseStart

-- Поиск удаленного события присяди для защиты от Фигуры
local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("RemotesFolder", 5) or game:GetService("ReplicatedStorage")
local CrouchRemote = Remotes:FindFirstChild("Crouch") or Remotes:FindFirstChild("Crouching")
if not CrouchRemote then
    for _, obj in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
        if obj:IsA("RemoteEvent") and (obj.Name:lower():find("crouch") or obj.Name:lower():find("sneak")) then
            CrouchRemote = obj
            break
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

-- =============================================================================
-- СОЗДАНИЕ ИНТЕРФЕЙСА (ЛОКАЛЬНАЯ АЛЬТЕРНАТИВА ORION)
-- =============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DoorsAutonomousMegaHub"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 480)
MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true 
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local HeaderFrame = Instance.new("Frame")
HeaderFrame.Size = UDim2.new(1, 0, 0, 35)
HeaderFrame.BackgroundTransparency = 1
HeaderFrame.Parent = MainFrame

local LogoLabel = Instance.new("TextLabel")
LogoLabel.Size = UDim2.new(0, 180, 1, 0)
LogoLabel.Position = UDim2.new(0, 12, 0, 0)
LogoLabel.Text = "Doors Mega Hub v13.0"
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
MinimizeBtn.TextSize = 14
MinimizeBtn.Parent = HeaderFrame
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 4)

local ButtonContainer = Instance.new("ScrollingFrame")
ButtonContainer.Size = UDim2.new(1, 0, 1, -40)
ButtonContainer.Position = UDim2.new(0, 0, 0, 35)
ButtonContainer.BackgroundTransparency = 1
ButtonContainer.CanvasSize = UDim2.new(0, 0, 0, 780)
ButtonContainer.ScrollBarThickness = 3
ButtonContainer.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ButtonContainer
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MinimizeBtn.Text = "+"
        ButtonContainer.Visible = false
        MainFrame:TweenSize(UDim2.new(0, 250, 0, 35), "Out", "Quart", 0.2, true)
    else
        MinimizeBtn.Text = "—"
        task.delay(0.1, function() ButtonContainer.Visible = true end)
        MainFrame:TweenSize(UDim2.new(0, 250, 0, 480), "Out", "Quart", 0.2, true)
    end
end)

-- Конструкторы элементов интерфейса
local function CreateToggle(text, default, callback)
    local state = default
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 230, 0, 32)
    Btn.BackgroundColor3 = default and Color3.fromRGB(40, 150, 40) or Color3.fromRGB(150, 40, 40)
    Btn.Text = text .. (default and ": ВКЛ" or ": ВЫКЛ")
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.SourceSansBold
    Btn.TextSize = 13
    Btn.Parent = ButtonContainer
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.BackgroundColor3 = state and Color3.fromRGB(40, 150, 40) or Color3.fromRGB(150, 40, 40)
        Btn.Text = text .. (state and ": ВКЛ" or ": ВЫКЛ")
        callback(state)
    end)
    return Btn
end

local function CreateButton(text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 230, 0, 32)
    Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.SourceSansBold
    Btn.TextSize = 13
    Btn.Parent = ButtonContainer
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    Btn.MouseButton1Click:Connect(callback)
    return Btn
end

local function CreateSlider(text, min, max, default, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(0, 230, 0, 35)
    Row.BackgroundTransparency = 1
    Row.Parent = ButtonContainer

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 110, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text .. ": " .. default
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.SourceSansBold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local val = default
    local Minus = Instance.new("TextButton")
    Minus.Size = UDim2.new(0, 32, 0, 32)
    Minus.Position = UDim2.new(0, 120, 0, 0)
    Minus.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Minus.Text = "−"
    Minus.TextColor3 = Color3.fromRGB(255, 255, 255)
    Minus.Font = Enum.Font.SourceSansBold
    Minus.TextSize = 16
    Minus.Parent = Row
    Instance.new("UICorner", Minus).CornerRadius = UDim.new(0, 4)

    local Plus = Instance.new("TextButton")
    Plus.Size = UDim2.new(0, 32, 0, 32)
    Plus.Position = UDim2.new(0, 157, 0, 0)
    Plus.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Plus.Text = "+"
    Plus.TextColor3 = Color3.fromRGB(255, 255, 255)
    Plus.Font = Enum.Font.SourceSansBold
    Plus.TextSize = 16
    Plus.Parent = Row
    Instance.new("UICorner", Plus).CornerRadius = UDim.new(0, 4)

    local Reset = Instance.new("TextButton")
    Reset.Size = UDim2.new(0, 32, 0, 32)
    Reset.Position = UDim2.new(0, 194, 0, 0)
    Reset.BackgroundColor3 = Color3.fromRGB(40, 80, 140)
    Reset.Text = "↺"
    Reset.TextColor3 = Color3.fromRGB(255, 255, 255)
    Reset.Font = Enum.Font.SourceSansBold
    Reset.TextSize = 14
    Reset.Parent = Row
    Instance.new("UICorner", Reset).CornerRadius = UDim.new(0, 4)

    local function update()
        Label.Text = text .. ": " .. val
        callback(val)
    end

    Minus.MouseButton1Click:Connect(function() val = math.max(min, val - 2) update() end)
    Plus.MouseButton1Click:Connect(function() val = math.min(max, val + 2) update() end)
    Reset.MouseButton1Click:Connect(function() val = default update() end)
end

-- =============================================================================
-- НАПОЛНЕНИЕ МЕНЮ ЭЛЕМЕНТАМИ УПРАВЛЕНИЯ
-- =============================================================================

-- Вкладка ESP / Визуальное (Новый текстовый документ.txt)
CreateToggle("АНТИ-СЛУХ ФИГУРЫ", true, function(v) _G.AntiHearingEnabled = v end)
CreateToggle("ESP ДВЕРЕЙ", false, function(v) _G.DoorEspEnabled = v end)
CreateToggle("ESP МОНСТРОВ", false, function(v) _G.MonsterEspEnabled = v end)
CreateToggle("ESP ПРЕДМЕТОВ", false, function(v) _G.ItemEspEnabled = v end)
CreateToggle("ESP УКРЫТИЙ", false, function(v) _G.HidingEspEnabled = v end)
CreateToggle("ДИСТАНЦИЯ ЕСП", false, function(v) _G.ShowDistanceEnabled = v end)
CreateToggle("Key Chams", false, function(v) Flags.KeyToggle = v end)

local function ApplyFullbright(enabled)
    local Lighting = game:GetService("Lighting")
    if enabled then
        Lighting.Ambient = Colors.Fullbright
        Lighting.OutdoorAmbient = Colors.Fullbright
        Lighting.Brightness = 5
        Lighting.ClockTime = 12
        Lighting.FogEnd = 999999
        Lighting.GlobalShadows = false
    else
        Lighting.Ambient = DefaultLighting.Ambient
        Lighting.OutdoorAmbient = DefaultLighting.OutdoorAmbient
        Lighting.Brightness = DefaultLighting.Brightness
        Lighting.ClockTime = DefaultLighting.ClockTime
        Lighting.FogEnd = DefaultLighting.FogEnd
        Lighting.GlobalShadows = DefaultLighting.GlobalShadows
    end
end
CreateToggle("ФУЛЛБРАЙТ", false, function(v) ApplyFullbright(v) end)

-- Вкладка Характеристик / Игрока
CreateSlider("СКОРОСТЬ", 0, 50, 5, function(v) TargetWalkspeed = v end)
CreateSlider("Кастомный FOV", 30, 120, 70, function(v) _G.CustomFOV = v end)

local pcl = Instance.new("SpotLight")
pcl.Brightness = 1
pcl.Face = Enum.NormalId.Front
pcl.Range = 90
pcl.Parent = game.Players.LocalPlayer.Character.Head
pcl.Enabled = false
CreateToggle("Фонарик (Headlight)", false, function(v) pcl.Enabled = v end)

-- Вкладка Автоматизации / Обходов (бекап анти слух фигуры.txt)
CreateToggle("No seek arms / Преграды", false, function(v) Flags.NoSeek = v end)
CreateToggle("Instant Interact", false, function(v) Flags.InstantToggle = v end)
CreateToggle("Auto Skip Level", false, function(v) Flags.AutoSkip = v end)
CreateToggle("Avoid Rush/Ambush", false, function(v) Flags.AvoidRushToggle = v end)
CreateToggle("No Screech", false, function(v) Flags.ScreechToggle = v end)
CreateToggle("Always win heartbeat", false, function(v) Flags.HeartbeatWin = v end)
CreateToggle("Predict Chases", false, function(v) Flags.PredictToggle = v end)
CreateToggle("Notify on Mob Spawn", true, function(v) Flags.MobToggle = v end)

CreateButton("Пропустить уровень (Skip Level)", function()
    pcall(function()
        local HasKey = false
        local CurrentDoor = workspace.CurrentRooms[tostring(game:GetService("ReplicatedStorage").GameData.LatestRoom.Value)]:WaitForChild("Door")
        for i,v in ipairs(CurrentDoor.Parent:GetDescendants()) do
            if v.Name == "KeyObtain" then HasKey = v end
        end
        if HasKey then
            game.Players.LocalPlayer.Character:PivotTo(CF(HasKey.Hitbox.Position))
            wait(0.3)
            fireproximityprompt(HasKey.ModulePrompt,0)
            game.Players.LocalPlayer.Character:PivotTo(CF(CurrentDoor.Door.Position))
            wait(0.3)
            fireproximityprompt(CurrentDoor.Lock.UnlockPrompt,0)
        end
        if LatestRoom.Value == 50 then
            CurrentDoor = workspace.CurrentRooms[tostring(LatestRoom.Value+1)]:WaitForChild("Door")
        end
        game.Players.LocalPlayer.Character:PivotTo(CF(CurrentDoor.Door.Position))
        wait(0.3)
        CurrentDoor.ClientOpen:FireServer()
    end)
end)

CreateButton("Убрать скримеры", function()
    pcall(function() game:GetService("ReplicatedStorage").Bricks.Jumpscare:Destroy() end)
end)

CreateButton("Пройти мини-игру с щитком", function()
    game:GetService("ReplicatedStorage").Bricks.EBF:FireServer()
end)

CreateButton("Пропустить 50 уровень", function()
    local CurrentDoor = workspace.CurrentRooms[tostring(LatestRoom.Value+1)]:WaitForChild("Door")
    game.Players.LocalPlayer.Character:PivotTo(CF(CurrentDoor.Door.Position))
end)

-- =============================================================================
-- СЕРВЕРНЫЙ ОБХОД И ЛОГИКА СЕТИ (HOOKMETAMETHOD)
-- =============================================================================
local old
old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    -- Синхронизированный Анти-слух Фигуры из нового документа
    if _G.AntiHearingEnabled and CrouchRemote and self == CrouchRemote and (method == "FireServer" or method == "fireServer") then
        args[1] = true
        return old(self, unpack(args))
    end
    
    -- Остальные сетевые обходы из бэкапа
    if tostring(self) == 'Screech' and method == "FireServer" and Flags.ScreechToggle == true then
        args[1] = true
        return old(self, unpack(args))
    end
    if tostring(self) == 'ClutchHeartbeat' and method == "FireServer" and Flags.HeartbeatWin == true then
        args[2] = true
        return old(self, unpack(args))
    end
    
    return old(self, ...)
end))

-- Постоянная фоновая отсылка фейк-сигнала скрытности
game:GetService("RunService").Heartbeat:Connect(function()
    pcall(function()
        if _G.AntiHearingEnabled and CrouchRemote then
            CrouchRemote:FireServer(true)
        end
    end)
end)

-- =============================================================================
-- ДВИЖОК ESP И СКАНЕРЫ (ОЦЕЛ-ХАБ)
-- =============================================================================
local function ApplyESP(object, color, text, id)
    if not object then return end
    local billboard = object:FindFirstChild("LocalText_" .. id)
    local highlight = object:FindFirstChild("LocalHighlight_" .. id)
    
    local distanceText = ""
    if _G.ShowDistanceEnabled then
        local localPlayer = game:GetService("Players").LocalPlayer
        if localPlayer and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local root = localPlayer.Character.HumanoidRootPart
            local targetPos = object:GetPivot().Position
            local dist = math.floor((targetPos - root.Position).Magnitude)
            distanceText = " [" .. dist .. "m]"
        end
    end
    
    if billboard and highlight then
        local label = billboard:FindFirstChildOfClass("TextLabel")
        if label then 
            label.Text = text .. distanceText
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
    bGui.Size = UDim2.new(0, 200, 0, 40)
    bGui.AlwaysOnTop = true
    bGui.StudsOffset = Vector3.new(0, 2.5, 0)
    bGui.Parent = object
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text .. distanceText
    label.TextColor3 = color 
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 14
    label.Parent = bGui
end

local function RemoveESP(object, id)
    if not object then return end
    local highlight = object:FindFirstChild("LocalHighlight_" .. id)
    local billboard = object:FindFirstChild("LocalText_" .. id)
    if highlight then highlight:Destroy() end
    if billboard then billboard:Destroy() end
end

-- Стриминг циклы сканирования карты
task.spawn(function()
    while task.wait(0.3) do
        pcall(function()
            local rooms = workspace:FindFirstChild("CurrentRooms")
            local currentRoomNum = GetCurrentRoomNumber()
            if rooms then
                for _, room in pairs(rooms:GetChildren()) do
                    local roomNum = tonumber(room.Name) or 0
                    local door = room:FindFirstChild("Door")
                    if door then
                        local actualDoor = door:FindFirstChild("Door") or door
                        if roomNum < currentRoomNum then RemoveESP(actualDoor, "Door")
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
    while task.wait(0.2) do
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
    while task.wait(0.3) do
        pcall(function()
            local rooms = workspace:FindFirstChild("CurrentRooms")
            local currentRoomNum = GetCurrentRoomNumber()
            if rooms then
                for _, room in pairs(rooms:GetChildren()) do
                    local roomNum = tonumber(room.Name) or 0
                    for _, asset in pairs(room:GetDescendants()) do
                        if roomNum < currentRoomNum then RemoveESP(asset, "Item")
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
    while task.wait(0.4) do
        pcall(function()
            local rooms = workspace:FindFirstChild("CurrentRooms")
            local currentRoomNum = GetCurrentRoomNumber()
            if rooms then
                for _, room in pairs(rooms:GetChildren()) do
                    local roomNum = tonumber(room.Name) or 0
                    for _, asset in pairs(room:GetDescendants()) do
                        if roomNum < currentRoomNum then RemoveESP(asset, "Hiding")
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

-- =============================================================================
-- СТАРЫЕ ЦИКЛЫ И ПРОЦЕССЫ ИЗ БЕКАПА
-- =============================================================================
game:GetService("RunService").RenderStepped:Connect(function()
    pcall(function()
        if game.Players.LocalPlayer.Character.Humanoid.MoveDirection.Magnitude > 0 then
            game.Players.LocalPlayer.Character:TranslateBy(game.Players.LocalPlayer.Character.Humanoid.MoveDirection * TargetWalkspeed/50)
        end
        local camera = workspace.CurrentCamera
        if camera and camera.FieldOfView ~= _G.CustomFOV then camera.FieldOfView = _G.CustomFOV end
    end)
end)

game:GetService("Workspace").CurrentRooms.DescendantAdded:Connect(function(descendant)
    if Flags.NoSeek == true and descendant.Name == ("Seek_Arm" or "ChandelierObstruction") then
        task.spawn(function() wait() descendant:Destroy() end)
    end
end)

game:GetService("ProximityPromptService").PromptButtonHoldBegan:Connect(function(prompt)
    if Flags.InstantToggle == true then fireproximityprompt(prompt) end
end)

workspace.CurrentCamera.ChildAdded:Connect(function(child)
    if child.Name == "Screech" and Flags.ScreechToggle == true then child:Destroy() end
end)

local function ApplyKeyChams(inst)
    wait()
    local Cham = Instance.new("Highlight")
    Cham.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    Cham.FillColor = Color3.new(0.980392, 0.670588, 0)
    Cham.FillTransparency = 0.5
    Cham.OutlineColor = Color3.new(0.792156, 0.792156, 0.792156)
    Cham.Parent = game:GetService("CoreGui")
    Cham.Adornee = inst
    Cham.Enabled = Flags.KeyToggle
    return Cham
end

local KeyChamsList = {}
workspace.CurrentRooms.DescendantAdded:Connect(function(inst)
    if inst.Name == "KeyObtain" then table.insert(KeyChamsList, ApplyKeyChams(inst)) end
end)

-- Автоклиент пропуска уровней (AutoSkip)
task.spawn(function()
    while true do
        task.wait()
        pcall(function()
            if Flags.AutoSkip == true and game:GetService("ReplicatedStorage").GameData.LatestRoom.Value < 100 then
                local HasKey = false
                local LRoom = game:GetService("ReplicatedStorage").GameData.LatestRoom.Value
                local CurrentDoor = workspace.CurrentRooms[tostring(LRoom)]:WaitForChild("Door")
                for i,v in ipairs(CurrentDoor.Parent:GetDescendants()) do
                    if v.Name == "KeyObtain" then HasKey = v end
                end
                if HasKey then
                    game.Players.LocalPlayer.Character:PivotTo(CF(HasKey.Hitbox.Position))
                    task.wait(0.3)
                    fireproximityprompt(HasKey.ModulePrompt,0)
                    game.Players.LocalPlayer.Character:PivotTo(CF(CurrentDoor.Door.Position))
                    task.wait(0.3)
                    fireproximityprompt(CurrentDoor.Lock.UnlockPrompt,0)
                end
                if LRoom == 50 then CurrentDoor = workspace.CurrentRooms[tostring(LRoom+1)]:WaitForChild("Door") end
                game.Players.LocalPlayer.Character:PivotTo(CF(CurrentDoor.Door.Position))
                task.wait(0.3)
                CurrentDoor.ClientOpen:FireServer()
            end
        end)
    end
end)

-- Детектор сущностей и авто-эвейд уклонение
workspace.ChildAdded:Connect(function(inst)
    pcall(function()
        if (inst.Name == "RushMoving" or inst.Name == "AmbushMoving") and Flags.MobToggle then
            if Flags.AvoidRushToggle then
                local OldPos = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
                local con = game:GetService("RunService").Heartbeat:Connect(function()
                    game.Players.LocalPlayer.Character:MoveTo(OldPos + Vector3.new(0,20,0))
                end)
                inst.Destroying:Wait()
                con:Disconnect()
                game.Players.LocalPlayer.Character:MoveTo(OldPos)
            end
        end
    end)
end)
