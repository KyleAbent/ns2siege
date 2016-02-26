// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//    
// lua\DissolveMixin.lua    
//    
//    Created by:   Max McGuire (max@unknownworlds.com)    
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local kDissolveSpeed = 1
local kDissolveDelay = 6

DissolveMixin = CreateMixin(DissolveMixin)
DissolveMixin.type = "Dissolve"

DissolveMixin.expectedMixins =
{
    Live = "Needed for GetIsAlive().",
    Model = "Needed for effects"
}

function DissolveMixin:__initmixin()
end

function DissolveMixin:OnInitialized()
    self.dissolveStart = nil
end

function DissolveMixin:OnKillClient()

    // Start the dissolve effect
    local now = Shared.GetTime()
    
    self.dissolveStart = now + kDissolveDelay
	self.dissolveAmount = 0
	
    self:InstanceMaterials()        

end

function DissolveMixin:OnUpdate( deltaTime )

    
	PROFILE("DissolveMixin:OnUpdate")
    
    local dissolveStart = self.dissolveStart
    
    if dissolveStart ~= nil then
    
        local model = self:GetRenderModel()
        
        if model then
			
            local now = Shared.GetTime()
			
            if now >= dissolveStart then
				
				self.dissolveAmount = math.min( 1, (now - dissolveStart) / kDissolveSpeed )
				
            end
            
        end

    end

end

function DissolveMixin:OnUpdateRender()
    
    PROFILE("DissolveMixin:OnUpdateRender")
	
	if self.dissolveAmount ~= nil then
		
		self:SetOpacity( 1 - self.dissolveAmount, "dissolve" )
	
	end
    
end