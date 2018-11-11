# TF2-ECJ-JumpAssist

## Various differences compared to nolem's version:
#### Too many to really list at this point. TL;DR this version is more efficient
  
Syntax updates  
Database structure  
Improved race functionality  
Removed soundhook sound blocking (Included in TF2-Hide plugin)  
Changed chat messages/colors (Change theme colors by editing cTheme1/2 and recompiling)  
Removed updater.  
Removed sm_goto (Available in another plugin used on ECJ)  
Removed speedrun functionality (Available in self-race)  
Showkeys improvements (Efficiency/responsiveness. Also improved /skeyspos)  
Tons of other undocumented misc changes.  
  
## Public Commands
Command | Description
--------| -----------
======== Help ======== |  
**ja_help** | Shows JA's commands.  
**sm_jumptf** | Shows the jump.tf website.  
**sm_forums** | Shows the jump.tf forums.  
**sm_jumpassist** | Shows the forum page for JumpAssist. 
======== General ======== |  
**sm_save, sm_s** | Saves your current position.   
**sm_tele, sm_t** | Teleports you to your current saved location.   
**sm_reset, sm_r** | Sends you back to the beginning without deleting your save.  
**sm_restart** | Deletes your save, and sends you back to the beginning.  
**sm_undo** | Restores your last saved position.  
**sm_ammo, sm_regen** | Regenerates weapon ammunition  
**sm_superman** | Makes you strong like superman. (Reduces damage taken)  
**sm_hardcore** | Enables hardcore mode (No regen, no saves)  
**sm_hidemessage** | Toggles display of JA messages, such as save and teleport
======== ShowKeys ======== |  
**sm_skeys** | Toggle showing a client's keys  
**sm_skeyscolor, sm_skeyscolors** | Changes the color of the text for skeys.  
**sm_skeyspos, sm_skeysloc** | Changes the location of the text for skeys.  
======== Race ======== |  
**sm_race** | Initializes a new race.  
**sm_r_leave, sm_race_leave** | Leave the current race.  
**sm_r_spec, sm_race_spec** | Spectate a race.  
**sm_r_list, sm_race_list, sm_racelist, sm_rlist** | Display race list  
**sm_race_set** | Change a race's settings.  
**sm_r_info, sm_race_info** | Display information about the race you are in.  
  
## Admin Commands  
Command | Description
--------|------------
**sm_server_race, sm_s_race** | Invite everyone to a server wide race  
**sm_mapset** | Change map settings  
**sm_send** | Send target to another target.  

## CVars
CVar | Def | Description  
-----|---------|--------  
**ja_enable** | 1 | Turns JumpAssist on/off.  
**ja_welcomemsg** | 1 | Show clients the welcome message when they join?  
**ja_ammocheat** | 1 | Allows engineers infinite sentrygun ammo?  
**ja_crits** | 0 | Allow critical hits?  
**ja_superman** | 1 | Allows everyone to be invincible?  
