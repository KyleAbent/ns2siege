
//----------------------------------------
//  
//----------------------------------------
class "Event"

function Event:Initialize()
    self.handlers = {}
end

function Event:AddHandler(key, handleFunc)
    self.handlers[key] = handleFunc
end

function Event:RemoveHandler(key)
    self.handlers[key] = nil
end

function Event:Trigger(params)

    for key,handler in pairs(self.handlers) do
        assert( handler ~= nil )
        handler(params)
    end

end

