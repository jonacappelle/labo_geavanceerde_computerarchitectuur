////////////////////////////////////////////////////////////////////////////////
// ADD / INVERT -- Jona Cappelle -- Jonas Bolle
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

// eigen includes
#include "iostream"
#include "cstdlib"

extern "C"
#define ARRAYSIZE 100 // Is also the number of threads that will be used
#define BLOCKSIZE

////////////////////////////////////////////////////////////////////////////////
// KERNEL ADD
////////////////////////////////////////////////////////////////////////////////
int BLOCKSIZE;
int nBlocks;
// GPU
__global__ void add(int *a, int *b, int *out)
{
	int idx = blockIdx.x * blockDim.x + threadIdx.x;
	if (idx < ARRAYSIZE)
	{
		out[idx] = a[idx] + b[idx];
	}
}

// CPU
void add(int *a, int *b, int *out)
{
	for (int i = 0; i < ARRAYSIZE; i++)
	{
		out[i] = a[i] + b[i];
	}
}

////////////////////////////////////////////////////////////////////////////////
// KERNEL INVERT
////////////////////////////////////////////////////////////////////////////////
int BLOCKSIZE;
int nBlocks;

// GPU
__global__ void invert(int *a, int *out)
{
	int idx = blockIdx.x * blockDim.x + threadIdx.x;
	if (idx < ARRAYSIZE)
	{
		out[idx] = a[ARRAYSIZE - idx]
	}
}

// CPU
void invert(int *a, int *out)
{
	for (int i = 0; i < ARRAYSIZE; i++)
	{
		out[i] = a[ARRAYSIZE - i];
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
	a_host = (int *)malloc(ARRAYSIZE * sizeof(int));

	b_host = (int *)malloc(ARRAYSIZE * sizeof(int));
	out_host = (int *)malloc(ARRAYSIZE * sizeof(int));

	//allocate arrays on device
	cudaMalloc((void **)&a_dev, ARRAYSIZE * sizeof(int));
	cudaMalloc((void **)&b_dev, ARRAYSIZE * sizeof(int));
	cudaMalloc((void **)&out_dev, ARRAYSIZE * sizeof(int));

	//Step 1: Copy data to GPU memory
	cudaMemcpy(a_dev, a_host, ARRAYSIZE * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(b_dev, b_host, ARRAYSIZE * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(out_dev, out_host, ARRAYSIZE * sizeof(int), cudaMemcpyHostToDevice);

	// Initialize data file where the timing results will be stored
	FILE *f = fopen("data.csv", "w");

	for (BLOCKSIZE = 1; BLOCKSIZE < 1024; BLOCKSIZE++)
	{
		// Calculate amount of blocks needed
		int nBlocks = ARRAYSIZE / BLOCKSIZE + (ARRAYSIZE % BLOCKSIZE == 0 ? 0 : 1);
		printf("Nblocks: %i", nBlocks);

		// Start timer
		StopWatchInterface *timer = 0;
		sdkCreateTimer(&timer);
		sdkStartTimer(&timer);

		////////////////////////////////////////////////////////////////////////////////
		// GPU -- comment / uncomment to run 'ADD' / 'INVERT'
		////////////////////////////////////////////////////////////////////////////////
		add<<<nBlocks, BLOCKSIZE>>>(a_dev, b_dev, out_dev);
		// invert <<< nBlocks, BLOCKSIZE >>> ( a_dev, out_dev );

		////////////////////////////////////////////////////////////////////////////////
		// CPU -- comment / uncomment to run 'ADD' / 'INVERT'
		////////////////////////////////////////////////////////////////////////////////
		// add( a_dev, b_dev, out_dev );
		// invert ( a_dev, out_dev );

		// Stop timer
		sdkStopTimer(&timer);
		printf("Processing time: %f (ms)\n", sdkGetTimerValue(&timer));

		// Write timing results to file
		fprintf(f, "%d,%f\n", BLOCKSIZE, sdkGetTimerValue(&timer));

		// Verwijder timer
		sdkDeleteTimer(&timer);

	} //End for

	// Close the file
	fclose(f);

	//Step 4: Retrieve result
	cudaMemcpy(a_host, a_dev, ARRAYSIZE * sizeof(int), cudaMemcpyDeviceToHost);
	cudaMemcpy(b_host, b_dev, ARRAYSIZE * sizeof(int), cudaMemcpyDeviceToHost);
	cudaMemcpy(out_host, out_dev, ARRAYSIZE * sizeof(int), cudaMemcpyDeviceToHost);

	// Free up the used memory
	free(a_host);
	free(b_host);
	free(out_host);
	cudaFree(a_dev);
	cudaFree(b_dev);
	cudaFree(out_dev);

	return 0;
}
