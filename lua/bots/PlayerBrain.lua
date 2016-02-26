
//----------------------------------------
//  Base class for bot brains
//----------------------------------------

Script.Load("lua/bots/BotUtils.lua")
Script.Load("lua/bots/BotDebug.lua")

gBotDebug:AddBoolean("debugall", false)

//----------------------------------------
//  Globals
//----------------------------------------

class 'PlayerBrain'

function PlayerBrain:Initialize()

    self.lastAction = nil

end

function PlayerBrain:GetShouldDebug(bot)

    //----------------------------------------
    //  This code is for Player-types, commanders should override this
    //----------------------------------------
    // If commander-selected, turn debug on
    local isSelected = bot:GetPlayer():GetIsSelected( kMarineTeamType ) or bot:GetPlayer():GetIsSelected( kAlienTeamType )

    if isSelected and gDebugSelectedBots then
        return true
    elseif self.targettedForDebug then
        return true
    else
        return false
    end

end

function PlayerBrain:Update(bot, move)
    PROFILE("BotPlayerBrain:Update")

    if gBotDebug:Get("spam") then
        Log("PlayerBrain:Update")
    end

    if not bot:GetPlayer():isa( self:GetExpectedPlayerClass() )
    or bot:GetPlayer():GetTeamNumber() ~= self:GetExpectedTeamNumber() then
        return
    end

    self.debug = self:GetShouldDebug(bot)

    if self.debug then
        DebugPrint("-- BEGIN BRAIN UPDATE, player name = %s --", bot:GetPlayer():GetName())
    end

    self.teamBrain = GetTeamBrain( bot:GetPlayer():GetTeamNumber() )

    local bestAction = nil

    // Prepare senses before action-evals use it
    assert( self:GetSenses() ~= nil )
    self:GetSenses():OnBeginFrame(bot)

    for actionNum, actionEval in ipairs( self:GetActions() ) do

        self:GetSenses():ResetDebugTrace()

        local action = actionEval(bot, self)
        assert( action.weight ~= nil )

        if self.debug then
            DebugPrint("weight(%s) = %0.2f. trace = %s",
                    action.name, action.weight, self:GetSenses():GetDebugTrace())
        end

        if bestAction == nil or action.weight > bestAction.weight then
            bestAction = action
        end
    end

    if bestAction ~= nil then
        if self.debug then
            DebugPrint("-- chose action: " .. bestAction.name)
        end

        bestAction.perform(move)
        self.lastAction = bestAction

        if self.debug or gBotDebug:Get("debugall") then
            Shared.DebugColor( 0, 1, 0, 1 )
            Shared.DebugText( bestAction.name, bot:GetPlayer():GetEyePos()+Vector(-1,0,0), 0.0 )
        end
    end

end

