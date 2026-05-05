-- hopefully this file remains small

local DW={}
Vectors.Dangerous_Windows=DW

local Default_table=	{
							["scale modificator"]=1
						}

local function Default_function(target)
	return Default_table[target]
end

local DW_meta={["__index"]=function() return Default_function end}
setmetatable(DW,DW_meta)

local IC_GetScale=InterfaceCore.GetScale
DW["SquaredAnchor"]=function(target)
	if(target=="scale modificator")
	then
		return IC_GetScale()
	end
	return nil
end
