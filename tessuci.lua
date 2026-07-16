-- =============================================
-- 🐟 FISH & MONSTERS - SCRIPT LENGKAP 🐟
-- Dibuat oleh : XyzeDev
-- Discord : https://discord.gg/xyzedev
-- Support : SEMUA Executor & SEMUA Device
-- =============================================

-- CEK DEVICE (HP atau PC)
local isMobile = game:GetService("UserInputService").TouchEnabled

-- VARIABEL GLOBAL
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- FUNGSI NOTIF (Universal)
local function notify(text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "🐟 XyzeDev Script",
            Text = tostring(text),
            Duration = 3
        })
    end)
end

-- FUNGSI FIND REMOTE (Otomatis cari remote yang benar)
local function findRemote(remoteName)
    local remoteEvents = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvents")
    if remoteEvents then
        local found = remoteEvents:FindFirstChild(remoteName)
        if found then return found end
    end
    
    -- Cari di semua tempat jika tidak ditemukan
    for _, service in pairs(game:GetChildren()) do
        local found = service:FindFirstChild(remoteName)
        if found then return found end
    end
    
    for _, service in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do
        if service:IsA("RemoteEvent") and service.Name:lower():find(remoteName:lower()) then
            return service
        end
    end
    
    return nil
end

-- =============================================
-- 🎣 FITUR MEMANCING DASAR
-- =============================================

-- 1. AUTO FARM MANCING
local autoFarm = false
local function toggleAutoFarm()
    autoFarm = not autoFarm
    notify("🎣 Auto Farm: " .. (autoFarm and "AKTIF" or "MATI"))
    
    if autoFarm then
        spawn(function()
            while autoFarm and game:IsLoaded() do
                pcall(function()
                    local cast = findRemote("CastRod") or findRemote("Cast") or findRemote("Fish")
                    local reel = findRemote("ReelIn") or findRemote("Reel") or findRemote("ReelInFish")
                    
                    if cast then cast:FireServer() end
                    wait(2)
                    if reel then reel:FireServer() end
                    wait(3)
                end)
                game:GetService("RunService").Heartbeat:Wait()
            end
        end)
    end
end

-- 2. AUTO REEL (Otomatis menggulung saat ikan menggigit)
local autoReel = false
local function toggleAutoReel()
    autoReel = not autoReel
    notify("🔄 Auto Reel: " .. (autoReel and "AKTIF" or "MATI"))
    
    if autoReel then
        spawn(function()
            while autoReel and game:IsLoaded() do
                pcall(function()
                    local reelRemote = findRemote("ReelIn") or findRemote("Reel") or findRemote("CatchFish")
                    if reelRemote then
                        reelRemote:FireServer()
                        wait(0.5)
                    end
                end)
                wait(2)
            end
        end)
    end
end

-- 3. AUTO BAIT (Pasang umpan otomatis)
local autoBait = false
local function toggleAutoBait()
    autoBait = not autoBait
    notify("🎣 Auto Bait: " .. (autoBait and "AKTIF" or "MATI"))
    
    if autoBait then
        spawn(function()
            while autoBait and game:IsLoaded() do
                pcall(function()
                    local backpack = player:FindFirstChild("Backpack")
                    if backpack then
                        for _, item in pairs(backpack:GetChildren()) do
                            if item:IsA("Tool") and (item.Name:lower():find("bait") or item.Name:lower():find("worm")) then
                                local baitRemote = findRemote("UseBait") or findRemote("EquipBait") or findRemote("Bait")
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

-- 4. AUTO SELL IKAN (Jual ikan otomatis)
local autoSell = false
local function toggleAutoSell()
    autoSell = not autoSell
    notify("💰 Auto Sell Ikan: " .. (autoSell and "AKTIF" or "MATI"))
    
    if autoSell then
        spawn(function()
            while autoSell and game:IsLoaded() do
                pcall(function()
                    local sellRemote = findRemote("SellFish") or findRemote("Sell") or findRemote("SellAll")
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

-- 5. AUTO UPGRADE ROD (Upgrade joran otomatis)
local autoUpgrade = false
local function toggleAutoUpgrade()
    autoUpgrade = not autoUpgrade
    notify("🔧 Auto Upgrade Rod: " .. (autoUpgrade and "AKTIF" or "MATI"))
    
    if autoUpgrade then
        spawn(function()
            while autoUpgrade and game:IsLoaded() do
                pcall(function()
                    local upgradeRemote = findRemote("UpgradeRod") or findRemote("EnhanceRod") or findRemote("LevelUp")
                    if upgradeRemote then
                        upgradeRemote:FireServer()
                        wait(2)
                    end
                end)
                wait(5)
            end
        end)
    end
end

-- 6. AUTO DROP (Buang ikan yang tidak diinginkan)
local autoDrop = false
local function toggleAutoDrop()
    autoDrop = not autoDrop
    notify("🗑️ Auto Drop Ikan: " .. (autoDrop and "AKTIF" or "MATI"))
    
    if autoDrop then
        spawn(function()
            while autoDrop and game:IsLoaded() do
                pcall(function()
                    local backpack = player:FindFirstChild("Backpack")
                    if backpack then
                        for _, item in pairs(backpack:GetChildren()) do
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

-- 7. FISH FINDER (Cari spot ikan terbaik)
local function fishFinder()
    notify("🔍 Mencari spot ikan terbaik...")
    pcall(function()
        local bestSpot = nil
        local mostFish = 0
        
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Part") and (obj.Name:lower():find("fish") or obj.Name:lower():find("spawn") or obj.Name:lower():find("water")) then
                local fishCount = 0
                for _, child in pairs(obj:GetChildren()) do
                    if child.Name:lower():find("fish") then
                        fishCount = fishCount + 1
                    end
                end
                
                if fishCount > mostFish then
                    mostFish = fishCount
                    bestSpot = obj
                end
            end
        end
        
        if bestSpot then
            rootPart.CFrame = bestSpot.CFrame * CFrame.new(0, 2, 5)
            notify("✅ Spot ikan ditemukan! (" .. mostFish .. " ikan)")
        else
            notify("❌ Tidak ada spot ikan ditemukan!")
        end
    end)
end

-- 8. MEGA CATCH (Tangkap ikan besar otomatis)
local function megaCatch()
    notify("🐋 Mencari ikan besar...")
    pcall(function()
        local megaRemote = findRemote("MegaCatch") or findRemote("BossFish") or findRemote("Legendary")
        if megaRemote then
            megaRemote:FireServer()
            notify("✅ Memancing ikan legendaris!")
        else
            notify("❌ Fitur Mega Catch tidak ditemukan!")
        end
    end)
end

-- 9. FISH STATS (Lihat statistik ikan)
local function fishStats()
    pcall(function()
        local stats = {}
        local inventory = player:FindFirstChild("Inventory") or player:FindFirstChild("Backpack")
        
        if inventory then
            for _, item in pairs(inventory:GetChildren()) do
                if item:IsA("Tool") and item.Name:lower():find("fish") then
                    local name = item.Name
                    stats[name] = (stats[name] or 0) + 1
                end
            end
        end
        
        local message = "📊 Statistik Ikan:\n"
        for name, count in pairs(stats) do
            message = message .. name .. ": " .. count .. " ekor\n"
        end
        
        if next(stats) == nil then
            message = "📊 Belum ada ikan yang ditangkap!"
        end
        
        notify(message)
    end)
end

-- 10. FISH RADAR (Deteksi ikan di sekitar)
local fishRadar = false
local function toggleFishRadar()
    fishRadar = not fishRadar
    notify("📡 Fish Radar: " .. (fishRadar and "AKTIF" or "MATI"))
    
    if fishRadar then
        spawn(function()
            while fishRadar and game:IsLoaded() do
                pcall(function()
                    local fishCount = 0
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj.Name:lower():find("fish") and obj:IsA("Model") and obj.PrimaryPart then
                            local distance = (obj.PrimaryPart.Position - rootPart.Position).Magnitude
                            if distance < 100 then
                                fishCount = fishCount + 1
                            end
                        end
                    end
                    
                    if fishCount > 0 then
                        notify("🐟 " .. fishCount .. " ikan terdeteksi di sekitar!")
                    end
                end)
                wait(5)
            end
        end)
    end
end

-- 11. AUTO ALL (Aktifkan semua fitur memancing)
local function autoFishAll()
    toggleAutoFarm()
    wait(1)
    toggleAutoReel()
    wait(1)
    toggleAutoBait()
    wait(1)
    toggleAutoSell()
    wait(1)
    toggleAutoUpgrade()
    wait(1)
    toggleAutoDrop()
    wait(1)
    toggleFishRadar()
    notify("✅ Semua fitur memancing diaktifkan!")
end

-- =============================================
-- 🛒 FITUR SHOP & TELEPORT
-- =============================================

-- AUTO BUY ROD
local function autoBuyRod()
    notify("🔄 Membeli semua rod...")
    pcall(function()
        local buyRemote = findRemote("BuyRod") or findRemote("PurchaseRod") or findRemote("Buy")
        if buyRemote then
            for i = 1, 20 do
                buyRemote:FireServer(i)
                wait(0.2)
            end
            notify("✅ Berhasil membeli rod!")
        else
            for _, obj in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                if obj:IsA("RemoteEvent") and (obj.Name:lower():find("buy") or obj.Name:lower():find("purchase")) then
                    obj:FireServer(1)
                    wait(0.2)
                end
            end
            notify("✅ Selesai mencoba membeli rod!")
        end
    end)
end

-- TELEPORT SPAWN
local function teleportSpawn()
    pcall(function()
        local spawns = workspace:FindFirstChild("Spawns") or workspace:FindFirstChild("SpawnLocation")
        if spawns then
            local spawnPoint = spawns:GetChildren()[1] or spawns
            if spawnPoint then
                rootPart.CFrame = spawnPoint.CFrame * CFrame.new(0, 3, 0)
                notify("📍 Teleport ke Spawn!")
                return
            end
        end
        
        for _, obj in pairs(workspace:GetChildren()) do
            if obj:IsA("SpawnLocation") then
                rootPart.CFrame = obj.CFrame * CFrame.new(0, 3, 0)
                notify("📍 Teleport ke Spawn!")
                return
            end
        end
        notify("❌ Spawn tidak ditemukan!")
    end)
end

-- SPEED BOAT
local function speedBoat()
    pcall(function()
        local boat = nil
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("VehicleSeat") and (obj.Parent:FindFirstChild("Boat") or obj.Name:lower():find("boat")) then
                local distance = (obj.Position - rootPart.Position).Magnitude
                if distance < 50 then
                    boat = obj
                    break
                end
            end
        end
        
        if boat then
            boat.MaxSpeed = 300
            boat.Torque = Vector3.new(999999, 0, 999999)
            notify("🚤 Speed Boat: AKTIF (300)")
        else
            notify("❌ Tidak ada boat di dekatmu!")
        end
    end)
end

-- =============================================
-- 🏃 SPEED & JUMP HACK
-- =============================================

local speedHack = false
local function toggleSpeed()
    speedHack = not speedHack
    if speedHack then
        humanoid.WalkSpeed = 80
        notify("🏃 Speed Karakter: AKTIF (80)")
    else
        humanoid.WalkSpeed = 16
        notify("🏃 Speed Karakter: MATI")
    end
end

local jumpHack = false
local function toggleJump()
    jumpHack = not jumpHack
    if jumpHack then
        humanoid.JumpPower = 200
        notify("⬆ Jump Hack: AKTIF (200)")
    else
        humanoid.JumpPower = 50
        notify("⬆ Jump Hack: MATI")
    end
end

-- INFINITE YIELD (Anti Lag)
game:GetService("RunService").Heartbeat:Connect(function()
    pcall(function()
        if speedHack then
            humanoid.WalkSpeed = 80
        end
        if jumpHack then
            humanoid.JumpPower = 200
        end
    end)
end)

-- =============================================
-- 📱 UI UNTUK HP (Mobile)
-- =============================================

local function createMobileUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "XyzeDevUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    -- Background
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 240, 0, 650)
    frame.Position = UDim2.new(0, 10, 0.5, -325)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    -- Scroll Frame
    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Size = UDim2.new(1, -10, 1, -40)
    scrollingFrame.Position = UDim2.new(0, 5, 0, 35)
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 800)
    scrollingFrame.ScrollBarThickness = 5
    scrollingFrame.Parent = frame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 5)
    title.Text = "🐟 XyzeDev Script"
    title.TextColor3 = Color3.fromRGB(255, 200, 50)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = frame
    
    -- Semua tombol
    local allButtons = {
        -- Fitur Memancing
        {text = "🎣 Auto Farm", color = Color3.fromRGB(50, 200, 100), func = toggleAutoFarm},
        {text = "🔄 Auto Reel", color = Color3.fromRGB(50, 150, 255), func = toggleAutoReel},
        {text = "🎣 Auto Bait", color = Color3.fromRGB(200, 150, 50), func = toggleAutoBait},
        {text = "💰 Auto Sell", color = Color3.fromRGB(0, 200, 100), func = toggleAutoSell},
        {text = "🔧 Upgrade Rod", color = Color3.fromRGB(200, 100, 50), func = toggleAutoUpgrade},
        {text = "🗑️ Auto Drop", color = Color3.fromRGB(150, 100, 50), func = toggleAutoDrop},
        {text = "🔍 Fish Finder", color = Color3.fromRGB(255, 100, 200), func = fishFinder},
        {text = "🐋 Mega Catch", color = Color3.fromRGB(255, 50, 50), func = megaCatch},
        {text = "📊 Fish Stats", color = Color3.fromRGB(100, 200, 255), func = fishStats},
        {text = "📡 Fish Radar", color = Color3.fromRGB(0, 255, 200), func = toggleFishRadar},
        {text = "⚡ Auto All", color = Color3.fromRGB(255, 200, 0), func = autoFishAll},
        -- Fitur Lain
        {text = "🛒 Beli Rod", color = Color3.fromRGB(50, 150, 255), func = autoBuyRod},
        {text = "📍 Teleport", color = Color3.fromRGB(255, 100, 100), func = teleportSpawn},
        {text = "🚤 Speed Boat", color = Color3.fromRGB(100, 200, 255), func = speedBoat},
        {text = "🏃 Speed Hack", color = Color3.fromRGB(255, 200, 50), func = toggleSpeed},
        {text = "⬆ Jump Hack", color = Color3.fromRGB(200, 100, 255), func = toggleJump},
        -- Info
        {text = "💬 Discord", color = Color3.fromRGB(100, 50, 200), func = function()
            notify("👨‍💻 Developer: XyzeDev")
            notify("💬 Discord: https://discord.gg/xyzedev")
            setclipboard and setclipboard("https://discord.gg/xyzedev") or nil
        end},
    }
    
    for i, btn in pairs(allButtons) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0.9, 0, 0, 35)
        button.Position = UDim2.new(0.05, 0, 0, 5 + (i-1) * 40)
        button.Text = btn.text
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.BackgroundColor3 = btn.color
        button.BackgroundTransparency = 0.2
        button.Font = Enum.Font.Gotham
        button.TextSize = 14
        button.BorderSizePixel = 0
        button.Parent = scrollingFrame
        
        button.MouseButton1Click:Connect(btn.func)
    end
    
    -- Tombol Tutup
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = frame
    
    closeBtn.MouseButton1Click:Connect(function()
        frame.Visible = not frame.Visible
    end)
    
    notify("📱 UI Mobile telah dimuat! (Klik ✕ untuk sembunyikan)")
end

-- =============================================
-- 🎮 KEYBOARD SHORTCUT (UNTUK PC)
-- =============================================

game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    local key = input.KeyCode
    
    -- Fitur Memancing
    if key == Enum.KeyCode.F then toggleAutoFarm()
    elseif key == Enum.KeyCode.L then toggleAutoReel()
    elseif key == Enum.KeyCode.K then toggleAutoBait()
    elseif key == Enum.KeyCode.J then toggleAutoSell()
    elseif key == Enum.KeyCode.N then toggleAutoUpgrade()
    elseif key == Enum.KeyCode.U then toggleAutoDrop()
    elseif key == Enum.KeyCode.M then fishFinder()
    elseif key == Enum.KeyCode.O then megaCatch()
    elseif key == Enum.KeyCode.P then fishStats()
    elseif key == Enum.KeyCode.I then toggleFishRadar()
    elseif key == Enum.KeyCode.Y then autoFishAll()
    
    -- Fitur Lain
    elseif key == Enum.KeyCode.B then autoBuyRod()
    elseif key == Enum.KeyCode.T then teleportSpawn()
    elseif key == Enum.KeyCode.V then speedBoat()
    elseif key == Enum.KeyCode.X then toggleSpeed()
    elseif key == Enum.KeyCode.Z then toggleJump()
    elseif key == Enum.KeyCode.H then
        notify("👨‍💻 Developer: XyzeDev")
        notify("💬 Discord: https://discord.gg/xyzedev")
    end
end)

-- =============================================
-- 🚫 ANTI AFK (UNIVERSAL)
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
-- 🚀 STARTUP
-- =============================================

wait(1)
notify("✅ Script Lengkap Siap!")
notify("📱 HP: Gunakan UI di layar")
notify("💻 PC: Lihat daftar hotkey di bawah")

-- Buat UI untuk HP
if isMobile then
    wait(0.5)
    createMobileUI()
end

-- =============================================
-- 📋 DAFTAR HOTKEY (PC)
-- =============================================

print("=========================================")
print("🐟 FISH & MONSTERS - SCRIPT LENGKAP")
print("=========================================")
print("🎣 FITUR MEMANCING:")
print("   [F] Auto Farm    [L] Auto Reel")
print("   [K] Auto Bait    [J] Auto Sell")
print("   [N] Upgrade Rod  [U] Auto Drop")
print("   [M] Fish Finder  [O] Mega Catch")
print("   [P] Fish Stats   [I] Fish Radar")
print("   [Y] Auto All")
print("")
print("🛒 FITUR LAIN:")
print("   [B] Beli Rod     [T] Teleport")
print("   [V] Speed Boat   [X] Speed Hack")
print("   [Z] Jump Hack    [H] Info")
print("=========================================")
print("👨‍💻 Developer: XyzeDev")
print("💬 Discord: https://discord.gg/xyzedev")
print("=========================================")