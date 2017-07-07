import numpy as np

x = np.array( [[  1,  1, -1, -1],
               [  0,  1, -1, -1],
               [ -1, -1,  1,  1],
               [  0, -1,  0,  1]])

mask = (x!=0).astype(int)

mu = np.random.randn(4)
mv = np.random.randn(4)
su = np.random.rand(4)
sv = np.random.rand(4)
eps = 1e-10

while True:

    old_su = su.copy()
    old_sv = sv.copy()
    old_mu = mu.copy()
    old_mv = mv.copy()

    for i in range(4):
        su[i] = (np.sum((sv+mv**2)*mask[i,:]) + 1 )**(-1)
        mu[i] = su[i] * np.sum(mask[i,:]*mv*x[i,:])
        
    for j in range(4):
        sv[j] = (np.sum((su+mu**2)*mask[:,j]) + 1 )**(-1)
        mv[j] = sv[j] * np.sum(mask[:,j]*mu*x[:,j])

    if np.max(np.abs([old_su-su,
                      old_sv-sv,
                      old_mu-mu,
                      old_mv-mv])) < eps :
        break
        
print("E[x_2,1]",mu[1]*mv[0])
print("E[x_4,1]",mu[3]*mv[0])
print("E[x_4,3]",mu[3]*mv[2])
