module.exports =
  get : (req, res, next, mongooseModel, cb) ->
    mongooseModel.findOne
      _id: req.params.id
    , (err, entity) ->
        return next(err)  if err
        return res.status(404, 'Not Found').send('Not Found').end()  unless entity
        res.jsonp(entity)
        cb(entity)  if cb

  getAll : (req, res, next, mongooseModel, cb, options) ->
    resData = {}
    require('./query-parser/$count')(resData, mongooseModel, req.query['$count'], req.query['$filter'])

    query = mongooseModel.find()
    require('./query-parser/$filter')(query, req.query['$filter'])
    require('./query-parser/$orderby')(query, req.query['$orderby'] || options.orderby)
    require('./query-parser/$skip')(query, req.query['$skip'], options.maxSkip)
    require('./query-parser/$top')(query, req.query['$top'], options.maxTop)
    require('./query-parser/$select')(query, req.query['$select'])

    # todo
    # $expand=Customers/Orders
    # $search

    query.exec (err, data) ->
      resData.value = data
      res.jsonp resData
      cb(resData)  if cb
