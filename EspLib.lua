local EspLib = {
    Enabled = false,
    NPCs = false,
    TicketEsp = false,
    Boxes = false,
    Tracers = false,
    Players = false,
    highlight = false,
    Distance = false,
    Settings = {
        PlayerColor = Color3.fromRGB(255, 170, 0), -- Varsayılan oyuncu rengi
        DPlayerColor = Color3.fromRGB(255, 255, 255), -- Düşmüş oyuncu rengi 
        BoxColor = Color3.fromRGB(255, 0, 0),
        OutlineColor = Color3.fromRGB(0, 0, 0),
        TracerColor = Color3.fromRGB(255, 0, 0),
        PlayerTextColor = Color3.fromRGB(255, 255, 0),
        DistanceTextColor = Color3.fromRGB(255, 255, 255)
    }
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

local function drawESP(character, player)
    local highlight = nil
    if EspLib.highlight and not character:FindFirstChild("Highlight") then
        highlight = Instance.new("Highlight")
        highlight.Parent = character
        highlight.FillColor = EspLib.Settings.PlayerColor
        highlight.OutlineColor = EspLib.Settings.OutlineColor
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    end

    local tracer = Drawing.new("Line")
    local distanceText = Drawing.new("Text")
    local nameText = Drawing.new("Text")

    tracer.Color = EspLib.Settings.TracerColor
    tracer.Thickness = 2
    tracer.Transparency = 1

    distanceText.Size = 20
    distanceText.Color = EspLib.Settings.DistanceTextColor
    distanceText.Outline = true

    nameText.Size = 20
    nameText.Color = EspLib.Settings.PlayerTextColor
    nameText.Outline = true

    RunService.RenderStepped:Connect(function()
        if EspLib.Enabled and character and character:FindFirstChild("HumanoidRootPart") then
            local hrp = character.HumanoidRootPart
            local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

            if onScreen then
                if EspLib.Tracers then
                    tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                    tracer.Visible = true
                else
                    tracer.Visible = false
                end

                if EspLib.Players then
                    nameText.Position = Vector2.new(screenPos.X, screenPos.Y - 50)
                    nameText.Text = player.Name
                    nameText.Visible = true
                else
                    nameText.Visible = false
                end

                if EspLib.Distance then
                    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
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
        else
            tracer.Visible = false
            nameText.Visible = false
            distanceText.Visible = false
            if highlight then highlight.Enabled = false end
        end
    end)
end

local function setupESPForPlayer(player)
    if player.Character then
        drawESP(player.Character, player)
    end
    player.CharacterAdded:Connect(function(character)
        drawESP(character, player)
    end)
end

Players.PlayerAdded:Connect(setupESPForPlayer)
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        setupESPForPlayer(player)
    end
end

Players.PlayerRemoving:Connect(function(player)
    if player.Character then
        if player.Character:FindFirstChild("Highlight") then
            player.Character.Highlight:Destroy()
        end
    end
end)

print("ESP Kütüphanesi Yüklendi! 🎯")

return EspLib
