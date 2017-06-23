import numpy as np
import matplotlib.pyplot as plt
n = 1000
x = np.random.randn(1000)
y1 = x + np.random.randn(1000)
y2 = -x + np.random.randn(1000)
y3 = np.random.randn(1000)
y4 = x*x + np.random.randn(1000)

print("(x,y1) ")
print(np.corrcoef(x,y1)[0][1])
print("(x,y2) ")
print(np.corrcoef(x,y2)[0][1])
print("(x,y3) ")
print(np.corrcoef(x,y3)[0][1])
print("(x,y4) ")
print(np.corrcoef(x,y4)[0][1])
