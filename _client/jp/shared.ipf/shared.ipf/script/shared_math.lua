-- shared_math.lua


-- x,y,z 에서 radius만큼 떨어진 원의 좌표를 360/interval 간격으로 반환
function GET_AROUND_POS_CIRCLE(x, y, z, radius, interval)
    local pos = {}
    local count = math.floor(360 / interval)    
    for i = 1, interval do
        local angle = i * count
        angle = DegToRad(angle)
        local x1 = math.cos(angle) * radius
        local z1 = math.sin(angle) * radius   
        table.insert(pos, {x + x1, y, z + z1})
    end

    return pos
end


function GET_AROUND_POS_BY_CIRCLE_ANGLE_LIST(x, y, z, radius, angle_list)
    local pos = {}
    local count = #angle_list
    for i = 1, count do
        local angle = angle_list[i]
        angle = DegToRad(angle)
        local x1 = math.cos(angle) * radius
        local z1 = math.sin(angle) * radius   
        table.insert(pos, {x + x1, y, z + z1})
    end

    return pos
end

function GET_AROUND_POS_BY_ANGLE(x, y, z, radius, angle)
    angle = DegToRad(angle)
    local x1 = math.cos(angle) * radius
    local z1 = math.sin(angle) * radius   
    return x + x1, y, z + z1    
end

-- from_x, from_z, to_x, to_z
-- 바라보는 각도
function GET_DIRECTION_DEGREE(from_x, from_z, to_x, to_z)
    local angle = DirToAngle(to_x - from_x, to_z - from_z)
    return angle    
end

-- start_time (시작한 imcTime.GetAppTime())
-- now_time (현재 imcTime.GetAppTime())
-- sec(한바퀴 회전하는데 걸리는 시간)
-- x, y, z 중점에서 radius 만큼 떨어져 sec당 360도 회전할때, 
-- 경과한 시간(now_time - start_time)을 기준으로 현재 지점을 시뮬레이션한 좌표를 가져온다.
-- dir_angle - 시작할 바라보는 각도(pc가 바라보는 방향)
function GET_AROUND_CIRCLE_SPIN_POS(x, y, z, dir_angle, radius, sec, start_time, now_time)    
    local diff = math.fmod((now_time - start_time), sec)
    local diff = diff / sec    
    local angle = 360 * diff + dir_angle
    local x1, y1, z1 = GET_AROUND_POS_BY_ANGLE(x, y, z, radius, angle)
    return x1, y1, z1
end
