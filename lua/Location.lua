// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Location.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// Represents a named location in a map, so players can see where they are.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Trigger.lua")

PrecacheAsset("materials/power/powered_decal.surface_shader")
local kPoweredDecalMaterial = PrecacheAsset("materials/power/powered_decal.material")
// local kUnpoweredDecalMaterial = PrecacheAsset("materials/power/unpowered_decal.material")

class 'Location' (Trigger)

Location.kMapName = "location"

local networkVars =
{
    showOnMinimap = "boolean",
    lasttime = "time",
    notapplied = "boolean",
}

Shared.PrecacheString("")

function Location:OnInitialized()

    Trigger.OnInitialized(self)
    
    // Precache name so we can use string index in entities
    Shared.PrecacheString(self.name)
    
    // Default to show.
    if self.showOnMinimap == nil then
        self.showOnMinimap = true
    end
    
    self:SetTriggerCollisionEnabled(true)
    
    self:SetPropagate(Entity.Propagate_Always)
    self:AddTimedCallback(Location.OnUpdate, 30)
    self.lasttime = 0
    self.notapplied = true
end

function Location:Reset()

end    

function Location:OnDestroy()

    Trigger.OnDestroy(self)
    
    if Client then
        self:HidePowerStatus()
    end

end

function Location:GetShowOnMinimap()
    return self.showOnMinimap
end
if Server then
function Location:GetIsSiege()
            local gameRules = GetGamerules()
            if gameRules then
               if gameRules:GetGameStarted() and gameRules:GetSiegeDoorsOpen() then 
                   return true
               end
            end
            return false
end
function Location:GetFront()
      //Siege 11.12 kyle abent =]
            local gameRules = GetGamerules()
            if gameRules then
               if gameRules:GetGameStarted() and gameRules:GetFrontDoorsOpen() then 
                   return true
               end
            end
            return false
end
    function Location:OnUpdate(deltaTime)
      //        Print("mainbattlecheck =", self.mainbattlecheck) //Print to veryify
              
      //   Print("check 1 complete") //Check complete. 
               //not when siege and only after front
       if self:GetIsSiege() or not self:GetFront() then return true end // Cancel and continue loop check
    //    Print("check 2 complete")
        
              //geneerate list
       local inrangeincombat = {}
       local combateersincombat = {}
          //triggermixin.lua get all within location
       local entities = self:GetEntitiesInTrigger()
       
            if table.count(entities) == 0 then
     //         Print("empty room")
              return true
            end
            
  //      Print("entities: %s", #entities)
       local combatentities = 0
       local eligable = {}
       
       for _, entity in ipairs(GetEntitiesWithMixin("Combat")) do
          combatentities = combatentities + 1
          if HasMixin(entity, "PowerConsumer") then entity.mainbattle = false end   
          
       if table.find(entities, entity) then // Only effect entities in this room
          local inCombat = (entity.timeLastDamageDealt + 30 > Shared.GetTime()) or (entity.lastTakenDamageTime + 30 > Shared.GetTime())
          if inCombat then
            table.insert(eligable, entity)
          end
       end
       
       
        end
        
             if table.count(eligable) == 0 then
    //          Print("empty eligabe room")
              return true
            end
            
        
    //   Print("combatentities; %s", combatentities)
    //   Print("eligable: %s", table.count(eligable) )
   //    Print("check 2 point 5 complete")
       

    
         self.notapplied = Shared.GetTime() > self.lasttime  + 25 //to make sure only one room is applied?
  if table.count(entities) >= (  table.count(eligable) * .51 ) and self.notapplied then   //To be eligable - contain 51% or more of the current 
    //Print("check 3 complete")
  
           //look for those who are in battle

       for _, entity in pairs(entities) do
         if HasMixin(entity, "PowerConsumer") then entity.mainbattle = true end
           Shared.ConsoleCommand("sh_zedtime")
           if entity:GetLocationName() then
           Print("room is %s", entity:GetLocationName())
           end
           entity:InsideMainRoom()
           if entity:isa("PowerPoint") then entity:SetMainRoom() end
           //CreateEntity(EtherealGate.kMapName, entity:GetOrigin(), 2)
       end
       
    //   Print("check 4 complete")
  end//
       

       
        self.lasttime = Shared.GetTime()
        return true // to continue loop check
    
    end
    function Location:OnTriggerEntered(entity, triggerEnt)
        ASSERT(self == triggerEnt)
        if entity.SetLocationName then
            //Log("%s enter loc %s ('%s') from '%s'", entity, self, self:GetName(), entity:GetLocationName())
            // only if we have no location do we set the location here
            // otherwise we wait until we exit the location to set it
            if not entity:GetLocationEntity() then
                entity:SetLocationName(triggerEnt:GetName())
                entity:SetLocationEntity(self)
            end
        end
            
    end
    
    function Location:OnTriggerExited(entity, triggerEnt)
        ASSERT(self == triggerEnt)
        if entity.SetLocationName then
            local enteredLoc = GetLocationForPoint(entity:GetOrigin(), self)
            local name = enteredLoc and enteredLoc:GetName() or ""
            //Log("%s exited location %s('%s'), entered '%s'", entity, self, self:GetName(), name)
            entity:SetLocationName(name)
            entity:SetLocationEntity(enteredLoc)
        end            
    end
end

// used for marine commander to show/hide power status in a location
if Client then

    function Location:ShowPowerStatus(powered)

        if not self.powerDecal then
            self.materialLoaded = nil  
        end

        if powered then
        
            if self.materialLoaded ~= "powered" then
            
                if self.powerDecal then
                    Client.DestroyRenderDecal(self.powerDecal)
                    Client.DestroyRenderMaterial(self.powerMaterial)
                end
                
                self.powerDecal = Client.CreateRenderDecal()

                local material = Client.CreateRenderMaterial()
                material:SetMaterial(kPoweredDecalMaterial)
        
                self.powerDecal:SetMaterial(material)
                self.materialLoaded = "powered"
                self.powerMaterial = material
                
            end

        else
            
            if self.powerDecal then
                Client.DestroyRenderDecal(self.powerDecal)
                Client.DestroyRenderMaterial(self.powerMaterial)
                self.powerDecal = nil
                self.powerMaterial = nil
                self.materialLoaded = nil
            end
            
            /*
            
            if self.materialLoaded ~= "unpowered" then
            
                if self.powerDecal then
                    Client.DestroyRenderDecal(self.powerDecal)
                end
                
                self.powerDecal = Client.CreateRenderDecal()
        
                self.powerDecal:SetMaterial(kUnpoweredDecalMaterial) 
                self.materialLoaded = "unpowered"
            
            end
            
            */
            
        end
        
    end

    function Location:HidePowerStatus()

        if self.powerDecal then
            Client.DestroyRenderDecal(self.powerDecal)
            Client.DestroyRenderMaterial(self.powerMaterial)
            self.powerDecal = nil
            self.powerMaterial = nil
        end

    end
    
    function Location:OnUpdateRender()
    
        PROFILE("Location:OnUpdateRender")
        
        local player = Client.GetLocalPlayer()      

        local showPowerStatus = player and player.GetShowPowerIndicator and player:GetShowPowerIndicator()
        local powerPoint

        if showPowerStatus then
            powerPoint = GetPowerPointForLocation(self.name)
            showPowerStatus = powerPoint ~= nil   
        end  
        
        if showPowerStatus then
                
            self:ShowPowerStatus(powerPoint:GetIsPowering())
            if self.powerDecal then
            
                // TODO: Doesn't need to be updated every frame, only setup on creation.
            
                local coords = self:GetCoords()
                local extents = self.scale * 0.2395
                extents.y = 10
                coords.origin.y = powerPoint:GetOrigin().y - 2
                
                // Get the origin in the object space of the decal.
                local osOrigin = coords:GetInverse():TransformPoint( powerPoint:GetOrigin() )
                self.powerMaterial:SetParameter("osOrigin", osOrigin)

                self.powerDecal:SetCoords(coords)
                self.powerDecal:SetExtents(extents)
                
            end
            
        else
            self:HidePowerStatus()
        end   
        
    end
    
end

Shared.LinkClassToMap("Location", Location.kMapName, networkVars)