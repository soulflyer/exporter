script Aperture
  property parent : class "NSObject"
  property topFolders : {}
  --property p_script : "/bin/echo $HOME"
  property p_sql : "/usr/bin/sqlite3"
  property tempDatabase : "/tmp/Library.apdb"

--------------------------------------------------------------------------------------------------------------------
  on setup()
    set g_libPath to my libraryPath()
    log g_libPath
    set libPOSIX to POSIX path of g_libPath
    set libDBPOSIX to quoted form of (libPOSIX & "/Database/Library.apdb") as string
    set thescript to "cp " & libDBPOSIX & " /tmp"
    log thescript
    do shell script thescript
    log "copied database"
    return true
  end setup
  
--------------------------------------------------------------------------------------------------------------------
  on teardown()
    log "Cleaning up"
    set thescript to "rm /tmp/Library.apdb"
    log thescript
    do shell script thescript
    return true
  end teardown

--------------------------------------------------------------------------------------------------------------------
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

--------------------------------------------------------------------------------------------------------------------
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
--------------------------------------------------------------------------------------------------------------------
  on getAllProjects()
    set allYearRecords to {}
    set newItem to {}
    set defaults to current application's NSUserDefaults's standardUserDefaults()
    set thing to (defaults's objectForKey:"topFolders") as string
    set things to my splitString(thing, ",")
    set my topFolders to things
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
  
  to splitString(aString, delimiter)
		set retVal to {}
    set prevDelimiter to AppleScript's text item delimiters
    set AppleScript's text item delimiters to {delimiter}
    set retVal to every text item of aString
    set AppleScript's text item delimiters to prevDelimiter
    return retVal
  end splitString

--------------------------------------------------------------------------------------------------------------------
on setExportedDate(selectedPics)
		-- Make sure the modified time comes before the exported date
    set edate to (current date) + 1 * minutes
    set curyear to year of edate as string
    set curmonth to month of edate as string
    my logg:curmonth
    set curmonth to my monthToIntegerString:curmonth
    set curday to day of edate as string
    if length of curday is 1 then
      set curday to "0" & curday
    end if
    set curhour to hours of edate as string
    if length of curhour is 1 then
      set curhour to "0" & curhour
    end if
    set curmins to minutes of edate as string
    if length of curmins is 1 then
      set curmins to "0" & curmins
    end if
    set cursecs to seconds of edate as string
    if length of cursecs is 1 then
      set cursecs to "0" & cursecs
    end if
    set exportedDate to curyear & curmonth & curday & "T" & curhour & curmins & cursecs & "+07"
    log "Export date: " & exportedDate
    tell application "Aperture"
      repeat with pic in selectedPics
        tell pic
          (my logg:("setting export date of " & name))
          make new IPTC tag with properties {name:"ReferenceDate", value:exportedDate}
        end tell
      end repeat
    end tell
end setExportedDate

--------------------------------------------------------------------------------------------------------------------
on setUrgency(pr)
		tell application "Aperture"
      tell project pr
        -- Digikam uses Urgency to store the ratings, so convert Aperture rating to urgency
        tell (every image version where main rating is 5)
          make new IPTC tag with properties {name:"Urgency", value:"1"}
        end tell
        tell (every image version where main rating is 4)
          make new IPTC tag with properties {name:"Urgency", value:"2"}
        end tell
        tell (every image version where main rating is 3)
          make new IPTC tag with properties {name:"Urgency", value:"4"}
        end tell
        tell (every image version where main rating is 2)
          make new IPTC tag with properties {name:"Urgency", value:"5"}
        end tell
        tell (every image version where main rating is 1)
          make new IPTC tag with properties {name:"Urgency", value:"6"}
        end tell
      end tell
    end tell
end setUrgency

--------------------------------------------------------------------------------------------------------------------
on exportPics:theProjectPath toDirectory:theRootDirectory
  log "starting export: " & theProjectPath & " to " & theRootDirectory
  set theRootDirectory to theRootDirectory as string
  set fullsizePath to theRootDirectory & "/fullsize/" & theProjectPath
  set largePath to theRootDirectory & "/large/" & theProjectPath
  set mastersPath to theRootDirectory & "/masters/" & theProjectPath
  set thumbsPath to theRootDirectory & "/thumbs/" & theProjectPath
  set mediumPath to theRootDirectory & "/medium/" & theProjectPath
  set rootPath to theRootDirectory & "/" & theProjectPath
  set components to (current application's NSString's stringWithString:theProjectPath)
  log "components " & components
  set componentsArray to (current application's NSMutableArray)
  set componentsArray to (components's componentsSeparatedByString:"/")
  repeat with comp in componentsArray
    log "## " & comp
  end repeat
  log count of componentsArray
  log "********"
  if componentsArray's |count|() is 4 then
    log "!!!!!!!!!!!!!!!"
    set asComponents to componentsArray as list
    set theYear to item 2 of asComponents
    log "the year " & theYear
    set theMonth to item 3 of asComponents
    log "the month " & theMonth
    set theMonth to my integerToMonthString:theMonth
    log "the month " & theMonth
    set theProject to item 4 of asComponents
    log "the project " & theProject
    log "%%%%%%%%"
    
    my removeAndReplaceDir(thumbsPath)
    my removeAndReplaceDir(mediumPath)
    my removeAndReplaceDir(largePath)
    my removeAndReplaceDir(rootPath)
    my removeAndReplaceDir(fullsizePath)
    my removeAndReplaceDir(mastersPath)
    log "##########"
    tell application "Aperture"
      tell folder theYear
        tell folder theMonth
          tell project theProject
            set thescript to p_sql & " " & tempDatabase & " \"select note from RKNOTE where ATTACHEDTOUUID='" & id & "'\""
            tell current application
            log thescript
            
            set notes to do shell script thescript
            log "notes " & notes
            end tell
            set cursel to (every image version where (main rating is greater than 2) or (color label is red)) as list
            my setUrgency(theProject)
          end tell
        end tell
      end tell
    end tell
    log "@@@@@@@@@@@@@@@@@@"
    my doExport(cursel, thumbsPath, mediumPath, largePath, fullsizePath)
    log "^^^^^^^^^^^^"
    --my addLinks(cursel, mastersPath)
    set thescript to "echo \"" & notes & "\"> " & rootPath & "/notes.txt"
    log thescript
    do shell script thescript
    set thescript to "/Users/iain/bin/build-shoot-page " & rootPath
    log thescript
    do shell script thescript
  else
    (alert("Problem with path to project. Is it in yyyy/mm/dd-projname form?"))
  end if
  log "&&&&&&&&&&&&"
end exportPics:

--------------------------------------------------------------------------------------------------------------------
on removeAndReplaceDir(dirName)
		--my logg:("Removing previous versions in " & dirName)
    if my fileExists(POSIX path of dirName) then
      set thescript to "rm -r " & dirName
      do shell script thescript
    end if
    set thescript to "mkdir -p " & dirName
    do shell script thescript
end removeAndReplaceDir

--------------------------------------------------------------------------------------------------------------------
on exportP:selection toDirectory:thePath atSize:theExportSetting
  set tempPath to my getTempDir()
  tell application "Aperture"
    export selection naming files with file naming policy "Version Name" using export setting theExportSetting to tempPath
  end tell
  set thescript to "mv " & tempPath & "/* " & thePath & "/"
  log thescript
  do shell script thescript
  return true
end export

--------------------------------------------------------------------------------------------------------------------
on getTempDir()
  --make a temporary directory for the export to avoid apples ludicrous file renaming when file already exists
  set curyear to year of (current date) as string
  set curmonth to month of (current date) as string
  set curday to day of (current date) as string
  set curtime to time of (current date) as string
  set tempPath to "/tmp/" & curyear & curmonth & curday & curtime
  set thescript to "mkdir " & tempPath
  log thescript
  do shell script thescript
  return tempPath as string
end getTempDir

--------------------------------------------------------------------------------------------------------------------
on doExport(theSel, theThumbsPath, theMediumPath, theLargePath, theFullsizePath)

  set tempPath to my getTempDir()
  log "tempPath " & tempPath

  tell application "Aperture"
      export theSel naming files with file naming policy "Version Name" using export setting "JPEG - Thumbnail" to tempPath
      set thescript to "mv " & tempPath & "/* " & theThumbsPath & "/"
      do shell script thescript
      my logg:"Finished exporting thumbnails"
      export theSel naming files with file naming policy "Version Name" using export setting "JPEG - Fit within 1024 x 1024" to tempPath
      set thescript to "/Users/iain/bin/add-watermark " & tempPath & "/*.jpg "
      do shell script thescript
      set thescript to "mv " & tempPath & "/* " & theMediumPath
      do shell script thescript
      my logg:"Finished exporting mediums"
      export theSel naming files with file naming policy "Version Name" using export setting "JPEG - Fit within 2048 x 2048" to tempPath
      set thescript to "/Users/iain/bin/add-watermark " & tempPath & "/*.jpg "
      do shell script thescript
      set thescript to "mv " & tempPath & "/* " & theLargePath
      do shell script thescript
      my logg:"Finished exporting larges"
      export theSel naming files with file naming policy "Version Name" using export setting "JPEG - Original Size" to tempPath
      set thescript to "mv " & tempPath & "/* " & theFullsizePath
      do shell script thescript
      my logg:"Finished exporting fullsize"
    end tell
    
    my setExportedDate(theSel)
    
    set thescript to "rm -r " & tempPath
    log thescript
    do shell script thescript
end doExport

--------------------------------------------------------------------------------------------------------------------
on integerToMonthString:mN
		set monthss to {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"}
    return item mN of monthss
end integerToMonthString:

--------------------------------------------------------------------------------------------------------------------
on monthToIntegerString:mN
		if (mN is "Jan") or (mN is "jan") or (mN is "January") or (mN is "january") then
      return "01"
      else if (mN is "Feb") or (mN is "feb") or (mN is "February") or (mN is "february") then
      return "02"
      else if (mN is "Mar") or (mN is "mar") or (mN is "March") or (mN is "march") then
      return "03"
      else if (mN is "Apr") or (mN is "apr") or (mN is "April") or (mN is "april") then
      return "04"
      else if (mN is "May") or (mN is "may") then
      return "05"
      else if (mN is "Jun") or (mN is "jun") or (mN is "June") or (mN is "june") then
      return "06"
      else if (mN is "Jul") or (mN is "jul") or (mN is "July") or (mN is "july") then
      return "07"
      else if (mN is "Aug") or (mN is "aug") or (mN is "August") or (mN is "august") then
      return "08"
      else if (mN is "Sep") or (mN is "sep") or (mN is "September") or (mN is "september") then
      return "09"
      else if (mN is "Oct") or (mN is "oct") or (mN is "October") or (mN is "october") then
      return "10"
      else if (mN is "Nov") or (mN is "nov") or (mN is "November") or (mN is "november") then
      return "11"
      else if (mN is "Dec") or (mN is "dec") or (mN is "December") or (mN is "december") then
      return "12"
      else
      return mN
    end if
end monthToIntegerString:

--------------------------------------------------------------------------------------------------------------------
on fileExists(posixPath)
		return ((do shell script "if ls " & quoted form of posixPath & " &>/dev/null; then
    echo 1;
    else
    echo 0;
    fi") as integer) as boolean
end fileExists

--------------------------------------------------------------------------------------------------------------------
on logg:message
		tell current application
      log message
    end tell
end logg:

--------------------------------------------------------------------------------------------------------------------


end script