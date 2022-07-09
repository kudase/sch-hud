# SCH-hud

The book will turn purple if you have Dark Arts enabled, and will glow purple if you activate Addenum: Black. The book will turn white if you have Light Arts enabled, and glow white if you active Addendum: White. 

The left page displays the number of Stratagems you have available. If you have used any stratagems, the right page will count down until the next stratagem refresh.

**NOTE:** This addon only supports the SCH main job and requires the job to be at level 99.

## Examples

Addendum: Black

![alt text](https://i.ibb.co/GnQ8RHR/Addendum-Black-Updated.png)

Addendum:White

![alt text](https://i.ibb.co/6ghfW15/Addendum-White-Updated.png)


## Installation
Make a folder in your Windower\addons called SCH-hud and put the contents of this repository (lua and the assets) folder in there. Load this addon with main job SCH by adding `send_command('lua l sch-hud')` to your Gearswap.

## Commands

The SCH-hud supports several configuration options that you can modify.  This can be done either by editing the `data\settings.xml` file directly or by issue a command within the game.

* `floor` - Toggles between rounding the calculation for the recharge timer up or down (**default: round down**)
* `interval <value>` - Allows you to change the minimum refresh interval (**default: 0.1**)
* `position <x> <y>` - Changes the position of the graphics on the screen (**defaults: x=1210, y=785**)

### Example
`\\sch-hud interval 1`  - This will set the refresh interval to atleast 1 second.\
`\\sch-hud position 1575 900`  - This position the UI at the X position of 1575 and Y of 900.