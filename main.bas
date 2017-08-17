' FB Graph Editor - by Pitto

'This program is free software; you can redistribute it and/or
'modify it under the terms of the GNU General Public License
'as published by the Free Software Foundation; either version 2
'of the License, or (at your option) any later version.
'
'This program is distributed in the hope that it will be useful,
'but WITHOUT ANY WARRANTY; without even the implied warranty of
'MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
'GNU General Public License for more details.
'
'You should have received a copy of the GNU General Public License
'along with this program; if not, write to the Free Software
'Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
'Also add information on how to contact you by electronic and paper mail.

'#######################################################################

' Compiling instructions: fbc -w all -exx "%f"
' use 1.04 freebasic compiler

' SOME CODING CONVENTIONS USED IN THIS SOURCE CODE______________________
' UPPERCASED  				is a constant
' First_leter uppercased 	is a shared variable
' first_letter_lowercase 	is a local variable
'
' Often the "c" variable name is used as counter variable


#include "fbgfx.bi"


#ifndef NULL
const NULL as any ptr = 0
#endif

'__MACROS_______________________________________________________________
'calculate angle between two points
#macro _abtp (x1,y1,x2,y2)
    -Atan2(y2-y1,x2-x1)
#endmacro
Using FB
dim shared Debug_mode		as boolean = false

'#INCLUDE FILES_________________________________________________________

#include "enums.bi"
#include "types.bas"
#include "define_and_consts.bas"
#include "functions.bi"
#include "subs.bas"

'VARIABLES Declarations_________________________________________________

DIM workpage 				AS INTEGER
Dim user_mouse 				as mouse_proto
Dim input_mode				as proto_input_mode
dim head 					as p_proto ptr
dim node_selected			as p_proto ptr
dim edge					as edge_proto ptr
dim icon_set (0 to 39) 		as Uinteger ptr
'dim test_bmp  				as Uinteger ptr
dim c 						as integer
dim view_area				as view_area_proto
dim w 						as single = SCR_W
dim h						as single = SCR_H
dim vertex_start			as p_proto ptr
dim vertex_target			as p_proto ptr
dim snap 					as boolean


'initializing some variables
snap = false
head = NULL
edge = NULL
node_selected = NULL
input_mode = add_vertex
user_mouse.is_dragging = false
user_mouse.is_lbtn_released = false
user_mouse.is_lbtn_pressed = false

view_area.x = 0
view_area.y = 0
view_area.zoom = 1.0f
view_area.old_zoom = view_area.zoom

'INITIALIZING GRAPHICS _________________________________________________
screenres SCR_W, SCR_H, 24		'initialize graphics
SetMouse SCR_W\2, SCR_H\2, 0 	'hides mouse pointer

'MAIN LOOP______________________________________________________________
do
	if MULTIKEY (SC_Escape) then exit do

	keyboard_listener(@input_mode, user_mouse, @view_area)
	mouse_listener(@user_mouse, @view_area)
	
	screenlock ' Lock the screen
	screenset Workpage, Workpage xor 1 ' Swap work pages.

	cls

	select case input_mode
		
		case add_vertex
			'add new node_______________________________________________
			if (user_mouse.is_lbtn_released) then
				'if snap then	
				'	add		(@head,	user_mouse.x, user_mouse.y)
				'else
					add		(@head,	user_mouse.x, user_mouse.y)
				'end if
			end if
			user_mouse.is_lbtn_released = false
		
		case del_edge
			if (user_mouse.is_lbtn_released) then
				node_selected = get_nearest_node(head, user_mouse.x, user_mouse.y)
				'del_an_edge (edge, node_selected)
				edge = del_an_edge(edge, node_selected)
			end if
			
			user_mouse.is_lbtn_released = false
		
		case add_edge
			if (user_mouse.is_dragging) then
				vertex_start = get_nearest_node(head, user_mouse.old_x, user_mouse.old_y)
				line (	*get_nearest_node(head, user_mouse.old_x, user_mouse.old_y).x, _
						*get_nearest_node(head, user_mouse.old_x, user_mouse.old_y).y) - _
						(user_mouse.x, user_mouse.y)
			end if
			if (user_mouse.is_lbtn_released) then
				vertex_target = get_nearest_node(head, user_mouse.x, user_mouse.y)
				add_edge_to_vertex (@edge, vertex_start, vertex_target)
			end if
			user_mouse.is_lbtn_released = false
		
		case move_vertex
			if (user_mouse.is_lbtn_released) then
				node_selected = get_nearest_node(head, user_mouse.x, user_mouse.y)
			end if
			if node_selected <> NULL then
				node_selected-> x = user_mouse.x
				node_selected-> y = user_mouse.y
			end if
			
			if (user_mouse.is_rbtn_released and CBool(node_selected <> NULL)) then
				node_selected->x = user_mouse.x
				node_selected->y = user_mouse.y
				node_selected = NULL
			end if
			
			user_mouse.is_lbtn_released = false
			user_mouse.is_rbtn_released = false
	end select
	'debug purpouses
	list_edges (edge, get_nearest_node(head, user_mouse.x, user_mouse.y))
	list_vertex (head, get_nearest_node(head, user_mouse.x, user_mouse.y))
	
	display(head, @user_mouse, view_area, input_mode)
	draw_mouse_pointer(user_mouse, input_mode, icon_set())

	draw string (user_mouse.x + 10, user_mouse.y + 10), _
				str(hex(get_nearest_node(head, user_mouse.x, user_mouse.y))), C_GRAY
	'bottom command tools list
	line (0, SCR_H - 30)-(SCR_W, SCR_H), C_DARK_GRAY, BF
	draw string (50, SCR_H - 20), "add Vertex | Move vertex | add Edge | Delete edge", C_GRAY
	draw string (50, SCR_H - 20), "    V        M                 E      D          ", C_RED
	draw string (50, SCR_H - 20), draw_current_tool (input_mode) , C_WHITE
	dim d as integer = 0
	
	draw_edges (edge, head, get_nearest_node(head, user_mouse.x, user_mouse.y), input_mode)
	
	draw string (SCR_W - 200, SCR_H - 20), APP_NAME + " " + APP_VERSION
	workpage = 1 - Workpage ' Swap work pages.
	screenunlock
	sleep 20,1
LOOP

'FREE MEMORY____________________________________________________________

'destroy icon_Set bitmaps form memory
for c = 0 to Ubound(icon_set)
	ImageDestroy icon_set(c)
next c

'destroy icon_Set bitmaps form memory
'ImageDestroy test_bmp
'ImageDestroy test_bmp_2

