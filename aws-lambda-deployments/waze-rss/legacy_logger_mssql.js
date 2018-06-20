/**
 * Using Rails-like standard naming convention for endpoints.
 * GET     /api/things              ->  index
 * POST    /api/things              ->  create
 * GET     /api/things/:id          ->  show
 * PUT     /api/things/:id          ->  update
 * DELETE  /api/things/:id          ->  destroy
 */

'use strict';

Object.defineProperty(exports, "__esModule", {
    value: true
});
exports.index = index;
exports.show = show;
exports.create = create;
exports.update = update;
exports.destroy = destroy;

var _lodash = require('lodash');

var _lodash2 = _interopRequireDefault(_lodash);

var _sqldb = require('../../sqldb');

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

var sql = require('mssql');
var config = require('./../../config/environment');
var request = require('request');

function respondWithResult(res, statusCode) {
    statusCode = statusCode || 200;
    return function (entity) {
        if (entity) {
            res.status(statusCode).json(entity);
        }
    };
}

function saveUpdates(updates) {
    return function (entity) {
        return entity.updateAttributes(updates).then(function (updated) {
            return updated;
        });
    };
}

function removeEntity(res) {
    return function (entity) {
        if (entity) {
            return entity.destroy().then(function () {
                res.status(204).end();
            });
        }
    };
}

function handleEntityNotFound(res) {
    return function (entity) {
        if (!entity) {
            res.status(404).end();
            return null;
        }
        return entity;
    };
}

function handleError(res, statusCode) {
    statusCode = statusCode || 500;
    return function (err) {
        res.status(statusCode).send(err);
    };
}

// Gets a list of Things
function index(req, res) {
    console.log('running things');
    // request module is used to process the yql url and return the results in JSON format
    request(SOMEWAZEURL, function (err, resp, body) {
        body = JSON.parse(body);
        // console.log(body);
        var currentTime = new Date();
        var dbRequest = new sql.Request(config.mssql.connection);
        // console.log(body.alerts.length);
        // Query 
        var table = new sql.Table('Transportation.WAZE_RSS_FEED_ALERTS'); // or temporary table, e.g. #temptable 
        var table2 = new sql.Table('Transportation.WAZE_RSS_FEED_JAMS'); // or temporary table, e.g. #temptable 

        table.create = true;
        table.columns.add('country', sql.VarChar(50), { nullable: true }); //1
        table.columns.add('city', sql.VarChar(50), { nullable: true }); //2
        table.columns.add('reportRating', sql.Int, { nullable: true }); //3
        table.columns.add('confidence', sql.Int, { nullable: true }); //4
        table.columns.add('reliability', sql.Int, { nullable: true }); //5
        table.columns.add('type', sql.VarChar(50), { nullable: true }); //6
        table.columns.add('uuid', sql.VarChar(80), { nullable: true }); //7
        table.columns.add('roadType', sql.Int, { nullable: true }); //8
        table.columns.add('magvar', sql.Int, { nullable: true }); //9
        table.columns.add('subtype', sql.VarChar(100), { nullable: true }); //10
        table.columns.add('street', sql.VarChar(100), { nullable: true }); //11
        table.columns.add('reportDescription', sql.NVarChar(500), { nullable: true }); //12
        table.columns.add('x', sql.Float, { nullable: true }); //13
        table.columns.add('y', sql.Float, { nullable: true }); //14
        table.columns.add('wkt', sql.VarChar(500), { nullable: true });
        table.columns.add('pubMillis', sql.VarChar(50), { nullable: true }); //15
        table.columns.add('dateAdded', sql.DateTime2, { nullable: true }); //15


        table2.create = true;
        table2.columns.add('country', sql.VarChar(50), { nullable: true }); //1
        table2.columns.add('city', sql.VarChar(50), { nullable: true }); //2
        table2.columns.add('uuid', sql.VarChar(80), { nullable: true }); //7
        table2.columns.add('roadType', sql.Int, { nullable: true }); //8
        table2.columns.add('street', sql.VarChar(100), { nullable: true }); //11
        table2.columns.add('pubMillis', sql.VarChar(50), { nullable: true }); //15
        table2.columns.add('dateAdded', sql.DateTime2, { nullable: true }); //15
        table2.columns.add('line', sql.VarChar(sql.MAX), { nullable: true }); //6
        table2.columns.add('speed', sql.Float, { nullable: true }); //7
        table2.columns.add('length', sql.Int, { nullable: true }); //8
        table2.columns.add('delay', sql.Int, { nullable: true }); //9
        table2.columns.add('startNode', sql.VarChar(250), { nullable: true }); //10
        table2.columns.add('endNode', sql.VarChar(250), { nullable: true }); //11
        table2.columns.add('level', sql.Int, { nullable: true }); //12
        table2.columns.add('turnLine', sql.VarChar(1000), { nullable: true }); //13
        table2.columns.add('turnType', sql.VarChar(250), { nullable: true }); //14
        table2.columns.add('blockingAlertUuid', sql.VarChar(250), { nullable: true });
        table2.columns.add('lineWKT', sql.VarChar(sql.MAX), { nullable: true });

        body.alerts.forEach(function (element) {
            //Create WKT string for each alert location
            var wkt = 'POINT (' + element.location.x + ' ' + element.location.y + ')';
            // Add rows to bulk insert definition
            table.rows.add(element.country, element.city, element.reportRating, element.confidence, element.reliability, element.type, element.uuid, element.roadType, element.magvar, element.subtype, element.street, element.reportDescription, element.location.x, element.location.y, wkt, element.pubMillis, currentTime);
        }, this);
        // Bulk insert rows into Alerts table
        dbRequest.bulk(table, function (err, rowCount) {
            if (err) {
                console.log(err);
            } else {
                console.log("alerts: ", rowCount);
            }
            body.jams.forEach(function (element) {
                var wktJam; //Built wkt string based on lat/lngs provided for each jam
                var wktJamVertices; //String of comma-separated lat/lngs provided for each jam
                if (element.line) {
                    wktJamVertices = "";
                    wktJam = "";
                    //Build comma-separated lat/lng string
                    for (var _index = 0; _index < element.line.length; _index++) {
                        wktJamVertices += element.line[_index].x + " " + element.line[_index].y + ",";
                    }
                    //Remove trailing comma
                    wktJamVertices = wktJamVertices.slice(0, -1);
                    //Build final WKT String
                    wktJam = "LINESTRING (" + wktJamVertices + ")";
                    console.log(wktJam);
                }
                // Add rows to bulk insert definition
                table2.rows.add(element.country, element.city, element.uuid, element.roadType, element.street, element.pubMillis, currentTime, element.line, element.speed, element.length, element.delay, element.startNode, element.endNode, element.level, element.turnLine, element.turnType, element.blockingAlertUuid, wktJam);
            }, this);
            //Bulk insert rows into Jams table
            dbRequest.bulk(table2, function (err, rowCount) {
                if (err) {
                    console.log(err);
                } else {
                    console.log("jams: ", rowCount);
                    res.json({
                        status: 'success',
                        rowCount: rowCount
                    });
                }
            });
        });
    });
}

// Gets a single Thing from the DB
function show(req, res) {
    return _sqldb.Thing.find({
        where: {
            _id: req.params.id
        }
    }).then(handleEntityNotFound(res)).then(respondWithResult(res)).catch(handleError(res));
}

// Creates a new Thing in the DB
function create(req, res) {
    return _sqldb.Thing.create(req.body).then(respondWithResult(res, 201)).catch(handleError(res));
}

// Updates an existing Thing in the DB
function update(req, res) {
    if (req.body._id) {
        delete req.body._id;
    }
    return _sqldb.Thing.find({
        where: {
            _id: req.params.id
        }
    }).then(handleEntityNotFound(res)).then(saveUpdates(req.body)).then(respondWithResult(res)).catch(handleError(res));
}

// Deletes a Thing from the DB
function destroy(req, res) {
    return _sqldb.Thing.find({
        where: {
            _id: req.params.id
        }
    }).then(handleEntityNotFound(res)).then(removeEntity(res)).catch(handleError(res));
}
//# sourceMappingURL=thing.controller.js.map
