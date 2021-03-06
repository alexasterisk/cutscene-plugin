local History = game:GetService("ChangeHistoryService")

-- create the keyframes folder
local beamFolder
local keyframeFolder = workspace:FindFirstChild("CSE_KEYFRAMES")
if not keyframeFolder then
    keyframeFolder = Instance.new("Folder")
    keyframeFolder.Name = "CSE_KEYFRAMES"
    keyframeFolder.Parent = workspace

    beamFolder = Instance.new("Folder")
    beamFolder.Name = "Beams"
    beamFolder.Parent = keyframeFolder
end

beamFolder = keyframeFolder.Beams

-- create a keyframe placeholder
local model: Model = script.Cam;

-- create a beam placeholder
local beamp: Beam = script.Beam
local beams: {[string]: Beam} = {}

-- solve bezier curve sizes
local function calculateCurve(p1: Model, p2: Model, beam: Beam)
    local dist = (p1.PrimaryPart.Position - p2.PrimaryPart.Position).Magnitude
    beam.CurveSize0 = math.clamp(dist / 10, 0, 10)
    beam.CurveSize1 = math.clamp(dist / 10, 0, 10)
end

local keyframe = {}
local keyframes: {[string]: Model} = {}

--- Creates a new Keyframe for the Cutscene Editor
---@param cf CFrame The CFrame that the position should be saved at
---@param pos? number The index of the keyframe to be located at
function keyframe.new(cf: CFrame, pos: number?)
    local inst = model:Clone()
    inst:SetPrimaryPartCFrame(cf)
    inst.Parent = keyframeFolder

    -- told to overwrite an existing number
    if type(pos) == "number" then
        inst.Name = "Keyframe " .. pos

        -- validate
        if keyframes[pos] ~= nil then
            keyframes[pos]:Destroy()
        end
        keyframes[pos] = inst
    else
        pos = #keyframes + 1
        inst.Name = "Keyframe " .. pos
        table.insert(keyframes, inst)
    end

    -- TODO make beziers smooth no matter their direction of movement
    -- connect the beams to eachother
    local before = keyframes[pos - 1]
    local after = keyframes[pos + 1]

    if before or after then
        local beam = beamp:Clone()

        if before ~= nil then
            local id = pos - 1 .. "-" .. pos
            local tb = beams[id]
            if tb ~= nil then
                tb:Destroy()
            end
            beam.Name = "Beam " .. id
            beam.Attachment0 = before.Camera.Attachment
            beam.Attachment1 = inst.Camera.Attachment
            calculateCurve(before, inst, beam)
            beams[id] = beam
        end

        if after ~= nil then
            local id = pos .. "-" .. pos + 1
            local tb = beams[id]
            if tb ~= nil then
                tb:Destroy()
            end
            beam.Name = "Beam " .. id
            beam.Attachment0 = inst.Camera.Attachment
            beam.Attachment1 = after.Camera.Attachment
            calculateCurve(inst, after, beam)
            beams[id] = beam
        end

        beam.Parent = beamFolder
    end

    History:SetWaypoint("CSE: New Keyframe")
end

keyframe.table = keyframes
return keyframe
