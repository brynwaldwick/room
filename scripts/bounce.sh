PORT=${1:-4997}
BASE=${2:-static}
rm $BASE/{css,js}/{app,login}.bounced.*
curl -o $BASE/js/app.bounced.js localhost:$PORT/js/app.js -H "X-Enable-Bouncer: true"
curl -o $BASE/css/app.bounced.css localhost:$PORT/css/app.css -H "X-Enable-Bouncer: true"