local U = {}

function U.color(r, g, b, a)
	return {r, g or r, b or r, a or 255}
end

function U.grey(level, a)
	return {level, level, level, a or 255}
end

function U.pointInRect(point, rect)
	return not (point.x > rect.x + rect.w or
		point.x < rect.x or
		point.y > rect.y + rect.h or
	point.y < rect.y)
end

function U.mouseInRect(rx, ry, rw, rh, mouseX, mouseY)
	return mouseX >= rx - rw / 2 and
	mouseX <= rx + rw / 2 and
	mouseY >= ry - rh / 2 and
	mouseY <= ry + rh / 2
end

function U.round(num)
	return math.floor(num + 0.5)
end

function U.reverse(arr)
	local i, j = 1, #arr

	while i < j do
		arr[i], arr[j] = arr[j], arr[i]

		i = i + 1
		j = j - 1
	end
end

function U.min(t)
  local min = math.huge
  for k,v in pairs(t) do
    if type(v) == 'number' then
      min = math.min(min, v)
    end
  end
  return min
end

function U.ParseCSVLine (line,sep)
	local res = {}
	local pos = 1
	sep = sep or ','
	while true do
		local c = string.sub(line,pos,pos)
		if (c == "") then break end
		if (c == '"') then
			-- quoted value (ignore separator within)
			local txt = ""
			repeat
				local startp,endp = string.find(line,'^%b""',pos)
				txt = txt..string.sub(line,startp+1,endp-1)
				pos = endp + 1
				c = string.sub(line,pos,pos)
				if (c == '"') then txt = txt..'"' end
				-- check first char AFTER quoted string, if it is another
				-- quoted string without separator, then append it
				-- this is the way to "escape" the quote char in a quote. example:
				--   value1,"blub""blip""boing",value3  will result in blub"blip"boing  for the middle
			until (c ~= '"')
			table.insert(res,txt)
			assert(c == sep or c == "")
			pos = pos + 1
		else
			-- no quotes used, just look for the first separator
			local startp,endp = string.find(line,sep,pos)
			if (startp) then
				table.insert(res,string.sub(line,pos,startp-1))
				pos = endp + 1
			else
				-- no separator found -> use rest of string and terminate
				table.insert(res,string.sub(line,pos))
				break
			end
		end
	end
	return res
end

function U.clone(t)
    if type(t) ~= "table" then return t end
    local meta = getmetatable(t)
    local target = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            target[k] = U.clone(v)
        else
            target[k] = v
        end
    end
    setmetatable(target, meta)
    return target
end

return U
