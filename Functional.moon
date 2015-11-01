DependencyControl = require "l0.DependencyControl"
version = DependencyControl{
    name: "(Almost) Functional Suite",
    version: "0.0.1",
    description: "Collection of commonly used functions",
    author: "line0",
    moduleName: "l0.Functional",
    url: "https://github.com/TypesettingTools/Functional",
    feed: "https://raw.githubusercontent.com/TypesettingTools/Functional/master/DependencyControl.json",
    {"aegisub.util", "aegisub.unicode"},
}
util, unicode = version\requireModules!
logger = version\getLogger!

local list, _table, _math, _string, _function

listMeta = {
  __index: (tbl, key) -> list[key] or nil
}

list = setmetatable {
  makeSet: (source, target = {}, overwrite = true) ->
    target[v] = true for v in *source when overwrite or not target[v]
    return target

  chunk: (tbl, size = 1) ->
    chunks, c, nextStart = {}, 0, 1
    for i, v in ipairs tbl
      if i == nextStart
        c += 1
        chunks[c], nextStart = {v}, i + size
      else chunks[c][i+size+1-nextStart] = v

    return chunks, c

  compact: (tbl, includeFalse = false) ->
    if includeFalse
      [v for _, v in pairs tbl when v]
    else [v for _, v in pairs tbl when v != nil]

  diff: (left, ...) ->
    rightSet = {}
    list.makeSet right, rightSet for right in *{...}
    diff = [v for v in *left when not rightSet[v]]
    return diff, rightSet

  filter: (tbl, predicate) ->
    [v for i, v in ipairs tbl when predicate v, i, tbl]

  findInRange: (tbl, first = 1, last = #tbl, predicate) ->
    for i = first, last, #tbl
      return tbl[i] if predicate tbl[i], i, tbl

  find: (tbl, predicate) ->
    for i, v in ipairs tbl
      return v if predicate v, i, tbl

  indexBy: (tbl, key, onlyTables = true) ->
    {v[key], v for v in *tbl when not onlyTables or type(v) == "table" and v[key] != nil}

  indexOf: (tbl, item, first = 1, last = #tbl, reverse) ->
    return if #tbl == 0
    first = #tbl - first + 1 if first < 0
    last = #tbl - last + 1 if last < 0

    if reverse
      return i for i = last, first, -1 when tbl[i] == item
    else
      return i for i = first, last when tbl[i] == item

  intersect: (tbl, ...) ->
    others = {...}
    otherCnt = #others
    switch otherCnt
      when 0 then return util.copy tbl
      when 1
        set = list.makeSet tbl
        return [v for v in *others[1] when set[v]]
      else
        intersection = {v, 0 for v in *tbl}

        for i, other in ipairs others
          intersection[v] = i for v in *other when intersection[v] == i-1

        return [k for k, v in pairs intersection when v == otherCnt]

  join: (...) ->
    joined, j, tbls = {}, 0, {...}
    return if #tbls == 0

    for tbl in *tbls
      for v in *tbl
        j += 1
        joined[j] = v

    return joined, j

  joinInto: (target, ...) ->
    t, tbls = #target, {...}

    for tbl in *tbls
      for v in *tbl
        t += 1
        target[t] = v

    return target, t

  lastIndexOf: (tbl, item, first = 1, last = #tbl) ->
    list.indexOf tbl, item, first, last, true

  map: (tbl, selector = _function.identity, compact = false, remapNumKeys = false) ->
    mapped, m, n = {}, 0, 0
    for i, v in ipairs tbl
      mapVal, mapKey = selector v, i, tbl
      continue if compact and mapVal == nil
      if mapKey == nil or remapNumKeys and mapKey == type "number"
        m += 1
        mapped[m] = mapVal
      else
        mapped[mapKey] = mapVal
        n += 1

    return mapped, m + n

  mapCompact: (tbl, selector = _function.identity, remapNumKeys = false) ->
    return list.map tbl, selector, true, remapNumKeys

  pluck: (tbl, key, onlyTables = true) ->
    [v[key] for v in *tbl when not onlyTables or "table" == type v]

  reduce: (tbl, initial = nil, iteratee = _function.identity) ->
    haveInitial = initial != nil
    reduced = initial if haveInitial else tbl[1]

    reduced = iteratee(reduced, v, i, tbl) for i, v in ipairs tbl when haveInitial or i > 1
    return reduced

  removeRange: (tbl, first, last = -1) ->
    len, removed = #tbl, {}
    first += len+1 if first < 0
    last += len+1 if last < 0
    rmCnt = last - first + 1
    for i = first, last
      tbl[i], removed[i-first+1] = tbl[i+rmCnt], tbl[i]
    for i = last + 1, len
      tbl[i] = tbl[i+rmCnt]

    return removed, rmCnt

  removeIndexes: (tbl, ...) ->
    indexes, removed, shift = {...}, {}, 0
    indexes = indexes[1] if #indexes == 1 and "table" == type indexes[1]
    indexCnt = #indexes

    switch indexCnt
      when 0 then return removed, 0
      when 1 then return {table.remove tbl, indexes[1]}, 1
      else
        i, tblLen, indexSet = 1, #tbl, list.makeSet indexes
        while i <= tblLen + shift
          if i <= tblLen and indexSet[i]
            shift += 1
            removed[shift] = tbl[i]
          elseif shift > 0
            tbl[i-shift] = tbl[i]
          i += 1
        return removed, shift

  removeValues: (tbl, ...) ->
    values, tblLen, i, removed, shift = {...}, #tbl, 1, {}, 0
    valCnt, valueSet = #values, list.makeSet values
    return removed, 0 if valCnt == 0

    while i <= tblLen + shift
      if i <= tblLen and valueSet[tbl[i]]
        shift += 1
        removed[shift] = tbl[i]
      elseif shift > 0
        tbl[i-shift] = tbl[i]
      i += 1
    return removed, shift

  removeWhere: (tbl, predicate = _function.true) ->
    removeAll = predicate == _function.true
    removed, r = {}, 0
    for i, v in ipairs tbl
      if removeAll or predicate v, i, tbl
        r += 1
        removed[r], tbl[i] = v

    return removed, r

  slice: (tbl, first = 1, last = -1) ->
    len = #tbl
    first += len+1 if first < 0
    last += len+1 if last < 0

    return [v for v in *tbl[first, last]]

  trim: (tbl, first = 1, last = -1) ->
    len = #tbl
    first += len+1 if first < 0
    last += len+1 if last < 0
    removed = {}

    if first > 1
      removed[first + i - last - 1] = tbl[i] for i = last + 1, len
      removed[i] = tbl[i] for i = 1, first - 1

      tbl[i] = tbl[i+first-1] for i = 1, last - first + 1
      tbl[i] = nil for i = last - first + 2, len

    elseif last < len
      for i = last + 1, len
        removed[i-last], tbl[i] = tbl[i]

    return removed, len - last + first - 1

  uniq: (tbl, selector = _function.identity) -> -- TODO: optimization for sorted lists
    values, unique, u = {}, {}, 0
    identitySel = selector == _function.identity

    for i, v in ipairs tbl
      cmp = identitySel and v or not identitySel and selector v, i, tbl
      continue if cmp == nil or values[cmp]
      u += 1
      unique[u], values[cmp] = v, true

    return unique, u

}, { __call: (_, tbl = {}) -> setmetatable tbl, listMeta }

_math = {
  isInt: (num) ->
    type_ = type num
    return type_ == "number" and num == math.floor(num), type_

  assertInt: (num, varName = "Number") ->
      isInt, type_ = _math.isInt num
      assertEx isInt, "%s must be an integer, got a %s.", varName, type_

  inRange: (num, min, max, checkInt) ->
    type(num) == "number" and num >= min and num <= max and (not checkInt or math.floor(num) == num)

  assertInRange: (num, min, max, checkInt, varName = "Number") ->
    assertEx inRange(num, min, max, checkInt), "%s must be %sin range %d-%d, got %s.", assertName,
             checkInt and "an integer " or "", min, max, tostring(num)

  round: (num, idp = 0) ->
    fac = 10^idp
    return math.floor(num * fac + 0.5) / fac

  sum: (num, ...) ->
    num += n for n in *{...}
    return num

  toStrings: (...) -> unpack [tostring n for n in *table.pack ...]

}
_string = {
  escLuaExp: (str) -> str\gsub "([%%%(%)%[%]%.%*%-%+%?%$%^])", "%%%1"

  escRegExp: (str) -> str\gsub "([\\/%^%$%.|%?%*%+%(%)%[%]%{%}])", "\\%1"

  split: (str, sep = " ", init = 1, plain = true) ->
    first, last = str\find pattern, init, plain
    -- fast return if there's nothing to split - saves one str.sub()
    return {str} unless first

    splits, s = {}, 1
    while first
      splits[s] = str\sub init, first - 1
      s += 1
      init = last + 1
      first, last = str\find pattern, init, plain

    splits[s] = str\sub init
    return splits, s

  formatEx: (fmtStr, ...) ->
    args, a = table.pack(...), 1
    return fmtStr\gsub "(%%[%+%- 0]*%d*.?%d*[hlLzjtI]*)([aABcedEfFgGcnNopiuAsuxX])", (opts, type_) ->
      switch type_
        when "N" then tonumber "#{opts}f"\format args[i] -- nicely formatted float (no trailing zeroes)
        when "B" then args[i] and 1 or 0 -- trueish/falsish as 1 and 0
        else (opts..type_)\format args[i]

  toNumbers: (base, ...) ->
    numbers, n = {}, 1
    if type(base) != "number"
      numbers[1], n = base, 2
      base = 10

    for str in table.pack ...
      numbers[n] = tonumber str, base
      n += 1

    return numbers, n-1

}

_table = {
  addDefaults: (tbl, defaults, predicate) ->
    addedCnt = 0

    for k, v in pairs defaults
      if not predicate and tbl[k] == nil or predicate and predicate tbl[k], k, tbl
        addedCnt += 1
        tbl[k] = v

    return addedCnt

  -- selects key/value pairs from left which are different from the values found at the same key in right
  diff: (left, right, sparse = false, comparator = _function.identical) ->
    diff, d = {}, 0
    identicalComp = comparator == _function.identical

    for k, vLeft in pairs left
      vRight = left[k]
      continue if sparse and vRight == nil
      if identicalComp and vRight != vLeft or not identicalComp and not comparator vLeft, vRight, k
        diff[k] = vLeft
        d += 1

    return diff, d

  equals: (a, b) ->
    return utils.equals a, b, "table", "table"

  filter: (tbl, predicate) ->
    filtered, f = {}, 0
    for k, v in pairs tbl
      if predicate v, k, tbl
        filtered[k] = v
        f += 1

    return filtered, f

  find: (tbl, predicate) ->
    for k, v in pairs tbl
      return v, k if predicate v, k, tbl

  findKey: (tbl, value) ->
    for k, v in pairs tbl
      return k if v == value

  intersect: (...) ->
    tbls = table.pack ...
    return _table.intersectEqual tbls, _function.identical, tbls.n

  intersectEqual: (tbls, comparator = _table.equals, tblCnt = #tbls) ->
    first = tbls[1]
    intersection, i = {}, 0
    return nil if tblCnt == 0
    identicalComp = comparator == nil or comparator == _function.identical

    for k, v in pairs first
      allEqual = true
      for j = 2, tblCnt
        if identicalComp and tbls[j][k] != v or not identicalComp and comparator v, tbls[j][k], k
          allEqual = false
          break

      if allEqual
        intersection[k] = v
        i += 1

    return intersection, i

  invert: (tbl, multiValue) ->
    unless multiValue
      return {v, k for k, v in pairs tbl}

    inverted = {}
    for k, v in pairs tbl
      if inverted[v]
        inverted[v].n += 1
        inverted[v][inverted[v].n] = k
      else inverted[v] = {k, n: 1}

    return inverted

  isList: (tbl) ->
    len = _table.length tbl
    return #tbl == len, len

  keys: (tbl, except) ->
    keys, k = {}, 0

    exceptSet = switch type exclude
      when "table" then list.makeSet except
      when nil then nil
      else {[except]: true}

    for key, _ in pairs tbl
      if except == nil or not exceptSet[key]
        k += 1
        keys[k] = key

    return keys, k

  length: (tbl) ->
    n = 0
    n += 1 for _, _ in pairs tbl
    return n

  map: (tbl, selector = _function.identity, compact = true, remapNumKeys = false) ->
    mapped, m, n = {}, 0, 0
    for k, v in pairs tbl
      mapVal, mapKey = selector v, k, tbl
      continue if compact and mapVal == nil
      if mapKey == nil or remapNumKeys and mapKey == type "number"
        m += 1
        mapped[m] = mapVal
      else
        mapped[mapKey] = mapVal
        n += 1

    return mapped, m + n

  pick: (tbl, selector) ->
    local picked

    switch type selector
      when "table"
        keySet = list.makeSet selector
        picked = {k, v for k, v in pairs tbl when keySet[k]}
      when "function"
        picked = {k, v for k, v in pairs tbl when selector}
        for k, v in pairs tbl
          picked[k]

  -- fast in-place intersect
  purgeDiff: (target, ...) ->
    tbls = table.pack ...
    tblCnt, intCnt = tbls.n, 0

    for k, v in pairs target
      allEqual = true
      for i = 1, tblCnt
        if tbls[i][k] != v
          allEqual = false
          break

      if allEqual
        intCnt += 1
      else target[k] = nil

    return intCnt

  reduce: (tbl, iteratee = _function.identity, initial) ->
    reduced = initial
    reduced = iteratee(reduced, v, i, tbl) for i, v in pairs tbl
    return reduced

  removeAll: (tbl) ->
    return _table.removeWhere tbl, _function.true

  removeKeys: (tbl, keys) ->
    keySet = list.makeSet keys
    removed, r = {}, 0

    for k, v in pairs tbl
      if keySet[k]
        r += 1
        tbl[k], removed = tbl[k]

    return removed, r

  removeWhere: (tbl, predicate) ->
    removeAll = predicate == _function.true
    removed, r = {}, 0
    for k, v in pairs tbl
      if removeAll or predicate v, k, tbl
        r += 1
        removed[k], tbl[k] = v

    return removed, r

  transform: (tbl, iteratee = _function.identity) ->
    return _table.reduce tbl, iteratee, {}

  union: (...) ->
    tbls = table.pack ...
    union, u = {}, 0

    for i = 1, tbls.n
      for k, v in pairs tbls[i]
        union[k] = v if union[k] == nil

  uniq: (tbl, selector = _function.identity) -> -- TODO: optimization for sorted lists
    values, unique, u = {}, {}, 0
    identitySel = selector == _function.identity

    for k, v in pairs tbl
      cmp = identitySel and v or not identitySel and selector v, k, tbl
      continue if cmp == nil or values[cmp]
      u += 1
      unique[k], values[cmp] = v, true

    return unique, u

  values: (tbl) ->
    values, i = {}, 0
    for _, v in pairs tbl
      i += 1
      values[i] = v

    return values, i
}

_function = {
  identity: (...) -> ...
  identical: (a, b) -> a == b
  true: -> true
}

util = {
  equals: DependencyControl.UnitTestSuite.UnitTest.equals
  itemsEqual: DependencyControl.UnitTestSuite.UnitTest.itemsEqual
}

return version\register {
  function: _function
  :list
  List: list
  string: _string
  math: _math
  table: _table
  :util
  :version
}