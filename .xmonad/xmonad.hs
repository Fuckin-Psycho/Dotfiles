-- Core
import XMonad
import System.Exit
import qualified XMonad.StackSet as W

-- Actions
import XMonad.Actions.CycleWS 
import XMonad.Actions.MouseResize
import XMonad.Actions.Promote 
import XMonad.Actions.WithAll 

-- Hooks
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks 
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP

-- Layouts
import XMonad.Layout.Grid
import XMonad.Layout.SimplestFloat
import XMonad.Layout.ResizableTile
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns

-- Layout modifiers
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.ShowWName
import XMonad.Layout.Spacing
import XMonad.Layout.WindowArranger
  
-- Utilites
import XMonad.Util.ClickableWorkspaces
import XMonad.Util.Cursor
import XMonad.Util.EZConfig
import XMonad.Util.SpawnOnce 

-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myTerminal :: String
myTerminal = "alacritty" 

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Whether clicking on a window to focus also passes the click to the window.
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
--
myBorderWidth :: Dimension
myBorderWidth = 2

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask = mod4Mask

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
myWorkspaces :: [String]
myWorkspaces = ["Dev","Web","Sys","Doc","VBox","Chat","Mus","Vid","GFX"]

-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor, myFocusedBorderColor :: String
myNormalBorderColor  = "#2D2A2E"
myFocusedBorderColor = "#66D9EF"

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys :: [(String, X ())]
myKeys = [ ("M-q", spawn "xmonad --recompile; xmonad --restart") -- Recompiles and restart XMonad
         , ("M-S-q", io exitSuccess) -- Quit XMonad
         
         -- Open my terminal
         , ("M-S-<Return>", spawn myTerminal)

         -- Run application launcher
         , ("M-p", spawn "rofi -show drun") 
        
         -- My applications
         , ("M-M1-b", spawn "librewolf")
         , ("M-M1-n", spawn "alacritty -e nvim")
         , ("M-M1-t", spawn "kotatogram-desktop")
         , ("M-M1-f", spawn "pcmanfm")
         , ("M-M1-k", spawn "keepassxc")
         
         -- Killing windows
         , ("M-S-c", kill) -- Kill the currently focused window
         , ("M-S-a", killAll) -- Kill all windows on current workspace

         -- Floating windows
         , ("M-t", withFocused $ windows . W.sink) -- Push floating window back to tile
         , ("M-S-t", sinkAll) -- Push ALL floating windows to tile
          
         -- Window navigation
         , ("M-m", windows W.focusMaster) -- Move focus to the master window
         , ("M-j", windows W.focusDown) -- Move focus to the next window
         , ("M-k", windows W.focusUp) -- Move focus to the prev window
         , ("M-S-j", windows W.swapDown) -- Swap focused window with next window
         , ("M-S-k", windows W.swapUp) -- Swap focused window with prev window
         , ("M-<Return>", promote) -- Moves the focused window to the master pane
         
         -- Workspaces
         , ("M-<Right>", nextWS) -- Switch to the next workspace
         , ("M-<Left>", prevWS) -- Switch to the previous workspace
         , ("M-S-<Right>", shiftToNext) -- Move the focused window to the next workspace
         , ("M-S-<Left>", shiftToPrev) -- Move the focused window to the previous workspace 
         , ("M-z", toggleWS) -- Toggle to the workspace displayed previously

         -- Layouts
         , ("M-<Space>", sendMessage NextLayout) -- Switch to next layout
         , ("M-b", sendMessage ToggleStruts) -- Toggle status bar gap

         -- Window resizing
         , ("M-h", sendMessage Shrink) -- Shrink horizontal window width
         , ("M-l", sendMessage Expand) -- Expand horizontal window width
         , ("M-C-j", sendMessage MirrorShrink) -- Shrink vertical window width
         , ("M-C-k", sendMessage MirrorExpand) -- Expand vertical window width
         
         -- Controls for moc music player.
         , ("M-u p", spawn "mocp --play")
         , ("M-u l", spawn "mocp --next")
         , ("M-u h", spawn "mocp --previous")
         , ("M-u <Space>", spawn "mocp --toggle-pause")
         
         -- Audio controls
         , ("<XF86AudioMute>", spawn "pactl set-sink-mute 0 toggle")  
         , ("<XF86AudioRaiseVolume>", spawn "pactl set-sink-volume 0 +5%")
         , ("<XF86AudioLowerVolume>", spawn "pactl set-sink-volume 0 -5%")
        
         -- Screen brightness controls
         , ("<XF86MonBrightnessUp>", spawn "xbacklight -inc 10")
         , ("<XF86MonBrightnessDown>", spawn "xbacklight -dec 10")
        
         -- Print screen
         , ("<Print>", spawn "scrot")
         ]
         
------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as XMonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
myLayout = mouseResize $ windowArrange myDefaultLayout
         where
           myDefaultLayout   = tiled 
                           ||| grid 
                           ||| threeCol
                           ||| tabs 
                           ||| floats 
                           ||| full
                           
-- The builtin tiling mode of XMonad. 
-- Supports Shrink, Expand and IncMasterN.
--
tiled    = renamed [Replace "Tall"]
           $ smartBorders
           $ smartSpacingWithEdge 5
           $ ResizableTall 1 (3/100) (1/2) []

-- A simple layout that attempts to put all windows in a square grid.
--
grid     = renamed [Replace "Grid"]
           $ smartBorders
           $ smartSpacingWithEdge 5
           $ Grid 

-- A layout similar to tall but with three columns. 
-- With 2560x1600 pixels this layout can be used for a huge main window and up to six reasonable sized slave windows.
--
threeCol = renamed [Replace "ThreeCol"]
           $ smartBorders
           $ smartSpacingWithEdge 5
           $ ThreeCol 1 (3/100) (1/2)

-- A tabbed layout for the XMonad Window Manager.
--
tabs     = renamed [Replace "Tabs"]
           $ smartBorders
           $ tabbed shrinkText def

-- A basic floating layout.
--
floats   = renamed [Replace "Floats"]
           $ smartBorders
           $ simplestFloat

-- Simple fullscreen mode. Renders the focused window fullscreen.
--
full     = renamed [Replace "Full"]
           $ smartBorders
           $ Full

-- This is a layout modifier that will show the workspace name.
--
myShowWNameTheme :: SWNConfig
myShowWNameTheme = def 
    { swn_font = "xft:JetBrainsMono Nerd Font:bold:size=60"
    , swn_fade = 1.0
    , swn_bgcolor = "#1C1F24"
    , swn_color = "#FFFFFF"
    }

------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook = composeAll
    [ className =? "MPlayer"        --> doFloat
    , className =? "Gimp"           --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore 
    ] 
    
------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
myEventHook = mempty

------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
myLogHook = return ()

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time XMonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
myStartupHook :: X ()
myStartupHook = do
    setDefaultCursor xC_left_ptr
    spawn "killall trayer &"
    spawnOnce "picom --experimental-backends &"
    spawnOnce "/usr/bin/lxpolkit &"
    spawnOnce "nm-applet &"
    spawnOnce "nitrogen --restore &"
    spawnOnce "dunst &"
    spawn "sleep 2 && trayer --edge top --align right --widthtype request --padding 6 --SetDockType true --SetPartialStrut true --expand true --transparent true --alpha 0 --tint 0x2D2A2E --height 20 &"

-- XMobar
--
mySB :: StatusBarConfig
mySB = statusBarProp "xmobar" (clickablePP =<< (pure myXmobarPP))
  where
myXmobarPP :: PP
myXmobarPP = def 
    { ppCurrent = xmobarBorder "Top" "#AE81FF" 2
    , ppHidden = xmobarColor "#FFFFFF" "" . wrap "" ""
    , ppHiddenNoWindows = xmobarColor "#BBBBBB" "" 
    , ppTitle = xmobarColor "#FFFFFF" "" 
    , ppSep = "<fc=#F92672> • </fc>"  
    , ppUrgent = xmobarColor "#E95678" "" . wrap "!" "!" 
    , ppOrder = \(ws:l:t:ex) -> [ws,l]++ex++[t]
    }

------------------------------------------------------------------------
-- Now run XMonad with all the defaults we set up.
--
main :: IO ()
main = xmonad 
     . ewmhFullscreen 
     . ewmh 
     . withEasySB mySB defToggleStrutsKey 
     $ myConfig  

-- A structure containing your configuration settings, overriding
-- fields in the default config. Any you don't override, will
-- use the defaults defined in xmonad/XMonad/Config.hs
--
myConfig = def {
        
        -- Simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,
        
        -- Hooks, layouts
        layoutHook         = showWName' myShowWNameTheme $ myLayout,
        manageHook         = myManageHook,
        handleEventHook    = myEventHook,
        logHook            = myLogHook,
        startupHook        = myStartupHook
    }
 `additionalKeysP` myKeys
