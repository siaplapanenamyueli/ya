-- =============================================
-- FISH & MONSTERS - SCRIPT FIX
-- Developer: XyzeDev
-- Discord: https://discord.gg/xyzedev
-- =============================================

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local mouse = player:GetMouse()
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

-- =============================================
-- AUTO FARM (DENGAN MEKANIK REEL CEPAT)
-- =============================================
local autoFarm = false
local function toggleFarm()
    autoFarm = not autoFarm
    notify("Auto Farm: " .. (autoFarm and "ON" or "OFF"))
    
    if autoFarm then
        spawn(function()
            while autoFarm do
                pcall(function()
                    -- 1. CAST (Klik tahan untuk charge)
                    local castRemote = game:GetService("ReplicatedStorage"):FindFirstChild("CastRod") or 
                                       game:GetService("ReplicatedStorage"):FindFirstChild("Cast")
                    if castRemote then
                        castRemote:FireServer()
                        wait(1.5) -- Waktu charge
                    end
                    
                    -- 2. TUNGGU GIGITAN
                    wait(3)
                    
                    -- 3. REEL CEPAT (Klik cepat untuk isi progress bar)
                    local reelRemote = game:GetService("ReplicatedStorage"):FindFirstChild("ReelIn") or 
                                       game:GetService("ReplicatedStorage"):FindFirstChild("Reel")
                    if reelRemote then
                        for i = 1, 10 do
                            reelRemote:FireServer()
                            wait(0.1) -- Klik cepat 10x
                        end
                    end
                    
                    wait(2)
                end)
                wait()
            end
        end)
    end
end

-- =============================================
-- AUTO REEL (OTOMATIS REEL SAAT IKAN GIGIT)
-- =============================================
local autoReel = false
local function toggleReel()
    autoReel = not autoReel
    notify("Auto Reel: " .. (autoReel and "ON" or "OFF"))
    
    if autoReel then
        spawn(function()
            while autoReel do
                pcall(function()
                    -- Deteksi notifikasi gigitan
                    local gui = player:FindFirstChild("PlayerGui")
                    if gui then
                        for _, obj in pairs(gui:GetDescendants()) do
                            if obj:IsA("TextLabel") and (obj.Text:lower():find("bite") or obj.Text:lower():find("gigit")) then
                                local reel = game:GetService("ReplicatedStorage"):FindFirstChild("ReelIn") or 
                                             game:GetService("ReplicatedStorage"):FindFirstChild("Reel")
                                if reel then
                                    for i = 1, 15 do
                                        reel:FireServer()
                                        wait(0.08)
                                    end
                                end
                            end
                        end
                    end
                end)
                wait(0.5)
            end
        end)
    end
end

-- =============================================
-- AUTO BAIT (PASANG UMPAN OTOMATIS)
-- =============================================
local autoBait = false
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
                                local baitRemote = game:GetService("ReplicatedStorage"):FindFirstChild("UseBait") or 
                                                   game:GetService("ReplicatedStorage"):FindFirstChild("Bait")
                                if baitRemote then
                                    baitRemote:FireServer(item.Name)
                                    wait(0.5)
                                end
                            end
                        end
                    end
                end)
                wait(10)
            end
        end)
    end
end

-- =============================================
-- AUTO SELL (JUAL IKAN OTOMATIS)
-- =============================================
local autoSell = false
local function toggleSell()
    autoSell = not autoSell
    notify("Auto Sell: " .. (autoSell and "ON" or "OFF"))
    
    if autoSell then
        spawn(function()
            while autoSell do
                pcall(function()
                    local sellRemote = game:GetService("ReplicatedStorage"):FindFirstChild("SellFish") or 
                                      game:GetService("ReplicatedStorage"):FindFirstChild("Sell")
                    if sellRemote then
                        sellRemote:FireServer()
                        wait(1)
                    end
                end)
                wait(3)
            end
        end)
    end
end

-- =============================================
-- AUTO UPGRADE ROD
-- =============================================
local autoUpgrade = false
local function toggleUpgrade()
    autoUpgrade = not autoUpgrade
    notify("Auto Upgrade Rod: " .. (autoUpgrade and "ON" or "OFF"))
    
    if autoUpgrade then
        spawn(function()
            while autoUpgrade do
                pcall(function()
                    local upRemote = game:GetService("ReplicatedStorage"):FindFirstChild("UpgradeRod") or 
                                    game:GetService("ReplicatedStorage"):FindFirstChild("LevelUp")
                    if upRemote then
                        upRemote:FireServer()
                        wait(2)
                    end
                end)
                wait(5)
            end
        end)
    end
end

-- =============================================
-- AUTO DROP (BUANG IKAN JELEK)
-- =============================================
local autoDrop = false
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
                                    wait(0.3)
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

-- =============================================
-- FISH FINDER (CARI SPOT IKAN TERBAIK)
-- =============================================
local function fishFinder()
    notify("Searching for best fishing spot...")
    pcall(function()
        local best = nil
        local count = 0
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Part") and (obj.Name:lower():find("fish") or obj.Name:lower():find("water") or obj.Name:lower():find("spot")) then
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
            notify("Spot found! (" .. count .. " fish nearby)")
        else
            -- Alternatif: cari warna air yang lebih gelap (spot ikan)
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Part") and obj.Material == Enum.Material.Water then
                    rootPart.CFrame = obj.CFrame * CFrame.new(0, 2, 5)
                    notify("Found water spot!")
                    return
                end
            end
            notify("No fishing spot found!")
        end
    end)
end

-- =============================================
-- MEGA CATCH (IKAN LEGENDARIS)
-- =============================================
local function megaCatch()
    notify("Attempting to catch legendary fish...")
    pcall(function()
        local megaRemote = game:GetService("ReplicatedStorage"):FindFirstChild("MegaCatch") or 
                          game:GetService("ReplicatedStorage"):FindFirstChild("BossFish") or
                          game:GetService("ReplicatedStorage"):FindFirstChild("Legendary")
        if megaRemote then
            megaRemote:FireServer()
            notify("Legendary fish hunt activated!")
        else
            notify("Mega Catch not available!")
        end
    end)
end

-- =============================================
-- SEA MONSTER RAID
-- =============================================
local function seaMonsterRaid()
    notify("Joining Sea Monster Raid...")
    pcall(function()
        local raidRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Raid") or 
                          game:GetService("ReplicatedStorage"):FindFirstChild("MonsterRaid") or
                          game:GetService("ReplicatedStorage"):FindFirstChild("BossRaid")
        if raidRemote then
            raidRemote:FireServer()
            notify("Raid joined! Fight the monster!")
        else
            notify("Sea Monster Raid not available!")
        end
    end)
end

-- =============================================
-- TREASURE HUNT
-- =============================================
local function treasureHunt()
    notify("Starting treasure hunt...")
    pcall(function()
        local treasureRemote = game:GetService("ReplicatedStorage"):FindFirstChild("TreasureHunt") or 
                              game:GetService("ReplicatedStorage"):FindFirstChild("Treasure")
        if treasureRemote then
            treasureRemote:FireServer()
            notify("Treasure hunt activated!")
        else
            notify("Treasure hunt not available!")
        end
    end)
end

-- =============================================
-- FISH STATS
-- =============================================
local function fishStats()
    pcall(function()
        local stats = {}
        local inv = player:FindFirstChild("Backpack") or player:FindFirstChild("Inventory")
        if inv then
            for _, item in pairs(inv:GetChildren()) do
                if item:IsA("Tool") and (item.Name:lower():find("fish") or item.Name:lower():find("catch")) then
                    stats[item.Name] = (stats[item.Name] or 0) + 1
                end
            end
        end
        local msg = "Fish Collection:\n"
        for name, count in pairs(stats) do
            msg = msg .. name .. ": " .. count .. "\n"
        end
        if next(stats) == nil then msg = "No fish caught yet!" end
        notify(msg)
    end)
end

-- =============================================
-- QUEST AUTO COMPLETE
-- =============================================
local function autoQuest()
    notify("Checking quests...")
    pcall(function()
        local questRemote = game:GetService("ReplicatedStorage"):FindFirstChild("CompleteQuest") or 
                           game:GetService("ReplicatedStorage"):FindFirstChild("Quest")
        if questRemote then
            questRemote:FireServer()
            notify("Quest completed!")
        else
            notify("Quest system not found!")
        end
    end)
end

-- =============================================
-- AUTO ALL
-- =============================================
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

-- =============================================
-- BUY ROD
-- =============================================
local function buyRod()
    notify("Buying rods...")
    pcall(function()
        local buyRemote = game:GetService("ReplicatedStorage"):FindFirstChild("BuyRod") or 
                         game:GetService("ReplicatedStorage"):FindFirstChild("PurchaseRod") or
                         game:GetService("ReplicatedStorage"):FindFirstChild("Buy")
        if buyRemote then
            for i = 1, 10 do
                buyRemote:FireServer(i)
                wait(0.2)
            end
            notify("Rods purchased!")
        end
    end)
end

-- =============================================
-- TELEPORT SPAWN / ISLAND
-- =============================================
local function teleportSpawn()
    pcall(function()
        local spawns = workspace:FindFirstChild("Spawns") or workspace:FindFirstChild("SpawnLocation")
        if spawns then
            local point = spawns:GetChildren()[1] or spawns
            rootPart.CFrame = point.CFrame * CFrame.new(0, 3, 0)
            notify("Teleported to spawn!")
            return
        end
        for _, obj in pairs(workspace:GetChildren()) do
            if obj:IsA("SpawnLocation") then
                rootPart.CFrame = obj.CFrame * CFrame.new(0, 3, 0)
                notify("Teleported to spawn!")
                return
            end
        end
        notify("Spawn not found!")
    end)
end

-- =============================================
-- SPEED BOAT
-- =============================================
local function speedBoat()
    pcall(function()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("VehicleSeat") and (obj.Name:lower():find("boat") or obj.Parent and obj.Parent.Name:lower():find("boat")) then
                local dist = (obj.Position - rootPart.Position).Magnitude
                if dist < 50 then
                    obj.MaxSpeed = 350
                    obj.Torque = Vector3.new(999999, 0, 999999)
                    notify("Boat speed: MAX")
                    return
                end
            end
        end
        notify("No boat nearby!")
    end)
end

-- =============================================
-- SPEED HACK
-- =============================================
local speedHack = false
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

-- =============================================
-- JUMP HACK
-- =============================================
local jumpHack = false
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

-- =============================================
-- INFINITE YIELD
-- =============================================
game:GetService("RunService").Heartbeat:Connect(function()
    pcall(function()
        if speedHack then humanoid.WalkSpeed = 80 end
        if jumpHack then humanoid.JumpPower = 200 end
    end)
end)

-- =============================================
-- ANTI AFK
-- =============================================
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    pcall(function()
        local vu = game:GetService("VirtualUser")
        vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        wait(1)
        vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end)

-- =============================================
-- KEYBOARD SHORTCUTS (PC)
-- =============================================
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
    elseif k == Enum.KeyCode.R then seaMonsterRaid()
    elseif k == Enum.KeyCode.W then treasureHunt()
    elseif k == Enum.KeyCode.P then fishStats()
    elseif k == Enum.KeyCode.Q then autoQuest()
    elseif k == Enum.KeyCode.I then fishFinder()
    elseif k == Enum.KeyCode.Y then autoAll()
    elseif k == Enum.KeyCode.B then buyRod()
    elseif k == Enum.KeyCode.T then teleportSpawn()
    elseif k == Enum.KeyCode.V then speedBoat()
    elseif k == Enum.KeyCode.X then toggleSpeed()
    elseif k == Enum.KeyCode.Z then toggleJump()
    elseif k == Enum.KeyCode.H then
        notify("Developer: XyzeDev")
        notify("Discord: https://discord.gg/xyzedev")
    end
end)

-- =============================================
-- MOBILE UI
-- =============================================
if isMobile then
    spawn(function()
        wait(1)
        local sg = Instance.new("ScreenGui")
        sg.Name = "XyzeUI"
        sg.Parent = player:WaitForChild("PlayerGui")
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 200, 0, 580)
        frame.Position = UDim2.new(0, 10, 0.5, -290)
        frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
        frame.BackgroundTransparency = 0.15
        frame.BorderSizePixel = 0
        frame.Parent = sg
        
        local sf = Instance.new("ScrollingFrame")
        sf.Size = UDim2.new(1, -10, 1, -40)
        sf.Position = UDim2.new(0, 5, 0, 35)
        sf.BackgroundTransparency = 1
        sf.CanvasSize = UDim2.new(0, 0, 0, 750)
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
            {"Finder", fishFinder}, {"Mega", megaCatch}, {"Raid", seaMonsterRaid},
            {"Treasure", treasureHunt}, {"Stats", fishStats}, {"Quest", autoQuest},
            {"All", autoAll}, {"Buy Rod", buyRod}, {"Teleport", teleportSpawn},
            {"Boat", speedBoat}, {"Speed", toggleSpeed}, {"Jump", toggleJump},
            {"Info", function()
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
            b.BackgroundTransparency = 0.25
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

-- =============================================
-- STARTUP
-- =============================================
wait(1)
notify("Script Loaded! (Game: Fish & Monsters)")
notify("F=Farm L=Reel K=Bait J=Sell")
notify("N=Upgrade U=Drop M=Finder O=Mega")
notify("R=Raid W=Treasure P=Stats Q=Quest")
notify("Y=All B=Buy Rod T=Teleport")
notify("V=Boat X=Speed Z=Jump H=Info")

print("=========================================")
print("FISH AND MONSTERS - SCRIPT FIX")
print("Developer: XyzeDev")
print("Discord: https://discord.gg/xyzedev")
print("=========================================")
print("FITUR BERDASARKAN DESKRIPSI GAME:")
print("- Auto Farm (Cast + Reel Cepat)")
print("- Auto Reel (Saat ikan gigit)")
print("- Sea Monster Raid")
print("- Treasure Hunt")
print("- Auto Quest")
print("- Dan lainnya...")
print("=========================================")