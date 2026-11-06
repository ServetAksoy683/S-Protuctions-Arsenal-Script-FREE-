local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Arayüz (Ekranın tam ortası)
local sg = Instance.new("ScreenGui")
sg.Name = "OCYasinAimlock"
sg.ResetOnSpawn = false
sg.Parent = game:GetService("CoreGui")

local Main = Instance.new("Frame", sg)
Main.Size = UDim2.new(0, 250, 0, 180)
Main.Position = UDim2.new(0.5, -125, 0.5, -90) -- Ortada başlar
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.Active = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

-- Sürükleme Çubuğu
local TopBar = Instance.new("Frame", Main)
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TopBar.BorderSizePixel = 0
TopBar.Parent = Main
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -30, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "OÇ YASİN | AIMLOCK"
Title.TextColor3 = Color3.fromRGB(255, 100, 100)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Kapatma Butonu
local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -28, 0, 2)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

-- Aimlock Aç/Kapa Butonu
local AimBtn = Instance.new("TextButton", Main)
AimBtn.Size = UDim2.new(1, -20, 0, 45)
AimBtn.Position = UDim2.new(0, 10, 0, 45)
AimBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
AimBtn.Text = "AIMLOCK: KAPALI"
AimBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AimBtn.Font = Enum.Font.GothamBold
AimBtn.TextSize = 14
AimBtn.Parent = Main
Instance.new("UICorner", AimBtn).CornerRadius = UDim.new(0, 6)

-- Bilgi Yazısı
local Info = Instance.new("TextLabel", Main)
Info.Size = UDim2.new(1, -20, 0, 20)
Info.Position = UDim2.new(0, 10, 0, 95)
Info.BackgroundTransparency = 1
Info.Text = "Kilit Tuşu: Sağ Tık (Mouse2)"
Info.TextColor3 = Color3.fromRGB(150, 150, 150)
Info.Font = Enum.Font.Gotham
Info.TextSize = 11
Info.Parent = Main

-- Hedefleme Mantığı Değişkenleri
local AimAktif = false
local KilitTusunaBasildi = false
local HedefOyuncu = nil

-- En Yakın Hedefi Bulma Fonksiyonu (Kamera merkezine en yakın)
local function EnYakinHedefiBul()
    local enYakin = nil
    local enKisaMesafe = 500 -- Ekran merkezinden maksimum 500 piksel uzaklık

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hedefKafa = player.Character:FindFirstChild("Head")
            local hedefHum = player.Character:FindFirstChildOfClass("Humanoid")
            
            -- Hedefin canı var mı?
            if hedefKafa and hedefHum and hedefHum.Health > 0 then
                -- Hedefin ekrandaki 2D konumunu al
                local screenPos, onScreen = Camera:WorldToViewportPoint(hedefKafa.Position)
                
                if onScreen then
                    -- Ekranın tam merkezi
                    local merkezX = Camera.ViewportSize.X / 2
                    local merkezY = Camera.ViewportSize.Y / 2
                    
                    -- Merkez ile hedef arasındaki mesafe
                    local mesafe = math.sqrt((screenPos.X - merkezX)^2 + (screenPos.Y - merkezY)^2)
                    
                    if mesafe < enKisaMesafe then
                        enKisaMesafe = mesafe
                        enYakin = hedefKafa
                    end
                end
            end
        end
    end
    return enYakin
end

-- Aimlock Döngüsü
RunService.RenderStepped:Connect(function()
    if AimAktif and KilitTusunaBasildi then
        HedefOyuncu = EnYakinHedefiBul()
        
        if HedefOyuncu then
            -- Kamerayı hedefe doğru yumuşakça çevir (Lerp ile)
            -- Lerp değeri (0.2) düşük olduğu için aniden kilitlenmez, insan gibi hareket eder.
            local hedefPozisyon = HedefOyuncu.Position
            local mevcutCFrame = Camera.CFrame
            local yeniCFrame = CFrame.new(mevcutCFrame.Position, hedefPozisyon)
            
            Camera.CFrame = mevcutCFrame:Lerp(yeniCFrame, 0.2)
        end
    end
end)

-- Tuş Dinleyicisi (Sağ Tık - Mouse2)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        KilitTusunaBasildi = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        KilitTusunaBasildi = false
    end
end)

-- Aç/Kapa Butonu Mantığı
AimBtn.MouseButton1Click:Connect(function()
    AimAktif = not AimAktif
    if AimAktif then
        AimBtn.Text = "AIMLOCK: AÇIK"
        AimBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    else
        AimBtn.Text = "AIMLOCK: KAPALI"
        AimBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end
end)

-- Sürükleme Mantığı
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
