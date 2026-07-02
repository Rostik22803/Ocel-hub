-- =============================================================================
-- DOORS LOCAL MEGA HUB v18.0 (HARDCORE HITBOX DESYNC)
-- =============================================================================

local oldGui = game:GetService("CoreGui"):FindFirstChild("DoorsLocalMegaHubFinal")
if oldGui then oldGui:Destroy() end

_G.DoorEspEnabled = false
_G.MonsterEspEnabled = false
_G.ItemEspEnabled = false
_G.HidingEspEnabled = false

_G.AntiA90 = false
_G.AntiScreech = false
_G.AntiSnare = false
_G.AntiTimothy = false
_G.AntiGiggle = false
_G.AntiEyes = false

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Создаем невидимый щит для блокировки Raycast (Защита от Глаз)
local EyeShield = Instance.new("Part")
EyeShield.Name = "ClientEyeShield"
EyeShield.Size = Vector3.new(20, 20, 0.1)
EyeShield.Transparency = 1
EyeShield.CanCollide = false
EyeShield.Anchored = true
EyeShield.Parent = workspace

-- =============================================================================
-- HARDCORE DEFUSE ENGINE
-- =============================================================================

RunService.Heartbeat:Connect(function()
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
