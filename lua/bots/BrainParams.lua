
class "BrainParams"

function BrainParams:Initialize(brainName)
    self.brainName = brainName
    self.param2values = {}
end

function BrainParams:Get(paramName, defaultValue)

    local value = self.param2values[paramName]

    if value == nil then
        return defaultValue
    else
        return value
    end

end

//----------------------------------------
//  maxRelativeAmount == 0.0 means no change, == 1.0 means a value could be set to 0 or doubled.
//----------------------------------------
function BrainParams:Mutate(maxRelativeAmount)

    for param, value in pairs(self.param2values) do
    
        local s = 1.0 + maxRelativeAmount*2*(math.random()-0.5)
        self.param2values[param] = value * s

    end

end

//----------------------------------------
//  
//----------------------------------------
function BrainParams:SetToAverage(p1, p2)

    self.param2values = {}

    for param, value in pairs(p1.param2values) do

        local v1 = value
        local v2 = p2.param2values[param]

        assert( v2 ~= nil )
        assert( type(v1) == "number" )
        assert( type(v2) == "number" )

        self.param2values[param] = (v1+v2) * 0.5;

    end

end

// TODO: Save load to disk or database, mutate
