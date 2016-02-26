// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\Mantis.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Shared.RegisterNetworkMessage("DisplayBug", { bugid = "integer" })
Shared.RegisterNetworkMessage("RefreshDisplayBug", { bugid = "integer" })

if Server then

    local function ForwardDisplayBug(client, data)
        Server.SendNetworkMessage("DisplayBug", data, true)
    end
    Server.HookNetworkMessage("DisplayBug", ForwardDisplayBug)
    
    local function ForwardRefreshDisplayBug(client, data)
        Server.SendNetworkMessage("RefreshDisplayBug", data, true)
    end
    Server.HookNetworkMessage("RefreshDisplayBug", ForwardRefreshDisplayBug)
    
end

if Client then

    Script.Load("lua/GUIMantis.lua")
    
    local kRequestURL = "http://mantisfeed.tsadb.com"
    local sessionId = nil
    local displayedBugId = nil
    local reportSent = PrecacheAsset("sound/NS2.fev/common/chat")
    local function ValidateResponse(response)
    
        if response then
        
            if response.loggedin and string.len(response.PHPSESSID) > 0 then
            
                sessionId = response.PHPSESSID
                return true, response.data, response.message
                
            else
                return false, response.data, response.message
            end
            
        end
        
        return false, nil, "Unknown"
        
    end
    
    local function RequestS3(responder)
    
        local function ValidateAndRespond(response)
        
            local valid, data, message = ValidateResponse(json.decode(response))
            if valid then
                responder(data)
            else
                Shared.Message("S3 request failed: " .. message)
            end
            
        end
        
        Shared.SendHTTPRequest(kRequestURL, "GET", { r = "livetest", PHPSESSID = sessionId }, ValidateAndRespond)
        
    end
    
    local function FindBugReport(data, bugId)
    
        for r = 1, #data.reports do
        
            local report = data.reports[r]
            if report.bugid == bugId then
                return report
            end
            
        end
        
        return nil
        
    end
    
    local function RefreshDisplay(responseData)
    
        if not displayedBugId then
            return
        end
        
        local function RefreshDisplayResponder(responseData)
        
            local bug = FindBugReport(responseData, tostring(displayedBugId))
        
            if not bug then
                return
            end

            -- Count up the votes.
            local accepts = 0
            local rejects = 0
            for f = 1, #bug.feedback do
            
                if bug.feedback[f].status == "0" then
                    rejects = rejects + 1
                else
                    accepts = accepts + 1
                end
                
            end

                DisplayMantisBug(bug.bugid, bug.summary, accepts, rejects)

        end
        RequestS3(RefreshDisplayResponder)
        
    end
    
    local function DisplayBug(data)
    
        if displayedBugId == data.bugid then

            displayedBugId = nil
            HideMantisBug()
            
        else
        
            displayedBugId = data.bugid
            RefreshDisplay()
            
        end
        
    end
    Client.HookNetworkMessage("DisplayBug", DisplayBug)
    
    local function RefreshDisplayBug(data)

        displayedBugId = data.bugid
        RefreshDisplay()
        
    end
    Client.HookNetworkMessage("RefreshDisplayBug", RefreshDisplayBug)
    
    local function ParseLoginResponse(response)
    
        local valid, data, message = ValidateResponse(json.decode(response))
        if valid then
            Shared.Message("Login Succeeded")
        else
            Shared.Message("Login Failed: " .. message)
        end
        
    end
    
    local function LoginToMantis(user, pass)
        Shared.SendHTTPRequest(kRequestURL, "GET", { r = "login", username = user, password = pass }, ParseLoginResponse)
    end
    Event.Hook("Console_mantis_login", LoginToMantis)
    
    local function RequestS3Response(data)
    
        for r = 1, #data.reports do
        
            local report = data.reports[r]
            Shared.Message(report.bugid .. " - " .. report.summary)
            
        end
        
    end
    
    local function DisplayBugResponse(bugId)
    
        return function(data)
        
            local bug = FindBugReport(data, bugId)
            if bug then
            
                Client.SendNetworkMessage("DisplayBug", { bugid = tonumber(bug.bugid) }, true)
                return
                
            end
            
        end
        
    end
    
    local function HandleRequestS3(bugId)
        RequestS3(bugId and DisplayBugResponse(bugId) or RequestS3Response)
    end
    Event.Hook("Console_mantis_s3", HandleRequestS3)
    
    local function FeedbackResponse(bugId)
   
        return function(responseData)
            Client.SendNetworkMessage("RefreshDisplayBug", { bugid = tonumber(bugId) }, true)
        end
        
    end
    
    local function HandleAccept(bugId)
    local message = "Report number " .. ToString(bugId) .. " accepted"
        Shared.SendHTTPRequest(kRequestURL, "GET", { r = "feedback", id = bugId, value = "accept", PHPSESSID = sessionId }, FeedbackResponse(bugId))
        Shared.ConsoleCommand("output " .. message)
        StartSoundEffect(reportSent)
    end
    Event.Hook("Console_mantis_accept", HandleAccept)
    Event.Hook("Console_accept", HandleAccept)
    Event.Hook("Console_ma", HandleAccept)
    
    local function HandleReject(bugId)
    local message = "Report number " .. ToString(bugId) .. " rejected"
        Shared.SendHTTPRequest(kRequestURL, "GET", { r = "feedback", id = bugId, value = "reject", PHPSESSID = sessionId }, FeedbackResponse(bugId))
        Shared.ConsoleCommand("output " .. message)
        StartSoundEffect(reportSent)
    end
    Event.Hook("Console_mantis_reject", HandleReject)
    Event.Hook("Console_reject", HandleReject)
    
end