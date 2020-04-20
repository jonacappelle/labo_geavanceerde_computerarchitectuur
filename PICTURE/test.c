// includes, system
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

// includes CUDA
#include <cuda_runtime.h>

// includes, project
#include <helper_cuda.h>
#include <helper_functions.h> // helper functions for SDK examples

// own includes
#include "iostream"
#include "cstdlib"
#include "time.h"	// timing on cpu
#include "lodepng.h" // PNG afbeelding inlezen


void decodeOneStep(const char* filename) {
	unsigned error;
	unsigned char* image = 0;
	unsigned width, height;

	error = lodepng_decode32_file(&image, &width, &height, filename);
	if(error) printf("error %u: %s\n", error, lodepng_error_text(error));

	/*use image here*/

	free(image);
}

void encodeOneStep(const char* filename, const unsigned char* image, unsigned width, unsigned height) {
	/*Encode the image*/
	unsigned error = lodepng_encode32_file(filename, image, width, height);

	/*if there's an error, display it*/
	if(error) printf("error %u: %s\n", error, lodepng_error_text(error));
}







int main()
{

	////////////////////////////////////////////////////////////////////////////////
	// Load PNG file
	////////////////////////////////////////////////////////////////////////////////

	const char* filename = argc > 1 ? argv[1] : "test.png";
	
	unsigned error;
	unsigned char* image = 0;
	unsigned width, height;
  
	error = lodepng_decode32_file(&image, &width, &height, filename);
	if(error) printf("error %u: %s\n", error, lodepng_error_text(error));
  
	/*use image here*/
	
	for(int i=0; i<width*height; i++)
	{
		printf("%f", image[i]);
	}

	////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////
}





