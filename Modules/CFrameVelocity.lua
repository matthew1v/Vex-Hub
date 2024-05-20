local VelocityCalculator = {}
local RunService = game:GetService("RunService")
local IsServer = RunService:IsServer()
local LoopMethod = (IsServer and RunService.Stepped or RunService.RenderStepped)
VelocityCalculator.__index = VelocityCalculator

function VelocityCalculator.new()
	local self = setmetatable({}, VelocityCalculator)
	self.Recording = {
		lastTick = tick(),
		lastPosition = Vector3.new(0, 0, 0)
	}
	self.instance = nil
	self.connection = nil
	self.velocity = Vector3.new(0, 0, 0)
	return self
end

function VelocityCalculator:init()
	assert(self.instance, "No instance found! Fix this by setting VelocityCalculator's .instance value to a BasePart.")
	assert(self.instance:IsA("BasePart"), "Argument was expected to be a BasePart, got " .. self.instance.ClassName)
	self.Recording.lastTick = tick()
	self.Recording.lastPosition = self.instance.Position
	self.connection = LoopMethod:Connect(function(delta)
		local newPosition = self.instance.Position
		local newTick = tick()

		local deltaPosition = newPosition - self.Recording.lastPosition
		local deltaTick = newTick - self.Recording.lastTick

		if deltaTick > 0 then
			self.velocity = deltaPosition / deltaTick
			self.Recording.lastTick = newTick
			self.Recording.lastPosition = newPosition
		end
	end)
end

function VelocityCalculator:stop()
	if self.connection then
		self.connection:Disconnect()
		self.connection = nil
	end
end

function VelocityCalculator:restart()
	if not self.connection then
		self.connection = LoopMethod:Connect(function(delta)
			local newPosition = self.instance.Position
			local newTick = tick()

			local deltaPosition = newPosition - self.Recording.lastPosition
			local deltaTick = newTick - self.Recording.lastTick

			if deltaTick > 0 then
				self.velocity = deltaPosition / deltaTick
				self.Recording.lastTick = newTick
				self.Recording.lastPosition = newPosition
			end
		end)
	end
end

function VelocityCalculator:timeToGoal(goalPosition)
	local currentPosition = self.instance.Position
	local distance = (goalPosition - currentPosition).magnitude
	local velocityMagnitude = self.velocity.magnitude

	if velocityMagnitude > 0 then
		return distance / velocityMagnitude
	else
		return math.huge
	end
end

return VelocityCalculator
