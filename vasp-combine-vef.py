#!/usr/bin/env python3
from natsort import natsorted
import glob, os, json
import subprocess
import numpy as np
exec(open("/home/patrickm/git/Python4ChemistryTools/mpl-settings.py").read())

files = natsorted(glob.glob('**/vasprun.xml', recursive=True))
data = []

for f in files:
    folder = os.path.dirname(os.path.abspath(f))
    if os.path.isfile(os.path.join(folder,'fe.dat')):
        print("Adding {}".format(folder))
    else:
        print("Running vef.py in {}".format(folder))
        p = subprocess.Popen(['vef.py'], cwd=folder)
        p.wait()
        assert os.path.isfile(os.path.join(folder,'fe.dat')), "Problem running vef.py in {:}".format(folder)
    data.append(np.loadtxt(os.path.join(folder,'fe.dat')))
combined = {}
combined['force'] = []
combined['energy'] = []
for d in data:
    combined['force'].extend(d[:,1].tolist())
    combined['energy'].extend(d[:,2].tolist())
nItems = len(combined['force'])
with open('fe-combined.json','w') as f:
    json.dump(combined, f)

xAxis = list(range(1, nItems+1))

def plot(filename,lw=2):
    fig, ax1 = plt.subplots()
    plt.xlabel('Step #')# [Å]
    color = 'black'
    ax1.set_ylabel(r'$\Delta E$ [eV]', color=color)
    #plt.ylim([-10**exp,10**exp])
    #plt.yscale('symlog')
    #plt.gca().yaxis.grid(True)
    ax1.plot(xAxis, combined['energy'], color=color, ls='-', lw=lw)
    color = 'grey'
    ax2 = ax1.twinx()
    ax2.grid(None)
    ax2.set_yscale('log')
    ax2.set_ylabel(r'max($F$) [eV/Å]', color=color)
    ax2.tick_params(axis='y', labelcolor=color)
    ax2.plot(xAxis, combined['force'], color=color, ls='-', lw=lw)
    plt.tight_layout()
    plt.savefig(filename)
    #plt.show()
    plt.close()

plot('fe.png', lw=2)

#Presentation
plt.rcParams.update({'font.size': 22})
plt.rcParams.update({'legend.fontsize': 22})
plot('fe_presentations.png', lw=4)

print('...Done!')
