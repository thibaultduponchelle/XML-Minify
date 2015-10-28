# xml-minifier
**xml-minifier** is a simple tool to minify xml. 

## How to use 

### Minify only
You could use it to minify your xml to reduce their size (for network exchange for instance) : 

    cat file.xml | xml-minifier.pl > mini.xml 

### Indent xml 
Have you ever tried to indent a xml ? 
**indent** tool seems not working correctly, **xmllint --format** works fine... if you preliminary use xml-minifier.pl on your xml.

    cat file.xml | xml-minifier.pl | xmllint --format - > pretty.xml
