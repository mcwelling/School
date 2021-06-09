McWelling H Todman
CS583 - Introduction to Computer Vision
Drexel University: CCI

ReadMe for Seam Carving implementation

Program: final.py

Dependencies:
	- argparse
	- imageio
	- logging
	- numpy
	- PIL
	- scipy 
	

Instructions:
	- create a directory to hold final.py and all associated input images.
	- the program can be called from the command line as follows:

python3 final.py <input_img.jpg> <output_img.jpg> [h/v] [scale (float)]

	- Parameters:
		1. input image - must be a jpg
		2. output image - must be a jpg
		3. direction - 'h' for horizontal, 'v' for vertical
		4. scale - must be a float between (0, 2)

Notes:
	- all images must be .jpg
	- all images must be 3-channel color images
