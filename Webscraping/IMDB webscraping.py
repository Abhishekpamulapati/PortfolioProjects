#!/usr/bin/env python
# coding: utf-8

# In[31]:


from bs4 import BeautifulSoup
import requests, openpyxl


# In[34]:


excel=openpyxl.Workbook()
print(excel.sheetnames)
sheet= excel.active
sheet.title='Top rated tv shows'
print(excel.sheetnames)
sheet.append(['show rank','show name','show year','show rating'])

try:
    source= requests.get('https://www.imdb.com/chart/toptv')
    source.raise_for_status()
    
    soup=BeautifulSoup(source.text,'html.parser')
    
    tvshow=soup.find('tbody', class_="lister-list").find_all('tr')
        
    for tv in tvshow:

        name=tv.find('td', class_="titleColumn").a.text
        
        rank=tv.find('td', class_="titleColumn").get_text(strip=True).split('.')[0]
        
        year=tv.find('td', class_="titleColumn").span.text.strip('()')
        
        rating=tv.find('td', class_="ratingColumn imdbRating").strong.text
        
        print(rank,name,year,rating)
        
        sheet.append([rank,name,year,rating])        

        
except Exception as e:
    print(e)

excel.save('IMDB TVshow ratings.xlsx')

