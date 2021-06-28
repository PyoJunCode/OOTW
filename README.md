# OOTW

Outfit Of Today's Weather(OOTW) Application

날씨를 알려주고 기온/장소 에 맞는 옷차림을 추천해주는 어플리케이션

[prototype figma link](https://www.figma.com/file/ZhkMhj4niGnZ3gAVbZAN29/ootd%EC%B6%94%EC%B2%9CApp?node-id=0%3A1)

<br>



## Database



Database crawling은 Naver 쇼핑의 패션의류 탭에서 진행

Selenium을 이용하여 전체카테고리 탐색 -> 각카테고리별 탐색 -> 각 상품 탐색의 DFS 구조로 진행



![crawl](https://user-images.githubusercontent.com/47979730/123631507-c8569480-d851-11eb-9eb9-fe49d6f9c6db.PNG)

Crawling한 Data들은 직접 Google Firebase Firestore에 저장됨. **(NoSQL)**

![database](https://user-images.githubusercontent.com/47979730/123631814-23888700-d852-11eb-8165-6056275a06a7.PNG)





## Machine Learning

Firebase ML kit를 사용해 Image의 multi labeling을 진행,

Label의 tag에서 장소를 식별하여 Pre-trained 된 Model을 통해 해당 장소에 알맞은 의류 카테고리의 상품을 추천해줍니다.

![ml](https://user-images.githubusercontent.com/47979730/123634415-5ed88500-d855-11eb-8618-ba7a6e7c8e51.png)





## Weather API



OpenWeather API를 사용하여 날씨 정보를 불러와 Parsing하여 사용.

위치를 특정하기 위해 GPS기능을 사용하여 현재의 위도,경도를 추출해 API에 전달.

외국/한국의 읍/면/동 까지의 세부적인 지역 단위로 날씨정보 조회 가능.



![weather](https://user-images.githubusercontent.com/47979730/123631962-50d53500-d852-11eb-89b3-bb3fafb328d1.png)

