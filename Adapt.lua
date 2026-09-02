-- ═══════════════════════════════════════════════════════════
--  ADAPT | HUB
--  Modern minimalist UI · 4 themes (B&W, Red, Blue, Pink)
--  All original mechanics from Kyzen preserved
-- ═══════════════════════════════════════════════════════════

-- ============================================================================
-- INTRO SEQUENCE
-- ============================================================================
task.spawn(function()
    local TweenService = game:GetService("TweenService")
    local CoreGui      = game:GetService("CoreGui")
    local SoundService = game:GetService("SoundService")

    local SONG_ID        = "rbxassetid://126107591945718"
    local SONG_VOL       = 0.7
    local INTRO_DURATION = 3.2
    local BLINK_INTERVAL = 0.15

    local blur = Instance.new("BlurEffect")
    blur.Size   = 56
    blur.Parent = game:GetService("Lighting")

    local introGui = Instance.new("ScreenGui")
    introGui.Name            = "AdaptIntro"
    introGui.ResetOnSpawn    = false
    introGui.IgnoreGuiInset  = true
    introGui.ZIndexBehavior  = Enum.ZIndexBehavior.Global
    introGui.Parent          = CoreGui

    local overlay = Instance.new("Frame", introGui)
    overlay.Size = UDim2.new(1,0,1,0)
    overlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
    overlay.BackgroundTransparency = 0.55
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 100

    local tag = Instance.new("TextLabel", introGui)
    tag.Size                   = UDim2.new(0, 520, 0, 94)
    tag.Position               = UDim2.new(0.5, -260, 0.5, -56)
    tag.BackgroundTransparency = 1
    tag.Text                   = "ADAPT"
    tag.Font                   = Enum.Font.GothamBlack
    tag.TextSize               = 84
    tag.TextColor3             = Color3.fromRGB(255, 255, 255)
    tag.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)
    tag.TextStrokeTransparency = 0.7
    tag.TextXAlignment         = Enum.TextXAlignment.Center
    tag.TextTransparency       = 0
    tag.ZIndex                 = 110

    local line = Instance.new("Frame", introGui)
    line.Size = UDim2.new(0, 340, 0, 1)
    line.Position = UDim2.new(0.5, -170, 0.5, 36)
    line.BackgroundColor3 = Color3.fromRGB(210, 210, 225)
    line.BackgroundTransparency = 0.2
    line.BorderSizePixel = 0
    line.ZIndex = 110

    local sub = Instance.new("TextLabel", introGui)
    sub.Size                   = UDim2.new(0, 520, 0, 30)
    sub.Position               = UDim2.new(0.5, -260, 0.5, 42)
    sub.BackgroundTransparency = 1
    sub.Text                   = "H  U  B"
    sub.Font                   = Enum.Font.GothamBold
    sub.TextSize               = 18
    sub.TextColor3             = Color3.fromRGB(175, 175, 198)
    sub.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)
    sub.TextStrokeTransparency = 0.5
    sub.TextXAlignment         = Enum.TextXAlignment.Center
    sub.TextTransparency       = 0
    sub.ZIndex                 = 110

    local snd = Instance.new("Sound")
    snd.SoundId            = SONG_ID
    snd.Volume             = SONG_VOL
    snd.Looped             = false
    snd.RollOffMode        = Enum.RollOffMode.InverseTapered
    snd.RollOffMinDistance = 10000
    snd.RollOffMaxDistance = 10000
    snd.TimePosition       = 34
    snd.Parent             = SoundService
    if not snd.IsLoaded then
        local loaded = false
        task.spawn(function() snd.Loaded:Wait(); loaded = true end)
        local t = 0
        while not loaded and t < 0.5 do task.wait(0.05); t = t + 0.05 end
    end
    pcall(function() snd:Play() end)

    local blinkActive = true
    local visible     = true
    task.spawn(function()
        while blinkActive do
            task.wait(BLINK_INTERVAL)
            visible = not visible
            tag.TextTransparency  = visible and 0 or 1
            sub.TextTransparency  = visible and 0 or 0.5
            line.BackgroundTransparency = visible and 0.4 or 0.85
        end
    end)

    task.wait(INTRO_DURATION)

    blinkActive = false
    local fadeInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    tag.TextTransparency = 0
    TweenService:Create(tag,     fadeInfo, {TextTransparency = 1}):Play()
    TweenService:Create(sub,     fadeInfo, {TextTransparency = 1}):Play()
    TweenService:Create(line,    fadeInfo, {BackgroundTransparency = 1}):Play()
    TweenService:Create(overlay, fadeInfo, {BackgroundTransparency = 1}):Play()
    TweenService:Create(snd,     TweenInfo.new(0.6), {Volume = 0}):Play()
    TweenService:Create(blur,    fadeInfo, {Size = 0}):Play()
    task.wait(0.7)

    pcall(function() snd:Stop(); snd:Destroy() end)
    pcall(function() blur:Destroy() end)
    pcall(function() introGui:Destroy() end)

    local pg = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    local hubGui = pg:FindFirstChild("AdaptHubGUI")
    if hubGui then
        local m = hubGui:FindFirstChild("Main")
        if m then m.Visible = true end
        for _, child in ipairs(hubGui:GetChildren()) do
            if child:IsA("Frame") and child.Name ~= "Main" and child.ZIndex == 2 then
                child.Visible = true
            end
        end
    end
end)

-- ============================================================================
-- ADAPT | HUB MAIN
-- ============================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local ContentProvider = game:GetService("ContentProvider")
local LP = Players.LocalPlayer

local State = {
	normalSpeed = 60, carrySpeed = 30,
	speedToggled = false, autoBatToggled = false,
	hittingCooldown = false, infJumpEnabled = false,
	antiRagdollEnabled = false, fpsBoostEnabled = false,
	guiVisible = true,
	isStealing = false, stealStartTime = nil, lastStealTick = 0, lastKnownHealth = 100,
	autoLeftEnabled = false, autoRightEnabled = false,
	autoLeftPhase = 1, autoRightPhase = 1,
	medusaLastUsed = 0, medusaDebounce = false, medusaCounterEnabled = false,
	dropBrainrotActive = false,
	autoPlayEnabled = false, autoPlayWaypoint = 1,
	autoPlayWaiting = false, autoPlayWaitingCountdown = false,
	_tpInProgress = false, detectedBaseSide = nil,
	lastMoveDir = Vector3.new(0,0,0), unwalkEnabled = false,
	customFontEnabled = false,
	batCounterEnabled = false, batCounterLastUsed = 0, _lastHealthBC = 100,
	stretchedResEnabled = false,
	hopPower = 35, hopCooldown = 0.08, lastHopTime = 0,
	laggerModeEnabled = false, laggerSpeed = 15,
	animEnabled = false,
	_autoBatLastHP = 100, _autoBatLastSwing = 0,
	currentTab = "Speed",
	jumpMode = "Single",
	floatRiseSpeed = 30, floatFallSpeed = 50, floatStopMode = "TP Down",
	batCounterFollow = true,
	aimbotHitMode = "Auto Swing",
	menuOpacity = 100, menuSize = 100, speedModeSize = 100,
	noCamCollisionEnabled = false,
	ultraModeEnabled = false,
	floatEnabled = false, floatHeight = 9.5,
	currentTheme = 1, -- 1=B&W, 2=Red, 3=Blue, 4=Pink
}

local Keys = {
	autoBat = Enum.KeyCode.E, speed = Enum.KeyCode.Q,
	guiHide = Enum.KeyCode.U,
	autoLeft = Enum.KeyCode.L, autoRight = Enum.KeyCode.R,
	dropBrainrot = Enum.KeyCode.H,
	autoPlay = Enum.KeyCode.P,
	laggerMode = Enum.KeyCode.B,
	tpDown = Enum.KeyCode.T,
}

local Steal = {
	AutoStealEnabled = false, StealRadius = 8, StealDuration = 0.19,
	Data = {}, plotCache = {}, plotCacheTime = {},
	cachedPrompts = {}, promptCacheTime = 0,
}

local MOVE_KEYS = {
	[Enum.KeyCode.W]=true,[Enum.KeyCode.A]=true,
	[Enum.KeyCode.S]=true,[Enum.KeyCode.D]=true,
	[Enum.KeyCode.Up]=true,[Enum.KeyCode.Left]=true,
	[Enum.KeyCode.Down]=true,[Enum.KeyCode.Right]=true,
}

local PLOT_CACHE_DURATION = 2
local PROMPT_CACHE_REFRESH = 0.15
local STEAL_COOLDOWN = 0.05
local AUTO_START_DELAY = 0.7
local DROP_ASCEND_DURATION = 0.2
local DROP_ASCEND_SPEED = 150
local MEDUSA_COOLDOWN = 25

local SlapList = {
	{1, "Bat"}, {2, "Slap"}, {3, "Iron Slap"}, {4, "Gold Slap"},
	{5, "Diamond Slap"}, {6, "Emerald Slap"}, {7, "Ruby Slap"},
	{8, "Dark Matter Slap"}, {9, "Flame Slap"}, {10, "Nuclear Slap"},
	{11, "Galaxy Slap"}, {12, "Glitched Slap"}
}

local POS = {
	L1 = Vector3.new(-476.48,-6.28,92.73), L2 = Vector3.new(-483.12,-4.95,94.80),
	R1 = Vector3.new(-476.16,-6.52,25.62), R2 = Vector3.new(-483.04,-5.09,23.14),
}

local RIGHT_STEP_3 = Vector3.new(-466.78, -7.10, 40.83)
local LEFT_STEP_3  = Vector3.new(-465.7, -7.0, 83.2)

local AP_RIGHT_WP = {
	Vector3.new(-473.04,-6.99,29.71), Vector3.new(-483.57,-5.10,18.74),
	Vector3.new(-475.00,-6.99,26.43), Vector3.new(-474.67,-6.94,105.48),
}
local AP_LEFT_WP = {
	Vector3.new(-472.49,-7.00,90.62), Vector3.new(-484.62,-5.10,100.37),
	Vector3.new(-475.08,-7.00,93.29), Vector3.new(-474.22,-6.96,16.18),
}

local Conns = {
	autoSteal = nil, antiRag = nil, autoPlay = nil,
	autoLeft = nil, autoRight = nil,
	anchor = {}, progress = nil,
}

local h, hrp, speedLbl
local setAutoPlay, setAutoLeft, setAutoRight
local setInstaGrab, setAutoBat, setInfJump, setAntiRag, setFps, setMedusaCounter
local setUnwalkToggle
local setLaggerMode, setTryhardAnim
local setupMedusaCounter, stopMedusaCounter, startAntiRagdoll, stopAntiRagdoll
local applyFPSBoost, startAutoSteal, stopAutoSteal
local startAutoLeft, stopAutoLeft, startAutoRight, stopAutoRight
local stopAutoPlay, saveConfig
local toggleAutoPlay
local setCustomFont
local setBatCounter, setVisualStretch, setNoCamColl, setAntiLag, setUltraMode, setStretchedRes
local applyStretchedRes
local applyVisualStretch, removeVisualStretch, applyNoCamCollision, applyAntiLag, applyUltraMode
local resetBaseSide, getBaseSide, runDropBrainrot
local getBat, tryHitBat, performBatSwing
local enableCustomFont, disableCustomFont
local startTryhardAnim, stopTryhardAnim
local saveOriginalAnims, applyAnimPack, restoreOriginalAnims
local modeValLbl, normalBox, carryBox, saveBtn
local hopPowerBox, hopCooldownBox
local autoBatKeyBtn, speedKeyBtn
local autoLeftKeyBtn, autoRightKeyBtn
local guiHideKeyBtn
local dropBrainrotKeyBtn
local laggerModeKeyBtn, laggerSpeedBox
local pbFrame, radiusFrame, progressPct, progressFill, progressRadLbl, radValBtn

-- ============================================================================
-- THEME SYSTEM (4 themes)
-- ============================================================================
local Themes = {
	-- 1: Black & White
	{
		name = "Mono",
		accent       = Color3.fromRGB(235, 235, 240),
		accentDim    = Color3.fromRGB(180, 180, 196),
		accentStrong = Color3.fromRGB(255, 255, 255),
		accentDark   = Color3.fromRGB(30, 30, 38),
	},
	-- 2: Black & Red
	{
		name = "Crimson",
		accent       = Color3.fromRGB(225, 60, 75),
		accentDim    = Color3.fromRGB(160, 50, 60),
		accentStrong = Color3.fromRGB(255, 80, 95),
		accentDark   = Color3.fromRGB(60, 18, 22),
	},
	-- 3: Black & Blue
	{
		name = "Azure",
		accent       = Color3.fromRGB(70, 130, 240),
		accentDim    = Color3.fromRGB(55, 95, 175),
		accentStrong = Color3.fromRGB(95, 155, 255),
		accentDark   = Color3.fromRGB(20, 30, 60),
	},
	-- 4: Black & Pink
	{
		name = "Rose",
		accent       = Color3.fromRGB(245, 100, 165),
		accentDim    = Color3.fromRGB(180, 75, 125),
		accentStrong = Color3.fromRGB(255, 130, 190),
		accentDark   = Color3.fromRGB(55, 20, 38),
	},
}

-- Base palette (dark, theme-agnostic)
local C_BG       = Color3.fromRGB(7, 7, 9)
local C_PANEL    = Color3.fromRGB(12, 12, 15)
local C_PANEL_2  = Color3.fromRGB(17, 17, 21)
local C_ROW      = Color3.fromRGB(15, 15, 19)
local C_ROW_HOV  = Color3.fromRGB(23, 23, 29)
local C_BORDER   = Color3.fromRGB(30, 30, 38)
local C_BORDER_HI= Color3.fromRGB(54, 54, 68)
local C_HEADER   = Color3.fromRGB(5, 5, 7)
local C_TAB_ACT  = Color3.fromRGB(20, 20, 26)
local C_TEXT     = Color3.fromRGB(238, 238, 245)
local C_TEXT_DIM = Color3.fromRGB(140, 140, 156)
local C_TEXT_MUTE= Color3.fromRGB(65, 65, 80)
local C_WHITE    = Color3.fromRGB(255, 255, 255)
local C_OFF_BG   = Color3.fromRGB(19, 19, 24)
local C_KEY_BG   = Color3.fromRGB(12, 12, 16)
local C_DANGER   = Color3.fromRGB(220, 70, 80)

-- Theme accessor (always returns current theme colors)
local function T()
	return Themes[State.currentTheme] or Themes[1]
end

-- Themed elements registry (for live theme switching)
local ThemedElements = {
	-- {element=, prop=, type="accent"/"accentStrong"/etc}
}
local function regTheme(element, prop, kind)
	table.insert(ThemedElements, {el=element, prop=prop, kind=kind})
end
local function applyTheme()
	local t = T()
	for _, e in ipairs(ThemedElements) do
		if e.el and e.el.Parent then
			local col = t[e.kind] or t.accent
			pcall(function() e.el[e.prop] = col end)
		end
	end
end

local LOGO_ID = "rbxassetid://107000024285887"
task.spawn(function() pcall(function() ContentProvider:PreloadAsync({LOGO_ID}) end) end)

local savedAnimate

local function startUnwalk()
	if State.unwalkEnabled then return end
	State.unwalkEnabled = true
	local c = LP.Character
	if not c then return end
	local hum = c:FindFirstChildOfClass("Humanoid")
	if hum then
		for _, t in ipairs(hum:GetPlayingAnimationTracks()) do
			t:Stop()
		end
	end
	local anim = c:FindFirstChild("Animate")
	if anim then
		savedAnimate = anim:Clone()
		anim:Destroy()
	end
end

local function stopUnwalk()
	if not State.unwalkEnabled then return end
	State.unwalkEnabled = false
	local c = LP.Character
	if c and savedAnimate then
		savedAnimate.Parent = c
		savedAnimate.Disabled = false
		savedAnimate = nil
	end
end

local Camera = workspace.CurrentCamera

-- Clean up old GUIs
for _, name in pairs({"VyseSlottedGUI", "KyzenHubGUI", "AdaptHubGUI"}) do
	local old = game:GetService("CoreGui"):FindFirstChild(name)
	if old then old:Destroy() end
	local oldPg = LP:FindFirstChild("PlayerGui") and LP.PlayerGui:FindFirstChild(name)
	if oldPg then oldPg:Destroy() end
end

local viewportSize = Camera.ViewportSize
local IS_MOBILE = UIS.TouchEnabled and not UIS.KeyboardEnabled

-- Draggable helper
local function makeDraggable(frame, linkedFrames)
	linkedFrames = linkedFrames or {}
	local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
	local linkedStart = {}
	frame.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			dragging = true; dragStart = inp.Position; startPos = frame.Position
			linkedStart = {}
			for i, lf in ipairs(linkedFrames) do
				if lf then linkedStart[i] = lf.Position end
			end
			inp.Changed:Connect(function() if inp.UserInputState == Enum.UserInputState.End then dragging = false end end)
		end
	end)
	frame.InputChanged:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then dragInput = inp end
	end)
	UIS.InputChanged:Connect(function(inp)
		if inp == dragInput and dragging then
			local dx = inp.Position.X - dragStart.X
			local dy = inp.Position.Y - dragStart.Y
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+dx, startPos.Y.Scale, startPos.Y.Offset+dy)
			for i, lf in ipairs(linkedFrames) do
				if lf and linkedStart[i] then
					lf.Position = UDim2.new(linkedStart[i].X.Scale, linkedStart[i].X.Offset+dx, linkedStart[i].Y.Scale, linkedStart[i].Y.Offset+dy)
				end
			end
		end
	end)
end

-- ============================================================================
-- DESYNC ENGINE (raknet send hook) — unchanged from original
-- ============================================================================
local _dsEnabled = false
local _dsUnwalkActive = false
local _dsUnwalkConn = nil
local _dsUpdateUI = function() end

local function _dsHook(packet)
    if packet.PacketId == 27 then
        local ok, buf = pcall(function() return packet.AsBuffer end)
        if ok and buf then
            pcall(function() buffer.writeu32(buf, 1, 0xFFFFFFD7) end)
            pcall(function() packet:SetData(buf) end)
        end
    end
end

local function _dsSetActive(on)
    _dsEnabled = on
    if on then
        pcall(function()
            if raknet and raknet.add_send_hook then raknet.add_send_hook(_dsHook) end
        end)
    else
        pcall(function()
            if raknet and raknet.remove_send_hook then raknet.remove_send_hook(_dsHook) end
        end)
    end
    _dsUpdateUI()
end

LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    if _dsEnabled then _dsSetActive(true) end
end)

local function _dsStartUnwalk()
    _dsUnwalkActive = true
    if _dsUnwalkConn then _dsUnwalkConn:Disconnect() end
    _dsUnwalkConn = RunService.Heartbeat:Connect(function()
        if not _dsUnwalkActive then return end
        pcall(function()
            local c = LP.Character; if not c then return end
            local hum = c:FindFirstChildOfClass("Humanoid"); if not hum then return end
            local anim = hum:FindFirstChildOfClass("Animator"); if not anim then return end
            for _, t in ipairs(anim:GetPlayingAnimationTracks()) do t:Stop() end
        end)
    end)
end
local function _dsStopUnwalk()
    _dsUnwalkActive = false
    if _dsUnwalkConn then _dsUnwalkConn:Disconnect(); _dsUnwalkConn = nil end
end

-- ============================================================================
-- GALAXY / FLOAT MECHANIC (VectorForce)
-- ============================================================================
local _galaxyVF = nil
local _galaxyAtt = nil
local _spaceHeld = false
local _lastHopTime = 0

local function _setupGalaxyForce()
    pcall(function()
        local c = LP.Character; if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart"); if not h then return end
        if _galaxyVF then _galaxyVF:Destroy() end
        if _galaxyAtt then _galaxyAtt:Destroy() end
        _galaxyAtt = Instance.new("Attachment"); _galaxyAtt.Parent = h
        _galaxyVF = Instance.new("VectorForce")
        _galaxyVF.Attachment0 = _galaxyAtt
        _galaxyVF.ApplyAtCenterOfMass = true
        _galaxyVF.RelativeTo = Enum.ActuatorRelativeTo.World
        _galaxyVF.Force = Vector3.new(0,0,0)
        _galaxyVF.Parent = h
    end)
end

local function _updateGalaxyForce()
    if not State.floatEnabled or not _galaxyVF then return end
    local c = LP.Character; if not c then return end
    local mass = 0
    for _, p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then mass = mass + p:GetMass() end
    end
    local gravPct = State.floatRiseSpeed
    local tg = 196.2 * (gravPct / 100)
    _galaxyVF.Force = Vector3.new(0, mass * (196.2 - tg) * 0.95, 0)
end

local function _doHop()
    pcall(function()
        local c = LP.Character; if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart")
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not h or not hum then return end
        if tick() - _lastHopTime < 0.08 then return end
        _lastHopTime = tick()
        if hum.FloorMaterial == Enum.Material.Air then
            h.AssemblyLinearVelocity = Vector3.new(
                h.AssemblyLinearVelocity.X,
                State.floatFallSpeed,
                h.AssemblyLinearVelocity.Z
            )
        end
    end)
end

RunService.Heartbeat:Connect(function()
    if _spaceHeld and State.floatEnabled then _doHop() end
    _updateGalaxyForce()
end)

UIS.InputBegan:Connect(function(i, gp)
    if not gp and i.KeyCode == Enum.KeyCode.Space then _spaceHeld = true end
end)
UIS.InputEnded:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.Space then _spaceHeld = false end
end)

LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    if State.floatEnabled then _setupGalaxyForce() end
end)

local function startFloat()
    State.floatEnabled = true
    _setupGalaxyForce()
end
local function stopFloat()
    State.floatEnabled = false
    if _galaxyVF then _galaxyVF:Destroy(); _galaxyVF = nil end
    if _galaxyAtt then _galaxyAtt:Destroy(); _galaxyAtt = nil end
end

local function runTPDown()
    pcall(function()
        loca
