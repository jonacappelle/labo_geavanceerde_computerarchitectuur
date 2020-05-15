////////////////////////////////////////////////////////////////////////////////
// EDGE DETECTION -- Jona Cappelle -- Jonas Bolle
////////////////////////////////////////////////////////////////////////////////

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

extern "C"

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

////////////////////////////////////////////////////////////////////////////////
// KERNEL GRAYSCALE
////////////////////////////////////////////////////////////////////////////////
int BLOCKSIZE;

// GPU
__global__ void edge(unsigned char* orig, unsigned char* result,unsigned width,unsigned height)
{

	int x = (threadIdx.x + blockIdx.x * blockDim.x)*4;
    int y = (threadIdx.y + blockIdx.y * blockDim.y);
    float dx, dy;
    width=4*width;
    if( x > 0 && y > 0 && x < (width-1) && y < (height-1)) {
        dx = (-1* orig[(y-1)*width + (x-4)]) + (-2*orig[y*width+(x-4)]) + (-1*orig[(y+1)*width+(x-4)]) +
             (    orig[(y-1)*width + (x+4)]) + ( 2*orig[y*width+(x+4)]) + (   orig[(y+1)*width+(x+4)]);
        dy = (    orig[(y-1)*width + (x-4)]) + ( 2*orig[(y-1)*width+x]) + (   orig[(y-1)*width+(x+4)]) +
             (-1* orig[(y+1)*width + (x-4)]) + (-2*orig[(y+1)*width+x]) + (-1*orig[(y+1)*width+(x+4)]);
        result[y*width + x] = sqrt( (dx*dx) + (dy*dy) );
        result[y*width + x + 1] = sqrt( (dx*dx) + (dy*dy) );
        result[y*width + x + 2] = sqrt( (dx*dx) + (dy*dy) );
        result[y*width + x + 3] = 255;
    }

}

// CPU
void edge_cpu(unsigned char* image, unsigned width, unsigned height)
{
	printf("test1");

	for(int j=0; j < (width*height*4); j+=4)
	{
		image[j] = (image[j]+image[j+1]+image[j+2])/3;
		image[j+1] = (image[j]+image[j+1]+image[j+2])/3;
		image[j+2] = (image[j]+image[j+1]+image[j+2])/3;

		if((image[j+4] - image[j]) > 5 )
		{
			image[j] = image[j+1] =image[j+2]= 255;
		}else{
			image[j] = image[j+1] =image[j+2]= 0;
		}

	}
	printf("test2");
}



////////////////////////////////////////////////////////////////////////////////
// Program main
////////////////////////////////////////////////////////////////////////////////
int main()
{
	////////////////////////////////////////////////////////////////////////////////
	// Load PNG file
	////////////////////////////////////////////////////////////////////////////////
	float millis = 0;
	unsigned char *image_in, *image_out, *image_in_dev, *image_out_dev;
	unsigned width, height, width_dev, height_dev;

	const char* filename = "test.png";

	unsigned error;
	unsigned char* image = 0;

	error = lodepng_decode32_file(&image, &width, &height, filename);
	if(error) printf("error %u: %s\n", error, lodepng_error_text(error));

	// allocate arrays on host
	image_in = (unsigned char *)malloc(width*height*4 * sizeof(char));
	image_out = (unsigned char *)malloc(width*height*4 * sizeof(char));


	FILE *f = fopen("data.csv", "w");

//	StopWatchInterface *timer = 0;
//	sdkCreateTimer(&timer);
//	sdkResetTimer(&timer);
//	sdkStartTimer(&timer);

//	edge_cpu(image, width, height);

//	sdkStopTimer(&timer);
//	printf("Tijd: %f\n", sdkGetTimerValue(&timer));
//	sdkDeleteTimer(&timer);

	// Grayscale on CPU
	for(int j=0; j < (width*height*4); j+=4)
	{
		image[j] = (image[j]+image[j+1]+image[j+2])/3;
		image[j+1] = (image[j]+image[j+1]+image[j+2])/3;
		image[j+2] = (image[j]+image[j+1]+image[j+2])/3;
	}

	// Allocate arrays on device
	cudaMalloc((void **)&image_in_dev, width*height*4 * sizeof(char));
	cudaMalloc((void **)&image_out_dev, width*height*4 * sizeof(char));

	cudaMemcpy(image_in_dev, image, width*height*4*sizeof(char), cudaMemcpyHostToDevice);
	cudaMemcpy(image_out_dev, image_out, width*height*4*sizeof(char), cudaMemcpyHostToDevice);

	// Record time on GPU with cuda events
	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);

	///////////////////////////
	// Choose Blocksize & nBlock in 2D
	dim3 BLOCKSIZE(64,16);
	dim3 nBlocks(ceil(width/64),ceil(height/16));
	///////////////////////////

	cudaEventRecord(start);
	edge <<< nBlocks, BLOCKSIZE >>> ( image_in_dev, image_out_dev, width, height );
	cudaEventRecord(stop);

	cudaMemcpy(image_in, image_in_dev, width*height*4*sizeof(char), cudaMemcpyDeviceToHost);
	cudaMemcpy(image_out, image_out_dev, width*height*4*sizeof(char), cudaMemcpyDeviceToHost);

	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&millis, start, stop);

	printf("Tijd op GPU: %f\n", millis);

//	fprintf(f, "%d,%f\n", BLOCKSIZE, millis);

	fclose(f);

	const char* output_filename = "output.png";
	encodeOneStep(output_filename, image_out, width, height);

	free(image_in);
	free(image_out);

	cudaFree(image_in_dev);
	cudaFree(image_out_dev);

	printf("Done!");

	return 0;
}
