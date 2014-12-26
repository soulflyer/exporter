script Aperture
	property parent : class "NSObject"
  property topFolders : {"2013", "2014"}
	
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
	
--	on topLevelFolders()
--		set returnValue to {}
--		tell application "Aperture"
--			--tell library "Aperture Library"
--			--log "hello"
--			set sels to every folder whose parent's name is "Aperture Library"
--      set sels to {"2013" , "2014"}
--			repeat with sel in sels
--        tell current application
--				log "sel: " & sel
--        end tell
--        set sel to (folder sel)
--				set selItem to {apertureID:(id of sel), apertureName:(name of sel), leaf:"false"}
--				set end of returnValue to selItem
--			end repeat
--			--end tell
--		end tell
--		return returnValue
--	end topLevelFolders
--	
  -----------------------------------------------------------------------------------------------------------------------
  on getAllProjects()
    set allYearRecords to {}
    set newItem to {}
    tell application "Aperture"
      repeat with yearName in my topFolders
        tell (folder yearName)
          set yearMonths to {}
          set allMonths to every folder
          repeat with thisMonth in allMonths
            set monthName to name of thisMonth
            tell thisMonth
              set monthProjects to {}
              set allProjects to every project
              repeat with thisProject in allProjects
                set newItem to {padding:"padding", projectName:(name of thisProject)}
                set end of monthProjects to newItem
              end repeat
            end tell
            set monthRecord to {monthName:(name of thisMonth), projectNames:monthProjects}
            set end of yearMonths to monthRecord
          end repeat
          set yearRecord to {yearName:yearName, |months|:yearMonths}
          set end of allYearRecords to yearRecord
        end tell
      end repeat
    end tell
    return allYearRecords
  end getAllProjects
  
end script