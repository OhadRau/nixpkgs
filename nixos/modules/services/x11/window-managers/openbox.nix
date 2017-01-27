{ config, lib, pkgs, ... }:

with lib;

let
  inherit (lib) mkOption mkIf;
  cfg = config.services.xserver.windowManager.openbox;
in

{
  options.services.xserver.windowManager.openbox = {
    enable = mkEnableOption "openbox";
    resistance = {
      strength = mkOption {
        type = types.int;
        default = 10;
        example = 10;
        description = "How much resistance (in pixels) there is between two windows before they overlap.";
      };
      screenEdgeStrength = mkOption {
        type = types.int;
        default = 20;
        example = 20;
        description = "Same as strength, but between window and screen edge.";
      };
    };
    focus = {
      focusNew = mkOption {
        type = types.bool;
        default = true;
        example = true;
        description = "Give focus to new windows when they are created.";
      };
      focusLast = mkOption {
        type = types.bool;
        default = true;
        example = true;
        description = "When switching desktops, focus the last focused window on that desktop again.";
      };
      followMouse = mkOption {
        type = types.bool;
        default = false;
        example = false;
        description = "Makes focus follow the mouse when the mouse is being moved.";
      };
      focusDelay = mkOption {
        type = types.int;
        default = 200;
        example = 200;
        description = "The time (in milliseconds) to wait before giving focus to the window under the mouse cursor (if followMouse is set).";
      };
      underMouse = mkOption {
        type = types.bool;
        default = false;
        example = false;
        description = "Focus under the mouse even when it enters another window without moving (if followMouse is set).";
      };
      raiseOnFocus = mkOption {
        type = types.bool;
        default = true;
        example = true;
        description = "Raises windows to top when they are focused (if followMouse is set).";
      };
    };
    placement = {
      policy = mkOption {
        type = types.enum [ "Smart" "UnderMouse" ];
        default = "Smart";
        example = "Smart";
        description = "Smart causes new windows to be placed automatically; UnderMouse makes new windows appear under the mouse cursor.";
      };
      center = mkOption {
        type = types.bool;
        default = false;
        example = false;
        description = "If enabled, windows will open centered in the free area found.";
      };
    };
    theme = {
      name = mkOption {
        type = types.str;
        default = "Clearlooks";
        example = "Clearlooks";
        description = "The name of the Openbox theme to use.";
      };
      titleLayout = mkOption {
        type = with types;
               let checkTitleLayout = str:
                 with builtins;
                 let chars = strings.stringToCharacters str;
                 in all (x: elem x [ "N" "L" "I" "M" "C" "S" "D" ]) chars && chars == lists.unique chars; 
               in addCheck str checkTitleLayout;
        default = "NLIMC";
        example = "MCSD";
        description = "Which order/what buttons to put in a window's titlebar. N=icon, L=label, I=iconify, M=maximize, C=close, S=shade, D=omnipresent.";
      };
      keepBorder = mkOption {
        type = types.bool;
        default = true;
        example = true;
        description = "Should windows keep Openbox's border when window decorations are turned off?";
      };
      animateIconify = mkOption {
        type = types.bool;
        default = true;
        example = true;
        description = "Add an iconification animation?";
      };
      fonts = mkOption {
        type = with types; listOf (submodule {
          options = {
            place = mkOption {
              type = types.enum [ "ActiveWindow" "InactiveWindow" "MenuHeader" "MenuItem" "OnScreenDisplay" ];
              default = "ActiveWindow";
              example = "ActiveWindow";
              description = "What element the font will be used for (active/inactive window title bar, menu headers, menu items, or in pop-ups)";
            };
            name = mkOption {
              type = types.str;
              default = "sans";
              example = "sans";
              description = "Specifies which font to use.";
            };
            size = mkOption {
              type = types.int;
              default = 8;
              example = 8;
              description = "Specifies which size text to use.";
            };
            weight = mkOption {
              type = types.enum [ "normal" "bold" ];
              default = "normal";
              example = "bold";
              description = "Specifies which font weight to use.";
            };
            slant = mkOption {
              type = types.enum [ "normal" "italic" ];
              default = "normal";
              example = "italic";
              description = "Specifies which font slant to use.";
            };
          };
        });
        default = [];
        example = [{
          place = "OnScreenDisplay";
          name = "serif";
          size = 12;
          weight = "bold";
        }];
        description = "Picks a font for a specific window element.";
      };
    };
    desktops = {
      number = mkOption {
        type = types.int;
        default = 4;
        example = 4;
        description = "The number of virtual desktops to use.";
      };
      firstDesk = mkOption {
        type = types.int;
        default = 1;
        example = 1;
        description = "The desktop to use when first started.";
      };
      popupTime = mkOption {
        type = types.int;
        default = 1000;
        example = 1000;
        description = "Time (in milliseconds) to show the pop-up when switching desktops (0 to disable).";
      };
      names = mkOption {
        type = with types; listOf str;
        default = [];
        example = [ "work" "play" "dull" "boy" ];
        description = "Each name tag names your desktops in ascending order. Unnamed desktops will be named automatically depending on the locale.";
      };
    };
    resize = {
      drawContents = mkOption {
        type = types.bool;
        default = false;
        example = false;
        description = "Resize the program inside the window while resizing.";
      };
      popupShow = mkOption {
        type = types.enum [ "Always" "Never" "Nonpixel" ];
        default = "Always";
        example = "Always";
        description = "When to show the move/resize pop-up (always, never, or when resizing in increments larger than pixels, e.g. terminals).";
      };
      popupPosition = mkOption {
        type = types.enum [ "Top" "Center" "Fixed" ];
        default = "Center";
        example = "Fixed";
        description = "Where to show the pop-up (ahove the title bar, centered on the window, or in a fixed location set by popupFixedPosition).";
      };
      popupFixedPosition = mkOption {
        type = with types; nullOr (submodule {
          options = {
            x = mkOption {
              type = with types; either int str;
              default = 400;
              example = "+-400";
              description = "The x coordinate to fix to.";
            };
            y = mkOption {
              type = with types; either int str;
              default = "center";
              example = "--200";
              description = "The y coordinate to fix to.";
            };
          };
        });
        default = null;
        example = { x = "center"; y = "center"; };
        description = "Specifies where on the screen to show the position when Fixed. Takes x and y coordinates.";
      };
    };
    # + Applications + Keyboard + Mouse + Margins + Menu + Dock
  };
  
  config = mkIf cfg.enable rec {
    environment.etc."openbox/rc.xml".text = ''
      <?xml version="1.0" encoding="UTF-8"?>

      <openbox_config xmlns="http://openbox.org/3.4/rc"
                      xmlns:xi="http://www.w3.org/2001/XInclude">

        <resistance>
          <strength>${toString cfg.resistance.strength}</strength>
          <screenEdgeStrength>${toString cfg.resistance.screenEdgeStrength}</screenEdgeStrength>
        </resistance>

        <focus>
          <focusNew>${if cfg.focus.focusNew then "yes" else "no"}</focusNew>
          <focusLast>${if cfg.focus.focusLast then "yes" else "no"}</focusLast>
          <followMouse>${if cfg.focus.followMouse then "yes" else "no"}</followMouse>
          <focusDelay>${toString cfg.focus.focusDelay}</focusDelay>
          <underMouse>${if cfg.focus.underMouse then "yes" else "no"}</underMouse>
          <raiseOnFocus>${if cfg.focus.raiseOnFocus then "yes" else "no"}</raiseOnFocus>
        </focus>

        <placement>
          <policy>${cfg.placement.policy}</policy>
          <center>${if cfg.placement.center then "yes" else "no"}</center>
        </placement>

        <theme>
          <name>${cfg.theme.name}</name>
          <titleLayout>${cfg.theme.titleLayout}</titleLayout>
          <keepBorder>${if cfg.theme.keepBorder then "yes" else "no"}</keepBorder>
          <animateIconify>${if cfg.theme.animateIconify then "yes" else "no"}</animateIconify>
          ${
            let
              formatFont = {place, name, size, weight, slant}: ''
                <font place=${place}>
                  <name>${name}</name>
                  <size>${toString size}</size>
                  <weight>${weight}</weight>
                  <slant>${slant}</slant>
                </font>
              '';
            in
            toString (map formatFont cfg.theme.fonts)
          }
        </theme>

        <desktops>
          <number>${toString cfg.desktops.number}</number>
          <firstdesk>${toString cfg.desktops.firstDesk}</firstdesk>
          <popupTime>${toString cfg.desktops.popupTime}</popupTime>
          <names>
            ${toString (map (s: "<name>${s}</name>") cfg.desktops.names)}
          </names>
        </desktops>

        <resize>
          <drawContents>${if cfg.resize.drawContents then "yes" else "no"}</drawContents>
          <popupShow>${cfg.resize.popupShow}</popupShow>
          <popupPosition>${cfg.resize.popupPosition}</popupPosition>
          ${
            if cfg.resize.popupFixedPosition != null
              then ''
              <popupFixedPosition>
                <x>${toString cfg.resize.popupFixedPosition.x}</x>
                <y>${toString cfg.resize.popupFixedPosition.y}</y>
              </popupFixedPosition>
              ''
              else ""
          }
        </resize>
      </openbox_config>
    '';
    services.xserver.windowManager = {
      session = [{
        name = "openbox";
        start = "${pkgs.openbox}/bin/openbox --config-file /etc/openbox/rc.xml";
      }];
    };
    environment.systemPackages = [ pkgs.openbox ];
  };
}
