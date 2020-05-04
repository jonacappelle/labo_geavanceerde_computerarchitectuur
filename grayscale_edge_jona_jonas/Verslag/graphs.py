#/usr/bin/python3
# belangrijk dat je de juiste Python Interpreter selecteert in VSCode (Python 3.x)

# onderstaande libraries heb je nodig 
# en kan je indien nodig met volgend commando 
# in Powershell of Linux/macOS Terminal installeren:
# pip install pandas matplotlib
 
import pandas as pd
import matplotlib as mpl
import matplotlib.pyplot as plt
import math
from matplotlib.ticker import ScalarFormatter # specifiek gebruikt in dit voorbeeld

golden_mean = (math.sqrt(5)-1.0)/2.0 # estetische ratio 

# parameters aanpassen zoals je ze zelf graag wilt
width = 5                       #inches
height = width * golden_mean    #inches
fontsize = 11                   #pt
axis_linewidth = 0.4            #pt


####### PARAMETERS VOOR LATEX GOED ZETTEN #######
# mpl.use("pgf")
# mpl.rcParams.update({
#         'backend': 'ps',
#         'axes.labelsize': fontsize,
#         'axes.titlesize': fontsize,
#         'legend.fontsize': fontsize,
#         'xtick.labelsize': fontsize,
#         'ytick.labelsize': fontsize,
#         'axes.linewidth' : axis_linewidth,
#         'text.usetex': True,
#         "pgf.rcfonts": False,
#         "pgf.texsystem": "lualatex",
#         'font.family': 'serif',
#         "pgf.preamble": [
#             r"\usepackage[utf8x]{inputenc}",    # use utf8 fonts
#             r"\usepackage[T1]{fontenc}",        # plots will be generated
#             r"\usepackage[detect-all]{siunitx}" # to use si units
#         ]
#     })

#########################################################################################
#########################################################################################
####### DATA INLEZEN EN VERWERKEN #######

data = pd.read_csv('E:\GOOGLE_DRIVE\SCHOOL 2019-2020\Geavanceerde computerarchitectuur\Labo\grayscale_edge_jona_jonas\Verslag\grayscale_gpu.csv')
# als je deze methode gebruikt voor de data in lezen
# dan moet de eerste regel van het bestand de kolomnamen bevatten 
# zo kan je er naar verwijzen en zo de data verwerken en plotten
# deze naam wordt ook in de legende gebruikt 
# in dit voorbeeld is de eerste regel: Tijd,Stroom
# en tweede regel: 10,0.02086235
data.head()
data.columns = ['x', 'y']
# data['y'] = 1000 * data['y']

####### PLOTTEN MAAR #######
# figure size
plt.figure(figsize=(width,height))

plt.style.use('grayscale')

plt.rc('axes', axisbelow=True) # plot grid below axis
plt.grid(color = 'silver')

plt.scatter(data['x'], data['y'], s=5)



#select range
plt.ylim(0.2,1.2)

# data plotten
# ax = plt.gca()
# data.plot(x='blocks',y='tijd')#,ax=ax)

# paar dingetjes aanpassen; ! note: volgorde maakt soms uit
# plt.yscale('log')
# ax.yaxis.set_major_formatter(ScalarFormatter())
# ax.legend().remove()

plt.ylabel("Tijd [ms]")
plt.xlabel("Aantal blocks")



####### OPSLAAN #######
plt.show()
# plt.savefig('gpu_grayscale.pdf', bbox_inches='tight')

# eventueel tweede plot maken kan met 
# plt.figure(2, figsize=(width, height))
# en dan zelfde methode zoals hierboven


print("done")