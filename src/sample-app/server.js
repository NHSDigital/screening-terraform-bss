var express = require('express');
var favicon = require('serve-favicon')
var path = require('node:path')
var app = express();
var port = 4000;

const version = require('./package.json').version;

app.use(favicon(path.join(__dirname, 'static', 'favicon.ico')))
app.set('views', './views');
app.set('view engine', 'ejs');

app.use(express.static('static'))

app.get('/', function(req, res) {
  res.render('index.ejs', { version: version });
});

app.listen(port);

console.log('Server running at http://localhost:' + port);
