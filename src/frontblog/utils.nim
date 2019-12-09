import sets, parseutils, strutils, strformat, times

let lookupSet = ["title", "layout", "id", "author", "datetime", "excerpt", "tags"].toHashSet



type
  MetaData* = tuple
    title: string
    layout: string
    id: string
    author: string
    dateTime: string
    excerpt: string
    tags: seq[string]
  Article* = object
    data*: MetaData
    content*: string
    title: bool
    id: bool
    author: bool
    dateTime: bool
    excerpt: bool
    tags: bool
  ParseError* = Exception
  

proc parseHeader*(s: string): Article = 
  result.dateTime = true
  result.data.dateTime = $local(now())

  template assign(attr, value: untyped): untyped = 
    result.attr = true
    result.data.attr = value
  var 
    pos: int
    key, value: string
  let length = s.len
  if skip(s, "---", pos) != 3:
    raise newException(ParseError, "No `---` in the head")
  pos += 3
  pos += skipWhitespace(s, pos)
  if skipUntil(s, {'\n'}, pos) == 0:
    raise newException(ParseError, "can't have words after `---`")
  while true:
    pos += skipWhitespace(s, pos)
    pos += parseUntil(s, key, {':'}, pos) + 1
    key = normalize(key)
    echo key
    if key notin lookupSet:
      raise newException(KeyError, fmt"key should be in {lookupSet}")
    pos += skipWhitespace(s, pos)
    pos += parseUntil(s, value, {'\n'}, pos)
    case key
    of "title":
      assign(title, value.strip)
    of "id":
      assign(id, value.strip)
    of "author":
      assign(author, value.strip)
    of "datetime":
      assign(datetime, value.strip)
    of "excerpt":
      assign(excerpt, value.strip)
    of "tags":
      result.tags = true
      result.data.tags = value.strip.split(", ")
    else: discard
    pos += skipWhitespace(s, pos)
    pos += skipWhile(s, {'\n'}, pos)
    if pos >= length or s[pos .. pos + 2] == "---":
      pos += 3 
      break
  result.content = s[pos ..< s.len]


proc parseHeader*(s: File): Article =
  result = parseHeader(s.readAll())   



var f = open("test.md", fmRead)
echo parseHeader(f.readAll())
  # pos += skip(s, pos)