local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Camera = workspace.CurrentCamera
local Mouse = Players.LocalPlayer:GetMouse()
local player = Players.LocalPlayer


local cursorIsForced = false
local savedMouseBehavior = nil
local savedMouseIconEnabled = nil
local CURSOR_RENDER_STEP = "YM_ForceFreeCursor"

local function setCursorForced(visible)
	if visible then
		if not cursorIsForced then
			savedMouseBehavior = UserInputService.MouseBehavior
			savedMouseIconEnabled = UserInputService.MouseIconEnabled
			cursorIsForced = true

			pcall(function()
				RunService:UnbindFromRenderStep(CURSOR_RENDER_STEP)
				RunService:BindToRenderStep(CURSOR_RENDER_STEP, Enum.RenderPriority.Last.Value, function()
					if cursorIsForced then
						UserInputService.MouseBehavior = Enum.MouseBehavior.Default
						UserInputService.MouseIconEnabled = true
					end
				end)
			end)
		end
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		UserInputService.MouseIconEnabled = true
	elseif cursorIsForced then
		cursorIsForced = false
		pcall(function()
			RunService:UnbindFromRenderStep(CURSOR_RENDER_STEP)
		end)
		if savedMouseBehavior then
			UserInputService.MouseBehavior = savedMouseBehavior
		end
		if savedMouseIconEnabled ~= nil then
			UserInputService.MouseIconEnabled = savedMouseIconEnabled
		end
	end
end


local WINDOW_BACKGROUND_IMAGE = "rbxassetid://100446752830441"
local BUTTON_BACKGROUND_IMAGE = "rbxassetid://115507210213862"

local function addButtonBackground(button)
	if not button or not button:IsA("GuiButton") then return end
	if button:FindFirstChild("YM_ButtonBackground") then return end

	-- Trois couches totalement séparées :
	-- 10 = image, 20 = bouton/clique, 30 = texte.
	-- Le TextLabel est un enfant du bouton et Active=false, donc il ne bloque pas le clic.
	button.BackgroundTransparency = math.max(button.BackgroundTransparency, 0.65)
	button.ZIndex = 20

	local background = Instance.new("ImageLabel")
	background.Name = "YM_ButtonBackground"
	background.Size = UDim2.fromScale(1, 1)
	background.Position = UDim2.fromScale(0, 0)
	background.BackgroundTransparency = 1
	background.Image = BUTTON_BACKGROUND_IMAGE
	background.ImageTransparency = 0.12
	background.ScaleType = Enum.ScaleType.Crop
	background.BorderSizePixel = 0
	background.Active = false
	background.Selectable = false
	background.ZIndex = 10
	background.Parent = button

	if button:IsA("TextButton") then
		-- On cache le texte natif du TextButton : le vrai texte est dans YM_ButtonText.
		button.TextTransparency = 1
		button.TextStrokeTransparency = 1

		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "YM_ButtonText"
		textLabel.Size = UDim2.fromScale(1, 1)
		textLabel.Position = UDim2.fromScale(0, 0)
		textLabel.BackgroundTransparency = 1
		textLabel.Text = button.Text
		textLabel.TextColor3 = button.TextColor3
		textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		textLabel.TextStrokeTransparency = 0
		textLabel.TextTransparency = 0
		textLabel.Font = button.Font
		textLabel.TextSize = button.TextSize
		textLabel.TextScaled = button.TextScaled
		textLabel.TextWrapped = button.TextWrapped
		textLabel.TextXAlignment = button.TextXAlignment
		textLabel.TextYAlignment = button.TextYAlignment
		textLabel.RichText = button.RichText
		textLabel.Active = false
		textLabel.Selectable = false
		textLabel.ZIndex = 30
		textLabel.Parent = button

		-- Le texte reste synchronisé avec les changements OFF/ON du bouton.
		button:GetPropertyChangedSignal("Text"):Connect(function()
			if textLabel.Parent then
				textLabel.Text = button.Text
			end
		end)
		button:GetPropertyChangedSignal("TextColor3"):Connect(function()
			if textLabel.Parent then
				textLabel.TextColor3 = button.TextColor3
			end
		end)
	end
end

local function addWindowBackground(frame)
	if not frame or not frame:IsA("GuiObject") then return end
	if frame:FindFirstChild("YM_WindowBackground") then return end


	frame.BackgroundTransparency = 0.25

	local background = Instance.new("ImageLabel")
	background.Name = "YM_WindowBackground"
	background.Size = UDim2.fromScale(1, 1)
	background.Position = UDim2.fromScale(0, 0)
	background.BackgroundTransparency = 1
	background.Image = WINDOW_BACKGROUND_IMAGE
	
	background.ImageTransparency = 0.08
	background.ScaleType = Enum.ScaleType.Crop
	background.BorderSizePixel = 0
	background.Active = false
	background.Selectable = false
	background.ZIndex = 1
	background.Parent = frame


	for _, obj in ipairs(frame:GetDescendants()) do
		if obj:IsA("GuiObject") and obj ~= background then
			obj.ZIndex = math.max(obj.ZIndex + 1, 2)
		end
	end

	
	for _, obj in ipairs(frame:GetDescendants()) do
		if obj:IsA("GuiButton") then
			addButtonBackground(obj)
		end
	end
end



local function protect()
	pcall(function()
		for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
			if typeof(v.Name) == "string" and (v.Name:find("YM") or v.Name:find("Core") or v.Name:find("Password")) then
				v.Name = "Core" .. math.random(100000, 999999)
			end
		end
	end)
end
protect()


local PassGui = Instance.new("ScreenGui")
PassGui.Name = "Core" .. math.random(100000, 999999)
PassGui.ResetOnSpawn = false
PassGui.Parent = player:WaitForChild("PlayerGui")
setCursorForced(true)

local PassFrame = Instance.new("Frame")
PassFrame.Size = UDim2.new(0, 340, 0, 200)
PassFrame.Position = UDim2.new(0.5, -170, 0.5, -100)
PassFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
PassFrame.Parent = PassGui
Instance.new("UICorner", PassFrame).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", PassFrame).Color = Color3.fromRGB(160, 0, 0)

local PassTitle = Instance.new("TextLabel")
PassTitle.Size = UDim2.new(1, 0, 0, 50)
PassTitle.BackgroundColor3 = Color3.fromRGB(18, 0, 0)
PassTitle.Text = "YM TOOL"
PassTitle.TextColor3 = Color3.fromRGB(220, 20, 20)
PassTitle.Font = Enum.Font.GothamBlack
PassTitle.TextSize = 26
PassTitle.Parent = PassFrame
Instance.new("UICorner", PassTitle).CornerRadius = UDim.new(0, 12)

local PassLabel = Instance.new("TextLabel")
PassLabel.Size = UDim2.new(1, -40, 0, 25)
PassLabel.Position = UDim2.new(0, 20, 0, 60)
PassLabel.BackgroundTransparency = 1
PassLabel.Text = "Entre le mot de passe :"
PassLabel.TextColor3 = Color3.fromRGB(200, 160, 160)
PassLabel.Font = Enum.Font.Gotham
PassLabel.TextSize = 14
PassLabel.TextXAlignment = Enum.TextXAlignment.Left
PassLabel.Parent = PassFrame

local PassBox = Instance.new("TextBox")
PassBox.Size = UDim2.new(1, -40, 0, 36)
PassBox.Position = UDim2.new(0, 20, 0, 90)
PassBox.BackgroundColor3 = Color3.fromRGB(25, 8, 8)
PassBox.PlaceholderText = "Mot de passe..."
PassBox.Text = ""
PassBox.TextColor3 = Color3.fromRGB(255, 220, 220)
PassBox.Font = Enum.Font.GothamBold
PassBox.TextSize = 16
PassBox.Parent = PassFrame
Instance.new("UICorner", PassBox).CornerRadius = UDim.new(0, 6)

local PassBtn = Instance.new("TextButton")
PassBtn.Size = UDim2.new(1, -40, 0, 38)
PassBtn.Position = UDim2.new(0, 20, 0, 140)
PassBtn.BackgroundColor3 = Color3.fromRGB(140, 0, 0)
PassBtn.Text = "ENTRER"
PassBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PassBtn.Font = Enum.Font.GothamBold
PassBtn.TextSize = 16
PassBtn.Parent = PassFrame
Instance.new("UICorner", PassBtn).CornerRadius = UDim.new(0, 6)

local ErrorLabel = Instance.new("TextLabel")
ErrorLabel.Size = UDim2.new(1, -20, 0, 20)
ErrorLabel.Position = UDim2.new(0, 10, 1, -25)
ErrorLabel.BackgroundTransparency = 1
ErrorLabel.Text = ""
ErrorLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
ErrorLabel.Font = Enum.Font.Gotham
ErrorLabel.TextSize = 13
ErrorLabel.Parent = PassFrame

addWindowBackground(PassFrame)

local correctPassword = "ymclxn"
local scriptLoaded = false

local function loadMainScript()
	if scriptLoaded then return end
	scriptLoaded = true
	PassGui:Destroy()
	protect()

	
	local flying, flySpeed, walkSpeed = false, 50, 16
	local godmode, invisible, noclip, rgb = false, false, false, false
	local glue, aimbot, esp = false, false, false
	local aimScope = false
	local aiming = false
	local spinning, spinSpeed = false, 50
	local spinning90, spinSpeed90 = false, 5000
	local moveObjects = false
	local clickTP, killAura, bringAll = false, false, false
	local infiniteJump, noFallDamage, antiAFK, ragdoll = false, false, false, false
	local skeletonESP, nameGlitch = false, false
	local fakeLagTP, fakeLagAngles = false, false
	local superForce = false
	local autoClick = false
	local forcePower = 2800
	local jumpPower = 50
	local fpsCap = 0
	local fpsCounterEnabled = true
	local crosshairEnabled = true

	local FPSGui = Instance.new("ScreenGui")
	FPSGui.Name = "YM_FPS_COUNTER"
	FPSGui.ResetOnSpawn = false
	FPSGui.Parent = player:WaitForChild("PlayerGui")

	local FPSLabel = Instance.new("TextLabel")
	FPSLabel.Name = "FPSCounter"
	FPSLabel.Size = UDim2.new(0, 100, 0, 28)
	FPSLabel.Position = UDim2.new(0, 8, 0, 70)
	FPSLabel.BackgroundTransparency = 1
	FPSLabel.Text = "0 FPS"
	FPSLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	FPSLabel.Font = Enum.Font.GothamBold
	FPSLabel.TextSize = 16
	FPSLabel.TextXAlignment = Enum.TextXAlignment.Left
	FPSLabel.Active = true
	FPSLabel.Parent = FPSGui

	local fpsDragging, fpsDragStart, fpsStartPos
	FPSLabel.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			fpsDragging = true
			fpsDragStart = input.Position
			fpsStartPos = FPSLabel.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then fpsDragging = false end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if fpsDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - fpsDragStart
			FPSLabel.Position = UDim2.new(fpsStartPos.X.Scale, fpsStartPos.X.Offset + delta.X, fpsStartPos.Y.Scale, fpsStartPos.Y.Offset + delta.Y)
		end
	end)

	local function applyFPSCap()
		if type(setfpscap) == "function" then
			pcall(function() setfpscap(fpsCap) end)
		end
	end
	applyFPSCap()

	task.spawn(function()
		local last = tick()
		local frames = 0
		while FPSGui.Parent do
			RunService.RenderStepped:Wait()
			frames += 1
			local now = tick()
			if now - last >= 0.5 then
				FPSLabel.Text = math.floor(frames / (now - last) + 0.5) .. " FPS"
				frames = 0
				last = now
			end
		end
	end)

	local bodyGyro, bodyVelocity
	local rgbConnection, glueConnection, spinConnection, spin90Connection
	local moveConnection, clickTPConnection, killAuraConnection
	local bringConnection, jumpConnection, fallConnection, antiAFKConnection
	local skeletonConnection, nameGlitchConnection
	local fakeLagTPConnection, fakeLagAnglesConnection
	local forceConnections = {}
	local autoClickConnection
	local autoClickHeld = false
	local gluedTarget, selectedPart
	local guiVisible = true
	local highlights = {}
	local ragdollConstraints = {}
	local skeletonDrawings = {}
	local nameGlitchBillboard = nil
	local boxESP = false
	local boxESPConnection = nil
	local boxESPObjects = {}
	local teamCheckEnabled = false
	local visibilityCheckEnabled = false
	local fovEnabled = false
	local fovRadius = 150
	local debugVisible = false

	
	local bigHeadEnabled = false
	local tinyCharacterEnabled = false
	local headlessEnabled = false
	local characterVisualBackup = {}

	local function cacheCharacterVisuals(char)
		if characterVisualBackup.char == char then return end
		characterVisualBackup = {char = char, parts = {}, scales = {}}
		local head = char:FindFirstChild("Head")
		if head and head:IsA("BasePart") then
			characterVisualBackup.parts.HeadSize = head.Size
			characterVisualBackup.parts.HeadTransparency = head.Transparency
			for _, obj in ipairs(head:GetDescendants()) do
				if obj:IsA("Decal") or obj:IsA("Texture") then
					characterVisualBackup.parts[obj] = obj.Transparency
				end
			end
		end
		for _, name in ipairs({"Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}) do
			local part = char:FindFirstChild(name)
			if part and part:IsA("BasePart") then characterVisualBackup.parts[name] = part.Size end
		end
		for _, obj in ipairs(char:GetDescendants()) do
			if obj:IsA("NumberValue") and (obj.Name == "BodyHeightScale" or obj.Name == "BodyWidthScale" or obj.Name == "BodyDepthScale" or obj.Name == "HeadScale") then
				characterVisualBackup.scales[obj.Name] = obj.Value
			end
		end
	end

	local function restoreCharacterVisuals()
		local char = player.Character
		if not char or characterVisualBackup.char ~= char then return end
		local head = char:FindFirstChild("Head")
		if head and characterVisualBackup.parts.HeadSize then
			head.Size = characterVisualBackup.parts.HeadSize
			head.Transparency = characterVisualBackup.parts.HeadTransparency or 0
			for _, obj in ipairs(head:GetDescendants()) do
				if (obj:IsA("Decal") or obj:IsA("Texture")) and characterVisualBackup.parts[obj] ~= nil then
					obj.Transparency = characterVisualBackup.parts[obj]
				end
			end
		end
		for _, name in ipairs({"Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}) do
			local part = char:FindFirstChild(name)
			local original = characterVisualBackup.parts[name]
			if part and original then part.Size = original end
		end
		for name, value in pairs(characterVisualBackup.scales) do
			local obj = char:FindFirstChild(name, true)
			if obj and obj:IsA("NumberValue") then obj.Value = value end
		end
	end

	local function updateCharacterVisuals()
		local char = player.Character
		if not char then return end
		cacheCharacterVisuals(char)
		restoreCharacterVisuals()
		local head = char:FindFirstChild("Head")
		local hum = char:FindFirstChildOfClass("Humanoid")
		if bigHeadEnabled and head and head:IsA("BasePart") then
			head.Size = characterVisualBackup.parts.HeadSize * 2.5
		end
		if tinyCharacterEnabled then
			for _, name in ipairs({"BodyHeightScale", "BodyWidthScale", "BodyDepthScale", "HeadScale"}) do
				local obj = char:FindFirstChild(name, true)
				if obj and obj:IsA("NumberValue") then obj.Value = (characterVisualBackup.scales[name] or 1) * 0.35 end
			end
			if not char:FindFirstChild("BodyHeightScale", true) then
				for _, name in ipairs({"Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}) do
					local part = char:FindFirstChild(name)
					if part and part:IsA("BasePart") then
						local original = characterVisualBackup.parts[name] or part.Size
						characterVisualBackup.parts[name] = original
						part.Size = original * 0.35
					end
				end
			end
		end
		if headlessEnabled and head then
			head.Transparency = 1
			for _, obj in ipairs(head:GetDescendants()) do
				if obj:IsA("Decal") or obj:IsA("Texture") then obj.Transparency = 1 end
			end
		end
	end

	
	local waypointSlots = {}
	for i = 1, 6 do waypointSlots[i] = {name = "Slot " .. i, cframe = nil} end
	local WaypointFrame

	
	local CrosshairGui = Instance.new("ScreenGui")
	CrosshairGui.Name = "YM_Crosshair"
	CrosshairGui.ResetOnSpawn = false
	CrosshairGui.IgnoreGuiInset = true
	CrosshairGui.Parent = player:WaitForChild("PlayerGui")
	local CrosshairDot = Instance.new("Frame")
	CrosshairDot.Name = "RGBDot"
	CrosshairDot.Size = UDim2.fromOffset(5, 5)
	CrosshairDot.AnchorPoint = Vector2.new(0.5, 0.5)
	CrosshairDot.Position = UDim2.new(0.5, 0, 0.5, 0)
	CrosshairDot.BorderSizePixel = 0
	CrosshairDot.ZIndex = 100
	CrosshairDot.Visible = crosshairEnabled
	CrosshairDot.Parent = CrosshairGui
	Instance.new("UICorner", CrosshairDot).CornerRadius = UDim.new(1, 0)
	task.spawn(function()
		while CrosshairGui.Parent do
			CrosshairDot.Visible = crosshairEnabled
			if crosshairEnabled then CrosshairDot.BackgroundColor3 = Color3.fromHSV((tick() * 0.25) % 1, 1, 1) end
			RunService.RenderStepped:Wait()
		end
	end)



	
	local VisibilityESP = {}
	local isTeammate
	local isVisibleFromCamera

	local function removeVisibilityESP(plr)
		local obj = VisibilityESP[plr]
		if obj then
			if obj.box then pcall(function() obj.box:Remove() end) end
			VisibilityESP[plr] = nil
		end
	end

	local function createVisibilityESP(plr)
		if plr == player or VisibilityESP[plr] then return end
		local char = plr.Character
		if not char then return end

		
		local highlight = Instance.new("Highlight")
		highlight.Name = "YM_VisibilityHighlight"
		highlight.Adornee = char
		highlight.FillTransparency = 0.35
		highlight.OutlineTransparency = 1
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.Enabled = visibilityCheckEnabled
		highlight.Parent = char

		VisibilityESP[plr] = {highlight = highlight}
	end

	local function updateVisibilityESP()
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character and not isTeammate(plr) then
				local char = plr.Character
				local root = char:FindFirstChild("HumanoidRootPart")
				local head = char:FindFirstChild("Head")
				local hum = char:FindFirstChildOfClass("Humanoid")

				if root and head and hum and hum.Health > 0 then
					createVisibilityESP(plr)
					local d = VisibilityESP[plr]
					if d and d.highlight then
						-- Vert = le joueur est visible ; rouge = il est derrière un obstacle.
						local visible = isVisibleFromCamera(root, char)
						d.highlight.FillColor = visible and Color3.fromRGB(40, 255, 80) or Color3.fromRGB(255, 40, 40)
						d.highlight.Enabled = visibilityCheckEnabled
					end
				else
					removeVisibilityESP(plr)
				end
			else
				removeVisibilityESP(plr)
			end
		end
	end

	Players.PlayerRemoving:Connect(removeVisibilityESP)

	RunService.RenderStepped:Connect(function()
		if visibilityCheckEnabled then
			updateVisibilityESP()
		else
			for _, obj in pairs(VisibilityESP) do
				if obj.highlight then obj.highlight.Enabled = false end
			end
		end
	end)

	
	local FOVGui = Instance.new("ScreenGui")
	FOVGui.Name = "YM_FOV"
	FOVGui.IgnoreGuiInset = true
	FOVGui.ResetOnSpawn = false
	FOVGui.Parent = player:WaitForChild("PlayerGui")

	local FOVCircle = Instance.new("Frame")
	FOVCircle.Name = "FOVCircle"
	FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
	FOVCircle.Position = UDim2.fromScale(0.5, 0.5)
	FOVCircle.Size = UDim2.fromOffset(fovRadius * 2, fovRadius * 2)
	FOVCircle.BackgroundTransparency = 1
	FOVCircle.Visible = fovEnabled
	FOVCircle.ZIndex = 90
	FOVCircle.Parent = FOVGui
	local fovCorner = Instance.new("UICorner")
	fovCorner.CornerRadius = UDim.new(1, 0)
	fovCorner.Parent = FOVCircle
	local fovStroke = Instance.new("UIStroke")
	fovStroke.Thickness = 1.5
	fovStroke.Parent = FOVCircle

	task.spawn(function()
		while FOVGui.Parent do
			FOVCircle.Visible = fovEnabled
			FOVCircle.Size = UDim2.fromOffset(fovRadius * 2, fovRadius * 2)
			if fovEnabled then
				fovStroke.Color = Color3.fromHSV((tick() * 0.25) % 1, 1, 1)
			end
			RunService.RenderStepped:Wait()
		end
	end)


	local function getChar() return player.Character end
	local function getHumanoid() local c = getChar() return c and c:FindFirstChildOfClass("Humanoid") end
	local function getRoot() local c = getChar() return c and c:FindFirstChild("HumanoidRootPart") end

	isTeammate = function(plr)
		if not teamCheckEnabled then return false end
		if player.Team ~= nil and plr.Team ~= nil then
			return player.Team == plr.Team
		end
		return false
	end

	isVisibleFromCamera = function(part, char)
		if not visibilityCheckEnabled then return true end
		local currentCamera = workspace.CurrentCamera
		if not currentCamera or not char then return false end

		local origin = currentCamera.CFrame.Position
		local points = {}

		-- Plusieurs points évitent les faux rouges quand seule la tête est derrière un petit obstacle.
		local head = char:FindFirstChild("Head")
		local root = char:FindFirstChild("HumanoidRootPart")
		local upper = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
		local lower = char:FindFirstChild("LowerTorso")
		local leftArm = char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm")
		local rightArm = char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm")

		for _, obj in ipairs({head, upper, lower, root, leftArm, rightArm, part}) do
			if obj and obj:IsA("BasePart") then
				table.insert(points, obj.Position)
			end
		end

		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = {player.Character, char}
		params.IgnoreWater = true

		
		for _, targetPosition in ipairs(points) do
			local direction = targetPosition - origin
			if direction.Magnitude <= 0.01 then
				return true
			end

			local result = workspace:Raycast(origin, direction, params)
			if result == nil then
				return true
			end
		end

		return false
	end

	local function setWalkSpeed(v)
		walkSpeed = v
		local h = getHumanoid()
		if h then
			h.WalkSpeed = v
			h:SetStateEnabled(Enum.HumanoidStateType.Running, true)
		end
	end

	
	local gameSprintSpeed = nil

	
	local function startFly()
		if flying then return end
		flying = true
		local root, hum = getRoot(), getHumanoid()
		if not root or not hum then return end
		bodyGyro = Instance.new("BodyGyro")
		bodyGyro.P = 9e4
		bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		bodyGyro.CFrame = root.CFrame
		bodyGyro.Parent = root
		bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
		bodyVelocity.Parent = root
		hum.PlatformStand = true
	end
	local function stopFly()
		if not flying then return end
		flying = false
		if bodyGyro then bodyGyro:Destroy() end
		if bodyVelocity then bodyVelocity:Destroy() end
		local hum = getHumanoid()
		if hum then hum.PlatformStand = false end
	end

	local function setInvisible(state)
		local char = getChar()
		if not char then return end
		for _, v in pairs(char:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Transparency = state and 1 or 0
				if state then v.CanCollide = false end
			elseif v:IsA("Decal") or v:IsA("Texture") then
				v.Transparency = state and 1 or 0
			elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then
				v.Enabled = not state
			end
		end
	end

	local function startRGB()
		if rgbConnection then rgbConnection:Disconnect() end
		rgbConnection = RunService.Heartbeat:Connect(function()
			if not rgb then return end
			local char = getChar()
			if not char then return end
			local color = Color3.fromHSV((tick() % 5)/5, 1, 1)
			for _, p in pairs(char:GetDescendants()) do
				if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" and p.Transparency < 0.1 then
					p.Color = color
				end
			end
		end)
	end
	local function stopRGB() if rgbConnection then rgbConnection:Disconnect() rgbConnection = nil end end

	local function getClosestPlayer()
		local closest, shortest, myRoot = nil, math.huge, getRoot()
		if not myRoot then return end
		for _, plr in pairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
				local d = (myRoot.Position - plr.Character.HumanoidRootPart.Position).Magnitude
				if d < shortest then shortest = d closest = plr end
			end
		end
		return closest
	end

	local function startGlue()
		if glueConnection then return end
		local t = getClosestPlayer()
		if not t then return end
		gluedTarget = t
		glueConnection = RunService.Heartbeat:Connect(function()
			if not glue or not gluedTarget then return end
			local myRoot = getRoot()
			local tr = gluedTarget.Character and gluedTarget.Character:FindFirstChild("HumanoidRootPart")
			if myRoot and tr then myRoot.CFrame = tr.CFrame * CFrame.new(0, 0, 1.5)
			else stopGlue() if glue then task.wait(0.2) startGlue() end end
		end)
	end
	local function stopGlue() if glueConnection then glueConnection:Disconnect() glueConnection = nil end gluedTarget = nil end


	local function startSpin()
		if spinConnection then return end
		spinConnection = RunService.Heartbeat:Connect(function()
			if not spinning then return end
			local r = getRoot()
			if r then r.CFrame = r.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0) end
		end)
	end
	local function stopSpin() if spinConnection then spinConnection:Disconnect() spinConnection = nil end end

	local function startSpin90()
		if spin90Connection then return end
		spin90Connection = RunService.Heartbeat:Connect(function()
			if not spinning90 then return end
			local r = getRoot()
			if r then
				r.CFrame = CFrame.new(r.Position) * CFrame.Angles(math.rad(90), math.rad(tick() * spinSpeed90), 0)
			end
		end)
	end
	local function stopSpin90() if spin90Connection then spin90Connection:Disconnect() spin90Connection = nil end end

	local function startMoveObjects()
		if moveConnection then return end
		moveConnection = Mouse.Button1Down:Connect(function()
			if not moveObjects then return end
			local t = Mouse.Target
			if t and t:IsA("BasePart") and not t:IsDescendantOf(player.Character) then
				selectedPart = t
				if selectedPart:FindFirstChild("YM_Select") then selectedPart.YM_Select:Destroy() end
				local s = Instance.new("SelectionBox")
				s.Name = "YM_Select"
				s.Adornee = selectedPart
				s.Color3 = Color3.fromRGB(255, 50, 50)
				s.Parent = selectedPart
			end
		end)
		RunService.Heartbeat:Connect(function()
			if moveObjects and selectedPart and selectedPart.Parent and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
				selectedPart.CFrame = CFrame.new(Mouse.Hit.Position)
			end
		end)
	end
	local function stopMoveObjects()
		if selectedPart and selectedPart:FindFirstChild("YM_Select") then selectedPart.YM_Select:Destroy() end
		selectedPart = nil
		if moveConnection then moveConnection:Disconnect() moveConnection = nil end
	end

	local function getPlayerUnderMouse()
		local target = Mouse.Target
		if not target then return nil end
		local character = target:FindFirstAncestorOfClass("Model")
		if not character then return nil end
		local plr = Players:GetPlayerFromCharacter(character)
		if not plr or plr == player or isTeammate(plr) then return nil end
		local hum = character:FindFirstChildOfClass("Humanoid")
		if not hum or hum.Health <= 0 then return nil end
		if visibilityCheckEnabled and not isVisibleFromCamera(target, character) then return nil end
		return plr
	end

	local function stopAutoClick()
		if autoClickHeld then
			pcall(function()
				VirtualUser:Button1Up(Vector2.new(Mouse.X, Mouse.Y), Camera.CFrame)
			end)
			autoClickHeld = false
		end
		if autoClickConnection then autoClickConnection:Disconnect() autoClickConnection = nil end
	end

	local function startAutoClick()
		if autoClickConnection then return end
		autoClickConnection = RunService.RenderStepped:Connect(function()
			if not autoClick then return end
			local targetPlayer = getPlayerUnderMouse()
			if targetPlayer then
				if not autoClickHeld then
					autoClickHeld = true
					pcall(function()
						VirtualUser:Button1Down(Vector2.new(Mouse.X, Mouse.Y), Camera.CFrame)
					end)
				end
			elseif autoClickHeld then
				pcall(function()
					VirtualUser:Button1Up(Vector2.new(Mouse.X, Mouse.Y), Camera.CFrame)
				end)
				autoClickHeld = false
			end
		end)
	end

	local function startClickTP()
		if clickTPConnection then return end
		clickTPConnection = Mouse.Button1Down:Connect(function()
			if not clickTP then return end
			local r = getRoot()
			if r then r.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0)) end
		end)
	end
	local function stopClickTP() if clickTPConnection then clickTPConnection:Disconnect() clickTPConnection = nil end end

	local function startKillAura()
		if killAuraConnection then return end
		killAuraConnection = RunService.Heartbeat:Connect(function()
			if not killAura then return end
			local myRoot = getRoot()
			if not myRoot then return end
			for _, plr in pairs(Players:GetPlayers()) do
				if plr ~= player and not isTeammate(plr) and plr.Character then
					local hum = plr.Character:FindFirstChildOfClass("Humanoid")
					local root = plr.Character:FindFirstChild("HumanoidRootPart")
					if hum and root and hum.Health > 0 and (myRoot.Position - root.Position).Magnitude < 15 then
						pcall(function() hum.Health = 0 end)
					end
				end
			end
		end)
	end
	local function stopKillAura() if killAuraConnection then killAuraConnection:Disconnect() killAuraConnection = nil end end


	local function startBringAll()
		if bringConnection then return end
		bringConnection = RunService.Heartbeat:Connect(function()
			if not bringAll then return end
			local myRoot = getRoot()
			if not myRoot then return end
			for _, plr in pairs(Players:GetPlayers()) do
				if plr ~= player and plr.Character then
					local root = plr.Character:FindFirstChild("HumanoidRootPart")
					if root then root.CFrame = myRoot.CFrame * CFrame.new(0, 0, 5) end
				end
			end
		end)
	end
	local function stopBringAll() if bringConnection then bringConnection:Disconnect() bringConnection = nil end end

	local function startInfiniteJump()
		if jumpConnection then return end
		jumpConnection = UserInputService.JumpRequest:Connect(function()
			if not infiniteJump then return end
			local h = getHumanoid()
			if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
		end)
	end
	local function stopInfiniteJump() if jumpConnection then jumpConnection:Disconnect() jumpConnection = nil end end

	local function startNoFallDamage()
		if fallConnection then return end
		fallConnection = RunService.Heartbeat:Connect(function()
			if not noFallDamage then return end
			local h = getHumanoid()
			if h and h:GetState() == Enum.HumanoidStateType.Freefall then
				h:ChangeState(Enum.HumanoidStateType.GettingUp)
			end
		end)
	end
	local function stopNoFallDamage() if fallConnection then fallConnection:Disconnect() fallConnection = nil end end

	local function startAntiAFK()
		if antiAFKConnection then return end
		antiAFKConnection = player.Idled:Connect(function()
			VirtualUser:CaptureController()
			VirtualUser:ClickButton2(Vector2.new())
		end)
	end
	local function stopAntiAFK() if antiAFKConnection then antiAFKConnection:Disconnect() antiAFKConnection = nil end end

	local function startRagdoll()
		local char = getChar()
		local hum = getHumanoid()
		if not char or not hum then return end
		hum.PlatformStand = true
		hum:ChangeState(Enum.HumanoidStateType.Physics)
		for _, v in pairs(char:GetDescendants()) do
			if v:IsA("Motor6D") and v.Part0 and v.Part1 then
				local att0 = Instance.new("Attachment")
				att0.Name = "YM_RagA0"
				att0.CFrame = v.C0
				att0.Parent = v.Part0
				local att1 = Instance.new("Attachment")
				att1.Name = "YM_RagA1"
				att1.CFrame = v.C1
				att1.Parent = v.Part1
				local ball = Instance.new("BallSocketConstraint")
				ball.Name = "YM_Ragdoll"
				ball.Attachment0 = att0
				ball.Attachment1 = att1
				ball.LimitsEnabled = false
				ball.Parent = v.Part0
				table.insert(ragdollConstraints, {motor = v, ball = ball, att0 = att0, att1 = att1})
				v.Enabled = false
			end
		end
	end
	local function stopRagdoll()
		local hum = getHumanoid()
		if hum then
			hum.PlatformStand = false
			hum:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
		for _, data in pairs(ragdollConstraints) do
			if data.motor then data.motor.Enabled = true end
			if data.ball then data.ball:Destroy() end
			if data.att0 then data.att0:Destroy() end
			if data.att1 then data.att1:Destroy() end
		end
		table.clear(ragdollConstraints)
	end

	-- ========== FORCE x1000 CORRIGÉE ==========
	local function setupSuperForce(char)
		for _, conn in pairs(forceConnections) do
			conn:Disconnect()
		end
		table.clear(forceConnections)
		if not superForce or not char then return end
		for _, part in pairs(char:GetDescendants()) do
			if part:IsA("BasePart") then
				local conn = part.Touched:Connect(function(hit)
					if not superForce then return end
					local enemyChar = hit:FindFirstAncestorOfClass("Model")
					if not enemyChar or enemyChar == char then return end
					local enemyHum = enemyChar:FindFirstChildOfClass("Humanoid")
					local enemyRoot = enemyChar:FindFirstChild("HumanoidRootPart")
					local myRoot = getRoot()
					if enemyHum and enemyRoot and myRoot and enemyHum.Health > 0 then
						local direction = (enemyRoot.Position - myRoot.Position)
						if direction.Magnitude < 0.8 then
							direction = myRoot.CFrame.LookVector
						else
							direction = direction.Unit
						end
						local power = forcePower
						enemyRoot.AssemblyLinearVelocity = direction * power + Vector3.new(0, power * 0.55, 0)
						local bv = Instance.new("BodyVelocity")
						bv.Velocity = direction * power + Vector3.new(0, power * 0.5, 0)
						bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
						bv.Parent = enemyRoot
						game:GetService("Debris"):AddItem(bv, 0.45)
					end
				end)
				table.insert(forceConnections, conn)
			end
		end
	end

	-- ESP Squelette
	local function clearSkeleton()
		for _, drawings in pairs(skeletonDrawings) do
			for _, d in pairs(drawings) do if d and d.Remove then d:Remove() end end
		end
		table.clear(skeletonDrawings)
	end
	local function startSkeletonESP()
		if skeletonConnection then return end
		skeletonConnection = RunService.RenderStepped:Connect(function()
			if not skeletonESP then return end
			clearSkeleton()
			for _, plr in pairs(Players:GetPlayers()) do
				if plr ~= player and not isTeammate(plr) and plr.Character then
					local char = plr.Character
					local bones = {
						{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
						{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
						{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
						{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
						{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}
					}
					if not char:FindFirstChild("UpperTorso") then
						bones = {{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}}
					end
					local drawings = {}
					for _, pair in pairs(bones) do
						local p1 = char:FindFirstChild(pair[1])
						local p2 = char:FindFirstChild(pair[2])
						if p1 and p2 then
							local pos1, on1 = Camera:WorldToViewportPoint(p1.Position)
							local pos2, on2 = Camera:WorldToViewportPoint(p2.Position)
							if on1 or on2 then
								local line = Drawing.new("Line")
								line.From = Vector2.new(pos1.X, pos1.Y)
								line.To = Vector2.new(pos2.X, pos2.Y)
								line.Color = Color3.fromRGB(255, 50, 50)
								line.Thickness = 1.5
								line.Visible = true
								table.insert(drawings, line)
							end
						end
					end
					skeletonDrawings[plr] = drawings
				end
			end
		end)
	end
	local function stopSkeletonESP()
		if skeletonConnection then skeletonConnection:Disconnect() skeletonConnection = nil end
		clearSkeleton()
	end

	local function clearNameHealth()
		for _, bb in pairs(nameHealthBillboards) do if bb then bb:Destroy() end end
		table.clear(nameHealthBillboards)
	end

	local function startNameGlitch()
		if nameGlitchConnection then return end
		local char = getChar()
		if not char then return end
		local head = char:FindFirstChild("Head")
		if not head then return end
		if nameGlitchBillboard then nameGlitchBillboard:Destroy() end
		local bb = Instance.new("BillboardGui")
		bb.Name = "YM_NameGlitch"
		bb.Adornee = head
		bb.Size = UDim2.new(0, 260, 0, 40)
		bb.StudsOffset = Vector3.new(0, 3.3, 0)
		bb.AlwaysOnTop = true
		bb.Parent = head
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.GothamBlack
		label.TextSize = 18
		label.TextStrokeTransparency = 0.3
		label.Parent = bb
		nameGlitchBillboard = bb
		local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789@#$%&*!?"
		nameGlitchConnection = RunService.Heartbeat:Connect(function()
			if not nameGlitch or not label or not label.Parent then return end
			local glitchText = ""
			for i = 1, 14 do
				glitchText = glitchText .. string.sub(chars, math.random(1, #chars), math.random(1, #chars))
			end
			label.Text = glitchText
			label.TextColor3 = Color3.fromHSV((tick() * 3) % 1, 1, 1)
		end)
	end
	local function stopNameGlitch()
		if nameGlitchConnection then nameGlitchConnection:Disconnect() nameGlitchConnection = nil end
		if nameGlitchBillboard then nameGlitchBillboard:Destroy() nameGlitchBillboard = nil end
	end

	local function startFakeLagTP()
		if fakeLagTPConnection then return end
		fakeLagTPConnection = RunService.Heartbeat:Connect(function()
			if not fakeLagTP then return end
			local root = getRoot()
			if root and math.random(1, 8) == 1 then
				local offset = Vector3.new(math.random(-4, 4), 0, math.random(-4, 4))
				root.CFrame = root.CFrame + offset
				task.wait(0.05)
				root.CFrame = root.CFrame - offset
			end
		end)
	end
	local function stopFakeLagTP() if fakeLagTPConnection then fakeLagTPConnection:Disconnect() fakeLagTPConnection = nil end end

	local function startFakeLagAngles()
		if fakeLagAnglesConnection then return end
		fakeLagAnglesConnection = RunService.Heartbeat:Connect(function()
			if not fakeLagAngles then return end
			local root = getRoot()
			if root then
				root.CFrame = CFrame.new(root.Position) * CFrame.Angles(
					math.rad(math.random(-60, 60)),
					math.rad(math.random(0, 360)),
					math.rad(math.random(-40, 40))
				)
			end
		end)
	end
	local function stopFakeLagAngles() if fakeLagAnglesConnection then fakeLagAnglesConnection:Disconnect() fakeLagAnglesConnection = nil end end

	-- ========== ESP BOX RGB + LIGNE CENTRALE + VIE + NOM + DISTANCE ==========
	local function removeBoxESP(plr)
		local data = boxESPObjects[plr]
		if data then
			for _, obj in pairs(data) do if obj and obj.Remove then pcall(function() obj:Remove() end) end end
			boxESPObjects[plr] = nil
		end
	end
	local function clearBoxESP() for plr in pairs(boxESPObjects) do removeBoxESP(plr) end end
	local function startBoxESP()
		if boxESPConnection then return end
		boxESPConnection = RunService.RenderStepped:Connect(function()
			if not boxESP then return end
			local rgbColor = Color3.fromHSV((tick() * 0.25) % 1, 1, 1)
			local currentCamera = workspace.CurrentCamera or Camera
			if not currentCamera then return end
			Camera = currentCamera
			local viewport = currentCamera.ViewportSize
			local screenCenter = Vector2.new(viewport.X / 2, viewport.Y / 2)
			for _, plr in pairs(Players:GetPlayers()) do
				if plr ~= player and not isTeammate(plr) and plr.Character then
					local char = plr.Character
					local root, head = char:FindFirstChild("HumanoidRootPart"), char:FindFirstChild("Head")
					local hum = char:FindFirstChildOfClass("Humanoid")
					if root and head and hum and hum.Health > 0 then
						local top3, topOn = currentCamera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.35, 0))
						local bot3, botOn = currentCamera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
						if (topOn or botOn) and top3.Z > 0 and bot3.Z > 0 then
							local h = math.max(12, math.abs(bot3.Y - top3.Y)); local w = math.max(8, h * 0.55)
							local x, y = top3.X - w/2, top3.Y
							local d = boxESPObjects[plr]
							if not d then
								d = {box=Drawing.new("Square"), line=Drawing.new("Line"), healthBG=Drawing.new("Square"), health=Drawing.new("Square"), name=Drawing.new("Text"), distance=Drawing.new("Text")}
								d.box.Filled=false; d.box.Thickness=2; d.line.Thickness=1.5; d.healthBG.Filled=true; d.health.Filled=true
								d.name.Center=true; d.name.Outline=true; d.name.Size=13; d.name.Font=2
								d.distance.Center=true; d.distance.Outline=true; d.distance.Size=11; d.distance.Font=2
								boxESPObjects[plr]=d
							end
							d.box.Position=Vector2.new(x,y); d.box.Size=Vector2.new(w,h)
							d.box.Color = rgbColor
							d.box.Visible=true
							d.line.From=screenCenter; d.line.To=Vector2.new(x+w/2,y+h/2)
							d.line.Color = rgbColor
							d.line.Visible = boxESP
							d.healthBG.Visible=true
							d.health.Visible=true
							d.name.Visible=true
							d.distance.Visible=true
							local ratio=math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1); local bx=x+w+4
							d.healthBG.Position=Vector2.new(bx,y); d.healthBG.Size=Vector2.new(4,h); d.healthBG.Color=Color3.fromRGB(25,25,25); d.healthBG.Visible=true
							d.health.Position=Vector2.new(bx,y+h*(1-ratio)); d.health.Size=Vector2.new(4,h*ratio); d.health.Color=Color3.fromHSV(math.clamp(ratio*.33,0,.33),1,1); d.health.Visible=true
							d.name.Position=Vector2.new(top3.X, y-16); d.name.Text=plr.DisplayName; d.name.Color=rgbColor; d.name.Visible=true
							local myRoot=getRoot(); local dist=myRoot and (myRoot.Position-root.Position).Magnitude or 0
							d.distance.Position=Vector2.new(top3.X, y+h+3); d.distance.Text=string.format("%dm", math.floor(dist+0.5)); d.distance.Color=rgbColor; d.distance.Visible=true
						else removeBoxESP(plr) end
					else removeBoxESP(plr) end
				end
			end
		end)
	end
	local function stopBoxESP() if boxESPConnection then boxESPConnection:Disconnect(); boxESPConnection=nil end; clearBoxESP() end

	local function createESP(plr)
		if plr == player or highlights[plr] or isTeammate(plr) then return end
		local char = plr.Character
		if not char then return end
		local h = Instance.new("Highlight")
		h.FillColor = Color3.fromRGB(180, 0, 0)
		h.OutlineColor = Color3.fromRGB(255, 40, 40)
		h.FillTransparency = 0.45
		h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		h.Parent = char
		highlights[plr] = h
	end
	local function removeESP(plr)
		if highlights[plr] then highlights[plr]:Destroy() highlights[plr] = nil end
	end
	local function updateESP()
		for _, plr in pairs(Players:GetPlayers()) do
			if esp and plr.Character and not isTeammate(plr) then
				createESP(plr)
			else
				removeESP(plr)
			end
		end
	end

	local function getClosestHead()
		local closest, shortest = nil, math.huge
		local currentCamera = workspace.CurrentCamera
		if not currentCamera then return end
		local screenCenter = currentCamera.ViewportSize * 0.5
		for _, plr in pairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character then
				local head = plr.Character:FindFirstChild("Head")
				local hum = plr.Character:FindFirstChildOfClass("Humanoid")
				if head and hum and hum.Health > 0 then
					local pos, onScreen = currentCamera:WorldToViewportPoint(head.Position)
					if onScreen and pos.Z > 0 then
						local d = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
						if d < shortest then shortest = d closest = head end
					end
				end
			end
		end
		return closest
	end

	local function teleportToPlayer(target)
		if not target or target == player then return end
		local myRoot = getRoot()
		local tr = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
		if myRoot and tr then myRoot.CFrame = tr.CFrame * CFrame.new(0, 0, 3.5) end
	end

	local function spectatePlayer(target)
		if not target or not target.Character then return end
		local hum = target.Character:FindFirstChildOfClass("Humanoid")
		if hum then Camera.CameraSubject = hum end
	end
	local function stopSpectate()
		local hum = getHumanoid()
		if hum then Camera.CameraSubject = hum end
	end

	-------------------------------------------------
	-- INTERFACE - CARTOGRAPHIE 0.6 / OUTILS 0.5
	-------------------------------------------------
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "Core" .. math.random(100000, 999999)
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.Parent = player:WaitForChild("PlayerGui")

	local WINDOW_BACKGROUND_IMAGE = "rbxassetid://100446752830441"
	local BUTTON_BACKGROUND_IMAGE = "rbxassetid://115507210213862"

	local Main = Instance.new("Frame")
	Main.Name = "Main"
	Main.Size = UDim2.new(0, 720, 0, 520)
	Main.Position = UDim2.new(0.5, -360, 0.5, -260)
	Main.BackgroundColor3 = Color3.fromRGB(15, 5, 5)
	Main.BackgroundTransparency = 0.15
	Main.BorderSizePixel = 0
	Main.Active = true
	Main.Parent = ScreenGui
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

	-- MOBILE UI : échelle responsive téléphone/tablette
	local DebugFrame, ListFrame, TPFrame, SpecFrame, WaypointFrame
	local MainScale = Instance.new("UIScale")
	MainScale.Name = "YM_MobileScale"
	MainScale.Scale = 1
	MainScale.Parent = Main

	local function updateMobileScale()
		local camera = workspace.CurrentCamera
		if not camera then return end
		local viewport = camera.ViewportSize
		if UserInputService.TouchEnabled then
			MainScale.Scale = math.clamp(math.min(viewport.X / 720, viewport.Y / 520), 0.62, 0.92)
		else
			MainScale.Scale = 1
		end
	end
	updateMobileScale()
	if workspace.CurrentCamera then
		workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateMobileScale)
	end

	-- X pour fermer, YM pour réafficher quand on veut
	local MainClose = Instance.new("TextButton")
	MainClose.Name = "YM_Close"
	MainClose.Size = UDim2.fromOffset(40, 40)
	MainClose.Position = UDim2.new(1, -48, 0, 8)
	MainClose.BackgroundColor3 = Color3.fromRGB(140, 0, 0)
	MainClose.BorderSizePixel = 0
	MainClose.Text = "X"
	MainClose.TextColor3 = Color3.fromRGB(255, 255, 255)
	MainClose.Font = Enum.Font.GothamBlack
	MainClose.TextSize = 18
	MainClose.ZIndex = 100
	MainClose.Parent = Main
	Instance.new("UICorner", MainClose).CornerRadius = UDim.new(0, 8)

	local ReopenYM = Instance.new("TextButton")
	ReopenYM.Name = "YM_Reopen"
	ReopenYM.Size = UDim2.fromOffset(54, 54)
	ReopenYM.AnchorPoint = Vector2.new(1, 1)
	ReopenYM.Position = UDim2.new(1, -18, 1, -92)
	ReopenYM.BackgroundColor3 = Color3.fromRGB(70, 0, 0)
	ReopenYM.BorderSizePixel = 0
	ReopenYM.Text = "YM"
	ReopenYM.TextColor3 = Color3.fromRGB(255, 255, 255)
	ReopenYM.Font = Enum.Font.GothamBlack
	ReopenYM.TextSize = 17
	ReopenYM.Visible = false
	ReopenYM.ZIndex = 500
	ReopenYM.Parent = ScreenGui
	Instance.new("UICorner", ReopenYM).CornerRadius = UDim.new(1, 0)
	local reopenAspect = Instance.new("UIAspectRatioConstraint")
	reopenAspect.AspectRatio = 1
	reopenAspect.Parent = ReopenYM
	local reopenStroke = Instance.new("UIStroke")
	reopenStroke.Color = Color3.fromRGB(180, 0, 0)
	reopenStroke.Thickness = 2
	reopenStroke.Parent = ReopenYM

	local function hideYMTool()
		Main.Visible = false
		ReopenYM.Visible = true
		if DebugFrame then DebugFrame.Visible = false end
		if ListFrame then ListFrame.Visible = false end
		if TPFrame then TPFrame.Visible = false end
		if SpecFrame then SpecFrame.Visible = false end
		if WaypointFrame then WaypointFrame.Visible = false end
	end

	MainClose.Activated:Connect(hideYMTool)
	ReopenYM.Activated:Connect(function()
		Main.Visible = true
		ReopenYM.Visible = false
	end)

	local Background = Instance.new("ImageLabel")
	Background.Name = "YM_WindowBackground"
	Background.Size = UDim2.fromScale(1, 1)
	Background.BackgroundTransparency = 1
	Background.Image = WINDOW_BACKGROUND_IMAGE
	Background.ImageTransparency = 0.08
	Background.ScaleType = Enum.ScaleType.Crop
	Background.BorderSizePixel = 0
	Background.ZIndex = 1
	Background.Parent = Main
	Instance.new("UICorner", Background).CornerRadius = UDim.new(0, 10)

	local Title = Instance.new("TextLabel")
	Title.Size = UDim2.new(1, -30, 0, 42)
	Title.Position = UDim2.new(0, 15, 0, 8)
	Title.BackgroundTransparency = 1
	Title.Text = "YM TOOL"
	Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title.TextStrokeTransparency = 0.15
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 24
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.ZIndex = 20
	Title.Parent = Main

	local SearchBox = Instance.new("TextBox")
	SearchBox.Size = UDim2.new(1, -30, 0, 34)
	SearchBox.Position = UDim2.new(0, 15, 0, 54)
	SearchBox.BackgroundColor3 = Color3.fromRGB(20, 5, 5)
	SearchBox.BackgroundTransparency = 0.2
	SearchBox.Text = ""
	SearchBox.PlaceholderText = "🔎 Rechercher un onglet / une option..."
	SearchBox.PlaceholderColor3 = Color3.fromRGB(190, 170, 170)
	SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	SearchBox.Font = Enum.Font.Gotham
	SearchBox.TextSize = 13
	SearchBox.ClearTextOnFocus = false
	SearchBox.ZIndex = 20
	SearchBox.Parent = Main
	Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 6)

	local Sidebar = Instance.new("Frame")
	Sidebar.Size = UDim2.new(0, 185, 1, -110)
	Sidebar.Position = UDim2.new(0, 15, 0, 100)
	Sidebar.BackgroundColor3 = Color3.fromRGB(10, 3, 3)
	Sidebar.BackgroundTransparency = 0.2
	Sidebar.BorderSizePixel = 0
	Sidebar.ZIndex = 10
	Sidebar.Parent = Main
	Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

	local SidebarLayout = Instance.new("UIListLayout")
	SidebarLayout.Padding = UDim.new(0, 7)
	SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
	SidebarLayout.Parent = Sidebar
	local SidebarPadding = Instance.new("UIPadding")
	SidebarPadding.PaddingTop = UDim.new(0, 10)
	SidebarPadding.PaddingLeft = UDim.new(0, 8)
	SidebarPadding.PaddingRight = UDim.new(0, 8)
	SidebarPadding.Parent = Sidebar

	local Content = Instance.new("Frame")
	Content.Size = UDim2.new(1, -220, 1, -110)
	Content.Position = UDim2.new(0, 205, 0, 100)
	Content.BackgroundColor3 = Color3.fromRGB(10, 3, 3)
	Content.BackgroundTransparency = 0.25
	Content.BorderSizePixel = 0
	Content.ZIndex = 10
	Content.Parent = Main
	Instance.new("UICorner", Content).CornerRadius = UDim.new(0, 8)

	local ContentTitle = Instance.new("TextLabel")
	ContentTitle.Size = UDim2.new(1, -24, 0, 40)
	ContentTitle.Position = UDim2.new(0, 12, 0, 10)
	ContentTitle.BackgroundTransparency = 1
	ContentTitle.Text = "ACCUEIL"
	ContentTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	ContentTitle.TextStrokeTransparency = 0.2
	ContentTitle.Font = Enum.Font.GothamBold
	ContentTitle.TextSize = 20
	ContentTitle.TextXAlignment = Enum.TextXAlignment.Left
	ContentTitle.ZIndex = 30
	ContentTitle.Parent = Content

	local Description = Instance.new("TextLabel")
	Description.Size = UDim2.new(1, -24, 0, 82)
	Description.Position = UDim2.new(0, 12, 0, 55)
	Description.BackgroundTransparency = 1
	Description.Text = "Bonjour, nous sommes YM TOOL ! Un tool universel pour chaque jeu et utilisation.\nNous ne sommes pas responsable de vos bannissement et nous respectons les mentions de ScriptBlox."
	Description.TextColor3 = Color3.fromRGB(235, 220, 220)
	Description.Font = Enum.Font.Gotham
	Description.TextSize = 14
	Description.TextWrapped = true
	Description.TextXAlignment = Enum.TextXAlignment.Left
	Description.TextYAlignment = Enum.TextYAlignment.Top
	Description.ZIndex = 30
	Description.Parent = Content

	local ScriptBloxCounter = Instance.new("TextLabel")
	ScriptBloxCounter.Size = UDim2.new(1, -24, 0, 26)
	ScriptBloxCounter.Position = UDim2.new(0, 12, 0, 145)
	ScriptBloxCounter.BackgroundTransparency = 1
	ScriptBloxCounter.Text = "ScriptBlox • chargement..."
	ScriptBloxCounter.TextColor3 = Color3.fromRGB(180, 180, 180)
	ScriptBloxCounter.Font = Enum.Font.GothamBold
	ScriptBloxCounter.TextSize = 12
	ScriptBloxCounter.TextXAlignment = Enum.TextXAlignment.Left
	ScriptBloxCounter.ZIndex = 30
	ScriptBloxCounter.Parent = Content

	local DiscHome = Instance.new("TextButton")
	DiscHome.Size = UDim2.new(1, -24, 0, 34)
	DiscHome.Position = UDim2.new(0, 12, 0, 185)
	DiscHome.BackgroundColor3 = Color3.fromRGB(60, 20, 100)
	DiscHome.Text = "Discord : discord.gg/cKPHdt99WG"
	DiscHome.TextColor3 = Color3.fromRGB(220, 200, 255)
	DiscHome.Font = Enum.Font.GothamBold
	DiscHome.TextSize = 13
	DiscHome.ZIndex = 30
	DiscHome.Parent = Content
	Instance.new("UICorner", DiscHome).CornerRadius = UDim.new(0, 6)
	DiscHome.MouseButton1Click:Connect(function()
		if setclipboard then
			setclipboard("https://discord.gg/cKPHdt99WG")
			DiscHome.Text = "✅ Lien copié !"
			task.wait(1.5)
			DiscHome.Text = "Discord : discord.gg/cKPHdt99WG"
		end
	end)

	local HttpService = game:GetService("HttpService")
	local function refreshScriptBloxCounter()
		local ok, result = pcall(function()
			return game:HttpGet("https://scriptblox.com/api/script/search?q=YM%20TOOL&max=20")
		end)
		if not ok then ScriptBloxCounter.Text = "ScriptBlox • indisponible" return end
		local decodedOk, data = pcall(function() return HttpService:JSONDecode(result) end)
		if not decodedOk or not data or not data.result or not data.result.scripts then
			ScriptBloxCounter.Text = "ScriptBlox • données indisponibles"
			return
		end
		for _, scriptData in ipairs(data.result.scripts) do
			if string.lower(scriptData.title or "") == "ym tool" then
				local views = tonumber(scriptData.views) or 0
				ScriptBloxCounter.Text = string.format("Powered by ScriptBlox.com • %s vues", tostring(views):reverse():gsub("(%d%d%d)", "%1 "):reverse():gsub("^ ", ""))
				return
			end
		end
		ScriptBloxCounter.Text = "Powered by ScriptBlox.com • YM TOOL introuvable"
	end
	task.spawn(function()
		while ScreenGui.Parent do
			refreshScriptBloxCounter()
			task.wait(60)
		end
	end)

	local PageHolder = Instance.new("Frame")
	PageHolder.Size = UDim2.new(1, -16, 1, -62)
	PageHolder.Position = UDim2.new(0, 8, 0, 52)
	PageHolder.BackgroundTransparency = 1
	PageHolder.ZIndex = 20
	PageHolder.Parent = Content

	local categories = {"ACCUEIL", "VALEURS MODIFIABLE", "FUN", "PVP", "RAGEBAIT", "ONLY YOUR EYES", "BOUTONS"}
	local pages = {}
	local categoryButtons = {}
	local activePage = nil
	local searchTargets = {}

	local function makePage(name)
		local page = Instance.new("ScrollingFrame")
		page.Name = "Page_" .. name:gsub("%W", "_")
		page.Size = UDim2.fromScale(1, 1)
		page.BackgroundTransparency = 1
		page.BorderSizePixel = 0
		page.ScrollBarThickness = 5
		page.ScrollBarImageColor3 = Color3.fromRGB(180, 0, 0)
		page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		page.Visible = false
		page.ZIndex = 25
		page.Parent = PageHolder
		local pad = Instance.new("UIPadding")
		pad.PaddingTop = UDim.new(0, 4)
		pad.PaddingBottom = UDim.new(0, 10)
		pad.PaddingLeft = UDim.new(0, 4)
		pad.PaddingRight = UDim.new(0, 4)
		pad.Parent = page
		local list = Instance.new("UIListLayout")
		list.Padding = UDim.new(0, 5)
		list.SortOrder = Enum.SortOrder.LayoutOrder
		list.Parent = page
		pages[name] = page
		return page
	end

	for _, name in ipairs(categories) do makePage(name) end

	local function showCategory(name)
		for n, page in pairs(pages) do page.Visible = (n == name) end
		for n, btn in pairs(categoryButtons) do
			btn.BackgroundTransparency = (n == name) and 0.02 or 0.15
		end
		ContentTitle.Text = name
		Description.Visible = (name == "ACCUEIL")
		ScriptBloxCounter.Visible = (name == "ACCUEIL")
		DiscHome.Visible = (name == "ACCUEIL")
	end

	for _, name in ipairs(categories) do
		local Button = Instance.new("TextButton")
		Button.Size = UDim2.new(1, -16, 0, 42)
		Button.BackgroundColor3 = Color3.fromRGB(25, 7, 7)
		Button.BackgroundTransparency = 0.15
		Button.Text = name
		Button.TextColor3 = Color3.fromRGB(245, 225, 225)
		Button.TextStrokeTransparency = 0.15
		Button.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		Button.Font = Enum.Font.GothamBold
		Button.TextSize = 12
		Button.AutoButtonColor = true
		Button.ZIndex = 30
		Button.Parent = Sidebar
		Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)
		categoryButtons[name] = Button
		Button.Activated:Connect(function() showCategory(name) end)
	end

	local dragging = false
	local dragStart
	local startPosition
	Title.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPosition = Main.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			Main.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
		end
	end)

	-- Fenêtre DEBUG séparée (créée après ScreenGui/Main pour garantir son affichage)
	DebugFrame = Instance.new("Frame")
	DebugFrame.Name = "YM_DEBUG"
	DebugFrame.Size = UDim2.fromOffset(300, 360)
	DebugFrame.AnchorPoint = Vector2.new(0, 0.5)
	DebugFrame.Position = UDim2.new(0.5, 165, 0.5, 0)
	DebugFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
	DebugFrame.Visible = false
	DebugFrame.Active = true
	DebugFrame.Draggable = true
	DebugFrame.Parent = ScreenGui
	Instance.new("UICorner", DebugFrame).CornerRadius = UDim.new(0, 10)
	local debugStroke = Instance.new("UIStroke")
	debugStroke.Color = Color3.fromRGB(160, 0, 0)
	debugStroke.Parent = DebugFrame

	local DebugTitle = Instance.new("TextLabel")
	DebugTitle.Size = UDim2.new(1, -40, 0, 40)
	DebugTitle.BackgroundColor3 = Color3.fromRGB(18, 0, 0)
	DebugTitle.Text = "YM TOOL  |  DEBUG"
	DebugTitle.TextColor3 = Color3.fromRGB(220, 20, 20)
	DebugTitle.Font = Enum.Font.GothamBlack
	DebugTitle.TextSize = 16
	DebugTitle.Parent = DebugFrame
	Instance.new("UICorner", DebugTitle).CornerRadius = UDim.new(0, 10)

	local DebugClose = Instance.new("TextButton")
	DebugClose.Size = UDim2.fromOffset(40, 40)
	DebugClose.Position = UDim2.new(1, -38, 0, 0)
	DebugClose.BackgroundColor3 = Color3.fromRGB(140, 0, 0)
	DebugClose.Text = "X"
	DebugClose.TextColor3 = Color3.fromRGB(255,255,255)
	DebugClose.Font = Enum.Font.GothamBlack
	DebugClose.TextSize = 17
	DebugClose.Parent = DebugFrame
	Instance.new("UICorner", DebugClose).CornerRadius = UDim.new(0, 10)
	DebugClose.Activated:Connect(function()
		DebugFrame.Visible = false
		debugVisible = false
	end)
	DebugFrame.Visible = false
	DebugFrame.ZIndex = 100

	local DebugStatus = Instance.new("TextLabel")
	DebugStatus.Size = UDim2.new(1, -20, 0, 22)
	DebugStatus.Position = UDim2.fromOffset(10, 42)
	DebugStatus.BackgroundTransparency = 1
	DebugStatus.Text = "● LIVE DEBUG"
	DebugStatus.TextColor3 = Color3.fromRGB(0, 255, 100)
	DebugStatus.Font = Enum.Font.GothamBold
	DebugStatus.TextSize = 12
	DebugStatus.TextXAlignment = Enum.TextXAlignment.Left
	DebugStatus.Parent = DebugFrame

	local DebugLabel = Instance.new("TextLabel")
	DebugLabel.Size = UDim2.new(1, -20, 1, -60)
	DebugLabel.Position = UDim2.fromOffset(10, 54)
	DebugLabel.BackgroundTransparency = 1
	DebugLabel.TextColor3 = Color3.fromRGB(220,220,220)
	DebugLabel.Font = Enum.Font.Code
	DebugLabel.TextSize = 13
	DebugLabel.TextXAlignment = Enum.TextXAlignment.Left
	DebugLabel.TextYAlignment = Enum.TextYAlignment.Top
	DebugLabel.TextWrapped = false
	DebugLabel.Text = "FPS          : ...\nPing         : ...\nPosition     : ...\nVelocity     : ...\nHumanoid     : ...\nCamera FOV   : ...\nServer       : ...\nClient       : LocalScript"
	DebugLabel.Parent = DebugFrame

	-- Tous les éléments DEBUG restent au-dessus de la fenêtre
	DebugTitle.ZIndex = 101
	DebugClose.ZIndex = 102
	DebugStatus.ZIndex = 101
	DebugLabel.ZIndex = 101

	task.spawn(function()
		local last = tick()
		local frames = 0
		local shownFPS = 0
		while DebugFrame.Parent do
			RunService.RenderStepped:Wait()
			frames += 1
			local now = tick()
			if now - last >= 0.5 then
				shownFPS = math.floor(frames / (now-last) + 0.5)
				frames = 0
				last = now
			end
			if debugVisible then
				local currentCamera = workspace.CurrentCamera
				local root = getRoot()
				local hum = getHumanoid()
				local pos = root and root.Position or Vector3.zero
				local vel = root and root.AssemblyLinearVelocity or Vector3.zero
				local state = hum and hum:GetState().Name or "N/A"
				local ping = "N/A"
				pcall(function()
					local stats = game:GetService("Stats")
					local network = stats:FindFirstChild("Network")
					local serverStats = network and network:FindFirstChild("ServerStatsItem")
					local item = serverStats and serverStats:FindFirstChild("Data Ping")
					if item then ping = tostring(math.floor(item:GetValue())) .. " ms" end
				end)
				DebugLabel.Text = string.format(
					"FPS          : %d\nPing         : %s\nPosition     : %.1f, %.1f, %.1f\nVelocity     : %.1f, %.1f, %.1f\nHumanoid     : %s\nCamera FOV   : %.1f\nServer       : %s\nClient       : %s",
					shownFPS, ping,
					pos.X, pos.Y, pos.Z,
					vel.X, vel.Y, vel.Z,
					state,
					currentCamera and currentCamera.FieldOfView or 0,
					game.JobId ~= "" and game.JobId or "N/A",
					"LocalScript"
				)
			end
		end
	end)


		local function buildDirectButtonUI()
local Title = Instance.new("TextLabel")
	Title.Size = UDim2.new(1, 0, 0, 48)
	Title.BackgroundColor3 = Color3.fromRGB(18, 0, 0)
	Title.Text = "YM TOOL  |  P pour cacher"
	Title.TextColor3 = Color3.fromRGB(220, 20, 20)
	Title.Font = Enum.Font.GothamBlack
	Title.TextSize = 20
	Title.Parent = Main
	Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)

	-- Recherche rapide + compteur ScriptBlox
		local function setActivePage(name)
		activePage = pages[name]
		return activePage
	end

	setActivePage("FUN")
	local function createToggle(text, callback)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, -10, 0, 34)
		btn.BackgroundColor3 = Color3.fromRGB(20, 5, 5)
		btn.Text = text .. " | OFF"
		btn.TextColor3 = Color3.fromRGB(255, 55, 55)
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 13
		btn.TextTransparency = 0
		btn.TextStrokeTransparency = 0
		btn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		btn.TextXAlignment = Enum.TextXAlignment.Center
		btn.TextYAlignment = Enum.TextYAlignment.Center
		btn.BackgroundTransparency = 0.58
		btn.BorderSizePixel = 0
		btn.AutoButtonColor = false
		btn.ZIndex = 20
		btn.Parent = activePage
		table.insert(searchTargets, {button = btn, text = text})
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(90, 0, 0)
		stroke.Parent = btn
		local on = false
		btn.MouseButton1Click:Connect(function()
			on = not on
			if on then
				btn.Text = text .. " | ON"
				btn.TextColor3 = Color3.fromRGB(90, 255, 120)
				btn.BackgroundColor3 = Color3.fromRGB(10, 35, 15)
				stroke.Color = Color3.fromRGB(0, 120, 40)
			else
				btn.Text = text .. " | OFF"
				btn.TextColor3 = Color3.fromRGB(255, 55, 55)
				btn.BackgroundColor3 = Color3.fromRGB(20, 5, 5)
				stroke.Color = Color3.fromRGB(90, 0, 0)
			end
			callback(on)
		end)
	end

		setActivePage("FUN")
	createToggle("Fly", function(s) if s then startFly() else stopFly() end end)
	createToggle("Invincible", function(s) godmode = s end)
	createToggle("Invisible", function(s) invisible = s setInvisible(s) end)
	createToggle("Noclip", function(s) noclip = s end)
	createToggle("Crosshair RGB", function(s) crosshairEnabled = s CrosshairDot.Visible = s end)
	createToggle("Skin RGB", function(s) rgb = s if s then startRGB() else stopRGB() end end)
	createToggle("Click TP", function(s) clickTP = s if s then startClickTP() else stopClickTP() end end)
	createToggle("Pseudo Glitch", function(s) nameGlitch = s if s then startNameGlitch() else stopNameGlitch() end end)
	createToggle("Infinite Jump", function(s) infiniteJump = s if s then startInfiniteJump() else stopInfiniteJump() end end)
	createToggle("No Fall Damage", function(s) noFallDamage = s if s then startNoFallDamage() else stopNoFallDamage() end end)
	createToggle("Anti-AFK", function(s) antiAFK = s if s then startAntiAFK() else stopAntiAFK() end end)
	createToggle("Ragdoll", function(s) ragdoll = s if s then startRagdoll() else stopRagdoll() end end)
	createToggle("Force x1000", function(s)
		superForce = s
		local char = getChar()
		if char then setupSuperForce(char) end
	end)

	setActivePage("PVP")
	createToggle("Aimbot", function(s) aimbot = s end)
	createToggle("AIMSCOPE", function(s) aimScope = s end)
	createToggle("FOV Circle", function(s) fovEnabled = s FOVCircle.Visible = s end)
	createToggle("ESP Rouge", function(s) esp = s updateESP() end)
	createToggle("ESP Box RGB + Ligne + Vie", function(s) boxESP=s if s then startBoxESP() else stopBoxESP() end end)
	createToggle("ESP Squelette", function(s) skeletonESP = s if s then startSkeletonESP() else stopSkeletonESP() end end)
	createToggle("Team Check", function(s)
		teamCheckEnabled = s
		if s then
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr ~= player and isTeammate(plr) then
					removeVisibilityESP(plr)
				end
			end
		end
	end)
	createToggle("Visibility Check", function(s)
		visibilityCheckEnabled = s
		for _, obj in pairs(VisibilityESP) do
			if obj.highlight then obj.highlight.Enabled = s end
		end
		if s then updateVisibilityESP() end
	end)
	createToggle("Autoclick", function(s) autoClick = s if s then startAutoClick() else stopAutoClick() end end)

	setActivePage("RAGEBAIT")
	createToggle("Toupie", function(s) spinning = s if s then startSpin() else stopSpin() end end)
	createToggle("Toupie 90°", function(s) spinning90 = s if s then startSpin90() else stopSpin90() end end)
	createToggle("Fake Lag TP", function(s) fakeLagTP = s if s then startFakeLagTP() else stopFakeLagTP() end end)
	createToggle("Fake Lag Angles", function(s) fakeLagAngles = s if s then startFakeLagAngles() else stopFakeLagAngles() end end)
	createToggle("Glue", function(s) glue = s if s then startGlue() else stopGlue() end end)

	setActivePage("ONLY YOUR EYES")
	createToggle("Big Head", function(s) bigHeadEnabled = s updateCharacterVisuals() end)
	createToggle("Tiny Character", function(s) tinyCharacterEnabled = s updateCharacterVisuals() end)
	createToggle("Headless Effect", function(s) headlessEnabled = s updateCharacterVisuals() end)
	createToggle("Bring All", function(s) bringAll = s if s then startBringAll() else stopBringAll() end end)
	createToggle("Kill Aura", function(s) killAura = s if s then startKillAura() else stopKillAura() end end)
	createToggle("Move Objects", function(s) moveObjects = s if s then startMoveObjects() else stopMoveObjects() end end)

	local function createBigBtn(text, color, callback)
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(1, -10, 0, 34)
		b.BackgroundColor3 = color
		b.Text = text
		b.TextColor3 = Color3.fromRGB(255, 55, 55)
		b.Font = Enum.Font.GothamBold
		b.TextSize = 13
		b.TextTransparency = 0
		b.TextStrokeTransparency = 0
		b.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		b.TextXAlignment = Enum.TextXAlignment.Center
		b.TextYAlignment = Enum.TextYAlignment.Center
		b.BackgroundTransparency = 0.58
		b.BorderSizePixel = 0
		b.AutoButtonColor = false
		b.ZIndex = 20
		b.Parent = activePage
		table.insert(searchTargets, {button = b, text = text})
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
		b.MouseButton1Click:Connect(callback)
	end

	-- Fenêtres Liste / TP / Spectate
	ListFrame = Instance.new("Frame")
	ListFrame.Size = UDim2.new(0, 300, 0, 380)
	ListFrame.Position = UDim2.new(0.5, -460, 0.2, 0)
	ListFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
	ListFrame.Visible = false
	ListFrame.Active = true
	ListFrame.Draggable = true
	ListFrame.Parent = ScreenGui
	Instance.new("UICorner", ListFrame).CornerRadius = UDim.new(0, 10)
	Instance.new("UIStroke", ListFrame).Color = Color3.fromRGB(160, 0, 0)

	local ListTitle = Instance.new("TextLabel")
	ListTitle.Size = UDim2.new(1, -40, 0, 40)
	ListTitle.BackgroundColor3 = Color3.fromRGB(18, 0, 0)
	ListTitle.Text = "YM TOOL  |  JOUEURS"
	ListTitle.TextColor3 = Color3.fromRGB(220, 20, 20)
	ListTitle.Font = Enum.Font.GothamBlack
	ListTitle.TextSize = 15
	ListTitle.Parent = ListFrame
	Instance.new("UICorner", ListTitle).CornerRadius = UDim.new(0, 10)

	local CloseList = Instance.new("TextButton")
	CloseList.Size = UDim2.new(0, 40, 0, 40)
	CloseList.Position = UDim2.new(1, -40, 0, 0)
	CloseList.BackgroundColor3 = Color3.fromRGB(140, 0, 0)
	CloseList.Text = "X"
	CloseList.TextColor3 = Color3.fromRGB(255, 255, 255)
	CloseList.Font = Enum.Font.GothamBlack
	CloseList.TextSize = 18
	CloseList.Parent = ListFrame
	Instance.new("UICorner", CloseList).CornerRadius = UDim.new(0, 10)
	CloseList.Activated:Connect(function() ListFrame.Visible = false end)

	local RefreshList = Instance.new("TextButton")
	RefreshList.Size = UDim2.new(0.9, 0, 0, 28)
	RefreshList.Position = UDim2.new(0.05, 0, 0, 48)
	RefreshList.BackgroundColor3 = Color3.fromRGB(90, 0, 0)
	RefreshList.Text = "🔄 Actualiser"
	RefreshList.TextColor3 = Color3.fromRGB(255, 220, 220)
	RefreshList.Font = Enum.Font.GothamBold
	RefreshList.TextSize = 13
	RefreshList.Parent = ListFrame
	Instance.new("UICorner", RefreshList).CornerRadius = UDim.new(0, 5)

	local ListScroll = Instance.new("ScrollingFrame")
	ListScroll.Size = UDim2.new(0.9, 0, 0, 290)
	ListScroll.Position = UDim2.new(0.05, 0, 0, 85)
	ListScroll.BackgroundColor3 = Color3.fromRGB(15, 5, 5)
	ListScroll.ScrollBarThickness = 5
	ListScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	ListScroll.Parent = ListFrame
	Instance.new("UICorner", ListScroll).CornerRadius = UDim.new(0, 6)
	Instance.new("UIListLayout", ListScroll).Padding = UDim.new(0, 5)

	local function refreshPlayerList()
		for _, c in pairs(ListScroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
		for _, plr in ipairs(Players:GetPlayers()) do
			local row = Instance.new("Frame")
			row.Size = UDim2.new(1, -8, 0, 48)
			row.BackgroundColor3 = Color3.fromRGB(25, 8, 8)
			row.Parent = ListScroll
			Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)
			local nameL = Instance.new("TextLabel")
			nameL.Size = UDim2.new(1, -10, 0, 22)
			nameL.Position = UDim2.new(0, 6, 0, 3)
			nameL.BackgroundTransparency = 1
			nameL.Text = plr.DisplayName .. "  (@" .. plr.Name .. ")"
			nameL.TextColor3 = Color3.fromRGB(255, 200, 200)
			nameL.Font = Enum.Font.GothamBold
			nameL.TextSize = 13
			nameL.TextXAlignment = Enum.TextXAlignment.Left
			nameL.Parent = row
			local infoL = Instance.new("TextLabel")
			infoL.Size = UDim2.new(1, -10, 0, 18)
			infoL.Position = UDim2.new(0, 6, 0, 26)
			infoL.BackgroundTransparency = 1
			infoL.Text = "ID: " .. plr.UserId .. "  |  Âge: " .. plr.AccountAge .. "j"
			infoL.TextColor3 = Color3.fromRGB(180, 120, 120)
			infoL.Font = Enum.Font.Gotham
			infoL.TextSize = 12
			infoL.TextXAlignment = Enum.TextXAlignment.Left
			infoL.Parent = row
		end
	end
	RefreshList.MouseButton1Click:Connect(refreshPlayerList)

	TPFrame = Instance.new("Frame")
	TPFrame.Size = UDim2.new(0, 280, 0, 360)
	TPFrame.Position = UDim2.new(0.5, 170, 0.2, 0)
	TPFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
	TPFrame.Visible = false
	TPFrame.Active = true
	TPFrame.Draggable = true
	TPFrame.Parent = ScreenGui
	Instance.new("UICorner", TPFrame).CornerRadius = UDim.new(0, 10)
	Instance.new("UIStroke", TPFrame).Color = Color3.fromRGB(160, 0, 0)

	local TPTitle = Instance.new("TextLabel")
	TPTitle.Size = UDim2.new(1, -40, 0, 40)
	TPTitle.BackgroundColor3 = Color3.fromRGB(18, 0, 0)
	TPTitle.Text = "YM TOOL  |  TP"
	TPTitle.TextColor3 = Color3.fromRGB(220, 20, 20)
	TPTitle.Font = Enum.Font.GothamBlack
	TPTitle.TextSize = 15
	TPTitle.Parent = TPFrame
	Instance.new("UICorner", TPTitle).CornerRadius = UDim.new(0, 10)

	local CloseTP = Instance.new("TextButton")
	CloseTP.Size = UDim2.new(0, 40, 0, 40)
	CloseTP.Position = UDim2.new(1, -40, 0, 0)
	CloseTP.BackgroundColor3 = Color3.fromRGB(140, 0, 0)
	CloseTP.Text = "X"
	CloseTP.TextColor3 = Color3.fromRGB(255, 255, 255)
	CloseTP.Font = Enum.Font.GothamBlack
	CloseTP.TextSize = 18
	CloseTP.Parent = TPFrame
	Instance.new("UICorner", CloseTP).CornerRadius = UDim.new(0, 10)
	CloseTP.Activated:Connect(function() TPFrame.Visible = false end)

	local RefreshTP = Instance.new("TextButton")
	RefreshTP.Size = UDim2.new(0.9, 0, 0, 28)
	RefreshTP.Position = UDim2.new(0.05, 0, 0, 48)
	RefreshTP.BackgroundColor3 = Color3.fromRGB(90, 0, 0)
	RefreshTP.Text = "🔄 Actualiser"
	RefreshTP.TextColor3 = Color3.fromRGB(255, 220, 220)
	RefreshTP.Font = Enum.Font.GothamBold
	RefreshTP.TextSize = 13
	RefreshTP.Parent = TPFrame
	Instance.new("UICorner", RefreshTP).CornerRadius = UDim.new(0, 5)

	local TPScroll = Instance.new("ScrollingFrame")
	TPScroll.Size = UDim2.new(0.9, 0, 0, 270)
	TPScroll.Position = UDim2.new(0.05, 0, 0, 85)
	TPScroll.BackgroundColor3 = Color3.fromRGB(15, 5, 5)
	TPScroll.ScrollBarThickness = 5
	TPScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	TPScroll.Parent = TPFrame
	Instance.new("UICorner", TPScroll).CornerRadius = UDim.new(0, 6)
	Instance.new("UIListLayout", TPScroll).Padding = UDim.new(0, 4)

	local function refreshTPList()
		for _, c in pairs(TPScroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player then
				local btn = Instance.new("TextButton")
				btn.Size = UDim2.new(1, -8, 0, 32)
				btn.BackgroundColor3 = Color3.fromRGB(30, 8, 8)
				btn.Text = plr.DisplayName .. "  (@" .. plr.Name .. ")"
				btn.TextColor3 = Color3.fromRGB(255, 200, 200)
				btn.Font = Enum.Font.GothamBold
				btn.TextSize = 13
				btn.Parent = TPScroll
				Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
				btn.MouseButton1Click:Connect(function() teleportToPlayer(plr) end)
			end
		end
	end
	RefreshTP.MouseButton1Click:Connect(refreshTPList)

	SpecFrame = Instance.new("Frame")
	SpecFrame.Size = UDim2.new(0, 280, 0, 400)
	SpecFrame.Position = UDim2.new(0.5, 170, 0.18, 0)
	SpecFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
	SpecFrame.Visible = false
	SpecFrame.Active = true
	SpecFrame.Draggable = true
	SpecFrame.Parent = ScreenGui
	Instance.new("UICorner", SpecFrame).CornerRadius = UDim.new(0, 10)
	Instance.new("UIStroke", SpecFrame).Color = Color3.fromRGB(160, 0, 0)

	local SpecTitle = Instance.new("TextLabel")
	SpecTitle.Size = UDim2.new(1, -40, 0, 40)
	SpecTitle.BackgroundColor3 = Color3.fromRGB(18, 0, 0)
	SpecTitle.Text = "YM TOOL  |  SPECTATE"
	SpecTitle.TextColor3 = Color3.fromRGB(220, 20, 20)
	SpecTitle.Font = Enum.Font.GothamBlack
	SpecTitle.TextSize = 15
	SpecTitle.Parent = SpecFrame
	Instance.new("UICorner", SpecTitle).CornerRadius = UDim.new(0, 10)

	local CloseSpec = Instance.new("TextButton")
	CloseSpec.Size = UDim2.new(0, 40, 0, 40)
	CloseSpec.Position = UDim2.new(1, -40, 0, 0)
	CloseSpec.BackgroundColor3 = Color3.fromRGB(140, 0, 0)
	CloseSpec.Text = "X"
	CloseSpec.TextColor3 = Color3.fromRGB(255, 255, 255)
	CloseSpec.Font = Enum.Font.GothamBlack
	CloseSpec.TextSize = 18
	CloseSpec.Parent = SpecFrame
	Instance.new("UICorner", CloseSpec).CornerRadius = UDim.new(0, 10)
	CloseSpec.Activated:Connect(function() SpecFrame.Visible = false end)

	local StopSpecBtn = Instance.new("TextButton")
	StopSpecBtn.Size = UDim2.new(0.9, 0, 0, 32)
	StopSpecBtn.Position = UDim2.new(0.05, 0, 0, 48)
	StopSpecBtn.BackgroundColor3 = Color3.fromRGB(160, 40, 40)
	StopSpecBtn.Text = "⏹ ARRÊTER SPECTATE"
	StopSpecBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	StopSpecBtn.Font = Enum.Font.GothamBold
	StopSpecBtn.TextSize = 13
	StopSpecBtn.Parent = SpecFrame
	Instance.new("UICorner", StopSpecBtn).CornerRadius = UDim.new(0, 6)
	StopSpecBtn.MouseButton1Click:Connect(stopSpectate)

	local RefreshSpec = Instance.new("TextButton")
	RefreshSpec.Size = UDim2.new(0.9, 0, 0, 28)
	RefreshSpec.Position = UDim2.new(0.05, 0, 0, 88)
	RefreshSpec.BackgroundColor3 = Color3.fromRGB(90, 0, 0)
	RefreshSpec.Text = "🔄 Actualiser"
	RefreshSpec.TextColor3 = Color3.fromRGB(255, 220, 220)
	RefreshSpec.Font = Enum.Font.GothamBold
	RefreshSpec.TextSize = 13
	RefreshSpec.Parent = SpecFrame
	Instance.new("UICorner", RefreshSpec).CornerRadius = UDim.new(0, 5)

	local SpecScroll = Instance.new("ScrollingFrame")
	SpecScroll.Size = UDim2.new(0.9, 0, 0, 265)
	SpecScroll.Position = UDim2.new(0.05, 0, 0, 125)
	SpecScroll.BackgroundColor3 = Color3.fromRGB(15, 5, 5)
	SpecScroll.ScrollBarThickness = 5
	SpecScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	SpecScroll.Parent = SpecFrame
	Instance.new("UICorner", SpecScroll).CornerRadius = UDim.new(0, 6)
	Instance.new("UIListLayout", SpecScroll).Padding = UDim.new(0, 4)

	local function refreshSpecList()
		for _, c in pairs(SpecScroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player then
				local btn = Instance.new("TextButton")
				btn.Size = UDim2.new(1, -8, 0, 32)
				btn.BackgroundColor3 = Color3.fromRGB(30, 8, 8)
				btn.Text = plr.DisplayName .. "  (@" .. plr.Name .. ")"
				btn.TextColor3 = Color3.fromRGB(255, 200, 200)
				btn.Font = Enum.Font.GothamBold
				btn.TextSize = 13
				btn.Parent = SpecScroll
				Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
				btn.MouseButton1Click:Connect(function() spectatePlayer(plr) end)
			end
		end
	end
	RefreshSpec.MouseButton1Click:Connect(refreshSpecList)

	
	-- FLING WINDOW : script séparé lancé depuis BOUTONS
	local flingWindowStop = nil

	local function launchFlingWindow()
	-- Services
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local Player = Players.LocalPlayer
	-- GUI Setup
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "YMMultiFlingGUI"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.Parent = game:GetService("CoreGui")
	-- Main Frame
	local MainFrame = Instance.new("Frame")
	MainFrame.Size = UDim2.new(0, 340, 0, 470)
	MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	MainFrame.BackgroundColor3 = Color3.fromRGB(15, 5, 5)
	MainFrame.BorderSizePixel = 0
	MainFrame.Active = true
	MainFrame.Draggable = true
	MainFrame.Parent = ScreenGui
	local MainCorner = Instance.new("UICorner")
	MainCorner.CornerRadius = UDim.new(0, 8)
	MainCorner.Parent = MainFrame

	local FlingScale = Instance.new("UIScale")
	FlingScale.Name = "MobileScale"
	FlingScale.Scale = 1
	FlingScale.Parent = MainFrame

	local function updateFlingScale()
		local camera = workspace.CurrentCamera
		if not camera then return end
		local viewport = camera.ViewportSize
		if UserInputService.TouchEnabled then
			FlingScale.Scale = math.clamp(math.min(viewport.X / 340, viewport.Y / 470), 0.72, 0.95)
		else
			FlingScale.Scale = 1
		end
	end
	updateFlingScale()
	if workspace.CurrentCamera then
		workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateFlingScale)
	end
	local MainStroke = Instance.new("UIStroke")
	MainStroke.Color = Color3.fromRGB(100, 0, 0)
	MainStroke.Thickness = 1
	MainStroke.Transparency = 0.15
	MainStroke.Parent = MainFrame
	-- Title Bar
	local TitleBar = Instance.new("Frame")
	TitleBar.Size = UDim2.new(1, 0, 0, 30)
	TitleBar.BackgroundColor3 = Color3.fromRGB(18, 0, 0)
	TitleBar.BorderSizePixel = 0
	TitleBar.Parent = MainFrame
	local TitleCorner = Instance.new("UICorner")
	TitleCorner.CornerRadius = UDim.new(0, 6)
	TitleCorner.Parent = TitleBar
	-- Title
	local Title = Instance.new("TextLabel")
	Title.Size = UDim2.new(1, -30, 1, 0)
	Title.BackgroundTransparency = 1
	Title.Text = "YM MULTI-FLING"
	Title.TextColor3 = Color3.fromRGB(255, 70, 70)
	Title.Font = Enum.Font.SourceSansBold
	Title.TextSize = 18
	Title.Parent = TitleBar
	-- Close Button
	local CloseButton = Instance.new("TextButton")
	CloseButton.Position = UDim2.new(1, -30, 0, 0)
	CloseButton.Size = UDim2.new(0, 30, 0, 30)
	CloseButton.BackgroundColor3 = Color3.fromRGB(140, 0, 0)
	CloseButton.BorderSizePixel = 0
	CloseButton.Text = "X"
	CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	CloseButton.Font = Enum.Font.SourceSansBold
	CloseButton.TextSize = 18
	CloseButton.Parent = TitleBar
	local CloseButtonCorner = Instance.new("UICorner")
	CloseButtonCorner.CornerRadius = UDim.new(0, 4)
	CloseButtonCorner.Parent = CloseButton
	-- Status Label
	local StatusLabel = Instance.new("TextLabel")
	StatusLabel.Position = UDim2.new(0, 10, 0, 40)
	StatusLabel.Size = UDim2.new(1, -20, 0, 25)
	StatusLabel.BackgroundTransparency = 1
	StatusLabel.Text = "Select targets to fling"
	StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	StatusLabel.Font = Enum.Font.SourceSans
	StatusLabel.TextSize = 16
	StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
	StatusLabel.Parent = MainFrame
	-- Player Selection Frame
	local SelectionFrame = Instance.new("Frame")
	SelectionFrame.Position = UDim2.new(0, 10, 0, 72)
	SelectionFrame.Size = UDim2.new(1, -20, 0, 270)
	SelectionFrame.BackgroundColor3 = Color3.fromRGB(10, 3, 3)
	SelectionFrame.BorderSizePixel = 0
	SelectionFrame.Parent = MainFrame
	local SelectionCorner = Instance.new("UICorner")
	SelectionCorner.CornerRadius = UDim.new(0, 4)
	SelectionCorner.Parent = SelectionFrame
	local SelectionStroke = Instance.new("UIStroke")
	SelectionStroke.Color = Color3.fromRGB(70, 0, 0)
	SelectionStroke.Thickness = 1
	SelectionStroke.Transparency = 0.25
	SelectionStroke.Parent = SelectionFrame
	-- Player List ScrollFrame
	local PlayerScrollFrame = Instance.new("ScrollingFrame")
	PlayerScrollFrame.Position = UDim2.new(0, 5, 0, 5)
	PlayerScrollFrame.Size = UDim2.new(1, -10, 1, -10)
	PlayerScrollFrame.BackgroundTransparency = 1
	PlayerScrollFrame.BorderSizePixel = 0
	PlayerScrollFrame.ScrollBarThickness = 6
	PlayerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	PlayerScrollFrame.Parent = SelectionFrame
	-- Start Fling Button
	local StartButton = Instance.new("TextButton")
	StartButton.Position = UDim2.new(0, 10, 0, 352)
	StartButton.Size = UDim2.new(0.5, -15, 0, 46)
	StartButton.BackgroundColor3 = Color3.fromRGB(25, 7, 7)
	StartButton.BorderSizePixel = 0
	StartButton.Text = "START FLING"
	StartButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	StartButton.Font = Enum.Font.SourceSansBold
	StartButton.TextSize = 16
	StartButton.Parent = MainFrame
	local StartButtonCorner = Instance.new("UICorner")
	StartButtonCorner.CornerRadius = UDim.new(0, 4)
	StartButtonCorner.Parent = StartButton
	-- Stop Fling Button
	local StopButton = Instance.new("TextButton")
	StopButton.Position = UDim2.new(0.5, 5, 0, 352)
	StopButton.Size = UDim2.new(0.5, -15, 0, 46)
	StopButton.BackgroundColor3 = Color3.fromRGB(110, 0, 0)
	StopButton.BorderSizePixel = 0
	StopButton.Text = "STOP FLING"
	StopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	StopButton.Font = Enum.Font.SourceSansBold
	StopButton.TextSize = 16
	StopButton.Parent = MainFrame
	local StopButtonCorner = Instance.new("UICorner")
	StopButtonCorner.CornerRadius = UDim.new(0, 4)
	StopButtonCorner.Parent = StopButton
	-- Select/Deselect Buttons
	local SelectAllButton = Instance.new("TextButton")
	SelectAllButton.Position = UDim2.new(0, 10, 0, 408)
	SelectAllButton.Size = UDim2.new(0.5, -15, 0, 40)
	SelectAllButton.BackgroundColor3 = Color3.fromRGB(25, 7, 7)
	SelectAllButton.BorderSizePixel = 0
	SelectAllButton.Text = "SELECT ALL"
	SelectAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	SelectAllButton.Font = Enum.Font.SourceSans
	SelectAllButton.TextSize = 13
	SelectAllButton.Parent = MainFrame
	local SelectAllButtonCorner = Instance.new("UICorner")
	SelectAllButtonCorner.CornerRadius = UDim.new(0, 4)
	SelectAllButtonCorner.Parent = SelectAllButton
	local DeselectAllButton = Instance.new("TextButton")
	DeselectAllButton.Position = UDim2.new(0.5, 5, 0, 408)
	DeselectAllButton.Size = UDim2.new(0.5, -15, 0, 40)
	DeselectAllButton.BackgroundColor3 = Color3.fromRGB(25, 7, 7)
	DeselectAllButton.BorderSizePixel = 0
	DeselectAllButton.Text = "DESELECT ALL"
	DeselectAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	DeselectAllButton.Font = Enum.Font.SourceSans
	DeselectAllButton.TextSize = 13
	DeselectAllButton.Parent = MainFrame

	for _, button in ipairs({CloseButton, StartButton, StopButton, SelectAllButton, DeselectAllButton}) do
		button.AutoButtonColor = false
		button.MouseEnter:Connect(function()
			button.BackgroundTransparency = 0.12
		end)
		button.MouseLeave:Connect(function()
			button.BackgroundTransparency = 0
		end)
	end
	local DeselectAllButtonCorner = Instance.new("UICorner")
	DeselectAllButtonCorner.CornerRadius = UDim.new(0, 4)
	DeselectAllButtonCorner.Parent = DeselectAllButton
	-- Variables
	local SelectedTargets = {}
	local PlayerCheckboxes = {}
	local FlingActive = false
	local FlingConnection = nil
	getgenv().OldPos = nil
	getgenv().FPDH = workspace.FallenPartsDestroyHeight
	-- Function to update player list
	local function RefreshPlayerList()
	    -- Clear existing player entries
	    for _, child in pairs(PlayerScrollFrame:GetChildren()) do
	        child:Destroy()
	    end
	    PlayerCheckboxes = {}
	    
	    -- Get players and sort them
	    local PlayerList = Players:GetPlayers()
	    table.sort(PlayerList, function(a, b) return a.Name:lower() < b.Name:lower() end)
	    
	    -- Create entries for each player
	    local yPosition = 5
	    for _, player in ipairs(PlayerList) do
	        if player ~= Player then -- Don't include yourself
	            -- Create player entry frame
	            local PlayerEntry = Instance.new("Frame")
	            PlayerEntry.Size = UDim2.new(1, -10, 0, 30)
	            PlayerEntry.Position = UDim2.new(0, 5, 0, yPosition)
	            PlayerEntry.BackgroundColor3 = Color3.fromRGB(20, 5, 5)
	            PlayerEntry.BorderSizePixel = 0
	            PlayerEntry.Parent = PlayerScrollFrame
	            
	            -- Create checkbox
	            local Checkbox = Instance.new("TextButton")
	            Checkbox.Size = UDim2.new(0, 24, 0, 24)
	            Checkbox.Position = UDim2.new(0, 3, 0.5, -12)
	            Checkbox.BackgroundColor3 = Color3.fromRGB(25, 8, 8)
	            Checkbox.BorderSizePixel = 0
	            Checkbox.Text = ""
	            Checkbox.Parent = PlayerEntry
	            
	            -- Checkmark (initially invisible)
	            local Checkmark = Instance.new("TextLabel")
	            Checkmark.Size = UDim2.new(1, 0, 1, 0)
	            Checkmark.BackgroundTransparency = 1
	            Checkmark.Text = "✓"
	            Checkmark.TextColor3 = Color3.fromRGB(0, 255, 0)
	            Checkmark.TextSize = 18
	            Checkmark.Font = Enum.Font.SourceSansBold
	            Checkmark.Visible = SelectedTargets[player.Name] ~= nil
	            Checkmark.Parent = Checkbox
	            
	            -- Player name label
	            local NameLabel = Instance.new("TextLabel")
	            NameLabel.Size = UDim2.new(1, -35, 1, 0)
	            NameLabel.Position = UDim2.new(0, 30, 0, 0)
	            NameLabel.BackgroundTransparency = 1
	            NameLabel.Text = player.Name
	            NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	            NameLabel.TextSize = 16
	            NameLabel.Font = Enum.Font.SourceSans
	            NameLabel.TextXAlignment = Enum.TextXAlignment.Left
	            NameLabel.Parent = PlayerEntry
	            
	            -- Make entire entry clickable
	            local ClickArea = Instance.new("TextButton")
	            ClickArea.Size = UDim2.new(1, 0, 1, 0)
	            ClickArea.BackgroundTransparency = 1
	            ClickArea.Text = ""
	            ClickArea.ZIndex = 2
	            ClickArea.Parent = PlayerEntry
	            
	            -- Selection toggle on click
	            ClickArea.MouseButton1Click:Connect(function()
	                if SelectedTargets[player.Name] then
	                    SelectedTargets[player.Name] = nil
	                    Checkmark.Visible = false
	                else
	                    SelectedTargets[player.Name] = player
	                    Checkmark.Visible = true
	                end
	                
	                UpdateStatus()
	            end)
	            
	            -- Store reference to this player's UI
	            PlayerCheckboxes[player.Name] = {
	                Entry = PlayerEntry,
	                Checkmark = Checkmark
	            }
	            
	            yPosition = yPosition + 35
	        end
	    end
	    
	    -- Update scrollframe canvas size
	    PlayerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, yPosition + 5)
	end
	-- Count selected targets
	local function CountSelectedTargets()
	    local count = 0
	    for _ in pairs(SelectedTargets) do
	        count = count + 1
	    end
	    return count
	end
	-- Update status display
	local function UpdateStatus()
	    local count = CountSelectedTargets()
	    if FlingActive then
	        StatusLabel.Text = "Flinging " .. count .. " target(s)"
	        StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
	    else
	        StatusLabel.Text = count .. " target(s) selected" 
	        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	    end
	end
	-- Function to select/deselect all players
	local function ToggleAllPlayers(select)
	    for _, player in ipairs(Players:GetPlayers()) do
	        if player ~= Player then
	            local checkboxData = PlayerCheckboxes[player.Name]
	            if checkboxData then
	                if select then
	                    SelectedTargets[player.Name] = player
	                    checkboxData.Checkmark.Visible = true
	                else
	                    SelectedTargets[player.Name] = nil
	                    checkboxData.Checkmark.Visible = false
	                end
	            end
	        end
	    end
	    
	    UpdateStatus()
	end
	-- Show notification
	local function Message(Title, Text, Time)
	    game:GetService("StarterGui"):SetCore("SendNotification", {
	        Title = Title,
	        Text = Text,
	        Duration = Time or 5
	    })
	end
	-- The fling function from zqyDSUWX
	local function SkidFling(TargetPlayer)
	    local Character = Player.Character
	    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
	    local RootPart = Humanoid and Humanoid.RootPart
	    local TCharacter = TargetPlayer.Character
	    if not TCharacter then return end
	    
	    local THumanoid
	    local TRootPart
	    local THead
	    local Accessory
	    local Handle
	    if TCharacter:FindFirstChildOfClass("Humanoid") then
	        THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
	    end
	    if THumanoid and THumanoid.RootPart then
	        TRootPart = THumanoid.RootPart
	    end
	    if TCharacter:FindFirstChild("Head") then
	        THead = TCharacter.Head
	    end
	    if TCharacter:FindFirstChildOfClass("Accessory") then
	        Accessory = TCharacter:FindFirstChildOfClass("Accessory")
	    end
	    if Accessory and Accessory:FindFirstChild("Handle") then
	        Handle = Accessory.Handle
	    end
	    if Character and Humanoid and RootPart then
	        if RootPart.Velocity.Magnitude < 50 then
	            getgenv().OldPos = RootPart.CFrame
	        end
	        
	        if THumanoid and THumanoid.Sit then
	            return Message("Error", TargetPlayer.Name .. " is sitting", 2)
	        end
	        
	        if THead then
	            workspace.CurrentCamera.CameraSubject = THead
	        elseif Handle then
	            workspace.CurrentCamera.CameraSubject = Handle
	        elseif THumanoid and TRootPart then
	            workspace.CurrentCamera.CameraSubject = THumanoid
	        end
	        
	        if not TCharacter:FindFirstChildWhichIsA("BasePart") then
	            return
	        end
	        
	        local FPos = function(BasePart, Pos, Ang)
	            RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
	            Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
	            RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
	            RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
	        end
	        
	        local SFBasePart = function(BasePart)
	            local TimeToWait = 2
	            local Time = tick()
	            local Angle = 0
	            repeat
	                if RootPart and THumanoid then
	                    if BasePart.Velocity.Magnitude < 50 then
	                        Angle = Angle + 100
	                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
	                        task.wait()
	                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
	                        task.wait()
	                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
	                        task.wait()
	                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
	                        task.wait()
	                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle),0 ,0))
	                        task.wait()
	                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0))
	                        task.wait()
	                    else
	                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
	                        task.wait()
	                        FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
	                        task.wait()
	                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
	                        task.wait()
	                        
	                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
	                        task.wait()
	                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
	                        task.wait()
	                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
	                        task.wait()
	                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
	                        task.wait()
	                    end
	                end
	            until Time + TimeToWait < tick() or not FlingActive
	        end
	        
	        workspace.FallenPartsDestroyHeight = 0/0
	        
	        local BV = Instance.new("BodyVelocity")
	        BV.Parent = RootPart
	        BV.Velocity = Vector3.new(0, 0, 0)
	        BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
	        
	        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
	        
	        if TRootPart then
	            SFBasePart(TRootPart)
	        elseif THead then
	            SFBasePart(THead)
	        elseif Handle then
	            SFBasePart(Handle)
	        else
	            return Message("Error", TargetPlayer.Name .. " has no valid parts", 2)
	        end
	        
	        BV:Destroy()
	        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
	        workspace.CurrentCamera.CameraSubject = Humanoid
	        
	        -- Reset character position
	        if getgenv().OldPos then
	            repeat
	                RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
	                Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
	                Humanoid:ChangeState("GettingUp")
	                for _, part in pairs(Character:GetChildren()) do
	                    if part:IsA("BasePart") then
	                        part.Velocity, part.RotVelocity = Vector3.new(), Vector3.new()
	                    end
	                end
	                task.wait()
	            until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
	            workspace.FallenPartsDestroyHeight = getgenv().FPDH
	        end
	    else
	        return Message("Error", "Your character is not ready", 2)
	    end
	end
	-- Start flinging selected targets
	local function StartFling()
	    if FlingActive then return end
	    
	    local count = CountSelectedTargets()
	    if count == 0 then
	        StatusLabel.Text = "No targets selected!"
	        wait(1)
	        StatusLabel.Text = "Select targets to fling"
	        return
	    end
	    
	    FlingActive = true
	    UpdateStatus()
	    Message("Started", "Flinging " .. count .. " targets", 2)
	    
	    -- Start flinger in separate thread
	    spawn(function()
	        while FlingActive do
	            local validTargets = {}
	            
	            -- Process all targets first to determine which are valid
	            for name, player in pairs(SelectedTargets) do
	                if player and player.Parent then
	                    validTargets[name] = player
	                else
	                    -- Remove players who left
	                    SelectedTargets[name] = nil
	                    local checkbox = PlayerCheckboxes[name]
	                    if checkbox then
	                        checkbox.Checkmark.Visible = false
	                    end
	                end
	            end
	            
	            -- Then attempt to fling each valid target
	            for _, player in pairs(validTargets) do
	                if FlingActive then
	                    SkidFling(player)
	                    -- Brief wait between targets to allow movement to reset
	                    wait(0.1)
	                else
	                    break
	                end
	            end
	            
	            -- Update status periodically
	            UpdateStatus()
	            
	            -- Wait a moment before starting next fling cycle
	            wait(0.5)
	        end
	    end)
	end
	-- Stop flinging
	local function StopFling()
	    if not FlingActive then return end
	    
	    FlingActive = false
	    
	    UpdateStatus()
	    Message("Stopped", "Fling has been stopped", 2)
	end
	-- Set up button connections
	StartButton.Activated:Connect(StartFling)
	StopButton.Activated:Connect(StopFling)
	SelectAllButton.Activated:Connect(function() ToggleAllPlayers(true) end)
	DeselectAllButton.Activated:Connect(function() ToggleAllPlayers(false) end)
	CloseButton.Activated:Connect(function()
	    StopFling()
	    ScreenGui:Destroy()
	end)
	-- Handle player joining/leaving
	Players.PlayerAdded:Connect(RefreshPlayerList)
	Players.PlayerRemoving:Connect(function(player)
	    if SelectedTargets[player.Name] then
	        SelectedTargets[player.Name] = nil
	    end
	    RefreshPlayerList()
	    UpdateStatus()
	end)
	-- Initialize
	RefreshPlayerList()
	UpdateStatus()
	-- Success message
	Message("Loaded", "YM MULTI-FLING loaded!", 3)
		return function()
			pcall(function() StopFling() end)
			pcall(function() ScreenGui:Destroy() end)
		end
	end

	setActivePage("BOUTONS")

	createBigBtn("YM FLING", Color3.fromRGB(110, 0, 0), function()
		if flingWindowStop then
			pcall(flingWindowStop)
			flingWindowStop = nil
		end
		flingWindowStop = launchFlingWindow()
	end)

	createBigBtn("📋 LISTE DES JOUEURS", Color3.fromRGB(90, 0, 0), function()
		ListFrame.Visible = not ListFrame.Visible
		if ListFrame.Visible then refreshPlayerList() end
	end)
	createBigBtn("📍 TP SUR UN JOUEUR", Color3.fromRGB(110, 0, 0), function()
		TPFrame.Visible = not TPFrame.Visible
		if TPFrame.Visible then refreshTPList() end
	end)
	createBigBtn("👁 SPECTATE JOUEUR", Color3.fromRGB(80, 20, 120), function()
		SpecFrame.Visible = not SpecFrame.Visible
		if SpecFrame.Visible then refreshSpecList() end
	end)

	createBigBtn("🛠 DEBUG", Color3.fromRGB(90, 0, 0), function()
		DebugFrame.Visible = not DebugFrame.Visible
		debugVisible = DebugFrame.Visible
	end)

	-- Fenêtre WAYPOINTS ajoutée sans modifier les fenêtres existantes
	WaypointFrame = Instance.new("Frame")
	WaypointFrame.Size = UDim2.new(0, 330, 0, 330)
	WaypointFrame.Position = UDim2.new(0.5, 165, 0.15, 0)
	WaypointFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
	WaypointFrame.Visible = false
	WaypointFrame.Active = true
	WaypointFrame.Draggable = true
	WaypointFrame.Parent = ScreenGui
	Instance.new("UICorner", WaypointFrame).CornerRadius = UDim.new(0, 10)
	Instance.new("UIStroke", WaypointFrame).Color = Color3.fromRGB(160, 0, 0)

	local WaypointTitle = Instance.new("TextLabel")
	WaypointTitle.Size = UDim2.new(1, -40, 0, 40)
	WaypointTitle.BackgroundColor3 = Color3.fromRGB(18, 0, 0)
	WaypointTitle.Text = "YM TOOL  |  WAYPOINTS"
	WaypointTitle.TextColor3 = Color3.fromRGB(220, 20, 20)
	WaypointTitle.Font = Enum.Font.GothamBlack
	WaypointTitle.TextSize = 15
	WaypointTitle.Parent = WaypointFrame
	Instance.new("UICorner", WaypointTitle).CornerRadius = UDim.new(0, 10)

	local WaypointClose = Instance.new("TextButton")
	WaypointClose.Size = UDim2.fromOffset(40, 40)
	WaypointClose.Position = UDim2.new(1, -40, 0, 0)
	WaypointClose.BackgroundColor3 = Color3.fromRGB(140, 0, 0)
	WaypointClose.Text = "X"
	WaypointClose.TextColor3 = Color3.fromRGB(255,255,255)
	WaypointClose.Font = Enum.Font.GothamBlack
	WaypointClose.TextSize = 17
	WaypointClose.Parent = WaypointFrame
	Instance.new("UICorner", WaypointClose).CornerRadius = UDim.new(0, 10)
	WaypointClose.MouseButton1Click:Connect(function() WaypointFrame.Visible = false end)

	for i = 1, 6 do
		local y = 48 + (i - 1) * 44
		local box = Instance.new("TextBox")
		box.Size = UDim2.new(0, 125, 0, 32)
		box.Position = UDim2.new(0, 10, 0, y)
		box.BackgroundColor3 = Color3.fromRGB(25, 8, 8)
		box.Text = waypointSlots[i].name
		box.TextColor3 = Color3.fromRGB(255, 220, 220)
		box.Font = Enum.Font.GothamBold
		box.TextSize = 12
		box.ClearTextOnFocus = false
		box.Parent = WaypointFrame
		Instance.new("UICorner", box).CornerRadius = UDim.new(0, 5)
		box.FocusLost:Connect(function()
			if box.Text ~= "" then waypointSlots[i].name = box.Text end
		end)

		local setBtn = Instance.new("TextButton")
		setBtn.Size = UDim2.new(0, 80, 0, 32)
		setBtn.Position = UDim2.new(0, 142, 0, y)
		setBtn.BackgroundColor3 = Color3.fromRGB(110, 0, 0)
		setBtn.Text = "SET"
		setBtn.TextColor3 = Color3.fromRGB(255,255,255)
		setBtn.Font = Enum.Font.GothamBold
		setBtn.TextSize = 12
		setBtn.Parent = WaypointFrame
		Instance.new("UICorner", setBtn).CornerRadius = UDim.new(0, 5)
		setBtn.MouseButton1Click:Connect(function()
			local root = getRoot()
			if root then waypointSlots[i].cframe = root.CFrame end
		end)

		local tpBtn = Instance.new("TextButton")
		tpBtn.Size = UDim2.new(0, 80, 0, 32)
		tpBtn.Position = UDim2.new(0, 228, 0, y)
		tpBtn.BackgroundColor3 = Color3.fromRGB(70, 40, 100)
		tpBtn.Text = "TP"
		tpBtn.TextColor3 = Color3.fromRGB(255,255,255)
		tpBtn.Font = Enum.Font.GothamBold
		tpBtn.TextSize = 12
		tpBtn.Parent = WaypointFrame
		Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 5)
		tpBtn.MouseButton1Click:Connect(function()
			local root = getRoot()
			if root and waypointSlots[i].cframe then root.CFrame = waypointSlots[i].cframe end
		end)
	end

	createBigBtn("📍 WAYPOINTS", Color3.fromRGB(90, 0, 0), function()
		WaypointFrame.Visible = not WaypointFrame.Visible
	end)

	-- Le curseur reste disponible tant qu'au moins une fenêtre du tool est ouverte.
	local function updateCursorForWindows()
		setCursorForced(
			Main.Visible
			or DebugFrame.Visible
			or ListFrame.Visible
			or TPFrame.Visible
			or SpecFrame.Visible
			or WaypointFrame.Visible
		)
	end

	for _, window in ipairs({Main, DebugFrame, ListFrame, TPFrame, SpecFrame, WaypointFrame}) do
		window:GetPropertyChangedSignal("Visible"):Connect(updateCursorForWindows)
	end
	updateCursorForWindows()

	createBigBtn("👻 CACHER TOUTES LES FENÊTRES", Color3.fromRGB(70, 20, 20), function()
		Main.Visible = false
		DebugFrame.Visible = false
		ListFrame.Visible = false
		TPFrame.Visible = false
		SpecFrame.Visible = false
		WaypointFrame.Visible = false
		guiVisible = false
		debugVisible = false
	end)


		setActivePage("VALEURS MODIFIABLE")

	local function createSpeed(label, default, cb)
		local f = Instance.new("Frame")
		f.Size = UDim2.new(1, -8, 0, 48)
		f.BackgroundTransparency = 1
		f.Parent = activePage
		local l = Instance.new("TextLabel")
		l.Size = UDim2.new(1, 0, 0, 16)
		l.BackgroundTransparency = 1
		l.Text = label
		l.TextColor3 = Color3.fromRGB(200, 160, 160)
		l.Font = Enum.Font.Gotham
		l.TextSize = 12
		l.TextXAlignment = Enum.TextXAlignment.Left
		l.Parent = f
		local box = Instance.new("TextBox")
		box.Size = UDim2.new(0.55, 0, 0, 26)
		box.Position = UDim2.new(0, 0, 0, 18)
		box.BackgroundColor3 = Color3.fromRGB(20, 5, 5)
		box.Text = tostring(default)
		box.TextColor3 = Color3.fromRGB(255, 200, 200)
		box.Font = Enum.Font.GothamBold
		box.TextSize = 13
		box.Parent = f
		Instance.new("UICorner", box).CornerRadius = UDim.new(0, 5)
		local ok = Instance.new("TextButton")
		ok.Size = UDim2.new(0.35, 0, 0, 26)
		ok.Position = UDim2.new(0.6, 0, 0, 18)
		ok.BackgroundColor3 = Color3.fromRGB(140, 0, 0)
		ok.Text = "OK"
		ok.TextColor3 = Color3.fromRGB(255, 255, 255)
		ok.Font = Enum.Font.GothamBold
		ok.TextSize = 12
		ok.Parent = f
		Instance.new("UICorner", ok).CornerRadius = UDim.new(0, 5)
		ok.MouseButton1Click:Connect(function()
			local v = tonumber(box.Text)
			if v then cb(v) end
		end)
	end

	createSpeed("Taille Crosshair", 5, function(v) CrosshairDot.Size = UDim2.fromOffset(math.clamp(math.floor(v), 1, 30), math.clamp(math.floor(v), 1, 30)) end)
	createSpeed("Rayon FOV", 150, function(v) fovRadius = math.clamp(math.floor(v), 20, 600) end)
	createSpeed("Vitesse de marche", 16, setWalkSpeed)
	createSpeed("Vitesse de vol", 50, function(v) flySpeed = v end)
	createSpeed("Vitesse Toupie", 50, function(v) spinSpeed = v end)
	createSpeed("Vitesse Toupie 90°", 5000, function(v) spinSpeed90 = v end)
	createSpeed("Force Power (x1000)", 2800, function(v) forcePower = v end)
	createSpeed("Force de saut", 50, function(v) jumpPower = math.max(0, v) end)
	createSpeed("FPS COUNTER (0 = débride les FPS)", 0, function(v)
		fpsCap = math.max(0, math.floor(v))
		applyFPSCap()
	end)

	UserInputService.InputBegan:Connect(function(i, g)
		if i.UserInputType == Enum.UserInputType.MouseButton2 then
			aiming = true
		end
		if g then return end
		-- Sur mobile, X ferme la fenêtre et le bouton YM la réaffiche.
	end)

	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton2 then
			aiming = false
		end
	end)
	end

	buildDirectButtonUI()

	RunService:BindToRenderStep("YM_Aimbot", Enum.RenderPriority.Camera.Value + 1, function()
		local currentCamera = workspace.CurrentCamera
		if currentCamera then Camera = currentCamera end
		if (aimbot or (aimScope and aiming)) and currentCamera then
			local h = getClosestHead()
			if h then
				local cameraPos = currentCamera.CFrame.Position
				currentCamera.CFrame = CFrame.lookAt(cameraPos, h.Position)
				local root = getRoot()
				local flatTarget = Vector3.new(h.Position.X, root and root.Position.Y or cameraPos.Y, h.Position.Z)
				if root and (flatTarget - root.Position).Magnitude > 0.01 then
					root.CFrame = CFrame.lookAt(root.Position, flatTarget)
				end
			end
		end
	end)

	RunService.RenderStepped:Connect(function()
		if flying and bodyVelocity and bodyGyro then
			local m = Vector3.zero
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then m += Camera.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then m -= Camera.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then m -= Camera.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then m += Camera.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then m += Vector3.new(0, 1, 0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then m -= Vector3.new(0, 1, 0) end
			bodyVelocity.Velocity = m.Magnitude > 0 and m.Unit * flySpeed or Vector3.zero
			bodyGyro.CFrame = Camera.CFrame
		end
	end)

	RunService.Heartbeat:Connect(function()
		local hum, char = getHumanoid(), getChar()
		if not hum or not char then return end
		-- Ne pas casser le sprint natif du jeu : si le jeu augmente la vitesse
		-- au-dessus de notre vitesse de base, on la laisse active. Quand le sprint
		-- s'arrête et que la vitesse revient à la normale, on reprend walkSpeed.
		if hum.WalkSpeed > walkSpeed then
			gameSprintSpeed = hum.WalkSpeed
		elseif hum.WalkSpeed < walkSpeed then
			gameSprintSpeed = nil
			hum.WalkSpeed = walkSpeed
		end
		-- Si un script du jeu a changé la vitesse pendant le sprint, on ne la force pas.
		if gameSprintSpeed and hum.WalkSpeed >= gameSprintSpeed then
			gameSprintSpeed = hum.WalkSpeed
		end
		if hum.UseJumpPower then
			if hum.JumpPower ~= jumpPower then hum.JumpPower = jumpPower end
		else
			if hum.JumpHeight ~= jumpPower / 7 then hum.JumpHeight = jumpPower / 7 end
		end
		if godmode then
			hum.MaxHealth = math.huge
			hum.Health = math.huge
		end
		if noclip then
			for _, p in pairs(char:GetDescendants()) do
				if p:IsA("BasePart") then p.CanCollide = false end
			end
		end
	end)

	Players.PlayerAdded:Connect(function(plr)
		plr.CharacterAdded:Connect(function()
			task.wait(1)
			if esp then createESP(plr) end
		end)
	end)
	Players.PlayerRemoving:Connect(function(plr)
		removeESP(plr)
		if skeletonDrawings[plr] then
			for _, d in pairs(skeletonDrawings[plr]) do if d.Remove then d:Remove() end end
			skeletonDrawings[plr] = nil
		end
	end)

	for _, plr in pairs(Players:GetPlayers()) do
		plr.CharacterAdded:Connect(function()
			task.wait(1)
			if esp then createESP(plr) end
		end)
	end

	player.CharacterAdded:Connect(function(char)
		task.wait(0.8)
		protect()
		setWalkSpeed(walkSpeed)
		setupSuperForce(char)
		if godmode then
			local h = char:WaitForChild("Humanoid")
			h.MaxHealth = math.huge
			h.Health = math.huge
		end
		if invisible then task.wait(0.3) setInvisible(true) end
		if rgb then startRGB() end
		if flying then stopFly() task.wait(0.3) startFly() end
		if spinning90 then stopSpin90() task.wait(0.3) startSpin90() end
		if ragdoll then stopRagdoll() task.wait(0.5) startRagdoll() end
		if nameGlitch then stopNameGlitch() task.wait(0.5) startNameGlitch() end
		characterVisualBackup = {}
		if bigHeadEnabled or tinyCharacterEnabled or headlessEnabled then
			task.wait(0.2)
			updateCharacterVisuals()
		end
	end)

	if player.Character then
		setupSuperForce(player.Character)
	end

	-- Une seule barre de recherche : celle de la cartographie principale.
	-- Elle filtre les boutons déjà enregistrés dans searchTargets.
	SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
		local query = string.lower(SearchBox.Text or "")
		for _, item in ipairs(searchTargets) do
			if query == "" then
				item.button.Visible = true
			else
				item.button.Visible = string.find(string.lower(item.text), query, 1, true) ~= nil
			end
		end
	end)


	showCategory("ACCUEIL")

	-- Fonds des fenêtres : ajoutés une fois toute l'interface créée.
	-- Apparence personnalisée UNIQUEMENT pour la fenêtre principale du tool.
	-- Les fenêtres TP / Spectate / Liste / Waypoints / Debug gardent leur apparence.
	addWindowBackground(Main)

	-- Image des boutons : uniquement dans la fenêtre principale du YM TOOL.
	-- Les fenêtres TP / Waypoints / Spectate / Liste / Debug restent inchangées.
	for _, obj in ipairs(Main:GetDescendants()) do
		if obj:IsA("GuiButton") then
			addButtonBackground(obj)
		end
	end

	print("✅ YM TOOL PC complet + Anti-Detection")
end

PassBtn.MouseButton1Click:Connect(function()
	if PassBox.Text == correctPassword then
		loadMainScript()
	else
		ErrorLabel.Text = "Mot de passe incorrect !"
		PassBox.Text = ""
		task.wait(1.5)
		ErrorLabel.Text = ""
	end
end)

PassBox.FocusLost:Connect(function(enter)
	if enter then
		if PassBox.Text == correctPassword then
			loadMainScript()
		else
			ErrorLabel.Text = "Mot de passe incorrect !"
			PassBox.Text = ""
			task.wait(1.5)
			ErrorLabel.Text = ""
		end
	end
end)
