
local verbose = false

//----------------------------------------
//  
//----------------------------------------
Script.Load("lua/bots/BrainSenses.lua")
local s = BrainSenses()
s:Initialize()
s:Add( "zzSum", function(db)
        local z = db:Get("z")
        local z = db:Get("z")
        return z+z
        end)
s:Add("x", function(db) return 1.0 end)
s:Add("y", function(db) return 2.0 end)
s:Add("z", function(db)
        local x = db:Get("x")
        local y = db:Get("y")
        return x*x+y*y
        end)

s:OnBeginFrame()
s:ResetDebugTrace()
s:Get("zzSum")
if verbose then DebugPrint("testing senses, trace: %s", s:GetDebugTrace() ) end
// do it again
s:ResetDebugTrace()
s:Get("zzSum")
if verbose then DebugPrint("testing senses again, trace: %s", s:GetDebugTrace() ) end

//----------------------------------------
//  
//----------------------------------------
AssertFloatEqual( 1.0, EvalLPF( 1.0, {{0,0}, {2,2}} ) )
AssertFloatEqual( 1.5, EvalLPF( 0.5, {{0,1}, {1,2}} ) )

//----------------------------------------
//  
//----------------------------------------
Script.Load("lua/bots/ManyToOne.lua")

local m2o = ManyToOne()
m2o:Initialize()

m2o:Assign("steve", "marines")
m2o:Assign("dushan", "marines")
m2o:Assign("max", "aliens")
m2o:Assign("brian", "aliens")
assert( m2o:GetNumAssignedTo("marines") == 2 )
assert( m2o:GetNumAssignedTo("aliens") == 2 )
if verbose then m2o:DebugDump() end

m2o:Assign("steve", "aliens")
assert( m2o:GetNumAssignedTo("marines") == 1 )
assert( m2o:GetNumAssignedTo("aliens") == 3 )
if verbose then m2o:DebugDump() end

m2o:Unassign("max")
m2o:Unassign("steve")
assert( m2o:GetNumAssignedTo("aliens") == 1 )
assert( m2o:GetNumAssignedTo("marines") == 1 )
if verbose then m2o:DebugDump() end

m2o:RemoveGroup("aliens")
if verbose then m2o:DebugDump() end
