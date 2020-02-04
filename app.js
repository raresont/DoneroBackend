var rp = require('request-promise');
var fs = require('fs');
var session;
var headers = {
    "x-zoom-s2t-key": "084d2ee8d0434618952dfc582f35b37ebb3c7afe95",
}
function createSessionAndRun() {
    rp.post({
        url: "https://api.zoommedia.ai/api/v1/speech-to-text/session/",
        headers: headers,
        json: {
            language: "en-us",
            punctuation: false
        }
    }).then(function (data) {
        console.log("Successfully created the session: ", data.sessionId);
        session = data.sessionId;
        uploadFile();
    }).catch(function (error) {
        console.log("Error creating the session", error);
    })
}

function uploadFile() {
    var formData = {
        upload: fs.createReadStream("owlet.mp3")
    };

    rp.post({
        url: "https://api.zoommedia.ai/api/v1/speech-to-text/session/" + session,
        headers: headers,
        formData: formData
    }).then(function (data) {
        console.log("File has been successfully uploaded");
        getTheExtraction();
    }).catch(function (error) {
        console.log("Error creating the session", error);
    })
}

function getTheExtraction() {
    rp.get({
        url: "https://api.zoommedia.ai/api/v1/speech-to-text/session/" + session,
        headers: { 'Content-type': 'application/json	', "x-zoom-s2t-key": "084d2ee8d0434618952dfc582f35b37ebb3c7afe95", }
    }).then(function (response) {
        console.log(JSON.parse(response));
    }).catch(function (error) {
        console.log("Error getting the results of the session", error);
    })
}

express = require('express');
const app = express();

var files;
app.post('/interpret', (req, res, next) => {
    
});

const PORT = 5000;

app.listen(PORT, '192.168.2.4', () => {
    console.log(`Donero running on port ${PORT}`)
});
app.get('/', function(req, res){
    res.setHeader('Content-Type', 'application/json');
    res.end(JSON.stringify({ a: 1 }));
});
