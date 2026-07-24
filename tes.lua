-- =========================================================================
-- FISH AND MONSTERS HUB + FAKE ADMIN BROADCAST (DELTA EXECUTOR)
-- =========================================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- 1. PEMBERSIHAN GUI SEBELUMNYA (Anti-Crash & Duplikasi)
if CoreGui:FindFirstChild("DeltaFishMonsterHub") then
    CoreGui.DeltaFishMonsterHub:Destroy()
end

-- 2. PENYIAPAN ANTARMUKA UTAMA (GUI)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaFishMonsterHub"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Tombol Utama untuk Mulai Memancing
local MainBtn = Instance.new("TextButton")
MainBtn.Name = "MainBtn"
MainBtn.Size = UDim2.new(0, 160, 0, 50)
MainBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
MainBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
MainBtn.Text = "🎣 Lempar Umpan"
MainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MainBtn.TextSize = 16
MainBtn.Font = Enum.Font.SourceSansBold
MainBtn.Parent = ScreenGui

local UICornerBtn = Instance.new("UICorner")
UICornerBtn.CornerRadius = URadius.new(0, 8)
UICornerBtn.Parent = MainBtn

-- Tombol Toggle Auto Steal/Loot
local StealBtn = Instance.new("TextButton")
StealBtn.Name = "StealBtn"
StealBtn.Size = UDim2.new(0, 160, 0, 40)
StealBtn.Position = UDim2.new(0.05, 0, 0.4, 60)
StealBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
StealBtn.Text = "🥷 Auto Steal: ON"
StealBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StealBtn.TextSize = 14
StealBtn.Font = Enum.Font.SourceSansBold
StealBtn.Parent = ScreenGui

local UICornerSteal = Instance.new("UICorner")
UICornerSteal.CornerRadius = URadius.new(0, 8)
UICornerSteal.Parent = StealBtn

-- Frame Progress Menarik Ikan (Mini Game)
local ReelFrame = Instance.new("Frame")
ReelFrame.Name = "ReelFrame"
ReelFrame.Size = UDim2.new(0, 300, 0, 120)
ReelFrame.Position = UDim2.new(0.5, -150, 0.4, -60)
ReelFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ReelFrame.Visible = false
ReelFrame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = URadius.new(0, 12)
FrameCorner.Parent = ReelFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0.4, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "MENUNGGU GIGITAN..."
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.TextSize = 18
StatusLabel.Font = Enum.Font.SourceSansBold
StatusLabel.Parent = ReelFrame

local BarBg = Instance.new("Frame")
BarBg.Size = UDim2.new(0.8, 0, 0.2, 0)
BarBg.Position = UDim2.new(0.1, 0, 0.6, 0)
BarBg.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
BarBg.Parent = ReelFrame

local BarFill = Instance.new("Frame")
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
BarFill.Parent = BarBg

-- =========================================================================
-- PENGATURAN DATABASE & VARIABEL GLOBAL
-- =========================================================================

_G.AutoSteal = true

local TargetItems = {
    "Fish", "Monster", "Ikan", "Lele", "Mas", "Tuna", 
    "Kerapu", "Hiu Megalodon", "Monster Kraken", "Rare Fish"
}

local FishDatabase = {"Lele", "Mas", "Tuna", "Kerapu", "Hiu Megalodon", "Monster Kraken"}
local MutationDatabase = {
    {Type = "Normal", Multiplier = 1, Chance = 60},
    {Type = "Shiny ✨", Multiplier = 2, Chance = 25},
    {Type = "Mutated 🧪", Multiplier = 5, Chance = 12},
    {Type = "Legendary 👑", Multiplier = 10, Chance = 3}
}

local isFishing = false
local isReeling = false
local progress = 0

-- Fungsi Notifikasi Lokal (Hanya muncul di HP Anda)
local function notify(title, text)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 3
    })
end

-- FUNGSI SIMULASI ADMIN: Mengirim Pesan Berformat Sistem ke All Server
local function broadcastAsAdmin(message)
    -- Format teks dimanipulasi agar terlihat seperti notifikasi sistem otomatis
    local fakeAdminFormat = "[SYSTEM NOTIFICATION]: " .. message
    
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        -- Untuk game dengan sistem chat Roblox baru
        local generalChannel = TextChatService:FindFirstChild("TextChannels") and TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if generalChannel then
            generalChannel:SendAsync(fakeAdminFormat)
        end
    else
        -- Untuk game dengan sistem chat Roblox lama (Legacy)
        local chatEvent = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") and ReplicatedStorage.DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest")
        if chatEvent then
            chatEvent:FireServer(fakeAdminFormat, "All")
        end
    end
end

local function isTargetItem(itemName)
    for _, name in ipairs(TargetItems) do
        if string.find(string.lower(itemName), string.lower(name)) then
            return true
        end
    end
    return false
end

-- =========================================================================
-- LOGIKA 1: FITUR MEMANCING INTERAKTIF
-- =========================================================================

local function rollMutation()
    local roll = math.random(1, 100)
    local current = 0
    for _, mutation in ipairs(MutationDatabase) do
        current = current + mutation.Chance
        if roll <= current then
            return mutation
        end
    end
    return MutationDatabase[1]
end

MainBtn.MouseButton1Click:Connect(function()
    if isFishing then return end
    isFishing = true
    MainBtn.Text = "⏳ Menunggu..."
    MainBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    
    task.wait(math.random(2, 5))
    
    isReeling = true
    progress = 20
    ReelFrame.Visible = true
    StatusLabel.Text = "🐠 IKAN MENGGIGIT! TAP LAYAR!"
    StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    
    task.spawn(function()
        while isReeling and progress > 0 and progress < 100 do
            progress = math.max(0, progress - 2)
            BarFill.Size = UDim2.new(progress / 100, 0, 1, 0)
            task.wait(0.1)
        end
        
        if progress <= 0 and isReeling then
            isReeling = false
            ReelFrame.Visible = false
            isFishing = false
            MainBtn.Text = "🎣 Lempar Umpan"
            MainBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
            notify("Yah, Lepas!", "Ikan berhasil kabur.")
        end
    end)
end)

Mouse.Button1Down:Connect(function()
    if not isReeling then return end
    
    progress = progress + 7
    BarFill.Size = UDim2.new(progress / 100, 0, 1, 0)
    
    if progress >= 100 then
        isReeling = false
        ReelFrame.Visible = false
        isFishing = false
        MainBtn.Text = "🎣 Lempar Umpan"
        MainBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        
        local baseFish = FishDatabase[math.random(1, #FishDatabase)]
        local mutation = rollMutation()
        local fishName = mutation.Type .. " " .. baseFish
        
        notify("BERHASIL!", "Menangkap: " .. fishName)
        
        -- Memicu pengumuman admin jika dapat ikan kategori langka
        if mutation.Type == "Mutated 🧪" or mutation.Type == "Legendary 👑" then
            broadcastAsAdmin("Player " .. LocalPlayer.Name .. " berhasil menangkap makhluk langka [" .. fishName .. "]!")
        end
    end
end)

-- =========================================================================
-- LOGIKA 2: FITUR AUTO LOOT & STEAL (PENCURI ITEM)
-- =========================================================================

StealBtn.MouseButton1Click:Connect(function()
    _G.AutoSteal = not _G.AutoSteal
    if _G.AutoSteal then
        StealBtn.Text = "🥷 Auto Steal: ON"
        StealBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        notify("Auto Steal", "Fitur diaktifkan.")
    else
        StealBtn.Text = "🥷 Auto Steal: OFF"
        StealBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        notify("Auto Steal", "Fitur dimatikan.")
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if _G.AutoSteal then
            local myChar = LocalPlayer.Character
            if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                
                -- Mencuri dari tangan atau inventory player lain
                for _, otherPlayer in ipairs(Players:GetPlayers()) do
                    if otherPlayer ~= LocalPlayer and otherPlayer.Character then
                        
                        for _, item in ipairs(otherPlayer.Character:GetChildren()) do
                            if item:IsA("Tool") and isTargetItem(item.Name) then
                                local stolenName = item.Name
                                item.Parent = LocalPlayer.Backpack
                                notify("Looted!", "Mengambil " .. stolenName .. " dari " .. otherPlayer.Name)
                                
                                -- Memicu pengumuman admin palsu jika mencuri item boss besar seperti Kraken/Megalodon
                                if string.find(string.lower(stolenName), "kraken") or string.find(string.lower(stolenName), "megalodon") then
                                    broadcastAsAdmin("Item BOSS [" .. stolenName .. "] milik " .. otherPlayer.Name .. " telah direbut oleh " .. LocalPlayer.Name .. "!")
                                end
                            end
                        end
                        
                        local otherBackpack = otherPlayer:FindFirstChild("Backpack")
                        if otherBackpack then
                            for _, item in ipairs(otherBackpack:GetChildren()) do
                                if item:IsA("Tool") and isTargetItem(item.Name) then
                                    item.Parent = LocalPlayer.Backpack
                                end
                            end
                        end
                    end
                end
                
                -- Mengambil item monster/ikan yang tergeletak bebas di Workspace
                for _, item in ipairs(workspace:GetChildren()) do
                    if item:IsA("Tool") and isTargetItem(item.Name) then
                        local handle = item:FindFirstChild("Handle")
                        if handle then
                            handle.CFrame = myChar.HumanoidRootPart.CFrame
                            task.wait(0.05)
                            item.Parent = LocalPlayer.Backpack
                            notify("Looted!", "Berhasil memungut " .. item.Name .. " di tanah!")
                        end
                    end
                end
                
            end
        end
    end
end)

notify("Script Berhasil Dimuat", "Fake Admin Broadcast System Siap Digunakan!")
