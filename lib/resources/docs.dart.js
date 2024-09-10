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
if(a[b]!==s){A.jY(b)}a[b]=r}var q=a[b]
a[c]=function(){return q}
return q}}function makeConstList(a){a.$flags=7
return a}function convertToFastObject(a){function t(){}t.prototype=a
new t()
return a}function convertAllToFastObject(a){for(var s=0;s<a.length;++s){convertToFastObject(a[s])}}var y=0
function instanceTearOffGetter(a,b){var s=null
return a?function(c){if(s===null)s=A.eA(b)
return new s(c,this)}:function(){if(s===null)s=A.eA(b)
return new s(this,null)}}function staticTearOffGetter(a){var s=null
return function(){if(s===null)s=A.eA(a).prototype
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
eF(a,b,c,d){return{i:a,p:b,e:c,x:d}},
eC(a){var s,r,q,p,o,n=a[v.dispatchPropertyName]
if(n==null)if($.eD==null){A.jJ()
n=a[v.dispatchPropertyName]}if(n!=null){s=n.p
if(!1===s)return n.i
if(!0===s)return a
r=Object.getPrototypeOf(a)
if(s===r)return n.i
if(n.e===r)throw A.a(A.f6("Return interceptor for "+A.i(s(a,n))))}q=a.constructor
if(q==null)p=null
else{o=$.de
if(o==null)o=$.de=v.getIsolateTag("_$dart_js")
p=q[o]}if(p!=null)return p
p=A.jO(a)
if(p!=null)return p
if(typeof a=="function")return B.F
s=Object.getPrototypeOf(a)
if(s==null)return B.t
if(s===Object.prototype)return B.t
if(typeof q=="function"){o=$.de
if(o==null)o=$.de=v.getIsolateTag("_$dart_js")
Object.defineProperty(q,o,{value:B.k,enumerable:false,writable:true,configurable:true})
return B.k}return B.k},
hJ(a,b){if(a<0||a>4294967295)throw A.a(A.G(a,0,4294967295,"length",null))
return J.hL(new Array(a),b)},
hK(a,b){if(a<0)throw A.a(A.M("Length must be a non-negative integer: "+a,null))
return A.h(new Array(a),b.i("o<0>"))},
eQ(a,b){if(a<0)throw A.a(A.M("Length must be a non-negative integer: "+a,null))
return A.h(new Array(a),b.i("o<0>"))},
hL(a,b){var s=A.h(a,b.i("o<0>"))
s.$flags=1
return s},
hM(a,b){return J.hm(a,b)},
al(a){if(typeof a=="number"){if(Math.floor(a)==a)return J.aM.prototype
return J.bF.prototype}if(typeof a=="string")return J.af.prototype
if(a==null)return J.aN.prototype
if(typeof a=="boolean")return J.bE.prototype
if(Array.isArray(a))return J.o.prototype
if(typeof a!="object"){if(typeof a=="function")return J.a0.prototype
if(typeof a=="symbol")return J.aR.prototype
if(typeof a=="bigint")return J.aP.prototype
return a}if(a instanceof A.k)return a
return J.eC(a)},
cj(a){if(typeof a=="string")return J.af.prototype
if(a==null)return a
if(Array.isArray(a))return J.o.prototype
if(typeof a!="object"){if(typeof a=="function")return J.a0.prototype
if(typeof a=="symbol")return J.aR.prototype
if(typeof a=="bigint")return J.aP.prototype
return a}if(a instanceof A.k)return a
return J.eC(a)},
dR(a){if(a==null)return a
if(Array.isArray(a))return J.o.prototype
if(typeof a!="object"){if(typeof a=="function")return J.a0.prototype
if(typeof a=="symbol")return J.aR.prototype
if(typeof a=="bigint")return J.aP.prototype
return a}if(a instanceof A.k)return a
return J.eC(a)},
jC(a){if(typeof a=="number")return J.aO.prototype
if(typeof a=="string")return J.af.prototype
if(a==null)return a
if(!(a instanceof A.k))return J.as.prototype
return a},
I(a,b){if(a==null)return b==null
if(typeof a!="object")return b!=null&&a===b
return J.al(a).E(a,b)},
hj(a,b){if(typeof b==="number")if(Array.isArray(a)||typeof a=="string"||A.fX(a,a[v.dispatchPropertyName]))if(b>>>0===b&&b<a.length)return a[b]
return J.cj(a).k(a,b)},
hk(a,b,c){if(typeof b==="number")if((Array.isArray(a)||A.fX(a,a[v.dispatchPropertyName]))&&!(a.$flags&2)&&b>>>0===b&&b<a.length)return a[b]=c
return J.dR(a).q(a,b,c)},
hl(a,b){return J.dR(a).Y(a,b)},
hm(a,b){return J.jC(a).aJ(a,b)},
hn(a,b){return J.cj(a).O(a,b)},
e7(a,b){return J.dR(a).C(a,b)},
X(a){return J.al(a).gp(a)},
ac(a){return J.dR(a).gA(a)},
bu(a){return J.cj(a).gl(a)},
ho(a){return J.al(a).gt(a)},
an(a){return J.al(a).h(a)},
bD:function bD(){},
bE:function bE(){},
aN:function aN(){},
aQ:function aQ(){},
a1:function a1(){},
bS:function bS(){},
as:function as(){},
a0:function a0(){},
aP:function aP(){},
aR:function aR(){},
o:function o(a){this.$ti=a},
cz:function cz(a){this.$ti=a},
Y:function Y(a,b,c){var _=this
_.a=a
_.b=b
_.c=0
_.d=null
_.$ti=c},
aO:function aO(){},
aM:function aM(){},
bF:function bF(){},
af:function af(){}},A={eb:function eb(){},
hr(a,b,c){if(b.i("c<0>").b(a))return new A.b6(a,b.i("@<0>").B(c).i("b6<1,2>"))
return new A.ad(a,b.i("@<0>").B(c).i("ad<1,2>"))},
dS(a){var s,r=a^48
if(r<=9)return r
s=a|32
if(97<=s&&s<=102)return s-87
return-1},
a3(a,b){a=a+b&536870911
a=a+((a&524287)<<10)&536870911
return a^a>>>6},
ei(a){a=a+((a&67108863)<<3)&536870911
a^=a>>>11
return a+((a&16383)<<15)&536870911},
ez(a,b,c){return a},
eE(a){var s,r
for(s=$.am.length,r=0;r<s;++r)if(a===$.am[r])return!0
return!1},
hP(a,b,c,d){if(t.U.b(a))return new A.aJ(a,b,c.i("@<0>").B(d).i("aJ<1,2>"))
return new A.ah(a,b,c.i("@<0>").B(d).i("ah<1,2>"))},
hG(){return new A.b2("No element")},
a4:function a4(){},
bx:function bx(a,b){this.a=a
this.$ti=b},
ad:function ad(a,b){this.a=a
this.$ti=b},
b6:function b6(a,b){this.a=a
this.$ti=b},
b5:function b5(){},
N:function N(a,b){this.a=a
this.$ti=b},
aS:function aS(a){this.a=a},
by:function by(a){this.a=a},
cJ:function cJ(){},
c:function c(){},
J:function J(){},
ao:function ao(a,b,c){var _=this
_.a=a
_.b=b
_.c=0
_.d=null
_.$ti=c},
ah:function ah(a,b,c){this.a=a
this.b=b
this.$ti=c},
aJ:function aJ(a,b,c){this.a=a
this.b=b
this.$ti=c},
ap:function ap(a,b,c){var _=this
_.a=null
_.b=a
_.c=b
_.$ti=c},
ai:function ai(a,b,c){this.a=a
this.b=b
this.$ti=c},
aL:function aL(){},
bX:function bX(){},
at:function at(){},
bm:function bm(){},
hx(){throw A.a(A.bY("Cannot modify unmodifiable Map"))},
h1(a){var s=v.mangledGlobalNames[a]
if(s!=null)return s
return"minified:"+a},
fX(a,b){var s
if(b!=null){s=b.x
if(s!=null)return s}return t.p.b(a)},
i(a){var s
if(typeof a=="string")return a
if(typeof a=="number"){if(a!==0)return""+a}else if(!0===a)return"true"
else if(!1===a)return"false"
else if(a==null)return"null"
s=J.an(a)
return s},
bT(a){var s,r=$.eV
if(r==null)r=$.eV=Symbol("identityHashCode")
s=a[r]
if(s==null){s=Math.random()*0x3fffffff|0
a[r]=s}return s},
eW(a,b){var s,r,q,p,o,n=null,m=/^\s*[+-]?((0x[a-f0-9]+)|(\d+)|([a-z0-9]+))\s*$/i.exec(a)
if(m==null)return n
s=m[3]
if(b==null){if(s!=null)return parseInt(a,10)
if(m[2]!=null)return parseInt(a,16)
return n}if(b<2||b>36)throw A.a(A.G(b,2,36,"radix",n))
if(b===10&&s!=null)return parseInt(a,10)
if(b<10||s==null){r=b<=10?47+b:86+b
q=m[1]
for(p=q.length,o=0;o<p;++o)if((q.charCodeAt(o)|32)>r)return n}return parseInt(a,b)},
cI(a){return A.hT(a)},
hT(a){var s,r,q,p
if(a instanceof A.k)return A.C(A.aC(a),null)
s=J.al(a)
if(s===B.E||s===B.G||t.o.b(a)){r=B.m(a)
if(r!=="Object"&&r!=="")return r
q=a.constructor
if(typeof q=="function"){p=q.name
if(typeof p=="string"&&p!=="Object"&&p!=="")return p}}return A.C(A.aC(a),null)},
eX(a){if(a==null||typeof a=="number"||A.eu(a))return J.an(a)
if(typeof a=="string")return JSON.stringify(a)
if(a instanceof A.ae)return a.h(0)
if(a instanceof A.bc)return a.aG(!0)
return"Instance of '"+A.cI(a)+"'"},
hV(a,b,c){var s,r,q,p
if(c<=500&&b===0&&c===a.length)return String.fromCharCode.apply(null,a)
for(s=b,r="";s<c;s=q){q=s+500
p=q<c?q:c
r+=String.fromCharCode.apply(null,a.subarray(s,p))}return r},
Q(a){var s
if(0<=a){if(a<=65535)return String.fromCharCode(a)
if(a<=1114111){s=a-65536
return String.fromCharCode((B.b.W(s,10)|55296)>>>0,s&1023|56320)}}throw A.a(A.G(a,0,1114111,null,null))},
hU(a){var s=a.$thrownJsError
if(s==null)return null
return A.a9(s)},
eY(a,b){var s
if(a.$thrownJsError==null){s=A.a(a)
a.$thrownJsError=s
s.stack=b.h(0)}},
eB(a,b){var s,r="index"
if(!A.fH(b))return new A.F(!0,b,r,null)
s=J.bu(a)
if(b<0||b>=s)return A.e9(b,s,a,r)
return A.hW(b,r)},
jz(a,b,c){if(a>c)return A.G(a,0,c,"start",null)
if(b!=null)if(b<a||b>c)return A.G(b,a,c,"end",null)
return new A.F(!0,b,"end",null)},
js(a){return new A.F(!0,a,null,null)},
a(a){return A.fW(new Error(),a)},
fW(a,b){var s
if(b==null)b=new A.R()
a.dartException=b
s=A.jZ
if("defineProperty" in Object){Object.defineProperty(a,"message",{get:s})
a.name=""}else a.toString=s
return a},
jZ(){return J.an(this.dartException)},
h0(a){throw A.a(a)},
eG(a,b){throw A.fW(b,a)},
K(a,b,c){var s
if(b==null)b=0
if(c==null)c=0
s=Error()
A.eG(A.iR(a,b,c),s)},
iR(a,b,c){var s,r,q,p,o,n,m,l,k
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
return new A.b3("'"+s+"': Cannot "+o+" "+l+k+n)},
e5(a){throw A.a(A.aE(a))},
S(a){var s,r,q,p,o,n
a=A.jT(a.replace(String({}),"$receiver$"))
s=a.match(/\\\$[a-zA-Z]+\\\$/g)
if(s==null)s=A.h([],t.s)
r=s.indexOf("\\$arguments\\$")
q=s.indexOf("\\$argumentsExpr\\$")
p=s.indexOf("\\$expr\\$")
o=s.indexOf("\\$method\\$")
n=s.indexOf("\\$receiver\\$")
return new A.cM(a.replace(new RegExp("\\\\\\$arguments\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$argumentsExpr\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$expr\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$method\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$receiver\\\\\\$","g"),"((?:x|[^x])*)"),r,q,p,o,n)},
cN(a){return function($expr$){var $argumentsExpr$="$arguments$"
try{$expr$.$method$($argumentsExpr$)}catch(s){return s.message}}(a)},
f5(a){return function($expr$){try{$expr$.$method$}catch(s){return s.message}}(a)},
ec(a,b){var s=b==null,r=s?null:b.method
return new A.bG(a,r,s?null:b.receiver)},
ab(a){if(a==null)return new A.cH(a)
if(a instanceof A.aK)return A.aa(a,a.a)
if(typeof a!=="object")return a
if("dartException" in a)return A.aa(a,a.dartException)
return A.jr(a)},
aa(a,b){if(t.C.b(b))if(b.$thrownJsError==null)b.$thrownJsError=a
return b},
jr(a){var s,r,q,p,o,n,m,l,k,j,i,h,g
if(!("message" in a))return a
s=a.message
if("number" in a&&typeof a.number=="number"){r=a.number
q=r&65535
if((B.b.W(r,16)&8191)===10)switch(q){case 438:return A.aa(a,A.ec(A.i(s)+" (Error "+q+")",null))
case 445:case 5007:A.i(s)
return A.aa(a,new A.aZ())}}if(a instanceof TypeError){p=$.h2()
o=$.h3()
n=$.h4()
m=$.h5()
l=$.h8()
k=$.h9()
j=$.h7()
$.h6()
i=$.hb()
h=$.ha()
g=p.D(s)
if(g!=null)return A.aa(a,A.ec(s,g))
else{g=o.D(s)
if(g!=null){g.method="call"
return A.aa(a,A.ec(s,g))}else if(n.D(s)!=null||m.D(s)!=null||l.D(s)!=null||k.D(s)!=null||j.D(s)!=null||m.D(s)!=null||i.D(s)!=null||h.D(s)!=null)return A.aa(a,new A.aZ())}return A.aa(a,new A.bW(typeof s=="string"?s:""))}if(a instanceof RangeError){if(typeof s=="string"&&s.indexOf("call stack")!==-1)return new A.b1()
s=function(b){try{return String(b)}catch(f){}return null}(a)
return A.aa(a,new A.F(!1,null,null,typeof s=="string"?s.replace(/^RangeError:\s*/,""):s))}if(typeof InternalError=="function"&&a instanceof InternalError)if(typeof s=="string"&&s==="too much recursion")return new A.b1()
return a},
a9(a){var s
if(a instanceof A.aK)return a.b
if(a==null)return new A.bd(a)
s=a.$cachedTrace
if(s!=null)return s
s=new A.bd(a)
if(typeof a==="object")a.$cachedTrace=s
return s},
fY(a){if(a==null)return J.X(a)
if(typeof a=="object")return A.bT(a)
return J.X(a)},
jB(a,b){var s,r,q,p=a.length
for(s=0;s<p;s=q){r=s+1
q=r+1
b.q(0,a[s],a[r])}return b},
j4(a,b,c,d,e,f){switch(b){case 0:return a.$0()
case 1:return a.$1(c)
case 2:return a.$2(c,d)
case 3:return a.$3(c,d,e)
case 4:return a.$4(c,d,e,f)}throw A.a(new A.d1("Unsupported number of arguments for wrapped closure"))},
aB(a,b){var s=a.$identity
if(!!s)return s
s=A.jx(a,b)
a.$identity=s
return s},
jx(a,b){var s
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
return function(c,d,e){return function(f,g,h,i){return e(c,d,f,g,h,i)}}(a,b,A.j4)},
hw(a2){var s,r,q,p,o,n,m,l,k,j,i=a2.co,h=a2.iS,g=a2.iI,f=a2.nDA,e=a2.aI,d=a2.fs,c=a2.cs,b=d[0],a=c[0],a0=i[b],a1=a2.fT
a1.toString
s=h?Object.create(new A.cK().constructor.prototype):Object.create(new A.aD(null,null).constructor.prototype)
s.$initialize=s.constructor
r=h?function static_tear_off(){this.$initialize()}:function tear_off(a3,a4){this.$initialize(a3,a4)}
s.constructor=r
r.prototype=s
s.$_name=b
s.$_target=a0
q=!h
if(q)p=A.eP(b,a0,g,f)
else{s.$static_name=b
p=a0}s.$S=A.hs(a1,h,g)
s[a]=p
for(o=p,n=1;n<d.length;++n){m=d[n]
if(typeof m=="string"){l=i[m]
k=m
m=l}else k=""
j=c[n]
if(j!=null){if(q)m=A.eP(k,m,g,f)
s[j]=m}if(n===e)o=m}s.$C=o
s.$R=a2.rC
s.$D=a2.dV
return r},
hs(a,b,c){if(typeof a=="number")return a
if(typeof a=="string"){if(b)throw A.a("Cannot compute signature for static tearoff.")
return function(d,e){return function(){return e(this,d)}}(a,A.hp)}throw A.a("Error in functionType of tearoff")},
ht(a,b,c,d){var s=A.eO
switch(b?-1:a){case 0:return function(e,f){return function(){return f(this)[e]()}}(c,s)
case 1:return function(e,f){return function(g){return f(this)[e](g)}}(c,s)
case 2:return function(e,f){return function(g,h){return f(this)[e](g,h)}}(c,s)
case 3:return function(e,f){return function(g,h,i){return f(this)[e](g,h,i)}}(c,s)
case 4:return function(e,f){return function(g,h,i,j){return f(this)[e](g,h,i,j)}}(c,s)
case 5:return function(e,f){return function(g,h,i,j,k){return f(this)[e](g,h,i,j,k)}}(c,s)
default:return function(e,f){return function(){return e.apply(f(this),arguments)}}(d,s)}},
eP(a,b,c,d){if(c)return A.hv(a,b,d)
return A.ht(b.length,d,a,b)},
hu(a,b,c,d){var s=A.eO,r=A.hq
switch(b?-1:a){case 0:throw A.a(new A.bU("Intercepted function with no arguments."))
case 1:return function(e,f,g){return function(){return f(this)[e](g(this))}}(c,r,s)
case 2:return function(e,f,g){return function(h){return f(this)[e](g(this),h)}}(c,r,s)
case 3:return function(e,f,g){return function(h,i){return f(this)[e](g(this),h,i)}}(c,r,s)
case 4:return function(e,f,g){return function(h,i,j){return f(this)[e](g(this),h,i,j)}}(c,r,s)
case 5:return function(e,f,g){return function(h,i,j,k){return f(this)[e](g(this),h,i,j,k)}}(c,r,s)
case 6:return function(e,f,g){return function(h,i,j,k,l){return f(this)[e](g(this),h,i,j,k,l)}}(c,r,s)
default:return function(e,f,g){return function(){var q=[g(this)]
Array.prototype.push.apply(q,arguments)
return e.apply(f(this),q)}}(d,r,s)}},
hv(a,b,c){var s,r
if($.eM==null)$.eM=A.eL("interceptor")
if($.eN==null)$.eN=A.eL("receiver")
s=b.length
r=A.hu(s,c,a,b)
return r},
eA(a){return A.hw(a)},
hp(a,b){return A.bi(v.typeUniverse,A.aC(a.a),b)},
eO(a){return a.a},
hq(a){return a.b},
eL(a){var s,r,q,p=new A.aD("receiver","interceptor"),o=Object.getOwnPropertyNames(p)
o.$flags=1
s=o
for(o=s.length,r=0;r<o;++r){q=s[r]
if(p[q]===a)return q}throw A.a(A.M("Field name "+a+" not found.",null))},
kA(a){throw A.a(new A.c3(a))},
jD(a){return v.getIsolateTag(a)},
jO(a){var s,r,q,p,o,n=$.fV.$1(a),m=$.dQ[n]
if(m!=null){Object.defineProperty(a,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
return m.i}s=$.e0[n]
if(s!=null)return s
r=v.interceptorsByTag[n]
if(r==null){q=$.fS.$2(a,n)
if(q!=null){m=$.dQ[q]
if(m!=null){Object.defineProperty(a,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
return m.i}s=$.e0[q]
if(s!=null)return s
r=v.interceptorsByTag[q]
n=q}}if(r==null)return null
s=r.prototype
p=n[0]
if(p==="!"){m=A.e1(s)
$.dQ[n]=m
Object.defineProperty(a,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
return m.i}if(p==="~"){$.e0[n]=s
return s}if(p==="-"){o=A.e1(s)
Object.defineProperty(Object.getPrototypeOf(a),v.dispatchPropertyName,{value:o,enumerable:false,writable:true,configurable:true})
return o.i}if(p==="+")return A.fZ(a,s)
if(p==="*")throw A.a(A.f6(n))
if(v.leafTags[n]===true){o=A.e1(s)
Object.defineProperty(Object.getPrototypeOf(a),v.dispatchPropertyName,{value:o,enumerable:false,writable:true,configurable:true})
return o.i}else return A.fZ(a,s)},
fZ(a,b){var s=Object.getPrototypeOf(a)
Object.defineProperty(s,v.dispatchPropertyName,{value:J.eF(b,s,null,null),enumerable:false,writable:true,configurable:true})
return b},
e1(a){return J.eF(a,!1,null,!!a.$iD)},
jQ(a,b,c){var s=b.prototype
if(v.leafTags[a]===true)return A.e1(s)
else return J.eF(s,c,null,null)},
jJ(){if(!0===$.eD)return
$.eD=!0
A.jK()},
jK(){var s,r,q,p,o,n,m,l
$.dQ=Object.create(null)
$.e0=Object.create(null)
A.jI()
s=v.interceptorsByTag
r=Object.getOwnPropertyNames(s)
if(typeof window!="undefined"){window
q=function(){}
for(p=0;p<r.length;++p){o=r[p]
n=$.h_.$1(o)
if(n!=null){m=A.jQ(o,s[o],n)
if(m!=null){Object.defineProperty(n,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
q.prototype=n}}}}for(p=0;p<r.length;++p){o=r[p]
if(/^[A-Za-z_]/.test(o)){l=s[o]
s["!"+o]=l
s["~"+o]=l
s["-"+o]=l
s["+"+o]=l
s["*"+o]=l}}},
jI(){var s,r,q,p,o,n,m=B.v()
m=A.aA(B.w,A.aA(B.x,A.aA(B.n,A.aA(B.n,A.aA(B.y,A.aA(B.z,A.aA(B.A(B.m),m)))))))
if(typeof dartNativeDispatchHooksTransformer!="undefined"){s=dartNativeDispatchHooksTransformer
if(typeof s=="function")s=[s]
if(Array.isArray(s))for(r=0;r<s.length;++r){q=s[r]
if(typeof q=="function")m=q(m)||m}}p=m.getTag
o=m.getUnknownTag
n=m.prototypeForTag
$.fV=new A.dT(p)
$.fS=new A.dU(o)
$.h_=new A.dV(n)},
aA(a,b){return a(b)||b},
jy(a,b){var s=b.length,r=v.rttc[""+s+";"+a]
if(r==null)return null
if(s===0)return r
if(s===r.length)return r.apply(null,b)
return r(b)},
eR(a,b,c,d,e,f){var s=b?"m":"",r=c?"":"i",q=d?"u":"",p=e?"s":"",o=f?"g":"",n=function(g,h){try{return new RegExp(g,h)}catch(m){return m}}(a,s+r+q+p+o)
if(n instanceof RegExp)return n
throw A.a(A.x("Illegal RegExp pattern ("+String(n)+")",a,null))},
jW(a,b,c){var s=a.indexOf(b,c)
return s>=0},
jT(a){if(/[[\]{}()*+?.\\^$|]/.test(a))return a.replace(/[[\]{}()*+?.\\^$|]/g,"\\$&")
return a},
fP(a){return a},
jX(a,b,c,d){var s,r,q,p=new A.cW(b,a,0),o=t.F,n=0,m=""
for(;p.m();){s=p.d
if(s==null)s=o.a(s)
r=s.b
q=r.index
m=m+A.i(A.fP(B.a.j(a,n,q)))+A.i(c.$1(s))
n=q+r[0].length}p=m+A.i(A.fP(B.a.K(a,n)))
return p.charCodeAt(0)==0?p:p},
cc:function cc(a,b){this.a=a
this.b=b},
aF:function aF(){},
aH:function aH(a,b,c){this.a=a
this.b=b
this.$ti=c},
c9:function c9(a,b,c){var _=this
_.a=a
_.b=b
_.c=0
_.d=null
_.$ti=c},
aG:function aG(){},
aI:function aI(a,b,c){this.a=a
this.b=b
this.$ti=c},
cM:function cM(a,b,c,d,e,f){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f},
aZ:function aZ(){},
bG:function bG(a,b,c){this.a=a
this.b=b
this.c=c},
bW:function bW(a){this.a=a},
cH:function cH(a){this.a=a},
aK:function aK(a,b){this.a=a
this.b=b},
bd:function bd(a){this.a=a
this.b=null},
ae:function ae(){},
cm:function cm(){},
cn:function cn(){},
cL:function cL(){},
cK:function cK(){},
aD:function aD(a,b){this.a=a
this.b=b},
c3:function c3(a){this.a=a},
bU:function bU(a){this.a=a},
ag:function ag(a){var _=this
_.a=0
_.f=_.e=_.d=_.c=_.b=null
_.r=0
_.$ti=a},
cA:function cA(a){this.a=a},
cD:function cD(a,b){this.a=a
this.b=b
this.c=null},
O:function O(a,b){this.a=a
this.$ti=b},
bH:function bH(a,b){var _=this
_.a=a
_.b=b
_.d=_.c=null},
dT:function dT(a){this.a=a},
dU:function dU(a){this.a=a},
dV:function dV(a){this.a=a},
bc:function bc(){},
cb:function cb(){},
cy:function cy(a,b){var _=this
_.a=a
_.b=b
_.d=_.c=null},
ca:function ca(a){this.b=a},
cW:function cW(a,b,c){var _=this
_.a=a
_.b=b
_.c=c
_.d=null},
iS(a){return a},
hQ(a){return new Int8Array(a)},
hR(a){return new Uint8Array(a)},
U(a,b,c){if(a>>>0!==a||a>=c)throw A.a(A.eB(b,a))},
iO(a,b,c){var s
if(!(a>>>0!==a))s=b>>>0!==b||a>b||b>c
else s=!0
if(s)throw A.a(A.jz(a,b,c))
return b},
bI:function bI(){},
aW:function aW(){},
bJ:function bJ(){},
aq:function aq(){},
aU:function aU(){},
aV:function aV(){},
bK:function bK(){},
bL:function bL(){},
bM:function bM(){},
bN:function bN(){},
bO:function bO(){},
bP:function bP(){},
bQ:function bQ(){},
aX:function aX(){},
aY:function aY(){},
b8:function b8(){},
b9:function b9(){},
ba:function ba(){},
bb:function bb(){},
f_(a,b){var s=b.c
return s==null?b.c=A.em(a,b.x,!0):s},
eh(a,b){var s=b.c
return s==null?b.c=A.bg(a,"a_",[b.x]):s},
f0(a){var s=a.w
if(s===6||s===7||s===8)return A.f0(a.x)
return s===12||s===13},
hX(a){return a.as},
bq(a){return A.cg(v.typeUniverse,a,!1)},
a8(a1,a2,a3,a4){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0=a2.w
switch(a0){case 5:case 1:case 2:case 3:case 4:return a2
case 6:s=a2.x
r=A.a8(a1,s,a3,a4)
if(r===s)return a2
return A.fk(a1,r,!0)
case 7:s=a2.x
r=A.a8(a1,s,a3,a4)
if(r===s)return a2
return A.em(a1,r,!0)
case 8:s=a2.x
r=A.a8(a1,s,a3,a4)
if(r===s)return a2
return A.fi(a1,r,!0)
case 9:q=a2.y
p=A.az(a1,q,a3,a4)
if(p===q)return a2
return A.bg(a1,a2.x,p)
case 10:o=a2.x
n=A.a8(a1,o,a3,a4)
m=a2.y
l=A.az(a1,m,a3,a4)
if(n===o&&l===m)return a2
return A.ek(a1,n,l)
case 11:k=a2.x
j=a2.y
i=A.az(a1,j,a3,a4)
if(i===j)return a2
return A.fj(a1,k,i)
case 12:h=a2.x
g=A.a8(a1,h,a3,a4)
f=a2.y
e=A.jo(a1,f,a3,a4)
if(g===h&&e===f)return a2
return A.fh(a1,g,e)
case 13:d=a2.y
a4+=d.length
c=A.az(a1,d,a3,a4)
o=a2.x
n=A.a8(a1,o,a3,a4)
if(c===d&&n===o)return a2
return A.el(a1,n,c,!0)
case 14:b=a2.x
if(b<a4)return a2
a=a3[b-a4]
if(a==null)return a2
return a
default:throw A.a(A.bw("Attempted to substitute unexpected RTI kind "+a0))}},
az(a,b,c,d){var s,r,q,p,o=b.length,n=A.dz(o)
for(s=!1,r=0;r<o;++r){q=b[r]
p=A.a8(a,q,c,d)
if(p!==q)s=!0
n[r]=p}return s?n:b},
jp(a,b,c,d){var s,r,q,p,o,n,m=b.length,l=A.dz(m)
for(s=!1,r=0;r<m;r+=3){q=b[r]
p=b[r+1]
o=b[r+2]
n=A.a8(a,o,c,d)
if(n!==o)s=!0
l.splice(r,3,q,p,n)}return s?l:b},
jo(a,b,c,d){var s,r=b.a,q=A.az(a,r,c,d),p=b.b,o=A.az(a,p,c,d),n=b.c,m=A.jp(a,n,c,d)
if(q===r&&o===p&&m===n)return b
s=new A.c6()
s.a=q
s.b=o
s.c=m
return s},
h(a,b){a[v.arrayRti]=b
return a},
fU(a){var s=a.$S
if(s!=null){if(typeof s=="number")return A.jF(s)
return a.$S()}return null},
jL(a,b){var s
if(A.f0(b))if(a instanceof A.ae){s=A.fU(a)
if(s!=null)return s}return A.aC(a)},
aC(a){if(a instanceof A.k)return A.E(a)
if(Array.isArray(a))return A.a6(a)
return A.et(J.al(a))},
a6(a){var s=a[v.arrayRti],r=t.b
if(s==null)return r
if(s.constructor!==r.constructor)return r
return s},
E(a){var s=a.$ti
return s!=null?s:A.et(a)},
et(a){var s=a.constructor,r=s.$ccache
if(r!=null)return r
return A.j0(a,s)},
j0(a,b){var s=a instanceof A.ae?Object.getPrototypeOf(Object.getPrototypeOf(a)).constructor:b,r=A.ip(v.typeUniverse,s.name)
b.$ccache=r
return r},
jF(a){var s,r=v.types,q=r[a]
if(typeof q=="string"){s=A.cg(v.typeUniverse,q,!1)
r[a]=s
return s}return q},
jE(a){return A.ak(A.E(a))},
ex(a){var s
if(a instanceof A.bc)return A.jA(a.$r,a.aA())
s=a instanceof A.ae?A.fU(a):null
if(s!=null)return s
if(t.k.b(a))return J.ho(a).a
if(Array.isArray(a))return A.a6(a)
return A.aC(a)},
ak(a){var s=a.r
return s==null?a.r=A.fD(a):s},
fD(a){var s,r,q=a.as,p=q.replace(/\*/g,"")
if(p===q)return a.r=new A.dr(a)
s=A.cg(v.typeUniverse,p,!0)
r=s.r
return r==null?s.r=A.fD(s):r},
jA(a,b){var s,r,q=b,p=q.length
if(p===0)return t.d
s=A.bi(v.typeUniverse,A.ex(q[0]),"@<0>")
for(r=1;r<p;++r)s=A.fl(v.typeUniverse,s,A.ex(q[r]))
return A.bi(v.typeUniverse,s,a)},
L(a){return A.ak(A.cg(v.typeUniverse,a,!1))},
j_(a){var s,r,q,p,o,n,m=this
if(m===t.K)return A.V(m,a,A.j9)
if(!A.W(m))s=m===t._
else s=!0
if(s)return A.V(m,a,A.jd)
s=m.w
if(s===7)return A.V(m,a,A.iW)
if(s===1)return A.V(m,a,A.fI)
r=s===6?m.x:m
q=r.w
if(q===8)return A.V(m,a,A.j5)
if(r===t.S)p=A.fH
else if(r===t.i||r===t.H)p=A.j8
else if(r===t.N)p=A.jb
else p=r===t.y?A.eu:null
if(p!=null)return A.V(m,a,p)
if(q===9){o=r.x
if(r.y.every(A.jM)){m.f="$i"+o
if(o==="f")return A.V(m,a,A.j7)
return A.V(m,a,A.jc)}}else if(q===11){n=A.jy(r.x,r.y)
return A.V(m,a,n==null?A.fI:n)}return A.V(m,a,A.iU)},
V(a,b,c){a.b=c
return a.b(b)},
iZ(a){var s,r=this,q=A.iT
if(!A.W(r))s=r===t._
else s=!0
if(s)q=A.iL
else if(r===t.K)q=A.iJ
else{s=A.br(r)
if(s)q=A.iV}r.a=q
return r.a(a)},
ci(a){var s=a.w,r=!0
if(!A.W(a))if(!(a===t._))if(!(a===t.A))if(s!==7)if(!(s===6&&A.ci(a.x)))r=s===8&&A.ci(a.x)||a===t.P||a===t.T
return r},
iU(a){var s=this
if(a==null)return A.ci(s)
return A.jN(v.typeUniverse,A.jL(a,s),s)},
iW(a){if(a==null)return!0
return this.x.b(a)},
jc(a){var s,r=this
if(a==null)return A.ci(r)
s=r.f
if(a instanceof A.k)return!!a[s]
return!!J.al(a)[s]},
j7(a){var s,r=this
if(a==null)return A.ci(r)
if(typeof a!="object")return!1
if(Array.isArray(a))return!0
s=r.f
if(a instanceof A.k)return!!a[s]
return!!J.al(a)[s]},
iT(a){var s=this
if(a==null){if(A.br(s))return a}else if(s.b(a))return a
A.fE(a,s)},
iV(a){var s=this
if(a==null)return a
else if(s.b(a))return a
A.fE(a,s)},
fE(a,b){throw A.a(A.ie(A.fa(a,A.C(b,null))))},
fa(a,b){return A.cq(a)+": type '"+A.C(A.ex(a),null)+"' is not a subtype of type '"+b+"'"},
ie(a){return new A.be("TypeError: "+a)},
B(a,b){return new A.be("TypeError: "+A.fa(a,b))},
j5(a){var s=this,r=s.w===6?s.x:s
return r.x.b(a)||A.eh(v.typeUniverse,r).b(a)},
j9(a){return a!=null},
iJ(a){if(a!=null)return a
throw A.a(A.B(a,"Object"))},
jd(a){return!0},
iL(a){return a},
fI(a){return!1},
eu(a){return!0===a||!1===a},
km(a){if(!0===a)return!0
if(!1===a)return!1
throw A.a(A.B(a,"bool"))},
ko(a){if(!0===a)return!0
if(!1===a)return!1
if(a==null)return a
throw A.a(A.B(a,"bool"))},
kn(a){if(!0===a)return!0
if(!1===a)return!1
if(a==null)return a
throw A.a(A.B(a,"bool?"))},
kp(a){if(typeof a=="number")return a
throw A.a(A.B(a,"double"))},
kr(a){if(typeof a=="number")return a
if(a==null)return a
throw A.a(A.B(a,"double"))},
kq(a){if(typeof a=="number")return a
if(a==null)return a
throw A.a(A.B(a,"double?"))},
fH(a){return typeof a=="number"&&Math.floor(a)===a},
fw(a){if(typeof a=="number"&&Math.floor(a)===a)return a
throw A.a(A.B(a,"int"))},
ks(a){if(typeof a=="number"&&Math.floor(a)===a)return a
if(a==null)return a
throw A.a(A.B(a,"int"))},
fx(a){if(typeof a=="number"&&Math.floor(a)===a)return a
if(a==null)return a
throw A.a(A.B(a,"int?"))},
j8(a){return typeof a=="number"},
kt(a){if(typeof a=="number")return a
throw A.a(A.B(a,"num"))},
kv(a){if(typeof a=="number")return a
if(a==null)return a
throw A.a(A.B(a,"num"))},
ku(a){if(typeof a=="number")return a
if(a==null)return a
throw A.a(A.B(a,"num?"))},
jb(a){return typeof a=="string"},
fy(a){if(typeof a=="string")return a
throw A.a(A.B(a,"String"))},
kw(a){if(typeof a=="string")return a
if(a==null)return a
throw A.a(A.B(a,"String"))},
iK(a){if(typeof a=="string")return a
if(a==null)return a
throw A.a(A.B(a,"String?"))},
fM(a,b){var s,r,q
for(s="",r="",q=0;q<a.length;++q,r=", ")s+=r+A.C(a[q],b)
return s},
ji(a,b){var s,r,q,p,o,n,m=a.x,l=a.y
if(""===m)return"("+A.fM(l,b)+")"
s=l.length
r=m.split(",")
q=r.length-s
for(p="(",o="",n=0;n<s;++n,o=", "){p+=o
if(q===0)p+="{"
p+=A.C(l[n],b)
if(q>=0)p+=" "+r[q];++q}return p+"})"},
fF(a3,a4,a5){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1=", ",a2=null
if(a5!=null){s=a5.length
if(a4==null)a4=A.h([],t.s)
else a2=a4.length
r=a4.length
for(q=s;q>0;--q)a4.push("T"+(r+q))
for(p=t.X,o=t._,n="<",m="",q=0;q<s;++q,m=a1){n=n+m+a4[a4.length-1-q]
l=a5[q]
k=l.w
if(!(k===2||k===3||k===4||k===5||l===p))j=l===o
else j=!0
if(!j)n+=" extends "+A.C(l,a4)}n+=">"}else n=""
p=a3.x
i=a3.y
h=i.a
g=h.length
f=i.b
e=f.length
d=i.c
c=d.length
b=A.C(p,a4)
for(a="",a0="",q=0;q<g;++q,a0=a1)a+=a0+A.C(h[q],a4)
if(e>0){a+=a0+"["
for(a0="",q=0;q<e;++q,a0=a1)a+=a0+A.C(f[q],a4)
a+="]"}if(c>0){a+=a0+"{"
for(a0="",q=0;q<c;q+=3,a0=a1){a+=a0
if(d[q+1])a+="required "
a+=A.C(d[q+2],a4)+" "+d[q]}a+="}"}if(a2!=null){a4.toString
a4.length=a2}return n+"("+a+") => "+b},
C(a,b){var s,r,q,p,o,n,m=a.w
if(m===5)return"erased"
if(m===2)return"dynamic"
if(m===3)return"void"
if(m===1)return"Never"
if(m===4)return"any"
if(m===6)return A.C(a.x,b)
if(m===7){s=a.x
r=A.C(s,b)
q=s.w
return(q===12||q===13?"("+r+")":r)+"?"}if(m===8)return"FutureOr<"+A.C(a.x,b)+">"
if(m===9){p=A.jq(a.x)
o=a.y
return o.length>0?p+("<"+A.fM(o,b)+">"):p}if(m===11)return A.ji(a,b)
if(m===12)return A.fF(a,b,null)
if(m===13)return A.fF(a.x,b,a.y)
if(m===14){n=a.x
return b[b.length-1-n]}return"?"},
jq(a){var s=v.mangledGlobalNames[a]
if(s!=null)return s
return"minified:"+a},
iq(a,b){var s=a.tR[b]
for(;typeof s=="string";)s=a.tR[s]
return s},
ip(a,b){var s,r,q,p,o,n=a.eT,m=n[b]
if(m==null)return A.cg(a,b,!1)
else if(typeof m=="number"){s=m
r=A.bh(a,5,"#")
q=A.dz(s)
for(p=0;p<s;++p)q[p]=r
o=A.bg(a,b,q)
n[b]=o
return o}else return m},
io(a,b){return A.fu(a.tR,b)},
im(a,b){return A.fu(a.eT,b)},
cg(a,b,c){var s,r=a.eC,q=r.get(b)
if(q!=null)return q
s=A.ff(A.fd(a,null,b,c))
r.set(b,s)
return s},
bi(a,b,c){var s,r,q=b.z
if(q==null)q=b.z=new Map()
s=q.get(c)
if(s!=null)return s
r=A.ff(A.fd(a,b,c,!0))
q.set(c,r)
return r},
fl(a,b,c){var s,r,q,p=b.Q
if(p==null)p=b.Q=new Map()
s=c.as
r=p.get(s)
if(r!=null)return r
q=A.ek(a,b,c.w===10?c.y:[c])
p.set(s,q)
return q},
T(a,b){b.a=A.iZ
b.b=A.j_
return b},
bh(a,b,c){var s,r,q=a.eC.get(c)
if(q!=null)return q
s=new A.H(null,null)
s.w=b
s.as=c
r=A.T(a,s)
a.eC.set(c,r)
return r},
fk(a,b,c){var s,r=b.as+"*",q=a.eC.get(r)
if(q!=null)return q
s=A.ik(a,b,r,c)
a.eC.set(r,s)
return s},
ik(a,b,c,d){var s,r,q
if(d){s=b.w
if(!A.W(b))r=b===t.P||b===t.T||s===7||s===6
else r=!0
if(r)return b}q=new A.H(null,null)
q.w=6
q.x=b
q.as=c
return A.T(a,q)},
em(a,b,c){var s,r=b.as+"?",q=a.eC.get(r)
if(q!=null)return q
s=A.ij(a,b,r,c)
a.eC.set(r,s)
return s},
ij(a,b,c,d){var s,r,q,p
if(d){s=b.w
r=!0
if(!A.W(b))if(!(b===t.P||b===t.T))if(s!==7)r=s===8&&A.br(b.x)
if(r)return b
else if(s===1||b===t.A)return t.P
else if(s===6){q=b.x
if(q.w===8&&A.br(q.x))return q
else return A.f_(a,b)}}p=new A.H(null,null)
p.w=7
p.x=b
p.as=c
return A.T(a,p)},
fi(a,b,c){var s,r=b.as+"/",q=a.eC.get(r)
if(q!=null)return q
s=A.ih(a,b,r,c)
a.eC.set(r,s)
return s},
ih(a,b,c,d){var s,r
if(d){s=b.w
if(A.W(b)||b===t.K||b===t._)return b
else if(s===1)return A.bg(a,"a_",[b])
else if(b===t.P||b===t.T)return t.W}r=new A.H(null,null)
r.w=8
r.x=b
r.as=c
return A.T(a,r)},
il(a,b){var s,r,q=""+b+"^",p=a.eC.get(q)
if(p!=null)return p
s=new A.H(null,null)
s.w=14
s.x=b
s.as=q
r=A.T(a,s)
a.eC.set(q,r)
return r},
bf(a){var s,r,q,p=a.length
for(s="",r="",q=0;q<p;++q,r=",")s+=r+a[q].as
return s},
ig(a){var s,r,q,p,o,n=a.length
for(s="",r="",q=0;q<n;q+=3,r=","){p=a[q]
o=a[q+1]?"!":":"
s+=r+p+o+a[q+2].as}return s},
bg(a,b,c){var s,r,q,p=b
if(c.length>0)p+="<"+A.bf(c)+">"
s=a.eC.get(p)
if(s!=null)return s
r=new A.H(null,null)
r.w=9
r.x=b
r.y=c
if(c.length>0)r.c=c[0]
r.as=p
q=A.T(a,r)
a.eC.set(p,q)
return q},
ek(a,b,c){var s,r,q,p,o,n
if(b.w===10){s=b.x
r=b.y.concat(c)}else{r=c
s=b}q=s.as+(";<"+A.bf(r)+">")
p=a.eC.get(q)
if(p!=null)return p
o=new A.H(null,null)
o.w=10
o.x=s
o.y=r
o.as=q
n=A.T(a,o)
a.eC.set(q,n)
return n},
fj(a,b,c){var s,r,q="+"+(b+"("+A.bf(c)+")"),p=a.eC.get(q)
if(p!=null)return p
s=new A.H(null,null)
s.w=11
s.x=b
s.y=c
s.as=q
r=A.T(a,s)
a.eC.set(q,r)
return r},
fh(a,b,c){var s,r,q,p,o,n=b.as,m=c.a,l=m.length,k=c.b,j=k.length,i=c.c,h=i.length,g="("+A.bf(m)
if(j>0){s=l>0?",":""
g+=s+"["+A.bf(k)+"]"}if(h>0){s=l>0?",":""
g+=s+"{"+A.ig(i)+"}"}r=n+(g+")")
q=a.eC.get(r)
if(q!=null)return q
p=new A.H(null,null)
p.w=12
p.x=b
p.y=c
p.as=r
o=A.T(a,p)
a.eC.set(r,o)
return o},
el(a,b,c,d){var s,r=b.as+("<"+A.bf(c)+">"),q=a.eC.get(r)
if(q!=null)return q
s=A.ii(a,b,c,r,d)
a.eC.set(r,s)
return s},
ii(a,b,c,d,e){var s,r,q,p,o,n,m,l
if(e){s=c.length
r=A.dz(s)
for(q=0,p=0;p<s;++p){o=c[p]
if(o.w===1){r[p]=o;++q}}if(q>0){n=A.a8(a,b,r,0)
m=A.az(a,c,r,0)
return A.el(a,n,m,c!==m)}}l=new A.H(null,null)
l.w=13
l.x=b
l.y=c
l.as=d
return A.T(a,l)},
fd(a,b,c,d){return{u:a,e:b,r:c,s:[],p:0,n:d}},
ff(a){var s,r,q,p,o,n,m,l=a.r,k=a.s
for(s=l.length,r=0;r<s;){q=l.charCodeAt(r)
if(q>=48&&q<=57)r=A.i8(r+1,q,l,k)
else if((((q|32)>>>0)-97&65535)<26||q===95||q===36||q===124)r=A.fe(a,r,l,k,!1)
else if(q===46)r=A.fe(a,r,l,k,!0)
else{++r
switch(q){case 44:break
case 58:k.push(!1)
break
case 33:k.push(!0)
break
case 59:k.push(A.a5(a.u,a.e,k.pop()))
break
case 94:k.push(A.il(a.u,k.pop()))
break
case 35:k.push(A.bh(a.u,5,"#"))
break
case 64:k.push(A.bh(a.u,2,"@"))
break
case 126:k.push(A.bh(a.u,3,"~"))
break
case 60:k.push(a.p)
a.p=k.length
break
case 62:A.ia(a,k)
break
case 38:A.i9(a,k)
break
case 42:p=a.u
k.push(A.fk(p,A.a5(p,a.e,k.pop()),a.n))
break
case 63:p=a.u
k.push(A.em(p,A.a5(p,a.e,k.pop()),a.n))
break
case 47:p=a.u
k.push(A.fi(p,A.a5(p,a.e,k.pop()),a.n))
break
case 40:k.push(-3)
k.push(a.p)
a.p=k.length
break
case 41:A.i7(a,k)
break
case 91:k.push(a.p)
a.p=k.length
break
case 93:o=k.splice(a.p)
A.fg(a.u,a.e,o)
a.p=k.pop()
k.push(o)
k.push(-1)
break
case 123:k.push(a.p)
a.p=k.length
break
case 125:o=k.splice(a.p)
A.ic(a.u,a.e,o)
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
return A.a5(a.u,a.e,m)},
i8(a,b,c,d){var s,r,q=b-48
for(s=c.length;a<s;++a){r=c.charCodeAt(a)
if(!(r>=48&&r<=57))break
q=q*10+(r-48)}d.push(q)
return a},
fe(a,b,c,d,e){var s,r,q,p,o,n,m=b+1
for(s=c.length;m<s;++m){r=c.charCodeAt(m)
if(r===46){if(e)break
e=!0}else{if(!((((r|32)>>>0)-97&65535)<26||r===95||r===36||r===124))q=r>=48&&r<=57
else q=!0
if(!q)break}}p=c.substring(b,m)
if(e){s=a.u
o=a.e
if(o.w===10)o=o.x
n=A.iq(s,o.x)[p]
if(n==null)A.h0('No "'+p+'" in "'+A.hX(o)+'"')
d.push(A.bi(s,o,n))}else d.push(p)
return m},
ia(a,b){var s,r=a.u,q=A.fc(a,b),p=b.pop()
if(typeof p=="string")b.push(A.bg(r,p,q))
else{s=A.a5(r,a.e,p)
switch(s.w){case 12:b.push(A.el(r,s,q,a.n))
break
default:b.push(A.ek(r,s,q))
break}}},
i7(a,b){var s,r,q,p=a.u,o=b.pop(),n=null,m=null
if(typeof o=="number")switch(o){case-1:n=b.pop()
break
case-2:m=b.pop()
break
default:b.push(o)
break}else b.push(o)
s=A.fc(a,b)
o=b.pop()
switch(o){case-3:o=b.pop()
if(n==null)n=p.sEA
if(m==null)m=p.sEA
r=A.a5(p,a.e,o)
q=new A.c6()
q.a=s
q.b=n
q.c=m
b.push(A.fh(p,r,q))
return
case-4:b.push(A.fj(p,b.pop(),s))
return
default:throw A.a(A.bw("Unexpected state under `()`: "+A.i(o)))}},
i9(a,b){var s=b.pop()
if(0===s){b.push(A.bh(a.u,1,"0&"))
return}if(1===s){b.push(A.bh(a.u,4,"1&"))
return}throw A.a(A.bw("Unexpected extended operation "+A.i(s)))},
fc(a,b){var s=b.splice(a.p)
A.fg(a.u,a.e,s)
a.p=b.pop()
return s},
a5(a,b,c){if(typeof c=="string")return A.bg(a,c,a.sEA)
else if(typeof c=="number"){b.toString
return A.ib(a,b,c)}else return c},
fg(a,b,c){var s,r=c.length
for(s=0;s<r;++s)c[s]=A.a5(a,b,c[s])},
ic(a,b,c){var s,r=c.length
for(s=2;s<r;s+=3)c[s]=A.a5(a,b,c[s])},
ib(a,b,c){var s,r,q=b.w
if(q===10){if(c===0)return b.x
s=b.y
r=s.length
if(c<=r)return s[c-1]
c-=r
b=b.x
q=b.w}else if(c===0)return b
if(q!==9)throw A.a(A.bw("Indexed base must be an interface type"))
s=b.y
if(c<=s.length)return s[c-1]
throw A.a(A.bw("Bad index "+c+" for "+b.h(0)))},
jN(a,b,c){var s,r=b.d
if(r==null)r=b.d=new Map()
s=r.get(c)
if(s==null){s=A.r(a,b,null,c,null,!1)?1:0
r.set(c,s)}if(0===s)return!1
if(1===s)return!0
return!0},
r(a,b,c,d,e,f){var s,r,q,p,o,n,m,l,k,j,i
if(b===d)return!0
if(!A.W(d))s=d===t._
else s=!0
if(s)return!0
r=b.w
if(r===4)return!0
if(A.W(b))return!1
s=b.w
if(s===1)return!0
q=r===14
if(q)if(A.r(a,c[b.x],c,d,e,!1))return!0
p=d.w
s=b===t.P||b===t.T
if(s){if(p===8)return A.r(a,b,c,d.x,e,!1)
return d===t.P||d===t.T||p===7||p===6}if(d===t.K){if(r===8)return A.r(a,b.x,c,d,e,!1)
if(r===6)return A.r(a,b.x,c,d,e,!1)
return r!==7}if(r===6)return A.r(a,b.x,c,d,e,!1)
if(p===6){s=A.f_(a,d)
return A.r(a,b,c,s,e,!1)}if(r===8){if(!A.r(a,b.x,c,d,e,!1))return!1
return A.r(a,A.eh(a,b),c,d,e,!1)}if(r===7){s=A.r(a,t.P,c,d,e,!1)
return s&&A.r(a,b.x,c,d,e,!1)}if(p===8){if(A.r(a,b,c,d.x,e,!1))return!0
return A.r(a,b,c,A.eh(a,d),e,!1)}if(p===7){s=A.r(a,b,c,t.P,e,!1)
return s||A.r(a,b,c,d.x,e,!1)}if(q)return!1
s=r!==12
if((!s||r===13)&&d===t.Z)return!0
o=r===11
if(o&&d===t.L)return!0
if(p===13){if(b===t.g)return!0
if(r!==13)return!1
n=b.y
m=d.y
l=n.length
if(l!==m.length)return!1
c=c==null?n:n.concat(c)
e=e==null?m:m.concat(e)
for(k=0;k<l;++k){j=n[k]
i=m[k]
if(!A.r(a,j,c,i,e,!1)||!A.r(a,i,e,j,c,!1))return!1}return A.fG(a,b.x,c,d.x,e,!1)}if(p===12){if(b===t.g)return!0
if(s)return!1
return A.fG(a,b,c,d,e,!1)}if(r===9){if(p!==9)return!1
return A.j6(a,b,c,d,e,!1)}if(o&&p===11)return A.ja(a,b,c,d,e,!1)
return!1},
fG(a3,a4,a5,a6,a7,a8){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2
if(!A.r(a3,a4.x,a5,a6.x,a7,!1))return!1
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
if(!A.r(a3,p[h],a7,g,a5,!1))return!1}for(h=0;h<m;++h){g=l[h]
if(!A.r(a3,p[o+h],a7,g,a5,!1))return!1}for(h=0;h<i;++h){g=l[m+h]
if(!A.r(a3,k[h],a7,g,a5,!1))return!1}f=s.c
e=r.c
d=f.length
c=e.length
for(b=0,a=0;a<c;a+=3){a0=e[a]
for(;!0;){if(b>=d)return!1
a1=f[b]
b+=3
if(a0<a1)return!1
a2=f[b-2]
if(a1<a0){if(a2)return!1
continue}g=e[a+1]
if(a2&&!g)return!1
g=f[b-1]
if(!A.r(a3,e[a+2],a7,g,a5,!1))return!1
break}}for(;b<d;){if(f[b+1])return!1
b+=3}return!0},
j6(a,b,c,d,e,f){var s,r,q,p,o,n=b.x,m=d.x
for(;n!==m;){s=a.tR[n]
if(s==null)return!1
if(typeof s=="string"){n=s
continue}r=s[m]
if(r==null)return!1
q=r.length
p=q>0?new Array(q):v.typeUniverse.sEA
for(o=0;o<q;++o)p[o]=A.bi(a,b,r[o])
return A.fv(a,p,null,c,d.y,e,!1)}return A.fv(a,b.y,null,c,d.y,e,!1)},
fv(a,b,c,d,e,f,g){var s,r=b.length
for(s=0;s<r;++s)if(!A.r(a,b[s],d,e[s],f,!1))return!1
return!0},
ja(a,b,c,d,e,f){var s,r=b.y,q=d.y,p=r.length
if(p!==q.length)return!1
if(b.x!==d.x)return!1
for(s=0;s<p;++s)if(!A.r(a,r[s],c,q[s],e,!1))return!1
return!0},
br(a){var s=a.w,r=!0
if(!(a===t.P||a===t.T))if(!A.W(a))if(s!==7)if(!(s===6&&A.br(a.x)))r=s===8&&A.br(a.x)
return r},
jM(a){var s
if(!A.W(a))s=a===t._
else s=!0
return s},
W(a){var s=a.w
return s===2||s===3||s===4||s===5||a===t.X},
fu(a,b){var s,r,q=Object.keys(b),p=q.length
for(s=0;s<p;++s){r=q[s]
a[r]=b[r]}},
dz(a){return a>0?new Array(a):v.typeUniverse.sEA},
H:function H(a,b){var _=this
_.a=a
_.b=b
_.r=_.f=_.d=_.c=null
_.w=0
_.as=_.Q=_.z=_.y=_.x=null},
c6:function c6(){this.c=this.b=this.a=null},
dr:function dr(a){this.a=a},
c5:function c5(){},
be:function be(a){this.a=a},
i2(){var s,r,q={}
if(self.scheduleImmediate!=null)return A.jt()
if(self.MutationObserver!=null&&self.document!=null){s=self.document.createElement("div")
r=self.document.createElement("span")
q.a=null
new self.MutationObserver(A.aB(new A.cY(q),1)).observe(s,{childList:true})
return new A.cX(q,s,r)}else if(self.setImmediate!=null)return A.ju()
return A.jv()},
i3(a){self.scheduleImmediate(A.aB(new A.cZ(a),0))},
i4(a){self.setImmediate(A.aB(new A.d_(a),0))},
i5(a){A.id(0,a)},
id(a,b){var s=new A.dp()
s.bb(a,b)
return s},
fK(a){return new A.c0(new A.v($.q,a.i("v<0>")),a.i("c0<0>"))},
fC(a,b){a.$2(0,null)
b.b=!0
return b.a},
fz(a,b){A.iM(a,b)},
fB(a,b){b.ae(a)},
fA(a,b){b.af(A.ab(a),A.a9(a))},
iM(a,b){var s,r,q=new A.dB(b),p=new A.dC(b)
if(a instanceof A.v)a.aF(q,p,t.z)
else{s=t.z
if(a instanceof A.v)a.ar(q,p,s)
else{r=new A.v($.q,t.e)
r.a=8
r.c=a
r.aF(q,p,s)}}},
fR(a){var s=function(b,c){return function(d,e){while(true){try{b(d,e)
break}catch(r){e=r
d=c}}}}(a,1)
return $.q.aZ(new A.dP(s))},
e8(a){var s
if(t.C.b(a)){s=a.gJ()
if(s!=null)return s}return B.f},
j1(a,b){if($.q===B.c)return null
return null},
j2(a,b){if($.q!==B.c)A.j1(a,b)
if(b==null)if(t.C.b(a)){b=a.gJ()
if(b==null){A.eY(a,B.f)
b=B.f}}else b=B.f
else if(t.C.b(a))A.eY(a,b)
return new A.Z(a,b)},
fb(a,b){var s,r
for(;s=a.a,(s&4)!==0;)a=a.c
if(a===b){b.T(new A.F(!0,a,null,"Cannot complete a future with itself"),A.f1())
return}s|=b.a&1
a.a=s
if((s&24)!==0){r=b.ac()
b.U(a)
A.b7(b,r)}else{r=b.c
b.aD(a)
a.ab(r)}},
i6(a,b){var s,r,q={},p=q.a=a
for(;s=p.a,(s&4)!==0;){p=p.c
q.a=p}if(p===b){b.T(new A.F(!0,p,null,"Cannot complete a future with itself"),A.f1())
return}if((s&24)===0){r=b.c
b.aD(p)
q.a.ab(r)
return}if((s&16)===0&&b.c==null){b.U(p)
return}b.a^=2
A.ay(null,null,b.b,new A.d5(q,b))},
b7(a,b){var s,r,q,p,o,n,m,l,k,j,i,h,g={},f=g.a=a
for(;!0;){s={}
r=f.a
q=(r&16)===0
p=!q
if(b==null){if(p&&(r&1)===0){f=f.c
A.ew(f.a,f.b)}return}s.a=b
o=b.a
for(f=b;o!=null;f=o,o=n){f.a=null
A.b7(g.a,f)
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
if(r){A.ew(m.a,m.b)
return}j=$.q
if(j!==k)$.q=k
else j=null
f=f.c
if((f&15)===8)new A.dc(s,g,p).$0()
else if(q){if((f&1)!==0)new A.db(s,m).$0()}else if((f&2)!==0)new A.da(g,s).$0()
if(j!=null)$.q=j
f=s.c
if(f instanceof A.v){r=s.a.$ti
r=r.i("a_<2>").b(f)||!r.y[1].b(f)}else r=!1
if(r){i=s.a.b
if((f.a&24)!==0){h=i.c
i.c=null
b=i.V(h)
i.a=f.a&30|i.a&1
i.c=f.c
g.a=f
continue}else A.fb(f,i)
return}}i=s.a.b
h=i.c
i.c=null
b=i.V(h)
f=s.b
r=s.c
if(!f){i.a=8
i.c=r}else{i.a=i.a&1|16
i.c=r}g.a=i
f=i}},
jj(a,b){if(t.Q.b(a))return b.aZ(a)
if(t.v.b(a))return a
throw A.a(A.eJ(a,"onError",u.c))},
jg(){var s,r
for(s=$.ax;s!=null;s=$.ax){$.bp=null
r=s.b
$.ax=r
if(r==null)$.bo=null
s.a.$0()}},
jn(){$.ev=!0
try{A.jg()}finally{$.bp=null
$.ev=!1
if($.ax!=null)$.eI().$1(A.fT())}},
fO(a){var s=new A.c1(a),r=$.bo
if(r==null){$.ax=$.bo=s
if(!$.ev)$.eI().$1(A.fT())}else $.bo=r.b=s},
jm(a){var s,r,q,p=$.ax
if(p==null){A.fO(a)
$.bp=$.bo
return}s=new A.c1(a)
r=$.bp
if(r==null){s.b=p
$.ax=$.bp=s}else{q=r.b
s.b=q
$.bp=r.b=s
if(q==null)$.bo=s}},
jU(a){var s=null,r=$.q
if(B.c===r){A.ay(s,s,B.c,a)
return}A.ay(s,s,r,r.aH(a))},
k4(a){A.ez(a,"stream",t.K)
return new A.ce()},
ew(a,b){A.jm(new A.dN(a,b))},
fL(a,b,c,d){var s,r=$.q
if(r===c)return d.$0()
$.q=c
s=r
try{r=d.$0()
return r}finally{$.q=s}},
jl(a,b,c,d,e){var s,r=$.q
if(r===c)return d.$1(e)
$.q=c
s=r
try{r=d.$1(e)
return r}finally{$.q=s}},
jk(a,b,c,d,e,f){var s,r=$.q
if(r===c)return d.$2(e,f)
$.q=c
s=r
try{r=d.$2(e,f)
return r}finally{$.q=s}},
ay(a,b,c,d){if(B.c!==c)d=c.aH(d)
A.fO(d)},
cY:function cY(a){this.a=a},
cX:function cX(a,b,c){this.a=a
this.b=b
this.c=c},
cZ:function cZ(a){this.a=a},
d_:function d_(a){this.a=a},
dp:function dp(){},
dq:function dq(a,b){this.a=a
this.b=b},
c0:function c0(a,b){this.a=a
this.b=!1
this.$ti=b},
dB:function dB(a){this.a=a},
dC:function dC(a){this.a=a},
dP:function dP(a){this.a=a},
Z:function Z(a,b){this.a=a
this.b=b},
c2:function c2(){},
b4:function b4(a,b){this.a=a
this.$ti=b},
av:function av(a,b,c,d,e){var _=this
_.a=null
_.b=a
_.c=b
_.d=c
_.e=d
_.$ti=e},
v:function v(a,b){var _=this
_.a=0
_.b=a
_.c=null
_.$ti=b},
d2:function d2(a,b){this.a=a
this.b=b},
d9:function d9(a,b){this.a=a
this.b=b},
d6:function d6(a){this.a=a},
d7:function d7(a){this.a=a},
d8:function d8(a,b,c){this.a=a
this.b=b
this.c=c},
d5:function d5(a,b){this.a=a
this.b=b},
d4:function d4(a,b){this.a=a
this.b=b},
d3:function d3(a,b,c){this.a=a
this.b=b
this.c=c},
dc:function dc(a,b,c){this.a=a
this.b=b
this.c=c},
dd:function dd(a){this.a=a},
db:function db(a,b){this.a=a
this.b=b},
da:function da(a,b){this.a=a
this.b=b},
c1:function c1(a){this.a=a
this.b=null},
ce:function ce(){},
dA:function dA(){},
dN:function dN(a,b){this.a=a
this.b=b},
dg:function dg(){},
dh:function dh(a,b){this.a=a
this.b=b},
eS(a,b,c){return A.jB(a,new A.ag(b.i("@<0>").B(c).i("ag<1,2>")))},
ed(a,b){return new A.ag(a.i("@<0>").B(b).i("ag<1,2>"))},
hH(a){var s,r=A.a6(a),q=new J.Y(a,a.length,r.i("Y<1>"))
if(q.m()){s=q.d
return s==null?r.c.a(s):s}return null},
ee(a){var s,r={}
if(A.eE(a))return"{...}"
s=new A.z("")
try{$.am.push(a)
s.a+="{"
r.a=!0
a.F(0,new A.cE(r,s))
s.a+="}"}finally{$.am.pop()}r=s.a
return r.charCodeAt(0)==0?r:r},
e:function e(){},
P:function P(){},
cE:function cE(a,b){this.a=a
this.b=b},
ch:function ch(){},
aT:function aT(){},
au:function au(a,b){this.a=a
this.$ti=b},
ar:function ar(){},
bj:function bj(){},
jh(a,b){var s,r,q,p=null
try{p=JSON.parse(a)}catch(r){s=A.ab(r)
q=A.x(String(s),null,null)
throw A.a(q)}q=A.dD(p)
return q},
dD(a){var s
if(a==null)return null
if(typeof a!="object")return a
if(!Array.isArray(a))return new A.c7(a,Object.create(null))
for(s=0;s<a.length;++s)a[s]=A.dD(a[s])
return a},
iH(a,b,c){var s,r,q,p,o=c-b
if(o<=4096)s=$.hh()
else s=new Uint8Array(o)
for(r=J.cj(a),q=0;q<o;++q){p=r.k(a,b+q)
if((p&255)!==p)p=255
s[q]=p}return s},
iG(a,b,c,d){var s=a?$.hg():$.hf()
if(s==null)return null
if(0===c&&d===b.length)return A.ft(s,b)
return A.ft(s,b.subarray(c,d))},
ft(a,b){var s,r
try{s=a.decode(b)
return s}catch(r){}return null},
eK(a,b,c,d,e,f){if(B.b.a2(f,4)!==0)throw A.a(A.x("Invalid base64 padding, padded length must be multiple of four, is "+f,a,c))
if(d+e!==f)throw A.a(A.x("Invalid base64 padding, '=' not at the end",a,b))
if(e>2)throw A.a(A.x("Invalid base64 padding, more than two '=' characters",a,b))},
iI(a){switch(a){case 65:return"Missing extension byte"
case 67:return"Unexpected extension byte"
case 69:return"Invalid UTF-8 byte"
case 71:return"Overlong encoding"
case 73:return"Out of unicode range"
case 75:return"Encoded surrogate"
case 77:return"Unfinished UTF-8 octet sequence"
default:return""}},
c7:function c7(a,b){this.a=a
this.b=b
this.c=null},
c8:function c8(a){this.a=a},
dx:function dx(){},
dw:function dw(){},
ck:function ck(){},
cl:function cl(){},
bz:function bz(){},
bB:function bB(){},
cp:function cp(){},
ct:function ct(){},
cs:function cs(){},
cB:function cB(){},
cC:function cC(a){this.a=a},
cT:function cT(){},
cV:function cV(){},
dy:function dy(a){this.b=0
this.c=a},
cU:function cU(a){this.a=a},
dv:function dv(a){this.a=a
this.b=16
this.c=0},
e_(a,b){var s=A.eW(a,b)
if(s!=null)return s
throw A.a(A.x(a,null,null))},
hy(a,b){a=A.a(a)
a.stack=b.h(0)
throw a
throw A.a("unreachable")},
eT(a,b,c,d){var s,r=c?J.hK(a,d):J.hJ(a,d)
if(a!==0&&b!=null)for(s=0;s<r.length;++s)r[s]=b
return r},
hO(a,b,c){var s,r,q=A.h([],c.i("o<0>"))
for(s=a.length,r=0;r<a.length;a.length===s||(0,A.e5)(a),++r)q.push(a[r])
q.$flags=1
return q},
eU(a,b,c){var s=A.hN(a,c)
return s},
hN(a,b){var s,r
if(Array.isArray(a))return A.h(a.slice(0),b.i("o<0>"))
s=A.h([],b.i("o<0>"))
for(r=J.ac(a);r.m();)s.push(r.gn())
return s},
f4(a,b,c){var s,r
A.ef(b,"start")
if(c!=null){s=c-b
if(s<0)throw A.a(A.G(c,b,null,"end",null))
if(s===0)return""}r=A.hY(a,b,c)
return r},
hY(a,b,c){var s=a.length
if(b>=s)return""
return A.hV(a,b,c==null||c>s?s:c)},
eZ(a,b){return new A.cy(a,A.eR(a,!1,b,!1,!1,!1))},
f3(a,b,c){var s=J.ac(b)
if(!s.m())return a
if(c.length===0){do a+=A.i(s.gn())
while(s.m())}else{a+=A.i(s.gn())
for(;s.m();)a=a+c+A.i(s.gn())}return a},
fs(a,b,c,d){var s,r,q,p,o,n="0123456789ABCDEF"
if(c===B.e){s=$.hd()
s=s.b.test(b)}else s=!1
if(s)return b
r=B.D.H(b)
for(s=r.length,q=0,p="";q<s;++q){o=r[q]
if(o<128&&(a[o>>>4]&1<<(o&15))!==0)p+=A.Q(o)
else p=d&&o===32?p+"+":p+"%"+n[o>>>4&15]+n[o&15]}return p.charCodeAt(0)==0?p:p},
iy(a){var s,r,q
if(!$.he())return A.iz(a)
s=new URLSearchParams()
a.F(0,new A.du(s))
r=s.toString()
q=r.length
if(q>0&&r[q-1]==="=")r=B.a.j(r,0,q-1)
return r.replace(/=&|\*|%7E/g,b=>b==="=&"?"&":b==="*"?"%2A":"~")},
f1(){return A.a9(new Error())},
cq(a){if(typeof a=="number"||A.eu(a)||a==null)return J.an(a)
if(typeof a=="string")return JSON.stringify(a)
return A.eX(a)},
hz(a,b){A.ez(a,"error",t.K)
A.ez(b,"stackTrace",t.l)
A.hy(a,b)},
bw(a){return new A.bv(a)},
M(a,b){return new A.F(!1,null,b,a)},
eJ(a,b,c){return new A.F(!0,a,b,c)},
hW(a,b){return new A.b_(null,null,!0,a,b,"Value not in range")},
G(a,b,c,d,e){return new A.b_(b,c,!0,a,d,"Invalid value")},
b0(a,b,c){if(0>a||a>c)throw A.a(A.G(a,0,c,"start",null))
if(b!=null){if(a>b||b>c)throw A.a(A.G(b,a,c,"end",null))
return b}return c},
ef(a,b){if(a<0)throw A.a(A.G(a,0,null,b,null))
return a},
e9(a,b,c,d){return new A.bC(b,!0,a,d,"Index out of range")},
bY(a){return new A.b3(a)},
f6(a){return new A.bV(a)},
f2(a){return new A.b2(a)},
aE(a){return new A.bA(a)},
x(a,b,c){return new A.cr(a,b,c)},
hI(a,b,c){var s,r
if(A.eE(a)){if(b==="("&&c===")")return"(...)"
return b+"..."+c}s=A.h([],t.s)
$.am.push(a)
try{A.je(a,s)}finally{$.am.pop()}r=A.f3(b,s,", ")+c
return r.charCodeAt(0)==0?r:r},
ea(a,b,c){var s,r
if(A.eE(a))return b+"..."+c
s=new A.z(b)
$.am.push(a)
try{r=s
r.a=A.f3(r.a,a,", ")}finally{$.am.pop()}s.a+=c
r=s.a
return r.charCodeAt(0)==0?r:r},
je(a,b){var s,r,q,p,o,n,m,l=a.gA(a),k=0,j=0
while(!0){if(!(k<80||j<3))break
if(!l.m())return
s=A.i(l.gn())
b.push(s)
k+=s.length+2;++j}if(!l.m()){if(j<=5)return
r=b.pop()
q=b.pop()}else{p=l.gn();++j
if(!l.m()){if(j<=4){b.push(A.i(p))
return}r=A.i(p)
q=b.pop()
k+=r.length+2}else{o=l.gn();++j
for(;l.m();p=o,o=n){n=l.gn();++j
if(j>100){while(!0){if(!(k>75&&j>3))break
k-=b.pop().length+2;--j}b.push("...")
return}}q=A.i(p)
r=A.i(o)
k+=r.length+q.length+4}}if(j>b.length+2){k+=5
m="..."}else m=null
while(!0){if(!(k>80&&b.length>3))break
k-=b.pop().length+2
if(m==null){k+=5
m="..."}}if(m!=null)b.push(m)
b.push(q)
b.push(r)},
hS(a,b,c,d){var s
if(B.j===c){s=B.b.gp(a)
b=J.X(b)
return A.ei(A.a3(A.a3($.e6(),s),b))}if(B.j===d){s=B.b.gp(a)
b=J.X(b)
c=J.X(c)
return A.ei(A.a3(A.a3(A.a3($.e6(),s),b),c))}s=B.b.gp(a)
b=J.X(b)
c=J.X(c)
d=J.X(d)
d=A.ei(A.a3(A.a3(A.a3(A.a3($.e6(),s),b),c),d))
return d},
c_(a5){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3=null,a4=a5.length
if(a4>=5){s=((a5.charCodeAt(4)^58)*3|a5.charCodeAt(0)^100|a5.charCodeAt(1)^97|a5.charCodeAt(2)^116|a5.charCodeAt(3)^97)>>>0
if(s===0)return A.f7(a4<a4?B.a.j(a5,0,a4):a5,5,a3).gb0()
else if(s===32)return A.f7(B.a.j(a5,5,a4),0,a3).gb0()}r=A.eT(8,0,!1,t.S)
r[0]=0
r[1]=-1
r[2]=-1
r[7]=-1
r[3]=0
r[4]=0
r[5]=a4
r[6]=a4
if(A.fN(a5,0,a4,0,r)>=14)r[7]=a4
q=r[1]
if(q>=0)if(A.fN(a5,0,q,20,r)===20)r[7]=q
p=r[2]+1
o=r[3]
n=r[4]
m=r[5]
l=r[6]
if(l<m)m=l
if(n<p)n=m
else if(n<=q)n=q+1
if(o<p)o=n
k=r[7]<0
j=a3
if(k){k=!1
if(!(p>q+3)){i=o>0
if(!(i&&o+1===n)){if(!B.a.v(a5,"\\",n))if(p>0)h=B.a.v(a5,"\\",p-1)||B.a.v(a5,"\\",p-2)
else h=!1
else h=!0
if(!h){if(!(m<a4&&m===n+2&&B.a.v(a5,"..",n)))h=m>n+2&&B.a.v(a5,"/..",m-3)
else h=!0
if(!h)if(q===4){if(B.a.v(a5,"file",0)){if(p<=0){if(!B.a.v(a5,"/",n)){g="file:///"
s=3}else{g="file://"
s=2}a5=g+B.a.j(a5,n,a4)
m+=s
l+=s
a4=a5.length
p=7
o=7
n=7}else if(n===m){++l
f=m+1
a5=B.a.I(a5,n,m,"/");++a4
m=f}j="file"}else if(B.a.v(a5,"http",0)){if(i&&o+3===n&&B.a.v(a5,"80",o+1)){l-=3
e=n-3
m-=3
a5=B.a.I(a5,o,n,"")
a4-=3
n=e}j="http"}}else if(q===5&&B.a.v(a5,"https",0)){if(i&&o+4===n&&B.a.v(a5,"443",o+1)){l-=4
e=n-4
m-=4
a5=B.a.I(a5,o,n,"")
a4-=3
n=e}j="https"}k=!h}}}}if(k)return new A.cd(a4<a5.length?B.a.j(a5,0,a4):a5,q,p,o,n,m,l,j)
if(j==null)if(q>0)j=A.iA(a5,0,q)
else{if(q===0)A.aw(a5,0,"Invalid empty scheme")
j=""}d=a3
if(p>0){c=q+3
b=c<p?A.iB(a5,c,p-1):""
a=A.iv(a5,p,o,!1)
i=o+1
if(i<n){a0=A.eW(B.a.j(a5,i,n),a3)
d=A.ix(a0==null?A.h0(A.x("Invalid port",a5,i)):a0,j)}}else{a=a3
b=""}a1=A.iw(a5,n,m,a3,j,a!=null)
a2=m<l?A.ep(a5,m+1,l,a3):a3
return A.en(j,b,a,d,a1,a2,l<a4?A.iu(a5,l+1,a4):a3)},
f9(a){var s=t.N
return B.d.bB(A.h(a.split("&"),t.s),A.ed(s,s),new A.cS(B.e))},
i1(a,b,c){var s,r,q,p,o,n,m="IPv4 address should contain exactly 4 parts",l="each part must be in the range 0..255",k=new A.cP(a),j=new Uint8Array(4)
for(s=b,r=s,q=0;s<c;++s){p=a.charCodeAt(s)
if(p!==46){if((p^48)>9)k.$2("invalid character",s)}else{if(q===3)k.$2(m,s)
o=A.e_(B.a.j(a,r,s),null)
if(o>255)k.$2(l,r)
n=q+1
j[q]=o
r=s+1
q=n}}if(q!==3)k.$2(m,c)
o=A.e_(B.a.j(a,r,c),null)
if(o>255)k.$2(l,r)
j[q]=o
return j},
f8(a,b,a0){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e=null,d=new A.cQ(a),c=new A.cR(d,a)
if(a.length<2)d.$2("address is too short",e)
s=A.h([],t.t)
for(r=b,q=r,p=!1,o=!1;r<a0;++r){n=a.charCodeAt(r)
if(n===58){if(r===b){++r
if(a.charCodeAt(r)!==58)d.$2("invalid start colon.",r)
q=r}if(r===q){if(p)d.$2("only one wildcard `::` is allowed",r)
s.push(-1)
p=!0}else s.push(c.$2(q,r))
q=r+1}else if(n===46)o=!0}if(s.length===0)d.$2("too few parts",e)
m=q===a0
l=B.d.ga0(s)
if(m&&l!==-1)d.$2("expected a part after last `:`",a0)
if(!m)if(!o)s.push(c.$2(q,a0))
else{k=A.i1(a,q,a0)
s.push((k[0]<<8|k[1])>>>0)
s.push((k[2]<<8|k[3])>>>0)}if(p){if(s.length>7)d.$2("an address with a wildcard must have less than 7 parts",e)}else if(s.length!==8)d.$2("an address without a wildcard must contain exactly 8 parts",e)
j=new Uint8Array(16)
for(l=s.length,i=9-l,r=0,h=0;r<l;++r){g=s[r]
if(g===-1)for(f=0;f<i;++f){j[h]=0
j[h+1]=0
h+=2}else{j[h]=B.b.W(g,8)
j[h+1]=g&255
h+=2}}return j},
en(a,b,c,d,e,f,g){return new A.bk(a,b,c,d,e,f,g)},
fm(a){if(a==="http")return 80
if(a==="https")return 443
return 0},
aw(a,b,c){throw A.a(A.x(c,a,b))},
ix(a,b){if(a!=null&&a===A.fm(b))return null
return a},
iv(a,b,c,d){var s,r,q,p,o,n
if(b===c)return""
if(a.charCodeAt(b)===91){s=c-1
if(a.charCodeAt(s)!==93)A.aw(a,b,"Missing end `]` to match `[` in host")
r=b+1
q=A.is(a,r,s)
if(q<s){p=q+1
o=A.fr(a,B.a.v(a,"25",p)?q+3:p,s,"%25")}else o=""
A.f8(a,r,q)
return B.a.j(a,b,q).toLowerCase()+o+"]"}for(n=b;n<c;++n)if(a.charCodeAt(n)===58){q=B.a.a_(a,"%",b)
q=q>=b&&q<c?q:c
if(q<c){p=q+1
o=A.fr(a,B.a.v(a,"25",p)?q+3:p,c,"%25")}else o=""
A.f8(a,b,q)
return"["+B.a.j(a,b,q)+o+"]"}return A.iD(a,b,c)},
is(a,b,c){var s=B.a.a_(a,"%",b)
return s>=b&&s<c?s:c},
fr(a,b,c,d){var s,r,q,p,o,n,m,l,k,j,i=d!==""?new A.z(d):null
for(s=b,r=s,q=!0;s<c;){p=a.charCodeAt(s)
if(p===37){o=A.eq(a,s,!0)
n=o==null
if(n&&q){s+=3
continue}if(i==null)i=new A.z("")
m=i.a+=B.a.j(a,r,s)
if(n)o=B.a.j(a,s,s+3)
else if(o==="%")A.aw(a,s,"ZoneID should not contain % anymore")
i.a=m+o
s+=3
r=s
q=!0}else if(p<127&&(B.i[p>>>4]&1<<(p&15))!==0){if(q&&65<=p&&90>=p){if(i==null)i=new A.z("")
if(r<s){i.a+=B.a.j(a,r,s)
r=s}q=!1}++s}else{l=1
if((p&64512)===55296&&s+1<c){k=a.charCodeAt(s+1)
if((k&64512)===56320){p=(p&1023)<<10|k&1023|65536
l=2}}j=B.a.j(a,r,s)
if(i==null){i=new A.z("")
n=i}else n=i
n.a+=j
m=A.eo(p)
n.a+=m
s+=l
r=s}}if(i==null)return B.a.j(a,b,c)
if(r<c){j=B.a.j(a,r,c)
i.a+=j}n=i.a
return n.charCodeAt(0)==0?n:n},
iD(a,b,c){var s,r,q,p,o,n,m,l,k,j,i
for(s=b,r=s,q=null,p=!0;s<c;){o=a.charCodeAt(s)
if(o===37){n=A.eq(a,s,!0)
m=n==null
if(m&&p){s+=3
continue}if(q==null)q=new A.z("")
l=B.a.j(a,r,s)
if(!p)l=l.toLowerCase()
k=q.a+=l
j=3
if(m)n=B.a.j(a,s,s+3)
else if(n==="%"){n="%25"
j=1}q.a=k+n
s+=j
r=s
p=!0}else if(o<127&&(B.a5[o>>>4]&1<<(o&15))!==0){if(p&&65<=o&&90>=o){if(q==null)q=new A.z("")
if(r<s){q.a+=B.a.j(a,r,s)
r=s}p=!1}++s}else if(o<=93&&(B.r[o>>>4]&1<<(o&15))!==0)A.aw(a,s,"Invalid character")
else{j=1
if((o&64512)===55296&&s+1<c){i=a.charCodeAt(s+1)
if((i&64512)===56320){o=(o&1023)<<10|i&1023|65536
j=2}}l=B.a.j(a,r,s)
if(!p)l=l.toLowerCase()
if(q==null){q=new A.z("")
m=q}else m=q
m.a+=l
k=A.eo(o)
m.a+=k
s+=j
r=s}}if(q==null)return B.a.j(a,b,c)
if(r<c){l=B.a.j(a,r,c)
if(!p)l=l.toLowerCase()
q.a+=l}m=q.a
return m.charCodeAt(0)==0?m:m},
iA(a,b,c){var s,r,q
if(b===c)return""
if(!A.fo(a.charCodeAt(b)))A.aw(a,b,"Scheme not starting with alphabetic character")
for(s=b,r=!1;s<c;++s){q=a.charCodeAt(s)
if(!(q<128&&(B.o[q>>>4]&1<<(q&15))!==0))A.aw(a,s,"Illegal scheme character")
if(65<=q&&q<=90)r=!0}a=B.a.j(a,b,c)
return A.ir(r?a.toLowerCase():a)},
ir(a){if(a==="http")return"http"
if(a==="file")return"file"
if(a==="https")return"https"
if(a==="package")return"package"
return a},
iB(a,b,c){return A.bl(a,b,c,B.a4,!1,!1)},
iw(a,b,c,d,e,f){var s,r=e==="file",q=r||f
if(a==null)return r?"/":""
else s=A.bl(a,b,c,B.p,!0,!0)
if(s.length===0){if(r)return"/"}else if(q&&!B.a.u(s,"/"))s="/"+s
return A.iC(s,e,f)},
iC(a,b,c){var s=b.length===0
if(s&&!c&&!B.a.u(a,"/")&&!B.a.u(a,"\\"))return A.iE(a,!s||c)
return A.iF(a)},
ep(a,b,c,d){if(a!=null){if(d!=null)throw A.a(A.M("Both query and queryParameters specified",null))
return A.bl(a,b,c,B.h,!0,!1)}if(d==null)return null
return A.iy(d)},
iz(a){var s={},r=new A.z("")
s.a=""
a.F(0,new A.ds(new A.dt(s,r)))
s=r.a
return s.charCodeAt(0)==0?s:s},
iu(a,b,c){return A.bl(a,b,c,B.h,!0,!1)},
eq(a,b,c){var s,r,q,p,o,n=b+2
if(n>=a.length)return"%"
s=a.charCodeAt(b+1)
r=a.charCodeAt(n)
q=A.dS(s)
p=A.dS(r)
if(q<0||p<0)return"%"
o=q*16+p
if(o<127&&(B.i[B.b.W(o,4)]&1<<(o&15))!==0)return A.Q(c&&65<=o&&90>=o?(o|32)>>>0:o)
if(s>=97||r>=97)return B.a.j(a,b,b+3).toUpperCase()
return null},
eo(a){var s,r,q,p,o,n="0123456789ABCDEF"
if(a<128){s=new Uint8Array(3)
s[0]=37
s[1]=n.charCodeAt(a>>>4)
s[2]=n.charCodeAt(a&15)}else{if(a>2047)if(a>65535){r=240
q=4}else{r=224
q=3}else{r=192
q=2}s=new Uint8Array(3*q)
for(p=0;--q,q>=0;r=128){o=B.b.bq(a,6*q)&63|r
s[p]=37
s[p+1]=n.charCodeAt(o>>>4)
s[p+2]=n.charCodeAt(o&15)
p+=3}}return A.f4(s,0,null)},
bl(a,b,c,d,e,f){var s=A.fq(a,b,c,d,e,f)
return s==null?B.a.j(a,b,c):s},
fq(a,b,c,d,e,f){var s,r,q,p,o,n,m,l,k,j,i=null
for(s=!e,r=b,q=r,p=i;r<c;){o=a.charCodeAt(r)
if(o<127&&(d[o>>>4]&1<<(o&15))!==0)++r
else{n=1
if(o===37){m=A.eq(a,r,!1)
if(m==null){r+=3
continue}if("%"===m)m="%25"
else n=3}else if(o===92&&f)m="/"
else if(s&&o<=93&&(B.r[o>>>4]&1<<(o&15))!==0){A.aw(a,r,"Invalid character")
n=i
m=n}else{if((o&64512)===55296){l=r+1
if(l<c){k=a.charCodeAt(l)
if((k&64512)===56320){o=(o&1023)<<10|k&1023|65536
n=2}}}m=A.eo(o)}if(p==null){p=new A.z("")
l=p}else l=p
j=l.a+=B.a.j(a,q,r)
l.a=j+A.i(m)
r+=n
q=r}}if(p==null)return i
if(q<c){s=B.a.j(a,q,c)
p.a+=s}s=p.a
return s.charCodeAt(0)==0?s:s},
fp(a){if(B.a.u(a,"."))return!0
return B.a.aS(a,"/.")!==-1},
iF(a){var s,r,q,p,o,n
if(!A.fp(a))return a
s=A.h([],t.s)
for(r=a.split("/"),q=r.length,p=!1,o=0;o<q;++o){n=r[o]
if(n===".."){if(s.length!==0){s.pop()
if(s.length===0)s.push("")}p=!0}else{p="."===n
if(!p)s.push(n)}}if(p)s.push("")
return B.d.aW(s,"/")},
iE(a,b){var s,r,q,p,o,n
if(!A.fp(a))return!b?A.fn(a):a
s=A.h([],t.s)
for(r=a.split("/"),q=r.length,p=!1,o=0;o<q;++o){n=r[o]
if(".."===n){p=s.length!==0&&B.d.ga0(s)!==".."
if(p)s.pop()
else s.push("..")}else{p="."===n
if(!p)s.push(n)}}r=s.length
if(r!==0)r=r===1&&s[0].length===0
else r=!0
if(r)return"./"
if(p||B.d.ga0(s)==="..")s.push("")
if(!b)s[0]=A.fn(s[0])
return B.d.aW(s,"/")},
fn(a){var s,r,q=a.length
if(q>=2&&A.fo(a.charCodeAt(0)))for(s=1;s<q;++s){r=a.charCodeAt(s)
if(r===58)return B.a.j(a,0,s)+"%3A"+B.a.K(a,s+1)
if(r>127||(B.o[r>>>4]&1<<(r&15))===0)break}return a},
it(a,b){var s,r,q
for(s=0,r=0;r<2;++r){q=a.charCodeAt(b+r)
if(48<=q&&q<=57)s=s*16+q-48
else{q|=32
if(97<=q&&q<=102)s=s*16+q-87
else throw A.a(A.M("Invalid URL encoding",null))}}return s},
er(a,b,c,d,e){var s,r,q,p,o=b
while(!0){if(!(o<c)){s=!0
break}r=a.charCodeAt(o)
q=!0
if(r<=127)if(r!==37)q=r===43
if(q){s=!1
break}++o}if(s)if(B.e===d)return B.a.j(a,b,c)
else p=new A.by(B.a.j(a,b,c))
else{p=A.h([],t.t)
for(q=a.length,o=b;o<c;++o){r=a.charCodeAt(o)
if(r>127)throw A.a(A.M("Illegal percent encoding in URI",null))
if(r===37){if(o+3>q)throw A.a(A.M("Truncated URI",null))
p.push(A.it(a,o+1))
o+=2}else if(r===43)p.push(32)
else p.push(r)}}return B.an.H(p)},
fo(a){var s=a|32
return 97<=s&&s<=122},
f7(a,b,c){var s,r,q,p,o,n,m,l,k="Invalid MIME type",j=A.h([b-1],t.t)
for(s=a.length,r=b,q=-1,p=null;r<s;++r){p=a.charCodeAt(r)
if(p===44||p===59)break
if(p===47){if(q<0){q=r
continue}throw A.a(A.x(k,a,r))}}if(q<0&&r>b)throw A.a(A.x(k,a,r))
for(;p!==44;){j.push(r);++r
for(o=-1;r<s;++r){p=a.charCodeAt(r)
if(p===61){if(o<0)o=r}else if(p===59||p===44)break}if(o>=0)j.push(o)
else{n=B.d.ga0(j)
if(p!==44||r!==n+7||!B.a.v(a,"base64",n+1))throw A.a(A.x("Expecting '='",a,r))
break}}j.push(r)
m=r+1
if((j.length&1)===1)a=B.u.bH(a,m,s)
else{l=A.fq(a,m,s,B.h,!0,!1)
if(l!=null)a=B.a.I(a,m,s,l)}return new A.cO(a,j,c)},
iQ(){var s,r,q,p,o,n="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._~!$&'()*+,;=",m=".",l=":",k="/",j="\\",i="?",h="#",g="/\\",f=J.eQ(22,t.D)
for(s=0;s<22;++s)f[s]=new Uint8Array(96)
r=new A.dG(f)
q=new A.dH()
p=new A.dI()
o=r.$2(0,225)
q.$3(o,n,1)
q.$3(o,m,14)
q.$3(o,l,34)
q.$3(o,k,3)
q.$3(o,j,227)
q.$3(o,i,172)
q.$3(o,h,205)
o=r.$2(14,225)
q.$3(o,n,1)
q.$3(o,m,15)
q.$3(o,l,34)
q.$3(o,g,234)
q.$3(o,i,172)
q.$3(o,h,205)
o=r.$2(15,225)
q.$3(o,n,1)
q.$3(o,"%",225)
q.$3(o,l,34)
q.$3(o,k,9)
q.$3(o,j,233)
q.$3(o,i,172)
q.$3(o,h,205)
o=r.$2(1,225)
q.$3(o,n,1)
q.$3(o,l,34)
q.$3(o,k,10)
q.$3(o,j,234)
q.$3(o,i,172)
q.$3(o,h,205)
o=r.$2(2,235)
q.$3(o,n,139)
q.$3(o,k,131)
q.$3(o,j,131)
q.$3(o,m,146)
q.$3(o,i,172)
q.$3(o,h,205)
o=r.$2(3,235)
q.$3(o,n,11)
q.$3(o,k,68)
q.$3(o,j,68)
q.$3(o,m,18)
q.$3(o,i,172)
q.$3(o,h,205)
o=r.$2(4,229)
q.$3(o,n,5)
p.$3(o,"AZ",229)
q.$3(o,l,102)
q.$3(o,"@",68)
q.$3(o,"[",232)
q.$3(o,k,138)
q.$3(o,j,138)
q.$3(o,i,172)
q.$3(o,h,205)
o=r.$2(5,229)
q.$3(o,n,5)
p.$3(o,"AZ",229)
q.$3(o,l,102)
q.$3(o,"@",68)
q.$3(o,k,138)
q.$3(o,j,138)
q.$3(o,i,172)
q.$3(o,h,205)
o=r.$2(6,231)
p.$3(o,"19",7)
q.$3(o,"@",68)
q.$3(o,k,138)
q.$3(o,j,138)
q.$3(o,i,172)
q.$3(o,h,205)
o=r.$2(7,231)
p.$3(o,"09",7)
q.$3(o,"@",68)
q.$3(o,k,138)
q.$3(o,j,138)
q.$3(o,i,172)
q.$3(o,h,205)
q.$3(r.$2(8,8),"]",5)
o=r.$2(9,235)
q.$3(o,n,11)
q.$3(o,m,16)
q.$3(o,g,234)
q.$3(o,i,172)
q.$3(o,h,205)
o=r.$2(16,235)
q.$3(o,n,11)
q.$3(o,m,17)
q.$3(o,g,234)
q.$3(o,i,172)
q.$3(o,h,205)
o=r.$2(17,235)
q.$3(o,n,11)
q.$3(o,k,9)
q.$3(o,j,233)
q.$3(o,i,172)
q.$3(o,h,205)
o=r.$2(10,235)
q.$3(o,n,11)
q.$3(o,m,18)
q.$3(o,k,10)
q.$3(o,j,234)
q.$3(o,i,172)
q.$3(o,h,205)
o=r.$2(18,235)
q.$3(o,n,11)
q.$3(o,m,19)
q.$3(o,g,234)
q.$3(o,i,172)
q.$3(o,h,205)
o=r.$2(19,235)
q.$3(o,n,11)
q.$3(o,g,234)
q.$3(o,i,172)
q.$3(o,h,205)
o=r.$2(11,235)
q.$3(o,n,11)
q.$3(o,k,10)
q.$3(o,j,234)
q.$3(o,i,172)
q.$3(o,h,205)
o=r.$2(12,236)
q.$3(o,n,12)
q.$3(o,i,12)
q.$3(o,h,205)
o=r.$2(13,237)
q.$3(o,n,13)
q.$3(o,i,13)
p.$3(r.$2(20,245),"az",21)
o=r.$2(21,245)
p.$3(o,"az",21)
p.$3(o,"09",21)
q.$3(o,"+-.",21)
return f},
fN(a,b,c,d,e){var s,r,q,p,o=$.hi()
for(s=b;s<c;++s){r=o[d]
q=a.charCodeAt(s)^96
p=r[q>95?31:q]
d=p&31
e[p>>>5]=s}return d},
du:function du(a){this.a=a},
d0:function d0(){},
l:function l(){},
bv:function bv(a){this.a=a},
R:function R(){},
F:function F(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
b_:function b_(a,b,c,d,e,f){var _=this
_.e=a
_.f=b
_.a=c
_.b=d
_.c=e
_.d=f},
bC:function bC(a,b,c,d,e){var _=this
_.f=a
_.a=b
_.b=c
_.c=d
_.d=e},
b3:function b3(a){this.a=a},
bV:function bV(a){this.a=a},
b2:function b2(a){this.a=a},
bA:function bA(a){this.a=a},
bR:function bR(){},
b1:function b1(){},
d1:function d1(a){this.a=a},
cr:function cr(a,b,c){this.a=a
this.b=b
this.c=c},
n:function n(){},
u:function u(){},
k:function k(){},
cf:function cf(){},
z:function z(a){this.a=a},
cS:function cS(a){this.a=a},
cP:function cP(a){this.a=a},
cQ:function cQ(a){this.a=a},
cR:function cR(a,b){this.a=a
this.b=b},
bk:function bk(a,b,c,d,e,f,g){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f
_.r=g
_.z=_.y=_.w=$},
dt:function dt(a,b){this.a=a
this.b=b},
ds:function ds(a){this.a=a},
cO:function cO(a,b,c){this.a=a
this.b=b
this.c=c},
dG:function dG(a){this.a=a},
dH:function dH(){},
dI:function dI(){},
cd:function cd(a,b,c,d,e,f,g,h){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f
_.r=g
_.w=h
_.x=null},
c4:function c4(a,b,c,d,e,f,g){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f
_.r=g
_.z=_.y=_.w=$},
a7(a){var s
if(typeof a=="function")throw A.a(A.M("Attempting to rewrap a JS function.",null))
s=function(b,c){return function(d){return b(c,d,arguments.length)}}(A.iN,a)
s[$.eH()]=a
return s},
iN(a,b,c){if(c>=1)return a.$1(b)
return a.$0()},
e2(a,b){var s=new A.v($.q,b.i("v<0>")),r=new A.b4(s,b.i("b4<0>"))
a.then(A.aB(new A.e3(r),1),A.aB(new A.e4(r),1))
return s},
e3:function e3(a){this.a=a},
e4:function e4(a){this.a=a},
cG:function cG(a){this.a=a},
m:function m(a,b){this.a=a
this.b=b},
hC(a){var s,r,q,p,o,n,m,l,k="enclosedBy"
if(a.k(0,k)!=null){s=t.a.a(a.k(0,k))
r=new A.co(A.fy(s.k(0,"name")),B.q[A.fw(s.k(0,"kind"))],A.fy(s.k(0,"href")))}else r=null
q=a.k(0,"name")
p=a.k(0,"qualifiedName")
o=A.fx(a.k(0,"packageRank"))
if(o==null)o=0
n=a.k(0,"href")
m=B.q[A.fw(a.k(0,"kind"))]
l=A.fx(a.k(0,"overriddenDepth"))
if(l==null)l=0
return new A.w(q,p,o,m,n,l,a.k(0,"desc"),r)},
A:function A(a,b){this.a=a
this.b=b},
cu:function cu(a){this.a=a},
cx:function cx(a,b){this.a=a
this.b=b},
cv:function cv(){},
cw:function cw(){},
w:function w(a,b,c,d,e,f,g,h){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f
_.r=g
_.w=h},
co:function co(a,b,c){this.a=a
this.b=b
this.c=c},
jG(){var s=self,r=s.document.getElementById("search-box"),q=s.document.getElementById("search-body"),p=s.document.getElementById("search-sidebar")
A.e2(s.window.fetch($.bt()+"index.json"),t.m).aq(new A.dX(new A.dY(r,q,p),r,q,p),t.P)},
ej(a){var s=A.h([],t.O),r=A.h([],t.M)
return new A.di(a,A.c_(self.window.location.href),s,r)},
iP(a,b){var s,r,q,p,o,n,m,l=self,k=l.document.createElement("div"),j=b.e
if(j==null)j=""
k.setAttribute("data-href",j)
k.classList.add("tt-suggestion")
s=l.document.createElement("span")
s.classList.add("tt-suggestion-title")
s.innerHTML=A.es(b.a+" "+b.d.h(0).toLowerCase(),a)
k.appendChild(s)
r=b.w
j=r!=null
if(j){s=l.document.createElement("span")
s.classList.add("tt-suggestion-container")
s.innerHTML="(in "+A.es(r.a,a)+")"
k.appendChild(s)}q=b.r
if(q!=null&&q.length!==0){s=l.document.createElement("blockquote")
s.classList.add("one-line-description")
p=l.document.createElement("textarea")
p.innerHTML=q
s.setAttribute("title",p.value)
s.innerHTML=A.es(q,a)
k.appendChild(s)}k.addEventListener("mousedown",A.a7(new A.dE()))
k.addEventListener("click",A.a7(new A.dF(b)))
if(j){j=r.a
o=r.b.h(0)
n=r.c
s=l.document.createElement("div")
s.classList.add("tt-container")
p=l.document.createElement("p")
p.textContent="Results from "
p.classList.add("tt-container-text")
m=l.document.createElement("a")
m.setAttribute("href",n)
m.innerHTML=j+" "+o
p.appendChild(m)
s.appendChild(p)
A.jf(s,k)}return k},
jf(a,b){var s,r=a.innerHTML
if(r.length===0)return
s=$.bn.k(0,r)
if(s!=null)s.appendChild(b)
else{a.appendChild(b)
$.bn.q(0,r,a)}},
es(a,b){return A.jX(a,A.eZ(b,!1),new A.dJ(),null)},
dK:function dK(){},
dY:function dY(a,b,c){this.a=a
this.b=b
this.c=c},
dX:function dX(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
di:function di(a,b,c,d){var _=this
_.a=a
_.b=b
_.e=_.d=_.c=$
_.f=null
_.r=""
_.w=c
_.x=d
_.y=-1},
dj:function dj(a){this.a=a},
dk:function dk(a,b){this.a=a
this.b=b},
dl:function dl(a,b){this.a=a
this.b=b},
dm:function dm(a,b){this.a=a
this.b=b},
dn:function dn(a,b){this.a=a
this.b=b},
dE:function dE(){},
dF:function dF(a){this.a=a},
dJ:function dJ(){},
iY(){var s=self,r=s.document.getElementById("sidenav-left-toggle"),q=s.document.querySelector(".sidebar-offcanvas-left"),p=s.document.getElementById("overlay-under-drawer"),o=A.a7(new A.dL(q,p))
if(p!=null)p.addEventListener("click",o)
if(r!=null)r.addEventListener("click",o)},
iX(){var s,r,q,p,o=self,n=o.document.body
if(n==null)return
s=n.getAttribute("data-using-base-href")
if(s==null)return
if(s!=="true"){r=n.getAttribute("data-base-href")
if(r==null)return
q=r}else q=""
p=o.document.getElementById("dartdoc-main-content")
if(p==null)return
A.fJ(q,p.getAttribute("data-above-sidebar"),o.document.getElementById("dartdoc-sidebar-left-content"))
A.fJ(q,p.getAttribute("data-below-sidebar"),o.document.getElementById("dartdoc-sidebar-right"))},
fJ(a,b,c){if(b==null||b.length===0||c==null)return
A.e2(self.window.fetch(a+A.i(b)),t.m).aq(new A.dM(c,a),t.P)},
fQ(a,b){var s,r,q,p
if(b.nodeName.toLowerCase()==="a"){s=b.getAttribute("href")
if(s!=null)if(!A.c_(s).gaV())b.href=a+s}r=b.childNodes
for(q=0;q<r.length;++q){p=r.item(q)
if(p!=null)A.fQ(a,p)}},
dL:function dL(a,b){this.a=a
this.b=b},
dM:function dM(a,b){this.a=a
this.b=b},
jH(){var s,r,q,p=self,o=p.document.body
if(o==null)return
s=p.document.getElementById("theme")
if(s==null)s=t.m.a(s)
r=new A.dZ(s,o)
s.addEventListener("change",A.a7(new A.dW(r)))
q=p.window.localStorage.getItem("colorTheme")
if(q!=null){s.checked=q==="true"
r.$0()}},
dZ:function dZ(a,b){this.a=a
this.b=b},
dW:function dW(a){this.a=a},
jS(a){if(typeof dartPrint=="function"){dartPrint(a)
return}if(typeof console=="object"&&typeof console.log!="undefined"){console.log(a)
return}if(typeof print=="function"){print(a)
return}throw"Unable to print message: "+String(a)},
jY(a){A.eG(new A.aS("Field '"+a+"' has been assigned during initialization."),new Error())},
bs(){A.eG(new A.aS("Field '' has been assigned during initialization."),new Error())},
jP(){A.iX()
A.iY()
A.jG()
var s=self.hljs
if(s!=null)s.highlightAll()
A.jH()}},B={}
var w=[A,J,B]
var $={}
A.eb.prototype={}
J.bD.prototype={
E(a,b){return a===b},
gp(a){return A.bT(a)},
h(a){return"Instance of '"+A.cI(a)+"'"},
gt(a){return A.ak(A.et(this))}}
J.bE.prototype={
h(a){return String(a)},
gp(a){return a?519018:218159},
gt(a){return A.ak(t.y)},
$ij:1}
J.aN.prototype={
E(a,b){return null==b},
h(a){return"null"},
gp(a){return 0},
$ij:1,
$iu:1}
J.aQ.prototype={$ip:1}
J.a1.prototype={
gp(a){return 0},
h(a){return String(a)}}
J.bS.prototype={}
J.as.prototype={}
J.a0.prototype={
h(a){var s=a[$.eH()]
if(s==null)return this.ba(a)
return"JavaScript function for "+J.an(s)}}
J.aP.prototype={
gp(a){return 0},
h(a){return String(a)}}
J.aR.prototype={
gp(a){return 0},
h(a){return String(a)}}
J.o.prototype={
Y(a,b){return new A.N(a,A.a6(a).i("@<1>").B(b).i("N<1,2>"))},
Z(a){a.$flags&1&&A.K(a,"clear","clear")
a.length=0},
aW(a,b){var s,r=A.eT(a.length,"",!1,t.N)
for(s=0;s<a.length;++s)r[s]=A.i(a[s])
return r.join(b)},
bA(a,b,c){var s,r,q=a.length
for(s=b,r=0;r<q;++r){s=c.$2(s,a[r])
if(a.length!==q)throw A.a(A.aE(a))}return s},
bB(a,b,c){return this.bA(a,b,c,t.z)},
C(a,b){return a[b]},
b9(a,b,c){var s=a.length
if(b>s)throw A.a(A.G(b,0,s,"start",null))
if(c<b||c>s)throw A.a(A.G(c,b,s,"end",null))
if(b===c)return A.h([],A.a6(a))
return A.h(a.slice(b,c),A.a6(a))},
ga0(a){var s=a.length
if(s>0)return a[s-1]
throw A.a(A.hG())},
b8(a,b){var s,r,q,p,o
a.$flags&2&&A.K(a,"sort")
s=a.length
if(s<2)return
if(b==null)b=J.j3()
if(s===2){r=a[0]
q=a[1]
if(b.$2(r,q)>0){a[0]=q
a[1]=r}return}p=0
if(A.a6(a).c.b(null))for(o=0;o<a.length;++o)if(a[o]===void 0){a[o]=null;++p}a.sort(A.aB(b,2))
if(p>0)this.bo(a,p)},
bo(a,b){var s,r=a.length
for(;s=r-1,r>0;r=s)if(a[s]===null){a[s]=void 0;--b
if(b===0)break}},
h(a){return A.ea(a,"[","]")},
gA(a){return new J.Y(a,a.length,A.a6(a).i("Y<1>"))},
gp(a){return A.bT(a)},
gl(a){return a.length},
k(a,b){if(!(b>=0&&b<a.length))throw A.a(A.eB(a,b))
return a[b]},
q(a,b,c){a.$flags&2&&A.K(a)
if(!(b>=0&&b<a.length))throw A.a(A.eB(a,b))
a[b]=c},
$ic:1,
$if:1}
J.cz.prototype={}
J.Y.prototype={
gn(){var s=this.d
return s==null?this.$ti.c.a(s):s},
m(){var s,r=this,q=r.a,p=q.length
if(r.b!==p)throw A.a(A.e5(q))
s=r.c
if(s>=p){r.d=null
return!1}r.d=q[s]
r.c=s+1
return!0}}
J.aO.prototype={
aJ(a,b){var s
if(a<b)return-1
else if(a>b)return 1
else if(a===b){if(a===0){s=this.gal(b)
if(this.gal(a)===s)return 0
if(this.gal(a))return-1
return 1}return 0}else if(isNaN(a)){if(isNaN(b))return 0
return 1}else return-1},
gal(a){return a===0?1/a<0:a<0},
h(a){if(a===0&&1/a<0)return"-0.0"
else return""+a},
gp(a){var s,r,q,p,o=a|0
if(a===o)return o&536870911
s=Math.abs(a)
r=Math.log(s)/0.6931471805599453|0
q=Math.pow(2,r)
p=s<1?s/q:q/s
return((p*9007199254740992|0)+(p*3542243181176521|0))*599197+r*1259&536870911},
a2(a,b){var s=a%b
if(s===0)return 0
if(s>0)return s
return s+b},
br(a,b){return(a|0)===a?a/b|0:this.bs(a,b)},
bs(a,b){var s=a/b
if(s>=-2147483648&&s<=2147483647)return s|0
if(s>0){if(s!==1/0)return Math.floor(s)}else if(s>-1/0)return Math.ceil(s)
throw A.a(A.bY("Result of truncating division is "+A.i(s)+": "+A.i(a)+" ~/ "+b))},
W(a,b){var s
if(a>0)s=this.aE(a,b)
else{s=b>31?31:b
s=a>>s>>>0}return s},
bq(a,b){if(0>b)throw A.a(A.js(b))
return this.aE(a,b)},
aE(a,b){return b>31?0:a>>>b},
gt(a){return A.ak(t.H)},
$it:1}
J.aM.prototype={
gt(a){return A.ak(t.S)},
$ij:1,
$ib:1}
J.bF.prototype={
gt(a){return A.ak(t.i)},
$ij:1}
J.af.prototype={
I(a,b,c,d){var s=A.b0(b,c,a.length)
return a.substring(0,b)+d+a.substring(s)},
v(a,b,c){var s
if(c<0||c>a.length)throw A.a(A.G(c,0,a.length,null,null))
s=c+b.length
if(s>a.length)return!1
return b===a.substring(c,s)},
u(a,b){return this.v(a,b,0)},
j(a,b,c){return a.substring(b,A.b0(b,c,a.length))},
K(a,b){return this.j(a,b,null)},
b5(a,b){var s,r
if(0>=b)return""
if(b===1||a.length===0)return a
if(b!==b>>>0)throw A.a(B.C)
for(s=a,r="";!0;){if((b&1)===1)r=s+r
b=b>>>1
if(b===0)break
s+=s}return r},
a_(a,b,c){var s
if(c<0||c>a.length)throw A.a(A.G(c,0,a.length,null,null))
s=a.indexOf(b,c)
return s},
aS(a,b){return this.a_(a,b,0)},
O(a,b){return A.jW(a,b,0)},
aJ(a,b){var s
if(a===b)s=0
else s=a<b?-1:1
return s},
h(a){return a},
gp(a){var s,r,q
for(s=a.length,r=0,q=0;q<s;++q){r=r+a.charCodeAt(q)&536870911
r=r+((r&524287)<<10)&536870911
r^=r>>6}r=r+((r&67108863)<<3)&536870911
r^=r>>11
return r+((r&16383)<<15)&536870911},
gt(a){return A.ak(t.N)},
gl(a){return a.length},
$ij:1,
$id:1}
A.a4.prototype={
gA(a){return new A.bx(J.ac(this.gN()),A.E(this).i("bx<1,2>"))},
gl(a){return J.bu(this.gN())},
C(a,b){return A.E(this).y[1].a(J.e7(this.gN(),b))},
h(a){return J.an(this.gN())}}
A.bx.prototype={
m(){return this.a.m()},
gn(){return this.$ti.y[1].a(this.a.gn())}}
A.ad.prototype={
gN(){return this.a}}
A.b6.prototype={$ic:1}
A.b5.prototype={
k(a,b){return this.$ti.y[1].a(J.hj(this.a,b))},
q(a,b,c){J.hk(this.a,b,this.$ti.c.a(c))},
$ic:1,
$if:1}
A.N.prototype={
Y(a,b){return new A.N(this.a,this.$ti.i("@<1>").B(b).i("N<1,2>"))},
gN(){return this.a}}
A.aS.prototype={
h(a){return"LateInitializationError: "+this.a}}
A.by.prototype={
gl(a){return this.a.length},
k(a,b){return this.a.charCodeAt(b)}}
A.cJ.prototype={}
A.c.prototype={}
A.J.prototype={
gA(a){var s=this
return new A.ao(s,s.gl(s),A.E(s).i("ao<J.E>"))}}
A.ao.prototype={
gn(){var s=this.d
return s==null?this.$ti.c.a(s):s},
m(){var s,r=this,q=r.a,p=J.cj(q),o=p.gl(q)
if(r.b!==o)throw A.a(A.aE(q))
s=r.c
if(s>=o){r.d=null
return!1}r.d=p.C(q,s);++r.c
return!0}}
A.ah.prototype={
gA(a){return new A.ap(J.ac(this.a),this.b,A.E(this).i("ap<1,2>"))},
gl(a){return J.bu(this.a)},
C(a,b){return this.b.$1(J.e7(this.a,b))}}
A.aJ.prototype={$ic:1}
A.ap.prototype={
m(){var s=this,r=s.b
if(r.m()){s.a=s.c.$1(r.gn())
return!0}s.a=null
return!1},
gn(){var s=this.a
return s==null?this.$ti.y[1].a(s):s}}
A.ai.prototype={
gl(a){return J.bu(this.a)},
C(a,b){return this.b.$1(J.e7(this.a,b))}}
A.aL.prototype={}
A.bX.prototype={
q(a,b,c){throw A.a(A.bY("Cannot modify an unmodifiable list"))}}
A.at.prototype={}
A.bm.prototype={}
A.cc.prototype={$r:"+item,matchPosition(1,2)",$s:1}
A.aF.prototype={
h(a){return A.ee(this)},
q(a,b,c){A.hx()},
$iy:1}
A.aH.prototype={
gl(a){return this.b.length},
gbl(){var s=this.$keys
if(s==null){s=Object.keys(this.a)
this.$keys=s}return s},
P(a){if("__proto__"===a)return!1
return this.a.hasOwnProperty(a)},
k(a,b){if(!this.P(b))return null
return this.b[this.a[b]]},
F(a,b){var s,r,q=this.gbl(),p=this.b
for(s=q.length,r=0;r<s;++r)b.$2(q[r],p[r])}}
A.c9.prototype={
gn(){var s=this.d
return s==null?this.$ti.c.a(s):s},
m(){var s=this,r=s.c
if(r>=s.b){s.d=null
return!1}s.d=s.a[r]
s.c=r+1
return!0}}
A.aG.prototype={}
A.aI.prototype={
gl(a){return this.b},
gA(a){var s,r=this,q=r.$keys
if(q==null){q=Object.keys(r.a)
r.$keys=q}s=q
return new A.c9(s,s.length,r.$ti.i("c9<1>"))},
O(a,b){if("__proto__"===b)return!1
return this.a.hasOwnProperty(b)}}
A.cM.prototype={
D(a){var s,r,q=this,p=new RegExp(q.a).exec(a)
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
A.aZ.prototype={
h(a){return"Null check operator used on a null value"}}
A.bG.prototype={
h(a){var s,r=this,q="NoSuchMethodError: method not found: '",p=r.b
if(p==null)return"NoSuchMethodError: "+r.a
s=r.c
if(s==null)return q+p+"' ("+r.a+")"
return q+p+"' on '"+s+"' ("+r.a+")"}}
A.bW.prototype={
h(a){var s=this.a
return s.length===0?"Error":"Error: "+s}}
A.cH.prototype={
h(a){return"Throw of null ('"+(this.a===null?"null":"undefined")+"' from JavaScript)"}}
A.aK.prototype={}
A.bd.prototype={
h(a){var s,r=this.b
if(r!=null)return r
r=this.a
s=r!==null&&typeof r==="object"?r.stack:null
return this.b=s==null?"":s},
$ia2:1}
A.ae.prototype={
h(a){var s=this.constructor,r=s==null?null:s.name
return"Closure '"+A.h1(r==null?"unknown":r)+"'"},
gbQ(){return this},
$C:"$1",
$R:1,
$D:null}
A.cm.prototype={$C:"$0",$R:0}
A.cn.prototype={$C:"$2",$R:2}
A.cL.prototype={}
A.cK.prototype={
h(a){var s=this.$static_name
if(s==null)return"Closure of unknown static method"
return"Closure '"+A.h1(s)+"'"}}
A.aD.prototype={
E(a,b){if(b==null)return!1
if(this===b)return!0
if(!(b instanceof A.aD))return!1
return this.$_target===b.$_target&&this.a===b.a},
gp(a){return(A.fY(this.a)^A.bT(this.$_target))>>>0},
h(a){return"Closure '"+this.$_name+"' of "+("Instance of '"+A.cI(this.a)+"'")}}
A.c3.prototype={
h(a){return"Reading static variable '"+this.a+"' during its initialization"}}
A.bU.prototype={
h(a){return"RuntimeError: "+this.a}}
A.ag.prototype={
gl(a){return this.a},
gR(){return new A.O(this,A.E(this).i("O<1>"))},
gb2(){var s=A.E(this)
return A.hP(new A.O(this,s.i("O<1>")),new A.cA(this),s.c,s.y[1])},
P(a){var s=this.b
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
return q}else return this.bF(b)},
bF(a){var s,r,q=this.d
if(q==null)return null
s=q[this.aT(a)]
r=this.aU(s,a)
if(r<0)return null
return s[r].b},
q(a,b,c){var s,r,q,p,o,n,m=this
if(typeof b=="string"){s=m.b
m.au(s==null?m.b=m.a9():s,b,c)}else if(typeof b=="number"&&(b&0x3fffffff)===b){r=m.c
m.au(r==null?m.c=m.a9():r,b,c)}else{q=m.d
if(q==null)q=m.d=m.a9()
p=m.aT(b)
o=q[p]
if(o==null)q[p]=[m.aa(b,c)]
else{n=m.aU(o,b)
if(n>=0)o[n].b=c
else o.push(m.aa(b,c))}}},
Z(a){var s=this
if(s.a>0){s.b=s.c=s.d=s.e=s.f=null
s.a=0
s.aB()}},
F(a,b){var s=this,r=s.e,q=s.r
for(;r!=null;){b.$2(r.a,r.b)
if(q!==s.r)throw A.a(A.aE(s))
r=r.c}},
au(a,b,c){var s=a[b]
if(s==null)a[b]=this.aa(b,c)
else s.b=c},
aB(){this.r=this.r+1&1073741823},
aa(a,b){var s=this,r=new A.cD(a,b)
if(s.e==null)s.e=s.f=r
else s.f=s.f.c=r;++s.a
s.aB()
return r},
aT(a){return J.X(a)&1073741823},
aU(a,b){var s,r
if(a==null)return-1
s=a.length
for(r=0;r<s;++r)if(J.I(a[r].a,b))return r
return-1},
h(a){return A.ee(this)},
a9(){var s=Object.create(null)
s["<non-identifier-key>"]=s
delete s["<non-identifier-key>"]
return s}}
A.cA.prototype={
$1(a){var s=this.a,r=s.k(0,a)
return r==null?A.E(s).y[1].a(r):r},
$S(){return A.E(this.a).i("2(1)")}}
A.cD.prototype={}
A.O.prototype={
gl(a){return this.a.a},
gA(a){var s=this.a,r=new A.bH(s,s.r)
r.c=s.e
return r}}
A.bH.prototype={
gn(){return this.d},
m(){var s,r=this,q=r.a
if(r.b!==q.r)throw A.a(A.aE(q))
s=r.c
if(s==null){r.d=null
return!1}else{r.d=s.a
r.c=s.c
return!0}}}
A.dT.prototype={
$1(a){return this.a(a)},
$S:10}
A.dU.prototype={
$2(a,b){return this.a(a,b)},
$S:11}
A.dV.prototype={
$1(a){return this.a(a)},
$S:12}
A.bc.prototype={
h(a){return this.aG(!1)},
aG(a){var s,r,q,p,o,n=this.bj(),m=this.aA(),l=(a?""+"Record ":"")+"("
for(s=n.length,r="",q=0;q<s;++q,r=", "){l+=r
p=n[q]
if(typeof p=="string")l=l+p+": "
o=m[q]
l=a?l+A.eX(o):l+A.i(o)}l+=")"
return l.charCodeAt(0)==0?l:l},
bj(){var s,r=this.$s
for(;$.df.length<=r;)$.df.push(null)
s=$.df[r]
if(s==null){s=this.be()
$.df[r]=s}return s},
be(){var s,r,q,p=this.$r,o=p.indexOf("("),n=p.substring(1,o),m=p.substring(o),l=m==="()"?0:m.replace(/[^,]/g,"").length+1,k=t.K,j=J.eQ(l,k)
for(s=0;s<l;++s)j[s]=s
if(n!==""){r=n.split(",")
s=r.length
for(q=l;s>0;){--q;--s
j[q]=r[s]}}j=A.hO(j,!1,k)
j.$flags=3
return j}}
A.cb.prototype={
aA(){return[this.a,this.b]},
E(a,b){if(b==null)return!1
return b instanceof A.cb&&this.$s===b.$s&&J.I(this.a,b.a)&&J.I(this.b,b.b)},
gp(a){return A.hS(this.$s,this.a,this.b,B.j)}}
A.cy.prototype={
h(a){return"RegExp/"+this.a+"/"+this.b.flags},
gbm(){var s=this,r=s.c
if(r!=null)return r
r=s.b
return s.c=A.eR(s.a,r.multiline,!r.ignoreCase,r.unicode,r.dotAll,!0)},
bi(a,b){var s,r=this.gbm()
r.lastIndex=b
s=r.exec(a)
if(s==null)return null
return new A.ca(s)}}
A.ca.prototype={
gby(){var s=this.b
return s.index+s[0].length},
k(a,b){return this.b[b]},
$icF:1,
$ieg:1}
A.cW.prototype={
gn(){var s=this.d
return s==null?t.F.a(s):s},
m(){var s,r,q,p,o,n,m=this,l=m.b
if(l==null)return!1
s=m.c
r=l.length
if(s<=r){q=m.a
p=q.bi(l,s)
if(p!=null){m.d=p
o=p.gby()
if(p.b.index===o){s=!1
if(q.b.unicode){q=m.c
n=q+1
if(n<r){r=l.charCodeAt(q)
if(r>=55296&&r<=56319){s=l.charCodeAt(n)
s=s>=56320&&s<=57343}}}o=(s?o+1:o)+1}m.c=o
return!0}}m.b=m.d=null
return!1}}
A.bI.prototype={
gt(a){return B.ab},
$ij:1}
A.aW.prototype={}
A.bJ.prototype={
gt(a){return B.ac},
$ij:1}
A.aq.prototype={
gl(a){return a.length},
$iD:1}
A.aU.prototype={
k(a,b){A.U(b,a,a.length)
return a[b]},
q(a,b,c){a.$flags&2&&A.K(a)
A.U(b,a,a.length)
a[b]=c},
$ic:1,
$if:1}
A.aV.prototype={
q(a,b,c){a.$flags&2&&A.K(a)
A.U(b,a,a.length)
a[b]=c},
$ic:1,
$if:1}
A.bK.prototype={
gt(a){return B.ad},
$ij:1}
A.bL.prototype={
gt(a){return B.ae},
$ij:1}
A.bM.prototype={
gt(a){return B.af},
k(a,b){A.U(b,a,a.length)
return a[b]},
$ij:1}
A.bN.prototype={
gt(a){return B.ag},
k(a,b){A.U(b,a,a.length)
return a[b]},
$ij:1}
A.bO.prototype={
gt(a){return B.ah},
k(a,b){A.U(b,a,a.length)
return a[b]},
$ij:1}
A.bP.prototype={
gt(a){return B.aj},
k(a,b){A.U(b,a,a.length)
return a[b]},
$ij:1}
A.bQ.prototype={
gt(a){return B.ak},
k(a,b){A.U(b,a,a.length)
return a[b]},
$ij:1}
A.aX.prototype={
gt(a){return B.al},
gl(a){return a.length},
k(a,b){A.U(b,a,a.length)
return a[b]},
$ij:1}
A.aY.prototype={
gt(a){return B.am},
gl(a){return a.length},
k(a,b){A.U(b,a,a.length)
return a[b]},
$ij:1,
$iaj:1}
A.b8.prototype={}
A.b9.prototype={}
A.ba.prototype={}
A.bb.prototype={}
A.H.prototype={
i(a){return A.bi(v.typeUniverse,this,a)},
B(a){return A.fl(v.typeUniverse,this,a)}}
A.c6.prototype={}
A.dr.prototype={
h(a){return A.C(this.a,null)}}
A.c5.prototype={
h(a){return this.a}}
A.be.prototype={$iR:1}
A.cY.prototype={
$1(a){var s=this.a,r=s.a
s.a=null
r.$0()},
$S:4}
A.cX.prototype={
$1(a){var s,r
this.a.a=a
s=this.b
r=this.c
s.firstChild?s.removeChild(r):s.appendChild(r)},
$S:13}
A.cZ.prototype={
$0(){this.a.$0()},
$S:5}
A.d_.prototype={
$0(){this.a.$0()},
$S:5}
A.dp.prototype={
bb(a,b){if(self.setTimeout!=null)self.setTimeout(A.aB(new A.dq(this,b),0),a)
else throw A.a(A.bY("`setTimeout()` not found."))}}
A.dq.prototype={
$0(){this.b.$0()},
$S:0}
A.c0.prototype={
ae(a){var s,r=this
if(a==null)a=r.$ti.c.a(a)
if(!r.b)r.a.av(a)
else{s=r.a
if(r.$ti.i("a_<1>").b(a))s.aw(a)
else s.a5(a)}},
af(a,b){var s=this.a
if(this.b)s.L(a,b)
else s.T(a,b)}}
A.dB.prototype={
$1(a){return this.a.$2(0,a)},
$S:2}
A.dC.prototype={
$2(a,b){this.a.$2(1,new A.aK(a,b))},
$S:14}
A.dP.prototype={
$2(a,b){this.a(a,b)},
$S:15}
A.Z.prototype={
h(a){return A.i(this.a)},
$il:1,
gJ(){return this.b}}
A.c2.prototype={
af(a,b){var s,r=this.a
if((r.a&30)!==0)throw A.a(A.f2("Future already completed"))
s=A.j2(a,b)
r.T(s.a,s.b)},
aK(a){return this.af(a,null)}}
A.b4.prototype={
ae(a){var s=this.a
if((s.a&30)!==0)throw A.a(A.f2("Future already completed"))
s.av(a)}}
A.av.prototype={
bG(a){if((this.c&15)!==6)return!0
return this.b.b.ap(this.d,a.a)},
bC(a){var s,r=this.e,q=null,p=a.a,o=this.b.b
if(t.Q.b(r))q=o.bL(r,p,a.b)
else q=o.ap(r,p)
try{p=q
return p}catch(s){if(t.c.b(A.ab(s))){if((this.c&1)!==0)throw A.a(A.M("The error handler of Future.then must return a value of the returned future's type","onError"))
throw A.a(A.M("The error handler of Future.catchError must return a value of the future's type","onError"))}else throw s}}}
A.v.prototype={
aD(a){this.a=this.a&1|4
this.c=a},
ar(a,b,c){var s,r,q=$.q
if(q===B.c){if(b!=null&&!t.Q.b(b)&&!t.v.b(b))throw A.a(A.eJ(b,"onError",u.c))}else if(b!=null)b=A.jj(b,q)
s=new A.v(q,c.i("v<0>"))
r=b==null?1:3
this.a4(new A.av(s,r,a,b,this.$ti.i("@<1>").B(c).i("av<1,2>")))
return s},
aq(a,b){return this.ar(a,null,b)},
aF(a,b,c){var s=new A.v($.q,c.i("v<0>"))
this.a4(new A.av(s,19,a,b,this.$ti.i("@<1>").B(c).i("av<1,2>")))
return s},
bp(a){this.a=this.a&1|16
this.c=a},
U(a){this.a=a.a&30|this.a&1
this.c=a.c},
a4(a){var s=this,r=s.a
if(r<=3){a.a=s.c
s.c=a}else{if((r&4)!==0){r=s.c
if((r.a&24)===0){r.a4(a)
return}s.U(r)}A.ay(null,null,s.b,new A.d2(s,a))}},
ab(a){var s,r,q,p,o,n=this,m={}
m.a=a
if(a==null)return
s=n.a
if(s<=3){r=n.c
n.c=a
if(r!=null){q=a.a
for(p=a;q!=null;p=q,q=o)o=q.a
p.a=r}}else{if((s&4)!==0){s=n.c
if((s.a&24)===0){s.ab(a)
return}n.U(s)}m.a=n.V(a)
A.ay(null,null,n.b,new A.d9(m,n))}},
ac(){var s=this.c
this.c=null
return this.V(s)},
V(a){var s,r,q
for(s=a,r=null;s!=null;r=s,s=q){q=s.a
s.a=r}return r},
bd(a){var s,r,q,p=this
p.a^=2
try{a.ar(new A.d6(p),new A.d7(p),t.P)}catch(q){s=A.ab(q)
r=A.a9(q)
A.jU(new A.d8(p,s,r))}},
a5(a){var s=this,r=s.ac()
s.a=8
s.c=a
A.b7(s,r)},
L(a,b){var s=this.ac()
this.bp(new A.Z(a,b))
A.b7(this,s)},
av(a){if(this.$ti.i("a_<1>").b(a)){this.aw(a)
return}this.bc(a)},
bc(a){this.a^=2
A.ay(null,null,this.b,new A.d4(this,a))},
aw(a){if(this.$ti.b(a)){A.i6(a,this)
return}this.bd(a)},
T(a,b){this.a^=2
A.ay(null,null,this.b,new A.d3(this,a,b))},
$ia_:1}
A.d2.prototype={
$0(){A.b7(this.a,this.b)},
$S:0}
A.d9.prototype={
$0(){A.b7(this.b,this.a.a)},
$S:0}
A.d6.prototype={
$1(a){var s,r,q,p=this.a
p.a^=2
try{p.a5(p.$ti.c.a(a))}catch(q){s=A.ab(q)
r=A.a9(q)
p.L(s,r)}},
$S:4}
A.d7.prototype={
$2(a,b){this.a.L(a,b)},
$S:16}
A.d8.prototype={
$0(){this.a.L(this.b,this.c)},
$S:0}
A.d5.prototype={
$0(){A.fb(this.a.a,this.b)},
$S:0}
A.d4.prototype={
$0(){this.a.a5(this.b)},
$S:0}
A.d3.prototype={
$0(){this.a.L(this.b,this.c)},
$S:0}
A.dc.prototype={
$0(){var s,r,q,p,o,n,m,l=this,k=null
try{q=l.a.a
k=q.b.b.bJ(q.d)}catch(p){s=A.ab(p)
r=A.a9(p)
if(l.c&&l.b.a.c.a===s){q=l.a
q.c=l.b.a.c}else{q=s
o=r
if(o==null)o=A.e8(q)
n=l.a
n.c=new A.Z(q,o)
q=n}q.b=!0
return}if(k instanceof A.v&&(k.a&24)!==0){if((k.a&16)!==0){q=l.a
q.c=k.c
q.b=!0}return}if(k instanceof A.v){m=l.b.a
q=l.a
q.c=k.aq(new A.dd(m),t.z)
q.b=!1}},
$S:0}
A.dd.prototype={
$1(a){return this.a},
$S:17}
A.db.prototype={
$0(){var s,r,q,p,o,n
try{q=this.a
p=q.a
q.c=p.b.b.ap(p.d,this.b)}catch(o){s=A.ab(o)
r=A.a9(o)
q=s
p=r
if(p==null)p=A.e8(q)
n=this.a
n.c=new A.Z(q,p)
n.b=!0}},
$S:0}
A.da.prototype={
$0(){var s,r,q,p,o,n,m,l=this
try{s=l.a.a.c
p=l.b
if(p.a.bG(s)&&p.a.e!=null){p.c=p.a.bC(s)
p.b=!1}}catch(o){r=A.ab(o)
q=A.a9(o)
p=l.a.a.c
if(p.a===r){n=l.b
n.c=p
p=n}else{p=r
n=q
if(n==null)n=A.e8(p)
m=l.b
m.c=new A.Z(p,n)
p=m}p.b=!0}},
$S:0}
A.c1.prototype={}
A.ce.prototype={}
A.dA.prototype={}
A.dN.prototype={
$0(){A.hz(this.a,this.b)},
$S:0}
A.dg.prototype={
bN(a){var s,r,q
try{if(B.c===$.q){a.$0()
return}A.fL(null,null,this,a)}catch(q){s=A.ab(q)
r=A.a9(q)
A.ew(s,r)}},
aH(a){return new A.dh(this,a)},
bK(a){if($.q===B.c)return a.$0()
return A.fL(null,null,this,a)},
bJ(a){return this.bK(a,t.z)},
bO(a,b){if($.q===B.c)return a.$1(b)
return A.jl(null,null,this,a,b)},
ap(a,b){var s=t.z
return this.bO(a,b,s,s)},
bM(a,b,c){if($.q===B.c)return a.$2(b,c)
return A.jk(null,null,this,a,b,c)},
bL(a,b,c){var s=t.z
return this.bM(a,b,c,s,s,s)},
bI(a){return a},
aZ(a){var s=t.z
return this.bI(a,s,s,s)}}
A.dh.prototype={
$0(){return this.a.bN(this.b)},
$S:0}
A.e.prototype={
gA(a){return new A.ao(a,this.gl(a),A.aC(a).i("ao<e.E>"))},
C(a,b){return this.k(a,b)},
Y(a,b){return new A.N(a,A.aC(a).i("@<e.E>").B(b).i("N<1,2>"))},
bz(a,b,c,d){var s
A.b0(b,c,this.gl(a))
for(s=b;s<c;++s)this.q(a,s,d)},
h(a){return A.ea(a,"[","]")},
$ic:1,
$if:1}
A.P.prototype={
F(a,b){var s,r,q,p
for(s=this.gR(),s=s.gA(s),r=A.E(this).i("P.V");s.m();){q=s.gn()
p=this.k(0,q)
b.$2(q,p==null?r.a(p):p)}},
gl(a){var s=this.gR()
return s.gl(s)},
h(a){return A.ee(this)},
$iy:1}
A.cE.prototype={
$2(a,b){var s,r=this.a
if(!r.a)this.b.a+=", "
r.a=!1
r=this.b
s=A.i(a)
s=r.a+=s
r.a=s+": "
s=A.i(b)
r.a+=s},
$S:18}
A.ch.prototype={
q(a,b,c){throw A.a(A.bY("Cannot modify unmodifiable map"))}}
A.aT.prototype={
k(a,b){return this.a.k(0,b)},
q(a,b,c){this.a.q(0,b,c)},
gl(a){var s=this.a
return s.gl(s)},
h(a){return this.a.h(0)},
$iy:1}
A.au.prototype={}
A.ar.prototype={
h(a){return A.ea(this,"{","}")},
C(a,b){var s,r
A.ef(b,"index")
s=this.gA(this)
for(r=b;s.m();){if(r===0)return s.gn();--r}throw A.a(A.e9(b,b-r,this,"index"))},
$ic:1}
A.bj.prototype={}
A.c7.prototype={
k(a,b){var s,r=this.b
if(r==null)return this.c.k(0,b)
else if(typeof b!="string")return null
else{s=r[b]
return typeof s=="undefined"?this.bn(b):s}},
gl(a){return this.b==null?this.c.a:this.M().length},
gR(){if(this.b==null){var s=this.c
return new A.O(s,A.E(s).i("O<1>"))}return new A.c8(this)},
q(a,b,c){var s,r,q=this
if(q.b==null)q.c.q(0,b,c)
else if(q.P(b)){s=q.b
s[b]=c
r=q.a
if(r==null?s!=null:r!==s)r[b]=null}else q.bt().q(0,b,c)},
P(a){if(this.b==null)return this.c.P(a)
return Object.prototype.hasOwnProperty.call(this.a,a)},
F(a,b){var s,r,q,p,o=this
if(o.b==null)return o.c.F(0,b)
s=o.M()
for(r=0;r<s.length;++r){q=s[r]
p=o.b[q]
if(typeof p=="undefined"){p=A.dD(o.a[q])
o.b[q]=p}b.$2(q,p)
if(s!==o.c)throw A.a(A.aE(o))}},
M(){var s=this.c
if(s==null)s=this.c=A.h(Object.keys(this.a),t.s)
return s},
bt(){var s,r,q,p,o,n=this
if(n.b==null)return n.c
s=A.ed(t.N,t.z)
r=n.M()
for(q=0;p=r.length,q<p;++q){o=r[q]
s.q(0,o,n.k(0,o))}if(p===0)r.push("")
else B.d.Z(r)
n.a=n.b=null
return n.c=s},
bn(a){var s
if(!Object.prototype.hasOwnProperty.call(this.a,a))return null
s=A.dD(this.a[a])
return this.b[a]=s}}
A.c8.prototype={
gl(a){return this.a.gl(0)},
C(a,b){var s=this.a
return s.b==null?s.gR().C(0,b):s.M()[b]},
gA(a){var s=this.a
if(s.b==null){s=s.gR()
s=s.gA(s)}else{s=s.M()
s=new J.Y(s,s.length,A.a6(s).i("Y<1>"))}return s}}
A.dx.prototype={
$0(){var s,r
try{s=new TextDecoder("utf-8",{fatal:true})
return s}catch(r){}return null},
$S:6}
A.dw.prototype={
$0(){var s,r
try{s=new TextDecoder("utf-8",{fatal:false})
return s}catch(r){}return null},
$S:6}
A.ck.prototype={
bH(a0,a1,a2){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a="Invalid base64 encoding length "
a2=A.b0(a1,a2,a0.length)
s=$.hc()
for(r=a1,q=r,p=null,o=-1,n=-1,m=0;r<a2;r=l){l=r+1
k=a0.charCodeAt(r)
if(k===37){j=l+2
if(j<=a2){i=A.dS(a0.charCodeAt(l))
h=A.dS(a0.charCodeAt(l+1))
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
if(k===61)continue}k=g}if(f!==-2){if(p==null){p=new A.z("")
e=p}else e=p
e.a+=B.a.j(a0,q,r)
d=A.Q(k)
e.a+=d
q=l
continue}}throw A.a(A.x("Invalid base64 data",a0,r))}if(p!=null){e=B.a.j(a0,q,a2)
e=p.a+=e
d=e.length
if(o>=0)A.eK(a0,n,a2,o,m,d)
else{c=B.b.a2(d-1,4)+1
if(c===1)throw A.a(A.x(a,a0,a2))
for(;c<4;){e+="="
p.a=e;++c}}e=p.a
return B.a.I(a0,a1,a2,e.charCodeAt(0)==0?e:e)}b=a2-a1
if(o>=0)A.eK(a0,n,a2,o,m,b)
else{c=B.b.a2(b,4)
if(c===1)throw A.a(A.x(a,a0,a2))
if(c>1)a0=B.a.I(a0,a2,a2,c===2?"==":"=")}return a0}}
A.cl.prototype={}
A.bz.prototype={}
A.bB.prototype={}
A.cp.prototype={}
A.ct.prototype={
h(a){return"unknown"}}
A.cs.prototype={
H(a){var s=this.bg(a,0,a.length)
return s==null?a:s},
bg(a,b,c){var s,r,q,p
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
default:q=null}if(q!=null){if(r==null)r=new A.z("")
if(s>b)r.a+=B.a.j(a,b,s)
r.a+=q
b=s+1}}if(r==null)return null
if(c>b){p=B.a.j(a,b,c)
r.a+=p}p=r.a
return p.charCodeAt(0)==0?p:p}}
A.cB.prototype={
bv(a,b){var s=A.jh(a,this.gbx().a)
return s},
gbx(){return B.H}}
A.cC.prototype={}
A.cT.prototype={}
A.cV.prototype={
H(a){var s,r,q,p=A.b0(0,null,a.length)
if(p===0)return new Uint8Array(0)
s=p*3
r=new Uint8Array(s)
q=new A.dy(r)
if(q.bk(a,0,p)!==p)q.ad()
return new Uint8Array(r.subarray(0,A.iO(0,q.b,s)))}}
A.dy.prototype={
ad(){var s=this,r=s.c,q=s.b,p=s.b=q+1
r.$flags&2&&A.K(r)
r[q]=239
q=s.b=p+1
r[p]=191
s.b=q+1
r[q]=189},
bu(a,b){var s,r,q,p,o=this
if((b&64512)===56320){s=65536+((a&1023)<<10)|b&1023
r=o.c
q=o.b
p=o.b=q+1
r.$flags&2&&A.K(r)
r[q]=s>>>18|240
q=o.b=p+1
r[p]=s>>>12&63|128
p=o.b=q+1
r[q]=s>>>6&63|128
o.b=p+1
r[p]=s&63|128
return!0}else{o.ad()
return!1}},
bk(a,b,c){var s,r,q,p,o,n,m,l,k=this
if(b!==c&&(a.charCodeAt(c-1)&64512)===55296)--c
for(s=k.c,r=s.$flags|0,q=s.length,p=b;p<c;++p){o=a.charCodeAt(p)
if(o<=127){n=k.b
if(n>=q)break
k.b=n+1
r&2&&A.K(s)
s[n]=o}else{n=o&64512
if(n===55296){if(k.b+4>q)break
m=p+1
if(k.bu(o,a.charCodeAt(m)))p=m}else if(n===56320){if(k.b+3>q)break
k.ad()}else if(o<=2047){n=k.b
l=n+1
if(l>=q)break
k.b=l
r&2&&A.K(s)
s[n]=o>>>6|192
k.b=l+1
s[l]=o&63|128}else{n=k.b
if(n+2>=q)break
l=k.b=n+1
r&2&&A.K(s)
s[n]=o>>>12|224
n=k.b=l+1
s[l]=o>>>6&63|128
k.b=n+1
s[n]=o&63|128}}}return p}}
A.cU.prototype={
H(a){return new A.dv(this.a).bh(a,0,null,!0)}}
A.dv.prototype={
bh(a,b,c,d){var s,r,q,p,o,n,m=this,l=A.b0(b,c,J.bu(a))
if(b===l)return""
if(a instanceof Uint8Array){s=a
r=s
q=0}else{r=A.iH(a,b,l)
l-=b
q=b
b=0}if(l-b>=15){p=m.a
o=A.iG(p,r,b,l)
if(o!=null){if(!p)return o
if(o.indexOf("\ufffd")<0)return o}}o=m.a6(r,b,l,!0)
p=m.b
if((p&1)!==0){n=A.iI(p)
m.b=0
throw A.a(A.x(n,a,q+m.c))}return o},
a6(a,b,c,d){var s,r,q=this
if(c-b>1000){s=B.b.br(b+c,2)
r=q.a6(a,b,s,!1)
if((q.b&1)!==0)return r
return r+q.a6(a,s,c,d)}return q.bw(a,b,c,d)},
bw(a,b,c,d){var s,r,q,p,o,n,m,l=this,k=65533,j=l.b,i=l.c,h=new A.z(""),g=b+1,f=a[b]
$label0$0:for(s=l.a;!0;){for(;!0;g=p){r="AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAFFFFFFFFFFFFFFFFGGGGGGGGGGGGGGGGHHHHHHHHHHHHHHHHHHHHHHHHHHHIHHHJEEBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBKCCCCCCCCCCCCDCLONNNMEEEEEEEEEEE".charCodeAt(f)&31
i=j<=32?f&61694>>>r:(f&63|i<<6)>>>0
j=" \x000:XECCCCCN:lDb \x000:XECCCCCNvlDb \x000:XECCCCCN:lDb AAAAA\x00\x00\x00\x00\x00AAAAA00000AAAAA:::::AAAAAGG000AAAAA00KKKAAAAAG::::AAAAA:IIIIAAAAA000\x800AAAAA\x00\x00\x00\x00 AAAAA".charCodeAt(j+r)
if(j===0){q=A.Q(i)
h.a+=q
if(g===c)break $label0$0
break}else if((j&1)!==0){if(s)switch(j){case 69:case 67:q=A.Q(k)
h.a+=q
break
case 65:q=A.Q(k)
h.a+=q;--g
break
default:q=A.Q(k)
q=h.a+=q
h.a=q+A.Q(k)
break}else{l.b=j
l.c=g-1
return""}j=0}if(g===c)break $label0$0
p=g+1
f=a[g]}p=g+1
f=a[g]
if(f<128){while(!0){if(!(p<c)){o=c
break}n=p+1
f=a[p]
if(f>=128){o=n-1
p=n
break}p=n}if(o-g<20)for(m=g;m<o;++m){q=A.Q(a[m])
h.a+=q}else{q=A.f4(a,g,o)
h.a+=q}if(o===c)break $label0$0
g=p}else g=p}if(d&&j>32)if(s){s=A.Q(k)
h.a+=s}else{l.b=77
l.c=c
return""}l.b=j
l.c=i
s=h.a
return s.charCodeAt(0)==0?s:s}}
A.du.prototype={
$2(a,b){var s,r
if(typeof b=="string")this.a.set(a,b)
else if(b==null)this.a.set(a,"")
else for(s=J.ac(b),r=this.a;s.m();){b=s.gn()
if(typeof b=="string")r.append(a,b)
else if(b==null)r.append(a,"")
else A.iK(b)}},
$S:7}
A.d0.prototype={
h(a){return this.az()}}
A.l.prototype={
gJ(){return A.hU(this)}}
A.bv.prototype={
h(a){var s=this.a
if(s!=null)return"Assertion failed: "+A.cq(s)
return"Assertion failed"}}
A.R.prototype={}
A.F.prototype={
ga8(){return"Invalid argument"+(!this.a?"(s)":"")},
ga7(){return""},
h(a){var s=this,r=s.c,q=r==null?"":" ("+r+")",p=s.d,o=p==null?"":": "+p,n=s.ga8()+q+o
if(!s.a)return n
return n+s.ga7()+": "+A.cq(s.gak())},
gak(){return this.b}}
A.b_.prototype={
gak(){return this.b},
ga8(){return"RangeError"},
ga7(){var s,r=this.e,q=this.f
if(r==null)s=q!=null?": Not less than or equal to "+A.i(q):""
else if(q==null)s=": Not greater than or equal to "+A.i(r)
else if(q>r)s=": Not in inclusive range "+A.i(r)+".."+A.i(q)
else s=q<r?": Valid value range is empty":": Only valid value is "+A.i(r)
return s}}
A.bC.prototype={
gak(){return this.b},
ga8(){return"RangeError"},
ga7(){if(this.b<0)return": index must not be negative"
var s=this.f
if(s===0)return": no indices are valid"
return": index should be less than "+s},
gl(a){return this.f}}
A.b3.prototype={
h(a){return"Unsupported operation: "+this.a}}
A.bV.prototype={
h(a){return"UnimplementedError: "+this.a}}
A.b2.prototype={
h(a){return"Bad state: "+this.a}}
A.bA.prototype={
h(a){var s=this.a
if(s==null)return"Concurrent modification during iteration."
return"Concurrent modification during iteration: "+A.cq(s)+"."}}
A.bR.prototype={
h(a){return"Out of Memory"},
gJ(){return null},
$il:1}
A.b1.prototype={
h(a){return"Stack Overflow"},
gJ(){return null},
$il:1}
A.d1.prototype={
h(a){return"Exception: "+this.a}}
A.cr.prototype={
h(a){var s,r,q,p,o,n,m,l,k,j,i,h=this.a,g=""!==h?"FormatException: "+h:"FormatException",f=this.c,e=this.b
if(typeof e=="string"){if(f!=null)s=f<0||f>e.length
else s=!1
if(s)f=null
if(f==null){if(e.length>78)e=B.a.j(e,0,75)+"..."
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
k=""}return g+l+B.a.j(e,i,j)+k+"\n"+B.a.b5(" ",f-i+l.length)+"^\n"}else return f!=null?g+(" (at offset "+A.i(f)+")"):g}}
A.n.prototype={
Y(a,b){return A.hr(this,A.E(this).i("n.E"),b)},
gl(a){var s,r=this.gA(this)
for(s=0;r.m();)++s
return s},
C(a,b){var s,r
A.ef(b,"index")
s=this.gA(this)
for(r=b;s.m();){if(r===0)return s.gn();--r}throw A.a(A.e9(b,b-r,this,"index"))},
h(a){return A.hI(this,"(",")")}}
A.u.prototype={
gp(a){return A.k.prototype.gp.call(this,0)},
h(a){return"null"}}
A.k.prototype={$ik:1,
E(a,b){return this===b},
gp(a){return A.bT(this)},
h(a){return"Instance of '"+A.cI(this)+"'"},
gt(a){return A.jE(this)},
toString(){return this.h(this)}}
A.cf.prototype={
h(a){return""},
$ia2:1}
A.z.prototype={
gl(a){return this.a.length},
h(a){var s=this.a
return s.charCodeAt(0)==0?s:s}}
A.cS.prototype={
$2(a,b){var s,r,q,p=B.a.aS(b,"=")
if(p===-1){if(b!=="")a.q(0,A.er(b,0,b.length,this.a,!0),"")}else if(p!==0){s=B.a.j(b,0,p)
r=B.a.K(b,p+1)
q=this.a
a.q(0,A.er(s,0,s.length,q,!0),A.er(r,0,r.length,q,!0))}return a},
$S:19}
A.cP.prototype={
$2(a,b){throw A.a(A.x("Illegal IPv4 address, "+a,this.a,b))},
$S:20}
A.cQ.prototype={
$2(a,b){throw A.a(A.x("Illegal IPv6 address, "+a,this.a,b))},
$S:21}
A.cR.prototype={
$2(a,b){var s
if(b-a>4)this.a.$2("an IPv6 part can only contain a maximum of 4 hex digits",a)
s=A.e_(B.a.j(this.b,a,b),16)
if(s<0||s>65535)this.a.$2("each part must be in the range of `0x0..0xFFFF`",a)
return s},
$S:22}
A.bk.prototype={
gX(){var s,r,q,p,o=this,n=o.w
if(n===$){s=o.a
r=s.length!==0?""+s+":":""
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
n!==$&&A.bs()
n=o.w=s.charCodeAt(0)==0?s:s}return n},
gp(a){var s,r=this,q=r.y
if(q===$){s=B.a.gp(r.gX())
r.y!==$&&A.bs()
r.y=s
q=s}return q},
gan(){var s,r=this,q=r.z
if(q===$){s=r.f
s=A.f9(s==null?"":s)
r.z!==$&&A.bs()
q=r.z=new A.au(s,t.h)}return q},
gb1(){return this.b},
gai(){var s=this.c
if(s==null)return""
if(B.a.u(s,"["))return B.a.j(s,1,s.length-1)
return s},
ga1(){var s=this.d
return s==null?A.fm(this.a):s},
gam(){var s=this.f
return s==null?"":s},
gaM(){var s=this.r
return s==null?"":s},
ao(a){var s,r,q,p,o=this,n=o.a,m=n==="file",l=o.b,k=o.d,j=o.c
if(!(j!=null))j=l.length!==0||k!=null||m?"":null
s=o.e
if(!m)r=j!=null&&s.length!==0
else r=!0
if(r&&!B.a.u(s,"/"))s="/"+s
q=s
p=A.ep(null,0,0,a)
return A.en(n,l,j,k,q,p,o.r)},
gaV(){if(this.a!==""){var s=this.r
s=(s==null?"":s)===""}else s=!1
return s},
gaO(){return this.c!=null},
gaR(){return this.f!=null},
gaP(){return this.r!=null},
h(a){return this.gX()},
E(a,b){var s,r,q,p=this
if(b==null)return!1
if(p===b)return!0
s=!1
if(t.R.b(b))if(p.a===b.ga3())if(p.c!=null===b.gaO())if(p.b===b.gb1())if(p.gai()===b.gai())if(p.ga1()===b.ga1())if(p.e===b.gaY()){r=p.f
q=r==null
if(!q===b.gaR()){if(q)r=""
if(r===b.gam()){r=p.r
q=r==null
if(!q===b.gaP()){s=q?"":r
s=s===b.gaM()}}}}return s},
$ibZ:1,
ga3(){return this.a},
gaY(){return this.e}}
A.dt.prototype={
$2(a,b){var s=this.b,r=this.a
s.a+=r.a
r.a="&"
r=A.fs(B.i,a,B.e,!0)
r=s.a+=r
if(b!=null&&b.length!==0){s.a=r+"="
r=A.fs(B.i,b,B.e,!0)
s.a+=r}},
$S:23}
A.ds.prototype={
$2(a,b){var s,r
if(b==null||typeof b=="string")this.a.$2(a,b)
else for(s=J.ac(b),r=this.a;s.m();)r.$2(a,s.gn())},
$S:7}
A.cO.prototype={
gb0(){var s,r,q,p,o=this,n=null,m=o.c
if(m==null){m=o.a
s=o.b[0]+1
r=B.a.a_(m,"?",s)
q=m.length
if(r>=0){p=A.bl(m,r+1,q,B.h,!1,!1)
q=r}else p=n
m=o.c=new A.c4("data","",n,n,A.bl(m,s,q,B.p,!1,!1),p,n)}return m},
h(a){var s=this.a
return this.b[0]===-1?"data:"+s:s}}
A.dG.prototype={
$2(a,b){var s=this.a[a]
B.a7.bz(s,0,96,b)
return s},
$S:24}
A.dH.prototype={
$3(a,b,c){var s,r,q
for(s=b.length,r=a.$flags|0,q=0;q<s;++q){r&2&&A.K(a)
a[b.charCodeAt(q)^96]=c}},
$S:8}
A.dI.prototype={
$3(a,b,c){var s,r,q
for(s=b.charCodeAt(0),r=b.charCodeAt(1),q=a.$flags|0;s<=r;++s){q&2&&A.K(a)
a[(s^96)>>>0]=c}},
$S:8}
A.cd.prototype={
gaO(){return this.c>0},
gaQ(){return this.c>0&&this.d+1<this.e},
gaR(){return this.f<this.r},
gaP(){return this.r<this.a.length},
gaV(){return this.b>0&&this.r>=this.a.length},
ga3(){var s=this.w
return s==null?this.w=this.bf():s},
bf(){var s,r=this,q=r.b
if(q<=0)return""
s=q===4
if(s&&B.a.u(r.a,"http"))return"http"
if(q===5&&B.a.u(r.a,"https"))return"https"
if(s&&B.a.u(r.a,"file"))return"file"
if(q===7&&B.a.u(r.a,"package"))return"package"
return B.a.j(r.a,0,q)},
gb1(){var s=this.c,r=this.b+3
return s>r?B.a.j(this.a,r,s-1):""},
gai(){var s=this.c
return s>0?B.a.j(this.a,s,this.d):""},
ga1(){var s,r=this
if(r.gaQ())return A.e_(B.a.j(r.a,r.d+1,r.e),null)
s=r.b
if(s===4&&B.a.u(r.a,"http"))return 80
if(s===5&&B.a.u(r.a,"https"))return 443
return 0},
gaY(){return B.a.j(this.a,this.e,this.f)},
gam(){var s=this.f,r=this.r
return s<r?B.a.j(this.a,s+1,r):""},
gaM(){var s=this.r,r=this.a
return s<r.length?B.a.K(r,s+1):""},
gan(){if(this.f>=this.r)return B.a6
return new A.au(A.f9(this.gam()),t.h)},
ao(a){var s,r,q,p,o,n=this,m=null,l=n.ga3(),k=l==="file",j=n.c,i=j>0?B.a.j(n.a,n.b+3,j):"",h=n.gaQ()?n.ga1():m
j=n.c
if(j>0)s=B.a.j(n.a,j,n.d)
else s=i.length!==0||h!=null||k?"":m
j=n.a
r=B.a.j(j,n.e,n.f)
if(!k)q=s!=null&&r.length!==0
else q=!0
if(q&&!B.a.u(r,"/"))r="/"+r
p=A.ep(m,0,0,a)
q=n.r
o=q<j.length?B.a.K(j,q+1):m
return A.en(l,i,s,h,r,p,o)},
gp(a){var s=this.x
return s==null?this.x=B.a.gp(this.a):s},
E(a,b){if(b==null)return!1
if(this===b)return!0
return t.R.b(b)&&this.a===b.h(0)},
h(a){return this.a},
$ibZ:1}
A.c4.prototype={}
A.e3.prototype={
$1(a){return this.a.ae(a)},
$S:2}
A.e4.prototype={
$1(a){if(a==null)return this.a.aK(new A.cG(a===undefined))
return this.a.aK(a)},
$S:2}
A.cG.prototype={
h(a){return"Promise was rejected with a value of `"+(this.a?"undefined":"null")+"`."}}
A.m.prototype={
az(){return"Kind."+this.b},
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
A.A.prototype={
az(){return"_MatchPosition."+this.b}}
A.cu.prototype={
aL(a){var s,r,q,p,o,n,m,l,k,j,i
if(a.length===0)return A.h([],t.M)
s=a.toLowerCase()
r=A.h([],t.r)
for(q=this.a,p=q.length,o=s.length>1,n="dart:"+s,m=0;m<q.length;q.length===p||(0,A.e5)(q),++m){l=q[m]
k=new A.cx(r,l)
j=l.a.toLowerCase()
i=l.b.toLowerCase()
if(j===s||i===s||j===n)k.$1(B.ao)
else if(o)if(B.a.u(j,s)||B.a.u(i,s))k.$1(B.ap)
else if(B.a.O(j,s)||B.a.O(i,s))k.$1(B.aq)}B.d.b8(r,new A.cv())
q=t.V
return A.eU(new A.ai(r,new A.cw(),q),!0,q.i("J.E"))}}
A.cx.prototype={
$1(a){this.a.push(new A.cc(this.b,a))},
$S:25}
A.cv.prototype={
$2(a,b){var s,r,q=a.b.a-b.b.a
if(q!==0)return q
s=a.a
r=b.a
q=s.c-r.c
if(q!==0)return q
q=s.gaC()-r.gaC()
if(q!==0)return q
q=s.f-r.f
if(q!==0)return q
return s.a.length-r.a.length},
$S:26}
A.cw.prototype={
$1(a){return a.a},
$S:27}
A.w.prototype={
gaC(){var s=0
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
A.co.prototype={}
A.dK.prototype={
$0(){var s,r=self.document.body
if(r==null)return""
if(J.I(r.getAttribute("data-using-base-href"),"false")){s=r.getAttribute("data-base-href")
return s==null?"":s}else return""},
$S:28}
A.dY.prototype={
$0(){A.jS("Could not activate search functionality.")
var s=this.a
if(s!=null)s.placeholder="Failed to initialize search"
s=this.b
if(s!=null)s.placeholder="Failed to initialize search"
s=this.c
if(s!=null)s.placeholder="Failed to initialize search"},
$S:0}
A.dX.prototype={
$1(a){return this.b4(a)},
b4(a){var s=0,r=A.fK(t.P),q,p=this,o,n,m,l,k,j,i,h,g
var $async$$1=A.fR(function(b,c){if(b===1)return A.fA(c,r)
while(true)switch(s){case 0:if(!J.I(a.status,200)){p.a.$0()
s=1
break}i=J
h=t.j
g=B.B
s=3
return A.fz(A.e2(a.text(),t.N),$async$$1)
case 3:o=i.hl(h.a(g.bv(c,null)),t.a)
n=o.$ti.i("ai<e.E,w>")
m=new A.cu(A.eU(new A.ai(o,A.jV(),n),!0,n.i("J.E")))
n=self
l=A.c_(J.an(n.window.location)).gan().k(0,"search")
if(l!=null){k=A.hH(m.aL(l))
j=k==null?null:k.e
if(j!=null){n.window.location.assign($.bt()+j)
s=1
break}}n=p.b
if(n!=null)A.ej(m).aj(n)
n=p.c
if(n!=null)A.ej(m).aj(n)
n=p.d
if(n!=null)A.ej(m).aj(n)
case 1:return A.fB(q,r)}})
return A.fC($async$$1,r)},
$S:9}
A.di.prototype={
gG(){var s,r=this,q=r.c
if(q===$){s=self.document.createElement("div")
s.setAttribute("role","listbox")
s.setAttribute("aria-expanded","false")
s.style.display="none"
s.classList.add("tt-menu")
s.appendChild(r.gaX())
s.appendChild(r.gS())
r.c!==$&&A.bs()
r.c=s
q=s}return q},
gaX(){var s,r=this.d
if(r===$){s=self.document.createElement("div")
s.classList.add("enter-search-message")
this.d!==$&&A.bs()
this.d=s
r=s}return r},
gS(){var s,r=this.e
if(r===$){s=self.document.createElement("div")
s.classList.add("tt-search-results")
this.e!==$&&A.bs()
this.e=s
r=s}return r},
aj(a){var s,r,q,p=this
a.disabled=!1
a.setAttribute("placeholder","Search API Docs")
s=self
s.document.addEventListener("keydown",A.a7(new A.dj(a)))
r=s.document.createElement("div")
r.classList.add("tt-wrapper")
a.replaceWith(r)
a.setAttribute("autocomplete","off")
a.setAttribute("spellcheck","false")
a.classList.add("tt-input")
r.appendChild(a)
r.appendChild(p.gG())
p.b6(a)
if(J.hn(s.window.location.href,"search.html")){q=p.b.gan().k(0,"q")
if(q==null)return
q=B.l.H(q)
$.ey=$.dO
p.bE(q,!0)
p.b7(q)
p.ah()
$.ey=10}},
b7(a){var s,r,q,p,o,n=self,m=n.document.getElementById("dartdoc-main-content")
if(m==null)return
m.textContent=""
s=n.document.createElement("section")
s.classList.add("search-summary")
m.appendChild(s)
s=n.document.createElement("h2")
s.innerHTML="Search Results"
m.appendChild(s)
s=n.document.createElement("div")
s.classList.add("search-summary")
s.innerHTML=""+$.dO+' results for "'+a+'"'
m.appendChild(s)
if($.bn.a!==0)for(n=$.bn.gb2(),r=A.E(n),n=new A.ap(J.ac(n.a),n.b,r.i("ap<1,2>")),r=r.y[1];n.m();){q=n.a
if(q==null)q=r.a(q)
m.appendChild(q)}else{s=n.document.createElement("div")
s.classList.add("search-summary")
s.innerHTML='There was not a match for "'+a+'". Want to try searching from additional Dart-related sites? '
p=A.c_("https://dart.dev/search?cx=011220921317074318178%3A_yy-tmb5t_i&ie=UTF-8&hl=en&q=").ao(A.eS(["q",a],t.N,t.z))
o=n.document.createElement("a")
o.setAttribute("href",p.gX())
o.textContent="Search on dart.dev."
s.appendChild(o)
m.appendChild(s)}},
ah(){var s=this.gG()
s.style.display="none"
s.setAttribute("aria-expanded","false")
return s},
b_(a,b,c){var s,r,q,p,o=this
o.x=A.h([],t.M)
s=o.w
B.d.Z(s)
$.bn.Z(0)
o.gS().textContent=""
r=b.length
if(r===0){o.ah()
return}for(q=0;q<b.length;b.length===r||(0,A.e5)(b),++q)s.push(A.iP(a,b[q]))
for(r=J.ac(c?$.bn.gb2():s);r.m();){p=r.gn()
o.gS().appendChild(p)}o.x=b
o.y=-1
if(o.gS().hasChildNodes()){r=o.gG()
r.style.display="block"
r.setAttribute("aria-expanded","true")}r=$.dO
r=r>10?'Press "Enter" key to see all '+r+" results":""
o.gaX().textContent=r},
bP(a,b){return this.b_(a,b,!1)},
ag(a,b,c){var s,r,q,p=this
if(p.r===a&&!b)return
if(a.length===0){p.bP("",A.h([],t.M))
return}s=p.a.aL(a)
r=s.length
$.dO=r
q=$.ey
if(r>q)s=B.d.b9(s,0,q)
p.r=a
p.b_(a,s,c)},
bE(a,b){return this.ag(a,!1,b)},
aN(a){return this.ag(a,!1,!1)},
bD(a,b){return this.ag(a,b,!1)},
aI(a){var s,r=this
r.y=-1
s=r.f
if(s!=null){a.value=s
r.f=null}r.ah()},
b6(a){var s=this
a.addEventListener("focus",A.a7(new A.dk(s,a)))
a.addEventListener("blur",A.a7(new A.dl(s,a)))
a.addEventListener("input",A.a7(new A.dm(s,a)))
a.addEventListener("keydown",A.a7(new A.dn(s,a)))}}
A.dj.prototype={
$1(a){var s
if(!J.I(a.key,"/"))return
s=self.document.activeElement
if(s==null||!B.aa.O(0,s.nodeName.toLowerCase())){a.preventDefault()
this.a.focus()}},
$S:1}
A.dk.prototype={
$1(a){this.a.bD(this.b.value,!0)},
$S:1}
A.dl.prototype={
$1(a){this.a.aI(this.b)},
$S:1}
A.dm.prototype={
$1(a){this.a.aN(this.b.value)},
$S:1}
A.dn.prototype={
$1(a){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e=this
if(!J.I(a.type,"keydown"))return
if(J.I(a.code,"Enter")){a.preventDefault()
s=e.a
r=s.y
if(r!==-1){q=s.w[r].getAttribute("data-href")
if(q!=null)self.window.location.assign($.bt()+q)
return}else{p=B.l.H(s.r)
o=A.c_($.bt()+"search.html").ao(A.eS(["q",p],t.N,t.z))
self.window.location.assign(o.gX())
return}}s=e.a
r=s.w
n=r.length-1
m=s.y
if(J.I(a.code,"ArrowUp")){l=s.y
if(l===-1)s.y=n
else s.y=l-1}else if(J.I(a.code,"ArrowDown")){l=s.y
if(l===n)s.y=-1
else s.y=l+1}else if(J.I(a.code,"Escape"))s.aI(e.b)
else{if(s.f!=null){s.f=null
s.aN(e.b.value)}return}l=m!==-1
if(l)r[m].classList.remove("tt-cursor")
k=s.y
if(k!==-1){j=r[k]
j.classList.add("tt-cursor")
r=s.y
if(r===0)s.gG().scrollTop=0
else if(r===n)s.gG().scrollTop=s.gG().scrollHeight
else{i=j.offsetTop
h=s.gG().offsetHeight
if(i<h||h<i+j.offsetHeight)j.scrollIntoView()}if(s.f==null)s.f=e.b.value
e.b.value=s.x[s.y].a}else{g=s.f
if(g!=null){r=l
f=g}else{f=null
r=!1}if(r){e.b.value=f
s.f=null}}a.preventDefault()},
$S:1}
A.dE.prototype={
$1(a){a.preventDefault()},
$S:1}
A.dF.prototype={
$1(a){var s=this.a.e
if(s!=null){self.window.location.assign($.bt()+s)
a.preventDefault()}},
$S:1}
A.dJ.prototype={
$1(a){return"<strong class='tt-highlight'>"+A.i(a.k(0,0))+"</strong>"},
$S:29}
A.dL.prototype={
$1(a){var s=this.a
if(s!=null)s.classList.toggle("active")
s=this.b
if(s!=null)s.classList.toggle("active")},
$S:1}
A.dM.prototype={
$1(a){return this.b3(a)},
b3(a){var s=0,r=A.fK(t.P),q,p=this,o,n
var $async$$1=A.fR(function(b,c){if(b===1)return A.fA(c,r)
while(true)switch(s){case 0:if(!J.I(a.status,200)){o=self.document.createElement("a")
o.href="https://dart.dev/tools/dart-doc#troubleshoot"
o.text="Failed to load sidebar. Visit dart.dev for help troubleshooting."
p.a.appendChild(o)
s=1
break}s=3
return A.fz(A.e2(a.text(),t.N),$async$$1)
case 3:n=c
o=self.document.createElement("div")
o.innerHTML=n
A.fQ(p.b,o)
p.a.appendChild(o)
case 1:return A.fB(q,r)}})
return A.fC($async$$1,r)},
$S:9}
A.dZ.prototype={
$0(){var s=this.a,r=this.b
if(s.checked){r.setAttribute("class","dark-theme")
s.setAttribute("value","dark-theme")
self.window.localStorage.setItem("colorTheme","true")}else{r.setAttribute("class","light-theme")
s.setAttribute("value","light-theme")
self.window.localStorage.setItem("colorTheme","false")}},
$S:0}
A.dW.prototype={
$1(a){this.a.$0()},
$S:1};(function aliases(){var s=J.a1.prototype
s.ba=s.h})();(function installTearOffs(){var s=hunkHelpers._static_2,r=hunkHelpers._static_1,q=hunkHelpers._static_0
s(J,"j3","hM",30)
r(A,"jt","i3",3)
r(A,"ju","i4",3)
r(A,"jv","i5",3)
q(A,"fT","jn",0)
r(A,"jV","hC",31)})();(function inheritance(){var s=hunkHelpers.mixin,r=hunkHelpers.inherit,q=hunkHelpers.inheritMany
r(A.k,null)
q(A.k,[A.eb,J.bD,J.Y,A.n,A.bx,A.l,A.e,A.cJ,A.ao,A.ap,A.aL,A.bX,A.bc,A.aF,A.c9,A.ar,A.cM,A.cH,A.aK,A.bd,A.ae,A.P,A.cD,A.bH,A.cy,A.ca,A.cW,A.H,A.c6,A.dr,A.dp,A.c0,A.Z,A.c2,A.av,A.v,A.c1,A.ce,A.dA,A.ch,A.aT,A.bz,A.bB,A.ct,A.dy,A.dv,A.d0,A.bR,A.b1,A.d1,A.cr,A.u,A.cf,A.z,A.bk,A.cO,A.cd,A.cG,A.cu,A.w,A.co,A.di])
q(J.bD,[J.bE,J.aN,J.aQ,J.aP,J.aR,J.aO,J.af])
q(J.aQ,[J.a1,J.o,A.bI,A.aW])
q(J.a1,[J.bS,J.as,J.a0])
r(J.cz,J.o)
q(J.aO,[J.aM,J.bF])
q(A.n,[A.a4,A.c,A.ah])
q(A.a4,[A.ad,A.bm])
r(A.b6,A.ad)
r(A.b5,A.bm)
r(A.N,A.b5)
q(A.l,[A.aS,A.R,A.bG,A.bW,A.c3,A.bU,A.c5,A.bv,A.F,A.b3,A.bV,A.b2,A.bA])
r(A.at,A.e)
r(A.by,A.at)
q(A.c,[A.J,A.O])
r(A.aJ,A.ah)
q(A.J,[A.ai,A.c8])
r(A.cb,A.bc)
r(A.cc,A.cb)
r(A.aH,A.aF)
r(A.aG,A.ar)
r(A.aI,A.aG)
r(A.aZ,A.R)
q(A.ae,[A.cm,A.cn,A.cL,A.cA,A.dT,A.dV,A.cY,A.cX,A.dB,A.d6,A.dd,A.dH,A.dI,A.e3,A.e4,A.cx,A.cw,A.dX,A.dj,A.dk,A.dl,A.dm,A.dn,A.dE,A.dF,A.dJ,A.dL,A.dM,A.dW])
q(A.cL,[A.cK,A.aD])
q(A.P,[A.ag,A.c7])
q(A.cn,[A.dU,A.dC,A.dP,A.d7,A.cE,A.du,A.cS,A.cP,A.cQ,A.cR,A.dt,A.ds,A.dG,A.cv])
q(A.aW,[A.bJ,A.aq])
q(A.aq,[A.b8,A.ba])
r(A.b9,A.b8)
r(A.aU,A.b9)
r(A.bb,A.ba)
r(A.aV,A.bb)
q(A.aU,[A.bK,A.bL])
q(A.aV,[A.bM,A.bN,A.bO,A.bP,A.bQ,A.aX,A.aY])
r(A.be,A.c5)
q(A.cm,[A.cZ,A.d_,A.dq,A.d2,A.d9,A.d8,A.d5,A.d4,A.d3,A.dc,A.db,A.da,A.dN,A.dh,A.dx,A.dw,A.dK,A.dY,A.dZ])
r(A.b4,A.c2)
r(A.dg,A.dA)
r(A.bj,A.aT)
r(A.au,A.bj)
q(A.bz,[A.ck,A.cp,A.cB])
q(A.bB,[A.cl,A.cs,A.cC,A.cV,A.cU])
r(A.cT,A.cp)
q(A.F,[A.b_,A.bC])
r(A.c4,A.bk)
q(A.d0,[A.m,A.A])
s(A.at,A.bX)
s(A.bm,A.e)
s(A.b8,A.e)
s(A.b9,A.aL)
s(A.ba,A.e)
s(A.bb,A.aL)
s(A.bj,A.ch)})()
var v={typeUniverse:{eC:new Map(),tR:{},eT:{},tPV:{},sEA:[]},mangledGlobalNames:{b:"int",t:"double",jR:"num",d:"String",jw:"bool",u:"Null",f:"List",k:"Object",y:"Map"},mangledNames:{},types:["~()","u(p)","~(@)","~(~())","u(@)","u()","@()","~(d,@)","~(aj,d,b)","a_<u>(p)","@(@)","@(@,d)","@(d)","u(~())","u(@,a2)","~(b,@)","u(k,a2)","v<@>(@)","~(k?,k?)","y<d,d>(y<d,d>,d)","~(d,b)","~(d,b?)","b(b,b)","~(d,d?)","aj(@,@)","~(A)","b(+item,matchPosition(w,A),+item,matchPosition(w,A))","w(+item,matchPosition(w,A))","d()","d(cF)","b(@,@)","w(y<d,@>)"],interceptorsByTag:null,leafTags:null,arrayRti:Symbol("$ti"),rttc:{"2;item,matchPosition":(a,b)=>c=>c instanceof A.cc&&a.b(c.a)&&b.b(c.b)}}
A.io(v.typeUniverse,JSON.parse('{"bS":"a1","as":"a1","a0":"a1","bE":{"j":[]},"aN":{"u":[],"j":[]},"aQ":{"p":[]},"a1":{"p":[]},"o":{"f":["1"],"c":["1"],"p":[]},"cz":{"o":["1"],"f":["1"],"c":["1"],"p":[]},"aO":{"t":[]},"aM":{"t":[],"b":[],"j":[]},"bF":{"t":[],"j":[]},"af":{"d":[],"j":[]},"a4":{"n":["2"]},"ad":{"a4":["1","2"],"n":["2"],"n.E":"2"},"b6":{"ad":["1","2"],"a4":["1","2"],"c":["2"],"n":["2"],"n.E":"2"},"b5":{"e":["2"],"f":["2"],"a4":["1","2"],"c":["2"],"n":["2"]},"N":{"b5":["1","2"],"e":["2"],"f":["2"],"a4":["1","2"],"c":["2"],"n":["2"],"e.E":"2","n.E":"2"},"aS":{"l":[]},"by":{"e":["b"],"f":["b"],"c":["b"],"e.E":"b"},"c":{"n":["1"]},"J":{"c":["1"],"n":["1"]},"ah":{"n":["2"],"n.E":"2"},"aJ":{"ah":["1","2"],"c":["2"],"n":["2"],"n.E":"2"},"ai":{"J":["2"],"c":["2"],"n":["2"],"J.E":"2","n.E":"2"},"at":{"e":["1"],"f":["1"],"c":["1"]},"aF":{"y":["1","2"]},"aH":{"y":["1","2"]},"aG":{"ar":["1"],"c":["1"]},"aI":{"ar":["1"],"c":["1"]},"aZ":{"R":[],"l":[]},"bG":{"l":[]},"bW":{"l":[]},"bd":{"a2":[]},"c3":{"l":[]},"bU":{"l":[]},"ag":{"P":["1","2"],"y":["1","2"],"P.V":"2"},"O":{"c":["1"],"n":["1"],"n.E":"1"},"ca":{"eg":[],"cF":[]},"bI":{"p":[],"j":[]},"aW":{"p":[]},"bJ":{"p":[],"j":[]},"aq":{"D":["1"],"p":[]},"aU":{"e":["t"],"f":["t"],"D":["t"],"c":["t"],"p":[]},"aV":{"e":["b"],"f":["b"],"D":["b"],"c":["b"],"p":[]},"bK":{"e":["t"],"f":["t"],"D":["t"],"c":["t"],"p":[],"j":[],"e.E":"t"},"bL":{"e":["t"],"f":["t"],"D":["t"],"c":["t"],"p":[],"j":[],"e.E":"t"},"bM":{"e":["b"],"f":["b"],"D":["b"],"c":["b"],"p":[],"j":[],"e.E":"b"},"bN":{"e":["b"],"f":["b"],"D":["b"],"c":["b"],"p":[],"j":[],"e.E":"b"},"bO":{"e":["b"],"f":["b"],"D":["b"],"c":["b"],"p":[],"j":[],"e.E":"b"},"bP":{"e":["b"],"f":["b"],"D":["b"],"c":["b"],"p":[],"j":[],"e.E":"b"},"bQ":{"e":["b"],"f":["b"],"D":["b"],"c":["b"],"p":[],"j":[],"e.E":"b"},"aX":{"e":["b"],"f":["b"],"D":["b"],"c":["b"],"p":[],"j":[],"e.E":"b"},"aY":{"aj":[],"e":["b"],"f":["b"],"D":["b"],"c":["b"],"p":[],"j":[],"e.E":"b"},"c5":{"l":[]},"be":{"R":[],"l":[]},"v":{"a_":["1"]},"Z":{"l":[]},"b4":{"c2":["1"]},"e":{"f":["1"],"c":["1"]},"P":{"y":["1","2"]},"aT":{"y":["1","2"]},"au":{"y":["1","2"]},"ar":{"c":["1"]},"c7":{"P":["d","@"],"y":["d","@"],"P.V":"@"},"c8":{"J":["d"],"c":["d"],"n":["d"],"J.E":"d","n.E":"d"},"f":{"c":["1"]},"eg":{"cF":[]},"bv":{"l":[]},"R":{"l":[]},"F":{"l":[]},"b_":{"l":[]},"bC":{"l":[]},"b3":{"l":[]},"bV":{"l":[]},"b2":{"l":[]},"bA":{"l":[]},"bR":{"l":[]},"b1":{"l":[]},"cf":{"a2":[]},"bk":{"bZ":[]},"cd":{"bZ":[]},"c4":{"bZ":[]},"hF":{"f":["b"],"c":["b"]},"aj":{"f":["b"],"c":["b"]},"i0":{"f":["b"],"c":["b"]},"hD":{"f":["b"],"c":["b"]},"hZ":{"f":["b"],"c":["b"]},"hE":{"f":["b"],"c":["b"]},"i_":{"f":["b"],"c":["b"]},"hA":{"f":["t"],"c":["t"]},"hB":{"f":["t"],"c":["t"]}}'))
A.im(v.typeUniverse,JSON.parse('{"aL":1,"bX":1,"at":1,"bm":2,"aF":2,"aG":1,"bH":1,"aq":1,"ce":1,"ch":2,"aT":2,"bj":2,"bz":2,"bB":2}'))
var u={c:"Error handler must accept one Object or one Object and a StackTrace as arguments, and return a value of the returned future's type"}
var t=(function rtii(){var s=A.bq
return{U:s("c<@>"),C:s("l"),Z:s("k2"),M:s("o<w>"),O:s("o<p>"),r:s("o<+item,matchPosition(w,A)>"),s:s("o<d>"),b:s("o<@>"),t:s("o<b>"),T:s("aN"),m:s("p"),g:s("a0"),p:s("D<@>"),j:s("f<@>"),a:s("y<d,@>"),V:s("ai<+item,matchPosition(w,A),w>"),P:s("u"),K:s("k"),L:s("k3"),d:s("+()"),F:s("eg"),l:s("a2"),N:s("d"),k:s("j"),c:s("R"),D:s("aj"),o:s("as"),h:s("au<d,d>"),R:s("bZ"),e:s("v<@>"),y:s("jw"),i:s("t"),z:s("@"),v:s("@(k)"),Q:s("@(k,a2)"),S:s("b"),A:s("0&*"),_:s("k*"),W:s("a_<u>?"),X:s("k?"),H:s("jR")}})();(function constants(){var s=hunkHelpers.makeConstList
B.E=J.bD.prototype
B.d=J.o.prototype
B.b=J.aM.prototype
B.a=J.af.prototype
B.F=J.a0.prototype
B.G=J.aQ.prototype
B.a7=A.aY.prototype
B.t=J.bS.prototype
B.k=J.as.prototype
B.ar=new A.cl()
B.u=new A.ck()
B.as=new A.ct()
B.l=new A.cs()
B.m=function getTagFallback(o) {
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
B.n=function(hooks) { return hooks; }

B.B=new A.cB()
B.C=new A.bR()
B.j=new A.cJ()
B.e=new A.cT()
B.D=new A.cV()
B.c=new A.dg()
B.f=new A.cf()
B.H=new A.cC(null)
B.a4=A.h(s([0,0,32722,12287,65534,34815,65534,18431]),t.t)
B.h=A.h(s([0,0,65490,45055,65535,34815,65534,18431]),t.t)
B.a5=A.h(s([0,0,32754,11263,65534,34815,65534,18431]),t.t)
B.o=A.h(s([0,0,26624,1023,65534,2047,65534,2047]),t.t)
B.p=A.h(s([0,0,65490,12287,65535,34815,65534,18431]),t.t)
B.I=new A.m(0,"accessor")
B.J=new A.m(1,"constant")
B.U=new A.m(2,"constructor")
B.Y=new A.m(3,"class_")
B.Z=new A.m(4,"dynamic")
B.a_=new A.m(5,"enum_")
B.a0=new A.m(6,"extension")
B.a1=new A.m(7,"extensionType")
B.a2=new A.m(8,"function")
B.a3=new A.m(9,"library")
B.K=new A.m(10,"method")
B.L=new A.m(11,"mixin")
B.M=new A.m(12,"never")
B.N=new A.m(13,"package")
B.O=new A.m(14,"parameter")
B.P=new A.m(15,"prefix")
B.Q=new A.m(16,"property")
B.R=new A.m(17,"sdk")
B.S=new A.m(18,"topic")
B.T=new A.m(19,"topLevelConstant")
B.V=new A.m(20,"topLevelProperty")
B.W=new A.m(21,"typedef")
B.X=new A.m(22,"typeParameter")
B.q=A.h(s([B.I,B.J,B.U,B.Y,B.Z,B.a_,B.a0,B.a1,B.a2,B.a3,B.K,B.L,B.M,B.N,B.O,B.P,B.Q,B.R,B.S,B.T,B.V,B.W,B.X]),A.bq("o<m>"))
B.r=A.h(s([0,0,32776,33792,1,10240,0,0]),t.t)
B.i=A.h(s([0,0,24576,1023,65534,34815,65534,18431]),t.t)
B.a8={}
B.a6=new A.aH(B.a8,[],A.bq("aH<d,d>"))
B.a9={input:0,textarea:1}
B.aa=new A.aI(B.a9,2,A.bq("aI<d>"))
B.ab=A.L("k_")
B.ac=A.L("k0")
B.ad=A.L("hA")
B.ae=A.L("hB")
B.af=A.L("hD")
B.ag=A.L("hE")
B.ah=A.L("hF")
B.ai=A.L("k")
B.aj=A.L("hZ")
B.ak=A.L("i_")
B.al=A.L("i0")
B.am=A.L("aj")
B.an=new A.cU(!1)
B.ao=new A.A(0,"isExactly")
B.ap=new A.A(1,"startsWith")
B.aq=new A.A(2,"contains")})();(function staticFields(){$.de=null
$.am=A.h([],A.bq("o<k>"))
$.eV=null
$.eN=null
$.eM=null
$.fV=null
$.fS=null
$.h_=null
$.dQ=null
$.e0=null
$.eD=null
$.df=A.h([],A.bq("o<f<k>?>"))
$.ax=null
$.bo=null
$.bp=null
$.ev=!1
$.q=B.c
$.ey=10
$.dO=0
$.bn=A.ed(t.N,t.m)})();(function lazyInitializers(){var s=hunkHelpers.lazyFinal
s($,"k1","eH",()=>A.jD("_$dart_dartClosure"))
s($,"k5","h2",()=>A.S(A.cN({
toString:function(){return"$receiver$"}})))
s($,"k6","h3",()=>A.S(A.cN({$method$:null,
toString:function(){return"$receiver$"}})))
s($,"k7","h4",()=>A.S(A.cN(null)))
s($,"k8","h5",()=>A.S(function(){var $argumentsExpr$="$arguments$"
try{null.$method$($argumentsExpr$)}catch(r){return r.message}}()))
s($,"kb","h8",()=>A.S(A.cN(void 0)))
s($,"kc","h9",()=>A.S(function(){var $argumentsExpr$="$arguments$"
try{(void 0).$method$($argumentsExpr$)}catch(r){return r.message}}()))
s($,"ka","h7",()=>A.S(A.f5(null)))
s($,"k9","h6",()=>A.S(function(){try{null.$method$}catch(r){return r.message}}()))
s($,"ke","hb",()=>A.S(A.f5(void 0)))
s($,"kd","ha",()=>A.S(function(){try{(void 0).$method$}catch(r){return r.message}}()))
s($,"kf","eI",()=>A.i2())
s($,"kl","hh",()=>A.hR(4096))
s($,"kj","hf",()=>new A.dx().$0())
s($,"kk","hg",()=>new A.dw().$0())
s($,"kg","hc",()=>A.hQ(A.iS(A.h([-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-1,-2,-2,-2,-2,-2,62,-2,62,-2,63,52,53,54,55,56,57,58,59,60,61,-2,-2,-2,-1,-2,-2,-2,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,-2,-2,-2,-2,63,-2,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,-2,-2,-2,-2,-2],t.t))))
s($,"kh","hd",()=>A.eZ("^[\\-\\.0-9A-Z_a-z~]*$",!0))
s($,"ki","he",()=>typeof URLSearchParams=="function")
s($,"kx","e6",()=>A.fY(B.ai))
s($,"kz","hi",()=>A.iQ())
s($,"ky","bt",()=>new A.dK().$0())})();(function nativeSupport(){!function(){var s=function(a){var m={}
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
hunkHelpers.setOrUpdateInterceptorsByTag({ArrayBuffer:A.bI,ArrayBufferView:A.aW,DataView:A.bJ,Float32Array:A.bK,Float64Array:A.bL,Int16Array:A.bM,Int32Array:A.bN,Int8Array:A.bO,Uint16Array:A.bP,Uint32Array:A.bQ,Uint8ClampedArray:A.aX,CanvasPixelArray:A.aX,Uint8Array:A.aY})
hunkHelpers.setOrUpdateLeafTags({ArrayBuffer:true,ArrayBufferView:false,DataView:true,Float32Array:true,Float64Array:true,Int16Array:true,Int32Array:true,Int8Array:true,Uint16Array:true,Uint32Array:true,Uint8ClampedArray:true,CanvasPixelArray:true,Uint8Array:false})
A.aq.$nativeSuperclassTag="ArrayBufferView"
A.b8.$nativeSuperclassTag="ArrayBufferView"
A.b9.$nativeSuperclassTag="ArrayBufferView"
A.aU.$nativeSuperclassTag="ArrayBufferView"
A.ba.$nativeSuperclassTag="ArrayBufferView"
A.bb.$nativeSuperclassTag="ArrayBufferView"
A.aV.$nativeSuperclassTag="ArrayBufferView"})()
Function.prototype.$0=function(){return this()}
Function.prototype.$1=function(a){return this(a)}
Function.prototype.$2=function(a,b){return this(a,b)}
Function.prototype.$1$1=function(a){return this(a)}
Function.prototype.$3=function(a,b,c){return this(a,b,c)}
Function.prototype.$4=function(a,b,c,d){return this(a,b,c,d)}
Function.prototype.$1$0=function(){return this()}
convertAllToFastObject(w)
convertToFastObject($);(function(a){if(typeof document==="undefined"){a(null)
return}if(typeof document.currentScript!="undefined"){a(document.currentScript)
return}var s=document.scripts
function onLoad(b){for(var q=0;q<s.length;++q){s[q].removeEventListener("load",onLoad,false)}a(b.target)}for(var r=0;r<s.length;++r){s[r].addEventListener("load",onLoad,false)}})(function(a){v.currentScript=a
var s=A.jP
if(typeof dartMainRunner==="function"){dartMainRunner(s,[])}else{s([])}})})()
//# sourceMappingURL=docs.dart.js.map
