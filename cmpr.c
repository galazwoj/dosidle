/*	
 * this is a crude utility that compares two files
*/

#include <io.h>
#include <fcntl.h>
#define SEEK_SET 0

#define TABLESIZE	20000
char src[TABLESIZE];
char dst[TABLESIZE];

#define FILE_S "dosidle.exe"
#define FILE_D "dosidlen.exe"
#define DIFF (0x7AE - 0x5AE)

main()
{
	int i,j;
	int ifs, ifd;
	int reads, readd;

	ifs = open(FILE_S,O_RDONLY|O_BINARY);
	if (ifs == 0) {
		puts("src file !");
		exit(1);
	}
	ifd = open(FILE_D,O_RDONLY|O_BINARY);
	if (ifd == 0) {
		puts("dst file !");
		exit(1);
	}
	lseek(ifs, 0, SEEK_SET);
	lseek(ifd, 0, SEEK_SET);
	reads = read(ifs, src, TABLESIZE);
	readd = read(ifd, dst, TABLESIZE);
	printf("read %d bytes\n",reads);
	if (reads != readd) {
		close (ifs);
		close (ifd);	
		puts("src  and dst file size");
		exit(1);
	}
	for (i=0; i <reads; i++) {
		unsigned char s,d;
		s = src[i];
		d = dst[i];
		if (s == d)
			continue;
		j = i - DIFF;
		if (j < 0)	
			printf("!%6x '%x' '%x'\n", i  ,s ,d);
		else
			printf("%6x '%x' '%x'\n", j  ,s ,d);
	}
	close (ifs);
	close (ifd);	
	return 0;
}
