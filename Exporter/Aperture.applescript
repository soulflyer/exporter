script Aperture
  property parent :class "NSObject"
  
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
  end getLibrary
  
end