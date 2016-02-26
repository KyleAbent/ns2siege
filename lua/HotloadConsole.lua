// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua/HotloadConsole.lua
//
// Created by Mats Olsson (mats.olsson@matsotech.se)
//
// -----------------------------------
//
// Convinience file to use when programming/debugging in lua, without having to restart the
// server. Any file can be used as a hotloading file, there is nothing special about this
// file. But it is a good place to write the documentation for how hotloading can be made
// to work.
//
// Hotloading in Spark is used to allow hotloading of all kinds of resources, such as models,
// shaders, materials etc.
// 
// It is also used for lua files, but just reloading a file in lua does not usually work - many
// times a lua file is intended to be loaded only once (it contains one-time only setup code),
// so reloading them causes all kinds of weird things to happen.
//
// However, it is possible to use hotloading as a way of having a runtime lua console where you
// can execute commands to inspect and modify the lua state. You have access to all of the 
// lua code, so it pretty much allows you to do anything you want.
//
// The HotloadTools (ht) module contains a lot of convinient methods to manipulate entities
// and classes, including the ability to replace the implementation of Mixin methods and
// class methods, even inside the currently active entities.
//
// Examples:
// * make all Eggs jump 2m into the air
// ht.ForAll("Egg", function (self) self:SetOrigin(self:GetOrigin() + Vector(0,2,0))

// With the HotloadTools (ht), you can even replace methods in active objects and classes.
//
// This allows you to debug/test/develop code in the console, without having to restarting the
// server.
//
// Examples:
// * Move all skulks 2m upwards
// if Server then
//    ht.ForAll("Skulk", function(self) self:SetOrigin(self:GetOrigin() + Vector(0,2,0)) end)
// end
// 
// Notice the "if Server then" guard - changes to the hotload console is done in three different
// lua VMs; Server, Client and Predict. Anything done to change the state of an object should only
// be done on the server - though doing it in all three isn't fatal, will cause a bit of hitching
// as the server change comes in and overrides what the Predict/Client world has been doing.
//
// * Turn off the brains for a skulk bot (useful for when you want the to stand still)
// ht.Replace("SkulkBrain", "GetActions", function(self) return {} end )
// 
// Notice; this time we are changing code, so do it in all three VMs. The replacing is done
// in any future users of SkulkBrain as well as all current users. ht.ReplaceStatic replaces
// it in future instances only (ie, it changes the class files)
//
// * Restore their brains
// ht.Restore("SkulkBrain", "GetActions")
//
// * Add a log message when a user of the JumpMoveMixin jumps
// local function LoggedJumpMoveMixin(self, input, velocity)
//     ht.original["JumpMoveMixin"]["DoJump"](self, input, velocity);
//     Log("%s has jumped", self)
// end
// ht.Replace("JumpMoveMixin", "DoJump", LoggedJumpMoveMixin)
// 
// Notice that all replaced original functions are available in the ht.original[classOrMixinName][functionName]
// 
// * Restore the original
// ht.Restore("JumpMoveMixin", "DoJump")
// 
// See HotloadTools for more tools 
Script.Load("lua/HotloadTools.lua")

// just a guard to to allow easy console disabling.
if true then
  
--- add your code here

if Client then

end -- Client


--- end your code 
end
