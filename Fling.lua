--[[ Made by evertdegriek ]]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

local flingPart = Instance.new("Part")
flingPart.Size = Vector3.new(2, 2, 2)
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
	angVel.AngularVelocity = Vector3.new(3000, 3000, 3000)
	angVel.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
	angVel.P = 100000
	angVel.Parent = spinPart
end

local holdingMouse = false

UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
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
		bodyPos.Position = targetPos:Lerp(bodyPos.Position, smoothing)
	end
end)

RunService.Heartbeat:Connect(function()
	if (flingPart.Position - rootPart.Position).Magnitude > 300 then
		bodyPos.Position = rootPart.Position + Vector3.new(0, 10, 0)
		flingPart.Velocity = Vector3.zero
	end
end)
