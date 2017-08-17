

type p_proto
	x 			as single
	y 			as single
	next_p  	as p_proto ptr
end type

type edge_proto
	start	as p_proto ptr
	target	as p_proto ptr
	next_p 	as edge_proto ptr
end type	

type view_area_proto
    x 		as single
    y 		as single
    old_x 	as single
    old_y 	as single
    w 		as single
    h 		as single
    speed 	as single
    rds 	as single
	zoom 	as single
	old_zoom 	as single
end type

Type mouse_proto
    As Integer res, x, y, old_x, old_y, wheel, clip, old_wheel, diff_wheel
    as single oppo_x, oppo_y, old_oppo_x, old_oppo_y
    as boolean is_dragging
    as boolean is_lbtn_released
    as boolean is_lbtn_pressed
    as boolean is_rbtn_released
    as boolean is_rbtn_pressed
    Union
        buttons 		As Integer
        Type
            Left:1 		As Integer
            Right:1 	As Integer
            middle:1 	As Integer
        End Type
    End Union
End Type




