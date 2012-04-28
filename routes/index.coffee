# Setup services
redis = require "redis"
redis_client = redis.createClient process.env.REDIS_PORT or null, process.env.REDIS_HOST or null
redis_client.auth process.env.REDIS_AUTH or ""

shorty = require('node-shorty')

# Handlers

exports.index = (req, res) ->
  res.render 'index', {}
  res.end()

exports.entry = {}

exports.entry.create = (req, res) ->
  new_text = req.body.text
  unless new_text
    return res.redirect "/"
  redis_client.incr "id_count", (err, id) ->
    slug = shorty.url_encode id
    redis_client.hmset "original-#{id}", {text: new_text, slug: slug, view_count: 0 }, (err, redis_result) ->
      res.redirect "/#{slug}"

exports.entry.show = (req, res, next) ->
  slug = req.params.original
  id = shorty.url_decode slug
  redis_client.hgetall "original-#{id}", (err, entry) ->
    text = entry.text.toString() if entry? and entry.text?
    if text?
      redis_client.hincrby "original-#{id}", "view_count", 1
      res.render "show_entry", original_entry: entry.text
      res.end()
    else
      res.redirect "/"

exports.diff = {}

exports.diff.create = (req, res) ->
  original_slug = req.params.original
  diff_text = req.body.text
  original_id = shorty.url_decode original_slug
  unless diff_text
    return res.redirect "/"
  redis_client.incr "id_count-#{original_id}", (err, id) ->
    slug = shorty.url_encode id
    redis_client.hmset "new-#{id}", {text: diff_text, slug: slug, view_count: 0 }, (err, redis_result) ->
      res.redirect "/#{original_slug}/#{slug}"

exports.diff.show = (req, res, next) ->
  original_slug = req.params.original
  new_slug = req.params.new
  original_id = shorty.url_decode original_slug
  new_id = shorty.url_decode new_slug
  redis_client.hmgetall "original-#{original_id}", (err, original_entry) ->
    if original_entry?
      redis_client.hmgetall "new-#{new_id}", (err, new_entry) ->
        if new_entry?
          redis_client.hincrby "original-#{original_id}", "view_count", 1
          redis_client.hincrby "new-#{new_id}", "view_count", 1
          res.render "show_entry", {original_entry: original_entry, new_entry: new_entry}
          res.end()
          return
  res.redirect "/"
