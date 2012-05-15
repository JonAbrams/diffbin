# Setup services
redis = require "redis"
redis_client = redis.createClient process.env.REDIS_PORT or null, process.env.REDIS_HOST or null
redis_client.auth process.env.REDIS_AUTH or ""

shorty = require("node-shorty")

# Handlers

exports.entry = {}

exports.entry.show = (req, res) ->
  root_url = "http://#{req.headers.host}"
  
  slug = req.params.slug
  
  if slug
    id = shorty.url_decode slug
    redis_client.hgetall "entry-#{id}", (err, entry) ->
      if entry?
        old_text = entry.old_text
        new_text = entry.new_text
      else
        old_text = new_text = ""
      redis_client.hincrby "entry-#{id}", "view_count", 1
      res.render "show_entry", {
        old_text
        new_text
        url: "#{root_url}/#{slug}"
      }
  else
    res.render "show_entry",
      old_text: "This area is for the original text."
      new_text: "This area is for the modified text."
      url: "#{root_url}"

exports.entry.create = (req, res) ->
  root_url = "http://#{req.headers.host}"
  
  old_text = req.body.old_text
  new_text = req.body.new_text
  
  unless old_text and new_text
    res.write("Missing old text")
    return res.end()
  
  redis_client.incr "id_count", (err, id) ->
    slug = shorty.url_encode id
    redis_client.hmset "entry-#{id}", {
      new_text
      old_text
      slug
      view_count: 0
    }, (err, redis_result) ->
      res.write JSON.stringify err: "SUCCESS", slug: slug
      res.end()
