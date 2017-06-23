import numpy
import matplotlib.pyplot as plt

theta = 0.2
n = 100
for i in range(2,8):
    sample = 5 ** i
    most_likely = numpy.random.binomial(n,theta,sample)/float(n)
    plt.hist(most_likely,bins=99,range=[0,1])
    plt.title("sample = %d" % sample)
    plt.savefig("%d.eps" % sample)
    plt.close()
