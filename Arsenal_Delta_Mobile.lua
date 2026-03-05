-- ============================================
--   ARSENAL HUB | S-Productions
--   Mobil Optimize | ESP + Fly + Speed Hack
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Mobil kontrol tespiti
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ============================================
-- AYARLAR
-- ============================================
local Settings = {
    ESP = { Enabled = false },
    Fly = { Enabled = false, Speed = 60 },
    Speed = { Enabled = false, Value = 50 },
}

-- ============================================
-- ESP SİSTEMİ
-- ============================================
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ArsenalESP"
ESPFolder.Parent = game.CoreGui

local ESPObjects = {}

local function CreateESP(player)
    if player == LocalPlayer then return end
    local esp = {}

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_" .. player.Name
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 130, 0, 65)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Enabled = false
    billboard.Parent = ESPFolder

    local nameLabel = Instance.new("TextLabel")
    nameLabel.BackgroundTransparency = 1
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Text = player.Name
    nameLabel.Parent = billboard

    local healthBg = Instance.new("Frame")
    healthBg.Size = UDim2.new(1, 0, 0.15, 0)
    healthBg.Position = UDim2.new(0, 0, 0.78, 0)
    healthBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    healthBg.BorderSizePixel = 0
    healthBg.Parent = billboard

    local healthBar = Instance.new("Frame")
    healthBar.Size = UDim2.new(1, 0, 1, 0)
    healthBar.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    healthBar.BorderSizePixel = 0
    healthBar.Parent = healthBg

    esp.Billboard = billboard
    esp.NameLabel = nameLabel
    esp.HealthBar = healthBar
    ESPObjects[player.Name] = esp

    RunService.Heartbeat:Connect(function()
        if not Settings.ESP.Enabled then
            billboard.Enabled = false
            return
        end
        local char = player.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                billboard.Adornee = hrp
                billboard.Enabled = true
                local hp = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                healthBar.Size = UDim2.new(hp, 0, 1, 0)
                healthBar.BackgroundColor3 = Color3.fromRGB(255 * (1 - hp), 255 * hp, 30)
                local dist = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude)
                nameLabel.Text = player.Name .. "  [" .. dist .. "m]"
            else
                billboard.Enabled = false
            end
        else
            billboard.Enabled = false
        end
    end)
end

local function RemoveESP(player)
    if ESPObjects[player.Name] then
        ESPObjects[player.Name].Billboard:Destroy()
        ESPObjects[player.Name] = nil
    end
end

Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)
for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end

-- ============================================
-- FLY SİSTEMİ (MOBİL UYUMLU)
-- ============================================
local flyConnection
local bodyVelocity, bodyGyro

-- Mobil için sanal yön vektörü
local mobileMove = Vector3.new(0, 0, 0)

local function EnableFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    hum.PlatformStand = true

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bodyVelocity.Parent = hrp

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bodyGyro.D = 100
    bodyGyro.Parent = hrp

    flyConnection = RunService.Heartbeat:Connect(function()
        if not Settings.Fly.Enabled then return end
        local camCF = Camera.CFrame
        local moveDir = Vector3.new(0, 0, 0)

        if isMobile then
            -- Mobil: thumbstick hareketi kameraya göre yön verir
            local moveVec = LocalPlayer.Character and
                LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and
                LocalPlayer.Character.HumanoidRootPart.AssemblyLinearVelocity or Vector3.zero

            -- Roblox'un kendi hareket sisteminden faydalanıyoruz
            local camLook = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z).Unit
            local camRight = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z).Unit

            moveDir = camLook * mobileMove.Z + camRight * mobileMove.X
            moveDir = moveDir + Vector3.new(0, mobileMove.Y, 0)
        else
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0,1,0) end
        end

        if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end
        bodyVelocity.Velocity = moveDir * Settings.Fly.Speed
        bodyGyro.CFrame = camCF
    end)

    -- Mobil: karakterin kendi hareketini fly ile birleştir
    if isMobile then
        RunService.Heartbeat:Connect(function()
            if not Settings.Fly.Enabled then return end
            local char2 = LocalPlayer.Character
            if not char2 then return end
            local hum2 = char2:FindFirstChildOfClass("Humanoid")
            if hum2 then
                local mv = hum2.MoveDirection
                mobileMove = Vector3.new(mv.X, 0, mv.Z)
            end
        end)
    end
end

local function DisableFly()
    if flyConnection then flyConnection:Disconnect() end
    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
    mobileMove = Vector3.new(0,0,0)
end

-- ============================================
-- SPEED HACK
-- ============================================
RunService.Heartbeat:Connect(function()
    if not Settings.Speed.Enabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = Settings.Speed.Value end
end)

-- ============================================
-- GUI
-- ============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SProductionsHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = game.CoreGui

-- Güvenli alan (notch vs için)
local inset = GuiService:GetGuiInset()

-- GUI boyutları mobil için büyütülmüş
local FRAME_W = isMobile and 320 or 300
local FRAME_H = isMobile and 430 or 400
local TOGGLE_H = isMobile and 62 or 55
local TEXT_SIZE = isMobile and 15 or 13
local TITLE_SIZE = isMobile and 20 or 18

-- ============================================
-- ANA FRAME
-- ============================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, FRAME_W, 0, FRAME_H)
MainFrame.Position = UDim2.new(0.5, -FRAME_W/2, 0.5, -FRAME_H/2)
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 16)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(220, 40, 40)
mainStroke.Thickness = 1.8
mainStroke.Parent = MainFrame

-- Arka plan gradient
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 14, 28)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 16)),
})
gradient.Rotation = 135
gradient.Parent = MainFrame

-- ============================================
-- BAŞLIK BÖLÜMÜ
-- ============================================
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 62)
TitleBar.BackgroundColor3 = Color3.fromRGB(18, 18, 32)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 14)

-- Kırmızı accent çizgi
local accentLine = Instance.new("Frame")
accentLine.Size = UDim2.new(0, 4, 0.7, 0)
accentLine.Position = UDim2.new(0, 14, 0.15, 0)
accentLine.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
accentLine.BorderSizePixel = 0
accentLine.Parent = TitleBar
Instance.new("UICorner", accentLine).CornerRadius = UDim.new(1, 0)

-- Şirket adı: S-Productions
local CompanyLabel = Instance.new("TextLabel")
CompanyLabel.Size = UDim2.new(1, -60, 0, 20)
CompanyLabel.Position = UDim2.new(0, 26, 0, 8)
CompanyLabel.BackgroundTransparency = 1
CompanyLabel.Font = Enum.Font.GothamBold
CompanyLabel.TextSize = 11
CompanyLabel.TextColor3 = Color3.fromRGB(180, 40, 40)
CompanyLabel.TextXAlignment = Enum.TextXAlignment.Left
CompanyLabel.Text = "S-PRODUCTIONS"
CompanyLabel.Parent = TitleBar

-- Başlık
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -60, 0, 26)
TitleLabel.Position = UDim2.new(0, 26, 0, 28)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = TITLE_SIZE
TitleLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Text = "⚡ ARSENAL HUB"
TitleLabel.Parent = TitleBar

-- Kapat butonu (mobil için daha büyük)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, isMobile and 38 or 32, 0, isMobile and 38 or 32)
CloseBtn.Position = UDim2.new(1, -46, 0.5, isMobile and -19 or -16)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Text = "✕"
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

-- Minimize butonu (GUI'yi küçültme - mobil için önemli)
local MinFrame = Instance.new("Frame")
MinFrame.Size = UDim2.new(0, FRAME_W, 0, 62)
MinFrame.Position = MainFrame.Position
MinFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 16)
MinFrame.BorderSizePixel = 0
MinFrame.Visible = false
MinFrame.Active = true
MinFrame.Draggable = true
MinFrame.Parent = ScreenGui
Instance.new("UICorner", MinFrame).CornerRadius = UDim.new(0, 14)

local minStroke = Instance.new("UIStroke")
minStroke.Color = Color3.fromRGB(220, 40, 40)
minStroke.Thickness = 1.8
minStroke.Parent = MinFrame

local MinLabel = Instance.new("TextLabel")
MinLabel.Size = UDim2.new(1, -80, 1, 0)
MinLabel.Position = UDim2.new(0, 26, 0, 0)
MinLabel.BackgroundTransparency = 1
MinLabel.Font = Enum.Font.GothamBold
MinLabel.TextSize = 15
MinLabel.TextColor3 = Color3.fromRGB(220, 220, 240)
MinLabel.TextXAlignment = Enum.TextXAlignment.Left
MinLabel.Text = "⚡ ARSENAL HUB  •  S-PRODUCTIONS"
MinLabel.Parent = MinFrame

local ExpandBtn = Instance.new("TextButton")
ExpandBtn.Size = UDim2.new(0, isMobile and 38 or 32, 0, isMobile and 38 or 32)
ExpandBtn.Position = UDim2.new(1, -46, 0.5, isMobile and -19 or -16)
ExpandBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
ExpandBtn.Font = Enum.Font.GothamBold
ExpandBtn.TextSize = 16
ExpandBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ExpandBtn.Text = "▲"
ExpandBtn.Parent = MinFrame
Instance.new("UICorner", ExpandBtn).CornerRadius = UDim.new(0, 8)

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, isMobile and 38 or 32, 0, isMobile and 38 or 32)
MinBtn.Position = UDim2.new(1, -88, 0.5, isMobile and -19 or -16)
MinBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 80)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 16
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Text = "▼"
MinBtn.Parent = TitleBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 8)

MinBtn.MouseButton1Click:Connect(function()
    MinFrame.Position = MainFrame.Position
    MainFrame.Visible = false
    MinFrame.Visible = true
end)

ExpandBtn.MouseButton1Click:Connect(function()
    MainFrame.Position = MinFrame.Position
    MinFrame.Visible = false
    MainFrame.Visible = true
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ============================================
-- İÇERİK ALANI
-- ============================================
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, 0, 1, -68)
Content.Position = UDim2.new(0, 0, 0, 68)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = isMobile and 4 or 3
Content.ScrollBarImageColor3 = Color3.fromRGB(220, 40, 40)
Content.CanvasSize = UDim2.new(0, 0, 0, 370)
Content.ScrollingDirection = Enum.ScrollingDirection.Y
Content.Parent = MainFrame

-- ============================================
-- YARDIMCI FONKSİYONLAR
-- ============================================
local function SectionLabel(yPos, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -30, 0, 24)
    lbl.Position = UDim2.new(0, 15, 0, yPos)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextColor3 = Color3.fromRGB(200, 40, 40)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = "▸ " .. string.upper(text)
    lbl.Parent = Content
end

local function CreateToggle(yPos, labelText, onToggle)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -24, 0, TOGGLE_H)
    frame.Position = UDim2.new(0, 12, 0, yPos)
    frame.BackgroundColor3 = Color3.fromRGB(18, 18, 32)
    frame.BorderSizePixel = 0
    frame.Parent = Content
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

    local fStroke = Instance.new("UIStroke")
    fStroke.Color = Color3.fromRGB(35, 35, 60)
    fStroke.Thickness = 1
    fStroke.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -75, 1, 0)
    label.Position = UDim2.new(0, 16, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = TEXT_SIZE
    label.TextColor3 = Color3.fromRGB(215, 215, 235)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = labelText
    label.Parent = frame

    -- Toggle boyutu mobil için büyük
    local bgW = isMobile and 54 or 46
    local bgH = isMobile and 30 or 24
    local circW = isMobile and 22 or 18

    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, bgW, 0, bgH)
    toggleBg.Position = UDim2.new(1, -(bgW + 12), 0.5, -bgH/2)
    toggleBg.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
    toggleBg.BorderSizePixel = 0
    toggleBg.Parent = frame
    Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)

    local toggleCircle = Instance.new("Frame")
    toggleCircle.Size = UDim2.new(0, circW, 0, circW)
    toggleCircle.Position = UDim2.new(0, 4, 0.5, -circW/2)
    toggleCircle.BackgroundColor3 = Color3.fromRGB(140, 140, 170)
    toggleCircle.BorderSizePixel = 0
    toggleCircle.Parent = toggleBg
    Instance.new("UICorner", toggleCircle).CornerRadius = UDim.new(1, 0)

    local toggled = false
    local onPos = bgW - circW - 4

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = frame

    btn.MouseButton1Click:Connect(function()
        toggled = not toggled
        TweenService:Create(toggleCircle, TweenInfo.new(0.18), {
            Position = toggled and UDim2.new(0, onPos, 0.5, -circW/2) or UDim2.new(0, 4, 0.5, -circW/2),
            BackgroundColor3 = toggled and Color3.fromRGB(255,255,255) or Color3.fromRGB(140,140,170),
        }):Play()
        TweenService:Create(toggleBg, TweenInfo.new(0.18), {
            BackgroundColor3 = toggled and Color3.fromRGB(210, 35, 35) or Color3.fromRGB(45,45,65),
        }):Play()
        onToggle(toggled)
    end)
end

local function CreateSlider(yPos, labelText, minVal, maxVal, defaultVal, onChange)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -24, 0, TOGGLE_H)
    frame.Position = UDim2.new(0, 12, 0, yPos)
    frame.BackgroundColor3 = Color3.fromRGB(18, 18, 32)
    frame.BorderSizePixel = 0
    frame.Parent = Content
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

    local fStroke = Instance.new("UIStroke")
    fStroke.Color = Color3.fromRGB(35, 35, 60)
    fStroke.Thickness = 1
    fStroke.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.68, 0, 0, 22)
    label.Position = UDim2.new(0, 16, 0, 6)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = TEXT_SIZE
    label.TextColor3 = Color3.fromRGB(200, 200, 220)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = labelText
    label.Parent = frame

    local valLabel = Instance.new("TextLabel")
    valLabel.Size = UDim2.new(0.3, -10, 0, 22)
    valLabel.Position = UDim2.new(0.7, 0, 0, 6)
    valLabel.BackgroundTransparency = 1
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextSize = TEXT_SIZE
    valLabel.TextColor3 = Color3.fromRGB(210, 35, 35)
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.Text = tostring(defaultVal)
    valLabel.Parent = frame

    -- Slider track - mobil için daha kalın
    local trackH = isMobile and 8 or 6
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -32, 0, trackH)
    track.Position = UDim2.new(0, 16, 0, TOGGLE_H - trackH - 10)
    track.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
    track.BorderSizePixel = 0
    track.Parent = frame
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local ratio = (defaultVal - minVal) / (maxVal - minVal)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(ratio, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(210, 35, 35)
    fill.BorderSizePixel = 0
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    -- Sürükleme noktası (mobil için büyük)
    local knobSize = isMobile and 20 or 14
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, knobSize, 0, knobSize)
    knob.Position = UDim2.new(ratio, -knobSize/2, 0.5, -knobSize/2)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.ZIndex = 2
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local dragging = false

    -- Dokunma desteği (mobil)
    local touchBtn = Instance.new("TextButton")
    touchBtn.Size = UDim2.new(1, 0, 3, 0)
    touchBtn.Position = UDim2.new(0, 0, 0.5, -trackH * 1.5)
    touchBtn.BackgroundTransparency = 1
    touchBtn.Text = ""
    touchBtn.ZIndex = 3
    touchBtn.Parent = track

    local function updateSlider(inputX)
        local trackAbsX = track.AbsolutePosition.X
        local trackAbsW = track.AbsoluteSize.X
        local r = math.clamp((inputX - trackAbsX) / trackAbsW, 0, 1)
        local val = math.floor(minVal + r * (maxVal - minVal))
        fill.Size = UDim2.new(r, 0, 1, 0)
        knob.Position = UDim2.new(r, -knobSize/2, 0.5, -knobSize/2)
        valLabel.Text = tostring(val)
        onChange(val)
    end

    touchBtn.MouseButton1Down:Connect(function() dragging = true end)

    -- Dokunma olayları (mobil)
    touchBtn.TouchStarted:Connect(function(touch)
        dragging = true
        updateSlider(touch.Position.X)
    end)
    touchBtn.TouchMoved:Connect(function(touch)
        if dragging then updateSlider(touch.Position.X) end
    end)
    touchBtn.TouchEnded:Connect(function()
        dragging = false
    end)

    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or
           inp.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    RunService.Heartbeat:Connect(function()
        if dragging then
            local pos = UserInputService:GetMouseLocation()
            updateSlider(pos.X)
        end
    end)
end

-- ============================================
-- TOGGLELAR VE SLIDERLAR
-- ============================================

-- ESP
SectionLabel(8, "ESP")
CreateToggle(32, "👁  Oyuncu ESP", function(on)
    Settings.ESP.Enabled = on
    if not on then
        for _, esp in pairs(ESPObjects) do
            esp.Billboard.Enabled = false
        end
    end
end)

-- FLY
SectionLabel(106, "Fly")
CreateToggle(130, "🕊  Uçma Modu", function(on)
    Settings.Fly.Enabled = on
    if on then EnableFly() else DisableFly() end
end)
CreateSlider(204, "Uçuş Hızı", 10, 200, 60, function(val)
    Settings.Fly.Speed = val
end)

-- SPEED
SectionLabel(278, "Speed")
CreateToggle(302, "⚡  Speed Hack", function(on)
    Settings.Speed.Enabled = on
    if not on then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end
    end
end)
CreateSlider(375, "Hız Değeri", 16, 200, 50, function(val)
    Settings.Speed.Value = val
end)

-- Canvas boyutunu ayarla
Content.CanvasSize = UDim2.new(0, 0, 0, 445)

-- ============================================
-- WATERMARK (alt bilgi)
-- ============================================
local watermark = Instance.new("TextLabel")
watermark.Size = UDim2.new(1, -24, 0, 22)
watermark.Position = UDim2.new(0, 12, 1, -28)
watermark.BackgroundTransparency = 1
watermark.Font = Enum.Font.Gotham
watermark.TextSize = 10
watermark.TextColor3 = Color3.fromRGB(80, 80, 110)
watermark.TextXAlignment = Enum.TextXAlignment.Center
watermark.Text = "S-Productions  •  Arsenal Hub  •  Mobile Edition"
watermark.Parent = MainFrame

-- ============================================
-- YÜKLENİYOR BİLDİRİMİ
-- ============================================
local notif = Instance.new("Frame")
notif.Size = UDim2.new(0, 260, 0, 44)
notif.Position = UDim2.new(0.5, -130, 1, 10)
notif.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
notif.BorderSizePixel = 0
notif.Parent = ScreenGui
Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 10)

local notifText = Instance.new("TextLabel")
notifText.Size = UDim2.new(1, 0, 1, 0)
notifText.BackgroundTransparency = 1
notifText.Font = Enum.Font.GothamBold
notifText.TextSize = 13
notifText.TextColor3 = Color3.fromRGB(255, 255, 255)
notifText.Text = "✓  S-Productions Hub Yüklendi!"
notifText.Parent = notif

TweenService:Create(notif, TweenInfo.new(0.6, Enum.EasingStyle.Back), {
    Position = UDim2.new(0.5, -130, 1, -60)
}):Play()

task.delay(3.5, function()
    TweenService:Create(notif, TweenInfo.new(0.4), {
        Position = UDim2.new(0.5, -130, 1, 10),
        BackgroundTransparency = 1,
    }):Play()
    TweenService:Create(notifText, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
    task.delay(0.5, function() notif:Destroy() end)
end)

print("[S-Productions] Arsenal Hub - Mobil Optimizeli Script Yüklendi!")
