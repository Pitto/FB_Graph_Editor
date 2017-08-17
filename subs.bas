
declare sub draw_arrow(x1 as single, y1 as single, x2 as single, y2 as single, cl as Uinteger)

sub keyboard_listener(	input_mode as proto_input_mode ptr, _
						user_mouse as mouse_proto, _
						view_area as view_area_proto ptr)
	
	static old_input_mode as proto_input_mode = add_vertex
	
	dim e As EVENT
	If (ScreenEvent(@e)) Then
		Select Case e.type
		Case EVENT_KEY_RELEASE
			'switch Debug mode ON/OFF___________________________________
			If (e.scancode = SC_D) Then
				if Debug_mode then
					Debug_mode = false
				else
					Debug_mode = true
				end if
			end if
		End Select
	End If
	
	'this is for the hand ovverride tool
	if multikey (SC_SPACE) then
		*input_mode = hand
	else
		*input_mode = old_input_mode
	end if
	if multikey (SC_V) then *input_mode = add_vertex
	if multikey (SC_E) then *input_mode = add_edge
	if multikey (SC_M) then *input_mode = move_vertex
	if multikey (SC_D) then *input_mode = del_edge
	
	'this is for the hand ovverride tool
	if *input_mode <> hand then
		old_input_mode = *input_mode
	end if
	
end sub

sub draw_input_mode (input_mode as proto_input_mode, x as integer, y as integer)
	'select case input_mode
		'case selection
			'draw string (x, y), "SELECTION"
		'case direct_selection
			'draw string (x, y), "DIRECT SELECTION"
		'case pen
			'draw string (x, y), "PEN TOOL"
		'case hand
			'draw string (x, y), "HAND TOOL"
		'case else
			'draw string (x, y), "???"
	'end select
end sub

sub draw_mouse_pointer	(	user_mouse as mouse_proto, _
							input_mode as proto_input_mode, _
							icon_set() as Uinteger ptr)
							
	User_Mouse.res = 	GetMouse( 	User_Mouse.x, User_Mouse.y, _
								User_Mouse.wheel, User_Mouse.buttons,_
								User_Mouse.clip)
								
	
	'mouse graphical cross pointer
			line (user_mouse.x-10, user_mouse.y)-(user_mouse.x+10, user_mouse.y)
			line (user_mouse.x, user_mouse.y-10)-(user_mouse.x, user_mouse.y+10)
	select case input_mode
		case add_vertex
			if User_Mouse.is_lbtn_pressed then
				circle (User_Mouse.x, User_Mouse.y), 6, C_RED	
					
			end if
		case add_edge
			line (user_mouse.x-5, user_mouse.y-5)-(user_mouse.x+5, user_mouse.y+5),, B
			if User_Mouse.is_dragging then 
				circle(User_mouse.x, User_mouse.y), 6, C_BLUE
			end if
		
		case move_vertex
			line (	user_mouse.x-(8* cos(timer)), _
					user_mouse.y-(8* cos(timer)))- _
					(user_mouse.x+(8* cos(timer)), _
					user_mouse.y+(8* cos(timer))), C_GRAY, B
					
			draw string (user_mouse.x, user_mouse.y + 24), "right click to release", C_DARK_GRAY
					
		case del_edge
			line (	user_mouse.x-(8* cos(timer*10)), _
					user_mouse.y-(8* cos(timer*10)))- _
					(user_mouse.x+(8* cos(timer*10)), _
					user_mouse.y+(8* cos(timer*10))), C_RED, B
			
	end select

end sub

sub mouse_listener(user_mouse as mouse_proto ptr, view_area as view_area_proto ptr)
	static old_is_lbtn_pressed as boolean = false
	static old_is_rbtn_pressed as boolean = false
	static as integer old_x, old_y
	static store_xy as boolean = false
	
	if User_Mouse->old_wheel < User_Mouse->wheel and view_area->zoom < 8 then
		view_area->zoom *= 1.1f
	end if
	if User_Mouse->old_wheel > User_Mouse->wheel and view_area->zoom > 0.25 then
		view_area->zoom *= 0.9f
	end if
	
	'recognize if the left button has been pressed
	if User_Mouse->buttons and 1 then
		User_Mouse->is_lbtn_pressed = true
	else
		User_Mouse->is_lbtn_pressed = false
	end if
	
	'recognize if the right button has been pressed
	if User_Mouse->buttons and 2 then
		User_Mouse->is_rbtn_pressed = true
	else
		User_Mouse->is_rbtn_pressed = false
	end if
	
	'recognize if the left button has been released
	if old_is_lbtn_pressed = false and User_Mouse->is_lbtn_pressed and store_xy = false then 
		store_xy = true
	end if
	
	if store_xy then
		user_mouse->old_x = user_mouse->x
		user_mouse->old_y = user_mouse->y
		store_xy = false
	end if
	
	'recognize if the left button has been released
	if old_is_lbtn_pressed and User_Mouse->is_lbtn_pressed = false then 
		User_Mouse->is_lbtn_released = true
	end if
	
	'recognize if the right button has been released
	if old_is_rbtn_pressed and User_Mouse->is_rbtn_pressed = false then 
		User_Mouse->is_rbtn_released = true
	end if
	
	'recognize drag
	if (User_Mouse->is_lbtn_pressed) and CBool((old_x <> user_mouse->x) or (old_y <> user_mouse->y)) then
		user_mouse->is_dragging = true
		'cuspid node
		if multikey(SC_ALT) then
			user_mouse->oppo_x = user_mouse->old_oppo_x
			user_mouse->oppo_y = user_mouse->old_oppo_y
		'normal node
		else
			user_mouse->oppo_x = User_Mouse->old_x - _
						cos (_abtp (User_Mouse->old_x, User_Mouse->old_y, User_Mouse->x, User_Mouse->y)) * _
						(dist(User_Mouse->old_x, User_Mouse->old_y, User_Mouse->x, User_Mouse->y))
			user_mouse->oppo_y = User_Mouse->old_y - _
						-sin(_abtp (User_Mouse->old_x, User_Mouse->old_y, User_Mouse->x, User_Mouse->y)) * _
						(dist(User_Mouse->old_x, User_Mouse->old_y, User_Mouse->x, User_Mouse->y))
			user_mouse->old_oppo_x = user_mouse->oppo_x
			user_mouse->old_oppo_y = user_mouse->oppo_y
		end if			
		
	else
		user_mouse->is_dragging = false
	end if
	   'store the old wheel state
	User_Mouse->old_wheel = User_Mouse->wheel
	'store the old state of left button
	old_is_lbtn_pressed = User_Mouse->is_lbtn_pressed
	'store the old state of left button
	old_is_rbtn_pressed = User_Mouse->is_rbtn_pressed
	

	
end sub


sub display (head as p_proto ptr, user_mouse as mouse_proto ptr, view_area as view_area_proto, input_mode as proto_input_mode)

dim nearest as p_proto ptr
nearest = get_nearest_node(head, user_mouse->x, user_mouse->y)
	while (head <> NULL)
		circle (head->x * view_area.zoom + view_area.x, _
				head->y * view_area.zoom + view_area.y), NODE_W, NODE_COLOR, , , , F
		if nearest = head and input_mode = add_edge then
			circle (head->x * view_area.zoom + view_area.x, _
						head->y * view_area.zoom + view_area.y), _
						NODE_W + 6 + cos(timer*10), C_GREEN
			
		end if
		if nearest = head and input_mode = move_vertex then
			circle (head->x * view_area.zoom + view_area.x, _
						head->y * view_area.zoom + view_area.y), _
						NODE_W +4, C_ORANGE
		end if
		if nearest = head and input_mode = del_edge then
			circle (head->x * view_area.zoom + view_area.x, _
						head->y * view_area.zoom + view_area.y), _
						NODE_W +7, C_RED
		end if
		
		head = head->next_p
	wend
end sub

sub list_edges (head as edge_proto ptr, node as p_proto ptr)
	dim as integer c = 0
	draw string (20, 20), "EDGE LIST", C_GRAY
	while (head <> NULL)
		draw string (20, 30 + c* 10), str(hex(head)) + _
			" > " + str(hex(head->next_p)) + _
			" : " + str(hex(head->start)) + " > " + _
			str(hex(head->target)), C_DARK_GRAY
		if head-> start = node then 
			draw string (0, 30 + c* 10), ">>", C_GREEN
		end if
		
		if head-> target = node then 
			draw string (0, 30 + c* 10), "<<", C_GREEN
		end if
		
		head = head->next_p
		c += 1
	wend
end sub

sub list_vertex (node as p_proto ptr, sel as p_proto ptr)
	dim as integer c = 0
	draw string (SCR_W - 150, 20), "VERTEX LIST", C_GRAY
	while (node <> NULL)
		if sel = node then
		draw string (SCR_W - 150, 30 + c* 10), str(hex(node)) + _
			" > " + str(hex(node->next_p)), C_GREEN
		else
		draw string (SCR_W - 150, 30 + c* 10), str(hex(node)) + _
			" > " + str(hex(node->next_p)), C_DARK_GRAY
		end if
		
		node = node->next_p
		c += 1
	wend
end sub

sub draw_edges (edge as edge_proto ptr, node as p_proto ptr, sel as p_proto ptr, input_mode as proto_input_mode )
	dim as integer x1, x2, y1, y2
	dim temp_node as p_proto ptr
	temp_node = node
	while (edge <> NULL)
		node= temp_node
		while (node <> NULL)
			if edge->start = node then
				x1 = node->x
				y1 = node->y
			end if
			if edge->target = node then
				x2 = node->x
				y2 = node->y
			end if
			node = node->next_p
		wend
		if input_mode = add_vertex then
			line (x1 , y1)-( x2 , y2 ) , C_GRAY
		elseif input_mode = del_edge then
			if sel = edge->start or sel = edge->target then
				draw_arrow(x1 , y1 , x2 , y2 , C_RED)
			else
				line (x1 , y1)-( x2 , y2 ) , C_GRAY
			end if
		else
			if sel = edge->start or sel = edge->target then
				draw_arrow(x1 , y1 , x2 , y2 , C_GREEN)
			else
				line (x1 , y1)-( x2 , y2 ) , C_GRAY
			end if
		end if
		edge = edge->next_p
	
	wend
end sub


'sub del_an_edge (head as edge_proto ptr, node as p_proto ptr )
	
	'dim as edge_proto ptr temp, prev
	
	'temp = head
	
	'while (temp <> NULL)
		'if (temp->start = node or temp->target = node) then
			''if found item in head
			'if (temp = head) then
				'head = temp->next_p
				'deallocate (temp)
				'exit while
			'else
				''if found in the middle
				'if (temp->next_p <> NULL) then
					'prev->next_p = temp->next_p
					'deallocate (temp)
					'exit while
				''if found on tail
				'else
					'prev->next_p = NULL
					
					'deallocate (temp)
					'exit while
				'end if
			'end if
		'else
			'prev = temp
			'temp = temp->next_p
		'end if
	'wend
	
	'deallocate (prev)
	'deallocate (temp)
	

	
'end sub

sub draw_arrow(x1 as single, y1 as single, x2 as single, y2 as single, cl as Uinteger)
    line (x1, y1)-(x2,y2),cl
    line (x2, y2)-(x2 + cos (_abtp(x2,y2,x1,y1) - 0.5) * 15, y2 + -sin(_abtp(x2, y2,x1,y1) - 0.5) * 15), cl
    line (x2, y2)-(x2 + cos (_abtp(x2,y2,x1,y1) + 0.5) * 15, y2 + -sin(_abtp(x2, y2,x1,y1) + 0.5) * 15), cl
end sub  
