include("shared.lua")

function ENT:Draw()
    self:DrawModel()
end

function ENT:OnRemove()
    self:EmitSound("physics/wood/wood_plank_break3.wav", 125, 25)
    self:EmitSound("physics/wood/wood_plank_break3.wav", 125, 50)
    self:EmitSound("physics/wood/wood_plank_break3.wav", 125, 75)
end