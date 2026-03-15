game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Catwljz",
    Text = "System Initialized...",
    Duration = 4,
    Icon = "rbxassetid://7733658504"
})

local Players = game:GetService("Players")
local ContentProvider = game:GetService("ContentProvider")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local OFF_IMAGE = "rbxassetid://70870733299983"
local ON_IMAGE = "rbxassetid://128028056631742"
local SOUND_ID = "rbxassetid://2668781453"

ContentProvider:PreloadAsync({OFF_IMAGE, ON_IMAGE})

local aiming = false
local lockedPlayer = nil
local headOffset = Vector3.new(0,0.6,0)
local prediction = 0.16

local gui = Instance.new("ScreenGui")
gui.Name = "LockGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("ImageButton")
button.Parent = gui
button.Size = UDim2.new(0,90,0,90)
button.Position = UDim2.new(0.5,-45,0.5,-45)
button.BackgroundColor3 = Color3.fromRGB(25,25,25)
button.BackgroundTransparency = 0.45
button.AutoButtonColor = false
button.Image = OFF_IMAGE
button.ScaleType = Enum.ScaleType.Fit

-- KÉO THẢ ĐƠN GIẢN
button.Active = true
button.Draggable = true

Instance.new("UICorner", button).CornerRadius = UDim.new(0,18)
Instance.new("UIAspectRatioConstraint", button).AspectRatio = 1

local clickSound = Instance.new("Sound")
clickSound.Parent = button
clickSound.SoundId = SOUND_ID
clickSound.Volume = 2

local espHighlight = nil

local function createESP(char)
	if espHighlight then
		espHighlight:Destroy()
	end
	
	espHighlight = Instance.new("Highlight")
	espHighlight.Parent = char
	espHighlight.FillColor = Color3.fromRGB(120,120,120)
	espHighlight.OutlineColor = Color3.fromRGB(255,255,255)
	espHighlight.FillTransparency = 0.4
	espHighlight.OutlineTransparency = 0
	espHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
end

local function removeESP()
	if espHighlight then
		espHighlight:Destroy()
		espHighlight = nil
	end
end

local function getCenterPlayer()

	local closest = nil
	local dist = math.huge
	local center = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)

	for _,v in pairs(Players:GetPlayers()) do
		if v ~= player and v.Character and v.Character:FindFirstChild("Head") then

			local head = v.Character.Head
			local pos,visible = camera:WorldToViewportPoint(head.Position)

			if visible then
				local magnitude = (Vector2.new(pos.X,pos.Y) - center).Magnitude

				if magnitude < dist then
					dist = magnitude
					closest = v
				end
			end
		end
	end

	return closest
end

button.MouseButton1Click:Connect(function()

	aiming = not aiming
	button.Image = aiming and ON_IMAGE or OFF_IMAGE

	clickSound:Play()

	if aiming then
		lockedPlayer = getCenterPlayer()
		if lockedPlayer and lockedPlayer.Character then
			createESP(lockedPlayer.Character)
		end
	else
		lockedPlayer = nil
		removeESP()
	end

end)

RunService.RenderStepped:Connect(function()

	if aiming and lockedPlayer then

		local char = lockedPlayer.Character
		if char and char:FindFirstChild("Head") then
			
			local head = char.Head
			local root = char:FindFirstChild("HumanoidRootPart")

			if root then
				local predicted = head.Position + (root.Velocity * prediction)
				camera.CFrame = CFrame.new(camera.CFrame.Position, predicted + headOffset)
			end

		else
			removeESP()
			lockedPlayer = getCenterPlayer()
			if lockedPlayer and lockedPlayer.Character then
				createESP(lockedPlayer.Character)
			end
		end

	end

end)