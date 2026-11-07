--[[
    R'X FLING | RayX Team | v1.9
    Gerakan Maju-Mundur 2x + Atas-Bawah 2x (Loop) + Hindari Tanah
]]

--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

--// ANTI-CHEAT BYPASS
local bypassStatus = "FALLBACK"
do
    pcall(function()
        local mt = getrawmetatable and getrawmetatable(game)
        if mt then
            setreadonly(mt, false)
            local oldNamecall = mt.__namecall
            mt.__namecall = newcclosure(function(self, ...)
                local m = getnamecallmethod()
                if m == "Kick" or m == "kick" then return nil end
                return oldNamecall(self, ...)
            end)
            setreadonly(mt, true)
            bypassStatus = "ACTIVE"
        end
    end)
end

--// THEME
local C = {
    Bg      = Color3.fromRGB(14, 14, 18),
    Panel   = Color3.fromRGB(22, 22, 28),
    Stroke  = Color3.fromRGB(48, 48, 62),
    Text    = Color3.fromRGB(230, 230, 240),
    Sub     = Color3.fromRGB(140, 140, 155),
    Accent  = Color3.fromRGB(0, 200, 255),
    Green   = Color3.fromRGB(0, 210, 120),
    Red     = Color3.fromRGB(255, 70, 90),
    Gray    = Color3.fromRGB(40, 40, 50),
}

local function create(cls, props, parent)
    local o = Instance.new(cls)
    for k, v in pairs(props or {}) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

local parentGui = (gethui and gethui()) or CoreGui
local ScreenGui = create("ScreenGui", {
    Name = "R4yX_Fling",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, parentGui)

--// ANTI DEATH BRUTAL
local antiDeathEnabled = true
local deathConns = {}

local function brutalProtect(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    hum.BreakJointsOnDeath = false
    hum.MaxHealth = math.huge
    hum.Health = math.huge
    pcall(function()
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    end)
    if hookfunction then
        pcall(function() hookfunction(hum.TakeDamage, function() return end) end)
    end
    table.insert(deathConns, hum.Died:Connect(function()
        if antiDeathEnabled then hum.Health = hum.MaxHealth end
    end))
    table.insert(deathConns, RunService.Heartbeat:Connect(function()
        if not antiDeathEnabled then return end
        if hum.Parent then
            if hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end
            if hum.MaxHealth ~= math.huge then hum.MaxHealth = math.huge end
        end
    end))
    table.insert(deathConns, hum.HealthChanged:Connect(function(h)
        if antiDeathEnabled and h < hum.MaxHealth then hum.Health = hum.MaxHealth end
    end))
end

local function clearDeathConns()
    for _, c in ipairs(deathConns) do c:Disconnect() end
    deathConns = {}
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.3)
    clearDeathConns()
    brutalProtect(char)
end)
if LocalPlayer.Character then brutalProtect(LocalPlayer.Character) end

--// MAIN UI
local Main = create("Frame", {
    Size = UDim2.new(0, 300, 0, 272),
    Position = UDim2.new(0.5, -150, 0.5, -136),
    BackgroundColor3 = C.Bg,
    BorderSizePixel = 0,
}, ScreenGui)
create("UICorner", { CornerRadius = UDim.new(0, 10) }, Main)
create("UIStroke", { Color = C.Stroke, Thickness = 1 }, Main)

local Header = create("Frame", {
    Size = UDim2.new(1, 0, 0, 36),
    BackgroundColor3 = C.Panel,
    BorderSizePixel = 0,
}, Main)
create("UICorner", { CornerRadius = UDim.new(0, 10) }, Header)
create("Frame", {
    Size = UDim2.new(1, 0, 0, 14),
    Position = UDim2.new(0, 0, 1, -14),
    BackgroundColor3 = C.Panel,
    BorderSizePixel = 0,
}, Header)

create("TextLabel", {
    Size = UDim2.new(1, -50, 1, 0),
    Position = UDim2.new(0, 12, 0, 0),
    BackgroundTransparency = 1,
    Text = "R'X FLING",
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    TextColor3 = C.Text,
    TextXAlignment = Enum.TextXAlignment.Left,
}, Header)

local HideBtn = create("TextButton", {
    Size = UDim2.new(0, 24, 0, 24),
    Position = UDim2.new(1, -30, 0, 6),
    BackgroundColor3 = C.Panel,
    BorderSizePixel = 0,
    Text = "X",
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    TextColor3 = C.Sub,
    AutoButtonColor = false,
}, Header)
create("UICorner", { CornerRadius = UDim.new(0, 6) }, HideBtn)
HideBtn.MouseEnter:Connect(function() HideBtn.TextColor3 = C.Red end)
HideBtn.MouseLeave:Connect(function() HideBtn.TextColor3 = C.Sub end)

local dragMain, dIn, dStart, dPos
Header.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragMain = true; dStart = i.Position; dPos = Main.Position
        i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragMain = false end end)
    end
end)
Header.InputChanged:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then dIn = i end
end)
UserInputService.InputChanged:Connect(function(i)
    if i == dIn and dragMain then
        local d = i.Position - dStart
        Main.Position = UDim2.new(dPos.X.Scale, dPos.X.Offset + d.X, dPos.Y.Scale, dPos.Y.Offset + d.Y)
    end
end)

create("TextLabel", {
    Size = UDim2.new(1, -24, 0, 14),
    Position = UDim2.new(0, 12, 0, 44),
    BackgroundTransparency = 1,
    Text = "TARGET",
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    TextColor3 = C.Sub,
    TextXAlignment = Enum.TextXAlignment.Left,
}, Main)

local Dropdown = create("TextButton", {
    Size = UDim2.new(1, -24, 0, 30),
    Position = UDim2.new(0, 12, 0, 60),
    BackgroundColor3 = C.Panel,
    BorderSizePixel = 0,
    Text = "",
    AutoButtonColor = false,
}, Main)
create("UICorner", { CornerRadius = UDim.new(0, 8) }, Dropdown)
create("UIStroke", { Color = C.Stroke, Thickness = 1 }, Dropdown)

local DropLabel = create("TextLabel", {
    Size = UDim2.new(1, -30, 1, 0),
    Position = UDim2.new(0, 12, 0, 0),
    BackgroundTransparency = 1,
    Text = "Pilih pemain...",
    Font = Enum.Font.Gotham,
    TextSize = 12,
    TextColor3 = C.Sub,
    TextXAlignment = Enum.TextXAlignment.Left,
}, Dropdown)

create("TextLabel", {
    Size = UDim2.new(0, 16, 0, 16),
    Position = UDim2.new(1, -24, 0.5, -8),
    BackgroundTransparency = 1,
    Text = "v",
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextColor3 = C.Sub,
}, Dropdown)

local DropFrame = create("ScrollingFrame", {
    Size = UDim2.new(1, -24, 0, 0),
    Position = UDim2.new(0, 12, 0, 92),
    BackgroundColor3 = C.Panel,
    BorderSizePixel = 0,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = C.Accent,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ClipsDescendants = true,
    Visible = false,
    ZIndex = 5,
}, Main)
create("UICorner", { CornerRadius = UDim.new(0, 8) }, DropFrame)
create("UIStroke", { Color = C.Stroke, Thickness = 1 }, DropFrame)
create("UIListLayout", { Padding = UDim.new(0, 2) }, DropFrame)
create("UIPadding", {
    PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4),
    PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4),
}, DropFrame)

local selectedTarget = nil
local dropOpen = false

local function setDrop(open)
    dropOpen = open
    DropFrame.Visible = open
    TweenService:Create(DropFrame, TweenInfo.new(0.12), {
        Size = open and UDim2.new(1, -24, 0, 110) or UDim2.new(1, -24, 0, 0)
    }):Play()
end

local function refreshDrop()
    for _, c in ipairs(DropFrame:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    local n = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        n += 1
        local o = create("TextButton", {
            Size = UDim2.new(1, -8, 0, 26),
            BackgroundColor3 = C.Bg,
            BorderSizePixel = 0,
            Text = plr.Name,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = C.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false,
        }, DropFrame)
        create("UICorner", { CornerRadius = UDim.new(0, 5) }, o)
        create("UIPadding", { PaddingLeft = UDim.new(0, 8) }, o)
        o.MouseButton1Click:Connect(function()
            selectedTarget = plr
            DropLabel.Text = plr.Name
            DropLabel.TextColor3 = C.Text
            setDrop(false)
        end)
    end
    if n == 0 then
        create("TextLabel", {
            Size = UDim2.new(1, -8, 0, 26),
            BackgroundTransparency = 1,
            Text = "Tidak ada pemain",
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextColor3 = C.Sub,
        }, DropFrame)
    end
end

Dropdown.MouseButton1Click:Connect(function()
    if not dropOpen then refreshDrop() end
    setDrop(not dropOpen)
end)

local Status = create("TextLabel", {
    Size = UDim2.new(1, -24, 0, 12),
    Position = UDim2.new(0, 12, 0, 128),
    BackgroundTransparency = 1,
    Text = "Target: —",
    Font = Enum.Font.Gotham,
    TextSize = 10,
    TextColor3 = C.Sub,
    TextXAlignment = Enum.TextXAlignment.Left,
}, Main)

local Row = create("Frame", {
    Size = UDim2.new(1, -24, 0, 30),
    Position = UDim2.new(0, 12, 0, 146),
    BackgroundTransparency = 1,
}, Main)

local buttonOrigColors = {}

local function mkBtn(txt, color, xScale)
    local b = create("TextButton", {
        Size = UDim2.new(0.5, -4, 1, 0),
        Position = UDim2.new(xScale, xScale == 0 and 0 or 4, 0, 0),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Text = txt,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        AutoButtonColor = false,
    }, Row)
    create("UICorner", { CornerRadius = UDim.new(0, 8) }, b)
    buttonOrigColors[b] = color
    return b
end

local StartBtn = mkBtn("Start Fling", C.Green, 0)
local StopBtn  = mkBtn("Stop Fling",  C.Red,   0.5)

local TouchBtn = create("TextButton", {
    Size = UDim2.new(1, -24, 0, 30),
    Position = UDim2.new(0, 12, 0, 182),
    BackgroundColor3 = C.Gray,
    BorderSizePixel = 0,
    Text = "Touch Fling: OFF",
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextColor3 = C.Text,
    AutoButtonColor = false,
}, Main)
create("UICorner", { CornerRadius = UDim.new(0, 8) }, TouchBtn)
create("UIStroke", { Color = C.Stroke, Thickness = 1 }, TouchBtn)
buttonOrigColors[TouchBtn] = C.Gray

local NoclipBtn = create("TextButton", {
    Size = UDim2.new(1, -24, 0, 30),
    Position = UDim2.new(0, 12, 0, 218),
    BackgroundColor3 = C.Gray,
    BorderSizePixel = 0,
    Text = "Noclip Object: OFF",
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextColor3 = C.Text,
    AutoButtonColor = false,
}, Main)
create("UICorner", { CornerRadius = UDim.new(0, 8) }, NoclipBtn)
create("UIStroke", { Color = C.Stroke, Thickness = 1 }, NoclipBtn)
buttonOrigColors[NoclipBtn] = C.Gray

--// FLOATING BUBBLE
local Bubble = create("TextButton", {
    Size = UDim2.new(0, 46, 0, 46),
    Position = UDim2.new(0, 20, 0.5, -23),
    BackgroundColor3 = C.Accent,
    BorderSizePixel = 0,
    Text = "RX",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = C.Bg,
    AutoButtonColor = false,
    Visible = false,
    ZIndex = 10,
}, ScreenGui)
create("UICorner", { CornerRadius = UDim.new(1, 0) }, Bubble)
create("UIStroke", { Color = C.Stroke, Thickness = 1.5 }, Bubble)

local UI_SIZE = UDim2.new(0, 300, 0, 272)
local currentUIPos = UDim2.new(0.5, -150, 0.5, -136)

local function hideUI()
    currentUIPos = Main.Position
    for _, d in ipairs(Main:GetDescendants()) do
        if d:IsA("TextLabel") then
            TweenService:Create(d, TweenInfo.new(0.18), { TextTransparency = 1 }):Play()
        elseif d:IsA("TextButton") then
            TweenService:Create(d, TweenInfo.new(0.18), { TextTransparency = 1, BackgroundTransparency = 1 }):Play()
        end
    end
    TweenService:Create(Main, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(currentUIPos.X.Scale, currentUIPos.X.Offset + 150, currentUIPos.Y.Scale, currentUIPos.Y.Offset + 136),
        BackgroundTransparency = 1,
    }):Play()
    task.delay(0.23, function()
        Main.Visible = false
        for _, d in ipairs(Main:GetDescendants()) do
            if d:IsA("TextLabel") then
                d.TextTransparency = 0
            elseif d:IsA("TextButton") then
                d.TextTransparency = 0
                d.BackgroundTransparency = 0
                if buttonOrigColors[d] then d.BackgroundColor3 = buttonOrigColors[d] end
            end
        end
        Main.BackgroundTransparency = 0
        Bubble.Visible = true
        Bubble.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(Bubble, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 46, 0, 46)
        }):Play()
    end)
end

local function showUI()
    Bubble.Visible = false
    Main.Visible = true
    Main.Size = UDim2.new(0, 0, 0, 0)
    Main.Position = UDim2.new(currentUIPos.X.Scale, currentUIPos.X.Offset + 150, currentUIPos.Y.Scale, currentUIPos.Y.Offset + 136)
    Main.BackgroundTransparency = 1
    for _, d in ipairs(Main:GetDescendants()) do
        if d:IsA("TextLabel") then
            d.TextTransparency = 1
        elseif d:IsA("TextButton") then
            d.TextTransparency = 1
            d.BackgroundTransparency = 1
        end
    end
    TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UI_SIZE,
        Position = currentUIPos,
        BackgroundTransparency = 0,
    }):Play()
    for _, d in ipairs(Main:GetDescendants()) do
        if d:IsA("TextLabel") then
            TweenService:Create(d, TweenInfo.new(0.28), { TextTransparency = 0 }):Play()
        elseif d:IsA("TextButton") then
            local targetColor = buttonOrigColors[d] or d.BackgroundColor3
            TweenService:Create(d, TweenInfo.new(0.28), {
                TextTransparency = 0,
                BackgroundTransparency = 0,
                BackgroundColor3 = targetColor,
            }):Play()
        end
    end
end

local bDrag, bIn, bStart, bPos
Bubble.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        bDrag = true; bStart = i.Position; bPos = Bubble.Position
        i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then
                bDrag = false
                local d = i.Position - bStart
                if math.abs(d.X) < 5 and math.abs(d.Y) < 5 then showUI() end
            end
        end)
    end
end)
Bubble.InputChanged:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then bIn = i end
end)
UserInputService.InputChanged:Connect(function(i)
    if i == bIn and bDrag then
        local d = i.Position - bStart
        Bubble.Position = UDim2.new(bPos.X.Scale, bPos.X.Offset + d.X, bPos.Y.Scale, bPos.Y.Offset + d.Y)
    end
end)

HideBtn.MouseButton1Click:Connect(hideUI)

--// FREEZE HELPER
local function freezeChar(duration)
    local mC = LocalPlayer.Character
    local mH = mC and mC:FindFirstChild("HumanoidRootPart")
    local hum = mC and mC:FindFirstChildOfClass("Humanoid")
    if not mH then return end
    if hum then hum.PlatformStand = true end
    local bp = Instance.new("BodyPosition")
    bp.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    bp.P = 100000
    bp.D = 1000
    bp.Position = mH.Position
    bp.Parent = mH
    local bg = Instance.new("BodyAngularVelocity")
    bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
    bg.AngularVelocity = Vector3.zero
    bg.Parent = mH
    task.delay(duration, function()
        if bp and bp.Parent then bp:Destroy() end
        if bg and bg.Parent then bg:Destroy() end
        if hum then hum.PlatformStand = false end
    end)
end

--// =========================================================
--// OFFSET SPIN: MAJU-MUNDUR 2x + ATAS-BAWAH 2x (LOOP)
--// =========================================================
--[[
    Pola per siklus (durasi T):
    0.0 - 0.25T : maju
    0.25 - 0.5T : mundur
    0.5 - 0.75T : maju
    0.75 - 1.0T : mundur
    dan Y:
    0.0 - 0.25T : naik
    0.25 - 0.5T : turun
    0.5 - 0.75T : naik
    0.75 - 1.0T : turun
    = maju mundur 2x + atas bawah 2x, loop
    Plus hindari tanah: offset Y minimum di atas target, gak pernah sentuh pijakan
]]

local function createOffsetPattern(hrp, targetHRP, spinSpeed)
    local conn
    local t = 0
    local phase = 0

    conn = RunService.Heartbeat:Connect(function(dt)
        if not hrp.Parent or not targetHRP.Parent then return end
        t = t + dt
        phase = (t % (math.pi * 4)) / (math.pi * 4) -- 0..1 loop 2 siklus

        -- Hitung offset maju/mundur: sin dengan 2 siklus per loop
        -- sin(2*2*pi*phase) = 2x maju mundur per loop
        local forwardBack = math.sin(phase * math.pi * 4) * 4 -- amplitude 4 studs
        local upDown = math.sin(phase * math.pi * 4) * 3 -- amplitude 3 studs

        -- Arah maju = LookVector dari target (horizontal)
        local look = targetHRP.CFrame.LookVector
        look = Vector3.new(look.X, 0, look.Z).Unit

        -- Posisi dasar = tengah target + sedikit naik biar gak nyentuh tanah
        local basePos = targetHRP.Position + Vector3.new(0, 2.5, 0)

        -- Offset akhir
        local offset = look * forwardBack + Vector3.new(0, upDown, 0)

        -- Hindari tanah: pastikan Y minimum >= target Y + 2
        local finalY = math.max(basePos.Y + offset.Y, targetHRP.Position.Y + 2)
        local finalPos = Vector3.new(basePos.X + offset.X, finalY, basePos.Z + offset.Z)

        -- Set CFrame: posisi + rotasi spin
        local spinAngle = t * spinSpeed
        hrp.CFrame = CFrame.new(finalPos) * CFrame.Angles(math.rad(-90), spinAngle, 0)
    end)

    return conn
end

--// FLING ENGINE
local flingActive = false
local conns, bodies = {}, {}
local patternConn = nil

local function clear()
    for _, c in ipairs(conns) do c:Disconnect() end
    conns = {}
    for _, b in ipairs(bodies) do if b and b.Parent then b:Destroy() end end
    bodies = {}
    if patternConn then patternConn:Disconnect() patternConn = nil end
    flingActive = false
    local mC = LocalPlayer.Character
    if mC then
        local h = mC:FindFirstChildOfClass("Humanoid")
        if h then h.PlatformStand = false end
    end
end

local function startFling()
    if not selectedTarget then
        Status.Text = "Pilih target dulu!"
        Status.TextColor3 = C.Red
        return
    end
    local tC = selectedTarget.Character
    local tH = tC and tC:FindFirstChild("HumanoidRootPart")
    local mC = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local mH = mC:FindFirstChild("HumanoidRootPart")
    if not tH or not mH then
        Status.Text = "Target/karakter invalid!"
        Status.TextColor3 = C.Red
        return
    end

    clear()
    flingActive = true
    brutalProtect(mC)
    Status.Text = "Flinging: " .. selectedTarget.Name
    Status.TextColor3 = C.Green

    -- Teleport ke tengah badan target, terbaring
    mH.CFrame = tH.CFrame * CFrame.Angles(math.rad(-90), 0, 0)

    local hum = mC:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = true end

    -- Pattern: maju-mundur 2x + atas-bawah 2x, loop, hindari tanah
    patternConn = createOffsetPattern(mH, tH, 12)

    local lastTargetPos = tH.Position
    local lastTime = tick()

    table.insert(conns, RunService.Heartbeat:Connect(function()
        if not flingActive then return end
        local now = tick()
        local dt = now - lastTime
        lastTime = now

        local tc = selectedTarget.Character
        local th = tc and tc:FindFirstChild("HumanoidRootPart")
        if not th or not mH.Parent then
            clear()
            Status.Text = "Target hilang."
            Status.TextColor3 = C.Red
            return
        end

        -- Deteksi target terpental
        local vel = (th.Position - lastTargetPos).Magnitude / math.max(dt, 0.001)
        if vel > 80 then
            Status.Text = "Target terpental — stop & freeze 1s"
            Status.TextColor3 = C.Red
            clear()
            freezeChar(1)
            return
        end
        lastTargetPos = th.Position
    end))
end

StartBtn.MouseButton1Click:Connect(startFling)

StopBtn.MouseButton1Click:Connect(function()
    if flingActive then
        clear()
        Status.Text = "Stopped."
        Status.TextColor3 = C.Sub
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if flingActive then
        clear()
        Status.Text = "Respawn — stop."
        Status.TextColor3 = C.Sub
    end
end)

--// TOUCH FLING
local touchFling = false
local touchData = nil

TouchBtn.MouseButton1Click:Connect(function()
    touchFling = not touchFling
    TouchBtn.Text = "Touch Fling: " .. (touchFling and "ON" or "OFF")
    TouchBtn.BackgroundColor3 = touchFling and C.Green or C.Gray
    buttonOrigColors[TouchBtn] = touchFling and C.Green or C.Gray
    Status.Text = touchFling and "Touch Fling AKTIF" or "Touch Fling OFF"
    Status.TextColor3 = touchFling and C.Green or C.Sub
end)

local function stopTouchStick(teleportBack)
    if touchData then
        if touchData.conn then touchData.conn:Disconnect() end
        if touchData.patternConn then touchData.patternConn:Disconnect() end
        local mC = LocalPlayer.Character
        local mH = mC and mC:FindFirstChild("HumanoidRootPart")
        if teleportBack and mH and touchData.lastTouchPos then
            mH.CFrame = CFrame.new(touchData.lastTouchPos + Vector3.new(0, 3, 0))
        end
        if mC then
            local h = mC:FindFirstChildOfClass("Humanoid")
            if h then h.PlatformStand = false end
        end
        touchData = nil
    end
end

local function startTouchStick(targetHRP, touchPos)
    stopTouchStick(false)
    local mC = LocalPlayer.Character
    local mH = mC and mC:FindFirstChild("HumanoidRootPart")
    local hum = mC and mC:FindFirstChildOfClass("Humanoid")
    if not mH or not hum then return end

    brutalProtect(mC)
    mH.CFrame = targetHRP.CFrame * CFrame.Angles(math.rad(-90), 0, 0)

    hum.PlatformStand = true

    -- Pattern maju-mundur 2x + atas-bawah 2x
    local patternConn = createOffsetPattern(mH, targetHRP, 15)

    local lastPos = targetHRP.Position
    local lastTime = tick()
    local conn = RunService.Heartbeat:Connect(function()
        if not touchData then return end
        local now = tick()
        local dt = now - lastTime
        lastTime = now

        if not targetHRP.Parent then
            stopTouchStick(true)
            return
        end

        local vel = (targetHRP.Position - lastPos).Magnitude / math.max(dt, 0.001)
        if vel > 80 then
            Status.Text = "Target terpental — stop & freeze 1s"
            Status.TextColor3 = C.Red
            stopTouchStick(true)
            freezeChar(1)
            return
        end
        lastPos = targetHRP.Position
    end)

    touchData = {
        conn = conn,
        patternConn = patternConn,
        lastTouchPos = touchPos or mH.Position,
    }
end

local function bindTouch(char)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.Touched:Connect(function(hit)
        if not touchFling then return end
        local mC = LocalPlayer.Character
        if not mC then return end
        local mH = mC:FindFirstChild("HumanoidRootPart")
        if not mH then return end

        local model = hit:FindFirstAncestorOfClass("Model")
        if not model then return end
        local plr = Players:GetPlayerFromCharacter(model)
        if not plr or plr == LocalPlayer then return end

        local tHRP = model:FindFirstChild("HumanoidRootPart")
        if tHRP and not touchData then
            local touchPos = mH.Position
            Status.Text = "Nempel: " .. plr.Name
            Status.TextColor3 = C.Green
            startTouchStick(tHRP, touchPos)
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    bindTouch(char)
end)
if LocalPlayer.Character then bindTouch(LocalPlayer.Character) end

--// NOCLIP OBJECT
local noclipEnabled = false
local noclipConn = nil

local function startNoclip()
    if noclipConn then noclipConn:Disconnect() end
    noclipConn = RunService.Stepped:Connect(function()
        if not noclipEnabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
                part.CanQuery = false
                part.CanTouch = false
            end
        end
    end)
end

local function stopNoclip()
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            if part.Name == "HumanoidRootPart" or part.Name == "Head"
               or part.Name == "UpperTorso" or part.Name == "LowerTorso"
               or part.Name == "Torso" or part.Name == "LeftLeg"
               or part.Name == "RightLeg" or part.Name == "LeftFoot"
               or part.Name == "RightFoot" or part.Name == "LeftUpperArm"
               or part.Name == "RightUpperArm" or part.Name == "LeftLowerArm"
               or part.Name == "RightLowerArm" or part.Name == "LeftHand"
               or part.Name == "RightHand" then
                part.CanCollide = true
            end
            part.CanQuery = true
            part.CanTouch = true
        end
    end
end

NoclipBtn.MouseButton1Click:Connect(function()
    noclipEnabled = not noclipEnabled
    NoclipBtn.Text = "Noclip Object: " .. (noclipEnabled and "ON" or "OFF")
    NoclipBtn.BackgroundColor3 = noclipEnabled and C.Green or C.Gray
    buttonOrigColors[NoclipBtn] = noclipEnabled and C.Green or C.Gray
    Status.Text = noclipEnabled and "Noclip AKTIF" or "Noclip OFF"
    Status.TextColor3 = noclipEnabled and C.Green or C.Sub
    if noclipEnabled then startNoclip() else stopNoclip() end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if noclipEnabled then startNoclip() end
end)

print("[R4yX] R'X FLING v1.9 | bypass:", bypassStatus)