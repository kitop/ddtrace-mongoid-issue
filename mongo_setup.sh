#!/bin/bash
echo "sleeping for 10 seconds"
sleep 10

echo mongo_setup.sh time now: `date +"%T" `
mongo --host mongo1:27017 <<EOF
  var cfg = {
    "_id": "rs0",
    "version": 1,
    "members": [
      {
        "_id": 0,
        "host": "mongo1:27017",
        "priority": 2
      },
      {
        "_id": 1,
        "host": "mongo2:27017",
        "priority": 0
      },
      {
        "_id": 2,
        "host": "mongo3:27017",
        "priority": 0
      }
    ]
  };
  rs.initiate(cfg);
EOF

sleep 30
echo "Stepdown" 1>&2

mongo --host mongo1:27017 <<EOF
  cfg = rs.conf()
  cfg.members[0].priority = 0
  cfg.members[1].priority = 1
  cfg.members[2].priority = 0
  rs.reconfig(cfg)
EOF

sleep 30
echo "Stepdown" 1>&2

mongo --host mongo2:27017 <<EOF
  cfg = rs.conf()
  cfg.members[0].priority = 0
  cfg.members[1].priority = 0
  cfg.members[2].priority = 1
  rs.reconfig(cfg)
EOF
