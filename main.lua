-- name: [CS] SMW dev2! [WIP]
-- description: Mario  \n\n\Made by: Wall_E20\n\n\\#ff7777\\This Pack requires Character Select\nto use as a Library!

local TEXT_MOD_NAME = "[CS] Super Mario World"

-- Stops mod from loading if Character Select isn't on
if not _G.charSelectExists then
    djui_popup_create(
        "\\#ffffdc\\\n" ..
        TEXT_MOD_NAME ..
        "\nRequires the Character Select Mod\nto use as a Library!\n\nPlease turn on the Character Select Mod\nand Restart the Room!",
        6)
    return 0
end

E_MODEL_SMW = smlua_model_util_get_id("smw_mario_geo")
TEX_SMW_MARIO_S = get_texture_info("smw-icon-small")
TEX_SMW_MARIO = get_texture_info("smw-icon-big")

local SMWVOICE = {}

SMW_anims = {
    [CHAR_ANIM_SWIM_PART1] = "SMW_WaterSwim",
    [CHAR_ANIM_SWIM_PART2] = "SMW_WaterSwim",
    [CHAR_ANIM_FLUTTERKICK] = "SMW_WaterIdle",
    [CHAR_ANIM_WATER_IDLE] = "SMW_WaterIdle",
    [CHAR_ANIM_WATER_ACTION_END] = "SMW_WaterIdle",
    [CHAR_ANIM_WATER_DYING] = "SMW_DeadAnim",
    [CHAR_ANIM_A_POSE] = "SMW_Idle",
    [CHAR_ANIM_TWIRL] = "SMW_Spinjump",
    [CHAR_ANIM_START_TWIRL] = "SMW_Spinjump",
    [CHAR_ANIM_IDLE_IN_QUICKSAND] = "SMW_Idle",
    [CHAR_ANIM_MOVE_IN_QUICKSAND] = "SMW_Walk2",
    [CHAR_ANIM_DYING_IN_QUICKSAND] = "SMW_DeadAnim",
    [CHAR_ANIM_WALK_WITH_LIGHT_OBJ] = SMW_ANIM_HOLD_WALK,
    [CHAR_ANIM_RUN_WITH_LIGHT_OBJ] = SMW_ANIM_HOLD_WALK,
    [CHAR_ANIM_SLOW_WALK_WITH_LIGHT_OBJ] = SMW_ANIM_HOLD_WALK,
    [CHAR_ANIM_FIRE_LAVA_BURN] = "SMW_DeadAnim",
    [CHAR_ANIM_TURNING_PART1] = "SMW_Skid",
    [CHAR_ANIM_TURNING_PART2] = "SMW_Skid",
    [CHAR_ANIM_IDLE_WITH_LIGHT_OBJ] = "SMW_IdleHold",
    [CHAR_ANIM_JUMP_WITH_LIGHT_OBJ] = "SMW_JumpHold",
    [CHAR_ANIM_FALL_WITH_LIGHT_OBJ] = "SMW_JumpHold",
    [CHAR_ANIM_SLIDING_ON_BOTTOM_WITH_LIGHT_OBJ] = "SMW_CrouchHold",
    [CHAR_ANIM_RIDING_SHELL] = "SMW_Sit",
    [CHAR_ANIM_START_RIDING_SHELL] = "SMW_Sit",
    [CHAR_ANIM_BEND_KNESS_RIDING_SHELL] = "SMW_Sit",
    [CHAR_ANIM_JUMP_RIDING_SHELL] = "SMW_Sit",
    [CHAR_ANIM_THROW_LIGHT_OBJECT] = "SMW_Kick",
    [CHAR_ANIM_GRAB_HEAVY_OBJECT] = "SMW_IdleHold",
    [CHAR_ANIM_MISSING_CAP] = "CHAR_ANIM_MISSING_CAP",
    [CHAR_ANIM_GROUND_THROW] = "SMW_Kick",
    [CHAR_ANIM_GROUND_KICK] = "SMW_Kick",
    [CHAR_ANIM_PLACE_LIGHT_OBJ] = "SMW_CrouchHold",
    [CHAR_ANIM_FIRST_PERSON] = "SMW_Idle",
    [CHAR_ANIM_LAND_FROM_SINGLE_JUMP] = "SMW_Idle",
    [CHAR_ANIM_WALK_PANTING] = "SMW_Idle",
    [CHAR_ANIM_GENERAL_LAND] = "SMW_Idle",
    [CHAR_ANIM_TAKE_CAP_OFF_THEN_ON] = "SMW_Idle",
    [CHAR_ANIM_STAND_AGAINST_WALL] = "SMW_Idle",
    [CHAR_ANIM_SIDESTEP_LEFT] = "SMW_Idle",
    [CHAR_ANIM_IDLE_HEAD_LEFT] = "SMW_Idle",
    [CHAR_ANIM_IDLE_HEAD_RIGHT] = "SMW_Idle",
    [CHAR_ANIM_IDLE_HEAD_CENTER] = "SMW_Idle",
    [CHAR_ANIM_RUNNING] = "SMW_Walk2",
    [CHAR_ANIM_RUNNING_UNUSED] = "SMW_Run",
    [CHAR_ANIM_WALKING] = "SMW_Walk2",
    [CHAR_ANIM_TIPTOE] = "SMW_Walk2",
    [CHAR_ANIM_START_TIPTOE] = "SMW_Walk2",
    [CHAR_ANIM_GENERAL_FALL] = "smw_fall",
    [CHAR_ANIM_SINGLE_JUMP] = "smw_Jump",
    [CHAR_ANIM_CROUCHING] = "SMW_Crouch",
    [CHAR_ANIM_START_CROUCHING] = "SMW_Crouch",
    [CHAR_ANIM_DOUBLE_JUMP_FALL] = "SMW_Spinjump",
    [CHAR_ANIM_DOUBLE_JUMP_RISE] = "SMW_Spinjump",
    [CHAR_ANIM_DIVE] = "SMW_Spinjump",
    [CHAR_ANIM_FORWARD_SPINNING] = "SMW_Spinjump",
    [CHAR_ANIM_BACKWARD_SPINNING] = "SMW_Spinjump",
    [CHAR_ANIM_TRIPLE_JUMP] = "SMW_RunJump",
    [CHAR_ANIM_AIRBORNE_ON_STOMACH] = "SMW_RunJump",
    [CHAR_ANIM_STAR_DANCE] = "SMW_Pacesign",
    --[CHAR_ANIM_SUMMON_STAR] = "SMW_Pacesign",
    [charSelect.CS_ANIM_MENU] = "SMW_Pacesign",
    [CHAR_ANIM_SLIDE] = "SMW_Sit",
    [CHAR_ANIM_SLIDE_DIVE] = "SMW_Sit",
    [CHAR_ANIM_FORWARD_KB] = "smw_fall",
    [CHAR_ANIM_SHOCKED] = "smw_fall",
    [CHAR_ANIM_BACKWARD_KB] = "smw_fall",
    [CHAR_ANIM_BACKWARD_AIR_KB] = "smw_fall",
    [CHAR_ANIM_AIR_FORWARD_KB] = "smw_fall",
    [CHAR_ANIM_FALL_OVER_BACKWARDS] = "smw_fall",
    [CHAR_ANIM_DYING_FALL_OVER] = "smw_fall",
    [CHAR_ANIM_BEING_GRABBED] = "smw_fall",
    [CHAR_ANIM_SUFFOCATING] = "SMW_Dead",
    [CHAR_ANIM_DYING_FALL_OVER] = "SMW_DeadAnim",
    [CHAR_ANIM_FALL_FROM_WATER] = "smw_fall",
    [CHAR_ANIM_IDLE_ON_POLE] = "SMW_Climb",
    [CHAR_ANIM_GRAB_POLE_SHORT] = "SMW_Climb",
    [CHAR_ANIM_GRAB_POLE_SWING_PART1] = "SMW_Climb",
    [CHAR_ANIM_GRAB_POLE_SWING_PART2] = "SMW_Climb",
    [CHAR_ANIM_CLIMB_UP_POLE] = "SMW_Climbing",
    [CHAR_ANIM_TWIRL_LAND] = "SMW_Idle",
    [CHAR_ANIM_HANG_ON_OWL] = "smw_fall",
    [CHAR_ANIM_HANG_ON_CEILING] = "smw_fall",
    [CHAR_ANIM_MOVE_ON_WIRE_NET_RIGHT] = "smw_fall",
    [CHAR_ANIM_MOVE_ON_WIRE_NET_LEFT] = "smw_fall",
}


S_SMW_anims = {
    [CHAR_ANIM_SWIM_PART1] = "SMW_WaterSwim",
    [CHAR_ANIM_SWIM_PART2] = "SMW_WaterSwim",
    [CHAR_ANIM_FLUTTERKICK] = "SMW_WaterIdle",
    [CHAR_ANIM_WATER_IDLE] = "SMW_WaterIdle",
    [CHAR_ANIM_WATER_ACTION_END] = "SMW_WaterIdle",
    [CHAR_ANIM_WATER_DYING] = "SMW_DeadAnim",
    [CHAR_ANIM_A_POSE] = "SMW_Idle",
    [CHAR_ANIM_IDLE_IN_QUICKSAND] = "SMW_Idle",
    [CHAR_ANIM_MOVE_IN_QUICKSAND] = "SMW_Walk2",
    [CHAR_ANIM_DYING_IN_QUICKSAND] = "SMW_DeadAnim",
    [CHAR_ANIM_TWIRL] = "SMW_Spinjump",
    [CHAR_ANIM_START_TWIRL] = "SMW_Spinjump",
    [CHAR_ANIM_WALK_WITH_LIGHT_OBJ] = SMW_ANIM_HOLD_WALK,
    [CHAR_ANIM_RUN_WITH_LIGHT_OBJ] = SMW_ANIM_HOLD_WALK,
    [CHAR_ANIM_SLOW_WALK_WITH_LIGHT_OBJ] = SMW_ANIM_HOLD_WALK,
    [CHAR_ANIM_FIRE_LAVA_BURN] = "SMW_DeadAnim",
    [CHAR_ANIM_TURNING_PART1] = "SMW_Skid",
    [CHAR_ANIM_TURNING_PART2] = "SMW_Skid",
    [CHAR_ANIM_IDLE_WITH_LIGHT_OBJ] = "SMW_IdleHold",
    [CHAR_ANIM_JUMP_WITH_LIGHT_OBJ] = "SMW_JumpHold",
    [CHAR_ANIM_FALL_WITH_LIGHT_OBJ] = "SMW_JumpHold",
    [CHAR_ANIM_SLIDING_ON_BOTTOM_WITH_LIGHT_OBJ] = "SMW_CrouchHold",
    [CHAR_ANIM_RIDING_SHELL] = "SMW_Sit",
    [CHAR_ANIM_START_RIDING_SHELL] = "SMW_Sit",
    [CHAR_ANIM_BEND_KNESS_RIDING_SHELL] = "SMW_Sit",
    [CHAR_ANIM_JUMP_RIDING_SHELL] = "SMW_Sit",
    [CHAR_ANIM_THROW_LIGHT_OBJECT] = "SMW_Kick",
    [CHAR_ANIM_GRAB_HEAVY_OBJECT] = "SMW_IdleHold",
    --[CHAR_ANIM_MISSING_CAP] = "CHAR_ANIM_MISSING_CAP",
    [CHAR_ANIM_GROUND_THROW] = "SMW_Kick",
    [CHAR_ANIM_GROUND_KICK] = "SMW_Kick",
    [CHAR_ANIM_PLACE_LIGHT_OBJ] = "SMW_CrouchHold",
    [CHAR_ANIM_FIRST_PERSON] = "S_SMW_Idle",
    [CHAR_ANIM_LAND_FROM_SINGLE_JUMP] = "S_SMW_Idle",
    [CHAR_ANIM_TAKE_CAP_OFF_THEN_ON] = "S_SMW_Idle",
    [CHAR_ANIM_GENERAL_LAND] = "S_SMW_Idle",
    [CHAR_ANIM_WALK_PANTING] = "S_SMW_Idle",
    [CHAR_ANIM_IDLE_HEAD_LEFT] = "S_SMW_Idle",
    [CHAR_ANIM_IDLE_HEAD_RIGHT] = "S_SMW_Idle",
    [CHAR_ANIM_IDLE_HEAD_CENTER] = "S_SMW_Idle",
    [CHAR_ANIM_STAND_AGAINST_WALL] = "S_SMW_Idle",
    [CHAR_ANIM_SIDESTEP_LEFT] = "S_SMW_Idle",
    [CHAR_ANIM_RUNNING] = "S_SMW_Walk",
    [CHAR_ANIM_RUNNING_UNUSED] = "S_SMW_Run",
    [CHAR_ANIM_WALKING] = "S_SMW_Walk",
    [CHAR_ANIM_TIPTOE] = "S_SMW_Walk",
    [CHAR_ANIM_START_TIPTOE] = "S_SMW_Walk",
    [CHAR_ANIM_GENERAL_FALL] = "S_SMW_Fall",
    [CHAR_ANIM_FORWARD_KB] = "S_SMW_Fall",
    [CHAR_ANIM_BACKWARD_KB] = "S_SMW_Fall",
    [CHAR_ANIM_BACKWARD_AIR_KB] = "S_SMW_Fall",
    [CHAR_ANIM_AIR_FORWARD_KB] = "S_SMW_Fall",
    [CHAR_ANIM_FALL_OVER_BACKWARDS] = "S_SMW_Fall",
    [CHAR_ANIM_SINGLE_JUMP] = "S_SMW_Jump",
    [CHAR_ANIM_CROUCHING] = "S_SMW_Crouch",
    [CHAR_ANIM_START_CROUCHING] = "S_SMW_Crouch",
    [CHAR_ANIM_DOUBLE_JUMP_FALL] = "S_SMW_Spijump",
    [CHAR_ANIM_DOUBLE_JUMP_RISE] = "S_SMW_Spijump",
    [CHAR_ANIM_DIVE] = "S_SMW_Spijump",
    [CHAR_ANIM_FORWARD_SPINNING] = "S_SMW_Spijump",
    [CHAR_ANIM_BACKWARD_SPINNING] = "S_SMW_Spijump",
    [CHAR_ANIM_TRIPLE_JUMP] = "S_SMW_RunJump",
    [CHAR_ANIM_AIRBORNE_ON_STOMACH] = "S_SMW_RunJump",
    [CHAR_ANIM_STAR_DANCE] = "S_SMW_PaceSign",
    --[CHAR_ANIM_SUMMON_STAR] = "S_SMW_PaceSign",
    [charSelect.CS_ANIM_MENU] = "S_SMW_PaceSign",
    [CHAR_ANIM_SLIDE] = "SMW_Sit",
    [CHAR_ANIM_SLIDE_DIVE] = "SMW_Sit",
    [CHAR_ANIM_BEING_GRABBED] = "S_SMW_Fall",
    [CHAR_ANIM_SUFFOCATING] = "SMW_Dead",
    [CHAR_ANIM_DYING_FALL_OVER] = "SMW_DeadAnim",
    [CHAR_ANIM_SHOCKED] = "S_SMW_Fall",
    [CHAR_ANIM_FALL_FROM_WATER] = "S_SMW_Fall",
    [CHAR_ANIM_IDLE_ON_POLE] = "SMW_Climb",
    [CHAR_ANIM_GRAB_POLE_SHORT] = "SMW_Climb",
    [CHAR_ANIM_GRAB_POLE_SWING_PART1] = "SMW_Climb",
    [CHAR_ANIM_GRAB_POLE_SWING_PART2] = "SMW_Climb",
    [CHAR_ANIM_CLIMB_UP_POLE] = "SMW_Climbing",
    [CHAR_ANIM_TWIRL_LAND] = "SMW_Idle",
    [CHAR_ANIM_HANG_ON_OWL] = "S_SMW_Fall",
    [CHAR_ANIM_HANG_ON_CEILING] = "S_SMW_Fall",
    [CHAR_ANIM_MOVE_ON_WIRE_NET_RIGHT] = "S_SMW_Fall",
    [CHAR_ANIM_MOVE_ON_WIRE_NET_LEFT] = "S_SMW_Fall",
}



local PALETTE_SMW = {
    [PANTS]  = "75C1B0",
    [SHIRT]  = "E23762",
    [GLOVES] = "ffffff",
    [SHOES]  = "66400B",
    [HAIR]   = "000000",
    [SKIN]   = "E2BAA9",
    [CAP]    = "E23762",
    [EMBLEM] = "E23762"
}

local CSloaded = false
local function on_character_select_load()
    CT_SMW = _G.charSelect.character_add("Super Mario World2",
        { "he is back new!" }, "Wall_E20",
        { r = 226, g = 55, b = 98 },
        E_MODEL_SMW, CT_MARIO, TEX_SMW_MARIO, 1)
    _G.charSelect.character_add_palette_preset(E_MODEL_SMW, PALETTE_SMW, "World")
    --_G.charSelect.config_character_sounds()
    _G.charSelect.character_add_animations(E_MODEL_SMW, SMW_anims)
    _G.charSelect.character_add_voice(E_MODEL_SMW, SMWVOICE)
end

local function on_character_sound(m, sound)
    if not CSloaded then return end
    if _G.charSelect.character_get_voice(m) == SMWVOICE then return _G.charSelect.voice.sound(m, sound) end
end

local function on_character_snore(m)
    if not CSloaded then return end
    if _G.charSelect.character_get_voice(m) == SMWVOICE then return _G.charSelect.voice.snore(m) end
end


hook_event(HOOK_ON_MODS_LOADED, on_character_select_load)
hook_event(HOOK_CHARACTER_SOUND, on_character_sound)
hook_event(HOOK_MARIO_UPDATE, on_character_snore)


local function on_smw_update(m)
    local e = gPlayerSyncTable[m.playerIndex]
    if _G.charSelect.character_get_current_number(m.playerIndex) == CT_SMW then
        e.is_smw = true
    else
        e.is_smw = false
    end

    if e.is_smw == false and (ACTIONS_SMW[m.action] ~= nil) then
        m.action = ACT_FREEFALL
    end

    if e.is_smw then

        smw_size(m)

        if (m.action ~= ACT_SMW_WALKING) and (m.action ~= ACT_SMW_JUMP) and (m.action ~= ACT_SMW_FALL) then
            if ((m.controller.buttonDown & B_BUTTON == 0) or m.forwardVel < 18 * 2.3) then
                e.pspeed = e.pspeed - 4
            end
        end
        if ((m.action == ACT_SMW_JUMP) or (m.action == ACT_SMW_FALL)) then
            if (m.forwardVel < 18 * 1.5) or (analog_stick_held_back(m) ~= 0) then
                e.pspeed = e.pspeed - 4
            end
        end

        if e.pspeed > 60 then
            e.pspeed = 60
        end
        if e.pspeed < 5 then
            e.pspeed = 5
        end

        m.peakHeight = m.pos.y
        --[[
        if e.small_model_switch == MODEL_SMALL then
            _G.charSelect.character_add_animations(E_MODEL_SMW, S_SMW_anims)
        else
            _G.charSelect.character_add_animations(E_MODEL_SMW, SMW_anims)
        end
        --]]

        if e.size_state > SIZESTATE_BIG then
            e.size_state = SIZESTATE_BIG
        end
        if e.size_state <= SIZESTATE_DEAD then
            set_mario_action(m, ACT_STANDING_DEATH, 0)
            e.size_state = SIZESTATE_SMALL
        end
        if e.coin_count < 0 then
            e.coin_count = 0
        end
        if e.coin_count >= 5 and e.size_state < SIZESTATE_BIG then
            heal_smw(m)
        end
        if m.hurtCounter ~= 0 then
            m.hurtCounter = 0
            damage_smw(m)
        end
    end
end
hook_event(HOOK_MARIO_UPDATE, on_smw_update)

local function on_death(m)
    local e = gPlayerSyncTable[m.playerIndex]
    if e.is_smw then
        --djui_chat_message_create("dead!")
        e.power_state = POWERSTATE_NORMAL
        e.size_state = SIZESTATE_SMALL
        e.coin_count = 0
    end
end
hook_event(HOOK_ON_DEATH, on_death)

---@param m MarioState
---@param o Object
local function smw_small(m, o, inttype)
    local e = gPlayerSyncTable[m.playerIndex]
    if (m.playerIndex ~= 0) then
    elseif (m.playerIndex == 0) and e.is_smw then
        if inttype == INTERACT_COIN and (o.oDamageOrCoinValue > 0) and e.size_state < SIZESTATE_BIG then
            e.coin_count = e.coin_count + 1
        end
    end
end

hook_event(HOOK_ON_INTERACT, smw_small)




local function setsmall()
    local e = gPlayerSyncTable[gMarioStates[0].playerIndex]
    if e.is_smw then
        damage_smw(gMarioStates[0])
    end
    return true
end
hook_chat_command("smw-damage", "- damages smw", setsmall)

local function setbig()
    local e = gPlayerSyncTable[gMarioStates[0].playerIndex]
    if e.is_smw then
        heal_smw(gMarioStates[0])
    end
    return true
end
hook_chat_command("smw-mushroom", "- gives smw a mushroom", setbig)

local function setfire()
    local e = gPlayerSyncTable[gMarioStates[0].playerIndex]
    if e.is_smw then
        power_smw(gMarioStates[0], POWERSTATE_FIRE)
    end
    return true
end
hook_chat_command("smw-fire", "- changes smw's status to be fire", setfire)



function on_hud_render()
    local s = gPlayerSyncTable[gMarioStates[0].playerIndex]
    djui_hud_set_resolution(RESOLUTION_N64);
    if s.is_smw then
        djui_hud_print_text("p-speed =" .. s.pspeed, 2, 140, 0.5)
        djui_hud_print_text("SIZESTATE =" .. s.size_state, 2, 120, 0.5)
        djui_hud_print_text("POWERSTATE =" .. s.power_state, 2, 100, 0.5)
        djui_hud_print_text("coin_count =" .. s.coin_count, 2, 80, 0.5)
        djui_hud_print_text("model =" .. s.small_model_switch, 2, 60, 0.5)
    end
end

hook_event(HOOK_ON_HUD_RENDER, on_hud_render)
