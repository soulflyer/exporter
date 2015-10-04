#!/bin/bash
# Called by applescript export.scpt

PAGE=index.html

cd $1
FULLPATH=`pwd`

project=`basename $FULLPATH`
FULLPATH=`dirname $FULLPATH`
month=`basename $FULLPATH`
FULLPATH=`dirname $FULLPATH`
year=`basename $FULLPATH`
FULLPATH=$year/$month/$project
echo $FULLPATH

cat <<EOF > $PAGE
<!doctype html>
<html>
<head>
  <meta name="viewport" content="width=device-width">
  <link rel="stylesheet" type="text/css" href="/css/shoot-main.css">
  <link rel="stylesheet" media="(max-width: 600px)"  type="text/css" href="/css/shoot-phone.css">
  <link rel="stylesheet" media="(min-width: 601px) and (max-width: 1024px)" type="text/css" href="/css/shoot-tablet.css">
  <link rel="stylesheet" media="(min-width: 1024px)" type="text/css" href="/css/shoot-laptop.css">
  <script type="text/javascript" src="/js/jquery-2.0.3.js"></script>
  <script type="text/javascript" chset="utf-8" src="/js/shoot-mobile-jquery.js"></script>

</head>
<body>
  <div class="container">
    <header class="main">
      <div id="logo">Soulflyer Photos</div>
      <div id="menu"></div>
    </header><!-- end header.main -->
    <nav>
      <ul>
        <li><a href=http://soulflyer.com/>home</a></li>
        <li id="infobutton">information</li>
      </ul>
    </nav>
    <aside>
EOF

if [ -f notes.txt ]
then
    echo "found notes.txt"
else
    cp /Users/iain/Code/PublishPhotos/lib/notes.txt .
fi

cat notes.txt >> $PAGE

cat <<EOF >> $PAGE
    </aside>
    <section class="content">

EOF

THUMBPATH="/photos/thumbs/$FULLPATH/"
MEDIUMPATH="/photos//medium/$FULLPATH/"
LARGEPATH="/photos/large/$FULLPATH/"


for i in ../../../thumbs/$FULLPATH/*.jpg
do
    i=`basename $i`
    echo $i
    LINKMEDIUM="<a class=\"medium\" href="$MEDIUMPATH$i"><img src="$THUMBPATH$i"></a>"
    LINKLARGE="<a class=\"large\" href="$LARGEPATH$i"><img src="$THUMBPATH$i"></a>"
    echo "     " $LINKMEDIUM >> $PAGE
    echo "     " $LINKLARGE >> $PAGE
    echo >> $PAGE
done

cat <<EOF >>$PAGE
    </section><!-- end section.content -->
  </div><!-- end .container -->
</body>
</html>

EOF
