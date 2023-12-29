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
