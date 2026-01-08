--here the actions of maro




local function anim_scale(m)
    local e = gPlayerSyncTable[m.playerIndex]

    if e.power_anim ~= 0 then
        set_character_animation(m, CHAR_ANIM_A_POSE)
        m.action = m.action | ACT_FLAG_INTANGIBLE | ACT_FLAG_INVULNERABLE
    end

    if e.power_anim == 1 or e.power_anim == 2 or e.power_anim == 3 then
        e.anim_timer = e.anim_timer + 1
        if e.anim_timer == 1 then
            vec3f_copy(e.prev_pos, m.pos)
        end
        m.vel.x = 0
        m.vel.z = 0
        m.vel.y = 0
        m.forwardVel = 0
        if e.anim_timer >= 2 then
            vec3f_copy(m.pos, e.prev_pos)
        end
        if e.anim_timer > 37 then
            m.invincTimer = 50
        end
        if e.anim_timer > 38 then
            vec3f_copy(m.vel, e.prev_speed)
            m.forwardVel = e.prev_forward_speed
            e.anim_timer = 0
            e.power_anim = 0
        end
    end


    if e.power_anim == 1 then
        local grow_anim = {
            [17] = set_model_big,
            [16] = set_model_growing,
            [15] = set_model_big,
            [14] = set_model_growing,
            [13] = set_model_growing,
            [12] = set_model_big,
            [11] = set_model_growing,
            [10] = set_model_big,
            [9] = set_model_big,
            [8] = set_model_growing,
            [7] = set_model_small,
            [6] = set_model_growing,
            [5] = set_model_growing,
            [4] = set_model_small,
            [3] = set_model_growing,
            [2] = set_model_small,
            [1] = set_model_small,
            [0] = set_model_small,
        }
        local idx = math.floor(e.anim_timer / 2)

        if idx > 17 then idx = 17 end
        if idx < 0 then idx = 0 end

        if grow_anim[idx] and e.power_state == POWERSTATE_NORMAL then
            grow_anim[idx](m)
        end

        --[[
            if grow_anim[idx] then
        grow_anim[idx](m)
    end
        ]]
    end
    if e.power_anim == 2 then
        local damage_anim = {
            [0] = set_model_small,
            [1] = set_model_big,
            [2] = set_model_big,
            [3] = set_model_growing,
            [4] = set_model_growing,
            [5] = set_model_big,
            [6] = set_model_growing,
            [7] = set_model_big,
            [8] = set_model_big,
            [9] = set_model_growing,
            [10] = set_model_small,
            [11] = set_model_growing,
            [12] = set_model_growing,
            [13] = set_model_small,
            [14] = set_model_growing,
            [15] = set_model_small,
            [16] = set_model_small,
            [17] = set_model_small,
        }
        local idx = math.floor(e.anim_timer / 2)

        if idx > 17 then idx = 17 end
        if idx < 0 then idx = 0 end

        if damage_anim[idx] and e.power_state == POWERSTATE_NORMAL then
            damage_anim[idx](m)
        end
    end
end
hook_event(HOOK_MARIO_UPDATE, anim_scale)



ACT_SMW_IDLE = allocate_mario_action(ACT_GROUP_STATIONARY | ACT_FLAG_IDLE | ACT_FLAG_PAUSE_EXIT | ACT_FLAG_CUSTOM_ACTION)

local function act_smw_idle(m)
    smw_idle_cancels(m)

    pspeed_remove(m)

    update_standing(m)

    set_character_animation(m, CHAR_ANIM_FIRST_PERSON)
end

hook_mario_action(ACT_SMW_IDLE, act_smw_idle)


ACT_SMW_WALKING = allocate_mario_action(ACT_GROUP_MOVING | ACT_FLAG_MOVING | ACT_FLAG_CUSTOM_ACTION)

function act_smw_walking(m)
    interact_w_door(m)
    mario_drop_held_object(m);

    if (should_begin_sliding(m) ~= 0) then
        return set_mario_action(m, ACT_SMW_SLIDE, 0);
    end

    if (m.input & INPUT_FIRST_PERSON) ~= 0 then
        return set_mario_action(m, ACT_DECELERATING, 0);
    end

    if (m.input & INPUT_A_PRESSED) ~= 0 then
        set_mario_action(m, ACT_JUMP, 0);
    end

    if (m.input & INPUT_ZERO_MOVEMENT) ~= 0 then
        return set_mario_action(m, ACT_DECELERATING, 0);
    end

    if (analog_stick_held_back(m) ~= 0 and m.forwardVel >= 16.0) then
        return set_mario_action(m, ACT_SMW_TURNING, 0);
    end

    if (m.input & INPUT_Z_PRESSED) ~= 0 then
        return set_mario_action(m, ACT_SMW_CROUCH_SLIDE, 0);
    end

    smw_update_walking_speed(m);
    smw_anim_walk(m)
    goundstep = (perform_ground_step(m))
    if goundstep == GROUND_STEP_LEFT_GROUND then
        set_mario_action(m, ACT_FREEFALL, 0)
        set_character_animation(m, CHAR_ANIM_GENERAL_FALL);
    elseif goundstep == GROUND_STEP_HIT_WALL then
        m.forwardVel = 0;
        pspeed_remove(m)

        local val04 = 0.0

        if (m.intendedMag > m.forwardVel) then
            val04 = m.intendedMag
        else
            val04 = m.forwardVel
        end
        if (val04 < 4.0) then
            val04 = 4.0
        end
        val14 = s32(val04 / 10.0 * 0x10000)
        set_character_anim_with_accel(m, CHAR_ANIM_RUNNING, val14)
    end
end

hook_mario_action(ACT_SMW_WALKING, act_smw_walking)

ACT_SMW_JUMP = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_CONTROL_JUMP_HEIGHT | ACT_FLAG_MOVING | ACT_FLAG_AIR |
    ACT_FLAG_CUSTOM_ACTION)

function act_jump(m)
    if m.actionArg <= 0 then
        m.actionArg = 1;
        audio_sample_play(JUMP, m.marioObj.header.gfx.cameraToObject, 5);
        m.vel.y = 45 + (m.forwardVel / 4)
    end
    if m.prevAction == ACT_SMW_CROUCH or m.prevAction == ACT_SMW_CROUCH_SLIDE then
        if (m.input & INPUT_Z_DOWN) ~= 0 then
            smw_common_air_action_step(m, ACT_SMW_CROUCH_SLIDE, CHAR_ANIM_CROUCHING, CHAR_ANIM_CROUCHING,
                CHAR_ANIM_CROUCHING,
                AIR_STEP_NONE);
        else
            smw_common_air_action_step(m, ACT_SMW_WALKING, CHAR_ANIM_CROUCHING, CHAR_ANIM_CROUCHING, CHAR_ANIM_CROUCHING,
                AIR_STEP_NONE);
        end
    else
        smw_common_air_action_step(m, ACT_SMW_WALKING, CHAR_ANIM_SINGLE_JUMP, CHAR_ANIM_GENERAL_FALL,
            CHAR_ANIM_TRIPLE_JUMP, AIR_STEP_NONE);
    end
end

hook_mario_action(ACT_SMW_JUMP, act_jump)


ACT_SMW_FALL = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_MOVING | ACT_FLAG_AIR |
    ACT_FLAG_CUSTOM_ACTION)

function act_fall(m)
    if m.prevAction == ACT_SMW_CROUCH or m.prevAction == ACT_SMW_CROUCH_SLIDE then
        if (m.input & INPUT_Z_DOWN) ~= 0 then
            smw_common_air_action_step(m, ACT_SMW_CROUCH_SLIDE, CHAR_ANIM_CROUCHING, CHAR_ANIM_CROUCHING,
                CHAR_ANIM_CROUCHING,
                AIR_STEP_NONE);
        else
            smw_common_air_action_step(m, ACT_SMW_WALKING, CHAR_ANIM_CROUCHING, CHAR_ANIM_CROUCHING, CHAR_ANIM_CROUCHING,
                AIR_STEP_NONE);
        end
    else
        smw_common_air_action_step(m, ACT_SMW_WALKING, CHAR_ANIM_GENERAL_FALL, CHAR_ANIM_GENERAL_FALL,
            CHAR_ANIM_GENERAL_FALL,
            AIR_STEP_NONE);
    end
end

hook_mario_action(ACT_SMW_FALL, act_fall)

ACT_SMW_CROUCH = allocate_mario_action(ACT_GROUP_STATIONARY | ACT_FLAG_IDLE | ACT_FLAG_STATIONARY |ACT_FLAG_SHORT_HITBOX|
    ACT_FLAG_CUSTOM_ACTION)

function act_crouch(m)
    pspeed_remove(m)

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

    if (m.input & INPUT_Z_DOWN) == 0 then
        return set_mario_action(m, ACT_SMW_IDLE, 0);
    end

    m.vel.x = 0
    m.vel.z = 0
    m.vel.y = 0
    m.forwardVel = 0

    update_standing(m)

    set_character_animation(m, CHAR_ANIM_CROUCHING)
end

hook_mario_action(ACT_SMW_CROUCH, act_crouch)


ACT_SMW_CROUCH_SLIDE = allocate_mario_action(ACT_GROUP_MOVING | ACT_FLAG_MOVING | ACT_FLAG_SHORT_HITBOX |
    ACT_FLAG_CUSTOM_ACTION)

function act_smw_crouch_slide(m)
    local cancel;

    if (m.input & INPUT_ABOVE_SLIDE) ~= 0 then
        return set_mario_action(m, ACT_SMW_SLIDE, 0);
    end

    if (m.input & INPUT_A_PRESSED) ~= 0 then
        return set_jumping_action(m, ACT_SMW_JUMP, 0);
    end

    if (m.input & INPUT_Z_DOWN) == 0 then
        return set_mario_action(m, ACT_DECELERATING, 0);
    end

    cancel = common_slide_action_with_jump(m, ACT_SMW_CROUCH, ACT_SMW_JUMP, ACT_SMW_FALL,
        CHAR_ANIM_CROUCHING);
    return cancel;
end

hook_mario_action(ACT_SMW_CROUCH_SLIDE, act_smw_crouch_slide)

ACT_SMW_SLIDE = allocate_mario_action(ACT_GROUP_MOVING | ACT_FLAG_MOVING | ACT_FLAG_BUTT_OR_STOMACH_SLIDE |
    ACT_FLAG_CUSTOM_ACTION)

local function act_smw_slide(m)

    common_slide_action_with_jump(m, ACT_SMW_WALKING, ACT_SMW_JUMP, ACT_SMW_FALL, CHAR_ANIM_SLIDE)
end

hook_mario_action(ACT_SMW_SLIDE, act_smw_slide)



ACT_SMW_TURNING = allocate_mario_action(ACT_GROUP_MOVING | ACT_FLAG_MOVING  |
    ACT_FLAG_CUSTOM_ACTION)

local function act_smw_turning(m)
    if (m.input & INPUT_ABOVE_SLIDE) ~= 0 then
        return set_mario_action(m, ACT_SMW_SLIDE, 0);
    end

    if (m.input & INPUT_A_PRESSED) ~= 0 then
        return set_jumping_action(m, ACT_SMW_JUMP, 0);
    end

    if (m.input & INPUT_ZERO_MOVEMENT) ~= 0 then
        return set_mario_action(m, ACT_SMW_WALKING, 0);
    end

    if (apply_slope_decel(m, 2.0)) ~= 0 then
        return begin_walking_action(m, 8.0, ACT_FINISH_TURNING_AROUND, 0);
    end

    if m.actionTimer <= 3 then
        set_mario_particle_flags(m, PARTICLE_DUST, false)
    end
    if (perform_ground_step(m)) == GROUND_STEP_LEFT_GROUND then
        set_mario_action(m, ACT_SMW_FALL, 0)
    end

    if (m.forwardVel >= 18.0) then
        set_character_animation(m, CHAR_ANIM_TURNING_PART1);
    else
        set_character_animation(m, CHAR_ANIM_TURNING_PART2);
        if (is_anim_at_end(m)) ~= 0 then
            if (m.forwardVel > 0.0) then
                begin_walking_action(m, m.forwardVel, ACT_SMW_WALKING, 0);
            else
                begin_walking_action(m, 8.0, ACT_SMW_WALKING, 0);
            end
        end
    end
end

hook_mario_action(ACT_SMW_TURNING, act_smw_turning)

















-- used to prevent other characters to do smw actions
ACTIONS_SMW = {
    [ACT_SMW_IDLE] = true,
    [ACT_SMW_WALKING] = true,
    [ACT_SMW_JUMP] = true,
    [ACT_SMW_FALL] = true,
    [ACT_SMW_CROUCH] = true,
    [ACT_SMW_CROUCH_SLIDE] = true,
    [ACT_SMW_SLIDE] = true,
    [ACT_SMW_TURNING] = true,
}

-- actions that get replaced
smwActions = {
    [ACT_IDLE] = ACT_SMW_IDLE,
    [ACT_WALKING] = ACT_SMW_WALKING,
    [ACT_JUMP] = ACT_SMW_JUMP,
    [ACT_STEEP_JUMP] = ACT_SMW_JUMP,
    [ACT_DOUBLE_JUMP] = ACT_SMW_JUMP,
    [ACT_TRIPLE_JUMP] = ACT_SMW_JUMP,

    [ACT_SPAWN_NO_SPIN_AIRBORNE] = ACT_SMW_FALL,
    [ACT_SPAWN_SPIN_AIRBORNE] = ACT_SMW_FALL,
    [ACT_SPAWN_SPIN_LANDING] = ACT_SMW_FALL,
    [ACT_SPAWN_NO_SPIN_LANDING] = ACT_SMW_FALL,

    [ACT_CROUCH_SLIDE] = ACT_SMW_CROUCH_SLIDE,
    [ACT_CROUCHING] = ACT_SMW_CROUCH,
    [ACT_START_CROUCHING] = ACT_SMW_CROUCH,
    [ACT_STOP_CROUCHING] = ACT_SMW_CROUCH,

    [ACT_STOMACH_SLIDE] = ACT_SMW_SLIDE,
    [ACT_BUTT_SLIDE] = ACT_SMW_SLIDE,
    [ACT_DIVE_SLIDE] = ACT_SMW_SLIDE,
}

local function smw_acts_update(m, action)
    e = gPlayerSyncTable[m.playerIndex]
    if e.is_smw then
        if smwActions[m.action] ~= nil then
            m.action = smwActions[m.action]
        end
    end
end
hook_event(HOOK_ON_SET_MARIO_ACTION, smw_acts_update)
hook_event(HOOK_BEFORE_MARIO_UPDATE, smw_acts_update)



-- vanilla actions that smw can do
local SMWCanActions = {
    [ACT_DISAPPEARED] = true,
    [ACT_FINISH_TURNING_AROUND] = true,
    [ACT_CREDITS_CUTSCENE] = true,
    [ACT_SQUISHED] = true,
    [ACT_IN_CANNON] = true,
    [ACT_TELEPORT_FADE_OUT] = true,
    [ACT_TELEPORT_FADE_IN] = true,
    [ACT_PULLING_DOOR] = true,
    [ACT_PUSHING_DOOR] = true,
    [ACT_DECELERATING] = true,
    [ACT_DROWNING] = true,
    [ACT_AIR_THROW] = true,
    [ACT_SHOT_FROM_CANNON] = true,
    [ACT_FALL_AFTER_STAR_GRAB] = true,
    [ACT_STAR_DANCE_WATER] = true,
    [ACT_FIRST_PERSON] = true,
    [ACT_RIDING_SHELL_GROUND] = true,
    [ACT_RIDING_SHELL_FALL] = true,
    [ACT_RIDING_SHELL_JUMP] = true,
    [ACT_BEGIN_SLIDING] = true,
    [ACT_GRABBED] = true,
    [ACT_THROWN_FORWARD] = true,
    [ACT_THROWN_BACKWARD] = true,
    [ACT_RIDING_SHELL_FALL] = true,
    [ACT_RIDING_SHELL_JUMP] = true,
    [ACT_RIDING_SHELL_GROUND] = true,
    [ACT_BUBBLED] = true,
    [ACT_HOLD_DECELERATING] = true,
    [ACT_CREDITS_CUTSCENE] = true,
    [ACT_END_PEACH_CUTSCENE] = true,
    [ACT_GRAB_POLE_FAST] = true,
    [ACT_GRAB_POLE_SLOW] = true,
    [ACT_TWIRLING] = true,
}

local function onlysmw(m, action)
    if _G.charSelect.character_get_current_number(m.playerIndex) == CT_SMW then
        if m.playerIndex ~= 0 then
        else
            if (SMWCanActions[m.action] ~= true) and ((m.action & ACT_FLAG_CUSTOM_ACTION) == 0) and ((m.action & ACT_FLAG_METAL_WATER) == 0) and ((m.action & ACT_GROUP_CUTSCENE) == 0) and not _G.charSelect.is_menu_open() then
                -- elseif ((m.action & ACT_FLAG_SWIMMING) ~= 0) then
                --     set_mario_action(m, ACT_SMW_WATER, 0)
                if ((m.action & ACT_FLAG_IDLE) ~= 0) then
                    set_mario_action(m, ACT_SMW_WALKING, 0)
                else
                    set_mario_action(m, ACT_SMW_FALL, 0)
                end
            end
        end
    end
end
hook_event(HOOK_ON_SET_MARIO_ACTION, onlysmw)
hook_event(HOOK_BEFORE_MARIO_UPDATE, onlysmw)

