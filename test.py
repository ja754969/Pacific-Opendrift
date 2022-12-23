#%%
## test 1: np.linspace
# import numpy as np
# ntraj=5
# # iniz=np.random.rand(ntraj) * -10.
# iniz=np.linspace(0.,0.,ntraj)
# print(iniz)
#%% 
# test 2: 
# import numpy as np
# import pandas as pd
from datetime import timedelta, datetime
td_0 = datetime(2010,12,12,0,0,0)
num_days = 3
for i in range(0, num_days):
    td_1=td_0+timedelta(days=i)
    time_1 = datetime(td_1.year, td_1.month, td_1.day, 0)
    txt = str(i)+'-time: '+str(td_1.year)+'_'+str(td_1.month)+'_{txt_day:02.0f}.'
    print(txt.format(txt_day = td_1.day))


# dti = pd.date_range("2018-01-01 00:00:00", periods=24, freq="H")
