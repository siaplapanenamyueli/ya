-- FISH AND MONSTERS SCRIPT
-- BY XyzeDev
-- DISCORD: https://discord.gg/xyzedev

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local isMobile = game:GetService("UserInputService").TouchEnabled

local function notify(text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "XyzeDev Script",
            Text = tostring(text),
            Duration = 3
        })
    end)
end

local function findRemote(name)
    local events = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvents")
    if events then
        local found = events:FindFirstChild(name)
        if found then return found end
    end
    for _, obj in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
        if obj:IsA("RemoteEvent") and obj.Name:lower():find(name:lower()) then
            return obj
        end
    end
    return nil
end

-- VARIABLES
local autoFarm = false
local autoReel = false
local autoBait = false
local autoSell = false
local autoUpgrade = false
local autoDrop = false
local fishRadar = false
local speedHack = false
local jumpHack = false

-- AUTO FARM
local function toggleFarm()
    autoFarm = not autoFarm
    notify("Auto Farm: " .. (autoFarm and "ON" or "OFF"))
    if autoFarm then
        spawn(function()
            while autoFarm do
                pcall(function()
                    local cast = findRemote("CastRod") or findRemote("Cast")
                    local reel = findRemote("ReelIn") or findRemote("Reel")
                    if cast then cast:FireServer() end
                    wait(2)
                    if reel then reel:FireServer() end
                    wait(3)
                end)
                wait()
            end
        end)
    end
end

-- AUTO REEL
local function toggleReel()
    autoReel = not autoReel
    notify("Auto Reel: " .. (autoReel and "ON" or "OFF"))
    if autoReel then
        spawn(function()
            while autoReel do
                pcall(function()
                    local reel = findRemote("ReelIn") or findRemote("Reel")
                    if reel then reel:FireServer() end
                end)
                wait(2)
            end
        end)
    end
end

-- AUTO BAIT
local function toggleBait()
    autoBait = not autoBait
    notify("Auto Bait: " .. (autoBait and "ON" or "OFF"))
    if autoBait then
        spawn(function()
            while autoBait do
                pcall(function()
                    local bp = player:FindFirstChild("Backpack")
                    if bp then
                        for _, item in pairs(bp:GetChildren()) do
                            if item:IsA("Tool") and (item.Name:lower():find("bait") or item.Name:lower():find("worm")) then
                                local bait = findRemote("UseBait") or findRemote("Bait")
                                if bait then bait:FireServer(item.Name) end
                            end
                        end
                    end
                end)
                wait(10)
            end
        end)
    end
end

-- AUTO SELL
local function toggleSell()
    autoSell = not autoSell
    notify("Auto Sell: " .. (autoSell and "ON" or "OFF"))
    if autoSell then
        spawn(function()
            while autoSell do
                pcall(function()
                    local sell = findRemote("SellFish") or findRemote("Sell")
                    if sell then sell:FireServer() end
                end)
                wait(3)
            end
        end)
    end
end

-- AUTO UPGRADE
local function toggleUpgrade()
    autoUpgrade = not autoUpgrade
    notify("Auto Upgrade: " .. (autoUpgrade and "ON" or "OFF"))
    if autoUpgrade then
        spawn(function()
            while autoUpgrade do
                pcall(function()
                    local up = findRemote("UpgradeRod") or findRemote("LevelUp")
                    if up then up:FireServer() end
                end)
                wait(5)
            end
        end)
    end
end

-- AUTO DROP
local function toggleDrop()
    autoDrop = not autoDrop
    notify("Auto Drop: " .. (autoDrop and "ON" or "OFF"))
    if autoDrop then
        spawn(function()
            while autoDrop do
                pcall(function()
                    local bp = player:FindFirstChild("Backpack")
                    if bp then
                        for _, item in pairs(bp:GetChildren()) do
                            if item:IsA("Tool") and item.Name:lower():find("fish") then
                                if item.Name:lower():find("common") or item.Name:lower():find("small") then
                                    item.Parent = workspace
                                end
                            end
                        end
                    end
                end)
                wait(3)
            end
        end)
    end
end

-- FISH FINDER
local function fishFinder()
    notify("Finding best fishing spot...")
    pcall(function()
        local best = nil
        local count = 0
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Part") and (obj.Name:lower():find("fish") or obj.Name:lower():find("water")) then
                local c = 0
                for _, child in pairs(obj:GetChildren()) do
                    if child.Name:lower():find("fish") then c = c + 1 end
                end
                if c > count then
                    count = c
                    best = obj
                end
            end
        end
        if best then
            rootPart.CFrame = best.CFrame * CFrame.new(0, 2, 5)
            notify("Spot found! (" .. count .. " fish)")
        else
            notify("No fishing spot found!")
        end
    end)
end

-- MEGA CATCH
local function megaCatch()
    notify("Trying to catch legendary fish...")
    pcall(function()
        local mega = findRemote("MegaCatch") or findRemote("BossFish")
        if mega then
            mega:FireServer()
            notify("Legendary fishing activated!")
        else
            notify("Mega Catch not found!")
        end
    end)
end

-- FISH STATS
local function fishStats()
    pcall(function()
        local stats = {}
        local inv = player:FindFirstChild("Backpack")
        if inv then
            for _, item in pairs(inv:GetChildren()) do
                if item:IsA("Tool") and item.Name:lower():find("fish") then
                    stats[item.Name] = (stats[item.Name] or 0) + 1
                end
            end
        end
        local msg = "Fish Stats:\n"
        for name, count in pairs(stats) do
            msg = msg .. name .. ": " .. count .. "\n"
        end
        if next(stats) == nil then msg = "No fish caught yet!" end
        notify(msg)
    end)
end

-- FISH RADAR
local function toggleRadar()
    fishRadar = not fishRadar
    notify("Fish Radar: " .. (fishRadar and "ON" or "OFF"))
    if fishRadar then
        spawn(function()
            while fishRadar do
                pcall(function()
                    local c = 0
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj.Name:lower():find("fish") and obj:IsA("Model") and obj.PrimaryPart then
                            local dist = (obj.PrimaryPart.Position - rootPart.Position).Magnitude
                            if dist < 100 then c = c + 1 end
                        end
                    end
                    if c > 0 then notify(c .. " fish detected nearby!") end
                end)
                wait(5)
            end
        end)
    end
end

-- AUTO ALL
local function autoAll()
    toggleFarm()
    wait(1)
    toggleReel()
    wait(1)
    toggleBait()
    wait(1)
    toggleSell()
    wait(1)
    toggleUpgrade()
    wait(1)
    toggleDrop()
    notify("All fishing features activated!")
end

-- BUY ROD
local function buyRod()
    notify("Buying rods...")
    pcall(function()
        local buy = findRemote("BuyRod") or findRemote("Buy")
        if buy then
            for i = 1, 10 do
                buy:FireServer(i)
                wait(0.2)
            end
            notify("Rods purchased!")
        end
    end)
end

-- TELEPORT
local function teleport()
    pcall(function()
        local spawns = workspace:FindFirstChild("Spawns") or workspace:FindFirstChild("SpawnLocation")
        if spawns then
            local point = spawns:GetChildren()[1] or spawns
            rootPart.CFrame = point.CFrame * CFrame.new(0, 3, 0)
            notify("Teleported to spawn!")
        end
    end)
end

-- SPEED BOAT
local function boatSpeed()
    pcall(function()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("VehicleSeat") and (obj.Name:lower():find("boat") or obj.Parent:FindFirstChild("Boat")) then
                local dist = (obj.Position - rootPart.Position).Magnitude
                if dist < 50 then
                    obj.MaxSpeed = 300
                    notify("Boat speed: ON")
                    return
                end
            end
        end
        notify("No boat nearby!")
    end)
end

-- SPEED HACK
local function toggleSpeed()
    speedHack = not speedHack
    if speedHack then
        humanoid.WalkSpeed = 80
        notify("Speed: ON (80)")
    else
        humanoid.WalkSpeed = 16
        notify("Speed: OFF")
    end
end

-- JUMP HACK
local function toggleJump()
    jumpHack = not jumpHack
    if jumpHack then
        humanoid.JumpPower = 200
        notify("Jump: ON (200)")
    else
        humanoid.JumpPower = 50
        notify("Jump: OFF")
    end
end

-- ANTI AFK
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    pcall(function()
        local vu = game:GetService("VirtualUser")
        vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        wait(1)
        vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end)

-- KEYBOARD SHORTCUTS
game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
    if gp then return end
    local k = input.KeyCode
    if k == Enum.KeyCode.F then toggleFarm()
    elseif k == Enum.KeyCode.L then toggleReel()
    elseif k == Enum.KeyCode.K then toggleBait()
    elseif k == Enum.KeyCode.J then toggleSell()
    elseif k == Enum.KeyCode.N then toggleUpgrade()
    elseif k == Enum.KeyCode.U then toggleDrop()
    elseif k == Enum.KeyCode.M then fishFinder()
    elseif k == Enum.KeyCode.O then megaCatch()
    elseif k == Enum.KeyCode.P then fishStats()
    elseif k == Enum.KeyCode.I then toggleRadar()
    elseif k == Enum.KeyCode.Y then autoAll()
    elseif k == Enum.KeyCode.B then buyRod()
    elseif k == Enum.KeyCode.T then teleport()
    elseif k == Enum.KeyCode.V then boatSpeed()
    elseif k == Enum.KeyCode.X then toggleSpeed()
    elseif k == Enum.KeyCode.Z then toggleJump()
    elseif k == Enum.KeyCode.H then
        notify("Developer: XyzeDev")
        notify("Discord: https://discord.gg/xyzedev")
    end
end)

-- MOBILE UI
if isMobile then
    spawn(function()
        wait(1)
        local sg = Instance.new("ScreenGui")
        sg.Name = "XyzeUI"
        sg.Parent = player:WaitForChild("PlayerGui")
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 200, 0, 500)
        frame.Position = UDim2.new(0, 10, 0.5, -250)
        frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
        frame.BackgroundTransparency = 0.2
        frame.BorderSizePixel = 0
        frame.Parent = sg
        
        local sf = Instance.new("ScrollingFrame")
        sf.Size = UDim2.new(1, -10, 1, -40)
        sf.Position = UDim2.new(0, 5, 0, 35)
        sf.BackgroundTransparency = 1
        sf.CanvasSize = UDim2.new(0, 0, 0, 700)
        sf.ScrollBarThickness = 5
        sf.Parent = frame
        
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 30)
        title.Position = UDim2.new(0, 0, 0, 5)
        title.Text = "XyzeDev Script"
        title.TextColor3 = Color3.fromRGB(255, 200, 50)
        title.BackgroundTransparency = 1
        title.Font = Enum.Font.GothamBold
        title.TextSize = 16
        title.Parent = frame
        
        local btns = {
            {"Farm", toggleFarm}, {"Reel", toggleReel}, {"Bait", toggleBait},
            {"Sell", toggleSell}, {"Upgrade", toggleUpgrade}, {"Drop", toggleDrop},
            {"Finder", fishFinder}, {"Mega", megaCatch}, {"Stats", fishStats},
            {"Radar", toggleRadar}, {"All", autoAll}, {"Buy Rod", buyRod},
            {"Teleport", teleport}, {"Boat", boatSpeed}, {"Speed", toggleSpeed},
            {"Jump", toggleJump}, {"Info", function()
                notify("Developer: XyzeDev")
                notify("Discord: https://discord.gg/xyzedev")
            end}
        }
        
        for i, btn in pairs(btns) do
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(0.9, 0, 0, 30)
            b.Position = UDim2.new(0.05, 0, 0, 5 + (i-1) * 35)
            b.Text = btn[1]
            b.TextColor3 = Color3.fromRGB(255, 255, 255)
            b.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
            b.BackgroundTransparency = 0.3
            b.Font = Enum.Font.Gotham
            b.TextSize = 13
            b.BorderSizePixel = 0
            b.Parent = sf
            b.MouseButton1Click:Connect(btn[2])
        end
        
        local close = Instance.new("TextButton")
        close.Size = UDim2.new(0, 30, 0, 30)
        close.Position = UDim2.new(1, -35, 0, 5)
        close.Text = "X"
        close.TextColor3 = Color3.fromRGB(255, 255, 255)
        close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        close.Font = Enum.Font.GothamBold
        close.TextSize = 16
        close.BorderSizePixel = 0
        close.Parent = frame
        close.MouseButton1Click:Connect(function()
            frame.Visible = not frame.Visible
        end)
    end)
end

-- STARTUP
wait(1)
notify("Script Loaded!")
notify("F=Farm L=Reel K=Bait J=Sell")
notify("N=Upgrade U=Drop M=Finder O=Mega")
notify("P=Stats I=Radar Y=All B=Buy Rod")
notify("T=Teleport V=Boat X=Speed Z=Jump H=Info")

print("=========================================")
print("FISH AND MONSTERS SCRIPT")
print("Developer: XyzeDev")
print("Discord: https://discord.gg/xyzedev")
print("=========================================")