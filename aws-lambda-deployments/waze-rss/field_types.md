## alerts

column|type|
------|-------|
city|VARCHAR(50)|
confidence|REAL|
country|VARCHAR(50)|
dateAdded|TIMESTAMPTZ|
magvar|BIGINT|
pubmillis|BIGINT|
reliability|REAL|
reportdescription|VARCHAR(300)|
reportrating|REAL|
roadtype|INTEGER|
severity|REAL|
street|VARCHAR(100)|
subtype|VARCHAR(100)| |
type|VARCHAR(50)|
uuid|VARCHAR(36)|
wkt|VARCHAR(MAX)|
x|REAL|
y|REAL|

## jams

column|type|
------|-------|
blockingalertuuid|VARCHAR(36)|
city|VARCHAR(50)|
country|VARCHAR(50)|
dateAdded|TIMESTAMPTZ|
delay|INTEGER|
endnode|VARCHAR(250)|
length|BIGINT|
level|INTEGER|
pubmillis|BIGINT|
roadtype|INTEGER|
speed|REAL|
startnode|VARCHAR(250)|
street|VARCHAR(100)|
turntype|VARCHAR(15)|
uuid|VARCHAR(36)|
wkt|VARCHAR(MAX)|