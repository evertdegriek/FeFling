-- Made by evertdegriek

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

local function isTargetCharacter(model)
	if not model or not model:IsA("Model") then return false end
	if model == character then return false end
	local humanoid = model:FindFirstChildWhichIsA("Humanoid")
	local hrp = model:FindFirstChild("HumanoidRootPart")
	return humanoid and hrp
end

local function isPathBlocked(origin, target)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastParams.FilterDescendantsInstances = {character}
	raycastParams.IgnoreWater = true

	local direction = (target - origin)
	local result = workspace:Raycast(origin, direction, raycastParams)

	return result and (result.Position - origin).Magnitude < direction.Magnitude
end

local flingPart = Instance.new("Part")
flingPart.Size = Vector3.new(1.5, 1.5, 1.5)
flingPart.Anchored = false
flingPart.CanCollide = true
flingPart.Transparency = 1
flingPart.Massless = false
flingPart.Position = rootPart.Position + Vector3.new(0, 7, 0)
flingPart.Name = "FlingPart"
flingPart.Parent = workspace

local bodyForce = Instance.new("BodyForce")
bodyForce.Force = Vector3.new(0, flingPart:GetMass() * workspace.Gravity, 0)
bodyForce.Parent = flingPart

local box = Instance.new("SelectionBox")
box.Adornee = flingPart
box.LineThickness = 0.1
box.Color3 = Color3.fromRGB(0, 170, 255)
box.Parent = flingPart

local bodyPos = Instance.new("BodyPosition")
bodyPos.MaxForce = Vector3.zero
bodyPos.P = 50000
bodyPos.D = 1000
bodyPos.Position = flingPart.Position
bodyPos.Parent = flingPart

for i = 1, 2 do
	local spinPart = Instance.new("Part")
	spinPart.Size = Vector3.new(2, 2, 2)
	spinPart.Anchored = false
	spinPart.CanCollide = false
	spinPart.Transparency = 1
	spinPart.Massless = true
	spinPart.Position = flingPart.Position + Vector3.new(i * 3, 0, 0)
	spinPart.Parent = flingPart

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = flingPart
	weld.Part1 = spinPart
	weld.Parent = flingPart

	local angVel = Instance.new("BodyAngularVelocity")
	angVel.AngularVelocity = Vector3.new(10000, 10000, 10000)
	angVel.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
	angVel.P = 100000
	angVel.Parent = spinPart
end

local alreadyFlung = {}

RunService.Heartbeat:Connect(function()
	local touchingParts = flingPart:GetTouchingParts()

	for _, part in ipairs(touchingParts) do
		local model = part:FindFirstAncestorOfClass("Model")
		if isTargetCharacter(model) and not alreadyFlung[model] then
			alreadyFlung[model] = true

			local hrp = model:FindFirstChild("HumanoidRootPart")
			if hrp then
				local direction = (hrp.Position - flingPart.Position).Unit
				hrp.Velocity = direction * 200
			end

			task.delay(1, function()
				alreadyFlung[model] = nil
			end)
		end
	end
end)

local holdingMouse = false

UserInputService.InputBegan:Connect(function(input, processed)
	if not processed and input.UserInputType == Enum.UserInputType.MouseButton1 then
		holdingMouse = true
		bodyPos.MaxForce = Vector3.new(1e6, 1e6, 1e6)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		holdingMouse = false
		bodyPos.MaxForce = Vector3.zero
		bodyPos.Position = flingPart.Position
		flingPart.Velocity = Vector3.zero
	end
end)

local smoothing = 0.2

RunService.RenderStepped:Connect(function()
	if holdingMouse then
		local unitRay = camera:ScreenPointToRay(mouse.X, mouse.Y)
		local targetPos = unitRay.Origin + unitRay.Direction * 22
		local origin = flingPart.Position

		if isPathBlocked(origin, targetPos) then
			flingPart.CanCollide = false
			for _, p in ipairs(flingPart:GetChildren()) do
				if p:IsA("BasePart") then p.CanCollide = false end
			end

			task.delay(0.3, function()
				flingPart.CanCollide = true
				for _, p in ipairs(flingPart:GetChildren()) do
					if p:IsA("BasePart") then p.CanCollide = false end
				end
			end)
		end

		bodyPos.Position = targetPos:Lerp(bodyPos.Position, smoothing)
	end
end)

RunService.Heartbeat:Connect(function()
	if (flingPart.Position - rootPart.Position).Magnitude > 300 then
		bodyPos.Position = rootPart.Position + Vector3.new(0, 10, 0)
		flingPart.Velocity = Vector3.zero
	end
end)
