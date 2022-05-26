local Signal = require(script.Parent.includes.Signal)

--- Gets the location on a cubic of the bezier curve
---@param time number The current % completion [0-1]
local function calculateBezier(time: number, start: number, bend1: number, bend2: number, finish: number): number
    return (1 - time)^3 * start + 3*(1 - time)^2 * time * bend1 + 3*(1 - time) * time^2 * bend2 + time^3 * finish
end

local function getLocation(kf: Model, next_kf: Model, time: number): CFrame
    return kf.PrimaryPart.CFrame * calculateBezier(time, kf.Camera.Attachment.Position, (kf.Camera.Attachment.CFrame * CFrame.new(10, 0, 0)).p, (next_kf.Camera.Attachment.CFrame * CFrame.new(-10, 0, 0)).p, next_kf.Camera.Attachment.Position)
end

local tracing = {}
tracing.__index = tracing

function tracing.new(keyframes: {[number]: Model}, events, timings)
    local mt = {}
    mt._keyframes = keyframes
    mt._events = events
    mt._timings = timings

    mt.Began = Signal.new()
    mt.KeyframeStarted = Signal.new()
    mt.Finished = Signal.new()

    setmetatable(mt, tracing) -- this mt is refusing to work

    mt.Began:Connect(function()
        if mt._events and mt._events["First"] ~= nil then
            mt._events["First"](mt._timings["First"] or 1)
        end
    end)

    mt.Finished:Connect(function()
        if mt._events and mt._events["Last"] ~= nil then
            mt._events["Last"](mt._timings["Last"] or 1)
        end
    end)

    mt.KeyframeStarted:Connect(function(kf: number)
        if mt._events and mt._events[kf] ~= nil then
            mt._events[kf](mt._timings[kf] or 1)
        end
    end)

    print(mt, getmetatable(mt)) -- metatable exists here
    return mt
end

--- Interpolates the cameras path with the bezier curve
---@param index number The Keyframe the tracing is currently on
function tracing:_interpolateBetween(index: number)
    local timeLength = self._timings[index] or 1
    local kf = self._keyframes[index]
    local next_kf = next(self._keyframes, index)
    if next_kf then
        for i = 0, timeLength, .05 do
            self._camera.CFrame = getLocation(kf, next_kf, i / timeLength)
            task.wait(.05)
        end
    end
end

-- Beings the camera path
function tracing:begin()
    print(self, getmetatable(self)) -- metatable doesnt exist here
    if self._thread then
        return
    end

    self._thread = coroutine.wrap(function()
        workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
        self._camera = workspace.CurrentCamera
        local conn
        conn = self.Finished:Connect(function() -- <== attempt to index nil with 'Connect'
            coroutine.yield()
            coroutine.close(self._thread)
            self._thread = nil
            conn:Disconnect()
        end)
        self.Began:Fire()
        for i = 1, #self._keyframes do
            if next(self._keyframes, i) then
                self.KeyframeStarted:Fire(i)
                self:_interpolateBetween(i)
            else
                break
            end
        end
        self.Finished:Fire()
    end)()
end

-- Ends the camera path
function tracing:stop()
    print(self, getmetatable(self)) -- metatable doesnt exist here
    self.connections.Finished:Fire()
end

return tracing