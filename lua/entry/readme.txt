Introduction:

The NS2 ModLoader allows you to dynamically load your own Lua script via the so called
entry points.

The ModLoader is the first script loaded in all Lua VMs except of the GUIView VMs (this
includes the Loading and the Menu VM!).

Be aware that ModLoader.lua itself loads Utility.lua so you can use those basic help functions
inside your entry file.


Entry points:

Available default entry points:
	* Client : loaded after the Client VM has loaded up fully
	* Server:  loaded after the Server VM has loaded up fully
	* Predict: loaded after the Predict VM has loaded up fully
	* Shared: loaded prior to the above three entries
	* FileHooks: loaded directly after the ModLoader in all VMs

Each entry point can be used by multiple mods at once. The mod loading order is
defined by the Priority attribute.


Entry files:

The entries are set up by files with the .entry extension inside the lua/entry/ folder. The entry
file's name is taken as mod's name.

Entry files are handled as Lua scripts. The entry points are set up by declaring a global
modEntry table like this:

	modEntry = {
		Client = "lua/TestClient.lua",
		Server = "lua/TestServer.lua",
		Predict = "lua/TestPredict.lua",
		Shared = "lua/TestShared.lua",
		FileHooks = "lua/TestHooks.lua",
		Priority = 5
	}

Each of these entry values can also be nil. In case that Priority is nil the default value of 10 is
used.


API:

function ModLoader.GetLoadedModNames()
	returns an array containing all loaded mod names


function ModLoader.GetModInfo(modName)
	returns the entry table of the mod with the given modName

Available FileHook modes:
	* pre: Loads the mod script before the given file
	* post: Loads the mod script after the given file
	* halt: Prevents the given file from getting loaded (in this case also none of the other file hooks
	  is called!)
	* replace: Loads the mod script instead of the given file

function ModLoader.SetupFileHook( fileName, hookFileName, mode )
	Sets the given mod script at the path hookFileName up for the file at the fileName path using
	given FileHook mode
	
	returns
		boolean : whether or not the hook was completed successfully.
		string : error description in case the operation failed.

function ModLoader.RemoveFileHook( fileName, hookFileName, mode )
	Removes given mod script hookFileName as hook from the file fileName for given FileHook
	mode

	returns
		boolean : whether or not the hook was removed successfully.
		string : error description in case the operation failed.

ModLoader.GetFileHooks( fileName, mode )
	returns a list of all hook entries of the given file under the fileName path and given mode


Upgrading from the old entry system:

The old "modEntry as string" format is still supported. But it is recommended to use the new
table format so the ModLoader won't have to parse the string.

The current entry system is being loaded earlier than the previous one did, so any custom Lua
code present in the .entry file may break. It is recommended to move this code to the Shared
entry point.

Mods already using the entry system as designed will still work without issues.