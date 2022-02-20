#include <stdio.h>
#include <time.h>

void compute(void);

void main()
{
   time_t start_time, end_time;
   // start_time = time(NULL);
   struct tm time_of_day;
   time_t ltime;
   auto char buf[26];

   compute();
   // end_time = time(NULL);
   time(&ltime);
   _localtime(&ltime, &time_of_day);
   printf("Date and time is: %s\n",
          _asctime(&time_of_day, buf));
   // printf("Elapsed time: %f seconds\n",
   //        difftime(end_time, start_time));
}
void compute(void)
{
   int i, j;
   for (i = 1; i <= 20; i++)
   {
      for (j = 1; j <= 20; j++)
         printf("%3d ", i * j);
      printf("\n");
   }
}
