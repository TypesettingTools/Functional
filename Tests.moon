DependencyControl = require "l0.DependencyControl"

DependencyControl.UnitTestSuite "l0.Functional", (cmn, util, unicode) -> {
  ListFunctions: {
    _description: "Test all functions for continuous, numerically indexed tables (list.*)"
    _setup: (ut) ->
      testFunc = () ->
      testTables = {
        mixedList:   {"a", 15, false, {"test"}, testFunc         }
        contList:    {"a", "b", "c", "d"                         }
        numbersList: {10, 11, 12, 13, 14, 15                     }
        joinedList:  {10, 11, 12, 13, 14, 15, "a", "b", "c", "d" }
        repeatList:  {"a", "b", "c", "b", "a", "d"               }
        gapList:     {"a", "b", nil, "c", "d"                    }
        stringSet:   {a: true, b: true, c: true, d: true         }
        stringUnset: {a: false, b: false, c: false, d: false     }
        tableList:   {{a: 1}, {b: 2}, 3, {a: 4}                  }
      }

      testData = {
        string: "This is a test."
        uniString: "仕方が無い"
      }

      return testTables, testFunc

    chunk: (ut, tbls, f) ->
      chunks = cmn.list.chunk tbls.mixedList, 2
      ut\assertEquals chunks, {{"a", 15}, {false, {"test"}, }, {f}}

    compact: (ut, tbls) ->
      list = cmn.list.compact tbls.gapList
      ut\assertEquals list, tbls.contList

    diff: (ut, tbls, f) ->
      diff, rightSet = cmn.list.diff tbls.mixedList, tbls.contList, tbls.numbersList
      ut\assertEquals diff, {false, {"test"}, f }

    filter: (ut, tbls) ->
      filtered = cmn.list.filter tbls.mixedList, (v, i) ->
        i == 3 or "string" == type v
      ut\assertEquals filtered, {"a", false}

    find: (ut, tbls) ->
      result = cmn.list.find tbls.numbersList, (v) -> v > 12
      ut\assertEquals result, 13

    findInRange: (ut, tbls) ->
      result = cmn.list.findInRange tbls.numbersList, 5, nil, (v) -> v > 12
      ut\assertEquals result, 14

    indexBy: (ut, tbls) ->
      result = cmn.list.indexBy tbls.tableList, "a"
      ut\assertEquals result, {{a: 1}, nil, nil, {a: 4} }

    indexOf: (ut, tbls) ->
      index = cmn.list.indexOf tbls.repeatList, "b", 3
      ut\assertEquals index, 4

    intersect: (ut, tbls) ->
      intersection = cmn.list.intersect tbls.mixedList, tbls.contList, tbls.repeatList
      ut\assertEquals intersection, {"a"}

    join: (ut, tbls) ->
      joined = cmn.list.join tbls.numbersList, tbls.contList
      ut\assertIsNot joined, tbls.numbersList
      ut\assertEquals joined, tbls.joinedList

    joinInto: (ut, tbls) ->
      numbersList = util.copy tbls.numbersList
      joined = cmn.list.joinInto numbersList, tbls.contList
      ut\assertIs joined, numbersList
      ut\assertEquals joined, tbls.joinedList

    lastIndexOf: (ut, tbls) ->
      index = cmn.list.lastIndexOf tbls.repeatList, "b", nil, 3
      ut\assertEquals index, 2

    listMetaType: (ut, tbls) ->
      list = cmn.list tbls.numbersList
      len = list\reduce 0, (result) -> result + 1
      ut\assertEquals len, #tbls.numbersList

    makeSetDef: (ut, tbls) ->
      set = cmn.list.makeSet tbls.contList
      ut\assertEquals set, tbls.stringSet
      ut\assertIsNot set, tbls.contList

    makeSetInline: (ut, tbls) ->
      set = util.copy tbls.contList
      set.a = false

      set2 = cmn.list.makeSet set, set, false
      ut\assertIs set2, set
      ut\assertEquals set2, {"a", "b", "c", "d", a: true, b: true, c: true, d: true}

    map: (ut, tbls) ->
      mapped = cmn.list.map tbls.numbersList, (v) -> v / 2 if v%2 == 0
      ut\assertEquals mapped, {5, nil, 6, nil, 7}

    mapCompact: (ut, tbls) ->
      mapped = cmn.list.mapCompact tbls.numbersList, (v) -> v / 2 if v%2 == 0
      ut\assertEquals mapped, {5, 6, 7}

    pluck: (ut, tbls) ->
      plucked = cmn.list.pluck tbls.tableList, "a"
      ut\assertEquals plucked, {1, nil, 4}

    reduce: (ut, tbls) ->
      result = cmn.list.reduce tbls.numbersList, 0, (result, v) -> result + v
      ut\assertEquals result, 75

    removeRange: (ut, tbls) ->
      tbl = util.copy tbls.repeatList
      removed, rmCnt = cmn.list.removeRange tbl, 4, 5
      ut\assertEquals rmCnt, 2
      ut\assertEquals removed, {"b", "a"}
      ut\assertEquals tbl, tbls.contList

    removeIndexes: (ut, tbls) ->
      tbl = util.copy tbls.repeatList
      removed, rmCnt = cmn.list.removeIndexes tbl, 4, 5
      ut\assertEquals rmCnt, 2
      ut\assertEquals removed, {"b", "a"}
      ut\assertEquals tbl, tbls.contList

    removeValues: (ut, tbls, f) ->
      tbl = util.copy tbls.mixedList
      removed, rmCnt = cmn.list.removeValues tbl, f, false, 15
      ut\assertEquals rmCnt, 3
      ut\assertEquals removed, {15, false, f}
      ut\assertEquals tbl, {"a", {"test"}}

    removeWhere: (ut, tbls, f) ->
      tbl = util.copy tbls.mixedList
      removed, rmCnt = cmn.list.removeWhere tbl, (v, i) ->
        type(v) == "string" or i == 2
      ut\assertEquals rmCnt, 2
      ut\assertEquals removed, {"a", 15}
      ut\assertEquals tbl, {false, {"test"}, f}

    slice: (ut, tbls) ->
      sliced = cmn.list.slice tbls.joinedList, 7, -1
      ut\assertIsNot sliced, tbls.joinedList
      ut\assertEquals sliced, tbls.contList

    trimEnd: (ut, tbls) ->
      trimmed = util.copy tbls.joinedList
      removed, rmCnt = cmn.list.trim trimmed, nil, 6
      ut\assertEquals rmCnt, 4
      ut\assertEquals removed, tbls.contList
      ut\assertEquals trimmed, tbls.numbersList

    trimBoth: (ut, tbls) ->
      trimmed = util.copy tbls.joinedList
      removed, rmCnt = cmn.list.trim trimmed, 6, -3
      ut\assertEquals rmCnt, 7
      ut\assertEquals removed, {10, 11, 12, 13, 14, "c", "d"}
      ut\assertEquals trimmed, {15, "a", "b"}

    uniq: (ut, tbls) ->
      unique, u = cmn.list.uniq tbls.repeatList
      ut\assertEquals u, #tbls.contList
      ut\assertEquals unique, tbls.contList

    uniqCallback: (ut, tbls) ->
      unique, u = cmn.list.uniq tbls.numbersList, (v) -> math.floor v/2
      ut\assertEquals u, 3
      ut\assertEquals, unique, {5, 6, 7}

    _order: {"makeSetDef", "makeSetInline", "compact", "chunk", "diff", "filter", "find", "findInRange",
             "indexBy", "indexOf", "lastIndexOf", "intersect", "join", "joinInto", "removeRange", "removeIndexes",
             "removeValues", "slice", "trimEnd", "trimBoth", "map", "mapCompact", "reduce", "pluck",
             "uniq", "uniqCallback", "listMetaType", "removeWhere"}
  }
}
