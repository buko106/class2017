#coding:utf-8
 
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d.axes3d import Axes3D

N = 100
d = 3
# 標準正規分布(を平均の分だけずらしたもの)に従う3つの系列のデータを生成
A =  np.random.randn(N,d) + [7,7,0]
B =  np.random.randn(N,d) + [0,7,7]
C =  np.random.randn(N,d) + [7,0,7]

# 生成したデータの確認用
fig = plt.figure()
ax =  Axes3D(fig)
ax.plot(A[:,0],A[:,1],A[:,2], "o" , color="blue")
ax.plot(B[:,0],B[:,1],B[:,2], "o" , color="red")
ax.plot(C[:,0],C[:,1],C[:,2], "o" , color="yellow")
plt.show()

# x = concat(A,B,C)
x = np.concatenate((A,B,C),axis=0)

# cを計算
c = np.zeros([d,d])
for i in range(0,x[:,0].size):
    for j in range(0,d):
        for k in range(0,d):
            c[j][k] += x[i][j] * x[i][k]

# 正規化された固有ベクトルを生成
l,v = np.linalg.eig(c)
# 固有値の順にソート
idx= l.argsort()[::-1]
l = l[idx]
v = v[idx]

# T_{PCA}を生成
T = v[range(0,2)]
# 2次元に投影しプロット
zx,zy=T.dot(x.T)
plt.scatter(zx,zy)
plt.show()

c = 3
mu = np.array([ [zx[0],zy[0]] , [zx[1],zy[1]] , [zx[2],zy[2]] ] )


y = np.array( [0]*zx.size)
oldy = np.array( [1]*zx.size)
# 3つのクラスタに分ける
idx = np.array(range(0,y.size))
i = 1

# 変化がなくなるまでクラスタ中心を探索
while not np.array_equal(y,oldy):
    oldy = np.array(y)
    for i in range(0,zx.size):
        L = np.array( [0.0] * c )
        xy = np.array([zx[i],zy[i]])
        for j in range(0,c):
            L[j] = np.linalg.norm(xy-mu[j])
        # 最近傍のクラスタを選ぶ
        y[i] = L.argmin()
    id0 = idx[np.where(y[idx]==0)]
    id1 = idx[np.where(y[idx]==1)]
    id2 = idx[np.where(y[idx]==2)]
    mu  = np.array( [[ np.average(zx[id0]),np.average(zy[id0]) ] ,[ np.average(zx[id1]),np.average(zy[id1]) ],[ np.average(zx[id2]),np.average(zy[id2]) ]] )

id0 = idx[np.where(y[idx]==0)]
id1 = idx[np.where(y[idx]==1)]
id2 = idx[np.where(y[idx]==2)]
plt.scatter(zx[id0],zy[id0],color="blue")
plt.scatter(zx[id1],zy[id1],color="red")
plt.scatter(zx[id2],zy[id2],color="green")
plt.show()
