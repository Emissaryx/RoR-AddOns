local Enemy = Enemy
local select = select


function Enemy.EventsInitialize ()

	Enemy.events = {}
	Enemy.TriggerEvent ("EventsInitialized")
end


function Enemy.AddEventHandler (key, name, callback)
  --d(key)
  --d(name)
  
    if (type(callback) ~= "function")
    then
        -- Invalid callback; do not register to avoid runtime errors later
        if (d) then d ("Wrong arguments for Enemy.AddEventHandler: "..tostring(key)..", "..tostring(name)..", "..tostring(callback)) end
        return
    end

    Enemy.RemoveEventHandler (key, name)
    
    local e = Enemy.events[name]
    if (e == nil)
    then
        e = EnemyLinkedList.New ()
        Enemy.events[name] = e
    end
    
    e:Add (key, callback)
end


function Enemy.TriggerEvent (name, ...)
  --d("trigger event")
  --d(name)
    local e = Enemy.events[name]
    if (e == nil) then return end

    local item = e.first
    while (item)
    do
        item.data(...)
        item = item.next
    end
end


function Enemy.RemoveEventHandler (key, name)
        --d(key)
	--d(name)
	local e = Enemy.events[name]
	if (e == nil) then return end
	e:Remove (key)
end
