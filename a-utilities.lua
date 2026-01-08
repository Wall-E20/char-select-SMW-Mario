SIZESTATE_DEAD = 0
SIZESTATE_SMALL = 1
SIZESTATE_BIG = 2

POWERSTATE_NORMAL = 0
POWERSTATE_CAPE = 2
POWERSTATE_FIRE = 1

gPlayerSyncTable[0].size_state = SIZESTATE_SMALL -- 0 = dead, 1 = small, 2 = big
gPlayerSyncTable[0].power_state = POWERSTATE_NORMAL

gPlayerSyncTable[0].is_smw = false
gPlayerSyncTable[0].coin_count = 0


gPlayerSyncTable[0].small_model_switch = 0

MODEL_BIG = 0
MODEL_SMALL = 1

gPlayerSyncTable[0].pspeed = 0
gPlayerSyncTable[0].pcheck = false


gPlayerSyncTable[0].power_anim = 0 --0= doing nothing 1= growing, 2=damaging
gPlayerSyncTable[0].anim_timer = 0
gPlayerSyncTable[0].prev_forward_speed = 0
gPlayerSyncTable[0].prev_speed = {}
local prevSpeed = gPlayerSyncTable[0].prev_speed
prevSpeed.x = 0
prevSpeed.y = 0
prevSpeed.z = 0
gPlayerSyncTable[0].prev_pos = {}
local prev_pos = gPlayerSyncTable[0].prev_pos
prev_pos.x = 0
prev_pos.y = 0
prev_pos.z = 0

DAMAGE = audio_sample_load("smw_powerdown.ogg")
POWER = audio_sample_load("smw_power-up.ogg")
ITEM = audio_sample_load("smw_item_get.ogg")
JUMP = audio_sample_load("smw_jump.ogg")

function smw_small_switch(node, matStackIndex)
    local m = geo_get_mario_state()
    local e = gPlayerSyncTable[m.playerIndex]
    local asSwitchNode = cast_graph_node(node)
    asSwitchNode.selectedCase = e.small_model_switch
end

function set_model_small(m)
    local e = gPlayerSyncTable[m.playerIndex]
    e.small_model_switch = MODEL_SMALL
    _G.charSelect.character_add_animations(E_MODEL_SMW, S_SMW_anims)
end

function set_model_big(m)
    local e = gPlayerSyncTable[m.playerIndex]
    e.small_model_switch = MODEL_BIG
    _G.charSelect.character_add_animations(E_MODEL_SMW, SMW_anims)
end

function set_model_growing(m)
    local e = gPlayerSyncTable[m.playerIndex]
    e.small_model_switch = MODEL_BIG
    m.marioObj.header.gfx.scale.y = 0.85
    _G.charSelect.character_add_animations(E_MODEL_SMW, SMW_anims)
end

function update_standing(m)
    if (perform_ground_step(m) == GROUND_STEP_LEFT_GROUND) then
        set_mario_action(m, ACT_FREEFALL, 0)
    end
end

function anim_power_or_damage(m, sound, add, power_anim)
    local e = gPlayerSyncTable[m.playerIndex]
    audio_sample_play(sound, m.pos, 5)
    e.size_state = e.size_state + add
    e.prev_forward_speed = m.forwardVel
    vec3f_copy(e.prev_speed, m.vel)
    e.power_anim = power_anim
end

function damage_smw(m)
    local e = gPlayerSyncTable[m.playerIndex]
    if e.anim_timer == 0 then
        e.coin_count = 0
        if e.size_state == SIZESTATE_SMALL then
            set_mario_action(m, ACT_STANDING_DEATH, 0)
        elseif e.power_state ~= POWERSTATE_NORMAL then
            --play damage animation
            anim_power_or_damage(m, DAMAGE, 0, 3)
            e.power_state = POWERSTATE_NORMAL
        else
            anim_power_or_damage(m, DAMAGE, -1, 2)
        end
    end
end

function heal_smw(m)
    local e = gPlayerSyncTable[m.playerIndex]
    if e.anim_timer == 0 then
        e.coin_count = 0
        if e.size_state == SIZESTATE_BIG then
            anim_power_or_damage(m, ITEM, 0, 0)
        else
            anim_power_or_damage(m, POWER, 1, 1)
        end
    end
end

function power_smw(m, power_type)
    local e = gPlayerSyncTable[m.playerIndex]
    e.coin_count = 0
    if e.power_state == power_type then
        anim_power_or_damage(m, ITEM, 0, 0)
        --djui_chat_message_create("SIZESTATE (power) = " .. e.size_state)
        --djui_chat_message_create("POWERSTATE (power) = " .. e.power_state)
    end
    if e.power_state ~= power_type then
        e.power_state = power_type
        anim_power_or_damage(m, POWER, 1, 3)
        --djui_chat_message_create("SIZESTATE (power) = " .. e.size_state)
        --djui_chat_message_create("POWERSTATE (power) = " .. e.power_state)
    end
end

function smw_size(m)
    local e = gPlayerSyncTable[m.playerIndex]

    if e.size_state == SIZESTATE_SMALL then
        if e.power_anim == 0 then
            set_model_small(m)
        end
    else
        if e.size_state == SIZESTATE_BIG then
            if e.power_anim == 0 then
                set_model_big(m)
            end
        end
    end
    if e.power_state ~= POWERSTATE_NORMAL then
        if e.power_anim == 0 then
            m.marioObj.header.gfx.scale.y = 1.3
        end
    end
end

function s16(x)
    x = (math.floor(x) & 0xFFFF)
    if x >= 32768 then return x - 65536 end
    return x
end

function s32(x)
    x = (math.floor(x) & 0xFFFFFFFF)
    if x >= 2147483648 then return x - 4294967296 end
    return x
end

function smw_anim_walk(m)
    local val14 = 0
    local val04 = 0.0

    if (m.intendedMag > m.forwardVel) then
        val04 = m.intendedMag
    else
        val04 = m.forwardVel
    end
    if (val04 < 4.0) then
        val04 = 4.0
    end
    if m.actionState == 1 then
        val14 = s32(val04 / 3.0 * 0x10000)
        set_character_anim_with_accel(m, CHAR_ANIM_RUNNING, val14)
    elseif m.actionState == 2 then
        val14 = s32(val04 / 3.5 * 0x10000)
        set_character_anim_with_accel(m, CHAR_ANIM_RUNNING_UNUSED, val14)
    else
        val14 = s32(val04 / 5.0 * 0x10000)
        set_character_anim_with_accel(m, CHAR_ANIM_RUNNING, val14)
    end
end

function check_b_for_pspeed(m)
    local e = gPlayerSyncTable[m.playerIndex]

    if (m.controller.buttonDown & B_BUTTON ~= 0) and (m.forwardVel > 18) then
        e.pspeed = e.pspeed + 1
    else
        e.pspeed = e.pspeed - 2
    end

    if e.pspeed > 55 then
        e.pcheck = true
    else
        e.pcheck = false
    end
end

function pspeed_remove(m)
    local e = gPlayerSyncTable[m.playerIndex]
    e.pspeed = 0
end

function smw_update_walking_speed(m)
    local e = gPlayerSyncTable[m.playerIndex]

    local maxTargetSpeed;
    local targetSpeed;

    check_b_for_pspeed(m)

    if (m.controller.buttonDown & B_BUTTON ~= 0) then
        if e.pspeed >= 55 then
            maxTargetSpeed = 18 * 2.3
            m.actionState = 2
        else
            maxTargetSpeed = 18 * 1.7
            m.actionState = 1
        end
    else
        m.actionState = 0
        maxTargetSpeed = 18
    end

    targetSpeed = maxTargetSpeed


    if (m.quicksandDepth > 10.0) then
        targetSpeed = targetSpeed * 6.25 / m.quicksandDepth;
    end

    if (m.forwardVel <= 0.0) then
        m.forwardVel = m.forwardVel + 1.1;
    elseif (m.forwardVel <= targetSpeed) then
        m.forwardVel = m.forwardVel + 1
    elseif (m.floor ~= nil and m.floor.normal.y >= 0.95) then
        m.forwardVel = m.forwardVel - 1.0;
    end
    if (m.forwardVel > 100.0) then
        m.forwardVel = 100.0;
    end

    m.faceAngle.y = m.intendedYaw - approach_s32(s16(m.intendedYaw - m.faceAngle.y), 0, 0x800, 0x800)
    apply_slope_accel(m);
end

function smw_idle_cancels(m)
    mario_drop_held_object(m);

    if (m.floor and m.floor.normal.y < 0.29237169) then
        return mario_push_off_steep_floor(m, ACT_SMW_FALL, 0);
    end

    if (m.input & INPUT_A_PRESSED) ~= 0 then
        return set_jumping_action(m, ACT_SMW_JUMP, 0);
    end

    if (m.input & INPUT_OFF_FLOOR) ~= 0 then
        return set_mario_action(m, ACT_SMW_FALL, 0);
    end

    if (m.input & INPUT_ABOVE_SLIDE) ~= 0 then
        return set_mario_action(m, ACT_SMW_SLIDE, 0);
    end

    if (m.input & INPUT_FIRST_PERSON) ~= 0 then
        return set_mario_action(m, ACT_FIRST_PERSON, 0);
    end

    if (m.input & INPUT_NONZERO_ANALOG) ~= 0 then
        m.faceAngle.y = s16(m.intendedYaw)
        return set_mario_action(m, ACT_SMW_WALKING, 0);
    else
        m.vel.x = 0
        m.vel.z = 0
        m.vel.y = 0
        m.forwardVel = 0
    end

    if (m.input & INPUT_Z_DOWN) ~= 0 then
        return set_mario_action(m, ACT_SMW_CROUCH, 0);
    end

    return false
end

function smw_update_air_without_turn(m)
    local sidewaysSpeed = 0.0
    local dragThreshold = 23.0
    local intendedDYaw;
    local intendedMag;

    m.forwardVel = approach_f32(m.forwardVel, 0.0, 0.35, 0.35);

    if (m.controller.buttonDown & B_BUTTON ~= 0) then
        if e.pspeed >= 55 then
            dragThreshold = 18 * 2.3
        else
            dragThreshold = 18 * 1.7
        end
    else
        dragThreshold = 18
    end

    if (m.input & INPUT_NONZERO_ANALOG) then
        intendedDYaw = m.intendedYaw - m.faceAngle.y;
        intendedMag = m.intendedMag / 23.0

        m.forwardVel = m.forwardVel + intendedMag * coss(intendedDYaw) * 1.5
        sidewaysSpeed = intendedMag * sins(intendedDYaw) * 10.0
    end


    if (m.forwardVel > dragThreshold) then
        m.forwardVel = m.forwardVel - 1.5
    end
    if (m.forwardVel < -16.0 and m.forwardVel < dragThreshold) then
        m.forwardVel = m.forwardVel + 2.0
    end

    m.slideVelX = m.forwardVel * sins(m.faceAngle.y)
    m.slideVelZ = m.forwardVel * coss(m.faceAngle.y)

    m.slideVelX = m.slideVelX + sidewaysSpeed * sins(m.faceAngle.y + 0x4000);
    m.slideVelZ = m.slideVelZ + sidewaysSpeed * coss(m.faceAngle.y + 0x4000);

    m.vel.x = m.slideVelX;
    m.vel.z = m.slideVelZ;
end

function smw_common_air_action_step(m, landAction, animation, fallanimation, pjumpanimation, stepArg)
    local stepResult;
    local e = gPlayerSyncTable[m.playerIndex]
    smw_update_air_without_turn(m);

    stepResult = perform_air_step(m, stepArg);
    if (m.action == ACT_BUBBLED and stepResult == AIR_STEP_HIT_LAVA_WALL) then
        stepResult = AIR_STEP_HIT_WALL
    end

    if stepResult == AIR_STEP_NONE then
        if m.prevAction == ACT_SMW_WALKING and e.pcheck then
            set_character_animation(m, pjumpanimation);
        else
            if m.vel.y > 0.0 then
                set_character_animation(m, animation);
            else
                set_character_animation(m, fallanimation);
            end
        end
    elseif stepResult == AIR_STEP_LANDED then
        set_mario_action(m, landAction, 0);
    elseif stepResult == AIR_STEP_HIT_WALL then
        if m.forwardVel > 0 then
            m.forwardVel = m.forwardVel / 2
        end
    elseif stepResult == AIR_STEP_HIT_LAVA_WALL then
        damage_smw(m)
    end

    return stepResult
end

function interact_w_door(m)
    local wdoor = obj_get_nearest_object_with_behavior_id(m.marioObj, id_bhvDoorWarp)
    local door = obj_get_nearest_object_with_behavior_id(m.marioObj, id_bhvDoor)
    local sdoor = obj_get_nearest_object_with_behavior_id(m.marioObj, id_bhvStarDoor)

    if door ~= nil and dist_between_objects(m.marioObj, door) < 150 then
        interact_door(m, 0, door)
        --djui_chat_message_create("door.")
        if door.oAction == 0 then
            if (should_push_or_pull_door(m, door) & 1) ~= 0 then
                door.oInteractStatus = 0x00010000
            else
                door.oInteractStatus = 0x00020000
            end
        end
    elseif sdoor ~= nil and dist_between_objects(m.marioObj, sdoor) < 150 then
        interact_door(m, 0, sdoor)
        --djui_chat_message_create("star door.")
        if sdoor.oAction == 0 then
            if (should_push_or_pull_door(m, sdoor) & 1) ~= 0 then
                sdoor.oInteractStatus = 0x00010000
            else
                sdoor.oInteractStatus = 0x00020000
            end
        end
    elseif wdoor ~= nil and dist_between_objects(m.marioObj, wdoor) < 150 then
        interact_warp_door(m, 0, wdoor)
        set_mario_action(m, ACT_DECELERATING, 0)
        --djui_chat_message_create("warp door.")
        if wdoor.oAction == 0 then
            if (should_push_or_pull_door(m, wdoor) & 1) ~= 0 then
                wdoor.oInteractStatus = 0x00010000
            else
                wdoor.oInteractStatus = 0x00020000
            end
        end
    end
end
