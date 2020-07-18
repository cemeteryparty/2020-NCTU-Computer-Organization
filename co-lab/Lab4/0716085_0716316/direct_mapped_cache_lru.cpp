#include <iostream>
#include <cstdio>
#include <cmath>
#include <vector>

using namespace std;

int n_ways = 8;

struct cache_content{
	bool v;
	unsigned int tag;
	int time_stamp;

};

const int K = 1024;
void simulate(int cache_size, int block_size){
	int block_count = cache_size / block_size;
	int line = block_count / n_ways;
	int offset_bit = (int)log2(block_size);
	int index_bit = (int)log2(line);

	vector<vector<cache_content> > cache(line, vector<cache_content>(n_ways));
	for(int i = 0;i < line;i++)
		for(int j = 0; j < n_ways; j++){
			cache[i][j].v = false;
			cache[i][j].time_stamp = -1;
		}

	int instr_count = 0,miss_count = 0;
	unsigned int tag, index, x;
	FILE *fp = fopen("RADIX.txt", "r");  // read file
	while(fscanf(fp, "%x", &x) != EOF){
		instr_count++;
		bool hit = false;
		index = (x >> (offset_bit)) & (line - 1);
		tag = x >> (index_bit + offset_bit);
		for(int i = 0;i < n_ways;i++)
			if(cache[index][i].v && cache[index][i].tag == tag){ // hit
				hit = true;
				cache[index][i].time_stamp = instr_count;
				break;
			}
		if(!hit){ // miss
			miss_count++;
			int lru = 0, longestT = cache[index][0].time_stamp;
			for(int i = 0;i < n_ways;i++){
				if(cache[index][i].time_stamp == -1){
					lru = i;
					break;
				}
				if(cache[index][i].time_stamp < longestT){
					lru = i;
					longestT = cache[index][i].time_stamp;
				}
			}
			cache[index][lru].v = true;
			cache[index][lru].tag = tag;
			cache[index][lru].time_stamp = instr_count;
		}
	}
	printf("Miss Rate = %d / %d = %f\n",miss_count,instr_count,(float)miss_count / instr_count);
}

int main(int argc, const char *argv[]){
	// Let us simulate 4KB cache with 16B blocks
	//simulate(4 * K, 16);
	printf("%d ways\n",n_ways);
	for(int i = 4;i <= 256;i <<= 2)
		for(int j = 16;j <= 256;j <<= 1){
			//if(j != 64)
			//	continue;
			printf("cache: %d, block: %d\n",i * K,j);
			simulate(i * K,j);
		}
	return 0;
}
