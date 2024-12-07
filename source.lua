ADOLFLOCAL = game:GetService("Players").LocalPlayer

getgenv().Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    Workspace = game:GetService("Workspace")
}

getgenv().Settings = {
    Speed = 5,
    JumpHeight = 2,
    HitboxSize = 5,
    HitboxColor = Color3.new(0, 1, 1)
}

ADOLF = {}
ADOLF.SpeedToggle = false
ADOLF.HitboxToggle = false

UILIB = loadstring(game:HttpGet('https://raw.githubusercontent.com/topitbopit/dollarware/main/library.lua'))
UIADOLF = UILIB({
    rounding = false,
    theme = 'cherry',
    smoothDragging = false
})
UIADOLF.autoDisableToggles = true

WINDOW = UIADOLF.newWindow({
    text = 'Adolfware',
    resize = true,
    size = Vector2.new(550, 376),
    position = nil
})

PLAYERMENU = WINDOW:addMenu({
    text = 'Player'
})

PLAYERSECTION = PLAYERMENU:addSection({
    text = 'Player Settings',
    side = 'auto',
    showMinButton = true
})

PLAYERSECTION:addToggle({
    text = 'Enable CFrame Speed',
    state = false
}, function(state)
    ADOLF.SpeedToggle = state
end)

PLAYERSECTION:addSlider({
    text = 'Speed',
    min = 1,
    max = 20,
    step = 0.1,
    val = getgenv().Settings.Speed or 5
}, function(newSpeed)
    getgenv().Settings.Speed = newSpeed
end)

PLAYERSECTION:addSlider({
    text = 'Jump Height',
    min = 1,
    max = 10,
    step = 0.1,
    val = getgenv().Settings.JumpHeight or 2
}, function(newHeight)
    getgenv().Settings.JumpHeight = newHeight
end)

CREATEVISUALIZER = function(plr)
    if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then return nil end
    
    CHAR = plr.Character
    ROOTPART = CHAR.HumanoidRootPart
    
    VISUALPART = Instance.new("Part")
    VISUALPART.Name = "HitboxVisualizer"
    VISUALPART.Anchored = true
    VISUALPART.CanCollide = false
    VISUALPART.Transparency = 0.5
    VISUALPART.Parent = CHAR
    
    return VISUALPART
end

UPDATEHITBOX = function(plr)
    if not ADOLF.HitboxToggle then return end
    
    CHAR = plr.Character
    if not CHAR or not CHAR:FindFirstChild("HumanoidRootPart") then return end
    
    VISUALPART = CHAR:FindFirstChild("HitboxVisualizer")
    if not VISUALPART then
        VISUALPART = CREATEVISUALIZER(plr)
    end
    
    if not VISUALPART then return end
    
    ROOTPART = CHAR.HumanoidRootPart
    VISUALPART.Size = Vector3.new(getgenv().Settings.HitboxSize, getgenv().Settings.HitboxSize, getgenv().Settings.HitboxSize)
    VISUALPART.Color = getgenv().Settings.HitboxColor
    VISUALPART.CFrame = ROOTPART.CFrame
end

REMOVEHITBOX = function(plr)
    if plr.Character and plr.Character:FindFirstChild("HitboxVisualizer") then
        plr.Character.HitboxVisualizer:Destroy()
    end
end

getgenv().Services.RunService.Heartbeat:Connect(function()
    if ADOLF.HitboxToggle then
        for _, PLR in ipairs(getgenv().Services.Players:GetPlayers()) do
            if PLR ~= ADOLFLOCAL then
                UPDATEHITBOX(PLR)
            end
        end
    end
end)

getgenv().Services.RunService.Stepped:Connect(function()
    if ADOLF.SpeedToggle then
        if ADOLFLOCAL and ADOLFLOCAL.Character and ADOLFLOCAL.Character:FindFirstChild("HumanoidRootPart") then
            ROOTPART = ADOLFLOCAL.Character.HumanoidRootPart
            MOVEDIRECTION = ADOLFLOCAL.Character.Humanoid.MoveDirection
            ROOTPART.CFrame = ROOTPART.CFrame + (MOVEDIRECTION * (getgenv().Settings.Speed) * 0.1)
        end
    end
end)

getgenv().Services.UserInputService.JumpRequest:Connect(function()
    if ADOLFLOCAL and ADOLFLOCAL.Character and ADOLFLOCAL.Character:FindFirstChild("HumanoidRootPart") then
        ADOLFLOCAL.Character.HumanoidRootPart.Velocity = Vector3.new(0, (getgenv().Settings.JumpHeight) * 50, 0)
    end
end)

HITBOXMENU = WINDOW:addMenu({
    text = 'Hitbox Settings'
})

HITBOXSECTION = HITBOXMENU:addSection({
    text = 'Hitbox Controls',
    side = 'auto',
    showMinButton = true
})

HITBOXSECTION:addToggle({
    text = 'Enable Hitbox',
    state = false
}, function(state)
    ADOLF.HitboxToggle = state
    
    if not state then
        for _, PLR in ipairs(getgenv().Services.Players:GetPlayers()) do
            if PLR ~= ADOLFLOCAL then
                REMOVEHITBOX(PLR)
            end
        end
    end
end)

HITBOXSECTION:addSlider({
    text = 'Hitbox Size',
    min = 1,
    max = 20,
    step = 0.1,
    val = getgenv().Settings.HitboxSize or 5
}, function(newSize)
    getgenv().Settings.HitboxSize = newSize
end)

HITBOXSECTION:addColorPicker({
    text = 'Hitbox Color',
    color = getgenv().Settings.HitboxColor or Color3.new(0, 1, 1)
}, function(newColor)
    getgenv().Settings.HitboxColor = newColor
end)

getgenv().Services.Players.PlayerAdded:Connect(function(PLR)
    PLR.CharacterAdded:Connect(function()
        if ADOLF.HitboxToggle then
            task.wait(0.1)
            UPDATEHITBOX(PLR)
        end
    end)
end)

getgenv().Services.Players.PlayerRemoving:Connect(function(PLR)
    REMOVEHITBOX(PLR)
end)

for _, PLR in ipairs(getgenv().Services.Players:GetPlayers()) do
    if PLR ~= ADOLFLOCAL then
        PLR.CharacterAdded:Connect(function()
            if ADOLF.HitboxToggle then
                task.wait(0.1)
                UPDATEHITBOX(PLR)
            end
        end)
    end
end
