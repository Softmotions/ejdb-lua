--package.path
package.path = "../?.lua;" .. package.path
package.cpath = "../?.so;" .. package.cpath

local inspect = require("inspect")
local ejdb = require("ejdb")
assert(type(ejdb) == "table")

assert(not pcall(function() ejdb.check_valid_oid_string("sss") end));
assert(pcall(function() ejdb.check_valid_oid_string("510f7fa91ad6270a00000000") end));

local Q = ejdb.Q
local B = ejdb.B

local db = ejdb:open("testdb", "rwct");
local q = Q("name", "Andy"):F("_id"):Eq("510f7fa91ad6270a00000000"):F("age"):Gt(20):Lt(40):F("score"):In({ 11, 22.12333, 1362835380447, db.toNull() }):Max(232);

assert([[.name(2)=Andy
._id(7)=510f7fa91ad6270a00000000
.age(3)=
..$gt(16)=20
..$lt(16)=40

.score(3)=
..$in(4)=
...1(16)=11
...2(1)=22.123330
...3(18)=1362835380447
...4(10)=BSON_NULL


]] == ejdb.print_bson(q:toBSON()))

local obj = ejdb.from_bson(q:toBSON())
--print(inspect(obj))
assert(obj.name == "Andy")
assert(obj._id == "510f7fa91ad6270a00000000")
assert(type(obj.age) == "table" and getmetatable(obj.age).__bsontype == db.BSON_OBJECT)
assert(obj["age"]["$gt"] == 20)
assert(obj["age"]["$lt"] == 40)
assert(type(obj.score) == "table" and getmetatable(obj.score).__bsontype == db.BSON_OBJECT)
assert(type(obj.score["$in"]) == "table" and getmetatable(obj.score["$in"]).__bsontype == db.BSON_ARRAY)
assert(#obj.score["$in"] == 4)

-- Second
--
q = Q("name", "Andy"):F("bdate"):Eq(db.toDate(1362835380447)):KV("car", Q("name", "Lamborghini"):KV("maxspeed", 320)):KV("dst", db.toNull());

assert([[.name(2)=Andy
.bdate(9)=1362835380447
.car(3)=
..name(2)=Lamborghini
..maxspeed(16)=320

.dst(10)=BSON_NULL
]] == ejdb.print_bson(q:toBSON()));

obj = ejdb.from_bson(q:toBSON())
assert(obj.name == "Andy")
assert(type(obj.bdate) == "table" and getmetatable(obj.bdate).__bsontype == db.BSON_DATE)
assert(obj.bdate[1] == 1362835380447)
assert(type(obj.dst) == "table" and getmetatable(obj.dst).__bsontype == db.BSON_NULL)

assert([[._id(7)=510f7fa91ad6270a00000000
.a(16)=2
.c(2)=d
.dd(3)=
..c(16)=1
..f(2)=v1
..gt(8)=true

.ee(2)=t
]] == ejdb.print_bson(ejdb.to_bson({ c = "d", a = 2, _id = "510f7fa91ad6270a00000000", dd = { f = "v1", gt = true, c = 1 }, ee = "t" })))

-- Test save
--
local oid = db:save("mycoll", { foo = "bar", k1 = "v1" });
ejdb.check_valid_oid_string(oid)

oid = db:save("mycoll", B("foo2", "bar2"):KV("g", "d"):KV("e", 1):KV("a", "g"));
ejdb.check_valid_oid_string(oid)

obj = db:load("mycoll", oid)
assert(type(obj) == "table")
assert(obj["_id"] == oid)
assert(obj.a == "g" and obj.e == 1 and obj.foo2 == "bar2" and obj.g == "d")

db:save("mycoll", { foo = "bar3" });
db:save("mycoll", { foo = "bar4" });
db:save("mycoll", { foo = "bar6", k2 = "v2" });

local qres, count, log = db:find("mycoll", Q("foo", "bar"))
assert(qres)
assert(count == 1)
assert(log == nil)
assert(#qres == 1)

for i = 1, #qres do
  local vobj = ejdb.from_bson(qres[i]);
  assert(vobj)
  assert(vobj["foo"] == "bar")
  assert(vobj["k1"] == "v1")
  ejdb.check_valid_oid_string(vobj["_id"])
end

for i = 1, #qres do
  assert(qres:field(i, "foo") == "bar")
  assert(qres:field(i, "k1") == "v1")
  local vobj = qres:object(i);
  assert(vobj)
  assert(vobj["foo"] == "bar")
  assert(vobj["k1"] == "v1")
  ejdb.check_valid_oid_string(vobj["_id"])
end

for o in qres() do

end

db:close()

collectgarbage()
collectgarbage()
collectgarbage()



