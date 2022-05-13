_addon.name = 'SCH-hud'
_addon.author = 'NeoNRAGE'
_addon.version = '1.1.0'
_addon.commands = {'sch'}

config = require('config')
texts = require('texts')
require('logger')

local timer3 = texts.new("")
local stratcount = texts.new("")

texts.visible(timer3, false)
texts.bg_alpha(timer3, 0)
texts.size(timer3, 26)
texts.font(timer3, 'Arial')
texts.color(timer3, 255, 255, 255)
texts.bold(timer3, true)
texts.stroke_alpha(timer3, 255)
texts.stroke_width(timer3, 1.5)
texts.stroke_color(timer3, 0, 0, 0)

texts.visible(stratcount, false)
texts.bg_alpha(stratcount, 0)
texts.size(stratcount, 35)
texts.font(stratcount, 'Arial')
texts.color(stratcount, 0, 0, 0)
texts.bold(stratcount, true)
texts.stroke_alpha(stratcount, 255)
texts.stroke_width(stratcount, 1.5)
texts.stroke_color(stratcount, 255, 255, 255)
texts.alpha(stratcount, 50)

local time_start = 0
local defaults = {}
defaults.interval = 0.1
defaults.pos = {}
defaults.pos.x = 1210
defaults.pos.y = 785

local settings = config.load(defaults)
local debug = false

local images = {'grimoire-d', 'grimoire-da', 'grimoire-l', 'grimoire-la'}
local vGD = 0
local vGDA = 0
local vGL = 0
local vGLA = 0

local current_mode = -1
local secs = 0
local recasttemp = 0

windower.register_event('load', function() 

	-- We currently don't support SCH sub-job or main level < 99.  Unload gracefully instead.
	local player =  windower.ffxi.get_player()
	if player.main_job_id ~= 20 or player.main_job_level < 99 then
		print('%s (v%s) does not currently support main jobs other than level 99 SCH. Unloading':format(_addon.name, _addon.version))
		windower.send_command('lua u sch-hud')
		return
	end

	for index, image_name in ipairs(images) do
		windower.prim.create(image_name)
		windower.prim.set_color(image_name, 0, 0, 0, 0)	
		windower.prim.set_fit_to_texture(image_name, false)
		windower.prim.set_texture(image_name, windower.addon_path .. 'assets/%s.png':format(image_name))
		windower.prim.set_repeat(image_name, 1, 1)
		windower.prim.set_visibility(image_name, true)
		windower.prim.set_position(image_name, settings.pos.x, settings.pos.y)
		windower.prim.set_size(image_name, 170, 120)	
	end
	set_screen_position()
	texts.alpha(stratcount, 50)
	texts.visible(stratcount, true)
end)

windower.register_event('prerender', function()
	local now = os.time()
	if now > time_start + settings.interval then
		time_start = now
		ability_hud() 
	end
end)

function ability_hud ()
	--Get number of SCH Job Points
	local sch_jp = windower.ffxi.get_player().job_points.sch.jp_spent
	--Get recast on Stratagems
	local recast = windower.ffxi.get_ability_recasts()[231]

	current_mode = update_images(current_mode)

	local charges = 5
	local recharge_time = 48
	if sch_jp > 549 then
		recharge_time = 33
	end
	
	-- Determine the number of strategems available
	-- We invert the recast timer and use the modulus for the count
	local strategems = ((charges * recharge_time) - recast) / recharge_time
	texts.text(stratcount, '%d':format(strategems))

	-- Calculate the time for the next strategem from the additive recast
	if (recast > 0) then
		next_strat = recast % recharge_time
		texts.text(timer3, '%.2d':format(next_strat))
		texts.visible(timer3, true)
	else
		texts.visible(timer3, false)
	end
end

function BuffActive(buffnum)
	for k,v in pairs(windower.ffxi.get_player().buffs) do
		if v == buffnum then
			return true
		end
	end
	return false
end

function delete()
	for index, image_name in pairs(images) do
		windower.prim.delete(image_name)
	end
	texts.destroy(stratcount)
	texts.destroy(timer3)
end

function set_screen_position() 
	for index, image_name in pairs(images) do
		windower.prim.set_position(image_name, settings.pos.x, settings.pos.y)
	end
	texts.pos(timer3, settings.pos.x + 93, settings.pos.y + 38)
	texts.pos(stratcount, settings.pos.x + 43, settings.pos.y + 30)
end

-- Updates the displayed images if the passed in mode does match the current game state.  If no mode is passed in, the images are always updated.
-- Returns the current mode as a number
function update_images(mode)
	local new_mode = 0
	mode = mode or -1
	vGD = 0
	vGDA = 0
	vGL = 0
	vGLA = 0

	if BuffActive(359) then --Dark Arts
		new_mode = 1
		vGD = 255
	elseif BuffActive(358) then --Light Arts
		new_mode = 2
		vGL = 255
	elseif BuffActive(401) then --Addendum White
		new_mode = 3
		vGLA = 255
	elseif BuffActive(402) then --Addendum Black
		new_mode = 4
		vGDA = 255
	else --No Arts Active
		new_mode = 0
		vGL = 100
	end

	-- Only modify the images if the mode was changed.
	if mode ~= new_mode then
		if new_mode == 0 then
			texts.alpha(stratcount, 50)
			texts.stroke_alpha(stratcount, 100)
		else
			texts.alpha(stratcount, 255)
			texts.stroke_alpha(stratcount, 255)
		end
		windower.prim.set_color('grimoire-d', vGD, vGD, vGD, vGD)	
		windower.prim.set_color('grimoire-da', vGDA, vGDA, vGDA, vGDA)	
		windower.prim.set_color('grimoire-l', vGL, vGL, vGL, vGL)
		windower.prim.set_color('grimoire-la', vGLA, vGLA, vGLA, vGLA)
	end

	return mode
end

windower.register_event('unload',function()
	delete()
end)

windower.register_event('logout',function()
	windower.send_command('lua u sch-hud')
end)

windower.register_event('job change',function(main_job_id)
	if (main_job_id ~= 20) then
		print('Job changed off of SCH, unloading %s':format(_addon.name))
		windower.send_command('lua u sch-hud')
	end
end)

windower.register_event('addon command', function(command1, command2, command3, ...)
    local args = L{...}
    command1 = command1 and command1:lower() or nil
    command2 = command2 and command2:lower() or nil
	command3 = command3 and command3:lower() or nil
    
    local name = args:concat(' ')
    if command1 == 'p' or command1 == 'position' then
		settings.pos.x = tonumber(command2) or 1210
		settings.pos.y = tonumber(command3) or 785
        log('Position set to <%s, %s>.':format(settings.pos.x, settings.pos.y))
        settings:save()
		set_screen_position()

    elseif command1 == 'i' or command1 == 'interval' then
        settings.interval = tonumber(command2) or .1
        log('Refresh interval set to %s seconds.':format(settings.interval))
        settings:save()

    else
        print('%s (v%s)':format(_addon.name, _addon.version))
        print('    \\cs(255,255,255)position <x> <y>\\cr - Changes the position of the graphics on the screen (defaults: x=1210, y=785)')
        print('    \\cs(255,255,255)interval <value>\\cr - Allows you to change the refresh interval (default: 0.1)')
    end
end)