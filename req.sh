# curl -i -X POST https://api-m2x.att.com/v2/devices/8517564616061f23db9be34c04d7f26e/streams/kicks/values -H "X-M2X-KEY: 8fad6b2a20bdb9813fa107ea49bf9031" -H "Content-Type: application/json" -d '{ "values": [ { "timestamp": "2014-11-18T18:50:00.624Z", "value": 20 }, { "timestamp": "2014-11-18T18:52:00.522Z", "value": 22 } ] }'

# curl -i -X POST https://api-m2x.att.com/v2/devices/aec2cd09e7556b2dc931980ad46a1e54/streams/kicks/values -H "X-M2X-KEY: f5e2226478066140dc92f7c5779c9530" -H "Content-Type: application/json" -d '{ "values": [ { "timestamp": "2014-11-18T18:50:00.624Z", "value": 20 }, { "timestamp": "2014-11-18T18:52:00.522Z", "value": 22 } ] }'

# curl -i -X DELETE https://api-m2x.att.com/v2/devices/99a65207d340d676cc4c65353fc98ab1 -H "X-M2X-KEY: f5e2226478066140dc92f7c5779c9530"

curl -i https://api-m2x.att.com/v2/devices?q=demo_weight -H "X-M2X-KEY: f5e2226478066140dc92f7c5779c9530"
