// These two lines are required to initialize Express in Cloud Code.
var express = require('express');
var app = express();

// Global app configuration section
app.set('views', 'cloud/views');  // Specify the folder to find templates
app.set('view engine', 'ejs');    // Set the template engine
app.use(express.bodyParser());    // Middleware for reading request body

// This is an example of hooking up a request handler with a specific request
// path and HTTP verb using the Express routing API.
app.get('/hello', function(req, res) {
  res.render('hello', { message: 'Congrats, you just set up your app!' });
});

app.post('/notify_trigger', function(req, res) {
  var deviceId = req.body["device_id"] || req.body["feed_id"];

  var query = new Parse.Query(Parse.Installation);
  query.equalTo("kicksDeviceId", deviceId);

  Parse.Push.send({
    where: query, // Set our Installation query
    data: {
      alert: "Hey! your trigger '" + req.body["stream"] + " " + req.body["condition"] + " " + req.body["threshold"] + "'' shot with a value of " + req.body["value"] + "!"
    }
  }, {
    success: function() {
      res.send('Success');
    },
    error: function(error) {
      res.send('Fail');
    }
  });

  // console.log(deviceId);

  // Use Parse JavaScript SDK to create a new message and save it.
  // var Message = Parse.Object.extend("Message");
  // var message = new Message();
  // message.save({ text: req.body.text }).then(function(message) {
  //   res.send('Success');
  // }, function(error) {
  //   res.status(500);
  //   res.send('Error');
  // });
});

// // Example reading from the request query string of an HTTP get request.
// app.get('/test', function(req, res) {
//   // GET http://example.parseapp.com/test?message=hello
//   res.send(req.query.message);
// });

// // Example reading from the request body of an HTTP post request.
// app.post('/test', function(req, res) {
//   // POST http://example.parseapp.com/test (with request body "message=hello")
//   res.send(req.body.message);
// });

// Attach the Express app to Cloud Code.
app.listen();
