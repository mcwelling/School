

def my_range(a, b):
  i = a
  R = []
  while i < b:
    R.append(i)
    i = i + 1
  return R

class MyNumbers:
  def __init__(self, start, end):
    self.a0 = start
    self.b = end

  def __iter__(self):
    self.a = self.a0
    return self

  def __next__(self):
    if self.a < self.b:
      x = self.a
      self.a += 1
      return x
    else:
      raise StopIteration

def my_range_delayed(a, b):
  i = a
  while i < b:
    yield i
    i = i + 1
