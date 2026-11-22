if SERVER then
    AddCSLuaFile()
end

pk_pills.packStart("Mr Frog", "AnalogHorrorPills_blastnit_mr_frog", "pills/pill_blast_sider.png")
pk_pills.register('pill_mr_frog', {
    printName = 'Mr Frog',  
    model = "models/blast/mrfrog.mdl",
    modelScale = '1',

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
                local pillForm = pill:GetPillForm()
                local pillTbl = pill.formTable
                
                pk_pills.setCostumeMoveSpeed(pill, 1000, 1000)
                
                pillTbl.anims.default.walk = "run"
                pillTbl.anims.default.run = "run"

                timer.Simple(1, function()
                    pk_pills.setCostumeMoveSpeed(pill, 200, 200)
                    
                    pillTbl.anims.default.walk = "walk"
                    pillTbl.anims.default.run = "walk"
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
                    for k, v in ipairs(player.GetAll()) do
                        if IsValid(v.pk_pill_ent) then continue end
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
            func = function(ply, pill)
                local puppet = pill:GetPuppet()
                local bone = puppet:LookupBone("Lowerarm.R")

                local pos = puppet:GetBonePosition(bone)

                local ang = ply:EyeAngles()
                ang.p = 0
                ang:RotateAroundAxis(ang:Right(), -150)

                local tree = ents.Create("prop_physics")
                tree:SetModel("models/props_foliage/tree_pine06.mdl")
                tree:SetPos(pos - ang:Up()*100)
                tree:SetAngles(ang)
                tree:SetParent(puppet)
                tree:SetSolid(SOLID_NONE)
                tree:FollowBone(puppet, bone)
                tree:SetOwner(ply)
                tree:Spawn()

                SafeRemoveEntityDelayed(tree, 1)

                timer.Simple(.5, function()
                    SafeRemoveEntity(tree)

                    local pos = puppet:GetBonePosition(bone)
                    local dir = ply:GetForward()

                    local ang = ply:EyeAngles()
                    ang.p = 0
                    ang:RotateAroundAxis(ang:Forward(), -90)
                    ang:RotateAroundAxis(ang:Right(), -90)

                    local tree = ents.Create("frog_tree")
                    tree:SetOwner(ply)
                    tree:SetPos(ply:EyePos() + Vector(0, 0, 20))
                    tree:SetAngles(ang)
                    tree.moveDir = dir
                    tree:Spawn()

                    SafeRemoveEntityDelayed(tree, 5)
                end)
                
                pill:PillSound("treethrow")
                pill:PillAnim("treethrow", true)
            end
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
    },
    moveSpeed = {
        walk = 200,
        run = 200,
        ducked = 150,
    },
    sounds = {
		step = {"frog_step1.wav", "frog_step2.wav", "frog_step3.wav", "frog_step4.wav", "frog_step5.wav", "frog_step6.wav", "frog_step7.wav"},
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
        xPose ="aim_yaw",
        yPose = "aim_pitch",
        nocrosshair = true
    },   
    canAim = function(ply,ent) return ent.active end,    
    attack = {
        mode = 'trigger',
        func = function(ply, ent)
            if ent:GetCollisionGroup() == COLLISION_GROUP_IN_VEHICLE then return end

            local timings = {
                1.25,
                1.75,
                2.25,
                2.75,

                3.25,
                3.5,
                3.75,
                4,

                7,
                7.25,
            }

            for i = 1, 50 do
                table.insert(timings, 3.5 + .03*(i - 1))
            end

            for i = 1, 75 do
                table.insert(timings, 4.5 + .03*(i - 1))
            end

            return SlashModules.JumpscareV2(ply, {
                time = 7.25,
                bloodImpacts = timings,
            })
        end
    },
    attack2 = {
        mode = "trigger",
        func = function(ply, ent)
        end,
    },
    reload = function(ply,ent)
    end,
    flashlight = function(ply, ent)
    end,
    jump = function(ply, ent) end,
}, function(form)
    -- The legacy damage branches are for Sandbox and NPCs.
    form.hnsKillAPI = true
    form.hnsAbilities = {
        { id = "attack", name = "Ataque", key = IN_ATTACK, OnUse = form.attack.func },
    }
    form.attack, form.attack2, form.reload = nil, nil, nil
    SlashModules.ConfigureHNSAbilities(form)
end)

hook.Add("PlayerStepSoundTime", "MrFrog", function(ply, foottype, walking)
    local ent = ply.pk_pill_ent

    if !IsValid(ent) then return end
    local pillForm = ent:GetPillForm()
    
    if pillForm != "pill_mr_frog" then return end

    return ply:IsSprinting() and 200 or 425
end)