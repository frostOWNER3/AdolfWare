local PlayerService = {
    Local = game:GetService("Players").LocalPlayer,
    Services = {
        Players = game:GetService("Players"),
        RunService = game:GetService("RunService"),
        UserInput = game:GetService("UserInputService"),
        Workspace = game:GetService("Workspace")
    }
}

getgenv().Config = {
    Enabled = false,
    LockKey = Enum.KeyCode.E,
    PredictionMultiplier = 0.1,
    Smoothness = 1
}

local ClientConfig = {
    Movement = {
        Speed = 5
    },
    Hitbox = {
        Size = 5,
        Color = Color3.new(0, 1, 1)
    }
}

local ClientState = {
    SpeedEnabled = false,
    HitboxEnabled = false,
    AimEnabled = false
}

local UILibrary = loadstring(game:HttpGet('https://raw.githubusercontent.com/topitbopit/dollarware/main/library.lua'))
local Interface = UILibrary({
    rounding = true,
    theme = 'watermelon',
    smoothDragging = true,
    autoDisableToggles = true
})

local MainWindow = Interface.newWindow({
    text = 'AdolfWare',
    resize = true,
    size = Vector2.new(550, 376)
})

local Camera = workspace.CurrentCamera
local Target = nil
local IsLocked = false

local HitboxManager = {}

function HitboxManager:CreateVisualizer(player)
    if not player or not player.Character then return end
    local character = player.Character
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local visualizer = Instance.new("Part")
    visualizer.Name = "HitboxVisualizer"
    visualizer.Anchored = true
    visualizer.CanCollide = false
    visualizer.Transparency = 0.5
    visualizer.Color = ClientConfig.Hitbox.Color
    visualizer.Size = Vector3.new(ClientConfig.Hitbox.Size, ClientConfig.Hitbox.Size, ClientConfig.Hitbox.Size)
    visualizer.Parent = character
    
    return visualizer
end

function HitboxManager:UpdateHitbox(player)
    if not ClientState.HitboxEnabled or not player or not player.Character then return end
    local character = player.Character
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local visualizer = character:FindFirstChild("HitboxVisualizer")
    if not visualizer then
        visualizer = self:CreateVisualizer(player)
        if not visualizer then return end
    end

    visualizer.Size = Vector3.new(ClientConfig.Hitbox.Size, ClientConfig.Hitbox.Size, ClientConfig.Hitbox.Size)
    visualizer.Color = ClientConfig.Hitbox.Color
    visualizer.CFrame = rootPart.CFrame
end

function HitboxManager:RemoveHitbox(player)
    if not player or not player.Character then return end
    local visualizer = player.Character:FindFirstChild("HitboxVisualizer")
    if visualizer then visualizer:Destroy() end
end

local MovementManager = {}

function MovementManager:UpdateSpeed()
    if not ClientState.SpeedEnabled then return end
    local character = PlayerService.Local.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    if not rootPart or not humanoid then return end

    local moveDirection = humanoid.MoveDirection
    local speedMultiplier = ClientConfig.Movement.Speed * 0.1
    local newPosition = rootPart.Position + (moveDirection * speedMultiplier)

    rootPart.Velocity = Vector3.new(rootPart.Velocity.X, rootPart.Velocity.Y, rootPart.Velocity.Z) -- Preserve jump velocity
    rootPart.CFrame = CFrame.new(newPosition, newPosition + rootPart.CFrame.LookVector)
end

PlayerService.Services.RunService.Stepped:Connect(function()
    MovementManager:UpdateSpeed()
end)

local function GetClosestPlayerToMouse()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in ipairs(PlayerService.Services.Players:GetPlayers()) do
        if player ~= PlayerService.Local and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local character = player.Character
            local humanoidRootPart = character.HumanoidRootPart
            local screenPoint = Camera:WorldToViewportPoint(humanoidRootPart.Position)
            local mousePos = PlayerService.Services.UserInput:GetMouseLocation()
            local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePos).Magnitude

            if distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = player
            end
        end
    end

    return closestPlayer
end

local function PredictPosition(target)
    if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
        return nil
    end

    local humanoidRootPart = target.Character.HumanoidRootPart
    local velocity = humanoidRootPart.Velocity
    local predictedPosition = humanoidRootPart.Position + (velocity * getgenv().Config.PredictionMultiplier)
    return predictedPosition
end

PlayerService.Services.UserInput.InputBegan:Connect(function(input)
    if input.KeyCode == getgenv().Config.LockKey and getgenv().Config.Enabled then
        if IsLocked then
            IsLocked = false
            Target = nil
        else
            Target = GetClosestPlayerToMouse()
            IsLocked = Target ~= nil
        end
    end
end)

PlayerService.Services.RunService.RenderStepped:Connect(function()
    if IsLocked and Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
        local predictedPosition = PredictPosition(Target)
        if predictedPosition then
            local newCFrame = CFrame.new(Camera.CFrame.Position, predictedPosition)
            Camera.CFrame = Camera.CFrame:Lerp(newCFrame, getgenv().Config.Smoothness)
        end
    end
end)

local function setupUI()
    local aimbotMenu = MainWindow:addMenu({ text = 'Aimbot Settings' })
    local aimbotSection = aimbotMenu:addSection({ text = 'Aimbot Controls', side = 'auto', showMinButton = false })

    aimbotSection:addToggle({ text = 'Enable Aimbot', state = false }, function(state)
        getgenv().Config.Enabled = state
    end)

    local hitboxMenu = MainWindow:addMenu({ text = 'Hitbox Settings' })
    local hitboxSection = hitboxMenu:addSection({ text = 'Hitbox Controls', side = 'auto', showMinButton = false })

    hitboxSection:addToggle({ text = 'Enable Hitbox', state = false }, function(state)
        ClientState.HitboxEnabled = state
    end)

    hitboxSection:addSlider({ text = 'Hitbox Size', min = 1, max = 20, step = 0.1, val = ClientConfig.Hitbox.Size }, function(size)
        ClientConfig.Hitbox.Size = size
    end)

    local movementMenu = MainWindow:addMenu({ text = 'Movement Settings' })
    local movementSection = movementMenu:addSection({ text = 'Movement Controls', side = 'auto', showMinButton = false })

    movementSection:addToggle({ text = 'Enable Speed Modification', state = false }, function(state)
        ClientState.SpeedEnabled = state
    end)

    movementSection:addSlider({ text = 'Speed Multiplier', min = 1, max = 20, step = 0.1, val = ClientConfig.Movement.Speed }, function(speed)
        ClientConfig.Movement.Speed = speed
    end)
end

setupUI()
