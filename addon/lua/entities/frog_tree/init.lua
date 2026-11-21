AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_foliage/tree_pine06.mdl")

    self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:PhysicsInit(SOLID_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
    self:DrawShadow(false)
    self:SetTrigger(true)
end

function ENT:ExplodePlayer(ply)
    if !IsValid(ply) or !ply:IsPlayer() or !ply:Alive() then return end
    if IsValid(ply.pk_pill_ent) then return end

    ply:TakeDamage(500, self:GetOwner())
    self:EmitSound("physics/wood/wood_plank_break3.wav", 125, 75)
end

function ENT:StartTouch(ent)
    self:ExplodePlayer(ent)
end

local sizeVec = Vector(100, 100, 100)
function ENT:Think()
    local moveSpeed = self.moveDir*5000*FrameTime()

    local pos = self:GetPos()
    local tr = util.TraceLine({
        start = pos,
        endpos = pos + moveSpeed,
        mask = MASK_SOLID_BRUSHONLY
    })

	local ents = ents.FindAlongRay(pos, pos + moveSpeed, -sizeVec, sizeVec)
    for k, v in ipairs(ents) do
        self:ExplodePlayer(v)
    end

    if tr.Hit then
		util.ScreenShake(self:GetPos(), 10, 15, 3, 1000)

        self:Remove()
        return
    elseif (self.qkCD or 0) < CurTime() then
        self.qkCD = CurTime() + .25
		util.ScreenShake(self:GetPos(), 2, 15, 1, 500)
    end

    local ang = self:GetAngles()
    ang.p = ang.p + 250*FrameTime()

    if ang.p >= 360 then
        ang.p = 0
    end

    self:SetAngles(ang)
    self:SetPos(pos + moveSpeed)

    self:NextThink(CurTime())
    return true
end