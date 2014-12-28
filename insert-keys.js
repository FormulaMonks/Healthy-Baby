#!/usr/bin/env node

var fs = require('fs');
var keys = require('./keys/keys.json');

var content = [
    {
        files: ['M2XDemo/AppDelegate.swift', 'M2XDemo.xcodeproj/project.pbxproj'],
        key: keys.CRASHLYTICS_KEY,
        keyToken: keys.CRASHLYTICS_KEY_TOKEN
    },
    {
        files: ['DemoCloudCode/config/global.json'],
        key: keys.PARSE_MASTER_KEY,
        keyToken: keys.PARSE_MASTER_KEY_TOKEN
    },
    {
        files: ['DemoCloudCode/config/global.json'],
        key: keys.PARSE_APP_ID,
        keyToken: keys.PARSE_APP_ID_TOKEN
    },
    {
        files: ['M2XDemo/AppDelegate.swift'],
        key: keys.PARSE_APP_ID,
        keyToken: keys.PARSE_APP_ID_TOKEN
    },
    {
        files: ['M2XDemo/AppDelegate.swift'],
        key: keys.PARSE_CLIENT_KEY,
        keyToken: keys.PARSE_CLIENT_KEY_TOKEN
    }
];

function processItem(item) {
    item.files.forEach(function(file) {
        data = fs.readFileSync(file, 'utf8');

        if (!data) {
            return console.log("couldn't read file " + file);
        }

        var result = data.replace(item.keyToken, item.key);

        if (data !== result) {
            console.log('successfully found and replaced ' + item.keyToken + ' on file ' + file);
        } else {
            console.log('could not found ' + item.keyToken + ' on file ' + file);
        }

        fs.writeFileSync(file, result, 'utf8');
    });
}

try {
    content.forEach(processItem);
} catch (e) {
    console.log(e);
}
