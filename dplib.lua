-- EspLib.lua

local dplib = {
    Enabled = false,
    NPCs = false,
    TicketEsp = false,
    Boxes = false,
    Tracers = false,
    Players = false,
    DPlayerESP = false, -- Düşmüş oyuncu ESP toggle
    highlight = false,
    Distance = false,
    Settings = {
        PlayerColor = Color3.fromRGB(255, 170, 0),
        DPlayerColor = Color3.fromRGB(255, 255, 255),
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

local function GetDownedPlr()
    local downedPlayers = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and player.Character:GetAttribute("Downed") then
            table.insert(downedPlayers, player)
        end
    end
    return downedPlayers
end

local function drawESP(character, player, isDowned)
    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Filled = false
    box.Color = isDowned and EspLib.Settings.DPlayerColor or EspLib.Settings.BoxColor

    RunService.RenderStepped:Connect(function()
        if EspLib.Enabled and character and character:FindFirstChild("HumanoidRootPart") then
            local hrp = character.HumanoidRootPart
            local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

            if onScreen then
                local size = Vector2.new(1000 / screenPos.Z, 1500 / screenPos.Z)
                box.Size = size
                box.Position = Vector2.new(screenPos.X - size.X / 2, screenPos.Y - size.Y / 2)
                box.Visible = (isDowned and EspLib.DPlayerESP) or (not isDowned)
            else
                box.Visible = false
            end
        else
            box.Visible = false
        end
    end)
end

local function setupESPForPlayer(player)
    if player.Character then
        local isDowned = player.Character:GetAttribute("Downed") or false
        drawESP(player.Character, player, isDowned)
    end
    player.CharacterAdded:Connect(function(character)
        local isDowned = character:GetAttribute("Downed") or false
        drawESP(character, player, isDowned)
    end)
end

Players.PlayerAdded:Connect(setupESPForPlayer)
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        setupESPForPlayer(player)
    end
end

RunService.RenderStepped:Connect(function()
    if EspLib.DPlayerESP then
        local downedPlayers = GetDownedPlr()
        for _, player in ipairs(downedPlayers) do
            if player.Character then
                drawESP(player.Character, player, true)
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if player.Character then
        if player.Character:FindFirstChild("Highlight") then
            player.Character.Highlight:Destroy()
        end
    end
end)

print("ESP Kütüphanesi Düşen Oyuncu Desteğiyle Yüklendi! 🎯")

return dplib
