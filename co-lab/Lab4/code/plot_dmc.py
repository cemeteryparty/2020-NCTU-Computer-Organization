from matplotlib import pyplot as plt

def main():
	fin = open("ans.txt",'r')
	table = []
	for line in fin.readlines():
		arr = line.strip().split(' ')
		table.append(float(arr[2]) * 100)
	
	x = [16,32,64,128,256]
	#x = [1,2,3,4,5]
	c4 = table[0:5]
	c16 = table[5:10]
	c64 = table[10:15]
	c256 = table[15:20]

	plt.plot(x,c4,'s-',color = 'r',label="cache 4K")
	plt.plot(x,c16,'o-',color = 'g',label="cache 16K")
	plt.plot(x,c64,'*-',color = 'y',label="cache 64K")
	plt.plot(x,c256,'1-',color = 'b',label="cache 256K")
	plt.title("RADIX (one-way)",fontsize = 20)
	plt.xticks(x)
	plt.xlabel("block size (B)",fontsize = 20,labelpad = 15)
	plt.ylabel("miss rate (%)",fontsize = 20,labelpad = 15)
	plt.legend(loc = "best",fontsize = 20)
	plt.show()
if __name__ == '__main__':
    main()