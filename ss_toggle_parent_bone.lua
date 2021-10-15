ScriptName = "SS_ToggleParentBone"

-- **************************************************
-- Toggle Parent Bone - for Animated/Target bones
-- version:	1.0 AS11-MH13.5 #511015
-- by Sam Cogheil (SimplSam)
-- **************************************************

SS_ToggleParentBone = {}

function SS_ToggleParentBone:Name()
	return "Toggle Parent Bone"
end

function SS_ToggleParentBone:Version()
	return "1.0 #511015"
end

function SS_ToggleParentBone:Description()
	return "Toggle Parent Bone"
end

function SS_ToggleParentBone:Creator()
	return "Sam Cogheil (SimplSam)"
end

function SS_ToggleParentBone:UILabel()
	return "Toggle Parent Bone (Root)"
end

function SS_ToggleParentBone:IsEnabled(moho)
	if (not (moho.layer:IsBoneType())) or (moho.document:CurrentDocAction() ~= "")
            or (moho:CountSelectedBones(false) < 1) then
        return false
    end
end

function SS_ToggleParentBone:IsRelevant(moho)
    return (moho:Skeleton() ~= nil)
end

function SS_ToggleParentBone:ColorizeIcon()
    return true
end

-- **************************************************
-- App vars
-- **************************************************

SS_ToggleParentBone.rootID   = 0

-- **************************************************
-- The guts of this script
-- **************************************************

function SS_ToggleParentBone:Run(moho)
	local skel = moho:Skeleton()
    local v1 = LM.Vector2:new_local()
    local invMatrix = LM.Matrix:new_local()
    local frame0 = 0
    local parent = skel:Bone(SS_ToggleParentBone.rootID)
    local wasFrame = moho.frame
    moho.document:PrepUndo(moho.layer)
	moho.document:SetDirty()
    if (moho.frame ~= frame0) then moho:SetCurFrame(frame0) end
    for iBone =1, skel:CountBones(false) -1 do -- skip root
        local bone = skel:Bone(iBone)
        if (bone.fSelected) then
            local boneHasParent = bone.fParent ~= -1
            if (not boneHasParent) or (bone.fParent == SS_ToggleParentBone.rootID) then -- unparented or rooted
                local newParentID = (boneHasParent and -1 or SS_ToggleParentBone.rootID)
                for iKey = bone.fAnimPos:CountKeys() -1, 0, -1 do
                    local when = bone.fAnimPos:GetKeyWhen(iKey)
                    moho:SetCurFrame(when)
                    v1:Set(0, 0)
                    bone.fMovedMatrix:Transform(v1)  -- @cur frame
                    if (not boneHasParent) then
                        invMatrix:Set(parent.fMovedMatrix)
                        invMatrix:Invert()
                        invMatrix:Transform(v1)
                    end
                    bone.fAnimParent:SetValue(when, newParentID)
                    bone.fAnimPos:SetValue(when, v1)
                end
                bone.fParent = newParentID
                bone.fAnimParent:Clear(frame0)
                skel:UpdateBoneMatrix(iBone)
            end
        end
    end
    if (moho.frame ~= wasFrame) then moho:SetCurFrame(wasFrame) end
end