int main()
{
   int a = 5;
   int b = 4;
   int c = 3;
   b = fun(a) + simple(a,b,c,5,10);
   while(1);
}


int fun(int x)
{
   if (x == 0)
      return 1;
   else
      return x+fun(x-1);
}
int simple(int a, int b, int c, int d, int e)
{
   int x, y;
   x = a+b+c;
   y = d-e;
   x = x + y;
   x = x & 7;
   return x;
}

