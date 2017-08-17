declare function add (	head as p_proto ptr ptr, x as single, y as single) as p_proto ptr
declare function dist (x1 as single, y1 as single, x2 as single, y2 as single) as single
declare function get_nearest_node(head as p_proto ptr, x as integer, y as integer) as p_proto ptr
declare function get_nodes_number(head as p_proto ptr) as integer

function add 	(head as p_proto ptr ptr, x as single, y as single) as p_proto ptr
    dim as p_proto ptr p = callocate(sizeof(p_proto))
    p->x = x
    p->y = y
	p->next_p = *head
    *head = p
    return p
end function

function add_edge_to_vertex	(	head as edge_proto ptr ptr, _
								start as p_proto ptr, _
								target as p_proto ptr) as edge_proto ptr
    if start <> target then
    	dim as edge_proto ptr p = callocate(sizeof(p_proto))
		p->start = start
		p->target = target
		p->next_p = *head
		*head = p

		return p
    end if
end function

function dist (x1 as single, y1 as single, x2 as single, y2 as single) as single
    return Sqr(((x1-x2)*(x1-x2))+((y1-y2)*(y1-y2)))
end function

function get_nearest_node(head as p_proto ptr, x as integer, y as integer) as p_proto ptr

    dim as single max_dist = 10000.0f
    dim nearest_node as p_proto ptr
    
	while (head <> NULL)
		if int(dist(x,y,head->x, head->y)) < max_dist then
			max_dist =  (dist(x,y,head->x, head->y))
			nearest_node = head
		end if
		head = head->next_p
	wend
	
	return nearest_node

end function

function get_nodes_number(head as p_proto ptr) as integer
	dim c as integer
	while (head <> NULL)
		c+=1
		head = head->next_p
	wend
	return c
end function

function draw_current_tool (tool as proto_input_mode) as string
	select case tool
		case add_vertex
			return "add Vertex"
		case move_vertex
			return "             Move vertex"
		case add_edge
			return "                           add Edge"
		case del_edge
			return "                                      Delete edge"
	end select
end function

function del_an_edge(edge as edge_proto ptr, value as p_proto ptr) as edge_proto ptr
	'thanks to http://www.cs.bu.edu/teaching/c/linked-list/delete/
	
  'Check if the end of list has been reached.
  if (edge = NULL) then return NULL

 ' Check to see if current node has to be deleted
  if (edge->start = value or edge->target = value) then
    dim tmp_next_p as edge_proto ptr
    'Save the next pointer in the node
    tmp_next_p = edge->next_p
    'Deallocate the node
    Deallocate(edge)
    return tmp_next_p
  end if

  'Check the rest of the list, adjusting the next_p pointer
  'in case that the next node is the one deleted.
  edge->next_p = del_an_edge(edge->next_p, value)
  return edge
end function




