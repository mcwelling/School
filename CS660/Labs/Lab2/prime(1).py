def is_prime(n):
   if (n < 2):
     return False
   d = 2
   while d*d <= n:
     if (n % d) == 0:
       return False
     d = d+1
   return True

def primes(a, b):
  for p in range(a, b + 1):
    if is_prime(p):
      yield p

def sum_primes(a, b):
  accum = 0
  for x in range(a, b+1):
    if is_prime(x):
      accum += x
  return accum
