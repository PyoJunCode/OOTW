# coding: utf-8
import requests
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from bs4 import BeautifulSoup
from urllib.parse import urlencode, quote
from fake_useragent import UserAgent
import firebase_admin
from firebase_admin import credentials, firestore
from time import sleep
import time

cred = credentials.Certificate("./ootwkey.json")
app = firebase_admin.initialize_app(cred)
db = firestore.client()
# 21800370 Seo jun pyo MOBILE APP team project

urlencode_noquote = lambda query: urlencode(query, quote_via = lambda k,l,m,n: k)

ROOT_MAIN = 'https://search.shopping.naver.com'


class Shop:

    options = webdriver.ChromeOptions()
    #options.add_argument('headless')
    #options.add_argument('--window-size=640,640')
    options.add_argument('--disable-gpu')
    driver = webdriver.Chrome(executable_path=r'./chromedriver', options=options)


    _CAMOUFLAGE_CHROME = {'User-Agent' : UserAgent().chrome}
    
    
    #_categorySummaryFilterArea
    #_categorySummaryFilterArea > div > div > ul

    def __init__(self):
        self.s = requests.Session()
        
    
    def disguised_post(self, url, **kwargs):
        return self.s.post(url, headers = self._CAMOUFLAGE_CHROME, **kwargs)

    def disguised_get(self, url):
        return self.s.get(url, headers = self._CAMOUFLAGE_CHROME)
        
    def get_Categories(self):
        
        resp = self.disguised_get('https://search.shopping.naver.com/category/category?catId=50000000')
        soup = BeautifulSoup(resp.content, 'html.parser')
        #categories = soup.select('#_categorySummaryFilterArea > div > div > ul > li > a')
        categories = soup.select('.__50000000_category_list__1oflE ')
        
        data = categories[2].select('li > a')
        for cate in data:
            print(cate.text)
            gender = '남성'
            col_name = '의류'
            cat_name = cate.text
            self.get_Product(gender,col_name,cat_name, cate['href'])
        
           
      
     
    def get_Product(self, gender, col_name, cate_name, cate_code):
        
        resp = self.driver.get(ROOT_MAIN+cate_code)
        
        self.driver.implicitly_wait(1)
       
        for i in range(0,16):
            self.driver.find_element_by_tag_name('body').send_keys(Keys.PAGE_DOWN)
            sleep(0.5)
            soup = BeautifulSoup(self.driver.page_source, 'html.parser')

            products = soup.select('.basicList_inner__eY_mq')
            
            if i%2 == 0:
                for product in products:
                    
                    docID = int(round(time.time() * 1000))
                    link = product.select('.thumbnail_thumb_wrap__1pEkS > a')
                    img = product.select('.thumbnail_thumb_wrap__1pEkS > a > img')
                    name = product.select('.basicList_title__3P9Q7')
                    price = product.select('.price_num__2WUXn')
                    
                    if len(product.select('.thumbnail_thumb_wrap__1pEkS > a > img')) == 0:
                        print('passed')
                        continue
                    print(name[0].text)
                    data = {
                            u'docID': str(docID),
                            u'name': name[0].text,
                            u'link': link[0].get('href'),
                            u'img': img[0].get('src'),
                            u'category': cate_name,
                            u'price': price[0].text,
                        }
                    
                    #db.collection(gender+col_name).document(str(docID)).set(data)
                    
            
            
        

           
            
            
                

s = Shop()
s.get_Categories()


