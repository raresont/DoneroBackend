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
var Web3 = require('web3');
var web3 = new Web3('ws://localhost:7545');
var contractAdress = '0xEAe19bE968B11a4902c642D4EbBf95D87c3B5088';
var fs = require('fs');
var jsonFile = "Supplychain.json";
var parsed= JSON.parse(fs.readFileSync(jsonFile));
var abi = parsed.abi;
var contract = new web3.eth.Contract(abi, contractAdress);

contract.methods.division(2,2).call((err, result) => {
    console.log(result)
    console.log(err)

});//.name().call((err, result) => {console.log(result)})
//web3.eth.getAccounts().then(console.log);

//web3.eth.
app.listen(PORT, '192.168.2.4', () => {
    console.log(`Donero running on port ${PORT}`)
});
app.get('/getNews', function(req, res){
    res.setHeader('Content-Type', 'application/json');
    res.end(JSON.stringify({ available: true }));
});

app.get('/getDonationOpportunities', function(req, res){
    res.setHeader('Content-Type', 'application/json');
    res.end(JSON.stringify({ available: true }));
});

app.get('/getHistory', function(req, res){
    res.setHeader('Content-Type', 'application/json');
    res.end(JSON.stringify({ available: true }));
});
