options.timeout = 60
options.subscribe = true

-- IMAP account
----------------------------------------
account = IMAP	{
		server = ‘imap.gmail.com’,
		username = ‘username@gmail.com’,
		password = ‘password’,
		ssl = 'tls1',
		}

-- ISY tables
----------------------------------------
isy = 		{
		server = '192.168.69.90',
		username = ‘username’,
		password = ‘password’,
		}

areas =         {
                first_floor = '1',
                second_floor = '2',
                third_floor = '3',
                garage = '4',
                }

nodes =	{
		all = '8730',
		exterior = '32377',
		garage = '27356',
		theater = '44403',
		}	
			
states =	{
		disarmed = '0',
		away = '1',
		stay = '2',
		stay_instant = '3',
		night = '4',
		night_instant = '5',
		vacation = '6',
		}		

-- ZM tables
----------------------------------------
zm =            {
                server = '192.168.69.85',
                username = ‘username’,
                password = ‘password’,
                }

cams =          {
                garage = '1',
                porch = '2',
                theater = '3',
                }

-- IMAP filter
----------------------------------------
filter = function (mailbox, from, subject)
        return  mailbox:is_unseen() *
                mailbox:contain_from(from) *
                mailbox:contain_subject(subject)
        end

-- ISY functions
----------------------------------------
areacmd = function (isy, area)
        local cmd = 'curl -u ' .. isy['username'] .. ':' .. isy['password'] .. ' http://' .. isy['server'] .. '/rest/elk/area/' .. area .. '/get/status'
        local f = assert(io.popen(cmd, 'r'))
        local s = assert(f:read('*a'))
        f:close()
        local a = string.match(s, 'type="3" area="' .. area .. '" val="(.?)"')
        return a
        end

nodecmd = function (isy, node, cmd)
	local cmd = 'curl -u ' .. isy['username'] .. ':' .. isy['password'] .. ' http://' .. isy['server'] .. '/rest/nodes/' .. node .. '/cmd/' .. cmd
	os.execute(cmd)
	end

-- ZM functions
----------------------------------------                   
modecmd = function (zm, cam, mode)
	local cmd = 'curl -d "username=' .. zm['username'] .. '&password=' .. zm['password'] .. '&action=login&view=console" http://' .. zm['server'] .. '/zm/index.php -c zm.cookie'  
	os.execute(cmd)
	local cmd = 'curl -d "view=none&action=function&mid=' .. cam .. '&newFunction=' .. mode .. '&newEnabled=1" http://' .. zm['server'] .. '/zm/index.php -b zm.cookie'
	os.execute(cmd)
	end

-- IFTTT recipies
----------------------------------------

-- Get mailbox status
----------------------------------------
account.INBOX:check_status()

-- Safelert alerts
----------------------------------------
results = filter(account.INBOX, 'elertus.com', 'Alert')
matches=0
for _, mesg in ipairs(results) do
	matches=matches+1
end
if (matches > 0) then
	nodecmd(isy, nodes['theater'], 'DFON')
	modecmd(zm, cams['theater'], 'Modect')
end
results:mark_seen()

-- Kidde remotelync alarm
----------------------------------------
results = filter(account.INBOX, 'kidde-remotelync.com', 'alarm')
matches=0
for _, mesg in ipairs(results) do
        matches=matches+1
end
if (matches > 0) then
        nodecmd(isy, nodes['all'], 'DFON')
end
results:mark_seen()

-- Econet alert
----------------------------------------
results = filter(account.INBOX, 'econet.com', 'alert')
matches=0
for _, mesg in ipairs(results) do
        matches=matches+1
end
if (matches > 0) then
        nodecmd(isy, nodes['garage'], 'DFON')
        modecmd(zm, cams['garage'], 'Modect')
end
results:mark_seen()

-- Control camera modes
----------------------------------------
armstate = areacmd(isy, areas['first_floor']) 
if (armstate == '0') then
        modecmd(zm, cams['porch'], 'Modect')
        modecmd(zm, cams['theater'], 'Monitor')
elseif (armstate == '1' or armstate == '6') then
        modecmd(zm, cams['porch'], 'Modect')
        modecmd(zm, cams['theater'], 'Modect')
else
        modecmd(zm, cams['porch'], 'Modect')
        modecmd(zm, cams['theater'], 'Monitor')
end
armstate = areacmd(isy, areas['garage'])
if (armstate == '0') then
        modecmd(zm, cams['garage'], 'Monitor')
elseif (armstate == '1' or armstate == '6') then
        modecmd(zm, cams['garage'], 'Modect')
else
        modecmd(zm, cams['garage'], 'Modect')
end

-- Sandbox
----------------------------------------
