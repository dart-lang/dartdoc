(function dartProgram(){function copyProperties(a,b){var s=Object.keys(a)
for(var r=0;r<s.length;r++){var q=s[r]
b[q]=a[q]}}function mixinPropertiesHard(a,b){var s=Object.keys(a)
for(var r=0;r<s.length;r++){var q=s[r]
if(!b.hasOwnProperty(q)){b[q]=a[q]}}}function mixinPropertiesEasy(a,b){Object.assign(b,a)}var z=function(){var s=function(){}
s.prototype={p:{}}
var r=new s()
if(!(Object.getPrototypeOf(r)&&Object.getPrototypeOf(r).p===s.prototype.p))return false
try{if(typeof navigator!="undefined"&&typeof navigator.userAgent=="string"&&navigator.userAgent.indexOf("Chrome/")>=0)return true
if(typeof version=="function"&&version.length==0){var q=version()
if(/^\d+\.\d+\.\d+\.\d+$/.test(q))return true}}catch(p){}return false}()
function inherit(a,b){a.prototype.constructor=a
a.prototype["$i"+a.name]=a
if(b!=null){if(z){Object.setPrototypeOf(a.prototype,b.prototype)
return}var s=Object.create(b.prototype)
copyProperties(a.prototype,s)
a.prototype=s}}function inheritMany(a,b){for(var s=0;s<b.length;s++){inherit(b[s],a)}}function mixinEasy(a,b){mixinPropertiesEasy(b.prototype,a.prototype)
a.prototype.constructor=a}function mixinHard(a,b){mixinPropertiesHard(b.prototype,a.prototype)
a.prototype.constructor=a}function lazy(a,b,c,d){var s=a
a[b]=s
a[c]=function(){if(a[b]===s){a[b]=d()}a[c]=function(){return this[b]}
return a[b]}}function lazyFinal(a,b,c,d){var s=a
a[b]=s
a[c]=function(){if(a[b]===s){var r=d()
if(a[b]!==s){A.kB(b)}a[b]=r}var q=a[b]
a[c]=function(){return q}
return q}}function makeConstList(a,b){if(b!=null)A.l(a,b)
a.$flags=7
return a}function convertToFastObject(a){function t(){}t.prototype=a
new t()
return a}function convertAllToFastObject(a){for(var s=0;s<a.length;++s){convertToFastObject(a[s])}}var y=0
function instanceTearOffGetter(a,b){var s=null
return a?function(c){if(s===null)s=A.f3(b)
return new s(c,this)}:function(){if(s===null)s=A.f3(b)
return new s(this,null)}}function staticTearOffGetter(a){var s=null
return function(){if(s===null)s=A.f3(a).prototype
return s}}var x=0
function tearOffParameters(a,b,c,d,e,f,g,h,i,j){if(typeof h=="number"){h+=x}return{co:a,iS:b,iI:c,rC:d,dV:e,cs:f,fs:g,fT:h,aI:i||0,nDA:j}}function installStaticTearOff(a,b,c,d,e,f,g,h){var s=tearOffParameters(a,true,false,c,d,e,f,g,h,false)
var r=staticTearOffGetter(s)
a[b]=r}function installInstanceTearOff(a,b,c,d,e,f,g,h,i,j){c=!!c
var s=tearOffParameters(a,false,c,d,e,f,g,h,i,!!j)
var r=instanceTearOffGetter(c,s)
a[b]=r}function setOrUpdateInterceptorsByTag(a){var s=v.interceptorsByTag
if(!s){v.interceptorsByTag=a
return}copyProperties(a,s)}function setOrUpdateLeafTags(a){var s=v.leafTags
if(!s){v.leafTags=a
return}copyProperties(a,s)}function updateTypes(a){var s=v.types
var r=s.length
s.push.apply(s,a)
return r}function updateHolder(a,b){copyProperties(b,a)
return a}var hunkHelpers=function(){var s=function(a,b,c,d,e){return function(f,g,h,i){return installInstanceTearOff(f,g,a,b,c,d,[h],i,e,false)}},r=function(a,b,c,d){return function(e,f,g,h){return installStaticTearOff(e,f,a,b,c,[g],h,d)}}
return{inherit:inherit,inheritMany:inheritMany,mixin:mixinEasy,mixinHard:mixinHard,installStaticTearOff:installStaticTearOff,installInstanceTearOff:installInstanceTearOff,_instance_0u:s(0,0,null,["$0"],0),_instance_1u:s(0,1,null,["$1"],0),_instance_2u:s(0,2,null,["$2"],0),_instance_0i:s(1,0,null,["$0"],0),_instance_1i:s(1,1,null,["$1"],0),_instance_2i:s(1,2,null,["$2"],0),_static_0:r(0,null,["$0"],0),_static_1:r(1,null,["$1"],0),_static_2:r(2,null,["$2"],0),makeConstList:makeConstList,lazy:lazy,lazyFinal:lazyFinal,updateHolder:updateHolder,convertToFastObject:convertToFastObject,updateTypes:updateTypes,setOrUpdateInterceptorsByTag:setOrUpdateInterceptorsByTag,setOrUpdateLeafTags:setOrUpdateLeafTags}}()
function initializeDeferredHunk(a){x=v.types.length
a(hunkHelpers,v,w,$)}var J={
f8(a,b,c,d){return{i:a,p:b,e:c,x:d}},
f5(a){var s,r,q,p,o,n="_$dart_js",m=a[v.dispatchPropertyName]
if(m==null)if($.f6==null){A.km()
m=a[v.dispatchPropertyName]}if(m!=null){s=m.p
if(!1===s)return m.i
if(!0===s)return a
r=Object.getPrototypeOf(a)
if(s===r)return m.i
if(m.e===r)throw A.a(A.fA("Return interceptor for "+A.i(s(a,m))))}q=a.constructor
if(q==null)p=null
else{o=$.dp
if(o==null)o=$.dp=A.e8(n)
p=q[o]}if(p!=null)return p
p=A.kr(a)
if(p!=null)return p
if(typeof a=="function")return B.I
s=Object.getPrototypeOf(a)
if(s==null)return B.t
if(s===Object.prototype)return B.t
if(typeof q=="function"){o=$.dp
if(o==null)o=$.dp=A.e8(n)
Object.defineProperty(q,o,{value:B.j,enumerable:false,writable:true,configurable:true})
return B.j}return B.j},
i8(a,b){if(a<0||a>4294967295)throw A.a(A.F(a,0,4294967295,"length",null))
return J.i9(new Array(a),b)},
i9(a,b){var s=A.l(a,b.j("p<0>"))
s.$flags=1
return s},
ia(a,b){return J.hN(a,b)},
fl(a){if(a<256)switch(a){case 9:case 10:case 11:case 12:case 13:case 32:case 133:case 160:return!0
default:return!1}switch(a){case 5760:case 8192:case 8193:case 8194:case 8195:case 8196:case 8197:case 8198:case 8199:case 8200:case 8201:case 8202:case 8232:case 8233:case 8239:case 8287:case 12288:case 65279:return!0
default:return!1}},
ib(a,b){var s,r
for(s=a.length;b<s;){r=a.charCodeAt(b)
if(r!==32&&r!==13&&!J.fl(r))break;++b}return b},
ic(a,b){var s,r
for(;b>0;b=s){s=b-1
r=a.charCodeAt(s)
if(r!==32&&r!==13&&!J.fl(r))break}return b},
aq(a){if(typeof a=="number"){if(Math.floor(a)==a)return J.aY.prototype
return J.bR.prototype}if(typeof a=="string")return J.a4.prototype
if(a==null)return J.aZ.prototype
if(typeof a=="boolean")return J.bQ.prototype
if(Array.isArray(a))return J.p.prototype
if(typeof a!="object"){if(typeof a=="function")return J.a5.prototype
if(typeof a=="symbol")return J.b2.prototype
if(typeof a=="bigint")return J.b0.prototype
return a}if(a instanceof A.k)return a
return J.f5(a)},
e6(a){if(typeof a=="string")return J.a4.prototype
if(a==null)return a
if(Array.isArray(a))return J.p.prototype
if(typeof a!="object"){if(typeof a=="function")return J.a5.prototype
if(typeof a=="symbol")return J.b2.prototype
if(typeof a=="bigint")return J.b0.prototype
return a}if(a instanceof A.k)return a
return J.f5(a)},
e7(a){if(a==null)return a
if(Array.isArray(a))return J.p.prototype
if(typeof a!="object"){if(typeof a=="function")return J.a5.prototype
if(typeof a=="symbol")return J.b2.prototype
if(typeof a=="bigint")return J.b0.prototype
return a}if(a instanceof A.k)return a
return J.f5(a)},
ke(a){if(typeof a=="number")return J.b_.prototype
if(typeof a=="string")return J.a4.prototype
if(a==null)return a
if(!(a instanceof A.k))return J.ak.prototype
return a},
kf(a){if(typeof a=="string")return J.a4.prototype
if(a==null)return a
if(!(a instanceof A.k))return J.ak.prototype
return a},
u(a,b){if(a==null)return b==null
if(typeof a!="object")return b!=null&&a===b
return J.aq(a).G(a,b)},
hK(a,b){if(typeof b==="number")if(Array.isArray(a)||typeof a=="string"||A.hl(a,a[v.dispatchPropertyName]))if(b>>>0===b&&b<a.length)return a[b]
return J.e6(a).k(a,b)},
hL(a,b,c){if(typeof b==="number")if((Array.isArray(a)||A.hl(a,a[v.dispatchPropertyName]))&&!(a.$flags&2)&&b>>>0===b&&b<a.length)return a[b]=c
return J.e7(a).q(a,b,c)},
hM(a,b){return J.e7(a).a1(a,b)},
hN(a,b){return J.ke(a).a3(a,b)},
fa(a,b){return J.e7(a).E(a,b)},
a2(a){return J.aq(a).gn(a)},
aQ(a){return J.e7(a).gB(a)},
a3(a){return J.e6(a).gl(a)},
hO(a){return J.aq(a).gt(a)},
T(a){return J.aq(a).h(a)},
hP(a){return J.kf(a).c7(a)},
bO:function bO(){},
bQ:function bQ(){},
aZ:function aZ(){},
b1:function b1(){},
a6:function a6(){},
c4:function c4(){},
ak:function ak(){},
a5:function a5(){},
b0:function b0(){},
b2:function b2(){},
p:function p(a){this.$ti=a},
bP:function bP(){},
cL:function cL(a){this.$ti=a},
Q:function Q(a,b,c){var _=this
_.a=a
_.b=b
_.c=0
_.d=null
_.$ti=c},
b_:function b_(){},
aY:function aY(){},
bR:function bR(){},
a4:function a4(){}},A={eu:function eu(){},
hS(a,b,c){if(t.U.b(a))return new A.bl(a,b.j("@<0>").D(c).j("bl<1,2>"))
return new A.ae(a,b.j("@<0>").D(c).j("ae<1,2>"))},
fn(a){return new A.bT("Field '"+a+"' has been assigned during initialization.")},
e9(a){var s,r=a^48
if(r<=9)return r
s=a|32
if(97<=s&&s<=102)return s-87
return-1},
a9(a,b){a=a+b&536870911
a=a+((a&524287)<<10)&536870911
return a^a>>>6},
eC(a){a=a+((a&67108863)<<3)&536870911
a^=a>>>11
return a+((a&16383)<<15)&536870911},
f2(a,b,c){return a},
f7(a){var s,r
for(s=$.ao.length,r=0;r<s;++r)if(a===$.ao[r])return!0
return!1},
fk(){return new A.bg("No element")},
aa:function aa(){},
bI:function bI(a,b){this.a=a
this.$ti=b},
ae:function ae(a,b){this.a=a
this.$ti=b},
bl:function bl(a,b){this.a=a
this.$ti=b},
bk:function bk(){},
V:function V(a,b){this.a=a
this.$ti=b},
bT:function bT(a){this.a=a},
bJ:function bJ(a){this.a=a},
cU:function cU(){},
c:function c(){},
L:function L(){},
av:function av(a,b,c){var _=this
_.a=a
_.b=b
_.c=0
_.d=null
_.$ti=c},
aj:function aj(a,b,c){this.a=a
this.b=b
this.$ti=c},
ay:function ay(a,b){this.a=a
this.$ti=b},
c2:function c2(a){this.a=a
this.b=null},
aX:function aX(){},
ca:function ca(){},
aA:function aA(){},
bA:function bA(){},
hY(){throw A.a(A.bi("Cannot modify unmodifiable Map"))},
hr(a){var s=A.hq(a)
if(s!=null)return s
return"minified:"+a},
hl(a,b){var s
if(b!=null){s=b.x
if(s!=null)return s}return t.p.b(a)},
i(a){var s
if(typeof a=="string")return a
if(typeof a=="number"){if(a!==0)return""+a}else if(!0===a)return"true"
else if(!1===a)return"false"
else if(a==null)return"null"
s=J.T(a)
return s},
c5(a){var s,r=$.fq
if(r==null)r=$.fq=Symbol("identityHashCode")
s=a[r]
if(s==null){s=Math.random()*0x3fffffff|0
a[r]=s}return s},
fr(a,b){var s,r=/^\s*[+-]?((0x[a-f0-9]+)|(\d+)|([a-z0-9]+))\s*$/i.exec(a)
if(r==null)return null
s=r[3]
if(s!=null)return parseInt(a,10)
if(r[2]!=null)return parseInt(a,16)
return null},
c6(a){var s,r,q,p
if(a instanceof A.k)return A.G(A.aO(a),null)
s=J.aq(a)
if(s===B.H||s===B.J||t.A.b(a)){r=B.o(a)
if(r!=="Object"&&r!=="")return r
q=a.constructor
if(typeof q=="function"){p=q.name
if(typeof p=="string"&&p!=="Object"&&p!=="")return p}}return A.G(A.aO(a),null)},
fs(a){var s,r,q
if(a==null||typeof a=="number"||A.eV(a))return J.T(a)
if(typeof a=="string")return JSON.stringify(a)
if(a instanceof A.af)return a.h(0)
if(a instanceof A.bq)return a.aQ(!0)
s=$.hJ()
for(r=0;r<1;++r){q=s[r].c8(a)
if(q!=null)return q}return"Instance of '"+A.c6(a)+"'"},
ij(a,b,c){var s,r,q,p
if(c<=500&&b===0&&c===a.length)return String.fromCharCode.apply(null,a)
for(s=b,r="";s<c;s=q){q=s+500
p=q<c?q:c
r+=String.fromCharCode.apply(null,a.subarray(s,p))}return r},
a7(a){var s
if(0<=a){if(a<=65535)return String.fromCharCode(a)
if(a<=1114111){s=a-65536
return String.fromCharCode((B.b.ai(s,10)|55296)>>>0,s&1023|56320)}}throw A.a(A.F(a,0,1114111,null,null))},
ii(a){var s=a.$thrownJsError
if(s==null)return null
return A.aN(s)},
ft(a,b){var s
if(a.$thrownJsError==null){s=new Error()
A.w(a,s)
a.$thrownJsError=s
s.stack=b.h(0)}},
f4(a,b){var s,r="index"
if(!A.h4(b))return new A.I(!0,b,r,null)
s=J.a3(a)
if(b<0||b>=s)return A.er(b,s,a,r)
return A.ik(b,r)},
kb(a,b,c){if(a>c)return A.F(a,0,c,"start",null)
if(b!=null)if(b<a||b>c)return A.F(b,a,c,"end",null)
return new A.I(!0,b,"end",null)},
k5(a){return new A.I(!0,a,null,null)},
a(a){return A.w(a,new Error())},
w(a,b){var s
if(a==null)a=new A.X()
b.dartException=a
s=A.kC
if("defineProperty" in Object){Object.defineProperty(b,"message",{get:s})
b.name=""}else b.toString=s
return b},
kC(){return J.T(this.dartException)},
as(a,b){throw A.w(a,b==null?new Error():b)},
O(a,b,c){var s
if(b==null)b=0
if(c==null)c=0
s=Error()
A.as(A.jq(a,b,c),s)},
jq(a,b,c){var s,r,q,p,o,n,m,l,k
if(typeof b=="string")s=b
else{r="[]=;add;removeWhere;retainWhere;removeRange;setRange;setInt8;setInt16;setInt32;setUint8;setUint16;setUint32;setFloat32;setFloat64".split(";")
q=r.length
p=b
if(p>q){c=p/q|0
p%=q}s=r[p]}o=typeof c=="string"?c:"modify;remove from;add to".split(";")[c]
n=t.j.b(a)?"list":"ByteData"
m=a.$flags|0
l="a "
if((m&4)!==0)k="constant "
else if((m&2)!==0){k="unmodifiable "
l="an "}else k=(m&1)!==0?"fixed-length ":""
return new A.bh("'"+s+"': Cannot "+o+" "+l+k+n)},
a1(a){throw A.a(A.ag(a))},
Y(a){var s,r,q,p,o,n
a=A.kv(a.replace(String({}),"$receiver$"))
s=a.match(/\\\$[a-zA-Z]+\\\$/g)
if(s==null)s=A.l([],t.s)
r=s.indexOf("\\$arguments\\$")
q=s.indexOf("\\$argumentsExpr\\$")
p=s.indexOf("\\$expr\\$")
o=s.indexOf("\\$method\\$")
n=s.indexOf("\\$receiver\\$")
return new A.cX(a.replace(new RegExp("\\\\\\$arguments\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$argumentsExpr\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$expr\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$method\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$receiver\\\\\\$","g"),"((?:x|[^x])*)"),r,q,p,o,n)},
cY(a){return function($expr$){var $argumentsExpr$="$arguments$"
try{$expr$.$method$($argumentsExpr$)}catch(s){return s.message}}(a)},
fz(a){return function($expr$){try{$expr$.$method$}catch(s){return s.message}}(a)},
ev(a,b){var s=b==null,r=s?null:b.method
return new A.bS(a,r,s?null:b.receiver)},
at(a){if(a==null)return new A.cT(a)
if(a instanceof A.aW)return A.ad(a,a.a)
if(typeof a!=="object")return a
if("dartException" in a)return A.ad(a,a.dartException)
return A.k4(a)},
ad(a,b){if(t.C.b(b))if(b.$thrownJsError==null)b.$thrownJsError=a
return b},
k4(a){var s,r,q,p,o,n,m,l,k,j,i,h,g
if(!("message" in a))return a
s=a.message
if("number" in a&&typeof a.number=="number"){r=a.number
q=r&65535
if((B.b.ai(r,16)&8191)===10)switch(q){case 438:return A.ad(a,A.ev(A.i(s)+" (Error "+q+")",null))
case 445:case 5007:A.i(s)
return A.ad(a,new A.bb())}}if(a instanceof TypeError){p=$.ht()
o=$.hu()
n=$.hv()
m=$.hw()
l=$.hz()
k=$.hA()
j=$.hy()
$.hx()
i=$.hC()
h=$.hB()
g=p.C(s)
if(g!=null)return A.ad(a,A.ev(s,g))
else{g=o.C(s)
if(g!=null){g.method="call"
return A.ad(a,A.ev(s,g))}else if(n.C(s)!=null||m.C(s)!=null||l.C(s)!=null||k.C(s)!=null||j.C(s)!=null||m.C(s)!=null||i.C(s)!=null||h.C(s)!=null)return A.ad(a,new A.bb())}return A.ad(a,new A.c9(typeof s=="string"?s:""))}if(a instanceof RangeError){if(typeof s=="string"&&s.indexOf("call stack")!==-1)return new A.bf()
s=function(b){try{return String(b)}catch(f){}return null}(a)
return A.ad(a,new A.I(!1,null,null,typeof s=="string"?s.replace(/^RangeError:\s*/,""):s))}if(typeof InternalError=="function"&&a instanceof InternalError)if(typeof s=="string"&&s==="too much recursion")return new A.bf()
return a},
aN(a){var s
if(a instanceof A.aW)return a.b
if(a==null)return new A.br(a)
s=a.$cachedTrace
if(s!=null)return s
s=new A.br(a)
if(typeof a==="object")a.$cachedTrace=s
return s},
hn(a){if(a==null)return J.a2(a)
if(typeof a=="object")return A.c5(a)
return J.a2(a)},
kd(a,b){var s,r,q,p=a.length
for(s=0;s<p;s=q){r=s+1
q=r+1
b.q(0,a[s],a[r])}return b},
jF(a,b,c,d,e,f){switch(b){case 0:return a.$0()
case 1:return a.$1(c)
case 2:return a.$2(c,d)
case 3:return a.$3(c,d,e)
case 4:return a.$4(c,d,e,f)}throw A.a(new A.da("Unsupported number of arguments for wrapped closure"))},
aM(a,b){var s=a.$identity
if(!!s)return s
s=A.k9(a,b)
a.$identity=s
return s},
k9(a,b){var s
switch(b){case 0:s=a.$0
break
case 1:s=a.$1
break
case 2:s=a.$2
break
case 3:s=a.$3
break
case 4:s=a.$4
break
default:s=null}if(s!=null)return s.bind(a)
return function(c,d,e){return function(f,g,h,i){return e(c,d,f,g,h,i)}}(a,b,A.jF)},
hX(a2){var s,r,q,p,o,n,m,l,k,j,i=a2.co,h=a2.iS,g=a2.iI,f=a2.nDA,e=a2.aI,d=a2.fs,c=a2.cs,b=d[0],a=c[0],a0=i[b],a1=a2.fT
a1.toString
s=h?Object.create(new A.cV().constructor.prototype):Object.create(new A.aR(null,null).constructor.prototype)
s.$initialize=s.constructor
r=h?function static_tear_off(){this.$initialize()}:function tear_off(a3,a4){this.$initialize(a3,a4)}
s.constructor=r
r.prototype=s
s.$_name=b
s.$_target=a0
q=!h
if(q)p=A.fh(b,a0,g,f)
else{s.$static_name=b
p=a0}s.$S=A.hT(a1,h,g)
s[a]=p
for(o=p,n=1;n<d.length;++n){m=d[n]
if(typeof m=="string"){l=i[m]
k=m
m=l}else k=""
j=c[n]
if(j!=null){if(q)m=A.fh(k,m,g,f)
s[j]=m}if(n===e)o=m}s.$C=o
s.$R=a2.rC
s.$D=a2.dV
return r},
hT(a,b,c){if(typeof a=="number")return a
if(typeof a=="string"){if(b)throw A.a("Cannot compute signature for static tearoff.")
return function(d,e){return function(){return e(this,d)}}(a,A.hQ)}throw A.a("Error in functionType of tearoff")},
hU(a,b,c,d){var s=A.fg
switch(b?-1:a){case 0:return function(e,f){return function(){return f(this)[e]()}}(c,s)
case 1:return function(e,f){return function(g){return f(this)[e](g)}}(c,s)
case 2:return function(e,f){return function(g,h){return f(this)[e](g,h)}}(c,s)
case 3:return function(e,f){return function(g,h,i){return f(this)[e](g,h,i)}}(c,s)
case 4:return function(e,f){return function(g,h,i,j){return f(this)[e](g,h,i,j)}}(c,s)
case 5:return function(e,f){return function(g,h,i,j,k){return f(this)[e](g,h,i,j,k)}}(c,s)
default:return function(e,f){return function(){return e.apply(f(this),arguments)}}(d,s)}},
fh(a,b,c,d){if(c)return A.hW(a,b,d)
return A.hU(b.length,d,a,b)},
hV(a,b,c,d){var s=A.fg,r=A.hR
switch(b?-1:a){case 0:throw A.a(new A.c7("Intercepted function with no arguments."))
case 1:return function(e,f,g){return function(){return f(this)[e](g(this))}}(c,r,s)
case 2:return function(e,f,g){return function(h){return f(this)[e](g(this),h)}}(c,r,s)
case 3:return function(e,f,g){return function(h,i){return f(this)[e](g(this),h,i)}}(c,r,s)
case 4:return function(e,f,g){return function(h,i,j){return f(this)[e](g(this),h,i,j)}}(c,r,s)
case 5:return function(e,f,g){return function(h,i,j,k){return f(this)[e](g(this),h,i,j,k)}}(c,r,s)
case 6:return function(e,f,g){return function(h,i,j,k,l){return f(this)[e](g(this),h,i,j,k,l)}}(c,r,s)
default:return function(e,f,g){return function(){var q=[g(this)]
Array.prototype.push.apply(q,arguments)
return e.apply(f(this),q)}}(d,r,s)}},
hW(a,b,c){var s,r
if($.fe==null)$.fe=A.fd("interceptor")
if($.ff==null)$.ff=A.fd("receiver")
s=b.length
r=A.hV(s,c,a,b)
return r},
f3(a){return A.hX(a)},
hQ(a,b){return A.bw(v.typeUniverse,A.aO(a.a),b)},
fg(a){return a.a},
hR(a){return a.b},
fd(a){var s,r,q,p=new A.aR("receiver","interceptor"),o=Object.getOwnPropertyNames(p)
o.$flags=1
s=o
for(o=s.length,r=0;r<o;++r){q=s[r]
if(p[q]===a)return q}throw A.a(A.U("Field name "+a+" not found.",null))},
e8(a){return v.getIsolateTag(a)},
kr(a){var s,r,q,p,o,n=$.hk.$1(a),m=$.e5[n]
if(m!=null){Object.defineProperty(a,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
return m.i}s=$.eh[n]
if(s!=null)return s
r=v.interceptorsByTag[n]
if(r==null){q=$.hh.$2(a,n)
if(q!=null){m=$.e5[q]
if(m!=null){Object.defineProperty(a,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
return m.i}s=$.eh[q]
if(s!=null)return s
r=v.interceptorsByTag[q]
n=q}}if(r==null)return null
s=r.prototype
p=n[0]
if(p==="!"){m=A.ei(s)
$.e5[n]=m
Object.defineProperty(a,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
return m.i}if(p==="~"){$.eh[n]=s
return s}if(p==="-"){o=A.ei(s)
Object.defineProperty(Object.getPrototypeOf(a),v.dispatchPropertyName,{value:o,enumerable:false,writable:true,configurable:true})
return o.i}if(p==="+")return A.ho(a,s)
if(p==="*")throw A.a(A.fA(n))
if(v.leafTags[n]===true){o=A.ei(s)
Object.defineProperty(Object.getPrototypeOf(a),v.dispatchPropertyName,{value:o,enumerable:false,writable:true,configurable:true})
return o.i}else return A.ho(a,s)},
ho(a,b){var s=Object.getPrototypeOf(a)
Object.defineProperty(s,v.dispatchPropertyName,{value:J.f8(b,s,null,null),enumerable:false,writable:true,configurable:true})
return b},
ei(a){return J.f8(a,!1,null,!!a.$iE)},
kt(a,b,c){var s=b.prototype
if(v.leafTags[a]===true)return A.ei(s)
else return J.f8(s,c,null,null)},
km(){if(!0===$.f6)return
$.f6=!0
A.kn()},
kn(){var s,r,q,p,o,n,m,l
$.e5=Object.create(null)
$.eh=Object.create(null)
A.kl()
s=v.interceptorsByTag
r=Object.getOwnPropertyNames(s)
if(typeof window!="undefined"){window
q=function(){}
for(p=0;p<r.length;++p){o=r[p]
n=$.hp.$1(o)
if(n!=null){m=A.kt(o,s[o],n)
if(m!=null){Object.defineProperty(n,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
q.prototype=n}}}}for(p=0;p<r.length;++p){o=r[p]
if(/^[A-Za-z_]/.test(o)){l=s[o]
s["!"+o]=l
s["~"+o]=l
s["-"+o]=l
s["+"+o]=l
s["*"+o]=l}}},
kl(){var s,r,q,p,o,n,m=B.v()
m=A.aL(B.w,A.aL(B.x,A.aL(B.p,A.aL(B.p,A.aL(B.y,A.aL(B.z,A.aL(B.A(B.o),m)))))))
if(typeof dartNativeDispatchHooksTransformer!="undefined"){s=dartNativeDispatchHooksTransformer
if(typeof s=="function")s=[s]
if(Array.isArray(s))for(r=0;r<s.length;++r){q=s[r]
if(typeof q=="function")m=q(m)||m}}p=m.getTag
o=m.getUnknownTag
n=m.prototypeForTag
$.hk=new A.ea(p)
$.hh=new A.eb(o)
$.hp=new A.ec(n)},
aL(a,b){return a(b)||b},
ka(a,b){var s=b.length,r=v.rttc[""+s+";"+a]
if(r==null)return null
if(s===0)return r
if(s===r.length)return r.apply(null,b)
return r(b)},
fm(a,b,c,d,e,f){var s=b?"m":"",r=c?"":"i",q=d?"u":"",p=e?"s":"",o=function(g,h){try{return new RegExp(g,h)}catch(n){return n}}(a,s+r+q+p+f)
if(o instanceof RegExp)return o
throw A.a(A.z("Illegal RegExp pattern ("+String(o)+")",a,null))},
kz(a,b,c){var s=a.indexOf(b,c)
return s>=0},
kv(a){if(/[[\]{}()*+?.\\^$|]/.test(a))return a.replace(/[[\]{}()*+?.\\^$|]/g,"\\$&")
return a},
hf(a){return a},
kA(a,b,c,d){var s,r,q,p=new A.d4(b,a,0),o=t.F,n=0,m=""
while(p.m()){s=p.d
if(s==null)s=o.a(s)
r=s.b
q=r.index
m=m+A.i(A.hf(B.a.i(a,n,q)))+A.i(c.$1(s))
n=q+r[0].length}p=m+A.i(A.hf(B.a.K(a,n)))
return p.charCodeAt(0)==0?p:p},
cp:function cp(a,b){this.a=a
this.b=b},
aS:function aS(){},
aU:function aU(a,b,c){this.a=a
this.b=b
this.$ti=c},
cl:function cl(a,b,c){var _=this
_.a=a
_.b=b
_.c=0
_.d=null
_.$ti=c},
aT:function aT(){},
aV:function aV(a,b,c){this.a=a
this.b=b
this.$ti=c},
be:function be(){},
cX:function cX(a,b,c,d,e,f){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f},
bb:function bb(){},
bS:function bS(a,b,c){this.a=a
this.b=b
this.c=c},
c9:function c9(a){this.a=a},
cT:function cT(a){this.a=a},
aW:function aW(a,b){this.a=a
this.b=b},
br:function br(a){this.a=a
this.b=null},
af:function af(){},
cz:function cz(){},
cA:function cA(){},
cW:function cW(){},
cV:function cV(){},
aR:function aR(a,b){this.a=a
this.b=b},
c7:function c7(a){this.a=a},
ah:function ah(a){var _=this
_.a=0
_.f=_.e=_.d=_.c=_.b=null
_.r=0
_.$ti=a},
cO:function cO(a,b){this.a=a
this.b=b
this.c=null},
ai:function ai(a,b){this.a=a
this.$ti=b},
bU:function bU(a,b,c){var _=this
_.a=a
_.b=b
_.c=c
_.d=null},
b4:function b4(a,b){this.a=a
this.$ti=b},
b3:function b3(a,b,c){var _=this
_.a=a
_.b=b
_.c=c
_.d=null},
ea:function ea(a){this.a=a},
eb:function eb(a){this.a=a},
ec:function ec(a){this.a=a},
bq:function bq(){},
co:function co(){},
cK:function cK(a,b){var _=this
_.a=a
_.b=b
_.e=_.d=_.c=null},
cn:function cn(a){this.b=a},
d4:function d4(a,b,c){var _=this
_.a=a
_.b=b
_.c=c
_.d=null},
js(a){return a},
ie(a){return new Int8Array(a)},
ig(a){return new Uint8Array(a)},
a_(a,b,c){if(a>>>0!==a||a>=c)throw A.a(A.f4(b,a))},
jn(a,b,c){var s
if(!(a>>>0!==a))s=b>>>0!==b||a>b||b>c
else s=!0
if(s)throw A.a(A.kb(a,b,c))
return b},
aw:function aw(){},
b8:function b8(){},
bV:function bV(){},
ax:function ax(){},
b6:function b6(){},
b7:function b7(){},
bW:function bW(){},
bX:function bX(){},
bY:function bY(){},
bZ:function bZ(){},
c_:function c_(){},
c0:function c0(){},
c1:function c1(){},
b9:function b9(){},
ba:function ba(){},
bm:function bm(){},
bn:function bn(){},
bo:function bo(){},
bp:function bp(){},
eA(a,b){var s=b.c
return s==null?b.c=A.bu(a,"S",[b.x]):s},
fv(a){var s=a.w
if(s===6||s===7)return A.fv(a.x)
return s===11||s===12},
il(a){return a.as},
bE(a){return A.dJ(v.typeUniverse,a,!1)},
an(a1,a2,a3,a4){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0=a2.w
switch(a0){case 5:case 1:case 2:case 3:case 4:return a2
case 6:s=a2.x
r=A.an(a1,s,a3,a4)
if(r===s)return a2
return A.fK(a1,r,!0)
case 7:s=a2.x
r=A.an(a1,s,a3,a4)
if(r===s)return a2
return A.fJ(a1,r,!0)
case 8:q=a2.y
p=A.aJ(a1,q,a3,a4)
if(p===q)return a2
return A.bu(a1,a2.x,p)
case 9:o=a2.x
n=A.an(a1,o,a3,a4)
m=a2.y
l=A.aJ(a1,m,a3,a4)
if(n===o&&l===m)return a2
return A.eF(a1,n,l)
case 10:k=a2.x
j=a2.y
i=A.aJ(a1,j,a3,a4)
if(i===j)return a2
return A.fL(a1,k,i)
case 11:h=a2.x
g=A.an(a1,h,a3,a4)
f=a2.y
e=A.k1(a1,f,a3,a4)
if(g===h&&e===f)return a2
return A.fI(a1,g,e)
case 12:d=a2.y
a4+=d.length
c=A.aJ(a1,d,a3,a4)
o=a2.x
n=A.an(a1,o,a3,a4)
if(c===d&&n===o)return a2
return A.eG(a1,n,c,!0)
case 13:b=a2.x
if(b<a4)return a2
a=a3[b-a4]
if(a==null)return a2
return a
default:throw A.a(A.bH("Attempted to substitute unexpected RTI kind "+a0))}},
aJ(a,b,c,d){var s,r,q,p,o=b.length,n=A.dR(o)
for(s=!1,r=0;r<o;++r){q=b[r]
p=A.an(a,q,c,d)
if(p!==q)s=!0
n[r]=p}return s?n:b},
k2(a,b,c,d){var s,r,q,p,o,n,m=b.length,l=A.dR(m)
for(s=!1,r=0;r<m;r+=3){q=b[r]
p=b[r+1]
o=b[r+2]
n=A.an(a,o,c,d)
if(n!==o)s=!0
l.splice(r,3,q,p,n)}return s?l:b},
k1(a,b,c,d){var s,r=b.a,q=A.aJ(a,r,c,d),p=b.b,o=A.aJ(a,p,c,d),n=b.c,m=A.k2(a,n,c,d)
if(q===r&&o===p&&m===n)return b
s=new A.ci()
s.a=q
s.b=o
s.c=m
return s},
l(a,b){a[v.arrayRti]=b
return a},
hj(a){var s=a.$S
if(s!=null){if(typeof s=="number")return A.kh(s)
return a.$S()}return null},
ko(a,b){var s
if(A.fv(b))if(a instanceof A.af){s=A.hj(a)
if(s!=null)return s}return A.aO(a)},
aO(a){if(a instanceof A.k)return A.a0(a)
if(Array.isArray(a))return A.Z(a)
return A.eU(J.aq(a))},
Z(a){var s=a[v.arrayRti],r=t.b
if(s==null)return r
if(s.constructor!==r.constructor)return r
return s},
a0(a){var s=a.$ti
return s!=null?s:A.eU(a)},
eU(a){var s=a.constructor,r=s.$ccache
if(r!=null)return r
return A.jB(a,s)},
jB(a,b){var s=a instanceof A.af?Object.getPrototypeOf(Object.getPrototypeOf(a)).constructor:b,r=A.iS(v.typeUniverse,s.name)
b.$ccache=r
return r},
kh(a){var s,r=v.types,q=r[a]
if(typeof q=="string"){s=A.dJ(v.typeUniverse,q,!1)
r[a]=s
return s}return q},
kg(a){return A.ap(A.a0(a))},
f_(a){var s
if(a instanceof A.bq)return A.kc(a.$r,a.aI())
s=a instanceof A.af?A.hj(a):null
if(s!=null)return s
if(t.q.b(a))return J.hO(a).a
if(Array.isArray(a))return A.Z(a)
return A.aO(a)},
ap(a){var s=a.r
return s==null?a.r=new A.dI(a):s},
kc(a,b){var s,r,q=b,p=q.length
if(p===0)return t.d
s=A.bw(v.typeUniverse,A.f_(q[0]),"@<0>")
for(r=1;r<p;++r)s=A.fN(v.typeUniverse,s,A.f_(q[r]))
return A.bw(v.typeUniverse,s,a)},
P(a){return A.ap(A.dJ(v.typeUniverse,a,!1))},
jA(a){var s=this
s.b=A.k_(s)
return s.b(a)},
k_(a){var s,r,q,p
if(a===t.K)return A.jL
if(A.ar(a))return A.jP
s=a.w
if(s===6)return A.jw
if(s===1)return A.h6
if(s===7)return A.jG
r=A.jZ(a)
if(r!=null)return r
if(s===8){q=a.x
if(a.y.every(A.ar)){a.f="$i"+q
if(q==="f")return A.jJ
if(a===t.m)return A.jI
return A.jO}}else if(s===10){p=A.ka(a.x,a.y)
return p==null?A.h6:p}return A.ju},
jZ(a){if(a.w===8){if(a===t.S)return A.h4
if(a===t.i||a===t.H)return A.jK
if(a===t.N)return A.jN
if(a===t.y)return A.eV}return null},
jz(a){var s=this,r=A.jt
if(A.ar(s))r=A.jj
else if(s===t.K)r=A.ji
else if(A.aP(s)){r=A.jv
if(s===t.w)r=A.eO
else if(s===t.u)r=A.fZ
else if(s===t.e)r=A.jd
else if(s===t.x)r=A.jh
else if(s===t.I)r=A.jf
else if(s===t.B)r=A.fY}else if(s===t.S)r=A.eN
else if(s===t.N)r=A.eP
else if(s===t.y)r=A.jc
else if(s===t.H)r=A.jg
else if(s===t.i)r=A.je
else if(s===t.m)r=A.fX
s.a=r
return s.a(a)},
ju(a){var s=this
if(a==null)return A.aP(s)
return A.kq(v.typeUniverse,A.ko(a,s),s)},
jw(a){if(a==null)return!0
return this.x.b(a)},
jO(a){var s,r=this
if(a==null)return A.aP(r)
s=r.f
if(a instanceof A.k)return!!a[s]
return!!J.aq(a)[s]},
jJ(a){var s,r=this
if(a==null)return A.aP(r)
if(typeof a!="object")return!1
if(Array.isArray(a))return!0
s=r.f
if(a instanceof A.k)return!!a[s]
return!!J.aq(a)[s]},
jI(a){var s=this
if(a==null)return!1
if(typeof a=="object"){if(a instanceof A.k)return!!a[s.f]
return!0}if(typeof a=="function")return!0
return!1},
h5(a){if(typeof a=="object"){if(a instanceof A.k)return t.m.b(a)
return!0}if(typeof a=="function")return!0
return!1},
jt(a){var s=this
if(a==null){if(A.aP(s))return a}else if(s.b(a))return a
throw A.w(A.h1(a,s),new Error())},
jv(a){var s=this
if(a==null||s.b(a))return a
throw A.w(A.h1(a,s),new Error())},
h1(a,b){return new A.bs("TypeError: "+A.fE(a,A.G(b,null)))},
fE(a,b){return A.cD(a)+": type '"+A.G(A.f_(a),null)+"' is not a subtype of type '"+b+"'"},
H(a,b){return new A.bs("TypeError: "+A.fE(a,b))},
jG(a){var s=this
return s.x.b(a)||A.eA(v.typeUniverse,s).b(a)},
jL(a){return a!=null},
ji(a){if(a!=null)return a
throw A.w(A.H(a,"Object"),new Error())},
jP(a){return!0},
jj(a){return a},
h6(a){return!1},
eV(a){return!0===a||!1===a},
jc(a){if(!0===a)return!0
if(!1===a)return!1
throw A.w(A.H(a,"bool"),new Error())},
jd(a){if(!0===a)return!0
if(!1===a)return!1
if(a==null)return a
throw A.w(A.H(a,"bool?"),new Error())},
je(a){if(typeof a=="number")return a
throw A.w(A.H(a,"double"),new Error())},
jf(a){if(typeof a=="number")return a
if(a==null)return a
throw A.w(A.H(a,"double?"),new Error())},
h4(a){return typeof a=="number"&&Math.floor(a)===a},
eN(a){if(typeof a=="number"&&Math.floor(a)===a)return a
throw A.w(A.H(a,"int"),new Error())},
eO(a){if(typeof a=="number"&&Math.floor(a)===a)return a
if(a==null)return a
throw A.w(A.H(a,"int?"),new Error())},
jK(a){return typeof a=="number"},
jg(a){if(typeof a=="number")return a
throw A.w(A.H(a,"num"),new Error())},
jh(a){if(typeof a=="number")return a
if(a==null)return a
throw A.w(A.H(a,"num?"),new Error())},
jN(a){return typeof a=="string"},
eP(a){if(typeof a=="string")return a
throw A.w(A.H(a,"String"),new Error())},
fZ(a){if(typeof a=="string")return a
if(a==null)return a
throw A.w(A.H(a,"String?"),new Error())},
fX(a){if(A.h5(a))return a
throw A.w(A.H(a,"JSObject"),new Error())},
fY(a){if(a==null)return a
if(A.h5(a))return a
throw A.w(A.H(a,"JSObject?"),new Error())},
ha(a,b){var s,r,q
for(s="",r="",q=0;q<a.length;++q,r=", ")s+=r+A.G(a[q],b)
return s},
jU(a,b){var s,r,q,p,o,n,m=a.x,l=a.y
if(""===m)return"("+A.ha(l,b)+")"
s=l.length
r=m.split(",")
q=r.length-s
for(p="(",o="",n=0;n<s;++n,o=", "){p+=o
if(q===0)p+="{"
p+=A.G(l[n],b)
if(q>=0)p+=" "+r[q];++q}return p+"})"},
h2(a1,a2,a3){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a=", ",a0=null
if(a3!=null){s=a3.length
if(a2==null)a2=A.l([],t.s)
else a0=a2.length
r=a2.length
for(q=s;q>0;--q)a2.push("T"+(r+q))
for(p=t.X,o="<",n="",q=0;q<s;++q,n=a){o=o+n+a2[a2.length-1-q]
m=a3[q]
l=m.w
if(!(l===2||l===3||l===4||l===5||m===p))o+=" extends "+A.G(m,a2)}o+=">"}else o=""
p=a1.x
k=a1.y
j=k.a
i=j.length
h=k.b
g=h.length
f=k.c
e=f.length
d=A.G(p,a2)
for(c="",b="",q=0;q<i;++q,b=a)c+=b+A.G(j[q],a2)
if(g>0){c+=b+"["
for(b="",q=0;q<g;++q,b=a)c+=b+A.G(h[q],a2)
c+="]"}if(e>0){c+=b+"{"
for(b="",q=0;q<e;q+=3,b=a){c+=b
if(f[q+1])c+="required "
c+=A.G(f[q+2],a2)+" "+f[q]}c+="}"}if(a0!=null){a2.toString
a2.length=a0}return o+"("+c+") => "+d},
G(a,b){var s,r,q,p,o,n,m=a.w
if(m===5)return"erased"
if(m===2)return"dynamic"
if(m===3)return"void"
if(m===1)return"Never"
if(m===4)return"any"
if(m===6){s=a.x
r=A.G(s,b)
q=s.w
return(q===11||q===12?"("+r+")":r)+"?"}if(m===7)return"FutureOr<"+A.G(a.x,b)+">"
if(m===8){p=A.k3(a.x)
o=a.y
return o.length>0?p+("<"+A.ha(o,b)+">"):p}if(m===10)return A.jU(a,b)
if(m===11)return A.h2(a,b,null)
if(m===12)return A.h2(a.x,b,a.y)
if(m===13){n=a.x
return b[b.length-1-n]}return"?"},
k3(a){var s=A.hq(a)
if(s!=null)return s
return"minified:"+a},
iT(a,b){var s=a.tR[b]
while(typeof s=="string")s=a.tR[s]
return s},
iS(a,b){var s,r,q,p,o,n=a.eT,m=n[b]
if(m==null)return A.dJ(a,b,!1)
else if(typeof m=="number"){s=m
r=A.bv(a,5,"#")
q=A.dR(s)
for(p=0;p<s;++p)q[p]=r
o=A.bu(a,b,q)
n[b]=o
return o}else return m},
iR(a,b){return A.fV(a.tR,b)},
iQ(a,b){return A.fV(a.eT,b)},
dJ(a,b,c){var s,r=a.eC,q=r.get(b)
if(q!=null)return q
s=A.fM(a,null,b,!1)
r.set(b,s)
return s},
bw(a,b,c){var s,r,q=b.z
if(q==null)q=b.z=new Map()
s=q.get(c)
if(s!=null)return s
r=A.fM(a,b,c,!0)
q.set(c,r)
return r},
fN(a,b,c){var s,r,q,p=b.Q
if(p==null)p=b.Q=new Map()
s=c.as
r=p.get(s)
if(r!=null)return r
q=A.eF(a,b,c.w===9?c.y:[c])
p.set(s,q)
return q},
fM(a,b,c,d){return A.iI(A.iC(a,b,c,d))},
ab(a,b){b.a=A.jz
b.b=A.jA
return b},
bv(a,b,c){var s,r,q=a.eC.get(c)
if(q!=null)return q
s=new A.M(null,null)
s.w=b
s.as=c
r=A.ab(a,s)
a.eC.set(c,r)
return r},
fK(a,b,c){var s,r=b.as+"?",q=a.eC.get(r)
if(q!=null)return q
s=A.iO(a,b,r,c)
a.eC.set(r,s)
return s},
iO(a,b,c,d){var s,r,q
if(d){s=b.w
r=!0
if(!A.ar(b))if(!(b===t.P||b===t.T))if(s!==6)r=s===7&&A.aP(b.x)
if(r)return b
else if(s===1)return t.P}q=new A.M(null,null)
q.w=6
q.x=b
q.as=c
return A.ab(a,q)},
fJ(a,b,c){var s,r=b.as+"/",q=a.eC.get(r)
if(q!=null)return q
s=A.iM(a,b,r,c)
a.eC.set(r,s)
return s},
iM(a,b,c,d){var s,r
if(d){s=b.w
if(A.ar(b)||b===t.K)return b
else if(s===1)return A.bu(a,"S",[b])
else if(b===t.P||b===t.T)return t.Y}r=new A.M(null,null)
r.w=7
r.x=b
r.as=c
return A.ab(a,r)},
iP(a,b){var s,r,q=""+b+"^",p=a.eC.get(q)
if(p!=null)return p
s=new A.M(null,null)
s.w=13
s.x=b
s.as=q
r=A.ab(a,s)
a.eC.set(q,r)
return r},
bt(a){var s,r,q,p=a.length
for(s="",r="",q=0;q<p;++q,r=",")s+=r+a[q].as
return s},
iL(a){var s,r,q,p,o,n=a.length
for(s="",r="",q=0;q<n;q+=3,r=","){p=a[q]
o=a[q+1]?"!":":"
s+=r+p+o+a[q+2].as}return s},
bu(a,b,c){var s,r,q,p=b
if(c.length>0)p+="<"+A.bt(c)+">"
s=a.eC.get(p)
if(s!=null)return s
r=new A.M(null,null)
r.w=8
r.x=b
r.y=c
if(c.length>0)r.c=c[0]
r.as=p
q=A.ab(a,r)
a.eC.set(p,q)
return q},
eF(a,b,c){var s,r,q,p,o,n
if(b.w===9){s=b.x
r=b.y.concat(c)}else{r=c
s=b}q=s.as+(";<"+A.bt(r)+">")
p=a.eC.get(q)
if(p!=null)return p
o=new A.M(null,null)
o.w=9
o.x=s
o.y=r
o.as=q
n=A.ab(a,o)
a.eC.set(q,n)
return n},
fL(a,b,c){var s,r,q="+"+(b+"("+A.bt(c)+")"),p=a.eC.get(q)
if(p!=null)return p
s=new A.M(null,null)
s.w=10
s.x=b
s.y=c
s.as=q
r=A.ab(a,s)
a.eC.set(q,r)
return r},
fI(a,b,c){var s,r,q,p,o,n=b.as,m=c.a,l=m.length,k=c.b,j=k.length,i=c.c,h=i.length,g="("+A.bt(m)
if(j>0){s=l>0?",":""
g+=s+"["+A.bt(k)+"]"}if(h>0){s=l>0?",":""
g+=s+"{"+A.iL(i)+"}"}r=n+(g+")")
q=a.eC.get(r)
if(q!=null)return q
p=new A.M(null,null)
p.w=11
p.x=b
p.y=c
p.as=r
o=A.ab(a,p)
a.eC.set(r,o)
return o},
eG(a,b,c,d){var s,r=b.as+("<"+A.bt(c)+">"),q=a.eC.get(r)
if(q!=null)return q
s=A.iN(a,b,c,r,d)
a.eC.set(r,s)
return s},
iN(a,b,c,d,e){var s,r,q,p,o,n,m,l
if(e){s=c.length
r=A.dR(s)
for(q=0,p=0;p<s;++p){o=c[p]
if(o.w===1){r[p]=o;++q}}if(q>0){n=A.an(a,b,r,0)
m=A.aJ(a,c,r,0)
return A.eG(a,n,m,c!==m)}}l=new A.M(null,null)
l.w=12
l.x=b
l.y=c
l.as=d
return A.ab(a,l)},
iC(a,b,c,d){return{u:a,e:b,r:c,s:[],p:0,n:d}},
iI(a){var s,r,q,p,o,n,m,l=a.r,k=a.s
for(s=l.length,r=0;r<s;){q=l.charCodeAt(r)
if(q>=48&&q<=57)r=A.iE(r+1,q,l,k)
else if((((q|32)>>>0)-97&65535)<26||q===95||q===36||q===124)r=A.fG(a,r,l,k,!1)
else if(q===46)r=A.fG(a,r,l,k,!0)
else{++r
switch(q){case 44:break
case 58:k.push(!1)
break
case 33:k.push(!0)
break
case 59:k.push(A.am(a.u,a.e,k.pop()))
break
case 94:k.push(A.iP(a.u,k.pop()))
break
case 35:k.push(A.bv(a.u,5,"#"))
break
case 64:k.push(A.bv(a.u,2,"@"))
break
case 126:k.push(A.bv(a.u,3,"~"))
break
case 60:k.push(a.p)
a.p=k.length
break
case 62:A.iG(a,k)
break
case 38:A.iF(a,k)
break
case 63:p=a.u
k.push(A.fK(p,A.am(p,a.e,k.pop()),a.n))
break
case 47:p=a.u
k.push(A.fJ(p,A.am(p,a.e,k.pop()),a.n))
break
case 40:k.push(-3)
k.push(a.p)
a.p=k.length
break
case 41:A.iD(a,k)
break
case 91:k.push(a.p)
a.p=k.length
break
case 93:o=k.splice(a.p)
A.fH(a.u,a.e,o)
a.p=k.pop()
k.push(o)
k.push(-1)
break
case 123:k.push(a.p)
a.p=k.length
break
case 125:o=k.splice(a.p)
A.iJ(a.u,a.e,o)
a.p=k.pop()
k.push(o)
k.push(-2)
break
case 43:n=l.indexOf("(",r)
k.push(l.substring(r,n))
k.push(-4)
k.push(a.p)
a.p=k.length
r=n+1
break
default:throw"Bad character "+q}}}m=k.pop()
return A.am(a.u,a.e,m)},
iE(a,b,c,d){var s,r,q=b-48
for(s=c.length;a<s;++a){r=c.charCodeAt(a)
if(!(r>=48&&r<=57))break
q=q*10+(r-48)}d.push(q)
return a},
fG(a,b,c,d,e){var s,r,q,p,o,n,m=b+1
for(s=c.length;m<s;++m){r=c.charCodeAt(m)
if(r===46){if(e)break
e=!0}else{if(!((((r|32)>>>0)-97&65535)<26||r===95||r===36||r===124))q=r>=48&&r<=57
else q=!0
if(!q)break}}p=c.substring(b,m)
if(e){s=a.u
o=a.e
if(o.w===9)o=o.x
n=A.iT(s,o.x)[p]
if(n==null)A.as('No "'+p+'" in "'+A.il(o)+'"')
d.push(A.bw(s,o,n))}else d.push(p)
return m},
iG(a,b){var s,r=a.u,q=A.fF(a,b),p=b.pop()
if(typeof p=="string")b.push(A.bu(r,p,q))
else{s=A.am(r,a.e,p)
switch(s.w){case 11:b.push(A.eG(r,s,q,a.n))
break
default:b.push(A.eF(r,s,q))
break}}},
iD(a,b){var s,r,q,p=a.u,o=b.pop(),n=null,m=null
if(typeof o=="number")switch(o){case-1:n=b.pop()
break
case-2:m=b.pop()
break
default:b.push(o)
break}else b.push(o)
s=A.fF(a,b)
o=b.pop()
switch(o){case-3:o=b.pop()
if(n==null)n=p.sEA
if(m==null)m=p.sEA
r=A.am(p,a.e,o)
q=new A.ci()
q.a=s
q.b=n
q.c=m
b.push(A.fI(p,r,q))
return
case-4:b.push(A.fL(p,b.pop(),s))
return
default:throw A.a(A.bH("Unexpected state under `()`: "+A.i(o)))}},
iF(a,b){var s=b.pop()
if(0===s){b.push(A.bv(a.u,1,"0&"))
return}if(1===s){b.push(A.bv(a.u,4,"1&"))
return}throw A.a(A.bH("Unexpected extended operation "+A.i(s)))},
fF(a,b){var s=b.splice(a.p)
A.fH(a.u,a.e,s)
a.p=b.pop()
return s},
am(a,b,c){if(typeof c=="string")return A.bu(a,c,a.sEA)
else if(typeof c=="number"){b.toString
return A.iH(a,b,c)}else return c},
fH(a,b,c){var s,r=c.length
for(s=0;s<r;++s)c[s]=A.am(a,b,c[s])},
iJ(a,b,c){var s,r=c.length
for(s=2;s<r;s+=3)c[s]=A.am(a,b,c[s])},
iH(a,b,c){var s,r,q=b.w
if(q===9){if(c===0)return b.x
s=b.y
r=s.length
if(c<=r)return s[c-1]
c-=r
b=b.x
q=b.w}else if(c===0)return b
if(q!==8)throw A.a(A.bH("Indexed base must be an interface type"))
s=b.y
if(c<=s.length)return s[c-1]
throw A.a(A.bH("Bad index "+c+" for "+b.h(0)))},
kq(a,b,c){var s,r=b.d
if(r==null)r=b.d=new Map()
s=r.get(c)
if(s==null){s=A.v(a,b,null,c,null)
r.set(c,s)}return s},
v(a,b,c,d,e){var s,r,q,p,o,n,m,l,k,j,i
if(b===d)return!0
if(A.ar(d))return!0
s=b.w
if(s===4)return!0
if(A.ar(b))return!1
if(b.w===1)return!0
r=s===13
if(r)if(A.v(a,c[b.x],c,d,e))return!0
q=d.w
p=t.P
if(b===p||b===t.T){if(q===7)return A.v(a,b,c,d.x,e)
return d===p||d===t.T||q===6}if(d===t.K){if(s===7)return A.v(a,b.x,c,d,e)
return s!==6}if(s===7){if(!A.v(a,b.x,c,d,e))return!1
return A.v(a,A.eA(a,b),c,d,e)}if(s===6)return A.v(a,p,c,d,e)&&A.v(a,b.x,c,d,e)
if(q===7){if(A.v(a,b,c,d.x,e))return!0
return A.v(a,b,c,A.eA(a,d),e)}if(q===6)return A.v(a,b,c,p,e)||A.v(a,b,c,d.x,e)
if(r)return!1
p=s!==11
if((!p||s===12)&&d===t.Z)return!0
o=s===10
if(o&&d===t.L)return!0
if(q===12){if(b===t.g)return!0
if(s!==12)return!1
n=b.y
m=d.y
l=n.length
if(l!==m.length)return!1
c=c==null?n:n.concat(c)
e=e==null?m:m.concat(e)
for(k=0;k<l;++k){j=n[k]
i=m[k]
if(!A.v(a,j,c,i,e)||!A.v(a,i,e,j,c))return!1}return A.h3(a,b.x,c,d.x,e)}if(q===11){if(b===t.g)return!0
if(p)return!1
return A.h3(a,b,c,d,e)}if(s===8){if(q!==8)return!1
return A.jH(a,b,c,d,e)}if(o&&q===10)return A.jM(a,b,c,d,e)
return!1},
h3(a3,a4,a5,a6,a7){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2
if(!A.v(a3,a4.x,a5,a6.x,a7))return!1
s=a4.y
r=a6.y
q=s.a
p=r.a
o=q.length
n=p.length
if(o>n)return!1
m=n-o
l=s.b
k=r.b
j=l.length
i=k.length
if(o+j<n+i)return!1
for(h=0;h<o;++h){g=q[h]
if(!A.v(a3,p[h],a7,g,a5))return!1}for(h=0;h<m;++h){g=l[h]
if(!A.v(a3,p[o+h],a7,g,a5))return!1}for(h=0;h<i;++h){g=l[m+h]
if(!A.v(a3,k[h],a7,g,a5))return!1}f=s.c
e=r.c
d=f.length
c=e.length
for(b=0,a=0;a<c;a+=3){a0=e[a]
for(;;){if(b>=d)return!1
a1=f[b]
b+=3
if(a0<a1)return!1
a2=f[b-2]
if(a1<a0){if(a2)return!1
continue}g=e[a+1]
if(a2&&!g)return!1
g=f[b-1]
if(!A.v(a3,e[a+2],a7,g,a5))return!1
break}}while(b<d){if(f[b+1])return!1
b+=3}return!0},
jH(a,b,c,d,e){var s,r,q,p,o,n=b.x,m=d.x
while(n!==m){s=a.tR[n]
if(s==null)return!1
if(typeof s=="string"){n=s
continue}r=s[m]
if(r==null)return!1
q=r.length
p=q>0?new Array(q):v.typeUniverse.sEA
for(o=0;o<q;++o)p[o]=A.bw(a,b,r[o])
return A.fW(a,p,null,c,d.y,e)}return A.fW(a,b.y,null,c,d.y,e)},
fW(a,b,c,d,e,f){var s,r=b.length
for(s=0;s<r;++s)if(!A.v(a,b[s],d,e[s],f))return!1
return!0},
jM(a,b,c,d,e){var s,r=b.y,q=d.y,p=r.length
if(p!==q.length)return!1
if(b.x!==d.x)return!1
for(s=0;s<p;++s)if(!A.v(a,r[s],c,q[s],e))return!1
return!0},
aP(a){var s=a.w,r=!0
if(!(a===t.P||a===t.T))if(!A.ar(a))if(s!==6)r=s===7&&A.aP(a.x)
return r},
ar(a){var s=a.w
return s===2||s===3||s===4||s===5||a===t.X},
fV(a,b){var s,r,q=Object.keys(b),p=q.length
for(s=0;s<p;++s){r=q[s]
a[r]=b[r]}},
dR(a){return a>0?new Array(a):v.typeUniverse.sEA},
M:function M(a,b){var _=this
_.a=a
_.b=b
_.r=_.f=_.d=_.c=null
_.w=0
_.as=_.Q=_.z=_.y=_.x=null},
ci:function ci(){this.c=this.b=this.a=null},
dI:function dI(a){this.a=a},
ch:function ch(){},
bs:function bs(a){this.a=a},
ix(){var s,r,q
if(self.scheduleImmediate!=null)return A.k6()
if(self.MutationObserver!=null&&self.document!=null){s={}
r=self.document.createElement("div")
q=self.document.createElement("span")
s.a=null
new self.MutationObserver(A.aM(new A.d6(s),1)).observe(r,{childList:true})
return new A.d5(s,r,q)}else if(self.setImmediate!=null)return A.k7()
return A.k8()},
iy(a){self.scheduleImmediate(A.aM(new A.d7(a),0))},
iz(a){self.setImmediate(A.aM(new A.d8(a),0))},
iA(a){A.eD(B.E,a)},
eD(a,b){return A.iK(a.a/1000|0,b)},
iK(a,b){var s=new A.dG()
s.bk(a,b)
return s},
eX(a){return new A.cd(new A.x($.q,a.j("x<0>")),a.j("cd<0>"))},
eS(a,b){a.$2(0,null)
b.b=!0
return b.a},
dU(a,b){A.jk(a,b)},
eR(a,b){b.am(a)},
eQ(a,b){b.an(A.at(a),A.aN(a))},
jk(a,b){var s,r,q=new A.dV(b),p=new A.dW(b)
if(a instanceof A.x)a.aP(q,p,t.z)
else{s=t.z
if(a instanceof A.x)a.az(q,p,s)
else{r=new A.x($.q,t.c)
r.a=8
r.c=a
r.aP(q,p,s)}}},
f1(a){var s=function(b,c){return function(d,e){while(true){try{b(d,e)
break}catch(r){e=r
d=c}}}}(a,1)
return $.q.b9(new A.e4(s))},
eo(a){var s
if(t.C.b(a)){s=a.gO()
if(s!=null)return s}return B.h},
jC(a,b){if($.q===B.d)return null
return null},
jD(a,b){if($.q!==B.d)A.jC(a,b)
if(b==null)if(t.C.b(a)){b=a.gO()
if(b==null){A.ft(a,B.h)
b=B.h}}else b=B.h
else if(t.C.b(a))A.ft(a,b)
return new A.J(a,b)},
eE(a,b,c){var s,r,q,p={},o=p.a=a
while(s=o.a,(s&4)!==0){o=o.c
p.a=o}if(o===b){s=A.im()
b.a9(new A.J(new A.I(!0,o,null,"Cannot complete a future with itself"),s))
return}r=b.a&1
s=o.a=s|r
if((s&24)===0){q=b.c
b.a=b.a&1|4
b.c=o
o.aL(q)
return}if(!c)if(b.c==null)o=(s&16)===0||r!==0
else o=!1
else o=!0
if(o){q=b.Y()
b.W(p.a)
A.aD(b,q)
return}b.a^=2
A.cw(null,null,b.b,new A.de(p,b))},
aD(a,b){var s,r,q,p,o,n,m,l,k,j,i,h,g={},f=g.a=a
for(;;){s={}
r=f.a
q=(r&16)===0
p=!q
if(b==null){if(p&&(r&1)===0){f=f.c
A.eY(f.a,f.b)}return}s.a=b
o=b.a
for(f=b;o!=null;f=o,o=n){f.a=null
A.aD(g.a,f)
s.a=o
n=o.a}r=g.a
m=r.c
s.b=p
s.c=m
if(q){l=f.c
l=(l&1)!==0||(l&15)===8}else l=!0
if(l){k=f.b.b
if(p){r=r.b===k
r=!(r||r)}else r=!1
if(r){A.eY(m.a,m.b)
return}j=$.q
if(j!==k)$.q=k
else j=null
f=f.c
if((f&15)===8)new A.di(s,g,p).$0()
else if(q){if((f&1)!==0)new A.dh(s,m).$0()}else if((f&2)!==0)new A.dg(g,s).$0()
if(j!=null)$.q=j
f=s.c
if(f instanceof A.x){r=s.a.$ti
r=r.j("S<2>").b(f)||!r.y[1].b(f)}else r=!1
if(r){i=s.a.b
if((f.a&24)!==0){h=i.c
i.c=null
b=i.Z(h)
i.a=f.a&30|i.a&1
i.c=f.c
g.a=f
continue}else A.eE(f,i,!0)
return}}i=s.a.b
h=i.c
i.c=null
b=i.Z(h)
f=s.b
r=s.c
if(!f){i.a=8
i.c=r}else{i.a=i.a&1|16
i.c=r}g.a=i
f=i}},
jV(a,b){if(t.Q.b(a))return b.b9(a)
if(t.v.b(a))return a
throw A.a(A.fb(a,"onError",u.c))},
jS(){var s,r
for(s=$.aI;s!=null;s=$.aI){$.bD=null
r=s.b
$.aI=r
if(r==null)$.bC=null
s.a.$0()}},
k0(){$.eW=!0
try{A.jS()}finally{$.bD=null
$.eW=!1
if($.aI!=null)$.f9().$1(A.hi())}},
hc(a){var s=new A.ce(a),r=$.bC
if(r==null){$.aI=$.bC=s
if(!$.eW)$.f9().$1(A.hi())}else $.bC=r.b=s},
jY(a){var s,r,q,p=$.aI
if(p==null){A.hc(a)
$.bD=$.bC
return}s=new A.ce(a)
r=$.bD
if(r==null){s.b=p
$.aI=$.bD=s}else{q=r.b
s.b=q
$.bD=r.b=s
if(q==null)$.bC=s}},
kK(a){A.f2(a,"stream",t.K)
return new A.cr()},
fy(a,b){var s=$.q
if(s===B.d)return A.eD(a,b)
return A.eD(a,s.aR(b))},
eY(a,b){A.jY(new A.e2(a,b))},
h9(a,b,c,d){var s,r=$.q
if(r===c)return d.$0()
$.q=c
s=r
try{r=d.$0()
return r}finally{$.q=s}},
jX(a,b,c,d,e){var s,r=$.q
if(r===c)return d.$1(e)
$.q=c
s=r
try{r=d.$1(e)
return r}finally{$.q=s}},
jW(a,b,c,d,e,f){var s,r=$.q
if(r===c)return d.$2(e,f)
$.q=c
s=r
try{r=d.$2(e,f)
return r}finally{$.q=s}},
cw(a,b,c,d){if(B.d!==c){d=c.aR(d)
d=d}A.hc(d)},
d6:function d6(a){this.a=a},
d5:function d5(a,b,c){this.a=a
this.b=b
this.c=c},
d7:function d7(a){this.a=a},
d8:function d8(a){this.a=a},
dG:function dG(){this.b=null},
dH:function dH(a,b){this.a=a
this.b=b},
cd:function cd(a,b){this.a=a
this.b=!1
this.$ti=b},
dV:function dV(a){this.a=a},
dW:function dW(a){this.a=a},
e4:function e4(a){this.a=a},
J:function J(a,b){this.a=a
this.b=b},
cf:function cf(){},
bj:function bj(a,b){this.a=a
this.$ti=b},
aC:function aC(a,b,c,d,e){var _=this
_.a=null
_.b=a
_.c=b
_.d=c
_.e=d
_.$ti=e},
x:function x(a,b){var _=this
_.a=0
_.b=a
_.c=null
_.$ti=b},
db:function db(a,b){this.a=a
this.b=b},
df:function df(a,b){this.a=a
this.b=b},
de:function de(a,b){this.a=a
this.b=b},
dd:function dd(a,b){this.a=a
this.b=b},
dc:function dc(a,b){this.a=a
this.b=b},
di:function di(a,b,c){this.a=a
this.b=b
this.c=c},
dj:function dj(a,b){this.a=a
this.b=b},
dk:function dk(a){this.a=a},
dh:function dh(a,b){this.a=a
this.b=b},
dg:function dg(a,b){this.a=a
this.b=b},
ce:function ce(a){this.a=a
this.b=null},
cr:function cr(){},
dS:function dS(){},
dz:function dz(){},
dA:function dA(a,b){this.a=a
this.b=b},
e2:function e2(a,b){this.a=a
this.b=b},
fo(a,b,c){return A.kd(a,new A.ah(b.j("@<0>").D(c).j("ah<1,2>")))},
ew(a,b){return new A.ah(a.j("@<0>").D(b).j("ah<1,2>"))},
es(a){var s,r=A.Z(a),q=new J.Q(a,a.length,r.j("Q<1>"))
if(q.m()){s=q.d
return s==null?r.c.a(s):s}return null},
ex(a){var s,r
if(A.f7(a))return"{...}"
s=new A.B("")
try{r={}
$.ao.push(a)
s.a+="{"
r.a=!0
a.I(0,new A.cQ(r,s))
s.a+="}"}finally{$.ao.pop()}r=s.a
return r.charCodeAt(0)==0?r:r},
e:function e(){},
W:function W(){},
cQ:function cQ(a,b){this.a=a
this.b=b},
ct:function ct(){},
b5:function b5(){},
aB:function aB(a,b){this.a=a
this.$ti=b},
az:function az(){},
bx:function bx(){},
jT(a,b){var s,r,q,p=null
try{p=JSON.parse(a)}catch(r){s=A.at(r)
q=A.z(String(s),null,null)
throw A.a(q)}q=A.dX(p)
return q},
dX(a){var s
if(a==null)return null
if(typeof a!="object")return a
if(!Array.isArray(a))return new A.cj(a,Object.create(null))
for(s=0;s<a.length;++s)a[s]=A.dX(a[s])
return a},
j9(a,b,c){var s,r,q,p,o=c-b
if(o<=4096)s=$.hI()
else s=new Uint8Array(o)
for(r=J.e6(a),q=0;q<o;++q){p=r.k(a,b+q)
if((p&255)!==p)p=255
s[q]=p}return s},
j8(a,b,c,d){var s=a?$.hH():$.hG()
if(s==null)return null
if(0===c&&d===b.length)return A.fU(s,b)
return A.fU(s,b.subarray(c,d))},
fU(a,b){var s,r
try{s=a.decode(b)
return s}catch(r){}return null},
fc(a,b,c,d,e,f){if(B.b.a6(f,4)!==0)throw A.a(A.z("Invalid base64 padding, padded length must be multiple of four, is "+f,a,c))
if(d+e!==f)throw A.a(A.z("Invalid base64 padding, '=' not at the end",a,b))
if(e>2)throw A.a(A.z("Invalid base64 padding, more than two '=' characters",a,b))},
ja(a){switch(a){case 65:return"Missing extension byte"
case 67:return"Unexpected extension byte"
case 69:return"Invalid UTF-8 byte"
case 71:return"Overlong encoding"
case 73:return"Out of unicode range"
case 75:return"Encoded surrogate"
case 77:return"Unfinished UTF-8 octet sequence"
default:return""}},
cj:function cj(a,b){this.a=a
this.b=b
this.c=null},
ck:function ck(a){this.a=a},
dP:function dP(){},
dO:function dO(){},
cx:function cx(){},
cy:function cy(){},
bK:function bK(){},
bM:function bM(){},
cC:function cC(){},
cF:function cF(){},
cE:function cE(){},
cM:function cM(){},
cN:function cN(a){this.a=a},
d1:function d1(){},
d3:function d3(){},
dQ:function dQ(a){this.b=0
this.c=a},
d2:function d2(a){this.a=a},
dN:function dN(a){this.a=a
this.b=16
this.c=0},
kp(a){var s=A.fr(a,null)
if(s!=null)return s
throw A.a(A.z(a,null,null))},
hZ(a,b){a=A.w(a,new Error())
a.stack=b.h(0)
throw a},
fp(a,b,c,d){var s,r=J.i8(a,d)
if(a!==0&&b!=null)for(s=0;s<a;++s)r[s]=b
return r},
id(a,b,c){var s,r,q=A.l([],c.j("p<0>"))
for(s=a.length,r=0;r<a.length;a.length===s||(0,A.a1)(a),++r)q.push(a[r])
q.$flags=1
return q},
cP(a,b){var s,r=A.l([],b.j("p<0>"))
for(s=J.aQ(a);s.m();)r.push(s.gp())
return r},
fx(a,b,c){var s,r
A.ey(b,"start")
if(c!=null){s=c-b
if(s<0)throw A.a(A.F(c,b,null,"end",null))
if(s===0)return""}r=A.io(a,b,c)
return r},
io(a,b,c){var s=a.length
if(b>=s)return""
return A.ij(a,b,c==null||c>s?s:c)},
fu(a,b){return new A.cK(a,A.fm(a,!1,b,!1,!1,""))},
fw(a,b,c){var s=J.aQ(b)
if(!s.m())return a
if(c.length===0){do a+=A.i(s.gp())
while(s.m())}else{a+=A.i(s.gp())
while(s.m())a=a+c+A.i(s.gp())}return a},
eM(a,b,c,d){var s,r,q,p,o,n="0123456789ABCDEF"
if(c===B.e){s=$.hE()
s=s.b.test(b)}else s=!1
if(s)return b
r=B.D.T(b)
for(s=r.length,q=0,p="";q<s;++q){o=r[q]
if(o<128&&(u.f.charCodeAt(o)&a)!==0)p+=A.a7(o)
else p=d&&o===32?p+"+":p+"%"+n[o>>>4&15]+n[o&15]}return p.charCodeAt(0)==0?p:p},
j0(a){var s,r,q
if(!$.hF())return A.j1(a)
s=new URLSearchParams()
a.I(0,new A.dM(s))
r=s.toString()
q=r.length
if(q>0&&r[q-1]==="=")r=B.a.i(r,0,q-1)
return r.replace(/=&|\*|%7E/g,b=>b==="=&"?"&":b==="*"?"%2A":"~")},
im(){return A.aN(new Error())},
cD(a){if(typeof a=="number"||A.eV(a)||a==null)return J.T(a)
if(typeof a=="string")return JSON.stringify(a)
return A.fs(a)},
i_(a,b){A.f2(a,"error",t.K)
A.f2(b,"stackTrace",t.k)
A.hZ(a,b)},
bH(a){return new A.bG(a)},
U(a,b){return new A.I(!1,null,b,a)},
fb(a,b,c){return new A.I(!0,a,b,c)},
ik(a,b){return new A.bc(null,null,!0,a,b,"Value not in range")},
F(a,b,c,d,e){return new A.bc(b,c,!0,a,d,"Invalid value")},
bd(a,b,c){if(0>a||a>c)throw A.a(A.F(a,0,c,"start",null))
if(b!=null){if(a>b||b>c)throw A.a(A.F(b,a,c,"end",null))
return b}return c},
ey(a,b){if(a<0)throw A.a(A.F(a,0,null,b,null))
return a},
er(a,b,c,d){return new A.bN(b,!0,a,d,"Index out of range")},
bi(a){return new A.bh(a)},
fA(a){return new A.c8(a)},
eB(a){return new A.bg(a)},
ag(a){return new A.bL(a)},
z(a,b,c){return new A.R(a,b,c)},
i6(a,b,c){var s,r
if(A.f7(a)){if(b==="("&&c===")")return"(...)"
return b+"..."+c}s=A.l([],t.s)
$.ao.push(a)
try{A.jQ(a,s)}finally{$.ao.pop()}r=A.fw(b,s,", ")+c
return r.charCodeAt(0)==0?r:r},
et(a,b,c){var s,r
if(A.f7(a))return b+"..."+c
s=new A.B(b)
$.ao.push(a)
try{r=s
r.a=A.fw(r.a,a,", ")}finally{$.ao.pop()}s.a+=c
r=s.a
return r.charCodeAt(0)==0?r:r},
jQ(a,b){var s,r,q,p,o,n,m,l=a.gB(a),k=0,j=0
for(;;){if(!(k<80||j<3))break
if(!l.m())return
s=A.i(l.gp())
b.push(s)
k+=s.length+2;++j}if(!l.m()){if(j<=5)return
r=b.pop()
q=b.pop()}else{p=l.gp();++j
if(!l.m()){if(j<=4){b.push(A.i(p))
return}r=A.i(p)
q=b.pop()
k+=r.length+2}else{o=l.gp();++j
for(;l.m();p=o,o=n){n=l.gp();++j
if(j>100){for(;;){if(!(k>75&&j>3))break
k-=b.pop().length+2;--j}b.push("...")
return}}q=A.i(p)
r=A.i(o)
k+=r.length+q.length+4}}if(j>b.length+2){k+=5
m="..."}else m=null
for(;;){if(!(k>80&&b.length>3))break
k-=b.pop().length+2
if(m==null){k+=5
m="..."}}if(m!=null)b.push(m)
b.push(q)
b.push(r)},
ih(a,b,c,d){var s
if(B.i===c){s=B.b.gn(a)
b=J.a2(b)
return A.eC(A.a9(A.a9($.en(),s),b))}if(B.i===d){s=B.b.gn(a)
b=J.a2(b)
c=J.a2(c)
return A.eC(A.a9(A.a9(A.a9($.en(),s),b),c))}s=B.b.gn(a)
b=J.a2(b)
c=J.a2(c)
d=J.a2(d)
d=A.eC(A.a9(A.a9(A.a9(A.a9($.en(),s),b),c),d))
return d},
al(a4,a5,a6){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3=null
a6=a4.length
s=a5+5
if(a6>=s){r=((a4.charCodeAt(a5+4)^58)*3|a4.charCodeAt(a5)^100|a4.charCodeAt(a5+1)^97|a4.charCodeAt(a5+2)^116|a4.charCodeAt(a5+3)^97)>>>0
if(r===0)return A.fB(a5>0||a6<a6?B.a.i(a4,a5,a6):a4,5,a3).gbb()
else if(r===32)return A.fB(B.a.i(a4,s,a6),0,a3).gbb()}q=A.fp(8,0,!1,t.S)
q[0]=0
p=a5-1
q[1]=p
q[2]=p
q[7]=p
q[3]=a5
q[4]=a5
q[5]=a6
q[6]=a6
if(A.hb(a4,a5,a6,0,q)>=14)q[7]=a6
o=q[1]
if(o>=a5)if(A.hb(a4,a5,o,20,q)===20)q[7]=o
n=q[2]+1
m=q[3]
l=q[4]
k=q[5]
j=q[6]
if(j<k)k=j
if(l<n)l=k
else if(l<=o)l=o+1
if(m<n)m=l
i=q[7]<a5
h=a3
if(i){i=!1
if(!(n>o+3)){p=m>a5
g=0
if(!(p&&m+1===l)){if(!B.a.u(a4,"\\",l))if(n>a5)f=B.a.u(a4,"\\",n-1)||B.a.u(a4,"\\",n-2)
else f=!1
else f=!0
if(!f){if(!(k<a6&&k===l+2&&B.a.u(a4,"..",l)))f=k>l+2&&B.a.u(a4,"/..",k-3)
else f=!0
if(!f)if(o===a5+4){if(B.a.u(a4,"file",a5)){if(n<=a5){if(!B.a.u(a4,"/",l)){e="file:///"
r=3}else{e="file://"
r=2}a4=e+B.a.i(a4,l,a6)
o-=a5
s=r-a5
k+=s
j+=s
a6=a4.length
a5=g
n=7
m=7
l=7}else if(l===k){s=a5===0
s
if(s){a4=B.a.N(a4,l,k,"/");++k;++j;++a6}else{a4=B.a.i(a4,a5,l)+"/"+B.a.i(a4,k,a6)
o-=a5
n-=a5
m-=a5
l-=a5
s=1-a5
k+=s
j+=s
a6=a4.length
a5=g}}h="file"}else if(B.a.u(a4,"http",a5)){if(p&&m+3===l&&B.a.u(a4,"80",m+1)){s=a5===0
s
if(s){a4=B.a.N(a4,m,l,"")
l-=3
k-=3
j-=3
a6-=3}else{a4=B.a.i(a4,a5,m)+B.a.i(a4,l,a6)
o-=a5
n-=a5
m-=a5
s=3+a5
l-=s
k-=s
j-=s
a6=a4.length
a5=g}}h="http"}}else if(o===s&&B.a.u(a4,"https",a5)){if(p&&m+4===l&&B.a.u(a4,"443",m+1)){s=a5===0
s
if(s){a4=B.a.N(a4,m,l,"")
l-=4
k-=4
j-=4
a6-=3}else{a4=B.a.i(a4,a5,m)+B.a.i(a4,l,a6)
o-=a5
n-=a5
m-=a5
s=4+a5
l-=s
k-=s
j-=s
a6=a4.length
a5=g}}h="https"}i=!f}}}}if(i){if(a5>0||a6<a4.length){a4=B.a.i(a4,a5,a6)
o-=a5
n-=a5
m-=a5
l-=a5
k-=a5
j-=a5}return new A.cq(a4,o,n,m,l,k,j,h)}if(h==null)if(o>a5)h=A.j2(a4,a5,o)
else{if(o===a5)A.aG(a4,a5,"Invalid empty scheme")
h=""}d=a3
if(n>a5){c=o+3
b=c<n?A.j3(a4,c,n-1):""
a=A.iY(a4,n,m,!1)
s=m+1
if(s<l){a0=A.fr(B.a.i(a4,s,l),a3)
d=A.j_(a0==null?A.as(A.z("Invalid port",a4,s)):a0,h)}}else{a=a3
b=""}a1=A.iZ(a4,l,k,a3,h,a!=null)
a2=k<j?A.eJ(a4,k+1,j,a3):a3
return A.eH(h,b,a,d,a1,a2,j<a6?A.iX(a4,j+1,a6):a3)},
iw(a){var s,r,q=0,p=null
try{s=A.al(a,q,p)
return s}catch(r){if(A.at(r) instanceof A.R)return null
else throw r}},
fD(a){var s=t.N
return B.c.bT(A.l(a.split("&"),t.s),A.ew(s,s),new A.d0(B.e))},
cc(a,b,c){throw A.a(A.z("Illegal IPv4 address, "+a,b,c))},
it(a,b,c,d,e){var s,r,q,p,o,n,m,l,k="invalid character"
for(s=d.$flags|0,r=b,q=r,p=0,o=0;;){n=q>=c?0:a.charCodeAt(q)
m=n^48
if(m<=9){if(o!==0||q===r){o=o*10+m
if(o<=255){++q
continue}A.cc("each part must be in the range 0..255",a,r)}A.cc("parts must not have leading zeros",a,r)}if(q===r){if(q===c)break
A.cc(k,a,q)}l=p+1
s&2&&A.O(d)
d[e+p]=o
if(n===46){if(l<4){++q
p=l
r=q
o=0
continue}break}if(q===c){if(l===4)return
break}A.cc(k,a,q)
p=l}A.cc("IPv4 address should contain exactly 4 parts",a,q)},
iu(a,b,c){var s
if(b===c)throw A.a(A.z("Empty IP address",a,b))
if(a.charCodeAt(b)===118){s=A.iv(a,b,c)
if(s!=null)throw A.a(s)
return!1}A.fC(a,b,c)
return!0},
iv(a,b,c){var s,r,q,p,o="Missing hex-digit in IPvFuture address";++b
for(s=b;;s=r){if(s<c){r=s+1
q=a.charCodeAt(s)
if((q^48)<=9)continue
p=q|32
if(p>=97&&p<=102)continue
if(q===46){if(r-1===b)return new A.R(o,a,r)
s=r
break}return new A.R("Unexpected character",a,r-1)}if(s-1===b)return new A.R(o,a,s)
return new A.R("Missing '.' in IPvFuture address",a,s)}if(s===c)return new A.R("Missing address in IPvFuture address, host, cursor",null,null)
for(;;){if((u.f.charCodeAt(a.charCodeAt(s))&16)!==0){++s
if(s<c)continue
return null}return new A.R("Invalid IPvFuture address character",a,s)}},
fC(a1,a2,a3){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a="an address must contain at most 8 parts",a0=new A.d_(a1)
if(a3-a2<2)a0.$2("address is too short",null)
s=new Uint8Array(16)
r=-1
q=0
if(a1.charCodeAt(a2)===58)if(a1.charCodeAt(a2+1)===58){p=a2+2
o=p
r=0
q=1}else{a0.$2("invalid start colon",a2)
p=a2
o=p}else{p=a2
o=p}for(n=0,m=!0;;){l=p>=a3?0:a1.charCodeAt(p)
A:{k=l^48
j=!1
if(k<=9)i=k
else{h=l|32
if(h>=97&&h<=102)i=h-87
else break A
m=j}if(p<o+4){n=n*16+i;++p
continue}a0.$2("an IPv6 part can contain a maximum of 4 hex digits",o)}if(p>o){if(l===46){if(m){if(q<=6){A.it(a1,o,a3,s,q*2)
q+=2
p=a3
break}a0.$2(a,o)}break}g=q*2
s[g]=B.b.ai(n,8)
s[g+1]=n&255;++q
if(l===58){if(q<8){++p
o=p
n=0
m=!0
continue}a0.$2(a,p)}break}if(l===58){if(r<0){f=q+1;++p
r=q
q=f
o=p
continue}a0.$2("only one wildcard `::` is allowed",p)}if(r!==q-1)a0.$2("missing part",p)
break}if(p<a3)a0.$2("invalid character",p)
if(q<8){if(r<0)a0.$2("an address without a wildcard must contain exactly 8 parts",a3)
e=r+1
d=q-e
if(d>0){c=e*2
b=16-d*2
B.r.bf(s,b,16,s,c)
B.r.bR(s,c,b,0)}}return s},
eH(a,b,c,d,e,f,g){return new A.by(a,b,c,d,e,f,g)},
fO(a){if(a==="http")return 80
if(a==="https")return 443
return 0},
aG(a,b,c){throw A.a(A.z(c,a,b))},
j_(a,b){if(a!=null&&a===A.fO(b))return null
return a},
iY(a,b,c,d){var s,r,q,p,o,n,m,l
if(b===c)return""
if(a.charCodeAt(b)===91){s=c-1
if(a.charCodeAt(s)!==93)A.aG(a,b,"Missing end `]` to match `[` in host")
r=b+1
q=""
if(a.charCodeAt(r)!==118){p=A.iV(a,r,s)
if(p<s){o=p+1
q=A.fT(a,B.a.u(a,"25",o)?p+3:o,s,"%25")}s=p}n=A.iu(a,r,s)
m=B.a.i(a,r,s)
return"["+(n?m.toLowerCase():m)+q+"]"}for(l=b;l<c;++l)if(a.charCodeAt(l)===58){s=B.a.a4(a,"%",b)
s=s>=b&&s<c?s:c
if(s<c){o=s+1
q=A.fT(a,B.a.u(a,"25",o)?s+3:o,c,"%25")}else q=""
A.fC(a,b,s)
return"["+B.a.i(a,b,s)+q+"]"}return A.j5(a,b,c)},
iV(a,b,c){var s=B.a.a4(a,"%",b)
return s>=b&&s<c?s:c},
fT(a,b,c,d){var s,r,q,p,o,n,m,l,k,j,i=d!==""?new A.B(d):null
for(s=b,r=s,q=!0;s<c;){p=a.charCodeAt(s)
if(p===37){o=A.eK(a,s,!0)
n=o==null
if(n&&q){s+=3
continue}if(i==null)i=new A.B("")
m=i.a+=B.a.i(a,r,s)
if(n)o=B.a.i(a,s,s+3)
else if(o==="%")A.aG(a,s,"ZoneID should not contain % anymore")
i.a=m+o
s+=3
r=s
q=!0}else if(p<127&&(u.f.charCodeAt(p)&1)!==0){if(q&&65<=p&&90>=p){if(i==null)i=new A.B("")
if(r<s){i.a+=B.a.i(a,r,s)
r=s}q=!1}++s}else{l=1
if((p&64512)===55296&&s+1<c){k=a.charCodeAt(s+1)
if((k&64512)===56320){p=65536+((p&1023)<<10)+(k&1023)
l=2}}j=B.a.i(a,r,s)
if(i==null){i=new A.B("")
n=i}else n=i
n.a+=j
m=A.eI(p)
n.a+=m
s+=l
r=s}}if(i==null)return B.a.i(a,b,c)
if(r<c){j=B.a.i(a,r,c)
i.a+=j}n=i.a
return n.charCodeAt(0)==0?n:n},
j5(a,b,c){var s,r,q,p,o,n,m,l,k,j,i,h=u.f
for(s=b,r=s,q=null,p=!0;s<c;){o=a.charCodeAt(s)
if(o===37){n=A.eK(a,s,!0)
m=n==null
if(m&&p){s+=3
continue}if(q==null)q=new A.B("")
l=B.a.i(a,r,s)
if(!p)l=l.toLowerCase()
k=q.a+=l
j=3
if(m)n=B.a.i(a,s,s+3)
else if(n==="%"){n="%25"
j=1}q.a=k+n
s+=j
r=s
p=!0}else if(o<127&&(h.charCodeAt(o)&32)!==0){if(p&&65<=o&&90>=o){if(q==null)q=new A.B("")
if(r<s){q.a+=B.a.i(a,r,s)
r=s}p=!1}++s}else if(o<=93&&(h.charCodeAt(o)&1024)!==0)A.aG(a,s,"Invalid character")
else{j=1
if((o&64512)===55296&&s+1<c){i=a.charCodeAt(s+1)
if((i&64512)===56320){o=65536+((o&1023)<<10)+(i&1023)
j=2}}l=B.a.i(a,r,s)
if(!p)l=l.toLowerCase()
if(q==null){q=new A.B("")
m=q}else m=q
m.a+=l
k=A.eI(o)
m.a+=k
s+=j
r=s}}if(q==null)return B.a.i(a,b,c)
if(r<c){l=B.a.i(a,r,c)
if(!p)l=l.toLowerCase()
q.a+=l}m=q.a
return m.charCodeAt(0)==0?m:m},
j2(a,b,c){var s,r,q
if(b===c)return""
if(!A.fQ(a.charCodeAt(b)))A.aG(a,b,"Scheme not starting with alphabetic character")
for(s=b,r=!1;s<c;++s){q=a.charCodeAt(s)
if(!(q<128&&(u.f.charCodeAt(q)&8)!==0))A.aG(a,s,"Illegal scheme character")
if(65<=q&&q<=90)r=!0}a=B.a.i(a,b,c)
return A.iU(r?a.toLowerCase():a)},
iU(a){if(a==="http")return"http"
if(a==="file")return"file"
if(a==="https")return"https"
if(a==="package")return"package"
return a},
j3(a,b,c){return A.bz(a,b,c,16,!1,!1)},
iZ(a,b,c,d,e,f){var s,r=e==="file",q=r||f
if(a==null)return r?"/":""
else s=A.bz(a,b,c,128,!0,!0)
if(s.length===0){if(r)return"/"}else if(q&&!B.a.A(s,"/"))s="/"+s
return A.j4(s,e,f)},
j4(a,b,c){var s=b.length===0
if(s&&!c&&!B.a.A(a,"/")&&!B.a.A(a,"\\"))return A.j6(a,!s||c)
return A.j7(a)},
eJ(a,b,c,d){if(a!=null){if(d!=null)throw A.a(A.U("Both query and queryParameters specified",null))
return A.bz(a,b,c,256,!0,!1)}if(d==null)return null
return A.j0(d)},
j1(a){var s={},r=new A.B("")
s.a=""
a.I(0,new A.dK(new A.dL(s,r)))
s=r.a
return s.charCodeAt(0)==0?s:s},
iX(a,b,c){return A.bz(a,b,c,256,!0,!1)},
eK(a,b,c){var s,r,q,p,o,n=b+2
if(n>=a.length)return"%"
s=a.charCodeAt(b+1)
r=a.charCodeAt(n)
q=A.e9(s)
p=A.e9(r)
if(q<0||p<0)return"%"
o=q*16+p
if(o<127&&(u.f.charCodeAt(o)&1)!==0)return A.a7(c&&65<=o&&90>=o?(o|32)>>>0:o)
if(s>=97||r>=97)return B.a.i(a,b,b+3).toUpperCase()
return null},
eI(a){var s,r,q,p,o,n="0123456789ABCDEF"
if(a<=127){s=new Uint8Array(3)
s[0]=37
s[1]=n.charCodeAt(a>>>4)
s[2]=n.charCodeAt(a&15)}else{if(a>2047)if(a>65535){r=240
q=4}else{r=224
q=3}else{r=192
q=2}s=new Uint8Array(3*q)
for(p=0;--q,q>=0;r=128){o=B.b.bF(a,6*q)&63|r
s[p]=37
s[p+1]=n.charCodeAt(o>>>4)
s[p+2]=n.charCodeAt(o&15)
p+=3}}return A.fx(s,0,null)},
bz(a,b,c,d,e,f){var s=A.fS(a,b,c,d,e,f)
return s==null?B.a.i(a,b,c):s},
fS(a,b,c,d,e,f){var s,r,q,p,o,n,m,l,k,j=null,i=u.f
for(s=!e,r=b,q=r,p=j;r<c;){o=a.charCodeAt(r)
if(o<127&&(i.charCodeAt(o)&d)!==0)++r
else{n=1
if(o===37){m=A.eK(a,r,!1)
if(m==null){r+=3
continue}if("%"===m)m="%25"
else n=3}else if(o===92&&f)m="/"
else if(s&&o<=93&&(i.charCodeAt(o)&1024)!==0){A.aG(a,r,"Invalid character")
n=j
m=n}else{if((o&64512)===55296){l=r+1
if(l<c){k=a.charCodeAt(l)
if((k&64512)===56320){o=65536+((o&1023)<<10)+(k&1023)
n=2}}}m=A.eI(o)}if(p==null){p=new A.B("")
l=p}else l=p
l.a=(l.a+=B.a.i(a,q,r))+m
r+=n
q=r}}if(p==null)return j
if(q<c){s=B.a.i(a,q,c)
p.a+=s}s=p.a
return s.charCodeAt(0)==0?s:s},
fR(a){if(B.a.A(a,"."))return!0
return B.a.b2(a,"/.")!==-1},
j7(a){var s,r,q,p,o,n
if(!A.fR(a))return a
s=A.l([],t.s)
for(r=a.split("/"),q=r.length,p=!1,o=0;o<q;++o){n=r[o]
if(n===".."){if(s.length!==0){s.pop()
if(s.length===0)s.push("")}p=!0}else{p="."===n
if(!p)s.push(n)}}if(p)s.push("")
return B.c.b6(s,"/")},
j6(a,b){var s,r,q,p,o,n
if(!A.fR(a))return!b?A.fP(a):a
s=A.l([],t.s)
for(r=a.split("/"),q=r.length,p=!1,o=0;o<q;++o){n=r[o]
if(".."===n){if(s.length!==0&&B.c.gb7(s)!=="..")s.pop()
else s.push("..")
p=!0}else{p="."===n
if(!p)s.push(n.length===0&&s.length===0?"./":n)}}if(s.length===0)return"./"
if(p)s.push("")
if(!b)s[0]=A.fP(s[0])
return B.c.b6(s,"/")},
fP(a){var s,r,q=a.length
if(q>=2&&A.fQ(a.charCodeAt(0)))for(s=1;s<q;++s){r=a.charCodeAt(s)
if(r===58)return B.a.i(a,0,s)+"%3A"+B.a.K(a,s+1)
if(r>127||(u.f.charCodeAt(r)&8)===0)break}return a},
iW(a,b){var s,r,q
for(s=0,r=0;r<2;++r){q=a.charCodeAt(b+r)
if(48<=q&&q<=57)s=s*16+q-48
else{q|=32
if(97<=q&&q<=102)s=s*16+q-87
else throw A.a(A.U("Invalid URL encoding",null))}}return s},
eL(a,b,c,d,e){var s,r,q,p,o=b
for(;;){if(!(o<c)){s=!0
break}r=a.charCodeAt(o)
q=!0
if(r<=127)if(r!==37)q=r===43
if(q){s=!1
break}++o}if(s)if(B.e===d)return B.a.i(a,b,c)
else p=new A.bJ(B.a.i(a,b,c))
else{p=A.l([],t.t)
for(q=a.length,o=b;o<c;++o){r=a.charCodeAt(o)
if(r>127)throw A.a(A.U("Illegal percent encoding in URI",null))
if(r===37){if(o+3>q)throw A.a(A.U("Truncated URI",null))
p.push(A.iW(a,o+1))
o+=2}else if(r===43)p.push(32)
else p.push(r)}}return B.an.T(p)},
fQ(a){var s=a|32
return 97<=s&&s<=122},
fB(a,b,c){var s,r,q,p,o,n,m,l,k="Invalid MIME type",j=A.l([b-1],t.t)
for(s=a.length,r=b,q=-1,p=null;r<s;++r){p=a.charCodeAt(r)
if(p===44||p===59)break
if(p===47){if(q<0){q=r
continue}throw A.a(A.z(k,a,r))}}if(q<0&&r>b)throw A.a(A.z(k,a,r))
while(p!==44){j.push(r);++r
for(o=-1;r<s;++r){p=a.charCodeAt(r)
if(p===61){if(o<0)o=r}else if(p===59||p===44)break}if(o>=0)j.push(o)
else{n=B.c.gb7(j)
if(p!==44||r!==n+7||!B.a.u(a,"base64",n+1))throw A.a(A.z("Expecting '='",a,r))
break}}j.push(r)
m=r+1
if((j.length&1)===1)a=B.u.bY(a,m,s)
else{l=A.fS(a,m,s,256,!0,!1)
if(l!=null)a=B.a.N(a,m,s,l)}return new A.cZ(a,j,c)},
hb(a,b,c,d,e){var s,r,q
for(s=b;s<c;++s){r=a.charCodeAt(s)^96
if(r>95)r=31
q='\xe1\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\xe1\xe1\xe1\x01\xe1\xe1\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\xe1\xe3\xe1\xe1\x01\xe1\x01\xe1\xcd\x01\xe1\x01\x01\x01\x01\x01\x01\x01\x01\x0e\x03\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01"\x01\xe1\x01\xe1\xac\xe1\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\xe1\xe1\xe1\x01\xe1\xe1\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\xe1\xea\xe1\xe1\x01\xe1\x01\xe1\xcd\x01\xe1\x01\x01\x01\x01\x01\x01\x01\x01\x01\n\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01"\x01\xe1\x01\xe1\xac\xeb\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\xeb\xeb\xeb\x8b\xeb\xeb\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\xeb\x83\xeb\xeb\x8b\xeb\x8b\xeb\xcd\x8b\xeb\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x92\x83\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\xeb\x8b\xeb\x8b\xeb\xac\xeb\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\xeb\xeb\xeb\v\xeb\xeb\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\xebD\xeb\xeb\v\xeb\v\xeb\xcd\v\xeb\v\v\v\v\v\v\v\v\x12D\v\v\v\v\v\v\v\v\v\v\xeb\v\xeb\v\xeb\xac\xe5\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\xe5\xe5\xe5\x05\xe5D\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe8\x8a\xe5\xe5\x05\xe5\x05\xe5\xcd\x05\xe5\x05\x05\x05\x05\x05\x05\x05\x05\x05\x8a\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05f\x05\xe5\x05\xe5\xac\xe5\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\xe5\xe5\xe5\x05\xe5D\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\x8a\xe5\xe5\x05\xe5\x05\xe5\xcd\x05\xe5\x05\x05\x05\x05\x05\x05\x05\x05\x05\x8a\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05f\x05\xe5\x05\xe5\xac\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7D\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\x8a\xe7\xe7\xe7\xe7\xe7\xe7\xcd\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\x8a\xe7\x07\x07\x07\x07\x07\x07\x07\x07\x07\xe7\xe7\xe7\xe7\xe7\xac\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7D\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\x8a\xe7\xe7\xe7\xe7\xe7\xe7\xcd\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\x8a\x07\x07\x07\x07\x07\x07\x07\x07\x07\x07\xe7\xe7\xe7\xe7\xe7\xac\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\x05\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\xeb\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\xeb\xeb\xeb\v\xeb\xeb\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\xeb\xea\xeb\xeb\v\xeb\v\xeb\xcd\v\xeb\v\v\v\v\v\v\v\v\x10\xea\v\v\v\v\v\v\v\v\v\v\xeb\v\xeb\v\xeb\xac\xeb\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\xeb\xeb\xeb\v\xeb\xeb\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\xeb\xea\xeb\xeb\v\xeb\v\xeb\xcd\v\xeb\v\v\v\v\v\v\v\v\x12\n\v\v\v\v\v\v\v\v\v\v\xeb\v\xeb\v\xeb\xac\xeb\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\xeb\xeb\xeb\v\xeb\xeb\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\xeb\xea\xeb\xeb\v\xeb\v\xeb\xcd\v\xeb\v\v\v\v\v\v\v\v\v\n\v\v\v\v\v\v\v\v\v\v\xeb\v\xeb\v\xeb\xac\xec\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\xec\xec\xec\f\xec\xec\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\xec\xec\xec\xec\f\xec\f\xec\xcd\f\xec\f\f\f\f\f\f\f\f\f\xec\f\f\f\f\f\f\f\f\f\f\xec\f\xec\f\xec\f\xed\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\xed\xed\xed\r\xed\xed\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\xed\xed\xed\xed\r\xed\r\xed\xed\r\xed\r\r\r\r\r\r\r\r\r\xed\r\r\r\r\r\r\r\r\r\r\xed\r\xed\r\xed\r\xe1\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\xe1\xe1\xe1\x01\xe1\xe1\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\xe1\xea\xe1\xe1\x01\xe1\x01\xe1\xcd\x01\xe1\x01\x01\x01\x01\x01\x01\x01\x01\x0f\xea\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01"\x01\xe1\x01\xe1\xac\xe1\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\xe1\xe1\xe1\x01\xe1\xe1\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\xe1\xe9\xe1\xe1\x01\xe1\x01\xe1\xcd\x01\xe1\x01\x01\x01\x01\x01\x01\x01\x01\x01\t\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01"\x01\xe1\x01\xe1\xac\xeb\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\xeb\xeb\xeb\v\xeb\xeb\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\xeb\xea\xeb\xeb\v\xeb\v\xeb\xcd\v\xeb\v\v\v\v\v\v\v\v\x11\xea\v\v\v\v\v\v\v\v\v\v\xeb\v\xeb\v\xeb\xac\xeb\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\xeb\xeb\xeb\v\xeb\xeb\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\xeb\xe9\xeb\xeb\v\xeb\v\xeb\xcd\v\xeb\v\v\v\v\v\v\v\v\v\t\v\v\v\v\v\v\v\v\v\v\xeb\v\xeb\v\xeb\xac\xeb\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\xeb\xeb\xeb\v\xeb\xeb\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\xeb\xea\xeb\xeb\v\xeb\v\xeb\xcd\v\xeb\v\v\v\v\v\v\v\v\x13\xea\v\v\v\v\v\v\v\v\v\v\xeb\v\xeb\v\xeb\xac\xeb\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\xeb\xeb\xeb\v\xeb\xeb\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\xeb\xea\xeb\xeb\v\xeb\v\xeb\xcd\v\xeb\v\v\v\v\v\v\v\v\v\xea\v\v\v\v\v\v\v\v\v\v\xeb\v\xeb\v\xeb\xac\xf5\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\x15\xf5\x15\x15\xf5\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\xf5\xf5\xf5\xf5\xf5\xf5'.charCodeAt(d*96+r)
d=q&31
e[q>>>5]=s}return d},
dM:function dM(a){this.a=a},
au:function au(a){this.a=a},
d9:function d9(){},
m:function m(){},
bG:function bG(a){this.a=a},
X:function X(){},
I:function I(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
bc:function bc(a,b,c,d,e,f){var _=this
_.e=a
_.f=b
_.a=c
_.b=d
_.c=e
_.d=f},
bN:function bN(a,b,c,d,e){var _=this
_.f=a
_.a=b
_.b=c
_.c=d
_.d=e},
bh:function bh(a){this.a=a},
c8:function c8(a){this.a=a},
bg:function bg(a){this.a=a},
bL:function bL(a){this.a=a},
c3:function c3(){},
bf:function bf(){},
da:function da(a){this.a=a},
R:function R(a,b,c){this.a=a
this.b=b
this.c=c},
o:function o(){},
t:function t(){},
k:function k(){},
cs:function cs(){},
B:function B(a){this.a=a},
d0:function d0(a){this.a=a},
d_:function d_(a){this.a=a},
by:function by(a,b,c,d,e,f,g){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f
_.r=g
_.z=_.y=_.w=$},
dL:function dL(a,b){this.a=a
this.b=b},
dK:function dK(a){this.a=a},
cZ:function cZ(a,b,c){this.a=a
this.b=b
this.c=c},
cq:function cq(a,b,c,d,e,f,g,h){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f
_.r=g
_.w=h
_.x=null},
cg:function cg(a,b,c,d,e,f,g){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f
_.r=g
_.z=_.y=_.w=$},
i7(a,b){var s,r,q,p,o
if(b.length===0)return!1
s=b.split(".")
r=v.G
for(q=s.length,p=0;p<q;++p,r=o){o=r[s[p]]
A.fY(o)
if(o==null)return!1}return a instanceof t.g.a(r)},
cS:function cS(a){this.a=a},
D(a){var s
if(typeof a=="function")throw A.a(A.U("Attempting to rewrap a JS function.",null))
s=function(b,c){return function(d){return b(c,d,arguments.length)}}(A.jm,a)
s[$.em()]=a
return s},
jl(a){return a.$0()},
jm(a,b,c){if(c>=1)return a.$1(b)
return a.$0()},
ej(a,b){var s=new A.x($.q,b.j("x<0>")),r=new A.bj(s,b.j("bj<0>"))
a.then(A.aM(new A.ek(r),1),A.aM(new A.el(r),1))
return s},
ek:function ek(a){this.a=a},
el:function el(a){this.a=a},
n:function n(a,b){this.a=a
this.b=b},
i2(a){var s,r,q,p,o,n,m,l,k="enclosedBy"
if(a.k(0,k)!=null){s=t.a.a(a.k(0,k))
r=new A.cB(A.eP(s.k(0,"name")),B.q[A.eN(s.k(0,"kind"))],A.eP(s.k(0,"href")))}else r=null
q=a.k(0,"name")
p=a.k(0,"qualifiedName")
o=A.eO(a.k(0,"packageRank"))
if(o==null)o=0
n=a.k(0,"href")
m=B.q[A.eN(a.k(0,"kind"))]
l=A.eO(a.k(0,"overriddenDepth"))
if(l==null)l=0
return new A.y(q,p,o,m,n,l,a.k(0,"desc"),r)},
C:function C(a,b){this.a=a
this.b=b},
cG:function cG(a){this.a=a},
cJ:function cJ(a,b){this.a=a
this.b=b},
cH:function cH(){},
cI:function cI(){},
y:function y(a,b,c,d,e,f,g,h){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f
_.r=g
_.w=h},
cB:function cB(a,b,c){this.a=a
this.b=b
this.c=c},
kk(){var s,r,q,p,o,n=v.G,m=n.document.querySelectorAll("pre:has(> code)")
for(s=0;s<m.length;++s){r={}
q=m.item(s)
if(q==null)continue
p=n.document.createElement("button")
p.className="copy-button"
o=n.document.createElement("span")
o.className="material-symbols-outlined"
o.textContent="content_copy"
p.appendChild(o)
r.a=null
p.addEventListener("click",A.D(new A.ee(r,q,o,p)))
q.insertBefore(p,q.firstChild)}},
ee:function ee(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
ed:function ed(a,b,c){this.a=a
this.b=b
this.c=c},
bB(){var s,r=v.G.document.body
if(r==null)return""
if(J.u(r.getAttribute("data-using-base-href"),"false")){s=r.getAttribute("data-base-href")
return s==null?"":s}return""},
ki(){var s,r,q,p,o,n,m,l,k,j=$.eZ
if(j!=null){v.G.document.removeEventListener("keydown",j)
$.eZ=null}s=$.aH
if(s!=null)s.a0()
$.aH=null
s=v.G
r=s.document.getElementById("search-box")
q=s.document.getElementById("search-body")
p=s.document.getElementById("search-sidebar")
o=t.o
n=t.l
m=n.j("o.E")
l=A.cP(new A.ay(A.l([r,q,p],o),n),m)
k=A.cP(new A.ay(A.l([r,p,q],o),n),m)
if(l.length===0&&!A.he(A.al(J.T(s.window.location),0,null),l))return
A.jr()
new A.cm(l,k,A.kx(),A.ky(),B.k).bM()},
jp(a){v.G.window.location.assign(a)},
cv(){var s=0,r=A.eX(t.u),q,p=2,o=[],n,m,l,k
var $async$cv=A.f1(function(a,b){if(a===1){o.push(b)
s=p}for(;;)switch(s){case 0:p=4
s=7
return A.dU(A.ej(v.G.window.fetch(A.bB()+"index.json"),t.m),$async$cv)
case 7:n=b
if(!J.u(n.status,200)){q=null
s=1
break}s=8
return A.dU(A.ej(n.text(),t.N),$async$cv)
case 8:m=b
q=m
s=1
break
p=2
s=6
break
case 4:p=3
k=o.pop()
q=null
s=1
break
s=6
break
case 3:s=2
break
case 6:case 1:return A.eR(q,r)
case 2:return A.eQ(o.at(-1),r)}})
return A.eS($async$cv,r)},
jr(){var s,r,q=v.G,p=q.document.body
if(p==null)return null
s=q.document.getElementById("dartdoc-search-status")
if(t.m.b(s)){s.textContent=""
return s}r=A.K()
r.id="dartdoc-search-status"
r.setAttribute("role","status")
r.setAttribute("aria-live","polite")
r.setAttribute("aria-atomic","true")
q=r.style
q.position="absolute"
q.width="1px"
q.height="1px"
q.padding="0"
q.margin="-1px"
q.overflow="hidden"
q.setProperty("clip","rect(0, 0, 0, 0)")
q.setProperty("clip-path","inset(50%)")
q.whiteSpace="nowrap"
q.border="0"
p.appendChild(r)
return r},
cu(a){var s,r=$.aH
if(r!=null)r.a0()
$.aH=null
s=v.G.document.getElementById("dartdoc-search-status")
if(t.m.b(s))s.textContent=a},
jb(a){var s=$.aH
if(s!=null)s.a0()
$.aH=A.fy(B.G,new A.dT(a))},
h8(a){var s
A:{if(0===a){s="No search results."
break A}if(1===a){s="1 search result available."
break A}s=""+a+" search results available."
break A}return s},
he(a,b){if(a.gF().v("search"))return!0
if(B.a.U(a.gJ(),"search.html")&&a.gF().v("q"))return!0
return B.c.al(b,new A.e3())},
hd(a){var s,r,q
for(s=a.length,r=0;r<s;++r){q=a[r]
if(q.offsetParent!=null)return q}return A.es(a)},
iB(a,b,c){var s,r,q
a.disabled=!1
a.placeholder="Search API Docs"
a.setAttribute("autocomplete","off")
a.setAttribute("spellcheck","false")
a.classList.add("tt-input")
if(!a.hasAttribute("aria-label")&&!a.hasAttribute("aria-labelledby"))a.setAttribute("aria-label","Search API Docs")
s=A.h0(a)
A.h_(s,new A.dl(),".tt-search-spinner")
r=A.h_(s,new A.dm(),".tt-search-status")
q=a.form
if(q!=null)q.addEventListener("submit",A.D(new A.dn(b,a,c)))
return new A.aE(a,s,r)},
h0(a){var s,r,q,p,o,n,m=a.parentElement
if(t.m.b(m)){s=m.classList
s=s.contains("tt-wrapper")
r=m}else{r=null
s=!1}if(s)return r
q=J.u(v.G.document.activeElement,a)
p=a.selectionStart
o=a.selectionEnd
n=A.K()
n.classList.add("tt-wrapper")
a.replaceWith(n)
n.appendChild(a)
if(q){a.focus()
if(p!=null&&o!=null)a.setSelectionRange(p,o)}return n},
h_(a,b,c){var s,r=a.querySelector(c)
if(t.m.b(r))return r
s=b.$0()
a.appendChild(s)
return s},
jo(a,b,c){var s,r,q,p,o,n,m,l,k,j=A.K(),i=b.e
if(i==null)i=""
j.setAttribute("data-href",i)
j.classList.add("tt-suggestion")
s=A.eq()
s.classList.add("tt-suggestion-title")
s.innerHTML=A.eT(b.a+" "+b.d.h(0).toLowerCase(),a)
j.appendChild(s)
r=b.w
i=r!=null
if(i){q=A.eq()
q.classList.add("tt-suggestion-container")
q.innerHTML="(in "+A.eT(r.a,a)+")"
j.appendChild(q)}p=b.r
if(p!=null&&p.length!==0){q=v.G
o=q.document.createElement("blockquote")
o.classList.add("one-line-description")
n=q.document.createElement("textarea")
n.innerHTML=p
o.setAttribute("title",n.value)
o.innerHTML=A.eT(p,a)
j.appendChild(o)}j.addEventListener("mousedown",A.D(new A.dY()))
j.addEventListener("click",A.D(new A.dZ(b,c)))
if(i){i=r.a
q=r.b.h(0)
m=r.c
l=A.K()
l.classList.add("tt-container")
o=v.G.document.createElement("p")
o.textContent="Results from "
o.classList.add("tt-container-text")
k=A.ep()
k.setAttribute("href",m)
k.innerHTML=i+" "+q
o.appendChild(k)
l.appendChild(o)
A.jR(l,j)}return j},
jR(a,b){var s,r=a.innerHTML
if(r.length===0)return
s=$.ac.k(0,r)
if(s!=null)s.appendChild(b)
else{a.appendChild(b)
$.ac.q(0,r,a)}},
eT(a,b){return A.kA(a,A.fu(b,!1),new A.e_(),null)},
aF:function aF(a,b){this.a=a
this.b=b},
dT:function dT(a){this.a=a},
e3:function e3(){},
aE:function aE(a,b,c){this.a=a
this.b=b
this.c=c},
dl:function dl(){},
dm:function dm(){},
dn:function dn(a,b,c){this.a=a
this.b=b
this.c=c},
cm:function cm(a,b,c,d,e){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=$
_.f=e
_.r=null},
dx:function dx(a){this.a=a},
dq:function dq(a){this.a=a},
dr:function dr(a){this.a=a},
ds:function ds(a){this.a=a},
dt:function dt(a,b){this.a=a
this.b=b},
dv:function dv(a,b){this.a=a
this.b=b},
du:function du(){},
dw:function dw(){},
dB:function dB(a,b,c,d,e){var _=this
_.a=a
_.b=b
_.c=c
_.f=_.e=_.d=$
_.r=null
_.w=""
_.x=d
_.y=e
_.z=-1},
dC:function dC(a,b){this.a=a
this.b=b},
dD:function dD(a,b){this.a=a
this.b=b},
dE:function dE(a,b){this.a=a
this.b=b},
dF:function dF(a,b){this.a=a
this.b=b},
dY:function dY(){},
dZ:function dZ(a,b){this.a=a
this.b=b},
e_:function e_(){},
jy(){var s=v.G,r=s.document.getElementById("sidenav-left-toggle"),q=s.document.querySelector(".sidebar-offcanvas-left"),p=s.document.getElementById("overlay-under-drawer"),o=A.D(new A.e0(q,p))
if(p!=null)p.addEventListener("click",o)
if(r!=null)r.addEventListener("click",o)},
jx(){var s,r,q,p,o=v.G,n=o.document.body
if(n==null)return
s=n.getAttribute("data-using-base-href")
if(s==null)return
if(s!=="true"){r=n.getAttribute("data-base-href")
if(r==null)return
q=r}else q=""
p=o.document.getElementById("dartdoc-main-content")
if(p==null)return
A.h7(q,p.getAttribute("data-above-sidebar"),o.document.getElementById("dartdoc-sidebar-left-content"))
A.h7(q,p.getAttribute("data-below-sidebar"),o.document.getElementById("dartdoc-sidebar-right"))},
h7(a,b,c){if(b==null||b.length===0||c==null)return
A.ej(v.G.window.fetch(a+b),t.m).c6(new A.e1(c,a),t.P)},
hg(a,b){var s,r,q,p,o,n=A.i7(b,"HTMLAnchorElement")
if(n){n=b.attributes.getNamedItem("href")
s=n==null?null:n.value
if(s==null)return
r=A.iw(s)
if(r!=null&&!r.gb5())b.href=a+s}q=b.childNodes
for(p=0;p<q.length;++p){o=q.item(p)
if(o!=null)A.hg(a,o)}},
e0:function e0(a,b){this.a=a
this.b=b},
e1:function e1(a,b){this.a=a
this.b=b},
kj(){var s,r,q,p=v.G,o=p.document.body
if(o==null)return
s=p.document.getElementById("theme-button")
if(s==null)s=A.fX(s)
r=new A.eg(o)
s.addEventListener("click",A.D(new A.ef(o,r)))
q=p.window.localStorage.getItem("colorTheme")
if(q!=null)r.$1(q==="true")},
eg:function eg(a){this.a=a},
ef:function ef(a,b){this.a=a
this.b=b},
hq(a){return v.mangledGlobalNames[a]},
ku(a){if(typeof dartPrint=="function"){dartPrint(a)
return}if(typeof console=="object"&&typeof console.log!="undefined"){console.log(a)
return}if(typeof print=="function"){print(a)
return}throw"Unable to print message: "+String(a)},
kB(a){throw A.w(A.fn(a),new Error())},
bF(){throw A.w(A.fn(""),new Error())},
fi(){return v.G.document.createElement("section")},
fj(){return v.G.document.createElement("h2")},
K(){return v.G.document.createElement("div")},
ep(){return v.G.document.createElement("a")},
eq(){return v.G.document.createElement("span")},
ks(){A.jx()
A.jy()
A.ki()
var s=v.G.hljs
if(s!=null)s.highlightAll()
A.kj()
A.kk()}},B={}
var w=[A,J,B]
var $={}
A.eu.prototype={}
J.bO.prototype={
G(a,b){return a===b},
gn(a){return A.c5(a)},
h(a){return"Instance of '"+A.c6(a)+"'"},
gt(a){return A.ap(A.eU(this))}}
J.bQ.prototype={
h(a){return String(a)},
gn(a){return a?519018:218159},
gt(a){return A.ap(t.y)},
$ij:1,
$iN:1}
J.aZ.prototype={
G(a,b){return null==b},
h(a){return"null"},
gn(a){return 0},
$ij:1,
$it:1}
J.b1.prototype={$ih:1}
J.a6.prototype={
gn(a){return 0},
h(a){return String(a)}}
J.c4.prototype={}
J.ak.prototype={}
J.a5.prototype={
h(a){var s=a[$.hs()]
if(s==null)s=a[$.em()]
if(s==null)return this.bj(a)
return"JavaScript function for "+J.T(s)}}
J.b0.prototype={
gn(a){return 0},
h(a){return String(a)}}
J.b2.prototype={
gn(a){return 0},
h(a){return String(a)}}
J.p.prototype={
a1(a,b){return new A.V(a,A.Z(a).j("@<1>").D(b).j("V<1,2>"))},
a2(a){a.$flags&1&&A.O(a,"clear","clear")
a.length=0},
b6(a,b){var s,r=A.fp(a.length,"",!1,t.N)
for(s=0;s<a.length;++s)r[s]=A.i(a[s])
return r.join(b)},
bS(a,b,c){var s,r,q=a.length
for(s=b,r=0;r<q;++r){s=c.$2(s,a[r])
if(a.length!==q)throw A.a(A.ag(a))}return s},
bT(a,b,c){return this.bS(a,b,c,t.z)},
E(a,b){return a[b]},
bi(a,b,c){var s=a.length
if(b>s)throw A.a(A.F(b,0,s,"start",null))
if(c<b||c>s)throw A.a(A.F(c,b,s,"end",null))
if(b===c)return A.l([],A.Z(a))
return A.l(a.slice(b,c),A.Z(a))},
gb7(a){var s=a.length
if(s>0)return a[s-1]
throw A.a(A.fk())},
al(a,b){var s,r=a.length
for(s=0;s<r;++s){if(b.$1(a[s]))return!0
if(a.length!==r)throw A.a(A.ag(a))}return!1},
bh(a,b){var s,r,q,p,o
a.$flags&2&&A.O(a,"sort")
s=a.length
if(s<2)return
if(b==null)b=J.jE()
if(s===2){r=a[0]
q=a[1]
if(b.$2(r,q)>0){a[0]=q
a[1]=r}return}p=0
if(A.Z(a).c.b(null))for(o=0;o<a.length;++o)if(a[o]===void 0){a[o]=null;++p}a.sort(A.aM(b,2))
if(p>0)this.bD(a,p)},
bD(a,b){var s,r=a.length
for(;s=r-1,r>0;r=s)if(a[s]===null){a[s]=void 0;--b
if(b===0)break}},
h(a){return A.et(a,"[","]")},
gB(a){return new J.Q(a,a.length,A.Z(a).j("Q<1>"))},
gn(a){return A.c5(a)},
gl(a){return a.length},
k(a,b){if(!(b>=0&&b<a.length))throw A.a(A.f4(a,b))
return a[b]},
q(a,b,c){a.$flags&2&&A.O(a)
if(!(b>=0&&b<a.length))throw A.a(A.f4(a,b))
a[b]=c},
$ic:1,
$if:1}
J.bP.prototype={
c8(a){var s,r,q
if(!Array.isArray(a))return null
s=a.$flags|0
if((s&4)!==0)r="const, "
else if((s&2)!==0)r="unmodifiable, "
else r=(s&1)!==0?"fixed, ":""
q="Instance of '"+A.c6(a)+"'"
if(r==="")return q
return q+" ("+r+"length: "+a.length+")"}}
J.cL.prototype={}
J.Q.prototype={
gp(){var s=this.d
return s==null?this.$ti.c.a(s):s},
m(){var s,r=this,q=r.a,p=q.length
if(r.b!==p)throw A.a(A.a1(q))
s=r.c
if(s>=p){r.d=null
return!1}r.d=q[s]
r.c=s+1
return!0}}
J.b_.prototype={
a3(a,b){var s
if(a<b)return-1
else if(a>b)return 1
else if(a===b){if(a===0){s=this.gar(b)
if(this.gar(a)===s)return 0
if(this.gar(a))return-1
return 1}return 0}else if(isNaN(a)){if(isNaN(b))return 0
return 1}else return-1},
gar(a){return a===0?1/a<0:a<0},
h(a){if(a===0&&1/a<0)return"-0.0"
else return""+a},
gn(a){var s,r,q,p,o=a|0
if(a===o)return o&536870911
s=Math.abs(a)
r=Math.log(s)/0.6931471805599453|0
q=Math.pow(2,r)
p=s<1?s/q:q/s
return((p*9007199254740992|0)+(p*3542243181176521|0))*599197+r*1259&536870911},
a6(a,b){var s=a%b
if(s===0)return 0
if(s>0)return s
return s+b},
aj(a,b){return(a|0)===a?a/b|0:this.bJ(a,b)},
bJ(a,b){var s=a/b
if(s>=-2147483648&&s<=2147483647)return s|0
if(s>0){if(s!==1/0)return Math.floor(s)}else if(s>-1/0)return Math.ceil(s)
throw A.a(A.bi("Result of truncating division is "+A.i(s)+": "+A.i(a)+" ~/ "+b))},
ai(a,b){var s
if(a>0)s=this.aO(a,b)
else{s=b>31?31:b
s=a>>s>>>0}return s},
bF(a,b){if(0>b)throw A.a(A.k5(b))
return this.aO(a,b)},
aO(a,b){return b>31?0:a>>>b},
gt(a){return A.ap(t.H)},
$ir:1}
J.aY.prototype={
gt(a){return A.ap(t.S)},
$ij:1,
$ib:1}
J.bR.prototype={
gt(a){return A.ap(t.i)},
$ij:1}
J.a4.prototype={
U(a,b){var s=b.length,r=a.length
if(s>r)return!1
return b===this.K(a,r-s)},
N(a,b,c,d){var s=A.bd(b,c,a.length)
return a.substring(0,b)+d+a.substring(s)},
u(a,b,c){var s
if(c<0||c>a.length)throw A.a(A.F(c,0,a.length,null,null))
s=c+b.length
if(s>a.length)return!1
return b===a.substring(c,s)},
A(a,b){return this.u(a,b,0)},
i(a,b,c){return a.substring(b,A.bd(b,c,a.length))},
K(a,b){return this.i(a,b,null)},
c7(a){var s,r,q,p=a.trim(),o=p.length
if(o===0)return p
if(p.charCodeAt(0)===133){s=J.ib(p,1)
if(s===o)return""}else s=0
r=o-1
q=p.charCodeAt(r)===133?J.ic(p,r):o
if(s===0&&q===o)return p
return p.substring(s,q)},
aA(a,b){var s,r
if(0>=b)return""
if(b===1||a.length===0)return a
if(b!==b>>>0)throw A.a(B.C)
for(s=a,r="";;){if((b&1)===1)r=s+r
b=b>>>1
if(b===0)break
s+=s}return r},
bZ(a,b,c){var s=b-a.length
if(s<=0)return a
return this.aA(c,s)+a},
a4(a,b,c){var s
if(c<0||c>a.length)throw A.a(A.F(c,0,a.length,null,null))
s=a.indexOf(b,c)
return s},
b2(a,b){return this.a4(a,b,0)},
H(a,b){return A.kz(a,b,0)},
a3(a,b){var s
if(a===b)s=0
else s=a<b?-1:1
return s},
h(a){return a},
gn(a){var s,r,q
for(s=a.length,r=0,q=0;q<s;++q){r=r+a.charCodeAt(q)&536870911
r=r+((r&524287)<<10)&536870911
r^=r>>6}r=r+((r&67108863)<<3)&536870911
r^=r>>11
return r+((r&16383)<<15)&536870911},
gt(a){return A.ap(t.N)},
gl(a){return a.length},
$ij:1,
$id:1}
A.aa.prototype={
gB(a){return new A.bI(J.aQ(this.gR()),A.a0(this).j("bI<1,2>"))},
gl(a){return J.a3(this.gR())},
E(a,b){return A.a0(this).y[1].a(J.fa(this.gR(),b))},
h(a){return J.T(this.gR())}}
A.bI.prototype={
m(){return this.a.m()},
gp(){return this.$ti.y[1].a(this.a.gp())}}
A.ae.prototype={
gR(){return this.a}}
A.bl.prototype={$ic:1}
A.bk.prototype={
k(a,b){return this.$ti.y[1].a(J.hK(this.a,b))},
q(a,b,c){J.hL(this.a,b,this.$ti.c.a(c))},
$ic:1,
$if:1}
A.V.prototype={
a1(a,b){return new A.V(this.a,this.$ti.j("@<1>").D(b).j("V<1,2>"))},
gR(){return this.a}}
A.bT.prototype={
h(a){return"LateInitializationError: "+this.a}}
A.bJ.prototype={
gl(a){return this.a.length},
k(a,b){return this.a.charCodeAt(b)}}
A.cU.prototype={}
A.c.prototype={}
A.L.prototype={
gB(a){var s=this
return new A.av(s,s.gl(s),A.a0(s).j("av<L.E>"))}}
A.av.prototype={
gp(){var s=this.d
return s==null?this.$ti.c.a(s):s},
m(){var s,r=this,q=r.a,p=J.e6(q),o=p.gl(q)
if(r.b!==o)throw A.a(A.ag(q))
s=r.c
if(s>=o){r.d=null
return!1}r.d=p.E(q,s);++r.c
return!0}}
A.aj.prototype={
gl(a){return J.a3(this.a)},
E(a,b){return this.b.$1(J.fa(this.a,b))}}
A.ay.prototype={
gB(a){var s=this.a
return new A.c2(new J.Q(s,3,A.Z(s).j("Q<1>")))}}
A.c2.prototype={
m(){var s,r,q
this.b=null
for(s=this.a,r=s.$ti.c;s.m();){q=s.d
if(q==null)q=r.a(q)
if(q!=null){this.b=q
return!0}}return!1},
gp(){var s=this.b
return s==null?A.as(A.fk()):s}}
A.aX.prototype={}
A.ca.prototype={
q(a,b,c){throw A.a(A.bi("Cannot modify an unmodifiable list"))}}
A.aA.prototype={}
A.bA.prototype={}
A.cp.prototype={$r:"+item,matchPosition(1,2)",$s:1}
A.aS.prototype={
h(a){return A.ex(this)},
q(a,b,c){A.hY()},
$iA:1}
A.aU.prototype={
gl(a){return this.b.length},
gbz(){var s=this.$keys
if(s==null){s=Object.keys(this.a)
this.$keys=s}return s},
v(a){if("__proto__"===a)return!1
return this.a.hasOwnProperty(a)},
k(a,b){if(!this.v(b))return null
return this.b[this.a[b]]},
I(a,b){var s,r,q=this.gbz(),p=this.b
for(s=q.length,r=0;r<s;++r)b.$2(q[r],p[r])}}
A.cl.prototype={
gp(){var s=this.d
return s==null?this.$ti.c.a(s):s},
m(){var s=this,r=s.c
if(r>=s.b){s.d=null
return!1}s.d=s.a[r]
s.c=r+1
return!0}}
A.aT.prototype={}
A.aV.prototype={
gl(a){return this.b},
gB(a){var s,r=this,q=r.$keys
if(q==null){q=Object.keys(r.a)
r.$keys=q}s=q
return new A.cl(s,s.length,r.$ti.j("cl<1>"))},
H(a,b){if("__proto__"===b)return!1
return this.a.hasOwnProperty(b)}}
A.be.prototype={}
A.cX.prototype={
C(a){var s,r,q=this,p=new RegExp(q.a).exec(a)
if(p==null)return null
s=Object.create(null)
r=q.b
if(r!==-1)s.arguments=p[r+1]
r=q.c
if(r!==-1)s.argumentsExpr=p[r+1]
r=q.d
if(r!==-1)s.expr=p[r+1]
r=q.e
if(r!==-1)s.method=p[r+1]
r=q.f
if(r!==-1)s.receiver=p[r+1]
return s}}
A.bb.prototype={
h(a){return"Null check operator used on a null value"}}
A.bS.prototype={
h(a){var s,r=this,q="NoSuchMethodError: method not found: '",p=r.b
if(p==null)return"NoSuchMethodError: "+r.a
s=r.c
if(s==null)return q+p+"' ("+r.a+")"
return q+p+"' on '"+s+"' ("+r.a+")"}}
A.c9.prototype={
h(a){var s=this.a
return s.length===0?"Error":"Error: "+s}}
A.cT.prototype={
h(a){return"Throw of null ('"+(this.a===null?"null":"undefined")+"' from JavaScript)"}}
A.aW.prototype={}
A.br.prototype={
h(a){var s,r=this.b
if(r!=null)return r
r=this.a
s=r!==null&&typeof r==="object"?r.stack:null
return this.b=s==null?"":s},
$ia8:1}
A.af.prototype={
h(a){var s=this.constructor,r=s==null?null:s.name
return"Closure '"+A.hr(r==null?"unknown":r)+"'"},
gca(){return this},
$C:"$1",
$R:1,
$D:null}
A.cz.prototype={$C:"$0",$R:0}
A.cA.prototype={$C:"$2",$R:2}
A.cW.prototype={}
A.cV.prototype={
h(a){var s=this.$static_name
if(s==null)return"Closure of unknown static method"
return"Closure '"+A.hr(s)+"'"}}
A.aR.prototype={
G(a,b){if(b==null)return!1
if(this===b)return!0
if(!(b instanceof A.aR))return!1
return this.$_target===b.$_target&&this.a===b.a},
gn(a){return(A.hn(this.a)^A.c5(this.$_target))>>>0},
h(a){return"Closure '"+this.$_name+"' of "+("Instance of '"+A.c6(this.a)+"'")}}
A.c7.prototype={
h(a){return"RuntimeError: "+this.a}}
A.ah.prototype={
gl(a){return this.a},
gL(){return new A.ai(this,A.a0(this).j("ai<1>"))},
v(a){var s=this.b
if(s==null)return!1
return s[a]!=null},
k(a,b){var s,r,q,p,o=null
if(typeof b=="string"){s=this.b
if(s==null)return o
r=s[b]
q=r==null?o:r.b
return q}else if(typeof b=="number"&&(b&0x3fffffff)===b){p=this.c
if(p==null)return o
r=p[b]
q=r==null?o:r.b
return q}else return this.bW(b)},
bW(a){var s,r,q=this.d
if(q==null)return null
s=this.bu(q,a)
r=this.b4(s,a)
if(r<0)return null
return s[r].b},
q(a,b,c){var s,r,q,p,o,n,m=this
if(typeof b=="string"){s=m.b
m.aC(s==null?m.b=m.ag():s,b,c)}else if(typeof b=="number"&&(b&0x3fffffff)===b){r=m.c
m.aC(r==null?m.c=m.ag():r,b,c)}else{q=m.d
if(q==null)q=m.d=m.ag()
p=m.b3(b)
o=q[p]
if(o==null)q[p]=[m.ah(b,c)]
else{n=m.b4(o,b)
if(n>=0)o[n].b=c
else o.push(m.ah(b,c))}}},
a2(a){var s=this
if(s.a>0){s.b=s.c=s.d=s.e=s.f=null
s.a=0
s.aJ()}},
I(a,b){var s=this,r=s.e,q=s.r
while(r!=null){b.$2(r.a,r.b)
if(q!==s.r)throw A.a(A.ag(s))
r=r.c}},
aC(a,b,c){var s=a[b]
if(s==null)a[b]=this.ah(b,c)
else s.b=c},
aJ(){this.r=this.r+1&1073741823},
ah(a,b){var s=this,r=new A.cO(a,b)
if(s.e==null)s.e=s.f=r
else s.f=s.f.c=r;++s.a
s.aJ()
return r},
b3(a){return J.a2(a)&1073741823},
bu(a,b){return a[this.b3(b)]},
b4(a,b){var s,r
if(a==null)return-1
s=a.length
for(r=0;r<s;++r)if(J.u(a[r].a,b))return r
return-1},
h(a){return A.ex(this)},
ag(){var s=Object.create(null)
s["<non-identifier-key>"]=s
delete s["<non-identifier-key>"]
return s}}
A.cO.prototype={}
A.ai.prototype={
gl(a){return this.a.a},
gB(a){var s=this.a
return new A.bU(s,s.r,s.e)},
H(a,b){return this.a.v(b)}}
A.bU.prototype={
gp(){return this.d},
m(){var s,r=this,q=r.a
if(r.b!==q.r)throw A.a(A.ag(q))
s=r.c
if(s==null){r.d=null
return!1}else{r.d=s.a
r.c=s.c
return!0}}}
A.b4.prototype={
gl(a){return this.a.a},
gB(a){var s=this.a
return new A.b3(s,s.r,s.e)}}
A.b3.prototype={
gp(){return this.d},
m(){var s,r=this,q=r.a
if(r.b!==q.r)throw A.a(A.ag(q))
s=r.c
if(s==null){r.d=null
return!1}else{r.d=s.b
r.c=s.c
return!0}}}
A.ea.prototype={
$1(a){return this.a(a)},
$S:11}
A.eb.prototype={
$2(a,b){return this.a(a,b)},
$S:13}
A.ec.prototype={
$1(a){return this.a(a)},
$S:12}
A.bq.prototype={
h(a){return this.aQ(!1)},
aQ(a){var s,r,q,p,o,n=this.bs(),m=this.aI(),l=(a?"Record ":"")+"("
for(s=n.length,r="",q=0;q<s;++q,r=", "){l+=r
p=n[q]
if(typeof p=="string")l=l+p+": "
o=m[q]
l=a?l+A.fs(o):l+A.i(o)}l+=")"
return l.charCodeAt(0)==0?l:l},
bs(){var s,r=this.$s
while($.dy.length<=r)$.dy.push(null)
s=$.dy[r]
if(s==null){s=this.bo()
$.dy[r]=s}return s},
bo(){var s,r,q,p=this.$r,o=p.indexOf("("),n=p.substring(1,o),m=p.substring(o),l=m==="()"?0:m.replace(/[^,]/g,"").length+1,k=A.l(new Array(l),t.f)
for(s=0;s<l;++s)k[s]=s
if(n!==""){r=n.split(",")
s=r.length
for(q=l;s>0;){--q;--s
k[q]=r[s]}}k=A.id(k,!1,t.K)
k.$flags=3
return k}}
A.co.prototype={
aI(){return[this.a,this.b]},
G(a,b){if(b==null)return!1
return b instanceof A.co&&this.$s===b.$s&&J.u(this.a,b.a)&&J.u(this.b,b.b)},
gn(a){return A.ih(this.$s,this.a,this.b,B.i)}}
A.cK.prototype={
h(a){return"RegExp/"+this.a+"/"+this.b.flags},
gbB(){var s=this,r=s.c
if(r!=null)return r
r=s.b
return s.c=A.fm(s.a,r.multiline,!r.ignoreCase,r.unicode,r.dotAll,"g")},
br(a,b){var s,r=this.gbB()
r.lastIndex=b
s=r.exec(a)
if(s==null)return null
return new A.cn(s)}}
A.cn.prototype={
gbQ(){var s=this.b
return s.index+s[0].length},
k(a,b){return this.b[b]},
$icR:1,
$iez:1}
A.d4.prototype={
gp(){var s=this.d
return s==null?t.F.a(s):s},
m(){var s,r,q,p,o,n,m=this,l=m.b
if(l==null)return!1
s=m.c
r=l.length
if(s<=r){q=m.a
p=q.br(l,s)
if(p!=null){m.d=p
o=p.gbQ()
if(p.b.index===o){s=!1
if(q.b.unicode){q=m.c
n=q+1
if(n<r){r=l.charCodeAt(q)
if(r>=55296&&r<=56319){s=l.charCodeAt(n)
s=s>=56320&&s<=57343}}}o=(s?o+1:o)+1}m.c=o
return!0}}m.b=m.d=null
return!1}}
A.aw.prototype={
gt(a){return B.ab},
$ij:1}
A.b8.prototype={
by(a,b,c,d){var s=A.F(b,0,c,d,null)
throw A.a(s)},
aF(a,b,c,d){if(b>>>0!==b||b>c)this.by(a,b,c,d)}}
A.bV.prototype={
gt(a){return B.ac},
$ij:1}
A.ax.prototype={
gl(a){return a.length},
$iE:1}
A.b6.prototype={
k(a,b){A.a_(b,a,a.length)
return a[b]},
q(a,b,c){a.$flags&2&&A.O(a)
A.a_(b,a,a.length)
a[b]=c},
$ic:1,
$if:1}
A.b7.prototype={
q(a,b,c){a.$flags&2&&A.O(a)
A.a_(b,a,a.length)
a[b]=c},
bf(a,b,c,d,e){var s,r,q
a.$flags&2&&A.O(a,5)
s=a.length
this.aF(a,b,s,"start")
this.aF(a,c,s,"end")
if(b>c)A.as(A.F(b,0,c,null,null))
r=c-b
if(e<0)A.as(A.U(e,null))
if(16-e<r)A.as(A.eB("Not enough elements"))
q=e!==0||16!==r?d.subarray(e,e+r):d
a.set(q,b)
return},
$ic:1,
$if:1}
A.bW.prototype={
gt(a){return B.ad},
$ij:1}
A.bX.prototype={
gt(a){return B.ae},
$ij:1}
A.bY.prototype={
gt(a){return B.af},
k(a,b){A.a_(b,a,a.length)
return a[b]},
$ij:1}
A.bZ.prototype={
gt(a){return B.ag},
k(a,b){A.a_(b,a,a.length)
return a[b]},
$ij:1}
A.c_.prototype={
gt(a){return B.ah},
k(a,b){A.a_(b,a,a.length)
return a[b]},
$ij:1}
A.c0.prototype={
gt(a){return B.aj},
k(a,b){A.a_(b,a,a.length)
return a[b]},
$ij:1}
A.c1.prototype={
gt(a){return B.ak},
k(a,b){A.a_(b,a,a.length)
return a[b]},
$ij:1}
A.b9.prototype={
gt(a){return B.al},
gl(a){return a.length},
k(a,b){A.a_(b,a,a.length)
return a[b]},
$ij:1}
A.ba.prototype={
gt(a){return B.am},
gl(a){return a.length},
k(a,b){A.a_(b,a,a.length)
return a[b]},
$ij:1}
A.bm.prototype={}
A.bn.prototype={}
A.bo.prototype={}
A.bp.prototype={}
A.M.prototype={
j(a){return A.bw(v.typeUniverse,this,a)},
D(a){return A.fN(v.typeUniverse,this,a)}}
A.ci.prototype={}
A.dI.prototype={
h(a){return A.G(this.a,null)}}
A.ch.prototype={
h(a){return this.a}}
A.bs.prototype={$iX:1}
A.d6.prototype={
$1(a){var s=this.a,r=s.a
s.a=null
r.$0()},
$S:5}
A.d5.prototype={
$1(a){var s,r
this.a.a=a
s=this.b
r=this.c
s.firstChild?s.removeChild(r):s.appendChild(r)},
$S:20}
A.d7.prototype={
$0(){this.a.$0()},
$S:3}
A.d8.prototype={
$0(){this.a.$0()},
$S:3}
A.dG.prototype={
bk(a,b){if(self.setTimeout!=null)this.b=self.setTimeout(A.aM(new A.dH(this,b),0),a)
else throw A.a(A.bi("`setTimeout()` not found."))},
a0(){if(self.setTimeout!=null){var s=this.b
if(s==null)return
self.clearTimeout(s)
this.b=null}else throw A.a(A.bi("Canceling a timer."))}}
A.dH.prototype={
$0(){this.a.b=null
this.b.$0()},
$S:0}
A.cd.prototype={
am(a){var s,r=this
if(a==null)a=r.$ti.c.a(a)
if(!r.b)r.a.aD(a)
else{s=r.a
if(r.$ti.j("S<1>").b(a))s.aE(a)
else s.aG(a)}},
an(a,b){var s=this.a
if(this.b)s.aa(new A.J(a,b))
else s.a9(new A.J(a,b))}}
A.dV.prototype={
$1(a){return this.a.$2(0,a)},
$S:4}
A.dW.prototype={
$2(a,b){this.a.$2(1,new A.aW(a,b))},
$S:22}
A.e4.prototype={
$2(a,b){this.a(a,b)},
$S:25}
A.J.prototype={
h(a){return A.i(this.a)},
$im:1,
gO(){return this.b}}
A.cf.prototype={
an(a,b){var s=this.a
if((s.a&30)!==0)throw A.a(A.eB("Future already completed"))
s.a9(A.jD(a,b))},
aT(a){return this.an(a,null)}}
A.bj.prototype={
am(a){var s=this.a
if((s.a&30)!==0)throw A.a(A.eB("Future already completed"))
s.aD(a)}}
A.aC.prototype={
bX(a){if((this.c&15)!==6)return!0
return this.b.b.aw(this.d,a.a)},
bU(a){var s,r=this.e,q=null,p=a.a,o=this.b.b
if(t.Q.b(r))q=o.c2(r,p,a.b)
else q=o.aw(r,p)
try{p=q
return p}catch(s){if(t._.b(A.at(s))){if((this.c&1)!==0)throw A.a(A.U("The error handler of Future.then must return a value of the returned future's type","onError"))
throw A.a(A.U("The error handler of Future.catchError must return a value of the future's type","onError"))}else throw s}}}
A.x.prototype={
az(a,b,c){var s,r,q=$.q
if(q===B.d){if(b!=null&&!t.Q.b(b)&&!t.v.b(b))throw A.a(A.fb(b,"onError",u.c))}else if(b!=null)b=A.jV(b,q)
s=new A.x(q,c.j("x<0>"))
r=b==null?1:3
this.a8(new A.aC(s,r,a,b,this.$ti.j("@<1>").D(c).j("aC<1,2>")))
return s},
c6(a,b){return this.az(a,null,b)},
aP(a,b,c){var s=new A.x($.q,c.j("x<0>"))
this.a8(new A.aC(s,19,a,b,this.$ti.j("@<1>").D(c).j("aC<1,2>")))
return s},
bE(a){this.a=this.a&1|16
this.c=a},
W(a){this.a=a.a&30|this.a&1
this.c=a.c},
a8(a){var s=this,r=s.a
if(r<=3){a.a=s.c
s.c=a}else{if((r&4)!==0){r=s.c
if((r.a&24)===0){r.a8(a)
return}s.W(r)}A.cw(null,null,s.b,new A.db(s,a))}},
aL(a){var s,r,q,p,o,n=this,m={}
m.a=a
if(a==null)return
s=n.a
if(s<=3){r=n.c
n.c=a
if(r!=null){q=a.a
for(p=a;q!=null;p=q,q=o)o=q.a
p.a=r}}else{if((s&4)!==0){s=n.c
if((s.a&24)===0){s.aL(a)
return}n.W(s)}m.a=n.Z(a)
A.cw(null,null,n.b,new A.df(m,n))}},
Y(){var s=this.c
this.c=null
return this.Z(s)},
Z(a){var s,r,q
for(s=a,r=null;s!=null;r=s,s=q){q=s.a
s.a=r}return r},
aG(a){var s=this,r=s.Y()
s.a=8
s.c=a
A.aD(s,r)},
bn(a){var s,r,q=this
if((a.a&16)!==0){s=q.b===a.b
s=!(s||s)}else s=!1
if(s)return
r=q.Y()
q.W(a)
A.aD(q,r)},
aa(a){var s=this.Y()
this.bE(a)
A.aD(this,s)},
aD(a){if(this.$ti.j("S<1>").b(a)){this.aE(a)
return}this.bl(a)},
bl(a){this.a^=2
A.cw(null,null,this.b,new A.dd(this,a))},
aE(a){A.eE(a,this,!1)
return},
a9(a){this.a^=2
A.cw(null,null,this.b,new A.dc(this,a))},
$iS:1}
A.db.prototype={
$0(){A.aD(this.a,this.b)},
$S:0}
A.df.prototype={
$0(){A.aD(this.b,this.a.a)},
$S:0}
A.de.prototype={
$0(){A.eE(this.a.a,this.b,!0)},
$S:0}
A.dd.prototype={
$0(){this.a.aG(this.b)},
$S:0}
A.dc.prototype={
$0(){this.a.aa(this.b)},
$S:0}
A.di.prototype={
$0(){var s,r,q,p,o,n,m,l,k=this,j=null
try{q=k.a.a
j=q.b.b.c0(q.d)}catch(p){s=A.at(p)
r=A.aN(p)
if(k.c&&k.b.a.c.a===s){q=k.a
q.c=k.b.a.c}else{q=s
o=r
if(o==null)o=A.eo(q)
n=k.a
n.c=new A.J(q,o)
q=n}q.b=!0
return}if(j instanceof A.x&&(j.a&24)!==0){if((j.a&16)!==0){q=k.a
q.c=j.c
q.b=!0}return}if(j instanceof A.x){m=k.b.a
l=new A.x(m.b,m.$ti)
j.az(new A.dj(l,m),new A.dk(l),t.n)
q=k.a
q.c=l
q.b=!1}},
$S:0}
A.dj.prototype={
$1(a){this.a.bn(this.b)},
$S:5}
A.dk.prototype={
$2(a,b){this.a.aa(new A.J(a,b))},
$S:30}
A.dh.prototype={
$0(){var s,r,q,p,o,n
try{q=this.a
p=q.a
q.c=p.b.b.aw(p.d,this.b)}catch(o){s=A.at(o)
r=A.aN(o)
q=s
p=r
if(p==null)p=A.eo(q)
n=this.a
n.c=new A.J(q,p)
n.b=!0}},
$S:0}
A.dg.prototype={
$0(){var s,r,q,p,o,n,m,l=this
try{s=l.a.a.c
p=l.b
if(p.a.bX(s)&&p.a.e!=null){p.c=p.a.bU(s)
p.b=!1}}catch(o){r=A.at(o)
q=A.aN(o)
p=l.a.a.c
if(p.a===r){n=l.b
n.c=p
p=n}else{p=r
n=q
if(n==null)n=A.eo(p)
m=l.b
m.c=new A.J(p,n)
p=m}p.b=!0}},
$S:0}
A.ce.prototype={}
A.cr.prototype={}
A.dS.prototype={}
A.dz.prototype={
c4(a){var s,r,q
try{if(B.d===$.q){a.$0()
return}A.h9(null,null,this,a)}catch(q){s=A.at(q)
r=A.aN(q)
A.eY(s,r)}},
aR(a){return new A.dA(this,a)},
c1(a){if($.q===B.d)return a.$0()
return A.h9(null,null,this,a)},
c0(a){return this.c1(a,t.z)},
c5(a,b){if($.q===B.d)return a.$1(b)
return A.jX(null,null,this,a,b)},
aw(a,b){var s=t.z
return this.c5(a,b,s,s)},
c3(a,b,c){if($.q===B.d)return a.$2(b,c)
return A.jW(null,null,this,a,b,c)},
c2(a,b,c){var s=t.z
return this.c3(a,b,c,s,s,s)},
c_(a){return a},
b9(a){var s=t.z
return this.c_(a,s,s,s)}}
A.dA.prototype={
$0(){return this.a.c4(this.b)},
$S:0}
A.e2.prototype={
$0(){A.i_(this.a,this.b)},
$S:0}
A.e.prototype={
gB(a){return new A.av(a,this.gl(a),A.aO(a).j("av<e.E>"))},
E(a,b){return this.k(a,b)},
a1(a,b){return new A.V(a,A.aO(a).j("@<e.E>").D(b).j("V<1,2>"))},
bR(a,b,c,d){var s
A.bd(b,c,this.gl(a))
for(s=b;s<c;++s)this.q(a,s,d)},
h(a){return A.et(a,"[","]")},
$ic:1,
$if:1}
A.W.prototype={
I(a,b){var s,r,q,p
for(s=this.gL(),s=s.gB(s),r=A.a0(this).j("W.V");s.m();){q=s.gp()
p=this.k(0,q)
b.$2(q,p==null?r.a(p):p)}},
v(a){return this.gL().H(0,a)},
gl(a){var s=this.gL()
return s.gl(s)},
h(a){return A.ex(this)},
$iA:1}
A.cQ.prototype={
$2(a,b){var s,r=this.a
if(!r.a)this.b.a+=", "
r.a=!1
r=this.b
s=A.i(a)
r.a=(r.a+=s)+": "
s=A.i(b)
r.a+=s},
$S:10}
A.ct.prototype={
q(a,b,c){throw A.a(A.bi("Cannot modify unmodifiable map"))}}
A.b5.prototype={
k(a,b){return this.a.k(0,b)},
q(a,b,c){this.a.q(0,b,c)},
v(a){return this.a.v(a)},
gl(a){var s=this.a
return s.gl(s)},
h(a){return this.a.h(0)},
$iA:1}
A.aB.prototype={}
A.az.prototype={
h(a){return A.et(this,"{","}")},
E(a,b){var s,r
A.ey(b,"index")
s=this.gB(this)
for(r=b;s.m();){if(r===0)return s.gp();--r}throw A.a(A.er(b,b-r,this,"index"))},
$ic:1}
A.bx.prototype={}
A.cj.prototype={
k(a,b){var s,r=this.b
if(r==null)return this.c.k(0,b)
else if(typeof b!="string")return null
else{s=r[b]
return typeof s=="undefined"?this.bC(b):s}},
gl(a){return this.b==null?this.c.a:this.P().length},
gL(){if(this.b==null){var s=this.c
return new A.ai(s,A.a0(s).j("ai<1>"))}return new A.ck(this)},
q(a,b,c){var s,r,q=this
if(q.b==null)q.c.q(0,b,c)
else if(q.v(b)){s=q.b
s[b]=c
r=q.a
if(r==null?s!=null:r!==s)r[b]=null}else q.bK().q(0,b,c)},
v(a){if(this.b==null)return this.c.v(a)
return Object.prototype.hasOwnProperty.call(this.a,a)},
I(a,b){var s,r,q,p,o=this
if(o.b==null)return o.c.I(0,b)
s=o.P()
for(r=0;r<s.length;++r){q=s[r]
p=o.b[q]
if(typeof p=="undefined"){p=A.dX(o.a[q])
o.b[q]=p}b.$2(q,p)
if(s!==o.c)throw A.a(A.ag(o))}},
P(){var s=this.c
if(s==null)s=this.c=A.l(Object.keys(this.a),t.s)
return s},
bK(){var s,r,q,p,o,n=this
if(n.b==null)return n.c
s=A.ew(t.N,t.z)
r=n.P()
for(q=0;p=r.length,q<p;++q){o=r[q]
s.q(0,o,n.k(0,o))}if(p===0)r.push("")
else B.c.a2(r)
n.a=n.b=null
return n.c=s},
bC(a){var s
if(!Object.prototype.hasOwnProperty.call(this.a,a))return null
s=A.dX(this.a[a])
return this.b[a]=s}}
A.ck.prototype={
gl(a){return this.a.gl(0)},
E(a,b){var s=this.a
return s.b==null?s.gL().E(0,b):s.P()[b]},
gB(a){var s=this.a
if(s.b==null){s=s.gL()
s=s.gB(s)}else{s=s.P()
s=new J.Q(s,s.length,A.Z(s).j("Q<1>"))}return s},
H(a,b){return this.a.v(b)}}
A.dP.prototype={
$0(){var s,r
try{s=new TextDecoder("utf-8",{fatal:true})
return s}catch(r){}return null},
$S:6}
A.dO.prototype={
$0(){var s,r
try{s=new TextDecoder("utf-8",{fatal:false})
return s}catch(r){}return null},
$S:6}
A.cx.prototype={
bY(a0,a1,a2){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a="Invalid base64 encoding length "
a2=A.bd(a1,a2,a0.length)
s=$.hD()
for(r=a1,q=r,p=null,o=-1,n=-1,m=0;r<a2;r=l){l=r+1
k=a0.charCodeAt(r)
if(k===37){j=l+2
if(j<=a2){i=A.e9(a0.charCodeAt(l))
h=A.e9(a0.charCodeAt(l+1))
g=i*16+h-(h&256)
if(g===37)g=-1
l=j}else g=-1}else g=k
if(0<=g&&g<=127){f=s[g]
if(f>=0){g="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".charCodeAt(f)
if(g===k)continue
k=g}else{if(f===-1){if(o<0){e=p==null?null:p.a.length
if(e==null)e=0
o=e+(r-q)
n=r}++m
if(k===61)continue}k=g}if(f!==-2){if(p==null){p=new A.B("")
e=p}else e=p
e.a+=B.a.i(a0,q,r)
d=A.a7(k)
e.a+=d
q=l
continue}}throw A.a(A.z("Invalid base64 data",a0,r))}if(p!=null){e=B.a.i(a0,q,a2)
e=p.a+=e
d=e.length
if(o>=0)A.fc(a0,n,a2,o,m,d)
else{c=B.b.a6(d-1,4)+1
if(c===1)throw A.a(A.z(a,a0,a2))
while(c<4){e+="="
p.a=e;++c}}e=p.a
return B.a.N(a0,a1,a2,e.charCodeAt(0)==0?e:e)}b=a2-a1
if(o>=0)A.fc(a0,n,a2,o,m,b)
else{c=B.b.a6(b,4)
if(c===1)throw A.a(A.z(a,a0,a2))
if(c>1)a0=B.a.N(a0,a2,a2,c===2?"==":"=")}return a0}}
A.cy.prototype={}
A.bK.prototype={}
A.bM.prototype={}
A.cC.prototype={}
A.cF.prototype={
h(a){return"unknown"}}
A.cE.prototype={
T(a){var s=this.aH(a,0,a.length)
return s==null?a:s},
aH(a,b,c){var s,r,q,p
for(s=b,r=null;s<c;++s){switch(a[s]){case"&":q="&amp;"
break
case'"':q="&quot;"
break
case"'":q="&#39;"
break
case"<":q="&lt;"
break
case">":q="&gt;"
break
case"/":q="&#47;"
break
default:q=null}if(q!=null){if(r==null)r=new A.B("")
if(s>b)r.a+=B.a.i(a,b,s)
r.a+=q
b=s+1}}if(r==null)return null
if(c>b){p=B.a.i(a,b,c)
r.a+=p}p=r.a
return p.charCodeAt(0)==0?p:p}}
A.cM.prototype={
bN(a,b){var s=A.jT(a,this.gbP().a)
return s},
gbP(){return B.K}}
A.cN.prototype={}
A.d1.prototype={}
A.d3.prototype={
T(a){var s,r,q,p=A.bd(0,null,a.length)
if(p===0)return new Uint8Array(0)
s=p*3
r=new Uint8Array(s)
q=new A.dQ(r)
if(q.bt(a,0,p)!==p)q.ak()
return new Uint8Array(r.subarray(0,A.jn(0,q.b,s)))}}
A.dQ.prototype={
ak(){var s=this,r=s.c,q=s.b,p=s.b=q+1
r.$flags&2&&A.O(r)
r[q]=239
q=s.b=p+1
r[p]=191
s.b=q+1
r[q]=189},
bL(a,b){var s,r,q,p,o=this
if((b&64512)===56320){s=65536+((a&1023)<<10)|b&1023
r=o.c
q=o.b
p=o.b=q+1
r.$flags&2&&A.O(r)
r[q]=s>>>18|240
q=o.b=p+1
r[p]=s>>>12&63|128
p=o.b=q+1
r[q]=s>>>6&63|128
o.b=p+1
r[p]=s&63|128
return!0}else{o.ak()
return!1}},
bt(a,b,c){var s,r,q,p,o,n,m,l,k=this
if(b!==c&&(a.charCodeAt(c-1)&64512)===55296)--c
for(s=k.c,r=s.$flags|0,q=s.length,p=b;p<c;++p){o=a.charCodeAt(p)
if(o<=127){n=k.b
if(n>=q)break
k.b=n+1
r&2&&A.O(s)
s[n]=o}else{n=o&64512
if(n===55296){if(k.b+4>q)break
m=p+1
if(k.bL(o,a.charCodeAt(m)))p=m}else if(n===56320){if(k.b+3>q)break
k.ak()}else if(o<=2047){n=k.b
l=n+1
if(l>=q)break
k.b=l
r&2&&A.O(s)
s[n]=o>>>6|192
k.b=l+1
s[l]=o&63|128}else{n=k.b
if(n+2>=q)break
l=k.b=n+1
r&2&&A.O(s)
s[n]=o>>>12|224
n=k.b=l+1
s[l]=o>>>6&63|128
k.b=n+1
s[n]=o&63|128}}}return p}}
A.d2.prototype={
T(a){return new A.dN(this.a).bq(a,0,null,!0)}}
A.dN.prototype={
bq(a,b,c,d){var s,r,q,p,o,n,m=this,l=A.bd(b,c,J.a3(a))
if(b===l)return""
if(a instanceof Uint8Array){s=a
r=s
q=0}else{r=A.j9(a,b,l)
l-=b
q=b
b=0}if(l-b>=15){p=m.a
o=A.j8(p,r,b,l)
if(o!=null){if(!p)return o
if(o.indexOf("\ufffd")<0)return o}}o=m.ab(r,b,l,!0)
p=m.b
if((p&1)!==0){n=A.ja(p)
m.b=0
throw A.a(A.z(n,a,q+m.c))}return o},
ab(a,b,c,d){var s,r,q=this
if(c-b>1000){s=B.b.aj(b+c,2)
r=q.ab(a,b,s,!1)
if((q.b&1)!==0)return r
return r+q.ab(a,s,c,d)}return q.bO(a,b,c,d)},
bO(a,b,c,d){var s,r,q,p,o,n,m,l=this,k=65533,j=l.b,i=l.c,h=new A.B(""),g=b+1,f=a[b]
A:for(s=l.a;;){for(;;g=p){r="AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAFFFFFFFFFFFFFFFFGGGGGGGGGGGGGGGGHHHHHHHHHHHHHHHHHHHHHHHHHHHIHHHJEEBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBKCCCCCCCCCCCCDCLONNNMEEEEEEEEEEE".charCodeAt(f)&31
i=j<=32?f&61694>>>r:(f&63|i<<6)>>>0
j=" \x000:XECCCCCN:lDb \x000:XECCCCCNvlDb \x000:XECCCCCN:lDb AAAAA\x00\x00\x00\x00\x00AAAAA00000AAAAA:::::AAAAAGG000AAAAA00KKKAAAAAG::::AAAAA:IIIIAAAAA000\x800AAAAA\x00\x00\x00\x00 AAAAA".charCodeAt(j+r)
if(j===0){q=A.a7(i)
h.a+=q
if(g===c)break A
break}else if((j&1)!==0){if(s)switch(j){case 69:case 67:q=A.a7(k)
h.a+=q
break
case 65:q=A.a7(k)
h.a+=q;--g
break
default:q=A.a7(k)
h.a=(h.a+=q)+q
break}else{l.b=j
l.c=g-1
return""}j=0}if(g===c)break A
p=g+1
f=a[g]}p=g+1
f=a[g]
if(f<128){for(;;){if(!(p<c)){o=c
break}n=p+1
f=a[p]
if(f>=128){o=n-1
p=n
break}p=n}if(o-g<20)for(m=g;m<o;++m){q=A.a7(a[m])
h.a+=q}else{q=A.fx(a,g,o)
h.a+=q}if(o===c)break A
g=p}else g=p}if(d&&j>32)if(s){s=A.a7(k)
h.a+=s}else{l.b=77
l.c=c
return""}l.b=j
l.c=i
s=h.a
return s.charCodeAt(0)==0?s:s}}
A.dM.prototype={
$2(a,b){var s,r
if(typeof b=="string")this.a.set(a,b)
else if(b==null)this.a.set(a,"")
else for(s=J.aQ(b),r=this.a;s.m();){b=s.gp()
if(typeof b=="string")r.append(a,b)
else if(b==null)r.append(a,"")
else A.fZ(b)}},
$S:7}
A.au.prototype={
G(a,b){if(b==null)return!1
return b instanceof A.au&&this.a===b.a},
gn(a){return B.b.gn(this.a)},
a3(a,b){return B.b.a3(this.a,b.a)},
h(a){var s,r,q,p=this.a,o=p%36e8,n=B.b.aj(o,6e7)
o%=6e7
s=n<10?"0":""
r=B.b.aj(o,1e6)
q=r<10?"0":""
return""+(p/36e8|0)+":"+s+n+":"+q+r+"."+B.a.bZ(B.b.h(o%1e6),6,"0")}}
A.d9.prototype={
h(a){return this.ad()}}
A.m.prototype={
gO(){return A.ii(this)}}
A.bG.prototype={
h(a){var s=this.a
if(s!=null)return"Assertion failed: "+A.cD(s)
return"Assertion failed"}}
A.X.prototype={}
A.I.prototype={
gaf(){return"Invalid argument"+(!this.a?"(s)":"")},
gae(){return""},
h(a){var s=this,r=s.c,q=r==null?"":" ("+r+")",p=s.d,o=p==null?"":": "+A.i(p),n=s.gaf()+q+o
if(!s.a)return n
return n+s.gae()+": "+A.cD(s.gaq())},
gaq(){return this.b}}
A.bc.prototype={
gaq(){return this.b},
gaf(){return"RangeError"},
gae(){var s,r=this.e,q=this.f
if(r==null)s=q!=null?": Not less than or equal to "+A.i(q):""
else if(q==null)s=": Not greater than or equal to "+A.i(r)
else if(q>r)s=": Not in inclusive range "+A.i(r)+".."+A.i(q)
else s=q<r?": Valid value range is empty":": Only valid value is "+A.i(r)
return s}}
A.bN.prototype={
gaq(){return this.b},
gaf(){return"RangeError"},
gae(){if(this.b<0)return": index must not be negative"
var s=this.f
if(s===0)return": no indices are valid"
return": index should be less than "+s},
gl(a){return this.f}}
A.bh.prototype={
h(a){return"Unsupported operation: "+this.a}}
A.c8.prototype={
h(a){return"UnimplementedError: "+this.a}}
A.bg.prototype={
h(a){return"Bad state: "+this.a}}
A.bL.prototype={
h(a){var s=this.a
if(s==null)return"Concurrent modification during iteration."
return"Concurrent modification during iteration: "+A.cD(s)+"."}}
A.c3.prototype={
h(a){return"Out of Memory"},
gO(){return null},
$im:1}
A.bf.prototype={
h(a){return"Stack Overflow"},
gO(){return null},
$im:1}
A.da.prototype={
h(a){return"Exception: "+this.a}}
A.R.prototype={
h(a){var s,r,q,p,o,n,m,l,k,j,i,h=this.a,g=""!==h?"FormatException: "+h:"FormatException",f=this.c,e=this.b
if(typeof e=="string"){if(f!=null)s=f<0||f>e.length
else s=!1
if(s)f=null
if(f==null){if(e.length>78)e=B.a.i(e,0,75)+"..."
return g+"\n"+e}for(r=1,q=0,p=!1,o=0;o<f;++o){n=e.charCodeAt(o)
if(n===10){if(q!==o||!p)++r
q=o+1
p=!1}else if(n===13){++r
q=o+1
p=!0}}g=r>1?g+(" (at line "+r+", character "+(f-q+1)+")\n"):g+(" (at character "+(f+1)+")\n")
m=e.length
for(o=f;o<m;++o){n=e.charCodeAt(o)
if(n===10||n===13){m=o
break}}l=""
if(m-q>78){k="..."
if(f-q<75){j=q+75
i=q}else{if(m-f<75){i=m-75
j=m
k=""}else{i=f-36
j=f+36}l="..."}}else{j=m
i=q
k=""}return g+l+B.a.i(e,i,j)+k+"\n"+B.a.aA(" ",f-i+l.length)+"^\n"}else return f!=null?g+(" (at offset "+A.i(f)+")"):g}}
A.o.prototype={
a1(a,b){return A.hS(this,A.a0(this).j("o.E"),b)},
gl(a){var s,r=this.gB(this)
for(s=0;r.m();)++s
return s},
E(a,b){var s,r
A.ey(b,"index")
s=this.gB(this)
for(r=b;s.m();){if(r===0)return s.gp();--r}throw A.a(A.er(b,b-r,this,"index"))},
h(a){return A.i6(this,"(",")")}}
A.t.prototype={
gn(a){return A.k.prototype.gn.call(this,0)},
h(a){return"null"}}
A.k.prototype={$ik:1,
G(a,b){return this===b},
gn(a){return A.c5(this)},
h(a){return"Instance of '"+A.c6(this)+"'"},
gt(a){return A.kg(this)},
toString(){return this.h(this)}}
A.cs.prototype={
h(a){return""},
$ia8:1}
A.B.prototype={
gl(a){return this.a.length},
h(a){var s=this.a
return s.charCodeAt(0)==0?s:s}}
A.d0.prototype={
$2(a,b){var s,r,q,p=B.a.b2(b,"=")
if(p===-1){if(b!=="")a.q(0,A.eL(b,0,b.length,this.a,!0),"")}else if(p!==0){s=B.a.i(b,0,p)
r=B.a.K(b,p+1)
q=this.a
a.q(0,A.eL(s,0,s.length,q,!0),A.eL(r,0,r.length,q,!0))}return a},
$S:14}
A.d_.prototype={
$2(a,b){throw A.a(A.z("Illegal IPv6 address, "+a,this.a,b))},
$S:15}
A.by.prototype={
ga_(){var s,r,q,p,o=this,n=o.w
if(n===$){s=o.a
r=s.length!==0?s+":":""
q=o.c
p=q==null
if(!p||s==="file"){s=r+"//"
r=o.b
if(r.length!==0)s=s+r+"@"
if(!p)s+=q
r=o.d
if(r!=null)s=s+":"+A.i(r)}else s=r
s+=o.e
r=o.f
if(r!=null)s=s+"?"+r
r=o.r
if(r!=null)s=s+"#"+r
n=o.w=s.charCodeAt(0)==0?s:s}return n},
gn(a){var s,r=this,q=r.y
if(q===$){s=B.a.gn(r.ga_())
r.y!==$&&A.bF()
r.y=s
q=s}return q},
gF(){var s,r=this,q=r.z
if(q===$){s=r.f
s=A.fD(s==null?"":s)
r.z!==$&&A.bF()
q=r.z=new A.aB(s,t.h)}return q},
gbc(){return this.b},
gap(){var s=this.c
if(s==null)return""
if(B.a.A(s,"[")&&!B.a.u(s,"v",1))return B.a.i(s,1,s.length-1)
return s},
ga5(){var s=this.d
return s==null?A.fO(this.a):s},
gau(){var s=this.f
return s==null?"":s},
gaV(){var s=this.r
return s==null?"":s},
av(a){var s,r,q,p,o=this,n=o.a,m=n==="file",l=o.b,k=o.d,j=o.c
if(!(j!=null))j=l.length!==0||k!=null||m?"":null
s=o.e
if(!m)r=j!=null&&s.length!==0
else r=!0
if(r&&!B.a.A(s,"/"))s="/"+s
q=s
p=A.eJ(null,0,0,a)
return A.eH(n,l,j,k,q,p,o.r)},
gb5(){if(this.a!==""){var s=this.r
s=(s==null?"":s)===""}else s=!1
return s},
gaY(){return this.c!=null},
gb0(){return this.f!=null},
gaZ(){return this.r!=null},
h(a){return this.ga_()},
G(a,b){var s,r,q,p=this
if(b==null)return!1
if(p===b)return!0
s=!1
if(t.R.b(b))if(p.a===b.ga7())if(p.c!=null===b.gaY())if(p.b===b.gbc())if(p.gap()===b.gap())if(p.ga5()===b.ga5())if(p.e===b.gJ()){r=p.f
q=r==null
if(!q===b.gb0()){if(q)r=""
if(r===b.gau()){r=p.r
q=r==null
if(!q===b.gaZ()){s=q?"":r
s=s===b.gaV()}}}}return s},
$icb:1,
ga7(){return this.a},
gJ(){return this.e}}
A.dL.prototype={
$2(a,b){var s=this.b,r=this.a
s.a+=r.a
r.a="&"
r=A.eM(1,a,B.e,!0)
r=s.a+=r
if(b!=null&&b.length!==0){s.a=r+"="
r=A.eM(1,b,B.e,!0)
s.a+=r}},
$S:16}
A.dK.prototype={
$2(a,b){var s,r
if(b==null||typeof b=="string")this.a.$2(a,b)
else for(s=J.aQ(b),r=this.a;s.m();)r.$2(a,s.gp())},
$S:7}
A.cZ.prototype={
gbb(){var s,r,q,p,o=this,n=null,m=o.c
if(m==null){m=o.a
s=o.b[0]+1
r=B.a.a4(m,"?",s)
q=m.length
if(r>=0){p=A.bz(m,r+1,q,256,!1,!1)
q=r}else p=n
m=o.c=new A.cg("data","",n,n,A.bz(m,s,q,128,!1,!1),p,n)}return m},
h(a){var s=this.a
return this.b[0]===-1?"data:"+s:s}}
A.cq.prototype={
gaY(){return this.c>0},
gb_(){return this.c>0&&this.d+1<this.e},
gb0(){return this.f<this.r},
gaZ(){return this.r<this.a.length},
gb5(){return this.b>0&&this.r>=this.a.length},
ga7(){var s=this.w
return s==null?this.w=this.bp():s},
bp(){var s,r=this,q=r.b
if(q<=0)return""
s=q===4
if(s&&B.a.A(r.a,"http"))return"http"
if(q===5&&B.a.A(r.a,"https"))return"https"
if(s&&B.a.A(r.a,"file"))return"file"
if(q===7&&B.a.A(r.a,"package"))return"package"
return B.a.i(r.a,0,q)},
gbc(){var s=this.c,r=this.b+3
return s>r?B.a.i(this.a,r,s-1):""},
gap(){var s=this.c
return s>0?B.a.i(this.a,s,this.d):""},
ga5(){var s,r=this
if(r.gb_())return A.kp(B.a.i(r.a,r.d+1,r.e))
s=r.b
if(s===4&&B.a.A(r.a,"http"))return 80
if(s===5&&B.a.A(r.a,"https"))return 443
return 0},
gJ(){return B.a.i(this.a,this.e,this.f)},
gau(){var s=this.f,r=this.r
return s<r?B.a.i(this.a,s+1,r):""},
gaV(){var s=this.r,r=this.a
return s<r.length?B.a.K(r,s+1):""},
gF(){if(this.f>=this.r)return B.a7
return new A.aB(A.fD(this.gau()),t.h)},
av(a){var s,r,q,p,o,n=this,m=null,l=n.ga7(),k=l==="file",j=n.c,i=j>0?B.a.i(n.a,n.b+3,j):"",h=n.gb_()?n.ga5():m
j=n.c
if(j>0)s=B.a.i(n.a,j,n.d)
else s=i.length!==0||h!=null||k?"":m
j=n.a
r=B.a.i(j,n.e,n.f)
if(!k)q=s!=null&&r.length!==0
else q=!0
if(q&&!B.a.A(r,"/"))r="/"+r
p=A.eJ(m,0,0,a)
q=n.r
o=q<j.length?B.a.K(j,q+1):m
return A.eH(l,i,s,h,r,p,o)},
gn(a){var s=this.x
return s==null?this.x=B.a.gn(this.a):s},
G(a,b){if(b==null)return!1
if(this===b)return!0
return t.R.b(b)&&this.a===b.h(0)},
h(a){return this.a},
$icb:1}
A.cg.prototype={}
A.cS.prototype={
h(a){return"Promise was rejected with a value of `"+(this.a?"undefined":"null")+"`."}}
A.ek.prototype={
$1(a){return this.a.am(a)},
$S:4}
A.el.prototype={
$1(a){if(a==null)return this.a.aT(new A.cS(a===undefined))
return this.a.aT(a)},
$S:4}
A.n.prototype={
ad(){return"Kind."+this.b},
h(a){var s
switch(this.a){case 0:s="accessor"
break
case 1:s="constant"
break
case 2:s="constructor"
break
case 3:s="class"
break
case 4:s="dynamic"
break
case 5:s="enum"
break
case 6:s="extension"
break
case 7:s="extension type"
break
case 8:s="function"
break
case 9:s="library"
break
case 10:s="method"
break
case 11:s="mixin"
break
case 12:s="Never"
break
case 13:s="package"
break
case 14:s="parameter"
break
case 15:s="prefix"
break
case 16:s="property"
break
case 17:s="SDK"
break
case 18:s="topic"
break
case 19:s="top-level constant"
break
case 20:s="top-level property"
break
case 21:s="typedef"
break
case 22:s="type parameter"
break
default:s=null}return s}}
A.C.prototype={
ad(){return"_MatchPosition."+this.b}}
A.cG.prototype={
aU(a){var s,r,q,p,o,n,m,l,k,j,i
if(a.length===0)return A.l([],t.M)
s=a.toLowerCase()
r=A.l([],t.r)
for(q=this.a,p=q.length,o=s.length>1,n="dart:"+s,m=0;m<q.length;q.length===p||(0,A.a1)(q),++m){l=q[m]
k=new A.cJ(r,l)
j=l.a.toLowerCase()
i=l.b.toLowerCase()
if(j===s||i===s||j===n)k.$1(B.ao)
else if(o)if(B.a.A(j,s)||B.a.A(i,s))k.$1(B.ap)
else if(B.a.H(j,s)||B.a.H(i,s))k.$1(B.aq)}B.c.bh(r,new A.cH())
q=t.V
q=A.cP(new A.aj(r,new A.cI(),q),q.j("L.E"))
return q}}
A.cJ.prototype={
$1(a){this.a.push(new A.cp(this.b,a))},
$S:17}
A.cH.prototype={
$2(a,b){var s,r,q=a.b.a-b.b.a
if(q!==0)return q
s=a.a
r=b.a
q=s.c-r.c
if(q!==0)return q
q=s.gaN()-r.gaN()
if(q!==0)return q
q=s.f-r.f
if(q!==0)return q
return s.a.length-r.a.length},
$S:18}
A.cI.prototype={
$1(a){return a.a},
$S:19}
A.y.prototype={
gaN(){var s=0
switch(this.d.a){case 3:break
case 5:break
case 6:break
case 7:break
case 11:break
case 19:break
case 20:break
case 21:break
case 0:s=1
break
case 1:s=1
break
case 2:s=1
break
case 8:s=1
break
case 10:s=1
break
case 16:s=1
break
case 9:s=2
break
case 13:s=2
break
case 18:s=2
break
case 4:s=3
break
case 12:s=3
break
case 14:s=3
break
case 15:s=3
break
case 17:s=3
break
case 22:s=3
break
default:s=null}return s}}
A.cB.prototype={}
A.ee.prototype={
$1(a){var s,r,q,p,o,n,m=this,l=m.b.querySelector("code"),k=l==null?null:l.textContent
if(k==null)k=""
s=v.G
s.window.navigator.clipboard.writeText(k)
r=m.c
r.textContent="check"
q=m.d
q.classList.add("copied")
p=m.a
o=p.a
if(o!=null)s.window.clearTimeout(o)
s=s.window
q=new A.ed(p,r,q)
if(typeof q=="function")A.as(A.U("Attempting to rewrap a JS function.",null))
n=function(b,c){return function(){return b(c)}}(A.jl,q)
n[$.em()]=q
p.a=s.setTimeout(n,2000)},
$S:1}
A.ed.prototype={
$0(){this.b.textContent="content_copy"
this.c.classList.remove("copied")
this.a.a=null},
$S:3}
A.aF.prototype={
ad(){return"_LoadState."+this.b}}
A.dT.prototype={
$0(){$.aH=null
var s=v.G.document.getElementById("dartdoc-search-status")
if(t.m.b(s))s.textContent=this.a},
$S:0}
A.e3.prototype={
$1(a){return J.u(v.G.document.activeElement,a)||J.a3(a.value)!==0},
$S:33}
A.aE.prototype={}
A.dl.prototype={
$0(){var s=A.eq()
s.classList.add("tt-search-spinner")
s.setAttribute("aria-hidden","true")
return s},
$S:8}
A.dm.prototype={
$0(){var s=A.K()
s.classList.add("tt-menu")
s.classList.add("tt-search-status")
s.setAttribute("aria-hidden","true")
s.style.display="none"
return s},
$S:8}
A.dn.prototype={
$1(a){var s
a.preventDefault()
if(!this.a.$0()){s=this.b.value
this.c.$1(A.bB()+"search.html?q="+A.eM(1,s,B.e,!0))}},
$S:1}
A.cm.prototype={
gV(){var s,r,q,p,o,n=this,m=n.e
if(m===$){s=A.l([],t.W)
for(r=n.a,q=r.length,p=n.d,o=0;o<r.length;r.length===q||(0,A.a1)(r),++o)s.push(A.iB(r[o],new A.dx(n),p))
n.e!==$&&A.bF()
n.e=s
m=s}return m},
bM(){var s,r,q,p,o=this
if(o.b.length!==0){s=A.D(o.gbw())
$.eZ=s
v.G.document.addEventListener("keydown",s)}for(r=o.gV(),q=r.length,p=0;p<r.length;r.length===q||(0,A.a1)(r),++p)o.bm(r[p])
if(A.he(A.al(J.T(v.G.window.location),0,null),o.a))o.ac()},
bm(a){var s=this,r=a.a
r.addEventListener("focus",A.D(new A.dq(s)))
r.addEventListener("input",A.D(new A.dr(s)))
r.addEventListener("blur",A.D(new A.ds(s)))
r.addEventListener("keydown",A.D(new A.dt(s,a)))},
aK(){var s=this.f
if(s===B.k||s===B.m)this.ac()
else if(s===B.l)this.S()},
bx(a){var s,r
if(!J.u(a.key,"/"))return
s=v.G.document.activeElement
if(s!=null&&B.aa.H(0,s.nodeName.toLowerCase()))return
a.preventDefault()
r=A.hd(this.b)
if(r!=null)r.focus()
r=this.f
if(r===B.k||r===B.m)this.ac()},
ac(){var s=this
if(s.f===B.f)return
if(s.r==null)s.r=s.X()},
X(){return this.bA()},
bA(){var s=0,r=A.eX(t.n),q,p=2,o=[],n=[],m=this,l,k,j,i,h,g,f,e,d,c
var $async$X=A.f1(function(a,b){if(a===1){o.push(b)
s=p}for(;;)switch(s){case 0:d={}
m.f=B.l
m.S()
i=A.al(J.T(v.G.window.location),0,null)
if(B.a.U(i.gJ(),"search.html")&&i.gF().v("q"))m.aM("Loading search index\u2026")
h=d.a=!1
l=A.fy(B.F,new A.dv(d,m))
k=null
p=4
s=7
return A.dU(m.c.$0(),$async$X)
case 7:j=b
if(j!=null){g=J.hM(t.j.a(B.B.bN(j,null)),t.a)
f=g.$ti.j("aj<e.E,y>")
f=A.cP(new A.aj(g,A.kw(),f),f.j("L.E"))
k=new A.cG(f)}n.push(6)
s=5
break
case 4:p=3
c=o.pop()
k=null
n.push(6)
s=5
break
case 3:n=[2]
case 5:p=2
l.a0()
m.r=null
s=n.pop()
break
case 6:if(k==null){A.ku("Could not activate search functionality.")
m.f=B.m
m.S()
if(B.a.U(i.gJ(),"search.html")?i.gF().v("q"):h)m.aM("Failed to load search index.")
A.cu("Failed to load search index.")
s=1
break}m.bv(k,d.a)
case 1:return A.eR(q,r)
case 2:return A.eQ(o.at(-1),r)}})
return A.eS($async$X,r)},
bv(a2,a3){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0=this,a1="search.html"
a0.f=B.f
a0.S()
s=v.G
r=A.al(J.T(s.window.location),0,null)
q=r.gF().k(0,"search")
if(q!=null){p=A.es(a2.aU(q))
o=p==null?null:p.e
if(o!=null){a0.d.$1(A.bB()+o)
return}}for(p=a0.gV(),n=p.length,m=a0.d,l=t.O,k=t.M,j=0;j<p.length;p.length===n||(0,A.a1)(p),++j){i=p[j]
h=A.l([],l)
g=A.l([],k)
f=A.al(s.window.location.href,0,null)
g=new A.dB(a2,f,m,h,g)
h=i.a
h.disabled=!1
h.setAttribute("placeholder","Search API Docs")
h.setAttribute("autocomplete","off")
h.setAttribute("spellcheck","false")
h.classList.add("tt-input")
e=A.h0(h)
d=e.querySelector('.tt-menu[role="listbox"]')
if(d!=null)d.remove()
d=g.gM()
e.appendChild(d)
g.be(h)
if(B.a.U(f.gJ(),a1)&&f.gF().v("q")){c=f.gF().k(0,"q")
b=c!=null
if(b){a=B.n.aH(c,0,c.length)
c=a==null?c:a
$.f0=$.aK
g.bV(c,!0)
g.bg(c)
d.style.display="none"
d.setAttribute("aria-expanded","false")
$.f0=10}}else b=!1
if(!b&&J.a3(h.value)!==0&&J.u(s.document.activeElement,h))g.aX(h.value,!0)}if(B.a.U(r.gJ(),a1)&&r.gF().v("q")||B.c.al(p,new A.du()))A.cu(A.h8($.aK))
else if(a3)A.cu("Search index ready.")},
S(){var s=this
switch(s.f.a){case 0:return
case 1:s.bI()
break
case 2:s.bG()
break
case 3:s.bH()
break}},
bI(){var s,r,q,p,o,n,m,l,k,j,i=A.hd(this.b)
if(i==null)i=A.es(this.a)
s=this.gV()
r=B.c.al(s,new A.dw())
for(q=s.length,p=v.G,o=0;o<s.length;s.length===q||(0,A.a1)(s),++o){n=s[o]
m=n.a
l=J.u(p.document.activeElement,m)
if(r)k=l||J.a3(m.value)!==0
else k=m===i
m.setAttribute("aria-busy","true")
m.placeholder="Search API Docs"
n.b.classList.toggle("is-loading",k)
m=l&&J.hP(m.value).length!==0
j=n.c
if(m){j.textContent="Loading search index\u2026"
j.classList.remove("is-error")
j.style.display="block"}else j.style.display="none"}},
bG(){var s,r,q,p,o,n,m
for(s=this.gV(),r=s.length,q=v.G,p=0;p<s.length;s.length===r||(0,A.a1)(s),++p){o=s[p]
n=o.a
n.removeAttribute("aria-busy")
n.placeholder="Failed to initialize search"
o.b.classList.remove("is-loading")
m=o.c
if(J.u(q.document.activeElement,n)){m.textContent="Failed to load search index. Type or refocus to retry."
m.classList.add("is-error")
m.style.display="block"}else m.style.display="none"}},
bH(){var s,r,q,p,o
for(s=this.gV(),r=s.length,q=0;q<s.length;s.length===r||(0,A.a1)(s),++q){p=s[q]
o=p.a
o.removeAttribute("aria-busy")
o.placeholder="Search API Docs"
p.b.classList.remove("is-loading")
o=p.c
o.textContent=""
o.classList.remove("is-error")
o.style.display="none"}},
aM(a){var s,r=v.G.document.getElementById("dartdoc-main-content")
if(r==null)return
r.textContent=""
s=A.fi()
s.classList.add("search-summary")
r.appendChild(s)
s=A.fj()
s.textContent="Search Results"
r.appendChild(s)
s=A.K()
s.classList.add("search-summary")
s.textContent=a
r.appendChild(s)}}
A.dx.prototype={
$0(){return this.a.f===B.f},
$S:24}
A.dq.prototype={
$1(a){this.a.aK()},
$S:1}
A.dr.prototype={
$1(a){this.a.aK()},
$S:1}
A.ds.prototype={
$1(a){var s=this.a
if(s.f!==B.f)s.S()},
$S:1}
A.dt.prototype={
$1(a){if(this.a.f!==B.f&&J.u(a.type,"keydown")&&J.u(a.code,"Escape"))this.b.c.style.display="none"},
$S:1}
A.dv.prototype={
$0(){if(this.b.f===B.l){this.a.a=!0
A.cu("Loading search index\u2026")}},
$S:0}
A.du.prototype={
$1(a){var s=a.a
return J.u(v.G.document.activeElement,s)&&J.a3(s.value)!==0},
$S:9}
A.dw.prototype={
$1(a){var s=a.a
return J.u(v.G.document.activeElement,s)||J.a3(s.value)!==0},
$S:9}
A.dB.prototype={
gM(){var s,r=this,q=r.d
if(q===$){s=A.K()
s.setAttribute("role","listbox")
s.setAttribute("aria-expanded","false")
s.style.display="none"
s.classList.add("tt-menu")
s.appendChild(r.gb8())
s.appendChild(r.gaB())
r.d!==$&&A.bF()
r.d=s
q=s}return q},
gb8(){var s,r=this.e
if(r===$){s=A.K()
s.classList.add("enter-search-message")
this.e!==$&&A.bF()
this.e=s
r=s}return r},
gaB(){var s,r=this.f
if(r===$){s=A.K()
s.classList.add("tt-search-results")
this.f!==$&&A.bF()
this.f=s
r=s}return r},
bg(a){var s,r,q,p,o=v.G.document.getElementById("dartdoc-main-content")
if(o==null)return
o.textContent=""
s=A.fi()
s.classList.add("search-summary")
o.appendChild(s)
s=A.fj()
s.innerHTML="Search Results"
o.appendChild(s)
s=A.K()
s.classList.add("search-summary")
s.innerHTML=""+$.aK+' results for "'+a+'"'
o.appendChild(s)
if($.ac.a!==0)for(s=new A.b3($.ac,$.ac.r,$.ac.e);s.m();)o.appendChild(s.d)
else{r=A.K()
r.classList.add("search-summary")
r.innerHTML='There was not a match for "'+a+'". Want to try searching from additional Dart-related sites? '
q=A.al("https://dart.dev/search?cx=011220921317074318178%3A_yy-tmb5t_i&ie=UTF-8&hl=en&q=",0,null).av(A.fo(["q",a],t.N,t.z))
p=A.ep()
p.setAttribute("href",q.ga_())
p.textContent="Search on dart.dev."
r.appendChild(p)
o.appendChild(r)}},
b1(){var s=this.gM()
s.style.display="none"
s.setAttribute("aria-expanded","false")
return s},
ba(a,b,c){var s,r,q,p,o,n=this
n.y=A.l([],t.M)
s=n.x
B.c.a2(s)
$.ac.a2(0)
r=n.gaB()
r.textContent=""
q=b.length
if(q===0){n.b1()
return}for(p=n.c,o=0;o<b.length;b.length===q||(0,A.a1)(b),++o)s.push(A.jo(a,b[o],p))
for(q=J.aQ(c?new A.b4($.ac,A.a0($.ac).j("b4<2>")):s);q.m();)r.appendChild(q.gp())
n.y=b
n.z=-1
if(r.hasChildNodes()){r=n.gM()
r.style.display="block"
r.setAttribute("aria-expanded","true")}r=$.aK
r=r>10?'Press "Enter" key to see all '+r+" results":""
n.gb8().textContent=r},
c9(a,b){return this.ba(a,b,!1)},
ao(a,b,c){var s,r,q,p=this
if(p.w===a&&!b)return
if(a.length===0){p.w=""
$.aK=0
p.c9("",A.l([],t.M))
if(!c&&!b)A.cu("")
return}s=p.a.aU(a)
r=s.length
$.aK=r
q=$.f0
if(r>q)s=B.c.bi(s,0,q)
p.w=a
p.ba(a,s,c)
if(!c&&!b)A.jb(A.h8($.aK))},
bV(a,b){return this.ao(a,!1,b)},
aX(a,b){return this.ao(a,b,!1)},
aW(a){return this.ao(a,!1,!1)},
aS(a){var s,r=this
r.z=-1
s=r.r
if(s!=null){a.value=s
r.r=null}r.b1()},
be(a){var s=this
a.addEventListener("focus",A.D(new A.dC(s,a)))
a.addEventListener("blur",A.D(new A.dD(s,a)))
a.addEventListener("input",A.D(new A.dE(s,a)))
a.addEventListener("keydown",A.D(new A.dF(s,a)))}}
A.dC.prototype={
$1(a){this.a.aX(this.b.value,!0)},
$S:1}
A.dD.prototype={
$1(a){this.a.aS(this.b)},
$S:1}
A.dE.prototype={
$1(a){this.a.aW(this.b.value)},
$S:1}
A.dF.prototype={
$1(a){var s,r,q,p,o,n,m,l,k,j,i,h,g,f=this
if(!J.u(a.type,"keydown"))return
if(J.u(a.code,"Enter")){a.preventDefault()
s=f.a
r=s.z
if(r!==-1){q=s.x[r].getAttribute("data-href")
if(q!=null)s.c.$1(A.bB()+q)
return}else{p=B.n.T(s.w)
s.c.$1(A.al(A.bB()+"search.html",0,null).av(A.fo(["q",p],t.N,t.z)).ga_())
return}}s=f.a
r=s.x
o=r.length-1
n=s.z
if(J.u(a.code,"ArrowUp")){m=s.z
if(m===-1)s.z=o
else s.z=m-1}else if(J.u(a.code,"ArrowDown")){m=s.z
if(m===o)s.z=-1
else s.z=m+1}else if(J.u(a.code,"Escape"))s.aS(f.b)
else{if(s.r!=null){s.r=null
s.aW(f.b.value)}return}m=n!==-1
if(m)r[n].classList.remove("tt-cursor")
l=s.z
if(l!==-1){k=r[l]
k.classList.add("tt-cursor")
r=s.z
if(r===0)s.gM().scrollTop=0
else if(r===o){r=s.gM()
r.scrollTop=r.scrollHeight}else{j=k.offsetTop
i=s.gM().offsetHeight
if(j<i||i<j+k.offsetHeight)k.scrollIntoView()}if(s.r==null)s.r=f.b.value
f.b.value=s.y[s.z].a}else{h=s.r
if(h!=null){r=m
g=h}else{g=null
r=!1}if(r){f.b.value=g
s.r=null}}a.preventDefault()},
$S:1}
A.dY.prototype={
$1(a){a.preventDefault()},
$S:1}
A.dZ.prototype={
$1(a){var s=this.a.e
if(s!=null){this.b.$1(A.bB()+s)
a.preventDefault()}},
$S:1}
A.e_.prototype={
$1(a){return"<strong class='tt-highlight'>"+A.i(a.k(0,0))+"</strong>"},
$S:26}
A.e0.prototype={
$1(a){var s=this.a
if(s!=null)s.classList.toggle("active")
s=this.b
if(s!=null)s.classList.toggle("active")},
$S:1}
A.e1.prototype={
$1(a){return this.bd(a)},
bd(a){var s=0,r=A.eX(t.P),q,p=this,o,n,m
var $async$$1=A.f1(function(b,c){if(b===1)return A.eQ(c,r)
for(;;)switch(s){case 0:if(!J.u(a.status,200)){o=A.ep()
o.href="https://dart.dev/tools/dart-doc#troubleshoot"
o.text="Failed to load sidebar. Visit dart.dev for help troubleshooting."
p.a.appendChild(o)
s=1
break}s=3
return A.dU(A.ej(a.text(),t.N),$async$$1)
case 3:n=c
m=A.K()
m.innerHTML=n
A.hg(p.b,m)
p.a.appendChild(m)
case 1:return A.eR(q,r)}})
return A.eS($async$$1,r)},
$S:27}
A.eg.prototype={
$1(a){var s=this.a,r=v.G
if(a){s.classList.remove("light-theme")
s.classList.add("dark-theme")
r.window.localStorage.setItem("colorTheme","true")}else{s.classList.remove("dark-theme")
s.classList.add("light-theme")
r.window.localStorage.setItem("colorTheme","false")}},
$S:28}
A.ef.prototype={
$1(a){this.b.$1(!this.a.classList.contains("dark-theme"))},
$S:1};(function aliases(){var s=J.a6.prototype
s.bj=s.h})();(function installTearOffs(){var s=hunkHelpers._static_2,r=hunkHelpers._static_1,q=hunkHelpers._static_0,p=hunkHelpers._instance_1u
s(J,"jE","ia",29)
r(A,"k6","iy",2)
r(A,"k7","iz",2)
r(A,"k8","iA",2)
q(A,"hi","k0",0)
r(A,"kw","i2",31)
r(A,"ky","jp",32)
q(A,"kx","cv",21)
p(A.cm.prototype,"gbw","bx",23)})();(function inheritance(){var s=hunkHelpers.mixin,r=hunkHelpers.inherit,q=hunkHelpers.inheritMany
r(A.k,null)
q(A.k,[A.eu,J.bO,A.be,J.Q,A.o,A.bI,A.m,A.e,A.cU,A.av,A.c2,A.aX,A.ca,A.bq,A.aS,A.cl,A.az,A.cX,A.cT,A.aW,A.br,A.af,A.W,A.cO,A.bU,A.b3,A.cK,A.cn,A.d4,A.M,A.ci,A.dI,A.dG,A.cd,A.J,A.cf,A.aC,A.x,A.ce,A.cr,A.dS,A.ct,A.b5,A.bK,A.bM,A.cF,A.dQ,A.dN,A.au,A.d9,A.c3,A.bf,A.da,A.R,A.t,A.cs,A.B,A.by,A.cZ,A.cq,A.cS,A.cG,A.y,A.cB,A.aE,A.cm,A.dB])
q(J.bO,[J.bQ,J.aZ,J.b1,J.b0,J.b2,J.b_,J.a4])
q(J.b1,[J.a6,J.p,A.aw,A.b8])
q(J.a6,[J.c4,J.ak,J.a5])
r(J.bP,A.be)
r(J.cL,J.p)
q(J.b_,[J.aY,J.bR])
q(A.o,[A.aa,A.c,A.ay])
q(A.aa,[A.ae,A.bA])
r(A.bl,A.ae)
r(A.bk,A.bA)
r(A.V,A.bk)
q(A.m,[A.bT,A.X,A.bS,A.c9,A.c7,A.ch,A.bG,A.I,A.bh,A.c8,A.bg,A.bL])
r(A.aA,A.e)
r(A.bJ,A.aA)
q(A.c,[A.L,A.ai,A.b4])
q(A.L,[A.aj,A.ck])
r(A.co,A.bq)
r(A.cp,A.co)
r(A.aU,A.aS)
r(A.aT,A.az)
r(A.aV,A.aT)
r(A.bb,A.X)
q(A.af,[A.cz,A.cA,A.cW,A.ea,A.ec,A.d6,A.d5,A.dV,A.dj,A.ek,A.el,A.cJ,A.cI,A.ee,A.e3,A.dn,A.dq,A.dr,A.ds,A.dt,A.du,A.dw,A.dC,A.dD,A.dE,A.dF,A.dY,A.dZ,A.e_,A.e0,A.e1,A.eg,A.ef])
q(A.cW,[A.cV,A.aR])
q(A.W,[A.ah,A.cj])
q(A.cA,[A.eb,A.dW,A.e4,A.dk,A.cQ,A.dM,A.d0,A.d_,A.dL,A.dK,A.cH])
q(A.b8,[A.bV,A.ax])
q(A.ax,[A.bm,A.bo])
r(A.bn,A.bm)
r(A.b6,A.bn)
r(A.bp,A.bo)
r(A.b7,A.bp)
q(A.b6,[A.bW,A.bX])
q(A.b7,[A.bY,A.bZ,A.c_,A.c0,A.c1,A.b9,A.ba])
r(A.bs,A.ch)
q(A.cz,[A.d7,A.d8,A.dH,A.db,A.df,A.de,A.dd,A.dc,A.di,A.dh,A.dg,A.dA,A.e2,A.dP,A.dO,A.ed,A.dT,A.dl,A.dm,A.dx,A.dv])
r(A.bj,A.cf)
r(A.dz,A.dS)
r(A.bx,A.b5)
r(A.aB,A.bx)
q(A.bK,[A.cx,A.cC,A.cM])
q(A.bM,[A.cy,A.cE,A.cN,A.d3,A.d2])
r(A.d1,A.cC)
q(A.I,[A.bc,A.bN])
r(A.cg,A.by)
q(A.d9,[A.n,A.C,A.aF])
s(A.aA,A.ca)
s(A.bA,A.e)
s(A.bm,A.e)
s(A.bn,A.aX)
s(A.bo,A.e)
s(A.bp,A.aX)
s(A.bx,A.ct)})()
var v={G:typeof self!="undefined"?self:globalThis,typeUniverse:{eC:new Map(),tR:{},eT:{},tPV:{},sEA:[]},mangledGlobalNames:{b:"int",r:"double",hm:"num",d:"String",N:"bool",t:"Null",f:"List",k:"Object",A:"Map",h:"JSObject"},mangledNames:{},types:["~()","t(h)","~(~())","t()","~(@)","t(@)","@()","~(d,@)","h()","N(aE)","~(k?,k?)","@(@)","@(d)","@(@,d)","A<d,d>(A<d,d>,d)","0&(d,b?)","~(d,d?)","~(C)","b(+item,matchPosition(y,C),+item,matchPosition(y,C))","y(+item,matchPosition(y,C))","t(~())","S<d?>()","t(@,a8)","~(h)","N()","~(b,@)","d(cR)","S<t>(h)","~(N)","b(@,@)","t(k,a8)","y(A<d,@>)","~(d)","N(h)"],interceptorsByTag:null,leafTags:null,arrayRti:Symbol("$ti"),rttc:{"2;item,matchPosition":(a,b)=>c=>c instanceof A.cp&&a.b(c.a)&&b.b(c.b)}}
A.iR(v.typeUniverse,JSON.parse('{"c4":"a6","ak":"a6","a5":"a6","kI":"aw","bQ":{"N":[],"j":[]},"aZ":{"t":[],"j":[]},"b1":{"h":[]},"a6":{"h":[]},"p":{"f":["1"],"c":["1"],"h":[]},"bP":{"be":[]},"cL":{"p":["1"],"f":["1"],"c":["1"],"h":[]},"b_":{"r":[]},"aY":{"r":[],"b":[],"j":[]},"bR":{"r":[],"j":[]},"a4":{"d":[],"j":[]},"aa":{"o":["2"]},"ae":{"aa":["1","2"],"o":["2"],"o.E":"2"},"bl":{"ae":["1","2"],"aa":["1","2"],"c":["2"],"o":["2"],"o.E":"2"},"bk":{"e":["2"],"f":["2"],"aa":["1","2"],"c":["2"],"o":["2"]},"V":{"bk":["1","2"],"e":["2"],"f":["2"],"aa":["1","2"],"c":["2"],"o":["2"],"e.E":"2","o.E":"2"},"bT":{"m":[]},"bJ":{"e":["b"],"f":["b"],"c":["b"],"e.E":"b"},"c":{"o":["1"]},"L":{"c":["1"],"o":["1"]},"aj":{"L":["2"],"c":["2"],"o":["2"],"o.E":"2","L.E":"2"},"ay":{"o":["1"],"o.E":"1"},"aA":{"e":["1"],"f":["1"],"c":["1"]},"aS":{"A":["1","2"]},"aU":{"A":["1","2"]},"aT":{"az":["1"],"c":["1"]},"aV":{"az":["1"],"c":["1"]},"bb":{"X":[],"m":[]},"bS":{"m":[]},"c9":{"m":[]},"br":{"a8":[]},"c7":{"m":[]},"ah":{"W":["1","2"],"A":["1","2"],"W.V":"2"},"ai":{"c":["1"],"o":["1"],"o.E":"1"},"b4":{"c":["1"],"o":["1"],"o.E":"1"},"cn":{"ez":[],"cR":[]},"aw":{"h":[],"j":[]},"b8":{"h":[]},"bV":{"h":[],"j":[]},"ax":{"E":["1"],"h":[]},"b6":{"e":["r"],"f":["r"],"E":["r"],"c":["r"],"h":[]},"b7":{"e":["b"],"f":["b"],"E":["b"],"c":["b"],"h":[]},"bW":{"e":["r"],"f":["r"],"E":["r"],"c":["r"],"h":[],"j":[],"e.E":"r"},"bX":{"e":["r"],"f":["r"],"E":["r"],"c":["r"],"h":[],"j":[],"e.E":"r"},"bY":{"e":["b"],"f":["b"],"E":["b"],"c":["b"],"h":[],"j":[],"e.E":"b"},"bZ":{"e":["b"],"f":["b"],"E":["b"],"c":["b"],"h":[],"j":[],"e.E":"b"},"c_":{"e":["b"],"f":["b"],"E":["b"],"c":["b"],"h":[],"j":[],"e.E":"b"},"c0":{"e":["b"],"f":["b"],"E":["b"],"c":["b"],"h":[],"j":[],"e.E":"b"},"c1":{"e":["b"],"f":["b"],"E":["b"],"c":["b"],"h":[],"j":[],"e.E":"b"},"b9":{"e":["b"],"f":["b"],"E":["b"],"c":["b"],"h":[],"j":[],"e.E":"b"},"ba":{"e":["b"],"f":["b"],"E":["b"],"c":["b"],"h":[],"j":[],"e.E":"b"},"ch":{"m":[]},"bs":{"X":[],"m":[]},"J":{"m":[]},"bj":{"cf":["1"]},"x":{"S":["1"]},"e":{"f":["1"],"c":["1"]},"W":{"A":["1","2"]},"b5":{"A":["1","2"]},"aB":{"A":["1","2"]},"az":{"c":["1"]},"cj":{"W":["d","@"],"A":["d","@"],"W.V":"@"},"ck":{"L":["d"],"c":["d"],"o":["d"],"o.E":"d","L.E":"d"},"f":{"c":["1"]},"ez":{"cR":[]},"bG":{"m":[]},"X":{"m":[]},"I":{"m":[]},"bc":{"m":[]},"bN":{"m":[]},"bh":{"m":[]},"c8":{"m":[]},"bg":{"m":[]},"bL":{"m":[]},"c3":{"m":[]},"bf":{"m":[]},"cs":{"a8":[]},"by":{"cb":[]},"cq":{"cb":[]},"cg":{"cb":[]},"i5":{"f":["b"],"c":["b"]},"is":{"f":["b"],"c":["b"]},"ir":{"f":["b"],"c":["b"]},"i3":{"f":["b"],"c":["b"]},"ip":{"f":["b"],"c":["b"]},"i4":{"f":["b"],"c":["b"]},"iq":{"f":["b"],"c":["b"]},"i0":{"f":["r"],"c":["r"]},"i1":{"f":["r"],"c":["r"]}}'))
A.iQ(v.typeUniverse,JSON.parse('{"c2":1,"aX":1,"ca":1,"aA":1,"bA":2,"aS":2,"aT":1,"bU":1,"b3":1,"ax":1,"cr":1,"ct":2,"b5":2,"bx":2,"bK":2,"bM":2}'))
var u={f:"\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\u03f6\x00\u0404\u03f4 \u03f4\u03f6\u01f6\u01f6\u03f6\u03fc\u01f4\u03ff\u03ff\u0584\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u05d4\u01f4\x00\u01f4\x00\u0504\u05c4\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u0400\x00\u0400\u0200\u03f7\u0200\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u0200\u0200\u0200\u03f7\x00",c:"Error handler must accept one Object or one Object and a StackTrace as arguments, and return a value of the returned future's type"}
var t=(function rtii(){var s=A.bE
return{U:s("c<@>"),C:s("m"),Z:s("kH"),M:s("p<y>"),O:s("p<h>"),f:s("p<k>"),r:s("p<+item,matchPosition(y,C)>"),s:s("p<d>"),W:s("p<aE>"),b:s("p<@>"),t:s("p<b>"),o:s("p<h?>"),T:s("aZ"),m:s("h"),g:s("a5"),p:s("E<@>"),j:s("f<@>"),a:s("A<d,@>"),V:s("aj<+item,matchPosition(y,C),y>"),l:s("ay<h>"),P:s("t"),K:s("k"),L:s("kJ"),d:s("+()"),F:s("ez"),k:s("a8"),N:s("d"),q:s("j"),_:s("X"),A:s("ak"),h:s("aB<d,d>"),R:s("cb"),c:s("x<@>"),y:s("N"),i:s("r"),z:s("@"),v:s("@(k)"),Q:s("@(k,a8)"),S:s("b"),Y:s("S<t>?"),B:s("h?"),X:s("k?"),u:s("d?"),e:s("N?"),I:s("r?"),w:s("b?"),x:s("hm?"),H:s("hm"),n:s("~")}})();(function constants(){var s=hunkHelpers.makeConstList
B.H=J.bO.prototype
B.c=J.p.prototype
B.b=J.aY.prototype
B.a=J.a4.prototype
B.I=J.a5.prototype
B.J=J.b1.prototype
B.r=A.ba.prototype
B.t=J.c4.prototype
B.j=J.ak.prototype
B.ar=new A.cy()
B.u=new A.cx()
B.as=new A.cF()
B.n=new A.cE()
B.o=function getTagFallback(o) {
  var s = Object.prototype.toString.call(o);
  return s.substring(8, s.length - 1);
}
B.v=function() {
  var toStringFunction = Object.prototype.toString;
  function getTag(o) {
    var s = toStringFunction.call(o);
    return s.substring(8, s.length - 1);
  }
  function getUnknownTag(object, tag) {
    if (/^HTML[A-Z].*Element$/.test(tag)) {
      var name = toStringFunction.call(object);
      if (name == "[object Object]") return null;
      return "HTMLElement";
    }
  }
  function getUnknownTagGenericBrowser(object, tag) {
    if (object instanceof HTMLElement) return "HTMLElement";
    return getUnknownTag(object, tag);
  }
  function prototypeForTag(tag) {
    if (typeof window == "undefined") return null;
    if (typeof window[tag] == "undefined") return null;
    var constructor = window[tag];
    if (typeof constructor != "function") return null;
    return constructor.prototype;
  }
  function discriminator(tag) { return null; }
  var isBrowser = typeof HTMLElement == "function";
  return {
    getTag: getTag,
    getUnknownTag: isBrowser ? getUnknownTagGenericBrowser : getUnknownTag,
    prototypeForTag: prototypeForTag,
    discriminator: discriminator };
}
B.A=function(getTagFallback) {
  return function(hooks) {
    if (typeof navigator != "object") return hooks;
    var userAgent = navigator.userAgent;
    if (typeof userAgent != "string") return hooks;
    if (userAgent.indexOf("DumpRenderTree") >= 0) return hooks;
    if (userAgent.indexOf("Chrome") >= 0) {
      function confirm(p) {
        return typeof window == "object" && window[p] && window[p].name == p;
      }
      if (confirm("Window") && confirm("HTMLElement")) return hooks;
    }
    hooks.getTag = getTagFallback;
  };
}
B.w=function(hooks) {
  if (typeof dartExperimentalFixupGetTag != "function") return hooks;
  hooks.getTag = dartExperimentalFixupGetTag(hooks.getTag);
}
B.z=function(hooks) {
  if (typeof navigator != "object") return hooks;
  var userAgent = navigator.userAgent;
  if (typeof userAgent != "string") return hooks;
  if (userAgent.indexOf("Firefox") == -1) return hooks;
  var getTag = hooks.getTag;
  var quickMap = {
    "BeforeUnloadEvent": "Event",
    "DataTransfer": "Clipboard",
    "GeoGeolocation": "Geolocation",
    "Location": "!Location",
    "WorkerMessageEvent": "MessageEvent",
    "XMLDocument": "!Document"};
  function getTagFirefox(o) {
    var tag = getTag(o);
    return quickMap[tag] || tag;
  }
  hooks.getTag = getTagFirefox;
}
B.y=function(hooks) {
  if (typeof navigator != "object") return hooks;
  var userAgent = navigator.userAgent;
  if (typeof userAgent != "string") return hooks;
  if (userAgent.indexOf("Trident/") == -1) return hooks;
  var getTag = hooks.getTag;
  var quickMap = {
    "BeforeUnloadEvent": "Event",
    "DataTransfer": "Clipboard",
    "HTMLDDElement": "HTMLElement",
    "HTMLDTElement": "HTMLElement",
    "HTMLPhraseElement": "HTMLElement",
    "Position": "Geoposition"
  };
  function getTagIE(o) {
    var tag = getTag(o);
    var newTag = quickMap[tag];
    if (newTag) return newTag;
    if (tag == "Object") {
      if (window.DataView && (o instanceof window.DataView)) return "DataView";
    }
    return tag;
  }
  function prototypeForTagIE(tag) {
    var constructor = window[tag];
    if (constructor == null) return null;
    return constructor.prototype;
  }
  hooks.getTag = getTagIE;
  hooks.prototypeForTag = prototypeForTagIE;
}
B.x=function(hooks) {
  var getTag = hooks.getTag;
  var prototypeForTag = hooks.prototypeForTag;
  function getTagFixed(o) {
    var tag = getTag(o);
    if (tag == "Document") {
      if (!!o.xmlVersion) return "!Document";
      return "!HTMLDocument";
    }
    return tag;
  }
  function prototypeForTagFixed(tag) {
    if (tag == "Document") return null;
    return prototypeForTag(tag);
  }
  hooks.getTag = getTagFixed;
  hooks.prototypeForTag = prototypeForTagFixed;
}
B.p=function(hooks) { return hooks; }

B.B=new A.cM()
B.C=new A.c3()
B.i=new A.cU()
B.e=new A.d1()
B.D=new A.d3()
B.d=new A.dz()
B.h=new A.cs()
B.E=new A.au(0)
B.F=new A.au(15e4)
B.G=new A.au(4e5)
B.K=new A.cN(null)
B.L=new A.n(0,"accessor")
B.M=new A.n(1,"constant")
B.X=new A.n(2,"constructor")
B.a0=new A.n(3,"class_")
B.a1=new A.n(4,"dynamic")
B.a2=new A.n(5,"enum_")
B.a3=new A.n(6,"extension")
B.a4=new A.n(7,"extensionType")
B.a5=new A.n(8,"function")
B.a6=new A.n(9,"library")
B.N=new A.n(10,"method")
B.O=new A.n(11,"mixin")
B.P=new A.n(12,"never")
B.Q=new A.n(13,"package")
B.R=new A.n(14,"parameter")
B.S=new A.n(15,"prefix")
B.T=new A.n(16,"property")
B.U=new A.n(17,"sdk")
B.V=new A.n(18,"topic")
B.W=new A.n(19,"topLevelConstant")
B.Y=new A.n(20,"topLevelProperty")
B.Z=new A.n(21,"typedef")
B.a_=new A.n(22,"typeParameter")
B.q=s([B.L,B.M,B.X,B.a0,B.a1,B.a2,B.a3,B.a4,B.a5,B.a6,B.N,B.O,B.P,B.Q,B.R,B.S,B.T,B.U,B.V,B.W,B.Y,B.Z,B.a_],A.bE("p<n>"))
B.a8={}
B.a7=new A.aU(B.a8,[],A.bE("aU<d,d>"))
B.a9={input:0,textarea:1}
B.aa=new A.aV(B.a9,2,A.bE("aV<d>"))
B.ab=A.P("kD")
B.ac=A.P("kE")
B.ad=A.P("i0")
B.ae=A.P("i1")
B.af=A.P("i3")
B.ag=A.P("i4")
B.ah=A.P("i5")
B.ai=A.P("k")
B.aj=A.P("ip")
B.ak=A.P("iq")
B.al=A.P("ir")
B.am=A.P("is")
B.an=new A.d2(!1)
B.k=new A.aF(0,"idle")
B.l=new A.aF(1,"loading")
B.m=new A.aF(2,"failed")
B.f=new A.aF(3,"loaded")
B.ao=new A.C(0,"isExactly")
B.ap=new A.C(1,"startsWith")
B.aq=new A.C(2,"contains")})();(function staticFields(){$.dp=null
$.ao=A.l([],t.f)
$.fq=null
$.ff=null
$.fe=null
$.hk=null
$.hh=null
$.hp=null
$.e5=null
$.eh=null
$.f6=null
$.dy=A.l([],A.bE("p<f<k>?>"))
$.aI=null
$.bC=null
$.bD=null
$.eW=!1
$.q=B.d
$.eZ=null
$.aH=null
$.f0=10
$.aK=0
$.ac=A.ew(t.N,t.m)})();(function lazyInitializers(){var s=hunkHelpers.lazyFinal
s($,"kG","hs",()=>A.e8("_$dart_dartClosure"))
s($,"kF","em",()=>A.e8("_$dart_dartClosure_dartJSInterop"))
s($,"l2","hJ",()=>A.l([new J.bP()],A.bE("p<be>")))
s($,"kL","ht",()=>A.Y(A.cY({
toString:function(){return"$receiver$"}})))
s($,"kM","hu",()=>A.Y(A.cY({$method$:null,
toString:function(){return"$receiver$"}})))
s($,"kN","hv",()=>A.Y(A.cY(null)))
s($,"kO","hw",()=>A.Y(function(){var $argumentsExpr$="$arguments$"
try{null.$method$($argumentsExpr$)}catch(r){return r.message}}()))
s($,"kR","hz",()=>A.Y(A.cY(void 0)))
s($,"kS","hA",()=>A.Y(function(){var $argumentsExpr$="$arguments$"
try{(void 0).$method$($argumentsExpr$)}catch(r){return r.message}}()))
s($,"kQ","hy",()=>A.Y(A.fz(null)))
s($,"kP","hx",()=>A.Y(function(){try{null.$method$}catch(r){return r.message}}()))
s($,"kU","hC",()=>A.Y(A.fz(void 0)))
s($,"kT","hB",()=>A.Y(function(){try{(void 0).$method$}catch(r){return r.message}}()))
s($,"kV","f9",()=>A.ix())
s($,"l0","hI",()=>A.ig(4096))
s($,"kZ","hG",()=>new A.dP().$0())
s($,"l_","hH",()=>new A.dO().$0())
s($,"kW","hD",()=>A.ie(A.js(A.l([-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-1,-2,-2,-2,-2,-2,62,-2,62,-2,63,52,53,54,55,56,57,58,59,60,61,-2,-2,-2,-1,-2,-2,-2,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,-2,-2,-2,-2,63,-2,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,-2,-2,-2,-2,-2],t.t))))
s($,"kX","hE",()=>A.fu("^[\\-\\.0-9A-Z_a-z~]*$",!0))
s($,"kY","hF",()=>typeof URLSearchParams=="function")
s($,"l1","en",()=>A.hn(B.ai))})();(function nativeSupport(){!function(){var s=function(a){var m={}
m[a]=1
return Object.keys(hunkHelpers.convertToFastObject(m))[0]}
v.getIsolateTag=function(a){return s("___dart_"+a+v.isolateTag)}
var r="___dart_isolate_tags_"
var q=Object[r]||(Object[r]=Object.create(null))
var p="_ZxYxX"
for(var o=0;;o++){var n=s(p+"_"+o+"_")
if(!(n in q)){q[n]=1
v.isolateTag=n
break}}v.dispatchPropertyName=v.getIsolateTag("dispatch_record")}()
hunkHelpers.setOrUpdateInterceptorsByTag({ArrayBuffer:A.aw,SharedArrayBuffer:A.aw,ArrayBufferView:A.b8,DataView:A.bV,Float32Array:A.bW,Float64Array:A.bX,Int16Array:A.bY,Int32Array:A.bZ,Int8Array:A.c_,Uint16Array:A.c0,Uint32Array:A.c1,Uint8ClampedArray:A.b9,CanvasPixelArray:A.b9,Uint8Array:A.ba})
hunkHelpers.setOrUpdateLeafTags({ArrayBuffer:true,SharedArrayBuffer:true,ArrayBufferView:false,DataView:true,Float32Array:true,Float64Array:true,Int16Array:true,Int32Array:true,Int8Array:true,Uint16Array:true,Uint32Array:true,Uint8ClampedArray:true,CanvasPixelArray:true,Uint8Array:false})
A.ax.$nativeSuperclassTag="ArrayBufferView"
A.bm.$nativeSuperclassTag="ArrayBufferView"
A.bn.$nativeSuperclassTag="ArrayBufferView"
A.b6.$nativeSuperclassTag="ArrayBufferView"
A.bo.$nativeSuperclassTag="ArrayBufferView"
A.bp.$nativeSuperclassTag="ArrayBufferView"
A.b7.$nativeSuperclassTag="ArrayBufferView"})()
Function.prototype.$0=function(){return this()}
Function.prototype.$1=function(a){return this(a)}
Function.prototype.$2=function(a,b){return this(a,b)}
Function.prototype.$3=function(a,b,c){return this(a,b,c)}
Function.prototype.$4=function(a,b,c,d){return this(a,b,c,d)}
Function.prototype.$1$0=function(){return this()}
Function.prototype.$1$1=function(a){return this(a)}
convertAllToFastObject(w)
convertToFastObject($);(function(a){if(typeof document==="undefined"){a(null)
return}if(typeof document.currentScript!="undefined"){a(document.currentScript)
return}var s=document.scripts
function onLoad(b){for(var q=0;q<s.length;++q){s[q].removeEventListener("load",onLoad,false)}a(b.target)}for(var r=0;r<s.length;++r){s[r].addEventListener("load",onLoad,false)}})(function(a){v.currentScript=a
var s=A.ks
if(typeof dartMainRunner==="function"){dartMainRunner(s,[])}else{s([])}})})()
//# sourceMappingURL=docs.dart.js.map
