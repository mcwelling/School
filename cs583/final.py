#   McWelling Todman (mht47@drexel.edu)
#   CS583 Introduction to Computer Vision
#   Final Project - Seam Carving

"""
Example Call: python3 final.py <input_img.jpg> <output_img.jpg> [h/v] [scale (float)]
"""

"""
Imports
"""
import argparse
import imageio
import logging
import numpy as np
from PIL import Image
from scipy.ndimage.filters import convolve


def load_image(filename):
    """
    Loads the provided image file, and returns it as a numpy array.
    """
    im = Image.open(filename)
    return np.array(im)


def sobel_operators():
    # generate 3d sobel operators to be used in convolution across 3 channel images
    sobelX = np.array([[1,0,-1],[2,0,-2],[1,0,-1]], dtype=np.float32)
    sobelX /= np.linalg.norm(sobelX)
    sobelY = sobelX.transpose()
    sobelX *= -1
    sobelY *= -1
    sobelX = np.tile(sobelX[:,:,None], [1,1,3])
    sobelY = np.tile(sobelY[:,:,None], [1,1,3])
    return sobelX, sobelY


def get_energy_map(img):

    """ 
    produces an energy map for a supplied 3-channel image 
    """

    # converts image datatype from uint-8 to float
    img = np.float32(img)
    
    # generate 3d sobel opertors
    sobelX, sobelY = sobel_operators()

    # operator e_1(I) = |d/dx*I| + |d/dy*I|
    xGradient = np.absolute(convolve(img, sobelX))
    yGradient = np.absolute(convolve(img, sobelY))
    energy = xGradient + yGradient
    emap = energy.sum(axis=2)
    
    return emap


def compute_seam(map):
    """ 
    given an energy map, determine the vertical seam with least energy
    returns an energy map as well as the logbook used for backtracking 
    """

    egrid = map.copy()
    logbook = np.zeros((len(map), len(map[0])), dtype=int)

    for row in range(1, len(map)): # start on row two (we already know the energy for row 1)
        for col in range(len(map[0])):
            if col == 0:
                # finds index of min linked value in row above
                min_above_idx = np.argmin(egrid[row - 1][col:col + 1])

                # logs the index of the min linked value for future reference
                logbook[row][col] = min_above_idx + col

                # grabs the minimum energy value by index
                min_energy = egrid[row - 1, min_above_idx + col]
            else:
                # finds index of min linked value in row above
                min_above_idx = np.argmin(egrid[row - 1][col - 1:col + 1])

                # logs the index of the min linked value for future reference
                logbook[row][col] = min_above_idx + col - 1

                # grabs the minimum energy value by index
                min_energy = egrid[row - 1, min_above_idx + col - 1]

            # update the running energy tally in the grid with the min energy from the previous cycle
            egrid[row, col] += min_energy

    return egrid, logbook


def remove_seam(img):
    """
    determines the minimum energy seam and removes it from the image
    returns the modified image as well as the column coordinates of the pixels removed
    """

    rows, cols, dims = img.shape
    
    emap = get_energy_map(img)
    egrid, logbook = compute_seam(emap)

    seam_mask = np.ones((rows, cols), dtype=np.bool8)

    # find the smallest aggregate value from the last row
    minCol = np.argmin(egrid[len(egrid)-1])
    seam_idx = []

    # loop through min available connect col in each row from bottom to top
    # log indices in the logbook as well as the seam index structure
    # update mask to reflect the optimal seam
    for row in reversed(range(rows)):
        seam_mask[row][minCol] = False
        seam_idx.append(minCol)
        minCol = logbook[row][minCol]

    # convery mask to 3 channel format
    seam_mask = np.tile(seam_mask[:,:,None],[1,1,3])

    # remove the seam
    img = img[seam_mask].reshape((rows, cols - 1, 3))

    return img, seam_idx


def add_vseam(img, indices):
    """
    adds a vertical seam to the image at the seam indices outlined in the supplied parameter
    returns an extended image
    """

    rows, cols, dims = img.shape

    # add a column to the image (we are adding a seam)
    img_xtnd = np.zeros((rows, cols+1, 3))

    # for each row, append a new pixel with the average l-r surrounding pixel weight at the specified col index
    # 1 row at a time per channel in the image
    for row in range(rows):
        col = indices[row]
        for channel in range(dims):
            if col == 0:
                avg_pixel_nrg = np.average(img[row, col:col+1, channel])
                img_xtnd[row, :col, channel] = img[row, :col, channel]
                img_xtnd[row, col+1, channel] = avg_pixel_nrg
                img_xtnd[row, col+1:, channel] = img[row, col:, channel]
            else:
                avg_pixel_nrg = np.average(img[row, col-1:col+1, channel])
                img_xtnd[row, :col, channel] = img[row, :col, channel]
                img_xtnd[row, col, channel] = avg_pixel_nrg
                img_xtnd[row, col+1:, channel] = img[row, col:, channel]
    
    return img_xtnd


#   
#   final functions to be called
#   

def hreduce_img(img, scale_factor):
    """
    returns horizontally reduced image
    """
    
    rows, cols, dims = img.shape

    reduced_size = int(np.round(scale_factor * cols))

    for seam in range(cols - reduced_size):
        img, idx = remove_seam(img)
    
    return img


def vreduce_img(img, scale_factor):
    """
    returns vertically reduced image
    """

    img = np.rot90(img, 1, (0,1))
    img = hreduce_img(img, scale_factor)
    img = np.rot90(img, 3, (0,1))

    return img


def henlarge_img(img, scale_factor):
    """
    returns horizontally enlarged image
    """

    rows, cols, dims = img.shape

    # determine number of seams to be computed
    increased_size = int(np.round(scale_factor * cols))
    seams_to_add = increased_size - cols

    seams = []
    working_img = img.copy()

    # populate the list of seams to be added by removing optimal seams from a dummy image
    for seam in range(seams_to_add):
        working_img, idx = remove_seam(working_img)
        seams.append(idx)
    
    # flip the list of seams to they can be added in reverse
    seams.reverse()
    seams = np.array(seams)

    # add seams to the image, increment the coordinates of the remainders that come after the new seam
    for seam in range(seams_to_add):
        current_seam = seams[-1]
        seams = seams[:-1]
        img = add_vseam(img, current_seam)

        for remainder in seams:
            remainder[np.where(remainder >= current_seam)] += 2

    return img


def venlarge_img(img, scale_factor):
    """
        returns vertically enlarged image
    """

    img = np.rot90(img, 1, (0,1))
    img = henlarge_img(img, scale_factor)
    img = np.rot90(img, 3, (0,1))

    return img


#
### MAIN FUNCTION
#

if __name__ == '__main__':
    logging.basicConfig(
        format='%(levelname)s: %(message)s', level=logging.INFO)
    parser = argparse.ArgumentParser(
        description='Blurs an image using an isotropic Gaussian kernel.')
    parser.add_argument('input', type=str, help='The input image file to blur')
    parser.add_argument('output', type=str, help='Where to save the result')
    parser.add_argument('direction', type=str, help='whether to modify horizontally or vertically')
    parser.add_argument('scale', type=np.float32, help='scale to change image by')

    args = parser.parse_args()

    # first load the input image
    logging.info('Loading input image %s' % (args.input))
    inputImage = load_image(args.input)

    # optional mechanism for producing an energy map -- simply comment out the if/else below
    #resultImage = get_energy_map(inputImage)

    logging.info('Carving input image %s' % (args.input))
    if args.scale <1.0:
        if args.direction == 'h':
            resultImage = hreduce_img(inputImage, args.scale)
        if args.direction == 'v':
            resultImage = vreduce_img(inputImage, args.scale)
    else:
        if args.direction == 'h':
            resultImage = henlarge_img(inputImage, args.scale)
        if args.direction == 'v':
            resultImage = venlarge_img(inputImage, args.scale)

    # save the result
    logging.info('Saving result to %s' % (args.output))
    imageio.imwrite(args.output, resultImage)