from .params_init import dict_portfolio, time_params, Mu, Rfree, Std, det_income, norm_factor, age_plot_params
import numpy as np
from HARK.utilities import approxNormal
time_params['Age_born'] = 27
dict_portfolio['T_age'] = time_params['Age_death'] - time_params['Age_born'] + 1
dict_portfolio['T_cycle'] = time_params['Age_death'] - time_params['Age_born']
dict_portfolio['T_retire'] = time_params['Age_retire'] - time_params['Age_born']
dict_portfolio['T_sim'] = (time_params['Age_death'] - time_params['Age_born'] + 1)*50
time_params['Age_retire'] = 70
dict_portfolio['T_age'] = time_params['Age_death'] - time_params['Age_born'] + 1
dict_portfolio['T_cycle'] = time_params['Age_death'] - time_params['Age_born']
dict_portfolio['T_retire'] = time_params['Age_retire'] - time_params['Age_born']
dict_portfolio['T_sim'] = (time_params['Age_death'] - time_params['Age_born'] + 1)*50
time_params['Age_death'] = 100
dict_portfolio['T_age'] = time_params['Age_death'] - time_params['Age_born'] + 1
dict_portfolio['T_cycle'] = time_params['Age_death'] - time_params['Age_born']
dict_portfolio['T_retire'] = time_params['Age_retire'] - time_params['Age_born']
dict_portfolio['T_sim'] = (time_params['Age_death'] - time_params['Age_born'] + 1)*50
dict_portfolio['TranShkStd'] = np.array([0.063 , 0.066 , 0.0675, 0.0685, 0.069 , 0.069 , 0.067 , 0.0665, 0.066 , 0.064 , 0.063 , 0.062 , 0.061 , 0.06  , 0.0585, 0.057 , 0.055 , 0.053 , 0.0515, 0.05  , 0.047 , 0.045 , 0.043 , 0.04  ,0.038 , 0.036 , 0.033 , 0.03  , 0.03  , 0.03  , 0.03  , 0.03  ,0.03  , 0.03  , 0.03  , 0.03  , 0.03  , 0.03  , 0.03  , 0.03  ,0.03  , 0.03  , 0.03  , 0.03  , 0.03  , 0.03  , 0.03  , 0.03  , 0.03  , 0.03  , 0.03  , 0.03  , 0.03  , 0.03  , 0.03  , 0.03  , 0.03  , 0.03  , 0.03  , 0.03  , 0.03  , 0.03  , 0.03  , 0.03  , 0.03  , 0.03  , 0.03  , 0.03  , 0.03  , 0.03  , 0.03  , 0.03  , 0.03  ])
dict_portfolio['PermShkStd'] = np.array([0.15 , 0.122, 0.115, 0.105, 0.093, 0.09 , 0.087, 0.08 , 0.075, 0.075, 0.067, 0.068, 0.061, 0.062, 0.058, 0.06 , 0.058, 0.058, 0.057, 0.056, 0.054, 0.057, 0.059, 0.059, 0.063, 0.066, 0.07 , 0.073, 0.073, 0.073, 0.073, 0.073, 0.073, 0.073, 0.073, 0.073,0.073, 0.073, 0.073, 0.073, 0.073, 0.073, 0.073, 0.073, 0.073, 0.073, 0.073, 0.073, 0.073, 0.073, 0.073, 0.073, 0.073, 0.073,0.073, 0.073, 0.073, 0.073, 0.073, 0.073, 0.073, 0.073, 0.073, 0.073, 0.073, 0.073, 0.073, 0.073, 0.073, 0.073, 0.073, 0.073, 0.073])
age_plot_params = [30, 40, 50, 60, 70, 80]
dict_portfolio['LivPrb'] = dict_portfolio['LivPrb'][(time_params['Age_born'] - 20):(time_params['Age_death'] - 20)]
