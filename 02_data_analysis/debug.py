import pandas as pd
import numpy as np


fs = 100 # set your sampling rate here

df = pd.read_csv("data/opensignals_98D351FE8835_2026-01-03_21-00-20.csv")
print('columns:', df.columns.tolist())
sig = df['A1'].values   # or replace with the column you used
print('len, type:', len(sig), type(sig))
print('min, max, mean, std:', sig.min(), sig.max(), sig.mean(), sig.std())
print('unique values (first 20):', np.unique(sig)[:20])
# count flat segments
flat_pct = 100 * np.mean(np.isclose(sig, sig[0]))
print(f'percent identical to first value: {flat_pct:.1f}%')

import matplotlib.pyplot as plt
N = 2000
xrange = 2000 / fs
plt.figure(1)
plt.plot(sig[:N])
plt.title('raw signal (first %d samples)' % N)
plt.xlabel('samples')
plt.ylabel('amplitude (AU)')
plt.show()

from scipy.signal import periodogram
f, pxx = periodogram(sig, fs=fs)
import numpy as np
hr_band = (f >= 0.5) & (f <= 5)
print('peak freq in HR band:', f[np.argmax(pxx[hr_band])], 'Hz')
plt.figure(2)
plt.semilogy(f, pxx); plt.xlim(0,10); plt.show()