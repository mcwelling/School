CS543
Assignment 3
McWelling Todman

Overview
	- I opted to follow the approach recommended by Prof BLS in recitation. After basic modifications were made to the Pool structure to support Slab allocation, each of the key functions in the memory allocation process were modified such that eligible block adds and requests would be routed to the slab, but otherwise maintaining default behavior.


Change Log
	- dopoolalloc()
		- conditional logic is used to screen request size against the slab bucket range. If there is a match, we round to the nearest power of two and perform the allocation using a block from the slab. In the event the conditions are not met, we default to searching the free tree.
	- pooladd()
		- a preliminary conditional check is used to divert block headers meeting the slab criteria to the slab rather than the free tree or associated doubly linked lists.
	- poolfree()
		- if the block header is in the slab range (32b to 4096b), coalescing is prevented.
	- pooldel()
		- conditional logic causes the function to return if the prev pointer in the block header is nil. This prevents the function from attempting to execute on items in the slab.


Testing Summary
	- I did not have time to run significant testing beyond that which was outlined by prof BLS in the recitation (see note below).
		- bitwise exponentiation validation (step 1)
		- used printing to track frequencies around standard allocation methods with slab functionality disabled (step 2)
		- using print frequency was able to confirm allocations with slab functionality enabled (step 3)


A personal note
	- I did not start working on this until Monday (25th). My grandmother was hospitalized in the earlier hours of Friday (22nd) morning after having a stroke, so I've been a bit pre-occupied with helping my mother manage the fallout/medical details and trying to keep up with work (I work full-time).
