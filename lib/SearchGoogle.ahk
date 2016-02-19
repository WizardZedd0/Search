; ======================= Function SearchGoogle: ==========================================
; Search Google - originally just for searching google, but was further expanded to youtube
;                 by using the /y option or putting "youtube" in the searchquery.
; searchQuery: The term to search for with any number of options at the beginning.
;       Options: to add an option type /(option)
;           /i  Images
;           /v  Videos
;           /s  Shop
;           /n  News
;           /d  Define
;           /t  Time Frame
;           /td     Last Day
;           /tw     Last Week
;           /tm     Last Month
;           /tmn    Last n Months
;           /ty     Last Year
;           /w(site)\   Does a site search
;           /y      Youtube
;           /r      Run First result (it finds)
; RunSearch: 
;       True launches the Search Link
; RunRes:
;       True launches the first link
; Returns: A list of links seperated by newlines(`n). The first link is to the search page.
; ==========================================================================================
SearchGoogle(searchQuery, runSearch:=true, runRes:=false)
{
   StringReplace, searchQuery, searchQuery, `r`n, %A_Space%, All
   option := getOption(searchQuery)
   while (option != space)
   {
      if (option = "/i")
         mode:="tbm=isch&"
      else if (option = "/v")
         mode:="tbm=vid&"
      else if (option = "/y")
         youtube:= true
      else if (option = "/r")
         runRes:=true
      else if (option = "/s")
         mode:="tmb=shop&"
      else if (option = "/n")
         mode:="tmb=nws&"
      else if (option = "/d")
         define := "define:"
      else if (instr(option, "/t") = 1)
         timeFrame:= "&as_qdr=" . substr(option, 3)
      else if (instr(option, "/w") = 1)
      {
         len:=instr(option, "\",, 3) - 3
         if(len > 0)
            asSiteSearch:= "&as_sitesearch=" . SubStr(option, 3, len)
      }
      option := getOption(searchQuery)
   }
   searchQuery:=formatStringForSearch(searchQuery)
      if youtube {
         searchURL=https://www.youtube.com/results?search_query=%searchQuery%
         className:="yt-lockup-title "
      } else {
      searchURL=http://www.google.com/search?%mode%q=%define%%searchQuery%%timeFrame%%asSiteSearch%
      className:="r"
      }
      ToolTip, Searching for %searchQuery% ... Please be patient.
      if(runSearch)
         run, %searchURL%
      ie:=ComObjCreate("InternetExplorer.Application")

      ie.Navigate(searchURL)
      while(ie.busy || ie.document.readyState !="complete")
         continue
      res:=ie.document.getElementsByClassName(className)
      list .= searchURL "`n"
      while(a_index < res.length, i:=a_index-1) {
         try    ; by chance it doesn't exist
            link:=res[i].firstElementChild.href
         catch {
         }
         if(!instr(link, "googleads") && !instr(link, list)) { ; no one likes an ad && no one wants a duplicate 
            if (first = "") {
               first:=link
            }
            list .= link "`n"
         }
      }
            ie.Quit()
      StringReplace, list, list, about:, http://www.google.com, All
   if runRes
      run, %first%
   Tooltip,
return list
}

formatStringForSearch(searchQuery)
{
   StringReplace, searchQuery, searchQuery, `%, `%25, All 
   StringReplace, searchQuery, searchQuery, #, `%23, All 
   StringReplace, searchQuery, searchQuery, &, `%26, All 
   return searchQuery
}

showGUIWithSearchBar(GUIName ="", Title="")
{
   global
   gui, %GUIName%: show ,, %Title%
   guicontrol, %GUIName%: focus, SearchText
   send {home}+{end}
}

includeSearchBar(GUIName = "", isUpdated=false)
{
   global SearchText
   static STHwnd
   gui, %GUIName%: add, ComboBox, w500 x10 hwndSTHwnd vSearchText gTestText, %Text%
   if(!isUpdated)
      addGraphicButton(MyPicButton, "lib\magnifyGlass.bmp", "default gGetText yp xp+505")
   else
      gui, %GUIName%: add, button, default gGetText yp xp+505, Search!
   return
TestText:
static curWin, curText, selectedIndex
static options = array()
Critical, off   ; Can interrupt
guicontrolget, SearchText, %a_gui%:, %a_guicontrol% ; SearchText
SendMessage 0x147, 0, 0,, ahk_id %STHwnd%  ; CB_GETCURSEL

if(errorlevel < 20) {  ; making selection
   if(selectedIndex:=errorlevel)  ; if not the first then save the text
      curText:=SearchText
   send {right}                     
   return           ; don't do anything else
} 
if(curText = SearchText)  ; don't do anything
   return
selectedIndex := ErrorLevel
curText:=SearchText
curWin:=WinActive()
static currentThread += 1
myThread:=currentThread
res:=manageSearch(SearchText)
total:="|" . SearchText . "||"
loop % res.Length() 
{
   if(SearchText != res[a_index])
      total .= res[a_index] "|"
   if(a_index > 10)
      break
}
if(myThread = currentThread) {   ; don't do anything if its not your not current
   guicontrol, %a_gui%:, SearchText, %total%
   control, ShowDropDown,,, ahk_id %STHwnd%
   setTimer, HideBox, 200

if(getkeystate("Shift", "P"))
      send {shift, up}
   send {right}
}
return
HideBox:
   winget, act, id, A
   if(act && curWin != act) {   ; window is not the active one
      control, HideDropDown,,, ahk_id %STHwnd%
      setTimer, HideBox, off
   }
return
GetText:
   GuiControlGet, SearchText, %a_gui%:, SearchText
   Clipboard = %SearchText%
   send {home}+{end}
   SearchGoogle(SearchText)
   manageSearch(SearchText, true)
return
}

manageSearch(search, put=false) {
   static searchRes := Array()
   while(getOption(search))
      continue
   if(searchRes.Length() < 1) {
      FileRead, res, %a_scriptdir%\CommonSearch.txt
      sort, res
      loop, parse, res, `n
         searchRes.push(A_LoopField)
   }
   if(put) {
      loop % searchRes.Length()
      {
         if(search = searchRes[a_index])
            return false
      }
      searchRes.push(search)
      FileAppend, `n%search%, %a_scriptdir%\CommonSearch.txt 
      return true
   } else {
      res:= Array()
      searchRes.cont
      loop % searchRes.Length() 
      {
         if(Regexmatch(searchRes[a_index], "i)" . search))
            res.push(searchRes[a_index])
      }
      return res
   }
}

getOption(byref text) 
{
   if(instr(text, "/") = 1)
   {
      if(instr(text, "/t") = 1)
         RegExMatch(text, "/t(d|w|m|y)\d?\d?", option)
      else if(instr(text, "/w") = 1)
      {
         RegExMatch(text, "/w\w*\\", optionRaw)
         RegExMatch(text, "/w\w*\.\w+.*\\", option)
         if(option = space)
         {
            MsgBox, Invalid option %optionRaw%
            StringReplace, text, text, %optionRaw%
         }
      }
      else
         option := substr(text, 1, 2)

      StringReplace, text, text, %option%
      return option
   } else if (pos:=instr(text, "Youtube")) {
      StringReplace, text, text, Youtube
      return "/y"
   }
   return
}

; ******************************************************************* 
; VariableName = variable name for the button 
; ImgPath = Path to the image to be displayed 
; Options = AutoHotkey button options (g label, button size, etc...) 
; bHeight = Image height (default = 32) 
; bWidth = Image width (default = 32) 
; ******************************************************************* 
; note: 
; - calling the function again with the same variable name will 
; modify the image on the button 
; ******************************************************************* 
AddGraphicButton(VariableName, ImgPath, Options="", bHeight=32, bWidth=32) 
{ 
Global 
Local ImgType, ImgType1, ImgPath0, ImgPath1, ImgPath2, hwndmode 
; BS_BITMAP := 128, IMAGE_BITMAP := 0, BS_ICON := 64, IMAGE_ICON := 1 
Static LR_LOADFROMFILE := 16 
Static BM_SETIMAGE := 247 
Static NULL 
SplitPath, ImgPath,,, ImgType1 
If ImgPath is float 
{ 
  ImgType1 := (SubStr(ImgPath, 1, 1)  = "0") ? "bmp" : "ico" 
  StringSplit, ImgPath, ImgPath,`. 
  %VariableName%_img := ImgPath2 
  hwndmode := true 
} 
ImgTYpe := (ImgType1 = "bmp") ? 128 : 64 
If (%VariableName%_img != "") AND !(hwndmode) 
  DllCall("DeleteObject", "UInt", %VariableName%_img) 
If (%VariableName%_hwnd = "") 
  Gui, Add, Button,  v%VariableName% hwnd%VariableName%_hwnd +%ImgTYpe% %Options% 
ImgType := (ImgType1 = "bmp") ? 0 : 1 
If !(hwndmode) 
  %VariableName%_img := DllCall("LoadImage", "UInt", NULL, "Str", ImgPath, "UInt", ImgType, "Int", bWidth, "Int", bHeight, "UInt", LR_LOADFROMFILE, "UInt") 
DllCall("SendMessage", "UInt", %VariableName%_hwnd, "UInt", BM_SETIMAGE, "UInt", ImgType,  "UInt", %VariableName%_img) 
Return, %VariableName%_img ; Return the handle to the image 
} 

