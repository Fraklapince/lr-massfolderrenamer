local LrDialogs = import "LrDialogs"
local LrFunctionContext = import "LrFunctionContext"
local LrView = import "LrView"
local LrApp = import "LrApplication"
local LrTasks = import "LrTasks"
local LrBinding = import "LrBinding"

local cat = LrApp.activeCatalog()
local bind = LrView.bind -- shortcut for bind() method

local FolderList = {}
local properties -- mage global

local LrLogger = import "LrLogger"
local log = LrLogger("libraryLogger")	-- in myDocuments/libraryLogger;log
log:enable("logfile")

function getCurrentFolders()
	
	
	local StrFolderList = ""
	
    for i, folder in pairs(cat:getActiveSources()) do
		if folder ~= cat.kAllPhotos 
			and folder ~= cat.kQuickCollectionIdentifier
			and folder ~= cat.kPreviousImport
			and folder ~= cat.kTemporaryImages
			and folder ~= cat.kLastCatalogExport
			and folder ~= cat.kTargetCollection
		then
			if folder:type() == "LrFolder" then
				FolderList[#FolderList+1] = folder
				StrFolderList = StrFolderList .. folder:getName() .. ": ".. folder:type() .."\r\n"
			end
		end
	end
	LrDialogs.message("getActiveSources() : \r\n" .. #FolderList .."Folder(s) \r\n".. StrFolderList)
	log:trace("getActiveSources() : \r\n" .. #FolderList .."Folder(s) \r\n".. StrFolderList)
	
	-- add 06/09 in refer to http://forums.adobe.com/thread/1017029
	LrTasks.startAsyncTask(function()
		showCustomDialog()
		--LrFunctionContext.callWithContext( 'RenameDialog', RenameDialogBox)
	end)
	
end

function showCustomDialog()
	LrFunctionContext.callWithContext( 'RenameDialog', RenameDialogBox)
end

function RenameDialogBox( context )
	local f = LrView.osFactory() -- obtain view factory
	
	--local properties = LrBinding.makePropertyTable( context ) -- make prop table
	properties = LrBinding.makePropertyTable( context ) -- make prop table
	
	-- create some keys with initial values
	properties.FolderListSrc = ""
	properties.FolderListDst = ""
	properties.RexExSearch = ".....(...).*"
	properties.RexExReplace = "%1"
	
	for i, folder in pairs(FolderList) do
		if properties.FolderListSrc ~= "" then
			properties.FolderListSrc = properties.FolderListSrc .. "\r"
		end
		properties.FolderListSrc = properties.FolderListSrc .. folder:getName();
	end
	
	UpdateDst()
	
	local content = f:column { -- define view hierarchy
		bind_to_object = properties, -- default bound table is the one we made
		spacing = f:control_spacing(),
		f:row{
			f:edit_field {
				height_in_lines = 10,	-- bind to the key value
				value = bind 'FolderListSrc',
				alignment = "left",
				enabled = false,
			},
			f:edit_field {
				height_in_lines = #FolderList,	-- bind to the key value
				value = bind 'FolderListDst',
				alignment = "left",
				enabled = false,
			},
		},
		f:row {
			f:static_text {
				title = "RegEx:",
				alignment = "right",
				width = LrView.share "label_width", -- the shared binding
			}, 
			f:edit_field {
				width_in_chars = 20,
				value = bind 'RexExSearch',
				immediate = false, -- update value w/every keystroke
				validate = UpdateDst,
				--[[
				validate = function( view, value )
					if #value > 0 then -- check length of entered text
						--properties.FolderListDst = properties.FolderListSrc .. value
						--ApplyPattern(value, properties.RexExReplace)
					else
						-- no input,
						properties.FolderListDst = properties.FolderListSrc
					end
					return true, value
				end
				]]
			},
		},
		f:row {
			f:static_text {
				title = "RegEx:",
				alignment = "right",
				width = LrView.share "label_width", -- the shared binding
			}, 
			f:edit_field {
				width_in_chars = 20,
				value = bind 'RexExReplace',
				immediate = false, -- update value w/every keystroke
				validate = UpdateDst,
				--[[
				validate = function( view, value )
					if #value > 0 then -- check length of entered text
						--properties.FolderListDst = properties.FolderListSrc .. value
						--ApplyPattern(properties.RexExSearch, value)
					else
						-- no input,
						properties.FolderListDst = properties.FolderListSrc
					end
					return true, value
				end
				]]
			},
		},
		f:row{
			f:push_button {
				title = "test",
				action = UpdateDst,
			},
		},
	}
	
	local result = LrDialogs.presentModalDialog( -- invoke the dialog
		{
			title = "Rename selected folders", 
			contents = content,
			actionVerb = "Rename",
			cancelVerb = "Cancel",
		} 
	)
	
	if result == 'ok' then -- action button was clicked
		LrDialogs.message("Rename Action")
	end
	
end 

function UpdateDst()
	--LrDialogs.message(" from " .. properties.RexExSearch .. " --> " .. properties.RexExReplace)
	--ApplyPattern(properties.RexExSearch, properties.RexExReplace)
	LrTasks.startAsyncTask(
		function()
			ApplyPattern(properties.RexExSearch, properties.RexExReplace)
			--LrFunctionContext.callWithContext( 'RenameDialog', 
			--function(context)
			--	ApplyPattern(properties.RexExSearch, properties.RexExReplace)
			--end)
		end
	)
	return true
end

function ApplyPattern(Pattern, Replace)
	
	--!!! passage par valeur, pas par ref ? !!!
	--LrDialogs.message("fct ApplyPattern")
	--log:trace("test");
	
	--LrDialogs.message("nb " .. #FolderList .. " : "  .. Pattern .. " --> " .. Replace .. ": " .. properties.FolderListDst .." in".. properties.FolderListSrc)
	--LrDialogs.message("nb " .. #FolderList)
	properties.FolderListDst = ""
	for i, folder in pairs(FolderList) do
		--LrDialogs.message("[".. i .."] pattern: ".. Pattern .." replace: ".. Replace )
		--LrDialogs.message("input: ".. FolderList[i]:type())
		--LrDialogs.message("input: ".. folder:type())
		--log:trace("input: ".. folder:getName())
		---LrDialogs.message("input: ".. folder:getName() .." --> ".. string.gsub(folder:getName(), Pattern, Replace))
		properties.FolderListDst = properties.FolderListDst .. string.gsub(folder:getName(), Pattern, Replace) .."\r"
		--properties.FolderListDst = properties.FolderListSrc .. Pattern .. Replace .."\r";
	end
end

LrTasks.startAsyncTask(getCurrentFolders)

