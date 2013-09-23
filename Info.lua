return {
  --LrInitPlugin = "Init.lua",
  --LrPluginInfoProvider = "Manager.lua",
  LrLibraryMenuItems = {
	{
	  title = "$$$/Menu/RenameFolder=&Rename selected Folder(s)",
      file = "RenameFolder.lua"
	}
  },
  LrHelpMenuItems = {
    {
      title = LOC("$$$/Menu/Help=On-Line Help..."),
      file = "Help.lua"
    }
  },
  LrPluginName = "$$$/Menu/PluginNameDebug=FolderRename",
  LrSdkVersion = 4,
  LrSdkMinimumVersion = 1.3,
  LrToolkitIdentifier = "RenameFolder",
  LrPluginInfoUrl = "www.google.com",
  VERSION = {
    major = 0,
    minor = 0,
    revision = 1,
    display = "0.0.1 (June 2013)"
  },
  LrForceInitPlugin = true
}


--[[

LrFileUtils
LrFolder

]]