if SERVER then
    AddCSLuaFile()
end

-- Montada uma vez; o JumpscareV2 só copia a tabela, nunca altera.
local ATTACK_TIMINGS = { 1.25, 1.75, 2.25, 2.75, 3.25, 3.5, 3.75, 4, 7, 7.25 }
for i = 1, 50 do ATTACK_TIMINGS[#ATTACK_TIMINGS + 1] = 3.5 + .03 * (i - 1) end
for i = 1, 75 do ATTACK_TIMINGS[#ATTACK_TIMINGS + 1] = 4.5 + .03 * (i - 1) end

local function Alive(ply, pill)
    return IsValid(ply) and ply:Alive() and IsValid(pill)
end

local function ThrowTree(ply, pill)
    local puppet = pill:GetPuppet()
    if not IsValid(puppet) then return false end

    local bone = puppet:LookupBone("Lowerarm.R")
    if not bone then return false end

    local pos = puppet:GetBonePosition(bone)

    local ang = ply:EyeAngles()
    ang.p = 0
    ang:RotateAroundAxis(ang:Right(), -150)

    -- árvore só visual, na mão do sapo
    local handTree = ents.Create("prop_dynamic")
    if IsValid(handTree) then
        handTree:SetModel("models/props_foliage/tree_pine06.mdl")
        handTree:SetPos(pos - ang:Up() * 100)
        handTree:SetAngles(ang)
        handTree:SetParent(puppet)
        handTree:SetSolid(SOLID_NONE)
        handTree:FollowBone(puppet, bone)
        handTree:Spawn()
    end

    timer.Simple(.5, function()
        SafeRemoveEntity(handTree)
        if not Alive(ply, pill) then return end

        local tAng = ply:EyeAngles()
        tAng.p = 0
        tAng:RotateAroundAxis(tAng:Forward(), -90)
        tAng:RotateAroundAxis(tAng:Right(), -90)

        local tree = ents.Create("frog_tree")
        tree:SetOwner(ply)
        tree:SetPos(ply:EyePos() + Vector(0, 0, 20))
        tree:SetAngles(tAng)
        tree.moveDir = ply:GetForward()
        tree:Spawn()

        SafeRemoveEntityDelayed(tree, 5)
    end)

    pill:PillSound("treethrow")
    pill:PillAnim("treethrow", true)
    return true
end

pk_pills.packStart("Mr Frog", "AnalogHorrorPills_blastnit_mr_frog", "pills/pill_blast_sider.png")
pk_pills.register('pill_mr_frog', {
    printName = 'Mr Frog',
    model = "models/blast/mrfrog.mdl",

    abilities = {
        {
            name = "Night Vision",
            key = KEY_F,
            hnsKeyLabel = "F",
            hnsIcon = "night_vision.png",
            cooldown = 1,
            mat = Material("night_vision.png", "smooth"),
            func = function(ply, pill) end -- Client Stuff
        },
        {
            name = "Run",
            key = KEY_LSHIFT,
            hnsKeyLabel = "SHIFT",
            hnsIcon = "frog_sprint.png",
            keyText = "SHIFT",
            cooldown = 3,
            mat = Material("frog_sprint.png", "smooth"),
            func = function(ply, pill)
                -- animSet "sprint" (veja anims): não mexe na formTable compartilhada
                pill.forceAnimSet = "sprint"
                pk_pills.setCostumeMoveSpeed(pill, 1000, 1000)

                timer.Simple(1, function()
                    if not IsValid(pill) then return end
                    pill.forceAnimSet = nil
                    pk_pills.setCostumeMoveSpeed(pill) -- volta ao original / override do admin
                end)
            end
        },
        {
            name = "Highlight",
            key = KEY_R,
            hnsKeyLabel = "R",
            hnsIcon = "frog_hello.png",
            cooldown = 40,
            mat = Material("frog_hello.png", "smooth"),
            func = function(ply, pill)
                timer.Simple(1, function()
                    if not Alive(ply, pill) then return end

                    for _, v in ipairs(player.GetAll()) do
                        if v == ply or IsValid(v.pk_pill_ent) then continue end
                        if SherlockHNS and not SherlockHNS.CanTarget(v, ply) then continue end

                        SlashModules.ApplyTargetEffect(v, ply, {
                            name = "Highlighted",
                            time = 10,
                            color = SlashUI.Theme.Green
                        })
                    end
                end)

                pill:PillSound("highlight")
                pill:PillAnim("highlight", true)
            end
        },
        {
            name = "Tree Throw",
            key = KEY_T,
            hnsKeyLabel = "T",
            hnsIcon = "frog_tree.png",
            cooldown = 60,
            mat = Material("frog_tree.png", "smooth"),
            func = ThrowTree,
        },
    },

    noragdoll = true,
    anims = {
        default = {
            highlight = "hello",
            treethrow = "throwtree",

            idle = "idle",
            jumpscare = "kill",
            walk = "walk",
            run = "walk",
            jump = "jump",
            crouch = "cidle",
            crouch_walk = "cwalk",
        },
        sprint = {
            walk = "run",
            run = "run",
        },
    },
    moveSpeed = {
        walk = 200,
        run = 200,
        ducked = 150,
    },
    sounds = {
        step = { "frog_step1.wav", "frog_step2.wav", "frog_step3.wav", "frog_step4.wav", "frog_step5.wav", "frog_step6.wav", "frog_step7.wav" },
        highlight = "frog_hello.wav",
        treethrow = "frog_tree.wav",
        jumpscare = "frog_kill2.wav",
    },
    type = 'ply',
    camera = {
        offset = Vector(0, 0, 50),
        dist = 200,
    },
    jumpPower = 1,
    health = 2000,
    movePoseMode = "xy",
    aim = {
        xPose = "aim_yaw",
        yPose = "aim_pitch",
        nocrosshair = true
    },
    attack = {
        mode = 'trigger',
        func = function(ply, ent)
            if ent:GetCollisionGroup() == COLLISION_GROUP_IN_VEHICLE then return false end

            local result = SlashModules.JumpscareV2(ply, {
                time = 7.25,
                bloodImpacts = ATTACK_TIMINGS,
            })

            -- No HNS, sem alvo / kill recusada = não gasta cooldown
            if SherlockHNS then return result == true end
        end
    },
}, function(form)
    -- The legacy damage branches are for Sandbox and NPCs.
    form.hnsKillAPI = true
    form.hnsAbilities = {
        { id = "attack", name = "Ataque", key = IN_ATTACK, OnUse = form.attack.func },
    }
    form.attack = nil
    SlashModules.ConfigureHNSAbilities(form)
end)

hook.Add("PlayerStepSoundTime", "MrFrog_StepSoundTime", function(ply, foottype, walking)
    local ent = ply.pk_pill_ent
    if not IsValid(ent) or ent:GetPillForm() ~= "pill_mr_frog" then return end

    return ply:IsSprinting() and 200 or 425
end)
