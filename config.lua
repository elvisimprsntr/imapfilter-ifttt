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

areas =        {
               first_floor = '1',
               second_floor = '2',
               third_floor = '3',
               garage = '4',
               }

nodes =	       {
		all = '8730',
		exterior = '32377',
		garage = '27356',
		theater = '44403',
		}	
			
states =       {
               ['0'] = 'disarmed',
               ['1'] = 'away',
               ['2'] = 'stay',
               ['3'] = 'stay_instant',
               ['4'] = 'night',
               ['5'] = 'night_instant',
               ['6'] = 'vacation'
               }

-- ZM tables
----------------------------------------
zm =            {
                server = '192.168.69.20',
                username = ‘username’,
                password = ‘password’,
                }

cams =          {
                garage = '1',
                porch = '2',
                theater = '3',
                stairwell = '4',
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
        return states[a]
        end

nodecmd = function (isy, node, cmd)
	local cmd = 'curl -u ' .. isy['username'] .. ':' .. isy['password'] .. ' http://' .. isy['server'] .. '/rest/nodes/' .. node .. '/cmd/' .. cmd
	os.execute(cmd)
	end

-- ZM functions
----------------------------------------                   
modecmd = function (zm, cam, mode)
	local cmd = 'curl -d "username=' .. zm['username'] .. '&password=' .. zm['password'] .. '&action=login&view=console" http://' .. zm['server'] .. '/zm/index.php -c ~/.imapfilter/zm.cookie'  
	os.execute(cmd)
	local cmd = 'curl -d "view=none&action=function&mid=' .. cam .. '&newFunction=' .. mode .. '&newEnabled=1" http://' .. zm['server'] .. '/zm/index.php -b ~/.imapfilter/zm.cookie'
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
end
results:delete_messages()

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
end
results:mark_seen()

-- Control camera modes
----------------------------------------
armstate = areacmd(isy, areas['first_floor']) 
if (armstate == 'disarmed') then
        modecmd(zm, cams['porch'], 'Modect')
        modecmd(zm, cams['theater'], 'Monitor')
        modecmd(zm, cams['stairwell'], 'Monitor')
else
        modecmd(zm, cams['porch'], 'Modect')
        modecmd(zm, cams['theater'], 'Modect')
        modecmd(zm, cams['stairwell'], 'Modect')
end
armstate = areacmd(isy, areas['garage'])
if (armstate == 'disarmed') then
        modecmd(zm, cams['garage'], 'Monitor')
else
        modecmd(zm, cams['garage'], 'Modect')
end

-- Sandbox
----------------------------------------
