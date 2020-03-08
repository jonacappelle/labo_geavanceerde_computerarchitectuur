////////////////////////////////////////////////////////////////////////////
//
// Copyright 1993-2015 NVIDIA Corporation.  All rights reserved.
//
// Please refer to the NVIDIA end user license agreement (EULA) associated
// with this source code for terms and conditions that govern your use of
// this software. Any use, reproduction, disclosure, or distribution of
// this software and related documentation outside the terms of the EULA
// is strictly prohibited.
//
////////////////////////////////////////////////////////////////////////////

/* Template project which demonstrates the basics on how to setup a project
* example application.
* Host code.
*/

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

//eigen includes
#include "iostream"
#include "cstdlib"


////////////////////////////////////////////////////////////////////////////////
// declaration, forward
extern "C"
void computeGold(float *reference, float *idata, const unsigned int len);


// KERNEL





#define ARRAYSIZE 100
//#define BLOCKSIZE
int BLOCKSIZE;

int nBlocks;


// Kernel
__global__ void add(int *a, int *b, int *out){
	int idx = blockIdx.x*blockDim.x + threadIdx.x;
	if (idx < ARRAYSIZE){
		out[idx] = a[idx] + b[idx];
	}
}


////////////////////////////////////////////////////////////////////////////////
// Program main
////////////////////////////////////////////////////////////////////////////////
int main()
{

	//declare variables
		int *a_host, *b_host, *out_host;
		int *a_dev, *b_dev, *out_dev;


		//allocate arrays on host
		a_host = (int*)malloc(ARRAYSIZE * sizeof(int));

		b_host = (int *)malloc(ARRAYSIZE * sizeof(int));
		out_host = (int *)malloc(ARRAYSIZE * sizeof(int));

		//allocate arrays on device
		cudaMalloc((void **) &a_dev, ARRAYSIZE * sizeof(int));
		cudaMalloc((void **) &b_dev, ARRAYSIZE * sizeof(int));
		cudaMalloc((void **) &out_dev, ARRAYSIZE * sizeof(int));


	//rest of program (Other 4 steps go here)

	//Step 1: Copy data to GPU memory

	cudaMemcpy(a_dev, a_host, ARRAYSIZE * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(b_dev, b_host, ARRAYSIZE * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(out_dev, out_host, ARRAYSIZE * sizeof(int), cudaMemcpyHostToDevice);


	FILE *f = fopen("data.csv", "w");

for ( BLOCKSIZE = 1; BLOCKSIZE < 1024; BLOCKSIZE++ )
{
	int nBlocks = ARRAYSIZE/BLOCKSIZE + (ARRAYSIZE%BLOCKSIZE == 0?0:1);
	printf("Nblocks: %i", nBlocks);

	// Measure time
    StopWatchInterface *timer = 0;
    sdkCreateTimer(&timer);
    sdkStartTimer(&timer);

	add <<< nBlocks, BLOCKSIZE >>> (a_dev, b_dev, out_dev);

    sdkStopTimer(&timer);
    printf("Processing time: %f (ms)\n", sdkGetTimerValue(&timer));


    fprintf(f, "%d,%f\n", BLOCKSIZE, sdkGetTimerValue(&timer));



    sdkDeleteTimer(&timer);

}//End for

	fclose(f);



	//Step 4: Retrieve result
	cudaMemcpy(a_host, a_dev, ARRAYSIZE * sizeof(int), 	cudaMemcpyDeviceToHost);
	cudaMemcpy(b_host, b_dev, ARRAYSIZE * sizeof(int), 	cudaMemcpyDeviceToHost);
	cudaMemcpy(out_host, out_dev, ARRAYSIZE * sizeof(int), 	cudaMemcpyDeviceToHost);


	//end of  program
	//cleanup: VERY IMPORTANT!!!
	free(a_host); free(b_host); free(out_host); cudaFree(a_dev); cudaFree(b_dev); cudaFree(out_dev);

return 0;
}
