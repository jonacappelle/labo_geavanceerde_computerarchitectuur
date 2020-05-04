////////////////////////////////////////////////////////////////////////////////
// GRAYSCALE - EDGE DETECTION -- Jona Cappelle -- Jonas Bolle
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


////////////////////////////////////////////////////////////////////////////////
// SELECT GPU - CPU TIMING
// #define GPU
//#define CPU
////////////////////////////////////////////////////////////////////////////////
// RUN ADD - INV
// #define ADD
// #define INV
////////////////////////////////////////////////////////////////////////////////

// Helper function



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
//__global__ void grayscale(unsigned char* image, unsigned char* grayImage,unsigned width,unsigned height)
//{
//	int absolute_position_x =(blockIdx.x * blockDim.x) + threadIdx.x;
//	int absolute_position_y = (blockIdx.y * blockDim.y) + threadIdx.y;
//	if(absolute_position_x >= width || absolute_position_y >= height){
//		return;
//	}
//
//	float channelSum = .299f * image[absolute_position_x + absolute_position_y * width]
//									 + .587f * image[(absolute_position_x + absolute_position_y * width)+1]
//									 + .114f * image[(absolute_position_x + absolute_position_y * width)+2];
//	grayImage[absolute_position_x + absolute_position_y * width] = channelSum;
//}

__global__ void grayscale(unsigned char* image, unsigned char* grayImage,unsigned width,unsigned height)
{
	int j = (blockIdx.x*blockDim.x + threadIdx.x)*4;

	if(j < width*height*4)
	{
		grayImage[j] = (image[j]+image[j+1]+image[j+2])/3;
		grayImage[j+1] = (image[j]+image[j+1]+image[j+2])/3;
		grayImage[j+2] = (image[j]+image[j+1]+image[j+2])/3;
		grayImage[j+3] = 255;
	}

}

// CPU
void grayscale_cpu(unsigned char* image, unsigned width, unsigned height)
{
	printf("test1");

	for(int j=0; j < (width*height*4); j+=4)
	{
		image[j] = (image[j]+image[j+1]+image[j+2])/3;
		image[j+1] = (image[j]+image[j+1]+image[j+2])/3;
		image[j+2] = (image[j]+image[j+1]+image[j+2])/3;
	}
	printf("test2");
}



////////////////////////////////////////////////////////////////////////////////
// Program main
////////////////////////////////////////////////////////////////////////////////
int main()
{

	printf("testest");


	////////////////////////////////////////////////////////////////////////////////
	// Load PNG file
	////////////////////////////////////////////////////////////////////////////////
	float millis = 0;
	unsigned char *image_in, *image_out, *image_in_dev, *image_out_dev;
	unsigned width, height, width_dev, height_dev;

	printf("test-2");

	const char* filename = "test.png";

	unsigned error;
	unsigned char* image = 0;


	printf("test-1");



	error = lodepng_decode32_file(&image, &width, &height, filename);
	if(error) printf("error %u: %s\n", error, lodepng_error_text(error));



	// allocate arrays on host
	image_in = (unsigned char *)malloc(width*height*4 * sizeof(char));
	image_out = (unsigned char *)malloc(width*height*4 * sizeof(char));


FILE *f = fopen("data.csv", "w");

for (int BLOCKSIZE = 1; BLOCKSIZE < 300; BLOCKSIZE++)
{
	int nBlocks = (width*height*4) / BLOCKSIZE + ((width*height*4) % BLOCKSIZE == 0 ? 0 : 1);
	printf("nBlocks: %d", nBlocks);
	// image wordt goed geprint
//	for(int i=0; i<(width*height*4); i+=4)
//	{
//	printf("%u %u %u %u\n", image[i], image[i+1], image[i+2], image[i+3]);
//	}


//	StopWatchInterface *timer = 0;
//	sdkCreateTimer(&timer);
//	sdkResetTimer(&timer);
//	sdkStartTimer(&timer);

//	grayscale_cpu(image, width, height);

//	sdkStopTimer(&timer);
//	printf("Tijd: %f\n", sdkGetTimerValue(&timer));
//	sdkDeleteTimer(&timer);


	// 	// allocate arrays on device
	cudaMalloc((void **)&image_in_dev, width*height*4 * sizeof(char));
	cudaMalloc((void **)&image_out_dev, width*height*4 * sizeof(char));



	cudaMemcpy(image_in_dev, image, width*height*4*sizeof(char), cudaMemcpyHostToDevice);
	cudaMemcpy(image_out_dev, image_out, width*height*4*sizeof(char), cudaMemcpyHostToDevice);

//	unsigned *width_1 = &width;
//	cudaMemcpy(width_dev, width_1, sizeof(unsigned), cudaMemcpyHostToDevice);
//	cudaMemcpy(height_dev, &height, sizeof(unsigned), cudaMemcpyHostToDevice);

	printf("Dit is van de CPU");
	for(int i=100*4; i<4*120; i+=4)
	{
	printf("%u %u %u %u\n", image[i], image[i+1], image[i+2], image[i+3]);
	}


	// Record time on GPU with cuda events
	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);




	cudaEventRecord(start);
	grayscale <<< nBlocks, BLOCKSIZE >>> ( image_in_dev, image_out_dev, width, height );
	cudaEventRecord(stop);

	cudaMemcpy(image_in, image_in_dev, width*height*4*sizeof(char), cudaMemcpyDeviceToHost);
	cudaMemcpy(image_out, image_out_dev, width*height*4*sizeof(char), cudaMemcpyDeviceToHost);
//	cudaMemcpy(width, width_dev, sizeof(unsigned), cudaMemcpyDeviceToHost);
//	cudaMemcpy(height, height_dev, sizeof(unsigned), cudaMemcpyDeviceToHost);

	printf("Dit is van de GPU");
	for(int i=100*4; i<4*120; i+=4)
		{
		printf("%u %u %u %u\n", image_out[i], image_out[i+1], image_out[i+2], image_out[i+3]);
		}

	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&millis, start, stop);

	printf("Tijd op GPU: %f\n", millis);

	fprintf(f, "%d,%f\n", BLOCKSIZE, millis);

//	cudaEventDestroy(stop);
//	cudaEventDestroy(start);

}
fclose(f);

	const char* output_filename = "output.png";
	encodeOneStep(output_filename, image_out, width, height);


	free(image_in);
	free(image_out);
//	free(width);
//	free(height);
	cudaFree(image_in_dev);
	cudaFree(image_out_dev);
//	cudaFree(width_dev);
//	cudaFree(height_dev);

	printf("Done!");

	return 0;
}
