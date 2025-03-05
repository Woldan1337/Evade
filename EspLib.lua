-- EspLib.lua

local EspLib = {
    Enabled = true,
    Boxes = true,
    Tracers = true,
    Players = true,
    Distance = true,
    Settings = {
        BoxColor = Color3.fromRGB(255, 0, 0),          -- Kutu rengi (Kırmızı)
        OutlineColor = Color3.fromRGB(0, 0, 0),       -- Kenarlık rengi (Siyah)
        TracerColor = Color3.fromRGB(255, 0, 0),      -- Tracer rengi (Kırmızı)
        PlayerTextColor = Color3.fromRGB(255, 255, 0), -- Oyuncu adı rengi (Sarı)
        DistanceTextColor = Color3.fromRGB(255, 255, 255) -- Mesafe rengi (Beyaz)
    }
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

local function drawESP(character, player)
    -- Highlight (Kutu çizimi)
    if EspLib.Boxes and not character:FindFirstChild("Highlight") then
        local highlight = Instance.new("Highlight")
        highlight.Parent = character
        highlight.FillColor = EspLib.Settings.BoxColor
        highlight.OutlineColor = EspLib.Settings.OutlineColor
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    end

    -- Tracer çizgisi
    local tracer = Drawing.new("Line")
    tracer.Color = EspLib.Settings.TracerColor
    tracer.Thickness = 2
    tracer.Transparency = 1

    -- Mesafe metni
    local distanceText = Drawing.new("Text")
    distanceText.Size = 20
    distanceText.Color = EspLib.Settings.DistanceTextColor
    distanceText.Outline = true

    -- Oyuncu ismi metni
    local nameText = Drawing.new("Text")
    nameText.Size = 20
    nameText.Color = EspLib.Settings.PlayerTextColor
    nameText.Outline = true

    -- ESP güncelleme
    RunService.RenderStepped:Connect(function()
        if EspLib.Enabled and character and character:FindFirstChild("HumanoidRootPart") then
            local hrp = character.HumanoidRootPart
            local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local distance = (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude

                if onScreen then
                    -- Tracer çizgisi
                    if EspLib.Tracers then
                        tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                        tracer.Visible = true
                    else
                        tracer.Visible = false
                    end

                    -- Oyuncu ismi
                    if EspLib.Players then
                        nameText.Position = Vector2.new(screenPos.X, screenPos.Y - 50)
                        nameText.Text = player.Name
                        nameText.Visible = true
                    else
                        nameText.Visible = false
                    end

                    -- Mesafe bilgisi
                    if EspLib.Distance then
                        distanceText.Position = Vector2.new(screenPos.X, screenPos.Y - 30)
                        distanceText.Text = string.format("%.1f m", distance)
                        distanceText.Visible = true
                    else
                        distanceText.Visible = false
                    end
                else
                    tracer.Visible = false
                    nameText.Visible = false
                    distanceText.Visible = false
                end
            end
        else
            tracer.Visible = false
            nameText.Visible = false
            distanceText.Visible = false
        end
    end)
end

-- ESP kurulumu
local function setupESPForPlayer(player)
    if player.Character then
        drawESP(player.Character, player)
    end

    player.CharacterAdded:Connect(function(character)
        drawESP(character, player)
    end)
end

-- Oyunculara ESP ekleyelim
Players.PlayerAdded:Connect(function(player)
    setupESPForPlayer(player)
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        setupESPForPlayer(player)
    end
end

-- Oyuncu çıkarsa highlight kaldır
Players.PlayerRemoving:Connect(function(player)
    if player.Character and player.Character:FindFirstChild("Highlight") then
        player.Character.Highlight:Destroy()
    end
end)

print("ESP Kütüphanesi Yüklendi! 🎯")

return EspLib
