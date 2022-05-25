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

local beams = {}
local keyframes = {}

local keyframe = {}
keyframe.__index = keyframe

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

    if before ~= nil then
        local id = pos - 1 .. "-" .. pos
        local tb = beams[id]
        if tb ~= nil then
            tb:Destroy()
        end
        local beam = beamp:Clone()
        beam.Name = "Beam " .. id
        beam.Attachment0 = before.Camera.Attachment
        beam.Attachment1 = inst.Camera.Attachment
        beam.Parent = beamFolder
    end

    if after ~= nil then
        local id = pos .. "-" .. pos + 1
        local tb = beams[id]
        if tb ~= nil then
            tb:Destroy()
        end
        local beam = beamp:Clone()
        beam.Name = "Beam " .. id
        beam.Attachment0 = inst.Camera.Attachment
        beam.Attachment1 = after.Camera.Attachment
        beam.Parent = beamFolder
    end

    History:SetWaypoint("CSE: New Keyframe")
end

return keyframe