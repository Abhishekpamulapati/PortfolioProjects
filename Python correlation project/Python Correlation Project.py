#!/usr/bin/env python
# coding: utf-8

# In[18]:


#importing libraries
import pandas as pd
import seaborn as sns
import numpy as np
import matplotlib 
import matplotlib.pyplot as plt
plt.style.use('ggplot')
from matplotlib.pyplot import figure

get_ipython().run_line_magic('matplotlib', 'inline')
matplotlib.rcParams['figure.figsize']=(12,8) #Adjusting the configuration that we are creating

#Read the Data
df=pd.read_csv(r'C:\Users\ABHISHEK\Desktop\Udemy\Portfolio_project\Project 3\movies.csv')


# In[19]:


#looking at the data in the csv
df.head()


# In[41]:


#checking for any missing data

for col in df.columns:
    perc_missing=np.mean(df[col].isnull())
    print('{} - {}%'.format(col, round(perc_missing*100)))


# In[71]:


df.isnull().sum() 


# In[20]:


#removing rows that contain null values
df = df.dropna()
df.head()


# In[28]:


#Datatypes for the columns
df.dtypes


# In[80]:


#changing datatype of the columns
df['budget'] = df['budget'].astype('int64')
df['gross'] = df['gross'].astype('int64')


# In[81]:


df.dtypes


# In[21]:


# Older logic
df['year_crrt']=df['released'].astype(str).str[:15]


# In[23]:


#New code as dataset got updated
df['yearcorrect'] = df['released'].str.extract(pat = '([0-9]{4})').astype(int)
df.head()


# In[ ]:


#Deleted the older year column
del df['year_crrt']
df


# In[109]:


df=df.sort_values(by=['gross'], inplace=False,ascending=False)


# In[102]:


pd.set_option('display.max_rows', None)


# In[104]:


#Droping the duplicates

df['company'].drop_duplicates().sort_values(ascending=False)


# In[ ]:


#budgeting high correlation
#company high correlation


# In[3]:


df.boxplot(column=['gross'])


# In[110]:


#scatter plot with budget vs gross
plt.scatter(x=df['budget'], y=df['gross'])
plt.title('Budget vs Gross')
plt.xlabel('Budget for film')
plt.ylabel('Gross budget')
plt.show()


# In[13]:


#Budget vs Gross using seaborn
sns.regplot(x='budget', y='gross',data=df, scatter_kws={"color":"orange"},line_kws={"color":"green"})


# In[4]:


#Gross vs Rating
sns.stripplot(x="rating", y="gross", data=df)


# In[19]:


# Understanding the correlation- It will be working only on numeericals
df.corr(method='pearson') # Diff methods-pearson,kendall,spearman


# In[21]:


#high correlation between budget and gross #visualizing correlation using heatmap
correlation_matrix=df.corr(method='pearson')
sns.heatmap(correlation_matrix, annot=True)
plt.title("Correlation matrix for numeric feature")
plt.xlabel("Movie Featue")
plt.ylabel("Movie Feature")
plt.show()


# In[22]:


#looking at the company
df.head()


# In[6]:


df_numerized=df


# In[7]:


#looping to change object datatype to numeric in df 

for col_name in df_numerized.columns:
    if(df_numerized[col_name].dtype == 'object'):
        df_numerized[col_name]= df_numerized[col_name].astype('category')
        df_numerized[col_name] = df_numerized[col_name].cat.codes
        
df_numerized.head()


# In[25]:


df_numerized.corr(method='pearson')


# In[27]:


#Visualiztion after the datasets is all numeric
correlation_matrix=df_numerized.corr(method='pearson')
sns.heatmap(correlation_matrix, annot=True)
plt.title("Correlation matrix for numeric feature")
plt.xlabel("Movie Featue")
plt.ylabel("Movie Feature")
plt.show()


# In[ ]:





# In[28]:


correlation_mat=df_numerized.corr()
corr_pairs=correlation_mat.unstack()
corr_pairs


# In[31]:


sort_pairs=corr_pairs.sort_values()
sort_pairs


# In[ ]:


#high correlation categories
high_corr=sort_pairs[(sort_pairs)>0.4]
high_corr


# In[ ]:


#Conclusion: Voters and budget have high correlation to gross and company as low correlation


# In[ ]:




