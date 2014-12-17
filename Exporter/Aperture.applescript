script Aperture
	property parent : class "NSObject"
	
	on libraryPath()
		tell application "System Events" to set p_libPath to value of property list item "LibraryPath" of property list file ((path to preferences as Unicode text) & "com.apple.Aperture.plist")
		if ((offset of "~" in p_libPath) is not 0) then
			set p_script to "/bin/echo $HOME"
			set p_homePath to (do shell script p_script)
			set p_offset to offset of "~" in p_libPath
			set p_path to text (p_offset + 1) thru -1 of p_libPath
			return p_homePath & p_path
		else
			return p_libPath
		end if
	end libraryPath
	
	on topLevelFolders()
		set returnValue to {}
		tell application "Aperture"
			set sels to every folder whose parent's name is "Aperture Library"
			repeat with sel in sels
				set end of returnValue to id of sel
			end repeat
		end tell
		return returnValue
	end topLevelFolders
	
	on getChildren:folderID
		set folderID to folderID as text
		--log folderID
		set returnValue to {}
		tell application "Aperture"
			set sels to every folder whose parent's id is folderID
			repeat with sel in sels
				set end of returnValue to id of sel
			end repeat
		end tell
		return returnValue
	end getChildren:
	
	on getFolderID()
		tell application "Aperture"
			set sels to every folder whose parent's name is "Aperture Library"
			set sel to first item of sels
		end tell
		set returnVal to id of sel
		return returnVal
	end getFolderID
	
	on getFolderName:folderID
		set folderID to folderID as text
		tell application "Aperture"
			set f to every folder whose id is folderID
			return name of first item of f
		end tell
	end getFolderName:
	
end script