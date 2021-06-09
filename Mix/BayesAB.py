%reset -f
import numpy as np
import matplotlib.pyplot as plt
from scipy.stats import beta
 


 
#p1 = 0.1
#data = {}
#for i in range(1,100) :
#    data[i] = 1 if np.random.random() < p1 else 0 
#    data2.append(1 if np.random.random() < p1 else 0)    
#print(sum(data.values())/len(data))


class Bandit:
    def __init__(self, p):
        self.p  = p
        self.a = 1
        self.b = 1
        
    def pull(self):
        return np.random.random() <self.p
    
    def sample(self):
        return np.random.beta(self.a, self.b)
    
    def update(self, x):
        self.a += x
        self.b += 1-x 
    
    def prt(self):
        return self.a,self.b
        
def plot(bandits,trial):
    x = np.linspace(0,1,200)
    for b in bandits:
        y = beta.pdf(x, b.a, b.b)
        plt.plot(x,y, label = "real p: %.4f" % b.p)
        plt.title("Bandit distributions after %s trials" % trial)
        plt.legend()
        plt.show()
       
y = beta.pdf(x, bestb.a, bestb.b)
plt.plot(x,y, label = "real p: %.4f" % bestb.p)

#BANDIT_PROBABILITIES = [0.4]
#def experiment():
#    bandits = [Bandit(p) for p in BANDIT_PROBABILITIES]
#    sample_points = [50, 500, 1000, 1999]
#    for i in range(NUM_TRIALS):
#        bestb = bandits[0]
#        x = bestb.pull()
#        bestb.update(x)
#        if i in sample_points: 
#            plot(bandits, i)
#            print(bestb.prt())    
#experiment()
  

 def experiment():
    bandits = [Bandit(p) for p in BANDIT_PROBABILITIES]
    
    sample_points = [50, 1000, 1500, 1999]
    for i in range(NUM_TRIALS):
        bestb = None
        maxsample = -1
        allsamples = []
        for b in bandits:
            sample = b.sample()
            allsamples.append("%.4f" % sample)
            if sample > maxsample:
                maxsample = sample
                bestb = b
        if i in sample_points:
            print("current samples: %s" % allsamples)
            plot(bandits, i)
        x = bestb.pull()
        bestb.update(x)

NUM_TRIALS = 2000
BANDIT_PROBABILITIES = [0.2,0.21]        
experiment() 




