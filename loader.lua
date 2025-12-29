loader.lua local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

-- GUI
local PlayerGui = player:WaitForChild("PlayerGui")
local screen = Instance.new("ScreenGui", PlayerGui)
screen.Name = "PolarisHubOPv8.1"

local MainFrame = Instance.new("Frame", screen)
MainFrame.Size = UDim2.new(0,350,0,500) -- kompakt
MainFrame.Position = UDim2.new(0.5,-175,0.5,-250)
MainFrame.BackgroundColor3 = Color3.fromRGB(15,15,50)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0,15)

-- Watermark
local watermark = Instance.new("TextLabel", MainFrame)
watermark.Text = "Polaris Hub OP v8.1"
watermark.TextColor3 = Color3.fromRGB(255,255,255)
watermark.TextScaled = true
watermark.BackgroundTransparency = 1
watermark.Position = UDim2.new(0,10,0,10)
watermark.Size = UDim2.new(0,200,0,30)

-- Notifier
local function notify(text)
    local notif = Instance.new("TextLabel", PlayerGui)
    notif.Size = UDim2.new(0,250,0,50)
    notif.Position = UDim2.new(0.5,-125,0.1,0)
    notif.BackgroundColor3 = Color3.fromRGB(30,30,60)
    notif.TextColor3 = Color3.fromRGB(255,255,255)
    notif.TextScaled = true
    notif.Text = text
    notif.BackgroundTransparency = 0.3
    notif.BorderSizePixel = 0
    game:GetService("Debris"):AddItem(notif,2)
end

local function createButton(name,posX,posY,parent)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0,150,0,40) -- mindre knapp
    btn.Position = UDim2.new(0,posX,0,posY)
    btn.Text = name
    btn.TextScaled = true
    btn.BackgroundColor3 = Color3.fromRGB(40,40,90)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
    return btn
end

-- -------------------
-- Checkpoints
-- -------------------
local checkpoints = {}
local function setCheckpoint(slot) checkpoints[slot] = hrp.CFrame end
local function tpCheckpoint(slot) if checkpoints[slot] then hrp.CFrame = checkpoints[slot] end end

createButton("Set CP 1", 20, 60, MainFrame).MouseButton1Click:Connect(function() setCheckpoint(1) end)
createButton("Set CP 2", 180, 60, MainFrame).MouseButton1Click:Connect(function() setCheckpoint(2) end)
createButton("TP CP 1", 20, 110, MainFrame).MouseButton1Click:Connect(function() tpCheckpoint(1) end)
createButton("TP CP 2", 180, 110, MainFrame).MouseButton1Click:Connect(function() tpCheckpoint(2) end)

-- -------------------
-- TP Forward
-- -------------------
createButton("TP Forward Old", 20, 160, MainFrame).MouseButton1Click:Connect(function()
    hrp.CFrame = hrp.CFrame + hrp.CFrame.LookVector * 10
end)
createButton("TP Forward New", 180, 160, MainFrame).MouseButton1Click:Connect(function()
    hrp.CFrame = hrp.CFrame + hrp.CFrame.LookVector * 10
end)

-- -------------------
-- Boost Fly
-- -------------------
local flySpeed, flyTime, upBoost = 50, 10, 10
local flying, flyCooldown, lastFly = false, 5, 0
local flyBtn = createButton("Boost Fly", 20, 210, MainFrame)
flyBtn.MouseButton1Click:Connect(function()
    if flying or tick()-lastFly < flyCooldown then return end
    lastFly = tick()
    flying = true
    hrp.Velocity = Vector3.new(0,upBoost*10,0)
    task.wait(0.2)
    local startTime = tick()
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if tick()-startTime>flyTime then
            flying=false connection:Disconnect() hrp.Velocity=Vector3.new(0,0,0)
            notify("Boost Fly finished")
            return
        end
        local moveDir = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + hrp.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - hrp.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - hrp.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + hrp.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0,1,0) end
        if moveDir.Magnitude>0 then hrp.Velocity=moveDir.Unit*flySpeed end
    end)
end)

-- -------------------
-- Quantum Clone
-- -------------------
local Remote = ReplicatedStorage:WaitForChild("QuantumCloneSwap")
local cloneRange, cloneCooldown, lastClone = 10,5,0
local cloneBtn = createButton("Quantum Clone",180,210,MainFrame)
cloneBtn.MouseButton1Click:Connect(function()
    if tick()-lastClone<cloneCooldown then return end
    lastClone = tick()
    Remote:FireServer(cloneRange)
    notify("Quantum Clone activated")
end)

-- -------------------
-- Range Slider
-- -------------------
local sliderLabel = Instance.new("TextLabel", MainFrame)
sliderLabel.Size = UDim2.new(0,150,0,30)
sliderLabel.Position = UDim2.new(0,20,0,260)
sliderLabel.BackgroundTransparency = 1
sliderLabel.TextColor3 = Color3.fromRGB(255,255,255)
sliderLabel.Text = "Clone Range: "..cloneRange.." studs"
local slider = Instance.new("TextBox", MainFrame)
slider.Size = UDim2.new(0,150,0,30)
slider.Position = UDim2.new(0,20,0,290)
slider.Text = tostring(cloneRange)
slider.TextScaled = true
slider.FocusLost:Connect(function(enterPressed)
    local val = tonumber(slider.Text)
    if val and val>=1 and val<=50 then
        cloneRange = val
        sliderLabel.Text = "Clone Range: "..cloneRange.." studs"
    else
        slider.Text = tostring(cloneRange)
    end
end)

-- -------------------
-- Safe Mode
-- -------------------
local safeMode = false
local originalHipHeight = humanoid.HipHeight
local safeBtn = createButton("Safe Mode: OFF",20,330,MainFrame)
safeBtn.MouseButton1Click:Connect(function()
    safeMode = not safeMode
    if safeMode then humanoid.HipHeight=0 humanoid.WalkSpeed=16 safeBtn.Text="Safe Mode: ON" notify("Safe Mode: ON")
    else humanoid.HipHeight=originalHipHeight humanoid.WalkSpeed=16 safeBtn.Text="Safe Mode: OFF" notify("Safe Mode: OFF") end
end)

-- -------------------
-- God Mode
-- -------------------
local godMode = false
local sniperSound = Instance.new("Sound")
sniperSound.SoundId = "rbxassetid://INSERT_SNIPER_SOUND_ID"
sniperSound.Volume = 1
sniperSound.Parent = hrp
local godBtn = createButton("God Mode: OFF",180,330,MainFrame)
godBtn.MouseButton1Click:Connect(function()
    godMode = not godMode
    sniperSound:Play()
    if godMode then humanoid.PlatformStand=true godBtn.Text="God Mode: ON" notify("God Mode: ON")
    else humanoid.PlatformStand=false godBtn.Text="God Mode: OFF" notify("God Mode: OFF") end
end)

-- -------------------
-- Safe Teleport
-- -------------------
local safeTeleportBtn = createButton("Safe Teleport",20,380,MainFrame)
safeTeleportBtn.MouseButton1Click:Connect(function()
    local targetCFrame = CFrame.new(0,10,0) -- ändra till din base-position
    local flyTime = 10
    local flySpeed = 11
    local startTime = tick()
    notify("Safe Teleport started")
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if tick()-startTime>flyTime then
            connection:Disconnect()
            hrp.Velocity=Vector3.new(0,0,0)
            notify("Safe Teleport finished")
            return
        end
        local direction = (targetCFrame.Position-hrp.Position).Unit
        hrp.Velocity = direction*flySpeed
    end)
end)

print("Polaris Hub OP v8.1 Loaded – Compact GUI Ready!")
