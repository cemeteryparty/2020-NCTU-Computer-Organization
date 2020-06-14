#include <iostream>
#include <cmath>
#include <vector>
#include <cstdio>

using namespace std;
/*
vector<float> miss_rates;
vector<int> blk_sizes;
vector<int> cach_sizes;
*/
struct cache_content{
	bool v;
	unsigned int tag;
};

const int K = 1024;


void simulate(int cache_size, int block_size,char *filename){
	printf("cache: %d, block: %d\n",cache_size,block_size);
	unsigned int tag, index, x;

	int offset_bit = (int)log2(block_size);
	int index_bit = (int)log2(cache_size / block_size);
	int line = cache_size >> (offset_bit);

	vector<cache_content> cache(line);
	
	printf("cache line: %d\n",line);

	for(int j = 0; j < line; j++)
		cache[j].v = false;
	
	FILE *fp = fopen(filename, "r");  // read file
	int instr_count = 0,miss_count = 0;
	while(fscanf(fp, "%x", &x) != EOF){
		instr_count++;
		index = (x >> offset_bit) & (line - 1);
		tag = x >> (index_bit + offset_bit);
		//printf("data = %x\tindex = %d\ttag = %d\n",x,index,tag);
		if(cache[index].v && cache[index].tag == tag)
			cache[index].v = true;    // hit
		else{
			cache[index].v = true;  // miss
			cache[index].tag = tag;
			miss_count++;
		}
	}
	fclose(fp);
	
	printf("Miss Rate = %f\n",(float)miss_count / instr_count);
	/*
	cach_sizes.push_back(cache_size);
	blk_sizes.push_back(block_size);
	miss_rates.push_back((float)miss_count / instr_count);
	*/
}
	
int main(){
	// Let us simulate 4KB cache with 16B blocks
	//simulate(4 * K, 16);
	char f1[] = "ICACHE.txt",f2[] = "DCACHE.txt";
	printf("%s:\n",f1);
	for(int i = 4;i <= 256;i <<= 2)
		for(int j = 16;j <= 256;j <<= 1)
			simulate(i * K,j,f1);
	printf("%s:\n",f2);
	for(int i = 4;i <= 256;i <<= 2)
		for(int j = 16;j <= 256;j <<= 1)
			simulate(i * K,j,f2);
	/*
	FILE *fw = fopen("ans.txt", "w");
	for(int i = 0; i < miss_rates.size(); i++)
        	fprintf(fw, "%d %d %f\n", cach_sizes[i], blk_sizes[i], miss_rates[i]);
    */
    	return 0;
}
