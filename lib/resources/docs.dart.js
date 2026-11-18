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
if(a[b]!==s){A.k8(b)}a[b]=r}var q=a[b]
a[c]=function(){return q}
return q}}function makeConstList(a,b){if(b!=null)A.l(a,b)
a.$flags=7
return a}function convertToFastObject(a){function t(){}t.prototype=a
new t()
return a}function convertAllToFastObject(a){for(var s=0;s<a.length;++s){convertToFastObject(a[s])}}var y=0
function instanceTearOffGetter(a,b){var s=null
return a?function(c){if(s===null)s=A.eM(b)
return new s(c,this)}:function(){if(s===null)s=A.eM(b)
return new s(this,null)}}function staticTearOffGetter(a){var s=null
return function(){if(s===null)s=A.eM(a).prototype
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
eR(a,b,c,d){return{i:a,p:b,e:c,x:d}},
eO(a){var s,r,q,p,o,n="_$dart_js",m=a[v.dispatchPropertyName]
if(m==null)if($.eP==null){A.jU()
m=a[v.dispatchPropertyName]}if(m!=null){s=m.p
if(!1===s)return m.i
if(!0===s)return a
r=Object.getPrototypeOf(a)
if(s===r)return m.i
if(m.e===r)throw A.a(A.fg("Return interceptor for "+A.i(s(a,m))))}q=a.constructor
if(q==null)p=null
else{o=$.dg
if(o==null)o=$.dg=A.dU(n)
p=q[o]}if(p!=null)return p
p=A.jZ(a)
if(p!=null)return p
if(typeof a=="function")return B.B
s=Object.getPrototypeOf(a)
if(s==null)return B.o
if(s===Object.prototype)return B.o
if(typeof q=="function"){o=$.dg
if(o==null)o=$.dg=A.dU(n)
Object.defineProperty(q,o,{value:B.i,enumerable:false,writable:true,configurable:true})
return B.i}return B.i},
hL(a,b){if(a<0||a>4294967295)throw A.a(A.E(a,0,4294967295,"length",null))
return J.hM(new Array(a),b)},
hM(a,b){var s=A.l(a,b.j("p<0>"))
s.$flags=1
return s},
hN(a,b){return J.hq(a,b)},
an(a){if(typeof a=="number"){if(Math.floor(a)==a)return J.aT.prototype
return J.bK.prototype}if(typeof a=="string")return J.ae.prototype
if(a==null)return J.aU.prototype
if(typeof a=="boolean")return J.bJ.prototype
if(Array.isArray(a))return J.p.prototype
if(typeof a!="object"){if(typeof a=="function")return J.a1.prototype
if(typeof a=="symbol")return J.aY.prototype
if(typeof a=="bigint")return J.aW.prototype
return a}if(a instanceof A.k)return a
return J.eO(a)},
dS(a){if(typeof a=="string")return J.ae.prototype
if(a==null)return a
if(Array.isArray(a))return J.p.prototype
if(typeof a!="object"){if(typeof a=="function")return J.a1.prototype
if(typeof a=="symbol")return J.aY.prototype
if(typeof a=="bigint")return J.aW.prototype
return a}if(a instanceof A.k)return a
return J.eO(a)},
dT(a){if(a==null)return a
if(Array.isArray(a))return J.p.prototype
if(typeof a!="object"){if(typeof a=="function")return J.a1.prototype
if(typeof a=="symbol")return J.aY.prototype
if(typeof a=="bigint")return J.aW.prototype
return a}if(a instanceof A.k)return a
return J.eO(a)},
jN(a){if(typeof a=="number")return J.aV.prototype
if(typeof a=="string")return J.ae.prototype
if(a==null)return a
if(!(a instanceof A.k))return J.aw.prototype
return a},
C(a,b){if(a==null)return b==null
if(typeof a!="object")return b!=null&&a===b
return J.an(a).F(a,b)},
hn(a,b){if(typeof b==="number")if(Array.isArray(a)||typeof a=="string"||A.fZ(a,a[v.dispatchPropertyName]))if(b>>>0===b&&b<a.length)return a[b]
return J.dS(a).k(a,b)},
ho(a,b,c){if(typeof b==="number")if((Array.isArray(a)||A.fZ(a,a[v.dispatchPropertyName]))&&!(a.$flags&2)&&b>>>0===b&&b<a.length)return a[b]=c
return J.dT(a).q(a,b,c)},
hp(a,b){return J.dT(a).X(a,b)},
hq(a,b){return J.jN(a).aI(a,b)},
eT(a,b){return J.dT(a).E(a,b)},
Z(a){return J.an(a).gp(a)},
aK(a){return J.dT(a).gA(a)},
aL(a){return J.dS(a).gl(a)},
hr(a){return J.an(a).gt(a)},
a_(a){return J.an(a).h(a)},
bH:function bH(){},
bJ:function bJ(){},
aU:function aU(){},
aX:function aX(){},
a2:function a2(){},
bY:function bY(){},
aw:function aw(){},
a1:function a1(){},
aW:function aW(){},
aY:function aY(){},
p:function p(a){this.$ti=a},
bI:function bI(){},
cG:function cG(a){this.$ti=a},
O:function O(a,b,c){var _=this
_.a=a
_.b=b
_.c=0
_.d=null
_.$ti=c},
aV:function aV(){},
aT:function aT(){},
bK:function bK(){},
ae:function ae(){}},A={ed:function ed(){},
hu(a,b,c){if(t.U.b(a))return new A.bf(a,b.j("@<0>").D(c).j("bf<1,2>"))
return new A.ab(a,b.j("@<0>").D(c).j("ab<1,2>"))},
f4(a){return new A.bM("Field '"+a+"' has been assigned during initialization.")},
dV(a){var s,r=a^48
if(r<=9)return r
s=a|32
if(97<=s&&s<=102)return s-87
return-1},
a5(a,b){a=a+b&536870911
a=a+((a&524287)<<10)&536870911
return a^a>>>6},
el(a){a=a+((a&67108863)<<3)&536870911
a^=a>>>11
return a+((a&16383)<<15)&536870911},
eL(a,b,c){return a},
eQ(a){var s,r
for(s=$.ak.length,r=0;r<s;++r)if(a===$.ak[r])return!0
return!1},
f1(){return new A.bb("No element")},
a6:function a6(){},
bB:function bB(a,b){this.a=a
this.$ti=b},
ab:function ab(a,b){this.a=a
this.$ti=b},
bf:function bf(a,b){this.a=a
this.$ti=b},
be:function be(){},
S:function S(a,b){this.a=a
this.$ti=b},
bM:function bM(a){this.a=a},
bC:function bC(a){this.a=a},
cP:function cP(){},
c:function c(){},
J:function J(){},
ar:function ar(a,b,c){var _=this
_.a=a
_.b=b
_.c=0
_.d=null
_.$ti=c},
ah:function ah(a,b,c){this.a=a
this.b=b
this.$ti=c},
au:function au(a,b){this.a=a
this.$ti=b},
bW:function bW(a){this.a=a
this.b=null},
aS:function aS(){},
c3:function c3(){},
ax:function ax(){},
bu:function bu(){},
hA(){throw A.a(A.c4("Cannot modify unmodifiable Map"))},
h4(a){var s=A.h3(a)
if(s!=null)return s
return"minified:"+a},
fZ(a,b){var s
if(b!=null){s=b.x
if(s!=null)return s}return t.p.b(a)},
i(a){var s
if(typeof a=="string")return a
if(typeof a=="number"){if(a!==0)return""+a}else if(!0===a)return"true"
else if(!1===a)return"false"
else if(a==null)return"null"
s=J.a_(a)
return s},
bZ(a){var s,r=$.f7
if(r==null)r=$.f7=Symbol("identityHashCode")
s=a[r]
if(s==null){s=Math.random()*0x3fffffff|0
a[r]=s}return s},
f8(a,b){var s,r=/^\s*[+-]?((0x[a-f0-9]+)|(\d+)|([a-z0-9]+))\s*$/i.exec(a)
if(r==null)return null
s=r[3]
if(s!=null)return parseInt(a,10)
if(r[2]!=null)return parseInt(a,16)
return null},
c_(a){var s,r,q,p
if(a instanceof A.k)return A.F(A.aI(a),null)
s=J.an(a)
if(s===B.A||s===B.C||t.A.b(a)){r=B.k(a)
if(r!=="Object"&&r!=="")return r
q=a.constructor
if(typeof q=="function"){p=q.name
if(typeof p=="string"&&p!=="Object"&&p!=="")return p}}return A.F(A.aI(a),null)},
f9(a){var s,r,q
if(a==null||typeof a=="number"||A.eD(a))return J.a_(a)
if(typeof a=="string")return JSON.stringify(a)
if(a instanceof A.ac)return a.h(0)
if(a instanceof A.bk)return a.aG(!0)
s=$.hm()
for(r=0;r<1;++r){q=s[r].bX(a)
if(q!=null)return q}return"Instance of '"+A.c_(a)+"'"},
hT(a,b,c){var s,r,q,p
if(c<=500&&b===0&&c===a.length)return String.fromCharCode.apply(null,a)
for(s=b,r="";s<c;s=q){q=s+500
p=q<c?q:c
r+=String.fromCharCode.apply(null,a.subarray(s,p))}return r},
a3(a){var s
if(0<=a){if(a<=65535)return String.fromCharCode(a)
if(a<=1114111){s=a-65536
return String.fromCharCode((B.b.ac(s,10)|55296)>>>0,s&1023|56320)}}throw A.a(A.E(a,0,1114111,null,null))},
hS(a){var s=a.$thrownJsError
if(s==null)return null
return A.aH(s)},
fa(a,b){var s
if(a.$thrownJsError==null){s=new Error()
A.v(a,s)
a.$thrownJsError=s
s.stack=b.h(0)}},
eN(a,b){var s,r="index"
if(!A.fK(b))return new A.H(!0,b,r,null)
s=J.aL(a)
if(b<0||b>=s)return A.eb(b,s,a,r)
return A.hU(b,r)},
jK(a,b,c){if(a>c)return A.E(a,0,c,"start",null)
if(b!=null)if(b<a||b>c)return A.E(b,a,c,"end",null)
return new A.H(!0,b,"end",null)},
jE(a){return new A.H(!0,a,null,null)},
a(a){return A.v(a,new Error())},
v(a,b){var s
if(a==null)a=new A.U()
b.dartException=a
s=A.k9
if("defineProperty" in Object){Object.defineProperty(b,"message",{get:s})
b.name=""}else b.toString=s
return b},
k9(){return J.a_(this.dartException)},
ap(a,b){throw A.v(a,b==null?new Error():b)},
M(a,b,c){var s
if(b==null)b=0
if(c==null)c=0
s=Error()
A.ap(A.iZ(a,b,c),s)},
iZ(a,b,c){var s,r,q,p,o,n,m,l,k
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
return new A.bc("'"+s+"': Cannot "+o+" "+l+k+n)},
aa(a){throw A.a(A.ad(a))},
V(a){var s,r,q,p,o,n
a=A.k2(a.replace(String({}),"$receiver$"))
s=a.match(/\\\$[a-zA-Z]+\\\$/g)
if(s==null)s=A.l([],t.s)
r=s.indexOf("\\$arguments\\$")
q=s.indexOf("\\$argumentsExpr\\$")
p=s.indexOf("\\$expr\\$")
o=s.indexOf("\\$method\\$")
n=s.indexOf("\\$receiver\\$")
return new A.cS(a.replace(new RegExp("\\\\\\$arguments\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$argumentsExpr\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$expr\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$method\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$receiver\\\\\\$","g"),"((?:x|[^x])*)"),r,q,p,o,n)},
cT(a){return function($expr$){var $argumentsExpr$="$arguments$"
try{$expr$.$method$($argumentsExpr$)}catch(s){return s.message}}(a)},
ff(a){return function($expr$){try{$expr$.$method$}catch(s){return s.message}}(a)},
ee(a,b){var s=b==null,r=s?null:b.method
return new A.bL(a,r,s?null:b.receiver)},
aq(a){if(a==null)return new A.cO(a)
if(a instanceof A.aR)return A.a9(a,a.a)
if(typeof a!=="object")return a
if("dartException" in a)return A.a9(a,a.dartException)
return A.jD(a)},
a9(a,b){if(t.C.b(b))if(b.$thrownJsError==null)b.$thrownJsError=a
return b},
jD(a){var s,r,q,p,o,n,m,l,k,j,i,h,g
if(!("message" in a))return a
s=a.message
if("number" in a&&typeof a.number=="number"){r=a.number
q=r&65535
if((B.b.ac(r,16)&8191)===10)switch(q){case 438:return A.a9(a,A.ee(A.i(s)+" (Error "+q+")",null))
case 445:case 5007:A.i(s)
return A.a9(a,new A.b6())}}if(a instanceof TypeError){p=$.h6()
o=$.h7()
n=$.h8()
m=$.h9()
l=$.hc()
k=$.hd()
j=$.hb()
$.ha()
i=$.hf()
h=$.he()
g=p.C(s)
if(g!=null)return A.a9(a,A.ee(s,g))
else{g=o.C(s)
if(g!=null){g.method="call"
return A.a9(a,A.ee(s,g))}else if(n.C(s)!=null||m.C(s)!=null||l.C(s)!=null||k.C(s)!=null||j.C(s)!=null||m.C(s)!=null||i.C(s)!=null||h.C(s)!=null)return A.a9(a,new A.b6())}return A.a9(a,new A.c2(typeof s=="string"?s:""))}if(a instanceof RangeError){if(typeof s=="string"&&s.indexOf("call stack")!==-1)return new A.ba()
s=function(b){try{return String(b)}catch(f){}return null}(a)
return A.a9(a,new A.H(!1,null,null,typeof s=="string"?s.replace(/^RangeError:\s*/,""):s))}if(typeof InternalError=="function"&&a instanceof InternalError)if(typeof s=="string"&&s==="too much recursion")return new A.ba()
return a},
aH(a){var s
if(a instanceof A.aR)return a.b
if(a==null)return new A.bl(a)
s=a.$cachedTrace
if(s!=null)return s
s=new A.bl(a)
if(typeof a==="object")a.$cachedTrace=s
return s},
h0(a){if(a==null)return J.Z(a)
if(typeof a=="object")return A.bZ(a)
return J.Z(a)},
jM(a,b){var s,r,q,p=a.length
for(s=0;s<p;s=q){r=s+1
q=r+1
b.q(0,a[s],a[r])}return b},
jc(a,b,c,d,e,f){switch(b){case 0:return a.$0()
case 1:return a.$1(c)
case 2:return a.$2(c,d)
case 3:return a.$3(c,d,e)
case 4:return a.$4(c,d,e,f)}throw A.a(new A.d5("Unsupported number of arguments for wrapped closure"))},
aG(a,b){var s=a.$identity
if(!!s)return s
s=A.jI(a,b)
a.$identity=s
return s},
jI(a,b){var s
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
return function(c,d,e){return function(f,g,h,i){return e(c,d,f,g,h,i)}}(a,b,A.jc)},
hz(a2){var s,r,q,p,o,n,m,l,k,j,i=a2.co,h=a2.iS,g=a2.iI,f=a2.nDA,e=a2.aI,d=a2.fs,c=a2.cs,b=d[0],a=c[0],a0=i[b],a1=a2.fT
a1.toString
s=h?Object.create(new A.cQ().constructor.prototype):Object.create(new A.aM(null,null).constructor.prototype)
s.$initialize=s.constructor
r=h?function static_tear_off(){this.$initialize()}:function tear_off(a3,a4){this.$initialize(a3,a4)}
s.constructor=r
r.prototype=s
s.$_name=b
s.$_target=a0
q=!h
if(q)p=A.f_(b,a0,g,f)
else{s.$static_name=b
p=a0}s.$S=A.hv(a1,h,g)
s[a]=p
for(o=p,n=1;n<d.length;++n){m=d[n]
if(typeof m=="string"){l=i[m]
k=m
m=l}else k=""
j=c[n]
if(j!=null){if(q)m=A.f_(k,m,g,f)
s[j]=m}if(n===e)o=m}s.$C=o
s.$R=a2.rC
s.$D=a2.dV
return r},
hv(a,b,c){if(typeof a=="number")return a
if(typeof a=="string"){if(b)throw A.a("Cannot compute signature for static tearoff.")
return function(d,e){return function(){return e(this,d)}}(a,A.hs)}throw A.a("Error in functionType of tearoff")},
hw(a,b,c,d){var s=A.eZ
switch(b?-1:a){case 0:return function(e,f){return function(){return f(this)[e]()}}(c,s)
case 1:return function(e,f){return function(g){return f(this)[e](g)}}(c,s)
case 2:return function(e,f){return function(g,h){return f(this)[e](g,h)}}(c,s)
case 3:return function(e,f){return function(g,h,i){return f(this)[e](g,h,i)}}(c,s)
case 4:return function(e,f){return function(g,h,i,j){return f(this)[e](g,h,i,j)}}(c,s)
case 5:return function(e,f){return function(g,h,i,j,k){return f(this)[e](g,h,i,j,k)}}(c,s)
default:return function(e,f){return function(){return e.apply(f(this),arguments)}}(d,s)}},
f_(a,b,c,d){if(c)return A.hy(a,b,d)
return A.hw(b.length,d,a,b)},
hx(a,b,c,d){var s=A.eZ,r=A.ht
switch(b?-1:a){case 0:throw A.a(new A.c0("Intercepted function with no arguments."))
case 1:return function(e,f,g){return function(){return f(this)[e](g(this))}}(c,r,s)
case 2:return function(e,f,g){return function(h){return f(this)[e](g(this),h)}}(c,r,s)
case 3:return function(e,f,g){return function(h,i){return f(this)[e](g(this),h,i)}}(c,r,s)
case 4:return function(e,f,g){return function(h,i,j){return f(this)[e](g(this),h,i,j)}}(c,r,s)
case 5:return function(e,f,g){return function(h,i,j,k){return f(this)[e](g(this),h,i,j,k)}}(c,r,s)
case 6:return function(e,f,g){return function(h,i,j,k,l){return f(this)[e](g(this),h,i,j,k,l)}}(c,r,s)
default:return function(e,f,g){return function(){var q=[g(this)]
Array.prototype.push.apply(q,arguments)
return e.apply(f(this),q)}}(d,r,s)}},
hy(a,b,c){var s,r
if($.eX==null)$.eX=A.eW("interceptor")
if($.eY==null)$.eY=A.eW("receiver")
s=b.length
r=A.hx(s,c,a,b)
return r},
eM(a){return A.hz(a)},
hs(a,b){return A.bq(v.typeUniverse,A.aI(a.a),b)},
eZ(a){return a.a},
ht(a){return a.b},
eW(a){var s,r,q,p=new A.aM("receiver","interceptor"),o=Object.getOwnPropertyNames(p)
o.$flags=1
s=o
for(o=s.length,r=0;r<o;++r){q=s[r]
if(p[q]===a)return q}throw A.a(A.R("Field name "+a+" not found.",null))},
dU(a){return v.getIsolateTag(a)},
jZ(a){var s,r,q,p,o,n=$.fY.$1(a),m=$.dR[n]
if(m!=null){Object.defineProperty(a,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
return m.i}s=$.e2[n]
if(s!=null)return s
r=v.interceptorsByTag[n]
if(r==null){q=$.fV.$2(a,n)
if(q!=null){m=$.dR[q]
if(m!=null){Object.defineProperty(a,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
return m.i}s=$.e2[q]
if(s!=null)return s
r=v.interceptorsByTag[q]
n=q}}if(r==null)return null
s=r.prototype
p=n[0]
if(p==="!"){m=A.e3(s)
$.dR[n]=m
Object.defineProperty(a,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
return m.i}if(p==="~"){$.e2[n]=s
return s}if(p==="-"){o=A.e3(s)
Object.defineProperty(Object.getPrototypeOf(a),v.dispatchPropertyName,{value:o,enumerable:false,writable:true,configurable:true})
return o.i}if(p==="+")return A.h1(a,s)
if(p==="*")throw A.a(A.fg(n))
if(v.leafTags[n]===true){o=A.e3(s)
Object.defineProperty(Object.getPrototypeOf(a),v.dispatchPropertyName,{value:o,enumerable:false,writable:true,configurable:true})
return o.i}else return A.h1(a,s)},
h1(a,b){var s=Object.getPrototypeOf(a)
Object.defineProperty(s,v.dispatchPropertyName,{value:J.eR(b,s,null,null),enumerable:false,writable:true,configurable:true})
return b},
e3(a){return J.eR(a,!1,null,!!a.$iD)},
k0(a,b,c){var s=b.prototype
if(v.leafTags[a]===true)return A.e3(s)
else return J.eR(s,c,null,null)},
jU(){if(!0===$.eP)return
$.eP=!0
A.jV()},
jV(){var s,r,q,p,o,n,m,l
$.dR=Object.create(null)
$.e2=Object.create(null)
A.jT()
s=v.interceptorsByTag
r=Object.getOwnPropertyNames(s)
if(typeof window!="undefined"){window
q=function(){}
for(p=0;p<r.length;++p){o=r[p]
n=$.h2.$1(o)
if(n!=null){m=A.k0(o,s[o],n)
if(m!=null){Object.defineProperty(n,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
q.prototype=n}}}}for(p=0;p<r.length;++p){o=r[p]
if(/^[A-Za-z_]/.test(o)){l=s[o]
s["!"+o]=l
s["~"+o]=l
s["-"+o]=l
s["+"+o]=l
s["*"+o]=l}}},
jT(){var s,r,q,p,o,n,m=B.q()
m=A.aF(B.r,A.aF(B.t,A.aF(B.l,A.aF(B.l,A.aF(B.u,A.aF(B.v,A.aF(B.w(B.k),m)))))))
if(typeof dartNativeDispatchHooksTransformer!="undefined"){s=dartNativeDispatchHooksTransformer
if(typeof s=="function")s=[s]
if(Array.isArray(s))for(r=0;r<s.length;++r){q=s[r]
if(typeof q=="function")m=q(m)||m}}p=m.getTag
o=m.getUnknownTag
n=m.prototypeForTag
$.fY=new A.dW(p)
$.fV=new A.dX(o)
$.h2=new A.dY(n)},
aF(a,b){return a(b)||b},
jJ(a,b){var s=b.length,r=v.rttc[""+s+";"+a]
if(r==null)return null
if(s===0)return r
if(s===r.length)return r.apply(null,b)
return r(b)},
f3(a,b,c,d,e,f){var s=b?"m":"",r=c?"":"i",q=d?"u":"",p=e?"s":"",o=function(g,h){try{return new RegExp(g,h)}catch(n){return n}}(a,s+r+q+p+f)
if(o instanceof RegExp)return o
throw A.a(A.y("Illegal RegExp pattern ("+String(o)+")",a,null))},
k6(a,b,c){var s=a.indexOf(b,c)
return s>=0},
k2(a){if(/[[\]{}()*+?.\\^$|]/.test(a))return a.replace(/[[\]{}()*+?.\\^$|]/g,"\\$&")
return a},
fT(a){return a},
k7(a,b,c,d){var s,r,q,p=new A.d_(b,a,0),o=t.F,n=0,m=""
while(p.m()){s=p.d
if(s==null)s=o.a(s)
r=s.b
q=r.index
m=m+A.i(A.fT(B.a.i(a,n,q)))+A.i(c.$1(s))
n=q+r[0].length}p=m+A.i(A.fT(B.a.I(a,n)))
return p.charCodeAt(0)==0?p:p},
cj:function cj(a,b){this.a=a
this.b=b},
aN:function aN(){},
aP:function aP(a,b,c){this.a=a
this.b=b
this.$ti=c},
cf:function cf(a,b,c){var _=this
_.a=a
_.b=b
_.c=0
_.d=null
_.$ti=c},
aO:function aO(){},
aQ:function aQ(a,b,c){this.a=a
this.b=b
this.$ti=c},
b9:function b9(){},
cS:function cS(a,b,c,d,e,f){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f},
b6:function b6(){},
bL:function bL(a,b,c){this.a=a
this.b=b
this.c=c},
c2:function c2(a){this.a=a},
cO:function cO(a){this.a=a},
aR:function aR(a,b){this.a=a
this.b=b},
bl:function bl(a){this.a=a
this.b=null},
ac:function ac(){},
cu:function cu(){},
cv:function cv(){},
cR:function cR(){},
cQ:function cQ(){},
aM:function aM(a,b){this.a=a
this.b=b},
c0:function c0(a){this.a=a},
af:function af(a){var _=this
_.a=0
_.f=_.e=_.d=_.c=_.b=null
_.r=0
_.$ti=a},
cJ:function cJ(a,b){this.a=a
this.b=b
this.c=null},
ag:function ag(a,b){this.a=a
this.$ti=b},
bN:function bN(a,b,c){var _=this
_.a=a
_.b=b
_.c=c
_.d=null},
b_:function b_(a,b){this.a=a
this.$ti=b},
aZ:function aZ(a,b,c){var _=this
_.a=a
_.b=b
_.c=c
_.d=null},
dW:function dW(a){this.a=a},
dX:function dX(a){this.a=a},
dY:function dY(a){this.a=a},
bk:function bk(){},
ci:function ci(){},
cF:function cF(a,b){var _=this
_.a=a
_.b=b
_.e=_.d=_.c=null},
ch:function ch(a){this.b=a},
d_:function d_(a,b,c){var _=this
_.a=a
_.b=b
_.c=c
_.d=null},
j_(a){return a},
hP(a){return new Int8Array(a)},
hQ(a){return new Uint8Array(a)},
X(a,b,c){if(a>>>0!==a||a>=c)throw A.a(A.eN(b,a))},
iW(a,b,c){var s
if(!(a>>>0!==a))s=b>>>0!==b||a>b||b>c
else s=!0
if(s)throw A.a(A.jK(a,b,c))
return b},
as:function as(){},
b3:function b3(){},
bO:function bO(){},
at:function at(){},
b1:function b1(){},
b2:function b2(){},
bP:function bP(){},
bQ:function bQ(){},
bR:function bR(){},
bS:function bS(){},
bT:function bT(){},
bU:function bU(){},
bV:function bV(){},
b4:function b4(){},
b5:function b5(){},
bg:function bg(){},
bh:function bh(){},
bi:function bi(){},
bj:function bj(){},
ej(a,b){var s=b.c
return s==null?b.c=A.bo(a,"Q",[b.x]):s},
fc(a){var s=a.w
if(s===6||s===7)return A.fc(a.x)
return s===11||s===12},
hV(a){return a.as},
by(a){return A.dv(v.typeUniverse,a,!1)},
aj(a1,a2,a3,a4){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0=a2.w
switch(a0){case 5:case 1:case 2:case 3:case 4:return a2
case 6:s=a2.x
r=A.aj(a1,s,a3,a4)
if(r===s)return a2
return A.fq(a1,r,!0)
case 7:s=a2.x
r=A.aj(a1,s,a3,a4)
if(r===s)return a2
return A.fp(a1,r,!0)
case 8:q=a2.y
p=A.aE(a1,q,a3,a4)
if(p===q)return a2
return A.bo(a1,a2.x,p)
case 9:o=a2.x
n=A.aj(a1,o,a3,a4)
m=a2.y
l=A.aE(a1,m,a3,a4)
if(n===o&&l===m)return a2
return A.en(a1,n,l)
case 10:k=a2.x
j=a2.y
i=A.aE(a1,j,a3,a4)
if(i===j)return a2
return A.fr(a1,k,i)
case 11:h=a2.x
g=A.aj(a1,h,a3,a4)
f=a2.y
e=A.jA(a1,f,a3,a4)
if(g===h&&e===f)return a2
return A.fo(a1,g,e)
case 12:d=a2.y
a4+=d.length
c=A.aE(a1,d,a3,a4)
o=a2.x
n=A.aj(a1,o,a3,a4)
if(c===d&&n===o)return a2
return A.eo(a1,n,c,!0)
case 13:b=a2.x
if(b<a4)return a2
a=a3[b-a4]
if(a==null)return a2
return a
default:throw A.a(A.bA("Attempted to substitute unexpected RTI kind "+a0))}},
aE(a,b,c,d){var s,r,q,p,o=b.length,n=A.dD(o)
for(s=!1,r=0;r<o;++r){q=b[r]
p=A.aj(a,q,c,d)
if(p!==q)s=!0
n[r]=p}return s?n:b},
jB(a,b,c,d){var s,r,q,p,o,n,m=b.length,l=A.dD(m)
for(s=!1,r=0;r<m;r+=3){q=b[r]
p=b[r+1]
o=b[r+2]
n=A.aj(a,o,c,d)
if(n!==o)s=!0
l.splice(r,3,q,p,n)}return s?l:b},
jA(a,b,c,d){var s,r=b.a,q=A.aE(a,r,c,d),p=b.b,o=A.aE(a,p,c,d),n=b.c,m=A.jB(a,n,c,d)
if(q===r&&o===p&&m===n)return b
s=new A.cc()
s.a=q
s.b=o
s.c=m
return s},
l(a,b){a[v.arrayRti]=b
return a},
fX(a){var s=a.$S
if(s!=null){if(typeof s=="number")return A.jP(s)
return a.$S()}return null},
jW(a,b){var s
if(A.fc(b))if(a instanceof A.ac){s=A.fX(a)
if(s!=null)return s}return A.aI(a)},
aI(a){if(a instanceof A.k)return A.Y(a)
if(Array.isArray(a))return A.W(a)
return A.eC(J.an(a))},
W(a){var s=a[v.arrayRti],r=t.b
if(s==null)return r
if(s.constructor!==r.constructor)return r
return s},
Y(a){var s=a.$ti
return s!=null?s:A.eC(a)},
eC(a){var s=a.constructor,r=s.$ccache
if(r!=null)return r
return A.j8(a,s)},
j8(a,b){var s=a instanceof A.ac?Object.getPrototypeOf(Object.getPrototypeOf(a)).constructor:b,r=A.ir(v.typeUniverse,s.name)
b.$ccache=r
return r},
jP(a){var s,r=v.types,q=r[a]
if(typeof q=="string"){s=A.dv(v.typeUniverse,q,!1)
r[a]=s
return s}return q},
jO(a){return A.am(A.Y(a))},
eI(a){var s
if(a instanceof A.bk)return A.jL(a.$r,a.aA())
s=a instanceof A.ac?A.fX(a):null
if(s!=null)return s
if(t.q.b(a))return J.hr(a).a
if(Array.isArray(a))return A.W(a)
return A.aI(a)},
am(a){var s=a.r
return s==null?a.r=new A.du(a):s},
jL(a,b){var s,r,q=b,p=q.length
if(p===0)return t.d
s=A.bq(v.typeUniverse,A.eI(q[0]),"@<0>")
for(r=1;r<p;++r)s=A.ft(v.typeUniverse,s,A.eI(q[r]))
return A.bq(v.typeUniverse,s,a)},
N(a){return A.am(A.dv(v.typeUniverse,a,!1))},
j7(a){var s=this
s.b=A.jy(s)
return s.b(a)},
jy(a){var s,r,q,p
if(a===t.K)return A.ji
if(A.ao(a))return A.jm
s=a.w
if(s===6)return A.j3
if(s===1)return A.fM
if(s===7)return A.jd
r=A.jx(a)
if(r!=null)return r
if(s===8){q=a.x
if(a.y.every(A.ao)){a.f="$i"+q
if(q==="f")return A.jg
if(a===t.m)return A.jf
return A.jl}}else if(s===10){p=A.jJ(a.x,a.y)
return p==null?A.fM:p}return A.j1},
jx(a){if(a.w===8){if(a===t.S)return A.fK
if(a===t.i||a===t.H)return A.jh
if(a===t.N)return A.jk
if(a===t.y)return A.eD}return null},
j6(a){var s=this,r=A.j0
if(A.ao(s))r=A.iS
else if(s===t.K)r=A.iR
else if(A.aJ(s)){r=A.j2
if(s===t.w)r=A.ew
else if(s===t.u)r=A.fF
else if(s===t.e)r=A.iM
else if(s===t.x)r=A.iQ
else if(s===t.I)r=A.iO
else if(s===t.B)r=A.fE}else if(s===t.S)r=A.ev
else if(s===t.N)r=A.ex
else if(s===t.y)r=A.iL
else if(s===t.H)r=A.iP
else if(s===t.i)r=A.iN
else if(s===t.m)r=A.fD
s.a=r
return s.a(a)},
j1(a){var s=this
if(a==null)return A.aJ(s)
return A.jY(v.typeUniverse,A.jW(a,s),s)},
j3(a){if(a==null)return!0
return this.x.b(a)},
jl(a){var s,r=this
if(a==null)return A.aJ(r)
s=r.f
if(a instanceof A.k)return!!a[s]
return!!J.an(a)[s]},
jg(a){var s,r=this
if(a==null)return A.aJ(r)
if(typeof a!="object")return!1
if(Array.isArray(a))return!0
s=r.f
if(a instanceof A.k)return!!a[s]
return!!J.an(a)[s]},
jf(a){var s=this
if(a==null)return!1
if(typeof a=="object"){if(a instanceof A.k)return!!a[s.f]
return!0}if(typeof a=="function")return!0
return!1},
fL(a){if(typeof a=="object"){if(a instanceof A.k)return t.m.b(a)
return!0}if(typeof a=="function")return!0
return!1},
j0(a){var s=this
if(a==null){if(A.aJ(s))return a}else if(s.b(a))return a
throw A.v(A.fH(a,s),new Error())},
j2(a){var s=this
if(a==null||s.b(a))return a
throw A.v(A.fH(a,s),new Error())},
fH(a,b){return new A.bm("TypeError: "+A.fk(a,A.F(b,null)))},
fk(a,b){return A.cy(a)+": type '"+A.F(A.eI(a),null)+"' is not a subtype of type '"+b+"'"},
G(a,b){return new A.bm("TypeError: "+A.fk(a,b))},
jd(a){var s=this
return s.x.b(a)||A.ej(v.typeUniverse,s).b(a)},
ji(a){return a!=null},
iR(a){if(a!=null)return a
throw A.v(A.G(a,"Object"),new Error())},
jm(a){return!0},
iS(a){return a},
fM(a){return!1},
eD(a){return!0===a||!1===a},
iL(a){if(!0===a)return!0
if(!1===a)return!1
throw A.v(A.G(a,"bool"),new Error())},
iM(a){if(!0===a)return!0
if(!1===a)return!1
if(a==null)return a
throw A.v(A.G(a,"bool?"),new Error())},
iN(a){if(typeof a=="number")return a
throw A.v(A.G(a,"double"),new Error())},
iO(a){if(typeof a=="number")return a
if(a==null)return a
throw A.v(A.G(a,"double?"),new Error())},
fK(a){return typeof a=="number"&&Math.floor(a)===a},
ev(a){if(typeof a=="number"&&Math.floor(a)===a)return a
throw A.v(A.G(a,"int"),new Error())},
ew(a){if(typeof a=="number"&&Math.floor(a)===a)return a
if(a==null)return a
throw A.v(A.G(a,"int?"),new Error())},
jh(a){return typeof a=="number"},
iP(a){if(typeof a=="number")return a
throw A.v(A.G(a,"num"),new Error())},
iQ(a){if(typeof a=="number")return a
if(a==null)return a
throw A.v(A.G(a,"num?"),new Error())},
jk(a){return typeof a=="string"},
ex(a){if(typeof a=="string")return a
throw A.v(A.G(a,"String"),new Error())},
fF(a){if(typeof a=="string")return a
if(a==null)return a
throw A.v(A.G(a,"String?"),new Error())},
fD(a){if(A.fL(a))return a
throw A.v(A.G(a,"JSObject"),new Error())},
fE(a){if(a==null)return a
if(A.fL(a))return a
throw A.v(A.G(a,"JSObject?"),new Error())},
fP(a,b){var s,r,q
for(s="",r="",q=0;q<a.length;++q,r=", ")s+=r+A.F(a[q],b)
return s},
jr(a,b){var s,r,q,p,o,n,m=a.x,l=a.y
if(""===m)return"("+A.fP(l,b)+")"
s=l.length
r=m.split(",")
q=r.length-s
for(p="(",o="",n=0;n<s;++n,o=", "){p+=o
if(q===0)p+="{"
p+=A.F(l[n],b)
if(q>=0)p+=" "+r[q];++q}return p+"})"},
fI(a1,a2,a3){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a=", ",a0=null
if(a3!=null){s=a3.length
if(a2==null)a2=A.l([],t.s)
else a0=a2.length
r=a2.length
for(q=s;q>0;--q)a2.push("T"+(r+q))
for(p=t.X,o="<",n="",q=0;q<s;++q,n=a){o=o+n+a2[a2.length-1-q]
m=a3[q]
l=m.w
if(!(l===2||l===3||l===4||l===5||m===p))o+=" extends "+A.F(m,a2)}o+=">"}else o=""
p=a1.x
k=a1.y
j=k.a
i=j.length
h=k.b
g=h.length
f=k.c
e=f.length
d=A.F(p,a2)
for(c="",b="",q=0;q<i;++q,b=a)c+=b+A.F(j[q],a2)
if(g>0){c+=b+"["
for(b="",q=0;q<g;++q,b=a)c+=b+A.F(h[q],a2)
c+="]"}if(e>0){c+=b+"{"
for(b="",q=0;q<e;q+=3,b=a){c+=b
if(f[q+1])c+="required "
c+=A.F(f[q+2],a2)+" "+f[q]}c+="}"}if(a0!=null){a2.toString
a2.length=a0}return o+"("+c+") => "+d},
F(a,b){var s,r,q,p,o,n,m=a.w
if(m===5)return"erased"
if(m===2)return"dynamic"
if(m===3)return"void"
if(m===1)return"Never"
if(m===4)return"any"
if(m===6){s=a.x
r=A.F(s,b)
q=s.w
return(q===11||q===12?"("+r+")":r)+"?"}if(m===7)return"FutureOr<"+A.F(a.x,b)+">"
if(m===8){p=A.jC(a.x)
o=a.y
return o.length>0?p+("<"+A.fP(o,b)+">"):p}if(m===10)return A.jr(a,b)
if(m===11)return A.fI(a,b,null)
if(m===12)return A.fI(a.x,b,a.y)
if(m===13){n=a.x
return b[b.length-1-n]}return"?"},
jC(a){var s=A.h3(a)
if(s!=null)return s
return"minified:"+a},
is(a,b){var s=a.tR[b]
while(typeof s=="string")s=a.tR[s]
return s},
ir(a,b){var s,r,q,p,o,n=a.eT,m=n[b]
if(m==null)return A.dv(a,b,!1)
else if(typeof m=="number"){s=m
r=A.bp(a,5,"#")
q=A.dD(s)
for(p=0;p<s;++p)q[p]=r
o=A.bo(a,b,q)
n[b]=o
return o}else return m},
iq(a,b){return A.fB(a.tR,b)},
ip(a,b){return A.fB(a.eT,b)},
dv(a,b,c){var s,r=a.eC,q=r.get(b)
if(q!=null)return q
s=A.fs(a,null,b,!1)
r.set(b,s)
return s},
bq(a,b,c){var s,r,q=b.z
if(q==null)q=b.z=new Map()
s=q.get(c)
if(s!=null)return s
r=A.fs(a,b,c,!0)
q.set(c,r)
return r},
ft(a,b,c){var s,r,q,p=b.Q
if(p==null)p=b.Q=new Map()
s=c.as
r=p.get(s)
if(r!=null)return r
q=A.en(a,b,c.w===9?c.y:[c])
p.set(s,q)
return q},
fs(a,b,c,d){return A.ig(A.i9(a,b,c,d))},
a7(a,b){b.a=A.j6
b.b=A.j7
return b},
bp(a,b,c){var s,r,q=a.eC.get(c)
if(q!=null)return q
s=new A.K(null,null)
s.w=b
s.as=c
r=A.a7(a,s)
a.eC.set(c,r)
return r},
fq(a,b,c){var s,r=b.as+"?",q=a.eC.get(r)
if(q!=null)return q
s=A.im(a,b,r,c)
a.eC.set(r,s)
return s},
im(a,b,c,d){var s,r,q
if(d){s=b.w
r=!0
if(!A.ao(b))if(!(b===t.P||b===t.T))if(s!==6)r=s===7&&A.aJ(b.x)
if(r)return b
else if(s===1)return t.P}q=new A.K(null,null)
q.w=6
q.x=b
q.as=c
return A.a7(a,q)},
fp(a,b,c){var s,r=b.as+"/",q=a.eC.get(r)
if(q!=null)return q
s=A.ik(a,b,r,c)
a.eC.set(r,s)
return s},
ik(a,b,c,d){var s,r
if(d){s=b.w
if(A.ao(b)||b===t.K)return b
else if(s===1)return A.bo(a,"Q",[b])
else if(b===t.P||b===t.T)return t.W}r=new A.K(null,null)
r.w=7
r.x=b
r.as=c
return A.a7(a,r)},
io(a,b){var s,r,q=""+b+"^",p=a.eC.get(q)
if(p!=null)return p
s=new A.K(null,null)
s.w=13
s.x=b
s.as=q
r=A.a7(a,s)
a.eC.set(q,r)
return r},
bn(a){var s,r,q,p=a.length
for(s="",r="",q=0;q<p;++q,r=",")s+=r+a[q].as
return s},
ij(a){var s,r,q,p,o,n=a.length
for(s="",r="",q=0;q<n;q+=3,r=","){p=a[q]
o=a[q+1]?"!":":"
s+=r+p+o+a[q+2].as}return s},
bo(a,b,c){var s,r,q,p=b
if(c.length>0)p+="<"+A.bn(c)+">"
s=a.eC.get(p)
if(s!=null)return s
r=new A.K(null,null)
r.w=8
r.x=b
r.y=c
if(c.length>0)r.c=c[0]
r.as=p
q=A.a7(a,r)
a.eC.set(p,q)
return q},
en(a,b,c){var s,r,q,p,o,n
if(b.w===9){s=b.x
r=b.y.concat(c)}else{r=c
s=b}q=s.as+(";<"+A.bn(r)+">")
p=a.eC.get(q)
if(p!=null)return p
o=new A.K(null,null)
o.w=9
o.x=s
o.y=r
o.as=q
n=A.a7(a,o)
a.eC.set(q,n)
return n},
fr(a,b,c){var s,r,q="+"+(b+"("+A.bn(c)+")"),p=a.eC.get(q)
if(p!=null)return p
s=new A.K(null,null)
s.w=10
s.x=b
s.y=c
s.as=q
r=A.a7(a,s)
a.eC.set(q,r)
return r},
fo(a,b,c){var s,r,q,p,o,n=b.as,m=c.a,l=m.length,k=c.b,j=k.length,i=c.c,h=i.length,g="("+A.bn(m)
if(j>0){s=l>0?",":""
g+=s+"["+A.bn(k)+"]"}if(h>0){s=l>0?",":""
g+=s+"{"+A.ij(i)+"}"}r=n+(g+")")
q=a.eC.get(r)
if(q!=null)return q
p=new A.K(null,null)
p.w=11
p.x=b
p.y=c
p.as=r
o=A.a7(a,p)
a.eC.set(r,o)
return o},
eo(a,b,c,d){var s,r=b.as+("<"+A.bn(c)+">"),q=a.eC.get(r)
if(q!=null)return q
s=A.il(a,b,c,r,d)
a.eC.set(r,s)
return s},
il(a,b,c,d,e){var s,r,q,p,o,n,m,l
if(e){s=c.length
r=A.dD(s)
for(q=0,p=0;p<s;++p){o=c[p]
if(o.w===1){r[p]=o;++q}}if(q>0){n=A.aj(a,b,r,0)
m=A.aE(a,c,r,0)
return A.eo(a,n,m,c!==m)}}l=new A.K(null,null)
l.w=12
l.x=b
l.y=c
l.as=d
return A.a7(a,l)},
i9(a,b,c,d){return{u:a,e:b,r:c,s:[],p:0,n:d}},
ig(a){var s,r,q,p,o,n,m,l=a.r,k=a.s
for(s=l.length,r=0;r<s;){q=l.charCodeAt(r)
if(q>=48&&q<=57)r=A.ib(r+1,q,l,k)
else if((((q|32)>>>0)-97&65535)<26||q===95||q===36||q===124)r=A.fm(a,r,l,k,!1)
else if(q===46)r=A.fm(a,r,l,k,!0)
else{++r
switch(q){case 44:break
case 58:k.push(!1)
break
case 33:k.push(!0)
break
case 59:k.push(A.ai(a.u,a.e,k.pop()))
break
case 94:k.push(A.io(a.u,k.pop()))
break
case 35:k.push(A.bp(a.u,5,"#"))
break
case 64:k.push(A.bp(a.u,2,"@"))
break
case 126:k.push(A.bp(a.u,3,"~"))
break
case 60:k.push(a.p)
a.p=k.length
break
case 62:A.id(a,k)
break
case 38:A.ic(a,k)
break
case 63:p=a.u
k.push(A.fq(p,A.ai(p,a.e,k.pop()),a.n))
break
case 47:p=a.u
k.push(A.fp(p,A.ai(p,a.e,k.pop()),a.n))
break
case 40:k.push(-3)
k.push(a.p)
a.p=k.length
break
case 41:A.ia(a,k)
break
case 91:k.push(a.p)
a.p=k.length
break
case 93:o=k.splice(a.p)
A.fn(a.u,a.e,o)
a.p=k.pop()
k.push(o)
k.push(-1)
break
case 123:k.push(a.p)
a.p=k.length
break
case 125:o=k.splice(a.p)
A.ih(a.u,a.e,o)
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
return A.ai(a.u,a.e,m)},
ib(a,b,c,d){var s,r,q=b-48
for(s=c.length;a<s;++a){r=c.charCodeAt(a)
if(!(r>=48&&r<=57))break
q=q*10+(r-48)}d.push(q)
return a},
fm(a,b,c,d,e){var s,r,q,p,o,n,m=b+1
for(s=c.length;m<s;++m){r=c.charCodeAt(m)
if(r===46){if(e)break
e=!0}else{if(!((((r|32)>>>0)-97&65535)<26||r===95||r===36||r===124))q=r>=48&&r<=57
else q=!0
if(!q)break}}p=c.substring(b,m)
if(e){s=a.u
o=a.e
if(o.w===9)o=o.x
n=A.is(s,o.x)[p]
if(n==null)A.ap('No "'+p+'" in "'+A.hV(o)+'"')
d.push(A.bq(s,o,n))}else d.push(p)
return m},
id(a,b){var s,r=a.u,q=A.fl(a,b),p=b.pop()
if(typeof p=="string")b.push(A.bo(r,p,q))
else{s=A.ai(r,a.e,p)
switch(s.w){case 11:b.push(A.eo(r,s,q,a.n))
break
default:b.push(A.en(r,s,q))
break}}},
ia(a,b){var s,r,q,p=a.u,o=b.pop(),n=null,m=null
if(typeof o=="number")switch(o){case-1:n=b.pop()
break
case-2:m=b.pop()
break
default:b.push(o)
break}else b.push(o)
s=A.fl(a,b)
o=b.pop()
switch(o){case-3:o=b.pop()
if(n==null)n=p.sEA
if(m==null)m=p.sEA
r=A.ai(p,a.e,o)
q=new A.cc()
q.a=s
q.b=n
q.c=m
b.push(A.fo(p,r,q))
return
case-4:b.push(A.fr(p,b.pop(),s))
return
default:throw A.a(A.bA("Unexpected state under `()`: "+A.i(o)))}},
ic(a,b){var s=b.pop()
if(0===s){b.push(A.bp(a.u,1,"0&"))
return}if(1===s){b.push(A.bp(a.u,4,"1&"))
return}throw A.a(A.bA("Unexpected extended operation "+A.i(s)))},
fl(a,b){var s=b.splice(a.p)
A.fn(a.u,a.e,s)
a.p=b.pop()
return s},
ai(a,b,c){if(typeof c=="string")return A.bo(a,c,a.sEA)
else if(typeof c=="number"){b.toString
return A.ie(a,b,c)}else return c},
fn(a,b,c){var s,r=c.length
for(s=0;s<r;++s)c[s]=A.ai(a,b,c[s])},
ih(a,b,c){var s,r=c.length
for(s=2;s<r;s+=3)c[s]=A.ai(a,b,c[s])},
ie(a,b,c){var s,r,q=b.w
if(q===9){if(c===0)return b.x
s=b.y
r=s.length
if(c<=r)return s[c-1]
c-=r
b=b.x
q=b.w}else if(c===0)return b
if(q!==8)throw A.a(A.bA("Indexed base must be an interface type"))
s=b.y
if(c<=s.length)return s[c-1]
throw A.a(A.bA("Bad index "+c+" for "+b.h(0)))},
jY(a,b,c){var s,r=b.d
if(r==null)r=b.d=new Map()
s=r.get(c)
if(s==null){s=A.u(a,b,null,c,null)
r.set(c,s)}return s},
u(a,b,c,d,e){var s,r,q,p,o,n,m,l,k,j,i
if(b===d)return!0
if(A.ao(d))return!0
s=b.w
if(s===4)return!0
if(A.ao(b))return!1
if(b.w===1)return!0
r=s===13
if(r)if(A.u(a,c[b.x],c,d,e))return!0
q=d.w
p=t.P
if(b===p||b===t.T){if(q===7)return A.u(a,b,c,d.x,e)
return d===p||d===t.T||q===6}if(d===t.K){if(s===7)return A.u(a,b.x,c,d,e)
return s!==6}if(s===7){if(!A.u(a,b.x,c,d,e))return!1
return A.u(a,A.ej(a,b),c,d,e)}if(s===6)return A.u(a,p,c,d,e)&&A.u(a,b.x,c,d,e)
if(q===7){if(A.u(a,b,c,d.x,e))return!0
return A.u(a,b,c,A.ej(a,d),e)}if(q===6)return A.u(a,b,c,p,e)||A.u(a,b,c,d.x,e)
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
if(!A.u(a,j,c,i,e)||!A.u(a,i,e,j,c))return!1}return A.fJ(a,b.x,c,d.x,e)}if(q===11){if(b===t.g)return!0
if(p)return!1
return A.fJ(a,b,c,d,e)}if(s===8){if(q!==8)return!1
return A.je(a,b,c,d,e)}if(o&&q===10)return A.jj(a,b,c,d,e)
return!1},
fJ(a3,a4,a5,a6,a7){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2
if(!A.u(a3,a4.x,a5,a6.x,a7))return!1
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
if(!A.u(a3,p[h],a7,g,a5))return!1}for(h=0;h<m;++h){g=l[h]
if(!A.u(a3,p[o+h],a7,g,a5))return!1}for(h=0;h<i;++h){g=l[m+h]
if(!A.u(a3,k[h],a7,g,a5))return!1}f=s.c
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
if(!A.u(a3,e[a+2],a7,g,a5))return!1
break}}while(b<d){if(f[b+1])return!1
b+=3}return!0},
je(a,b,c,d,e){var s,r,q,p,o,n=b.x,m=d.x
while(n!==m){s=a.tR[n]
if(s==null)return!1
if(typeof s=="string"){n=s
continue}r=s[m]
if(r==null)return!1
q=r.length
p=q>0?new Array(q):v.typeUniverse.sEA
for(o=0;o<q;++o)p[o]=A.bq(a,b,r[o])
return A.fC(a,p,null,c,d.y,e)}return A.fC(a,b.y,null,c,d.y,e)},
fC(a,b,c,d,e,f){var s,r=b.length
for(s=0;s<r;++s)if(!A.u(a,b[s],d,e[s],f))return!1
return!0},
jj(a,b,c,d,e){var s,r=b.y,q=d.y,p=r.length
if(p!==q.length)return!1
if(b.x!==d.x)return!1
for(s=0;s<p;++s)if(!A.u(a,r[s],c,q[s],e))return!1
return!0},
aJ(a){var s=a.w,r=!0
if(!(a===t.P||a===t.T))if(!A.ao(a))if(s!==6)r=s===7&&A.aJ(a.x)
return r},
ao(a){var s=a.w
return s===2||s===3||s===4||s===5||a===t.X},
fB(a,b){var s,r,q=Object.keys(b),p=q.length
for(s=0;s<p;++s){r=q[s]
a[r]=b[r]}},
dD(a){return a>0?new Array(a):v.typeUniverse.sEA},
K:function K(a,b){var _=this
_.a=a
_.b=b
_.r=_.f=_.d=_.c=null
_.w=0
_.as=_.Q=_.z=_.y=_.x=null},
cc:function cc(){this.c=this.b=this.a=null},
du:function du(a){this.a=a},
cb:function cb(){},
bm:function bm(a){this.a=a},
i5(){var s,r,q
if(self.scheduleImmediate!=null)return A.jF()
if(self.MutationObserver!=null&&self.document!=null){s={}
r=self.document.createElement("div")
q=self.document.createElement("span")
s.a=null
new self.MutationObserver(A.aG(new A.d1(s),1)).observe(r,{childList:true})
return new A.d0(s,r,q)}else if(self.setImmediate!=null)return A.jG()
return A.jH()},
i6(a){self.scheduleImmediate(A.aG(new A.d2(a),0))},
i7(a){self.setImmediate(A.aG(new A.d3(a),0))},
i8(a){A.ii(0,a)},
ii(a,b){var s=new A.ds()
s.bc(a,b)
return s},
eF(a){return new A.c7(new A.w($.q,a.j("w<0>")),a.j("c7<0>"))},
eA(a,b){a.$2(0,null)
b.b=!0
return b.a},
dF(a,b){A.iT(a,b)},
ez(a,b){b.ae(a)},
ey(a,b){b.af(A.aq(a),A.aH(a))},
iT(a,b){var s,r,q=new A.dG(b),p=new A.dH(b)
if(a instanceof A.w)a.aF(q,p,t.z)
else{s=t.z
if(a instanceof A.w)a.an(q,p,s)
else{r=new A.w($.q,t.c)
r.a=8
r.c=a
r.aF(q,p,s)}}},
eK(a){var s=function(b,c){return function(d,e){while(true){try{b(d,e)
break}catch(r){e=r
d=c}}}}(a,1)
return $.q.b0(new A.dQ(s))},
e9(a){var s
if(t.C.b(a)){s=a.gN()
if(s!=null)return s}return B.f},
j9(a,b){if($.q===B.d)return null
return null},
ja(a,b){if($.q!==B.d)A.j9(a,b)
if(b==null)if(t.C.b(a)){b=a.gN()
if(b==null){A.fa(a,B.f)
b=B.f}}else b=B.f
else if(t.C.b(a))A.fa(a,b)
return new A.I(a,b)},
em(a,b,c){var s,r,q,p={},o=p.a=a
while(s=o.a,(s&4)!==0){o=o.c
p.a=o}if(o===b){s=A.hW()
b.a4(new A.I(new A.H(!0,o,null,"Cannot complete a future with itself"),s))
return}r=b.a&1
s=o.a=s|r
if((s&24)===0){q=b.c
b.a=b.a&1|4
b.c=o
o.aC(q)
return}if(!c)if(b.c==null)o=(s&16)===0||r!==0
else o=!1
else o=!0
if(o){q=b.U()
b.S(p.a)
A.aB(b,q)
return}b.a^=2
A.cp(null,null,b.b,new A.d9(p,b))},
aB(a,b){var s,r,q,p,o,n,m,l,k,j,i,h,g={},f=g.a=a
for(;;){s={}
r=f.a
q=(r&16)===0
p=!q
if(b==null){if(p&&(r&1)===0){f=f.c
A.eG(f.a,f.b)}return}s.a=b
o=b.a
for(f=b;o!=null;f=o,o=n){f.a=null
A.aB(g.a,f)
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
if(r){A.eG(m.a,m.b)
return}j=$.q
if(j!==k)$.q=k
else j=null
f=f.c
if((f&15)===8)new A.dd(s,g,p).$0()
else if(q){if((f&1)!==0)new A.dc(s,m).$0()}else if((f&2)!==0)new A.db(g,s).$0()
if(j!=null)$.q=j
f=s.c
if(f instanceof A.w){r=s.a.$ti
r=r.j("Q<2>").b(f)||!r.y[1].b(f)}else r=!1
if(r){i=s.a.b
if((f.a&24)!==0){h=i.c
i.c=null
b=i.V(h)
i.a=f.a&30|i.a&1
i.c=f.c
g.a=f
continue}else A.em(f,i,!0)
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
js(a,b){if(t.Q.b(a))return b.b0(a)
if(t.v.b(a))return a
throw A.a(A.eU(a,"onError",u.c))},
jp(){var s,r
for(s=$.aD;s!=null;s=$.aD){$.bx=null
r=s.b
$.aD=r
if(r==null)$.bw=null
s.a.$0()}},
jz(){$.eE=!0
try{A.jp()}finally{$.bx=null
$.eE=!1
if($.aD!=null)$.eS().$1(A.fW())}},
fR(a){var s=new A.c8(a),r=$.bw
if(r==null){$.aD=$.bw=s
if(!$.eE)$.eS().$1(A.fW())}else $.bw=r.b=s},
jv(a){var s,r,q,p=$.aD
if(p==null){A.fR(a)
$.bx=$.bw
return}s=new A.c8(a)
r=$.bx
if(r==null){s.b=p
$.aD=$.bx=s}else{q=r.b
s.b=q
$.bx=r.b=s
if(q==null)$.bw=s}},
kh(a){A.eL(a,"stream",t.K)
return new A.cl()},
eG(a,b){A.jv(new A.dO(a,b))},
fO(a,b,c,d){var s,r=$.q
if(r===c)return d.$0()
$.q=c
s=r
try{r=d.$0()
return r}finally{$.q=s}},
ju(a,b,c,d,e){var s,r=$.q
if(r===c)return d.$1(e)
$.q=c
s=r
try{r=d.$1(e)
return r}finally{$.q=s}},
jt(a,b,c,d,e,f){var s,r=$.q
if(r===c)return d.$2(e,f)
$.q=c
s=r
try{r=d.$2(e,f)
return r}finally{$.q=s}},
cp(a,b,c,d){if(B.d!==c){d=c.bC(d)
d=d}A.fR(d)},
d1:function d1(a){this.a=a},
d0:function d0(a,b,c){this.a=a
this.b=b
this.c=c},
d2:function d2(a){this.a=a},
d3:function d3(a){this.a=a},
ds:function ds(){},
dt:function dt(a,b){this.a=a
this.b=b},
c7:function c7(a,b){this.a=a
this.b=!1
this.$ti=b},
dG:function dG(a){this.a=a},
dH:function dH(a){this.a=a},
dQ:function dQ(a){this.a=a},
I:function I(a,b){this.a=a
this.b=b},
c9:function c9(){},
bd:function bd(a,b){this.a=a
this.$ti=b},
aA:function aA(a,b,c,d,e){var _=this
_.a=null
_.b=a
_.c=b
_.d=c
_.e=d
_.$ti=e},
w:function w(a,b){var _=this
_.a=0
_.b=a
_.c=null
_.$ti=b},
d6:function d6(a,b){this.a=a
this.b=b},
da:function da(a,b){this.a=a
this.b=b},
d9:function d9(a,b){this.a=a
this.b=b},
d8:function d8(a,b){this.a=a
this.b=b},
d7:function d7(a,b){this.a=a
this.b=b},
dd:function dd(a,b,c){this.a=a
this.b=b
this.c=c},
de:function de(a,b){this.a=a
this.b=b},
df:function df(a){this.a=a},
dc:function dc(a,b){this.a=a
this.b=b},
db:function db(a,b){this.a=a
this.b=b},
c8:function c8(a){this.a=a
this.b=null},
cl:function cl(){},
dE:function dE(){},
dk:function dk(){},
dl:function dl(a,b){this.a=a
this.b=b},
dO:function dO(a,b){this.a=a
this.b=b},
f5(a,b,c){return A.jM(a,new A.af(b.j("@<0>").D(c).j("af<1,2>")))},
ef(a,b){return new A.af(a.j("@<0>").D(b).j("af<1,2>"))},
f2(a){var s,r=A.W(a),q=new J.O(a,a.length,r.j("O<1>"))
if(q.m()){s=q.d
return s==null?r.c.a(s):s}return null},
eg(a){var s,r
if(A.eQ(a))return"{...}"
s=new A.A("")
try{r={}
$.ak.push(a)
s.a+="{"
r.a=!0
a.H(0,new A.cL(r,s))
s.a+="}"}finally{$.ak.pop()}r=s.a
return r.charCodeAt(0)==0?r:r},
e:function e(){},
T:function T(){},
cL:function cL(a,b){this.a=a
this.b=b},
cn:function cn(){},
b0:function b0(){},
ay:function ay(a,b){this.a=a
this.$ti=b},
av:function av(){},
br:function br(){},
jq(a,b){var s,r,q,p=null
try{p=JSON.parse(a)}catch(r){s=A.aq(r)
q=A.y(String(s),null,null)
throw A.a(q)}q=A.dI(p)
return q},
dI(a){var s
if(a==null)return null
if(typeof a!="object")return a
if(!Array.isArray(a))return new A.cd(a,Object.create(null))
for(s=0;s<a.length;++s)a[s]=A.dI(a[s])
return a},
iJ(a,b,c){var s,r,q,p,o=c-b
if(o<=4096)s=$.hl()
else s=new Uint8Array(o)
for(r=J.dS(a),q=0;q<o;++q){p=r.k(a,b+q)
if((p&255)!==p)p=255
s[q]=p}return s},
iI(a,b,c,d){var s=a?$.hk():$.hj()
if(s==null)return null
if(0===c&&d===b.length)return A.fA(s,b)
return A.fA(s,b.subarray(c,d))},
fA(a,b){var s,r
try{s=a.decode(b)
return s}catch(r){}return null},
eV(a,b,c,d,e,f){if(B.b.a1(f,4)!==0)throw A.a(A.y("Invalid base64 padding, padded length must be multiple of four, is "+f,a,c))
if(d+e!==f)throw A.a(A.y("Invalid base64 padding, '=' not at the end",a,b))
if(e>2)throw A.a(A.y("Invalid base64 padding, more than two '=' characters",a,b))},
iK(a){switch(a){case 65:return"Missing extension byte"
case 67:return"Unexpected extension byte"
case 69:return"Invalid UTF-8 byte"
case 71:return"Overlong encoding"
case 73:return"Out of unicode range"
case 75:return"Encoded surrogate"
case 77:return"Unfinished UTF-8 octet sequence"
default:return""}},
cd:function cd(a,b){this.a=a
this.b=b
this.c=null},
ce:function ce(a){this.a=a},
dB:function dB(){},
dA:function dA(){},
cs:function cs(){},
ct:function ct(){},
bD:function bD(){},
bF:function bF(){},
cx:function cx(){},
cA:function cA(){},
cz:function cz(){},
cH:function cH(){},
cI:function cI(a){this.a=a},
cX:function cX(){},
cZ:function cZ(){},
dC:function dC(a){this.b=0
this.c=a},
cY:function cY(a){this.a=a},
dz:function dz(a){this.a=a
this.b=16
this.c=0},
jX(a){var s=A.f8(a,null)
if(s!=null)return s
throw A.a(A.y(a,null,null))},
hB(a,b){a=A.v(a,new Error())
a.stack=b.h(0)
throw a},
f6(a,b,c,d){var s,r=J.hL(a,d)
if(a!==0&&b!=null)for(s=0;s<a;++s)r[s]=b
return r},
hO(a,b,c){var s,r,q=A.l([],c.j("p<0>"))
for(s=a.length,r=0;r<a.length;a.length===s||(0,A.aa)(a),++r)q.push(a[r])
q.$flags=1
return q},
cK(a,b){var s,r=A.l([],b.j("p<0>"))
for(s=J.aK(a);s.m();)r.push(s.gn())
return r},
fe(a,b,c){var s,r
A.eh(b,"start")
if(c!=null){s=c-b
if(s<0)throw A.a(A.E(c,b,null,"end",null))
if(s===0)return""}r=A.hX(a,b,c)
return r},
hX(a,b,c){var s=a.length
if(b>=s)return""
return A.hT(a,b,c==null||c>s?s:c)},
fb(a,b){return new A.cF(a,A.f3(a,!1,b,!1,!1,""))},
fd(a,b,c){var s=J.aK(b)
if(!s.m())return a
if(c.length===0){do a+=A.i(s.gn())
while(s.m())}else{a+=A.i(s.gn())
while(s.m())a=a+c+A.i(s.gn())}return a},
eu(a,b,c,d){var s,r,q,p,o,n="0123456789ABCDEF"
if(c===B.e){s=$.hh()
s=s.b.test(b)}else s=!1
if(s)return b
r=B.z.R(b)
for(s=r.length,q=0,p="";q<s;++q){o=r[q]
if(o<128&&(u.f.charCodeAt(o)&a)!==0)p+=A.a3(o)
else p=d&&o===32?p+"+":p+"%"+n[o>>>4&15]+n[o&15]}return p.charCodeAt(0)==0?p:p},
iA(a){var s,r,q
if(!$.hi())return A.iB(a)
s=new URLSearchParams()
a.H(0,new A.dy(s))
r=s.toString()
q=r.length
if(q>0&&r[q-1]==="=")r=B.a.i(r,0,q-1)
return r.replace(/=&|\*|%7E/g,b=>b==="=&"?"&":b==="*"?"%2A":"~")},
hW(){return A.aH(new Error())},
cy(a){if(typeof a=="number"||A.eD(a)||a==null)return J.a_(a)
if(typeof a=="string")return JSON.stringify(a)
return A.f9(a)},
hC(a,b){A.eL(a,"error",t.K)
A.eL(b,"stackTrace",t.k)
A.hB(a,b)},
bA(a){return new A.bz(a)},
R(a,b){return new A.H(!1,null,b,a)},
eU(a,b,c){return new A.H(!0,a,b,c)},
hU(a,b){return new A.b7(null,null,!0,a,b,"Value not in range")},
E(a,b,c,d,e){return new A.b7(b,c,!0,a,d,"Invalid value")},
b8(a,b,c){if(0>a||a>c)throw A.a(A.E(a,0,c,"start",null))
if(b!=null){if(a>b||b>c)throw A.a(A.E(b,a,c,"end",null))
return b}return c},
eh(a,b){if(a<0)throw A.a(A.E(a,0,null,b,null))
return a},
eb(a,b,c,d){return new A.bG(b,!0,a,d,"Index out of range")},
c4(a){return new A.bc(a)},
fg(a){return new A.c1(a)},
ek(a){return new A.bb(a)},
ad(a){return new A.bE(a)},
y(a,b,c){return new A.P(a,b,c)},
hJ(a,b,c){var s,r
if(A.eQ(a)){if(b==="("&&c===")")return"(...)"
return b+"..."+c}s=A.l([],t.s)
$.ak.push(a)
try{A.jn(a,s)}finally{$.ak.pop()}r=A.fd(b,s,", ")+c
return r.charCodeAt(0)==0?r:r},
ec(a,b,c){var s,r
if(A.eQ(a))return b+"..."+c
s=new A.A(b)
$.ak.push(a)
try{r=s
r.a=A.fd(r.a,a,", ")}finally{$.ak.pop()}s.a+=c
r=s.a
return r.charCodeAt(0)==0?r:r},
jn(a,b){var s,r,q,p,o,n,m,l=a.gA(a),k=0,j=0
for(;;){if(!(k<80||j<3))break
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
hR(a,b,c,d){var s
if(B.h===c){s=B.b.gp(a)
b=J.Z(b)
return A.el(A.a5(A.a5($.e8(),s),b))}if(B.h===d){s=B.b.gp(a)
b=J.Z(b)
c=J.Z(c)
return A.el(A.a5(A.a5(A.a5($.e8(),s),b),c))}s=B.b.gp(a)
b=J.Z(b)
c=J.Z(c)
d=J.Z(d)
d=A.el(A.a5(A.a5(A.a5(A.a5($.e8(),s),b),c),d))
return d},
az(a4,a5,a6){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3=null
a6=a4.length
s=a5+5
if(a6>=s){r=((a4.charCodeAt(a5+4)^58)*3|a4.charCodeAt(a5)^100|a4.charCodeAt(a5+1)^97|a4.charCodeAt(a5+2)^116|a4.charCodeAt(a5+3)^97)>>>0
if(r===0)return A.fh(a5>0||a6<a6?B.a.i(a4,a5,a6):a4,5,a3).gb2()
else if(r===32)return A.fh(B.a.i(a4,s,a6),0,a3).gb2()}q=A.f6(8,0,!1,t.S)
q[0]=0
p=a5-1
q[1]=p
q[2]=p
q[7]=p
q[3]=a5
q[4]=a5
q[5]=a6
q[6]=a6
if(A.fQ(a4,a5,a6,0,q)>=14)q[7]=a6
o=q[1]
if(o>=a5)if(A.fQ(a4,a5,o,20,q)===20)q[7]=o
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
if(s){a4=B.a.M(a4,l,k,"/");++k;++j;++a6}else{a4=B.a.i(a4,a5,l)+"/"+B.a.i(a4,k,a6)
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
if(s){a4=B.a.M(a4,m,l,"")
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
if(s){a4=B.a.M(a4,m,l,"")
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
j-=a5}return new A.ck(a4,o,n,m,l,k,j,h)}if(h==null)if(o>a5)h=A.iC(a4,a5,o)
else{if(o===a5)A.aC(a4,a5,"Invalid empty scheme")
h=""}d=a3
if(n>a5){c=o+3
b=c<n?A.iD(a4,c,n-1):""
a=A.ix(a4,n,m,!1)
s=m+1
if(s<l){a0=A.f8(B.a.i(a4,s,l),a3)
d=A.iz(a0==null?A.ap(A.y("Invalid port",a4,s)):a0,h)}}else{a=a3
b=""}a1=A.iy(a4,l,k,a3,h,a!=null)
a2=k<j?A.er(a4,k+1,j,a3):a3
return A.ep(h,b,a,d,a1,a2,j<a6?A.iw(a4,j+1,a6):a3)},
i4(a){var s,r,q=0,p=null
try{s=A.az(a,q,p)
return s}catch(r){if(A.aq(r) instanceof A.P)return null
else throw r}},
fj(a){var s=t.N
return B.c.bJ(A.l(a.split("&"),t.s),A.ef(s,s),new A.cW(B.e))},
c6(a,b,c){throw A.a(A.y("Illegal IPv4 address, "+a,b,c))},
i1(a,b,c,d,e){var s,r,q,p,o,n,m,l,k="invalid character"
for(s=d.$flags|0,r=b,q=r,p=0,o=0;;){n=q>=c?0:a.charCodeAt(q)
m=n^48
if(m<=9){if(o!==0||q===r){o=o*10+m
if(o<=255){++q
continue}A.c6("each part must be in the range 0..255",a,r)}A.c6("parts must not have leading zeros",a,r)}if(q===r){if(q===c)break
A.c6(k,a,q)}l=p+1
s&2&&A.M(d)
d[e+p]=o
if(n===46){if(l<4){++q
p=l
r=q
o=0
continue}break}if(q===c){if(l===4)return
break}A.c6(k,a,q)
p=l}A.c6("IPv4 address should contain exactly 4 parts",a,q)},
i2(a,b,c){var s
if(b===c)throw A.a(A.y("Empty IP address",a,b))
if(a.charCodeAt(b)===118){s=A.i3(a,b,c)
if(s!=null)throw A.a(s)
return!1}A.fi(a,b,c)
return!0},
i3(a,b,c){var s,r,q,p,o="Missing hex-digit in IPvFuture address";++b
for(s=b;;s=r){if(s<c){r=s+1
q=a.charCodeAt(s)
if((q^48)<=9)continue
p=q|32
if(p>=97&&p<=102)continue
if(q===46){if(r-1===b)return new A.P(o,a,r)
s=r
break}return new A.P("Unexpected character",a,r-1)}if(s-1===b)return new A.P(o,a,s)
return new A.P("Missing '.' in IPvFuture address",a,s)}if(s===c)return new A.P("Missing address in IPvFuture address, host, cursor",null,null)
for(;;){if((u.f.charCodeAt(a.charCodeAt(s))&16)!==0){++s
if(s<c)continue
return null}return new A.P("Invalid IPvFuture address character",a,s)}},
fi(a1,a2,a3){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a="an address must contain at most 8 parts",a0=new A.cV(a1)
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
continue}a0.$2("an IPv6 part can contain a maximum of 4 hex digits",o)}if(p>o){if(l===46){if(m){if(q<=6){A.i1(a1,o,a3,s,q*2)
q+=2
p=a3
break}a0.$2(a,o)}break}g=q*2
s[g]=B.b.ac(n,8)
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
B.n.b7(s,b,16,s,c)
B.n.bH(s,c,b,0)}}return s},
ep(a,b,c,d,e,f,g){return new A.bs(a,b,c,d,e,f,g)},
fu(a){if(a==="http")return 80
if(a==="https")return 443
return 0},
aC(a,b,c){throw A.a(A.y(c,a,b))},
iz(a,b){if(a!=null&&a===A.fu(b))return null
return a},
ix(a,b,c,d){var s,r,q,p,o,n,m,l
if(b===c)return""
if(a.charCodeAt(b)===91){s=c-1
if(a.charCodeAt(s)!==93)A.aC(a,b,"Missing end `]` to match `[` in host")
r=b+1
q=""
if(a.charCodeAt(r)!==118){p=A.iu(a,r,s)
if(p<s){o=p+1
q=A.fz(a,B.a.u(a,"25",o)?p+3:o,s,"%25")}s=p}n=A.i2(a,r,s)
m=B.a.i(a,r,s)
return"["+(n?m.toLowerCase():m)+q+"]"}for(l=b;l<c;++l)if(a.charCodeAt(l)===58){s=B.a.Z(a,"%",b)
s=s>=b&&s<c?s:c
if(s<c){o=s+1
q=A.fz(a,B.a.u(a,"25",o)?s+3:o,c,"%25")}else q=""
A.fi(a,b,s)
return"["+B.a.i(a,b,s)+q+"]"}return A.iF(a,b,c)},
iu(a,b,c){var s=B.a.Z(a,"%",b)
return s>=b&&s<c?s:c},
fz(a,b,c,d){var s,r,q,p,o,n,m,l,k,j,i=d!==""?new A.A(d):null
for(s=b,r=s,q=!0;s<c;){p=a.charCodeAt(s)
if(p===37){o=A.es(a,s,!0)
n=o==null
if(n&&q){s+=3
continue}if(i==null)i=new A.A("")
m=i.a+=B.a.i(a,r,s)
if(n)o=B.a.i(a,s,s+3)
else if(o==="%")A.aC(a,s,"ZoneID should not contain % anymore")
i.a=m+o
s+=3
r=s
q=!0}else if(p<127&&(u.f.charCodeAt(p)&1)!==0){if(q&&65<=p&&90>=p){if(i==null)i=new A.A("")
if(r<s){i.a+=B.a.i(a,r,s)
r=s}q=!1}++s}else{l=1
if((p&64512)===55296&&s+1<c){k=a.charCodeAt(s+1)
if((k&64512)===56320){p=65536+((p&1023)<<10)+(k&1023)
l=2}}j=B.a.i(a,r,s)
if(i==null){i=new A.A("")
n=i}else n=i
n.a+=j
m=A.eq(p)
n.a+=m
s+=l
r=s}}if(i==null)return B.a.i(a,b,c)
if(r<c){j=B.a.i(a,r,c)
i.a+=j}n=i.a
return n.charCodeAt(0)==0?n:n},
iF(a,b,c){var s,r,q,p,o,n,m,l,k,j,i,h=u.f
for(s=b,r=s,q=null,p=!0;s<c;){o=a.charCodeAt(s)
if(o===37){n=A.es(a,s,!0)
m=n==null
if(m&&p){s+=3
continue}if(q==null)q=new A.A("")
l=B.a.i(a,r,s)
if(!p)l=l.toLowerCase()
k=q.a+=l
j=3
if(m)n=B.a.i(a,s,s+3)
else if(n==="%"){n="%25"
j=1}q.a=k+n
s+=j
r=s
p=!0}else if(o<127&&(h.charCodeAt(o)&32)!==0){if(p&&65<=o&&90>=o){if(q==null)q=new A.A("")
if(r<s){q.a+=B.a.i(a,r,s)
r=s}p=!1}++s}else if(o<=93&&(h.charCodeAt(o)&1024)!==0)A.aC(a,s,"Invalid character")
else{j=1
if((o&64512)===55296&&s+1<c){i=a.charCodeAt(s+1)
if((i&64512)===56320){o=65536+((o&1023)<<10)+(i&1023)
j=2}}l=B.a.i(a,r,s)
if(!p)l=l.toLowerCase()
if(q==null){q=new A.A("")
m=q}else m=q
m.a+=l
k=A.eq(o)
m.a+=k
s+=j
r=s}}if(q==null)return B.a.i(a,b,c)
if(r<c){l=B.a.i(a,r,c)
if(!p)l=l.toLowerCase()
q.a+=l}m=q.a
return m.charCodeAt(0)==0?m:m},
iC(a,b,c){var s,r,q
if(b===c)return""
if(!A.fw(a.charCodeAt(b)))A.aC(a,b,"Scheme not starting with alphabetic character")
for(s=b,r=!1;s<c;++s){q=a.charCodeAt(s)
if(!(q<128&&(u.f.charCodeAt(q)&8)!==0))A.aC(a,s,"Illegal scheme character")
if(65<=q&&q<=90)r=!0}a=B.a.i(a,b,c)
return A.it(r?a.toLowerCase():a)},
it(a){if(a==="http")return"http"
if(a==="file")return"file"
if(a==="https")return"https"
if(a==="package")return"package"
return a},
iD(a,b,c){return A.bt(a,b,c,16,!1,!1)},
iy(a,b,c,d,e,f){var s,r=e==="file",q=r||f
if(a==null)return r?"/":""
else s=A.bt(a,b,c,128,!0,!0)
if(s.length===0){if(r)return"/"}else if(q&&!B.a.v(s,"/"))s="/"+s
return A.iE(s,e,f)},
iE(a,b,c){var s=b.length===0
if(s&&!c&&!B.a.v(a,"/")&&!B.a.v(a,"\\"))return A.iG(a,!s||c)
return A.iH(a)},
er(a,b,c,d){if(a!=null){if(d!=null)throw A.a(A.R("Both query and queryParameters specified",null))
return A.bt(a,b,c,256,!0,!1)}if(d==null)return null
return A.iA(d)},
iB(a){var s={},r=new A.A("")
s.a=""
a.H(0,new A.dw(new A.dx(s,r)))
s=r.a
return s.charCodeAt(0)==0?s:s},
iw(a,b,c){return A.bt(a,b,c,256,!0,!1)},
es(a,b,c){var s,r,q,p,o,n=b+2
if(n>=a.length)return"%"
s=a.charCodeAt(b+1)
r=a.charCodeAt(n)
q=A.dV(s)
p=A.dV(r)
if(q<0||p<0)return"%"
o=q*16+p
if(o<127&&(u.f.charCodeAt(o)&1)!==0)return A.a3(c&&65<=o&&90>=o?(o|32)>>>0:o)
if(s>=97||r>=97)return B.a.i(a,b,b+3).toUpperCase()
return null},
eq(a){var s,r,q,p,o,n="0123456789ABCDEF"
if(a<=127){s=new Uint8Array(3)
s[0]=37
s[1]=n.charCodeAt(a>>>4)
s[2]=n.charCodeAt(a&15)}else{if(a>2047)if(a>65535){r=240
q=4}else{r=224
q=3}else{r=192
q=2}s=new Uint8Array(3*q)
for(p=0;--q,q>=0;r=128){o=B.b.bv(a,6*q)&63|r
s[p]=37
s[p+1]=n.charCodeAt(o>>>4)
s[p+2]=n.charCodeAt(o&15)
p+=3}}return A.fe(s,0,null)},
bt(a,b,c,d,e,f){var s=A.fy(a,b,c,d,e,f)
return s==null?B.a.i(a,b,c):s},
fy(a,b,c,d,e,f){var s,r,q,p,o,n,m,l,k,j=null,i=u.f
for(s=!e,r=b,q=r,p=j;r<c;){o=a.charCodeAt(r)
if(o<127&&(i.charCodeAt(o)&d)!==0)++r
else{n=1
if(o===37){m=A.es(a,r,!1)
if(m==null){r+=3
continue}if("%"===m)m="%25"
else n=3}else if(o===92&&f)m="/"
else if(s&&o<=93&&(i.charCodeAt(o)&1024)!==0){A.aC(a,r,"Invalid character")
n=j
m=n}else{if((o&64512)===55296){l=r+1
if(l<c){k=a.charCodeAt(l)
if((k&64512)===56320){o=65536+((o&1023)<<10)+(k&1023)
n=2}}}m=A.eq(o)}if(p==null){p=new A.A("")
l=p}else l=p
l.a=(l.a+=B.a.i(a,q,r))+m
r+=n
q=r}}if(p==null)return j
if(q<c){s=B.a.i(a,q,c)
p.a+=s}s=p.a
return s.charCodeAt(0)==0?s:s},
fx(a){if(B.a.v(a,"."))return!0
return B.a.aU(a,"/.")!==-1},
iH(a){var s,r,q,p,o,n
if(!A.fx(a))return a
s=A.l([],t.s)
for(r=a.split("/"),q=r.length,p=!1,o=0;o<q;++o){n=r[o]
if(n===".."){if(s.length!==0){s.pop()
if(s.length===0)s.push("")}p=!0}else{p="."===n
if(!p)s.push(n)}}if(p)s.push("")
return B.c.aY(s,"/")},
iG(a,b){var s,r,q,p,o,n
if(!A.fx(a))return!b?A.fv(a):a
s=A.l([],t.s)
for(r=a.split("/"),q=r.length,p=!1,o=0;o<q;++o){n=r[o]
if(".."===n){if(s.length!==0&&B.c.gaZ(s)!=="..")s.pop()
else s.push("..")
p=!0}else{p="."===n
if(!p)s.push(n.length===0&&s.length===0?"./":n)}}if(s.length===0)return"./"
if(p)s.push("")
if(!b)s[0]=A.fv(s[0])
return B.c.aY(s,"/")},
fv(a){var s,r,q=a.length
if(q>=2&&A.fw(a.charCodeAt(0)))for(s=1;s<q;++s){r=a.charCodeAt(s)
if(r===58)return B.a.i(a,0,s)+"%3A"+B.a.I(a,s+1)
if(r>127||(u.f.charCodeAt(r)&8)===0)break}return a},
iv(a,b){var s,r,q
for(s=0,r=0;r<2;++r){q=a.charCodeAt(b+r)
if(48<=q&&q<=57)s=s*16+q-48
else{q|=32
if(97<=q&&q<=102)s=s*16+q-87
else throw A.a(A.R("Invalid URL encoding",null))}}return s},
et(a,b,c,d,e){var s,r,q,p,o=b
for(;;){if(!(o<c)){s=!0
break}r=a.charCodeAt(o)
q=!0
if(r<=127)if(r!==37)q=r===43
if(q){s=!1
break}++o}if(s)if(B.e===d)return B.a.i(a,b,c)
else p=new A.bC(B.a.i(a,b,c))
else{p=A.l([],t.t)
for(q=a.length,o=b;o<c;++o){r=a.charCodeAt(o)
if(r>127)throw A.a(A.R("Illegal percent encoding in URI",null))
if(r===37){if(o+3>q)throw A.a(A.R("Truncated URI",null))
p.push(A.iv(a,o+1))
o+=2}else if(r===43)p.push(32)
else p.push(r)}}return B.ag.R(p)},
fw(a){var s=a|32
return 97<=s&&s<=122},
fh(a,b,c){var s,r,q,p,o,n,m,l,k="Invalid MIME type",j=A.l([b-1],t.t)
for(s=a.length,r=b,q=-1,p=null;r<s;++r){p=a.charCodeAt(r)
if(p===44||p===59)break
if(p===47){if(q<0){q=r
continue}throw A.a(A.y(k,a,r))}}if(q<0&&r>b)throw A.a(A.y(k,a,r))
while(p!==44){j.push(r);++r
for(o=-1;r<s;++r){p=a.charCodeAt(r)
if(p===61){if(o<0)o=r}else if(p===59||p===44)break}if(o>=0)j.push(o)
else{n=B.c.gaZ(j)
if(p!==44||r!==n+7||!B.a.u(a,"base64",n+1))throw A.a(A.y("Expecting '='",a,r))
break}}j.push(r)
m=r+1
if((j.length&1)===1)a=B.p.bO(a,m,s)
else{l=A.fy(a,m,s,256,!0,!1)
if(l!=null)a=B.a.M(a,m,s,l)}return new A.cU(a,j,c)},
fQ(a,b,c,d,e){var s,r,q
for(s=b;s<c;++s){r=a.charCodeAt(s)^96
if(r>95)r=31
q='\xe1\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\xe1\xe1\xe1\x01\xe1\xe1\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\xe1\xe3\xe1\xe1\x01\xe1\x01\xe1\xcd\x01\xe1\x01\x01\x01\x01\x01\x01\x01\x01\x0e\x03\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01"\x01\xe1\x01\xe1\xac\xe1\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\xe1\xe1\xe1\x01\xe1\xe1\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\xe1\xea\xe1\xe1\x01\xe1\x01\xe1\xcd\x01\xe1\x01\x01\x01\x01\x01\x01\x01\x01\x01\n\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01"\x01\xe1\x01\xe1\xac\xeb\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\xeb\xeb\xeb\x8b\xeb\xeb\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\xeb\x83\xeb\xeb\x8b\xeb\x8b\xeb\xcd\x8b\xeb\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x92\x83\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\x8b\xeb\x8b\xeb\x8b\xeb\xac\xeb\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\xeb\xeb\xeb\v\xeb\xeb\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\xebD\xeb\xeb\v\xeb\v\xeb\xcd\v\xeb\v\v\v\v\v\v\v\v\x12D\v\v\v\v\v\v\v\v\v\v\xeb\v\xeb\v\xeb\xac\xe5\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\xe5\xe5\xe5\x05\xe5D\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe8\x8a\xe5\xe5\x05\xe5\x05\xe5\xcd\x05\xe5\x05\x05\x05\x05\x05\x05\x05\x05\x05\x8a\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05f\x05\xe5\x05\xe5\xac\xe5\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\xe5\xe5\xe5\x05\xe5D\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\xe5\x8a\xe5\xe5\x05\xe5\x05\xe5\xcd\x05\xe5\x05\x05\x05\x05\x05\x05\x05\x05\x05\x8a\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05f\x05\xe5\x05\xe5\xac\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7D\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\x8a\xe7\xe7\xe7\xe7\xe7\xe7\xcd\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\x8a\xe7\x07\x07\x07\x07\x07\x07\x07\x07\x07\xe7\xe7\xe7\xe7\xe7\xac\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7D\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\x8a\xe7\xe7\xe7\xe7\xe7\xe7\xcd\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\xe7\x8a\x07\x07\x07\x07\x07\x07\x07\x07\x07\x07\xe7\xe7\xe7\xe7\xe7\xac\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\x05\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\xeb\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\xeb\xeb\xeb\v\xeb\xeb\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\xeb\xea\xeb\xeb\v\xeb\v\xeb\xcd\v\xeb\v\v\v\v\v\v\v\v\x10\xea\v\v\v\v\v\v\v\v\v\v\xeb\v\xeb\v\xeb\xac\xeb\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\xeb\xeb\xeb\v\xeb\xeb\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\xeb\xea\xeb\xeb\v\xeb\v\xeb\xcd\v\xeb\v\v\v\v\v\v\v\v\x12\n\v\v\v\v\v\v\v\v\v\v\xeb\v\xeb\v\xeb\xac\xeb\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\xeb\xeb\xeb\v\xeb\xeb\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\xeb\xea\xeb\xeb\v\xeb\v\xeb\xcd\v\xeb\v\v\v\v\v\v\v\v\v\n\v\v\v\v\v\v\v\v\v\v\xeb\v\xeb\v\xeb\xac\xec\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\xec\xec\xec\f\xec\xec\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\f\xec\xec\xec\xec\f\xec\f\xec\xcd\f\xec\f\f\f\f\f\f\f\f\f\xec\f\f\f\f\f\f\f\f\f\f\xec\f\xec\f\xec\f\xed\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\xed\xed\xed\r\xed\xed\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\xed\xed\xed\xed\r\xed\r\xed\xed\r\xed\r\r\r\r\r\r\r\r\r\xed\r\r\r\r\r\r\r\r\r\r\xed\r\xed\r\xed\r\xe1\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\xe1\xe1\xe1\x01\xe1\xe1\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\xe1\xea\xe1\xe1\x01\xe1\x01\xe1\xcd\x01\xe1\x01\x01\x01\x01\x01\x01\x01\x01\x0f\xea\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01"\x01\xe1\x01\xe1\xac\xe1\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\xe1\xe1\xe1\x01\xe1\xe1\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\xe1\xe9\xe1\xe1\x01\xe1\x01\xe1\xcd\x01\xe1\x01\x01\x01\x01\x01\x01\x01\x01\x01\t\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01"\x01\xe1\x01\xe1\xac\xeb\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\xeb\xeb\xeb\v\xeb\xeb\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\xeb\xea\xeb\xeb\v\xeb\v\xeb\xcd\v\xeb\v\v\v\v\v\v\v\v\x11\xea\v\v\v\v\v\v\v\v\v\v\xeb\v\xeb\v\xeb\xac\xeb\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\xeb\xeb\xeb\v\xeb\xeb\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\xeb\xe9\xeb\xeb\v\xeb\v\xeb\xcd\v\xeb\v\v\v\v\v\v\v\v\v\t\v\v\v\v\v\v\v\v\v\v\xeb\v\xeb\v\xeb\xac\xeb\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\xeb\xeb\xeb\v\xeb\xeb\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\xeb\xea\xeb\xeb\v\xeb\v\xeb\xcd\v\xeb\v\v\v\v\v\v\v\v\x13\xea\v\v\v\v\v\v\v\v\v\v\xeb\v\xeb\v\xeb\xac\xeb\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\xeb\xeb\xeb\v\xeb\xeb\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\v\xeb\xea\xeb\xeb\v\xeb\v\xeb\xcd\v\xeb\v\v\v\v\v\v\v\v\v\xea\v\v\v\v\v\v\v\v\v\v\xeb\v\xeb\v\xeb\xac\xf5\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\xf5\x15\xf5\x15\x15\xf5\x15\x15\x15\x15\x15\x15\x15\x15\x15\x15\xf5\xf5\xf5\xf5\xf5\xf5'.charCodeAt(d*96+r)
d=q&31
e[q>>>5]=s}return d},
dy:function dy(a){this.a=a},
d4:function d4(){},
m:function m(){},
bz:function bz(a){this.a=a},
U:function U(){},
H:function H(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
b7:function b7(a,b,c,d,e,f){var _=this
_.e=a
_.f=b
_.a=c
_.b=d
_.c=e
_.d=f},
bG:function bG(a,b,c,d,e){var _=this
_.f=a
_.a=b
_.b=c
_.c=d
_.d=e},
bc:function bc(a){this.a=a},
c1:function c1(a){this.a=a},
bb:function bb(a){this.a=a},
bE:function bE(a){this.a=a},
bX:function bX(){},
ba:function ba(){},
d5:function d5(a){this.a=a},
P:function P(a,b,c){this.a=a
this.b=b
this.c=c},
o:function o(){},
t:function t(){},
k:function k(){},
cm:function cm(){},
A:function A(a){this.a=a},
cW:function cW(a){this.a=a},
cV:function cV(a){this.a=a},
bs:function bs(a,b,c,d,e,f,g){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f
_.r=g
_.z=_.y=_.w=$},
dx:function dx(a,b){this.a=a
this.b=b},
dw:function dw(a){this.a=a},
cU:function cU(a,b,c){this.a=a
this.b=b
this.c=c},
ck:function ck(a,b,c,d,e,f,g,h){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f
_.r=g
_.w=h
_.x=null},
ca:function ca(a,b,c,d,e,f,g){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f
_.r=g
_.z=_.y=_.w=$},
hK(a,b){var s,r,q,p,o
if(b.length===0)return!1
s=b.split(".")
r=v.G
for(q=s.length,p=0;p<q;++p,r=o){o=r[s[p]]
A.fE(o)
if(o==null)return!1}return a instanceof t.g.a(r)},
cN:function cN(a){this.a=a},
L(a){var s
if(typeof a=="function")throw A.a(A.R("Attempting to rewrap a JS function.",null))
s=function(b,c){return function(d){return b(c,d,arguments.length)}}(A.iV,a)
s[$.e7()]=a
return s},
iU(a){return a.$0()},
iV(a,b,c){if(c>=1)return a.$1(b)
return a.$0()},
e4(a,b){var s=new A.w($.q,b.j("w<0>")),r=new A.bd(s,b.j("bd<0>"))
a.then(A.aG(new A.e5(r),1),A.aG(new A.e6(r),1))
return s},
e5:function e5(a){this.a=a},
e6:function e6(a){this.a=a},
n:function n(a,b){this.a=a
this.b=b},
hF(a){var s,r,q,p,o,n,m,l,k="enclosedBy"
if(a.k(0,k)!=null){s=t.a.a(a.k(0,k))
r=new A.cw(A.ex(s.k(0,"name")),B.m[A.ev(s.k(0,"kind"))],A.ex(s.k(0,"href")))}else r=null
q=a.k(0,"name")
p=a.k(0,"qualifiedName")
o=A.ew(a.k(0,"packageRank"))
if(o==null)o=0
n=a.k(0,"href")
m=B.m[A.ev(a.k(0,"kind"))]
l=A.ew(a.k(0,"overriddenDepth"))
if(l==null)l=0
return new A.x(q,p,o,m,n,l,a.k(0,"desc"),r)},
B:function B(a,b){this.a=a
this.b=b},
cB:function cB(a){this.a=a},
cE:function cE(a,b){this.a=a
this.b=b},
cC:function cC(){},
cD:function cD(){},
x:function x(a,b,c,d,e,f,g,h){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f
_.r=g
_.w=h},
cw:function cw(a,b,c){this.a=a
this.b=b
this.c=c},
jS(){var s,r,q,p,o,n=v.G,m=n.document.querySelectorAll("pre:has(> code)")
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
p.addEventListener("click",A.L(new A.e_(r,q,o,p)))
q.insertBefore(p,q.firstChild)}},
e_:function e_(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
dZ:function dZ(a,b,c){this.a=a
this.b=b
this.c=c},
bv(){var s,r=v.G.document.body
if(r==null)return""
if(J.C(r.getAttribute("data-using-base-href"),"false")){s=r.getAttribute("data-base-href")
return s==null?"":s}return""},
jQ(){var s,r,q,p,o,n,m,l,k,j=$.eH
if(j!=null){v.G.document.removeEventListener("keydown",j)
$.eH=null}s=v.G
r=s.document.getElementById("search-box")
q=s.document.getElementById("search-body")
p=s.document.getElementById("search-sidebar")
o=t.o
n=t.l
m=n.j("o.E")
l=A.cK(new A.au(A.l([r,q,p],o),n),m)
k=A.cK(new A.au(A.l([r,p,q],o),n),m)
if(l.length===0&&!A.fS(A.az(J.a_(s.window.location),0,null),l))return
new A.cg(l,k,A.k4(),A.k5()).bB()},
iY(a){v.G.window.location.assign(a)},
co(){var s=0,r=A.eF(t.u),q,p=2,o=[],n,m,l,k
var $async$co=A.eK(function(a,b){if(a===1){o.push(b)
s=p}for(;;)switch(s){case 0:p=4
s=7
return A.dF(A.e4(v.G.window.fetch(A.bv()+"index.json"),t.m),$async$co)
case 7:n=b
if(!J.C(n.status,200)){q=null
s=1
break}s=8
return A.dF(A.e4(n.text(),t.N),$async$co)
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
case 6:case 1:return A.ez(q,r)
case 2:return A.ey(o.at(-1),r)}})
return A.eA($async$co,r)},
fS(a,b){if(a.gL().B("search"))return!0
if(B.a.aK(a.ga_(),"search.html")&&a.gL().B("q"))return!0
return B.c.bA(b,new A.dP())},
jw(a){var s,r,q
for(s=a.length,r=0;r<s;++r){q=a[r]
if(q.offsetParent!=null)return q}return A.f2(a)},
fG(a){var s,r,q,p,o,n,m=a.parentElement
if(t.m.b(m)){s=m.classList
s=s.contains("tt-wrapper")
r=m}else{r=null
s=!1}if(s)return r
q=J.C(v.G.document.activeElement,a)
p=a.selectionStart
o=a.selectionEnd
n=A.a0()
n.classList.add("tt-wrapper")
a.replaceWith(n)
n.appendChild(a)
if(q){a.focus()
if(p!=null&&o!=null)a.setSelectionRange(p,o)}return n},
iX(a,b,c){var s,r,q,p,o,n,m,l,k,j=A.a0(),i=b.e
if(i==null)i=""
j.setAttribute("data-href",i)
j.classList.add("tt-suggestion")
s=A.f0()
s.classList.add("tt-suggestion-title")
s.innerHTML=A.eB(b.a+" "+b.d.h(0).toLowerCase(),a)
j.appendChild(s)
r=b.w
i=r!=null
if(i){q=A.f0()
q.classList.add("tt-suggestion-container")
q.innerHTML="(in "+A.eB(r.a,a)+")"
j.appendChild(q)}p=b.r
if(p!=null&&p.length!==0){q=v.G
o=q.document.createElement("blockquote")
o.classList.add("one-line-description")
n=q.document.createElement("textarea")
n.innerHTML=p
o.setAttribute("title",n.value)
o.innerHTML=A.eB(p,a)
j.appendChild(o)}j.addEventListener("mousedown",A.L(new A.dJ()))
j.addEventListener("click",A.L(new A.dK(b,c)))
if(i){i=r.a
q=r.b.h(0)
m=r.c
l=A.a0()
l.classList.add("tt-container")
o=v.G.document.createElement("p")
o.textContent="Results from "
o.classList.add("tt-container-text")
k=A.ea()
k.setAttribute("href",m)
k.innerHTML=i+" "+q
o.appendChild(k)
l.appendChild(o)
A.jo(l,j)}return j},
jo(a,b){var s,r=a.innerHTML
if(r.length===0)return
s=$.a8.k(0,r)
if(s!=null)s.appendChild(b)
else{a.appendChild(b)
$.a8.q(0,r,a)}},
eB(a,b){return A.k7(a,A.fb(b,!1),new A.dL(),null)},
dP:function dP(){},
cg:function cg(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.f=_.e=null
_.r=!1},
di:function di(a){this.a=a},
dh:function dh(a,b){this.a=a
this.b=b},
dm:function dm(a,b,c,d,e){var _=this
_.a=a
_.b=b
_.c=c
_.f=_.e=_.d=$
_.r=null
_.w=""
_.x=d
_.y=e
_.z=-1},
dn:function dn(a,b){this.a=a
this.b=b},
dp:function dp(a,b){this.a=a
this.b=b},
dq:function dq(a,b){this.a=a
this.b=b},
dr:function dr(a,b){this.a=a
this.b=b},
dJ:function dJ(){},
dK:function dK(a,b){this.a=a
this.b=b},
dL:function dL(){},
j5(){var s=v.G,r=s.document.getElementById("sidenav-left-toggle"),q=s.document.querySelector(".sidebar-offcanvas-left"),p=s.document.getElementById("overlay-under-drawer"),o=A.L(new A.dM(q,p))
if(p!=null)p.addEventListener("click",o)
if(r!=null)r.addEventListener("click",o)},
j4(){var s,r,q,p,o=v.G,n=o.document.body
if(n==null)return
s=n.getAttribute("data-using-base-href")
if(s==null)return
if(s!=="true"){r=n.getAttribute("data-base-href")
if(r==null)return
q=r}else q=""
p=o.document.getElementById("dartdoc-main-content")
if(p==null)return
A.fN(q,p.getAttribute("data-above-sidebar"),o.document.getElementById("dartdoc-sidebar-left-content"))
A.fN(q,p.getAttribute("data-below-sidebar"),o.document.getElementById("dartdoc-sidebar-right"))},
fN(a,b,c){if(b==null||b.length===0||c==null)return
A.e4(v.G.window.fetch(a+b),t.m).bW(new A.dN(c,a),t.P)},
fU(a,b){var s,r,q,p,o,n=A.hK(b,"HTMLAnchorElement")
if(n){n=b.attributes.getNamedItem("href")
s=n==null?null:n.value
if(s==null)return
r=A.i4(s)
if(r!=null&&!r.gaX())b.href=a+s}q=b.childNodes
for(p=0;p<q.length;++p){o=q.item(p)
if(o!=null)A.fU(a,o)}},
dM:function dM(a,b){this.a=a
this.b=b},
dN:function dN(a,b){this.a=a
this.b=b},
jR(){var s,r,q,p=v.G,o=p.document.body
if(o==null)return
s=p.document.getElementById("theme-button")
if(s==null)s=A.fD(s)
r=new A.e1(o)
s.addEventListener("click",A.L(new A.e0(o,r)))
q=p.window.localStorage.getItem("colorTheme")
if(q!=null)r.$1(q==="true")},
e1:function e1(a){this.a=a},
e0:function e0(a,b){this.a=a
this.b=b},
h3(a){return v.mangledGlobalNames[a]},
k1(a){if(typeof dartPrint=="function"){dartPrint(a)
return}if(typeof console=="object"&&typeof console.log!="undefined"){console.log(a)
return}if(typeof print=="function"){print(a)
return}throw"Unable to print message: "+String(a)},
k8(a){throw A.v(A.f4(a),new Error())},
cr(){throw A.v(A.f4(""),new Error())},
a0(){return v.G.document.createElement("div")},
ea(){return v.G.document.createElement("a")},
f0(){return v.G.document.createElement("span")},
k_(){A.j4()
A.j5()
A.jQ()
var s=v.G.hljs
if(s!=null)s.highlightAll()
A.jR()
A.jS()}},B={}
var w=[A,J,B]
var $={}
A.ed.prototype={}
J.bH.prototype={
F(a,b){return a===b},
gp(a){return A.bZ(a)},
h(a){return"Instance of '"+A.c_(a)+"'"},
gt(a){return A.am(A.eC(this))}}
J.bJ.prototype={
h(a){return String(a)},
gp(a){return a?519018:218159},
gt(a){return A.am(t.y)},
$ij:1,
$ial:1}
J.aU.prototype={
F(a,b){return null==b},
h(a){return"null"},
gp(a){return 0},
$ij:1,
$it:1}
J.aX.prototype={$ih:1}
J.a2.prototype={
gp(a){return 0},
h(a){return String(a)}}
J.bY.prototype={}
J.aw.prototype={}
J.a1.prototype={
h(a){var s=a[$.h5()]
if(s==null)s=a[$.e7()]
if(s==null)return this.bb(a)
return"JavaScript function for "+J.a_(s)}}
J.aW.prototype={
gp(a){return 0},
h(a){return String(a)}}
J.aY.prototype={
gp(a){return 0},
h(a){return String(a)}}
J.p.prototype={
X(a,b){return new A.S(a,A.W(a).j("@<1>").D(b).j("S<1,2>"))},
Y(a){a.$flags&1&&A.M(a,"clear","clear")
a.length=0},
aY(a,b){var s,r=A.f6(a.length,"",!1,t.N)
for(s=0;s<a.length;++s)r[s]=A.i(a[s])
return r.join(b)},
bI(a,b,c){var s,r,q=a.length
for(s=b,r=0;r<q;++r){s=c.$2(s,a[r])
if(a.length!==q)throw A.a(A.ad(a))}return s},
bJ(a,b,c){return this.bI(a,b,c,t.z)},
E(a,b){return a[b]},
ba(a,b,c){var s=a.length
if(b>s)throw A.a(A.E(b,0,s,"start",null))
if(c<b||c>s)throw A.a(A.E(c,b,s,"end",null))
if(b===c)return A.l([],A.W(a))
return A.l(a.slice(b,c),A.W(a))},
gaZ(a){var s=a.length
if(s>0)return a[s-1]
throw A.a(A.f1())},
bA(a,b){var s,r=a.length
for(s=0;s<r;++s){if(b.$1(a[s]))return!0
if(a.length!==r)throw A.a(A.ad(a))}return!1},
b9(a,b){var s,r,q,p,o
a.$flags&2&&A.M(a,"sort")
s=a.length
if(s<2)return
if(b==null)b=J.jb()
if(s===2){r=a[0]
q=a[1]
if(b.$2(r,q)>0){a[0]=q
a[1]=r}return}p=0
if(A.W(a).c.b(null))for(o=0;o<a.length;++o)if(a[o]===void 0){a[o]=null;++p}a.sort(A.aG(b,2))
if(p>0)this.bt(a,p)},
bt(a,b){var s,r=a.length
for(;s=r-1,r>0;r=s)if(a[s]===null){a[s]=void 0;--b
if(b===0)break}},
h(a){return A.ec(a,"[","]")},
gA(a){return new J.O(a,a.length,A.W(a).j("O<1>"))},
gp(a){return A.bZ(a)},
gl(a){return a.length},
k(a,b){if(!(b>=0&&b<a.length))throw A.a(A.eN(a,b))
return a[b]},
q(a,b,c){a.$flags&2&&A.M(a)
if(!(b>=0&&b<a.length))throw A.a(A.eN(a,b))
a[b]=c},
$ic:1,
$if:1}
J.bI.prototype={
bX(a){var s,r,q
if(!Array.isArray(a))return null
s=a.$flags|0
if((s&4)!==0)r="const, "
else if((s&2)!==0)r="unmodifiable, "
else r=(s&1)!==0?"fixed, ":""
q="Instance of '"+A.c_(a)+"'"
if(r==="")return q
return q+" ("+r+"length: "+a.length+")"}}
J.cG.prototype={}
J.O.prototype={
gn(){var s=this.d
return s==null?this.$ti.c.a(s):s},
m(){var s,r=this,q=r.a,p=q.length
if(r.b!==p)throw A.a(A.aa(q))
s=r.c
if(s>=p){r.d=null
return!1}r.d=q[s]
r.c=s+1
return!0}}
J.aV.prototype={
aI(a,b){var s
if(a<b)return-1
else if(a>b)return 1
else if(a===b){if(a===0){s=this.gaj(b)
if(this.gaj(a)===s)return 0
if(this.gaj(a))return-1
return 1}return 0}else if(isNaN(a)){if(isNaN(b))return 0
return 1}else return-1},
gaj(a){return a===0?1/a<0:a<0},
h(a){if(a===0&&1/a<0)return"-0.0"
else return""+a},
gp(a){var s,r,q,p,o=a|0
if(a===o)return o&536870911
s=Math.abs(a)
r=Math.log(s)/0.6931471805599453|0
q=Math.pow(2,r)
p=s<1?s/q:q/s
return((p*9007199254740992|0)+(p*3542243181176521|0))*599197+r*1259&536870911},
a1(a,b){var s=a%b
if(s===0)return 0
if(s>0)return s
return s+b},
bw(a,b){return(a|0)===a?a/b|0:this.bx(a,b)},
bx(a,b){var s=a/b
if(s>=-2147483648&&s<=2147483647)return s|0
if(s>0){if(s!==1/0)return Math.floor(s)}else if(s>-1/0)return Math.ceil(s)
throw A.a(A.c4("Result of truncating division is "+A.i(s)+": "+A.i(a)+" ~/ "+b))},
ac(a,b){var s
if(a>0)s=this.aE(a,b)
else{s=b>31?31:b
s=a>>s>>>0}return s},
bv(a,b){if(0>b)throw A.a(A.jE(b))
return this.aE(a,b)},
aE(a,b){return b>31?0:a>>>b},
gt(a){return A.am(t.H)},
$ir:1}
J.aT.prototype={
gt(a){return A.am(t.S)},
$ij:1,
$ib:1}
J.bK.prototype={
gt(a){return A.am(t.i)},
$ij:1}
J.ae.prototype={
aK(a,b){var s=b.length,r=a.length
if(s>r)return!1
return b===this.I(a,r-s)},
M(a,b,c,d){var s=A.b8(b,c,a.length)
return a.substring(0,b)+d+a.substring(s)},
u(a,b,c){var s
if(c<0||c>a.length)throw A.a(A.E(c,0,a.length,null,null))
s=c+b.length
if(s>a.length)return!1
return b===a.substring(c,s)},
v(a,b){return this.u(a,b,0)},
i(a,b,c){return a.substring(b,A.b8(b,c,a.length))},
I(a,b){return this.i(a,b,null)},
b5(a,b){var s,r
if(0>=b)return""
if(b===1||a.length===0)return a
if(b!==b>>>0)throw A.a(B.y)
for(s=a,r="";;){if((b&1)===1)r=s+r
b=b>>>1
if(b===0)break
s+=s}return r},
Z(a,b,c){var s
if(c<0||c>a.length)throw A.a(A.E(c,0,a.length,null,null))
s=a.indexOf(b,c)
return s},
aU(a,b){return this.Z(a,b,0)},
G(a,b){return A.k6(a,b,0)},
aI(a,b){var s
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
gt(a){return A.am(t.N)},
gl(a){return a.length},
$ij:1,
$id:1}
A.a6.prototype={
gA(a){return new A.bB(J.aK(this.gP()),A.Y(this).j("bB<1,2>"))},
gl(a){return J.aL(this.gP())},
E(a,b){return A.Y(this).y[1].a(J.eT(this.gP(),b))},
h(a){return J.a_(this.gP())}}
A.bB.prototype={
m(){return this.a.m()},
gn(){return this.$ti.y[1].a(this.a.gn())}}
A.ab.prototype={
gP(){return this.a}}
A.bf.prototype={$ic:1}
A.be.prototype={
k(a,b){return this.$ti.y[1].a(J.hn(this.a,b))},
q(a,b,c){J.ho(this.a,b,this.$ti.c.a(c))},
$ic:1,
$if:1}
A.S.prototype={
X(a,b){return new A.S(this.a,this.$ti.j("@<1>").D(b).j("S<1,2>"))},
gP(){return this.a}}
A.bM.prototype={
h(a){return"LateInitializationError: "+this.a}}
A.bC.prototype={
gl(a){return this.a.length},
k(a,b){return this.a.charCodeAt(b)}}
A.cP.prototype={}
A.c.prototype={}
A.J.prototype={
gA(a){var s=this
return new A.ar(s,s.gl(s),A.Y(s).j("ar<J.E>"))}}
A.ar.prototype={
gn(){var s=this.d
return s==null?this.$ti.c.a(s):s},
m(){var s,r=this,q=r.a,p=J.dS(q),o=p.gl(q)
if(r.b!==o)throw A.a(A.ad(q))
s=r.c
if(s>=o){r.d=null
return!1}r.d=p.E(q,s);++r.c
return!0}}
A.ah.prototype={
gl(a){return J.aL(this.a)},
E(a,b){return this.b.$1(J.eT(this.a,b))}}
A.au.prototype={
gA(a){var s=this.a
return new A.bW(new J.O(s,3,A.W(s).j("O<1>")))}}
A.bW.prototype={
m(){var s,r,q
this.b=null
for(s=this.a,r=s.$ti.c;s.m();){q=s.d
if(q==null)q=r.a(q)
if(q!=null){this.b=q
return!0}}return!1},
gn(){var s=this.b
return s==null?A.ap(A.f1()):s}}
A.aS.prototype={}
A.c3.prototype={
q(a,b,c){throw A.a(A.c4("Cannot modify an unmodifiable list"))}}
A.ax.prototype={}
A.bu.prototype={}
A.cj.prototype={$r:"+item,matchPosition(1,2)",$s:1}
A.aN.prototype={
h(a){return A.eg(this)},
q(a,b,c){A.hA()},
$iz:1}
A.aP.prototype={
gl(a){return this.b.length},
gbp(){var s=this.$keys
if(s==null){s=Object.keys(this.a)
this.$keys=s}return s},
B(a){if("__proto__"===a)return!1
return this.a.hasOwnProperty(a)},
k(a,b){if(!this.B(b))return null
return this.b[this.a[b]]},
H(a,b){var s,r,q=this.gbp(),p=this.b
for(s=q.length,r=0;r<s;++r)b.$2(q[r],p[r])}}
A.cf.prototype={
gn(){var s=this.d
return s==null?this.$ti.c.a(s):s},
m(){var s=this,r=s.c
if(r>=s.b){s.d=null
return!1}s.d=s.a[r]
s.c=r+1
return!0}}
A.aO.prototype={}
A.aQ.prototype={
gl(a){return this.b},
gA(a){var s,r=this,q=r.$keys
if(q==null){q=Object.keys(r.a)
r.$keys=q}s=q
return new A.cf(s,s.length,r.$ti.j("cf<1>"))},
G(a,b){if("__proto__"===b)return!1
return this.a.hasOwnProperty(b)}}
A.b9.prototype={}
A.cS.prototype={
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
A.b6.prototype={
h(a){return"Null check operator used on a null value"}}
A.bL.prototype={
h(a){var s,r=this,q="NoSuchMethodError: method not found: '",p=r.b
if(p==null)return"NoSuchMethodError: "+r.a
s=r.c
if(s==null)return q+p+"' ("+r.a+")"
return q+p+"' on '"+s+"' ("+r.a+")"}}
A.c2.prototype={
h(a){var s=this.a
return s.length===0?"Error":"Error: "+s}}
A.cO.prototype={
h(a){return"Throw of null ('"+(this.a===null?"null":"undefined")+"' from JavaScript)"}}
A.aR.prototype={}
A.bl.prototype={
h(a){var s,r=this.b
if(r!=null)return r
r=this.a
s=r!==null&&typeof r==="object"?r.stack:null
return this.b=s==null?"":s},
$ia4:1}
A.ac.prototype={
h(a){var s=this.constructor,r=s==null?null:s.name
return"Closure '"+A.h4(r==null?"unknown":r)+"'"},
gbZ(){return this},
$C:"$1",
$R:1,
$D:null}
A.cu.prototype={$C:"$0",$R:0}
A.cv.prototype={$C:"$2",$R:2}
A.cR.prototype={}
A.cQ.prototype={
h(a){var s=this.$static_name
if(s==null)return"Closure of unknown static method"
return"Closure '"+A.h4(s)+"'"}}
A.aM.prototype={
F(a,b){if(b==null)return!1
if(this===b)return!0
if(!(b instanceof A.aM))return!1
return this.$_target===b.$_target&&this.a===b.a},
gp(a){return(A.h0(this.a)^A.bZ(this.$_target))>>>0},
h(a){return"Closure '"+this.$_name+"' of "+("Instance of '"+A.c_(this.a)+"'")}}
A.c0.prototype={
h(a){return"RuntimeError: "+this.a}}
A.af.prototype={
gl(a){return this.a},
gJ(){return new A.ag(this,A.Y(this).j("ag<1>"))},
B(a){var s=this.b
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
return q}else return this.bM(b)},
bM(a){var s,r,q=this.d
if(q==null)return null
s=this.bl(q,a)
r=this.aW(s,a)
if(r<0)return null
return s[r].b},
q(a,b,c){var s,r,q,p,o,n,m=this
if(typeof b=="string"){s=m.b
m.ap(s==null?m.b=m.aa():s,b,c)}else if(typeof b=="number"&&(b&0x3fffffff)===b){r=m.c
m.ap(r==null?m.c=m.aa():r,b,c)}else{q=m.d
if(q==null)q=m.d=m.aa()
p=m.aV(b)
o=q[p]
if(o==null)q[p]=[m.ab(b,c)]
else{n=m.aW(o,b)
if(n>=0)o[n].b=c
else o.push(m.ab(b,c))}}},
Y(a){var s=this
if(s.a>0){s.b=s.c=s.d=s.e=s.f=null
s.a=0
s.aB()}},
H(a,b){var s=this,r=s.e,q=s.r
while(r!=null){b.$2(r.a,r.b)
if(q!==s.r)throw A.a(A.ad(s))
r=r.c}},
ap(a,b,c){var s=a[b]
if(s==null)a[b]=this.ab(b,c)
else s.b=c},
aB(){this.r=this.r+1&1073741823},
ab(a,b){var s=this,r=new A.cJ(a,b)
if(s.e==null)s.e=s.f=r
else s.f=s.f.c=r;++s.a
s.aB()
return r},
aV(a){return J.Z(a)&1073741823},
bl(a,b){return a[this.aV(b)]},
aW(a,b){var s,r
if(a==null)return-1
s=a.length
for(r=0;r<s;++r)if(J.C(a[r].a,b))return r
return-1},
h(a){return A.eg(this)},
aa(){var s=Object.create(null)
s["<non-identifier-key>"]=s
delete s["<non-identifier-key>"]
return s}}
A.cJ.prototype={}
A.ag.prototype={
gl(a){return this.a.a},
gA(a){var s=this.a
return new A.bN(s,s.r,s.e)},
G(a,b){return this.a.B(b)}}
A.bN.prototype={
gn(){return this.d},
m(){var s,r=this,q=r.a
if(r.b!==q.r)throw A.a(A.ad(q))
s=r.c
if(s==null){r.d=null
return!1}else{r.d=s.a
r.c=s.c
return!0}}}
A.b_.prototype={
gl(a){return this.a.a},
gA(a){var s=this.a
return new A.aZ(s,s.r,s.e)}}
A.aZ.prototype={
gn(){return this.d},
m(){var s,r=this,q=r.a
if(r.b!==q.r)throw A.a(A.ad(q))
s=r.c
if(s==null){r.d=null
return!1}else{r.d=s.b
r.c=s.c
return!0}}}
A.dW.prototype={
$1(a){return this.a(a)},
$S:8}
A.dX.prototype={
$2(a,b){return this.a(a,b)},
$S:9}
A.dY.prototype={
$1(a){return this.a(a)},
$S:10}
A.bk.prototype={
h(a){return this.aG(!1)},
aG(a){var s,r,q,p,o,n=this.bj(),m=this.aA(),l=(a?"Record ":"")+"("
for(s=n.length,r="",q=0;q<s;++q,r=", "){l+=r
p=n[q]
if(typeof p=="string")l=l+p+": "
o=m[q]
l=a?l+A.f9(o):l+A.i(o)}l+=")"
return l.charCodeAt(0)==0?l:l},
bj(){var s,r=this.$s
while($.dj.length<=r)$.dj.push(null)
s=$.dj[r]
if(s==null){s=this.bf()
$.dj[r]=s}return s},
bf(){var s,r,q,p=this.$r,o=p.indexOf("("),n=p.substring(1,o),m=p.substring(o),l=m==="()"?0:m.replace(/[^,]/g,"").length+1,k=A.l(new Array(l),t.f)
for(s=0;s<l;++s)k[s]=s
if(n!==""){r=n.split(",")
s=r.length
for(q=l;s>0;){--q;--s
k[q]=r[s]}}k=A.hO(k,!1,t.K)
k.$flags=3
return k}}
A.ci.prototype={
aA(){return[this.a,this.b]},
F(a,b){if(b==null)return!1
return b instanceof A.ci&&this.$s===b.$s&&J.C(this.a,b.a)&&J.C(this.b,b.b)},
gp(a){return A.hR(this.$s,this.a,this.b,B.h)}}
A.cF.prototype={
h(a){return"RegExp/"+this.a+"/"+this.b.flags},
gbq(){var s=this,r=s.c
if(r!=null)return r
r=s.b
return s.c=A.f3(s.a,r.multiline,!r.ignoreCase,r.unicode,r.dotAll,"g")},
bi(a,b){var s,r=this.gbq()
r.lastIndex=b
s=r.exec(a)
if(s==null)return null
return new A.ch(s)}}
A.ch.prototype={
gbG(){var s=this.b
return s.index+s[0].length},
k(a,b){return this.b[b]},
$icM:1,
$iei:1}
A.d_.prototype={
gn(){var s=this.d
return s==null?t.F.a(s):s},
m(){var s,r,q,p,o,n,m=this,l=m.b
if(l==null)return!1
s=m.c
r=l.length
if(s<=r){q=m.a
p=q.bi(l,s)
if(p!=null){m.d=p
o=p.gbG()
if(p.b.index===o){s=!1
if(q.b.unicode){q=m.c
n=q+1
if(n<r){r=l.charCodeAt(q)
if(r>=55296&&r<=56319){s=l.charCodeAt(n)
s=s>=56320&&s<=57343}}}o=(s?o+1:o)+1}m.c=o
return!0}}m.b=m.d=null
return!1}}
A.as.prototype={
gt(a){return B.a4},
$ij:1}
A.b3.prototype={
bo(a,b,c,d){var s=A.E(b,0,c,d,null)
throw A.a(s)},
au(a,b,c,d){if(b>>>0!==b||b>c)this.bo(a,b,c,d)}}
A.bO.prototype={
gt(a){return B.a5},
$ij:1}
A.at.prototype={
gl(a){return a.length},
$iD:1}
A.b1.prototype={
k(a,b){A.X(b,a,a.length)
return a[b]},
q(a,b,c){a.$flags&2&&A.M(a)
A.X(b,a,a.length)
a[b]=c},
$ic:1,
$if:1}
A.b2.prototype={
q(a,b,c){a.$flags&2&&A.M(a)
A.X(b,a,a.length)
a[b]=c},
b7(a,b,c,d,e){var s,r,q
a.$flags&2&&A.M(a,5)
s=a.length
this.au(a,b,s,"start")
this.au(a,c,s,"end")
if(b>c)A.ap(A.E(b,0,c,null,null))
r=c-b
if(e<0)A.ap(A.R(e,null))
if(16-e<r)A.ap(A.ek("Not enough elements"))
q=e!==0||16!==r?d.subarray(e,e+r):d
a.set(q,b)
return},
$ic:1,
$if:1}
A.bP.prototype={
gt(a){return B.a6},
$ij:1}
A.bQ.prototype={
gt(a){return B.a7},
$ij:1}
A.bR.prototype={
gt(a){return B.a8},
k(a,b){A.X(b,a,a.length)
return a[b]},
$ij:1}
A.bS.prototype={
gt(a){return B.a9},
k(a,b){A.X(b,a,a.length)
return a[b]},
$ij:1}
A.bT.prototype={
gt(a){return B.aa},
k(a,b){A.X(b,a,a.length)
return a[b]},
$ij:1}
A.bU.prototype={
gt(a){return B.ac},
k(a,b){A.X(b,a,a.length)
return a[b]},
$ij:1}
A.bV.prototype={
gt(a){return B.ad},
k(a,b){A.X(b,a,a.length)
return a[b]},
$ij:1}
A.b4.prototype={
gt(a){return B.ae},
gl(a){return a.length},
k(a,b){A.X(b,a,a.length)
return a[b]},
$ij:1}
A.b5.prototype={
gt(a){return B.af},
gl(a){return a.length},
k(a,b){A.X(b,a,a.length)
return a[b]},
$ij:1}
A.bg.prototype={}
A.bh.prototype={}
A.bi.prototype={}
A.bj.prototype={}
A.K.prototype={
j(a){return A.bq(v.typeUniverse,this,a)},
D(a){return A.ft(v.typeUniverse,this,a)}}
A.cc.prototype={}
A.du.prototype={
h(a){return A.F(this.a,null)}}
A.cb.prototype={
h(a){return this.a}}
A.bm.prototype={$iU:1}
A.d1.prototype={
$1(a){var s=this.a,r=s.a
s.a=null
r.$0()},
$S:5}
A.d0.prototype={
$1(a){var s,r
this.a.a=a
s=this.b
r=this.c
s.firstChild?s.removeChild(r):s.appendChild(r)},
$S:11}
A.d2.prototype={
$0(){this.a.$0()},
$S:2}
A.d3.prototype={
$0(){this.a.$0()},
$S:2}
A.ds.prototype={
bc(a,b){if(self.setTimeout!=null)self.setTimeout(A.aG(new A.dt(this,b),0),a)
else throw A.a(A.c4("`setTimeout()` not found."))}}
A.dt.prototype={
$0(){this.b.$0()},
$S:0}
A.c7.prototype={
ae(a){var s,r=this
if(a==null)a=r.$ti.c.a(a)
if(!r.b)r.a.aq(a)
else{s=r.a
if(r.$ti.j("Q<1>").b(a))s.ar(a)
else s.av(a)}},
af(a,b){var s=this.a
if(this.b)s.a5(new A.I(a,b))
else s.a4(new A.I(a,b))}}
A.dG.prototype={
$1(a){return this.a.$2(0,a)},
$S:3}
A.dH.prototype={
$2(a,b){this.a.$2(1,new A.aR(a,b))},
$S:12}
A.dQ.prototype={
$2(a,b){this.a(a,b)},
$S:13}
A.I.prototype={
h(a){return A.i(this.a)},
$im:1,
gN(){return this.b}}
A.c9.prototype={
af(a,b){var s=this.a
if((s.a&30)!==0)throw A.a(A.ek("Future already completed"))
s.a4(A.ja(a,b))},
aJ(a){return this.af(a,null)}}
A.bd.prototype={
ae(a){var s=this.a
if((s.a&30)!==0)throw A.a(A.ek("Future already completed"))
s.aq(a)}}
A.aA.prototype={
bN(a){if((this.c&15)!==6)return!0
return this.b.b.am(this.d,a.a)},
bK(a){var s,r=this.e,q=null,p=a.a,o=this.b.b
if(t.Q.b(r))q=o.bS(r,p,a.b)
else q=o.am(r,p)
try{p=q
return p}catch(s){if(t._.b(A.aq(s))){if((this.c&1)!==0)throw A.a(A.R("The error handler of Future.then must return a value of the returned future's type","onError"))
throw A.a(A.R("The error handler of Future.catchError must return a value of the future's type","onError"))}else throw s}}}
A.w.prototype={
an(a,b,c){var s,r,q=$.q
if(q===B.d){if(b!=null&&!t.Q.b(b)&&!t.v.b(b))throw A.a(A.eU(b,"onError",u.c))}else if(b!=null)b=A.js(b,q)
s=new A.w(q,c.j("w<0>"))
r=b==null?1:3
this.a3(new A.aA(s,r,a,b,this.$ti.j("@<1>").D(c).j("aA<1,2>")))
return s},
bW(a,b){return this.an(a,null,b)},
aF(a,b,c){var s=new A.w($.q,c.j("w<0>"))
this.a3(new A.aA(s,19,a,b,this.$ti.j("@<1>").D(c).j("aA<1,2>")))
return s},
bu(a){this.a=this.a&1|16
this.c=a},
S(a){this.a=a.a&30|this.a&1
this.c=a.c},
a3(a){var s=this,r=s.a
if(r<=3){a.a=s.c
s.c=a}else{if((r&4)!==0){r=s.c
if((r.a&24)===0){r.a3(a)
return}s.S(r)}A.cp(null,null,s.b,new A.d6(s,a))}},
aC(a){var s,r,q,p,o,n=this,m={}
m.a=a
if(a==null)return
s=n.a
if(s<=3){r=n.c
n.c=a
if(r!=null){q=a.a
for(p=a;q!=null;p=q,q=o)o=q.a
p.a=r}}else{if((s&4)!==0){s=n.c
if((s.a&24)===0){s.aC(a)
return}n.S(s)}m.a=n.V(a)
A.cp(null,null,n.b,new A.da(m,n))}},
U(){var s=this.c
this.c=null
return this.V(s)},
V(a){var s,r,q
for(s=a,r=null;s!=null;r=s,s=q){q=s.a
s.a=r}return r},
av(a){var s=this,r=s.U()
s.a=8
s.c=a
A.aB(s,r)},
be(a){var s,r,q=this
if((a.a&16)!==0){s=q.b===a.b
s=!(s||s)}else s=!1
if(s)return
r=q.U()
q.S(a)
A.aB(q,r)},
a5(a){var s=this.U()
this.bu(a)
A.aB(this,s)},
aq(a){if(this.$ti.j("Q<1>").b(a)){this.ar(a)
return}this.bd(a)},
bd(a){this.a^=2
A.cp(null,null,this.b,new A.d8(this,a))},
ar(a){A.em(a,this,!1)
return},
a4(a){this.a^=2
A.cp(null,null,this.b,new A.d7(this,a))},
$iQ:1}
A.d6.prototype={
$0(){A.aB(this.a,this.b)},
$S:0}
A.da.prototype={
$0(){A.aB(this.b,this.a.a)},
$S:0}
A.d9.prototype={
$0(){A.em(this.a.a,this.b,!0)},
$S:0}
A.d8.prototype={
$0(){this.a.av(this.b)},
$S:0}
A.d7.prototype={
$0(){this.a.a5(this.b)},
$S:0}
A.dd.prototype={
$0(){var s,r,q,p,o,n,m,l,k=this,j=null
try{q=k.a.a
j=q.b.b.bQ(q.d)}catch(p){s=A.aq(p)
r=A.aH(p)
if(k.c&&k.b.a.c.a===s){q=k.a
q.c=k.b.a.c}else{q=s
o=r
if(o==null)o=A.e9(q)
n=k.a
n.c=new A.I(q,o)
q=n}q.b=!0
return}if(j instanceof A.w&&(j.a&24)!==0){if((j.a&16)!==0){q=k.a
q.c=j.c
q.b=!0}return}if(j instanceof A.w){m=k.b.a
l=new A.w(m.b,m.$ti)
j.an(new A.de(l,m),new A.df(l),t.n)
q=k.a
q.c=l
q.b=!1}},
$S:0}
A.de.prototype={
$1(a){this.a.be(this.b)},
$S:5}
A.df.prototype={
$2(a,b){this.a.a5(new A.I(a,b))},
$S:14}
A.dc.prototype={
$0(){var s,r,q,p,o,n
try{q=this.a
p=q.a
q.c=p.b.b.am(p.d,this.b)}catch(o){s=A.aq(o)
r=A.aH(o)
q=s
p=r
if(p==null)p=A.e9(q)
n=this.a
n.c=new A.I(q,p)
n.b=!0}},
$S:0}
A.db.prototype={
$0(){var s,r,q,p,o,n,m,l=this
try{s=l.a.a.c
p=l.b
if(p.a.bN(s)&&p.a.e!=null){p.c=p.a.bK(s)
p.b=!1}}catch(o){r=A.aq(o)
q=A.aH(o)
p=l.a.a.c
if(p.a===r){n=l.b
n.c=p
p=n}else{p=r
n=q
if(n==null)n=A.e9(p)
m=l.b
m.c=new A.I(p,n)
p=m}p.b=!0}},
$S:0}
A.c8.prototype={}
A.cl.prototype={}
A.dE.prototype={}
A.dk.prototype={
bU(a){var s,r,q
try{if(B.d===$.q){a.$0()
return}A.fO(null,null,this,a)}catch(q){s=A.aq(q)
r=A.aH(q)
A.eG(s,r)}},
bC(a){return new A.dl(this,a)},
bR(a){if($.q===B.d)return a.$0()
return A.fO(null,null,this,a)},
bQ(a){return this.bR(a,t.z)},
bV(a,b){if($.q===B.d)return a.$1(b)
return A.ju(null,null,this,a,b)},
am(a,b){var s=t.z
return this.bV(a,b,s,s)},
bT(a,b,c){if($.q===B.d)return a.$2(b,c)
return A.jt(null,null,this,a,b,c)},
bS(a,b,c){var s=t.z
return this.bT(a,b,c,s,s,s)},
bP(a){return a},
b0(a){var s=t.z
return this.bP(a,s,s,s)}}
A.dl.prototype={
$0(){return this.a.bU(this.b)},
$S:0}
A.dO.prototype={
$0(){A.hC(this.a,this.b)},
$S:0}
A.e.prototype={
gA(a){return new A.ar(a,this.gl(a),A.aI(a).j("ar<e.E>"))},
E(a,b){return this.k(a,b)},
X(a,b){return new A.S(a,A.aI(a).j("@<e.E>").D(b).j("S<1,2>"))},
bH(a,b,c,d){var s
A.b8(b,c,this.gl(a))
for(s=b;s<c;++s)this.q(a,s,d)},
h(a){return A.ec(a,"[","]")},
$ic:1,
$if:1}
A.T.prototype={
H(a,b){var s,r,q,p
for(s=this.gJ(),s=s.gA(s),r=A.Y(this).j("T.V");s.m();){q=s.gn()
p=this.k(0,q)
b.$2(q,p==null?r.a(p):p)}},
B(a){return this.gJ().G(0,a)},
gl(a){var s=this.gJ()
return s.gl(s)},
h(a){return A.eg(this)},
$iz:1}
A.cL.prototype={
$2(a,b){var s,r=this.a
if(!r.a)this.b.a+=", "
r.a=!1
r=this.b
s=A.i(a)
r.a=(r.a+=s)+": "
s=A.i(b)
r.a+=s},
$S:15}
A.cn.prototype={
q(a,b,c){throw A.a(A.c4("Cannot modify unmodifiable map"))}}
A.b0.prototype={
k(a,b){return this.a.k(0,b)},
q(a,b,c){this.a.q(0,b,c)},
B(a){return this.a.B(a)},
gl(a){var s=this.a
return s.gl(s)},
h(a){return this.a.h(0)},
$iz:1}
A.ay.prototype={}
A.av.prototype={
h(a){return A.ec(this,"{","}")},
E(a,b){var s,r
A.eh(b,"index")
s=this.gA(this)
for(r=b;s.m();){if(r===0)return s.gn();--r}throw A.a(A.eb(b,b-r,this,"index"))},
$ic:1}
A.br.prototype={}
A.cd.prototype={
k(a,b){var s,r=this.b
if(r==null)return this.c.k(0,b)
else if(typeof b!="string")return null
else{s=r[b]
return typeof s=="undefined"?this.bs(b):s}},
gl(a){return this.b==null?this.c.a:this.O().length},
gJ(){if(this.b==null){var s=this.c
return new A.ag(s,A.Y(s).j("ag<1>"))}return new A.ce(this)},
q(a,b,c){var s,r,q=this
if(q.b==null)q.c.q(0,b,c)
else if(q.B(b)){s=q.b
s[b]=c
r=q.a
if(r==null?s!=null:r!==s)r[b]=null}else q.by().q(0,b,c)},
B(a){if(this.b==null)return this.c.B(a)
return Object.prototype.hasOwnProperty.call(this.a,a)},
H(a,b){var s,r,q,p,o=this
if(o.b==null)return o.c.H(0,b)
s=o.O()
for(r=0;r<s.length;++r){q=s[r]
p=o.b[q]
if(typeof p=="undefined"){p=A.dI(o.a[q])
o.b[q]=p}b.$2(q,p)
if(s!==o.c)throw A.a(A.ad(o))}},
O(){var s=this.c
if(s==null)s=this.c=A.l(Object.keys(this.a),t.s)
return s},
by(){var s,r,q,p,o,n=this
if(n.b==null)return n.c
s=A.ef(t.N,t.z)
r=n.O()
for(q=0;p=r.length,q<p;++q){o=r[q]
s.q(0,o,n.k(0,o))}if(p===0)r.push("")
else B.c.Y(r)
n.a=n.b=null
return n.c=s},
bs(a){var s
if(!Object.prototype.hasOwnProperty.call(this.a,a))return null
s=A.dI(this.a[a])
return this.b[a]=s}}
A.ce.prototype={
gl(a){return this.a.gl(0)},
E(a,b){var s=this.a
return s.b==null?s.gJ().E(0,b):s.O()[b]},
gA(a){var s=this.a
if(s.b==null){s=s.gJ()
s=s.gA(s)}else{s=s.O()
s=new J.O(s,s.length,A.W(s).j("O<1>"))}return s},
G(a,b){return this.a.B(b)}}
A.dB.prototype={
$0(){var s,r
try{s=new TextDecoder("utf-8",{fatal:true})
return s}catch(r){}return null},
$S:6}
A.dA.prototype={
$0(){var s,r
try{s=new TextDecoder("utf-8",{fatal:false})
return s}catch(r){}return null},
$S:6}
A.cs.prototype={
bO(a0,a1,a2){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a="Invalid base64 encoding length "
a2=A.b8(a1,a2,a0.length)
s=$.hg()
for(r=a1,q=r,p=null,o=-1,n=-1,m=0;r<a2;r=l){l=r+1
k=a0.charCodeAt(r)
if(k===37){j=l+2
if(j<=a2){i=A.dV(a0.charCodeAt(l))
h=A.dV(a0.charCodeAt(l+1))
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
if(k===61)continue}k=g}if(f!==-2){if(p==null){p=new A.A("")
e=p}else e=p
e.a+=B.a.i(a0,q,r)
d=A.a3(k)
e.a+=d
q=l
continue}}throw A.a(A.y("Invalid base64 data",a0,r))}if(p!=null){e=B.a.i(a0,q,a2)
e=p.a+=e
d=e.length
if(o>=0)A.eV(a0,n,a2,o,m,d)
else{c=B.b.a1(d-1,4)+1
if(c===1)throw A.a(A.y(a,a0,a2))
while(c<4){e+="="
p.a=e;++c}}e=p.a
return B.a.M(a0,a1,a2,e.charCodeAt(0)==0?e:e)}b=a2-a1
if(o>=0)A.eV(a0,n,a2,o,m,b)
else{c=B.b.a1(b,4)
if(c===1)throw A.a(A.y(a,a0,a2))
if(c>1)a0=B.a.M(a0,a2,a2,c===2?"==":"=")}return a0}}
A.ct.prototype={}
A.bD.prototype={}
A.bF.prototype={}
A.cx.prototype={}
A.cA.prototype={
h(a){return"unknown"}}
A.cz.prototype={
R(a){var s=this.aw(a,0,a.length)
return s==null?a:s},
aw(a,b,c){var s,r,q,p
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
default:q=null}if(q!=null){if(r==null)r=new A.A("")
if(s>b)r.a+=B.a.i(a,b,s)
r.a+=q
b=s+1}}if(r==null)return null
if(c>b){p=B.a.i(a,b,c)
r.a+=p}p=r.a
return p.charCodeAt(0)==0?p:p}}
A.cH.prototype={
bD(a,b){var s=A.jq(a,this.gbF().a)
return s},
gbF(){return B.D}}
A.cI.prototype={}
A.cX.prototype={}
A.cZ.prototype={
R(a){var s,r,q,p=A.b8(0,null,a.length)
if(p===0)return new Uint8Array(0)
s=p*3
r=new Uint8Array(s)
q=new A.dC(r)
if(q.bk(a,0,p)!==p)q.ad()
return new Uint8Array(r.subarray(0,A.iW(0,q.b,s)))}}
A.dC.prototype={
ad(){var s=this,r=s.c,q=s.b,p=s.b=q+1
r.$flags&2&&A.M(r)
r[q]=239
q=s.b=p+1
r[p]=191
s.b=q+1
r[q]=189},
bz(a,b){var s,r,q,p,o=this
if((b&64512)===56320){s=65536+((a&1023)<<10)|b&1023
r=o.c
q=o.b
p=o.b=q+1
r.$flags&2&&A.M(r)
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
r&2&&A.M(s)
s[n]=o}else{n=o&64512
if(n===55296){if(k.b+4>q)break
m=p+1
if(k.bz(o,a.charCodeAt(m)))p=m}else if(n===56320){if(k.b+3>q)break
k.ad()}else if(o<=2047){n=k.b
l=n+1
if(l>=q)break
k.b=l
r&2&&A.M(s)
s[n]=o>>>6|192
k.b=l+1
s[l]=o&63|128}else{n=k.b
if(n+2>=q)break
l=k.b=n+1
r&2&&A.M(s)
s[n]=o>>>12|224
n=k.b=l+1
s[l]=o>>>6&63|128
k.b=n+1
s[n]=o&63|128}}}return p}}
A.cY.prototype={
R(a){return new A.dz(this.a).bh(a,0,null,!0)}}
A.dz.prototype={
bh(a,b,c,d){var s,r,q,p,o,n,m=this,l=A.b8(b,c,J.aL(a))
if(b===l)return""
if(a instanceof Uint8Array){s=a
r=s
q=0}else{r=A.iJ(a,b,l)
l-=b
q=b
b=0}if(l-b>=15){p=m.a
o=A.iI(p,r,b,l)
if(o!=null){if(!p)return o
if(o.indexOf("\ufffd")<0)return o}}o=m.a6(r,b,l,!0)
p=m.b
if((p&1)!==0){n=A.iK(p)
m.b=0
throw A.a(A.y(n,a,q+m.c))}return o},
a6(a,b,c,d){var s,r,q=this
if(c-b>1000){s=B.b.bw(b+c,2)
r=q.a6(a,b,s,!1)
if((q.b&1)!==0)return r
return r+q.a6(a,s,c,d)}return q.bE(a,b,c,d)},
bE(a,b,c,d){var s,r,q,p,o,n,m,l=this,k=65533,j=l.b,i=l.c,h=new A.A(""),g=b+1,f=a[b]
A:for(s=l.a;;){for(;;g=p){r="AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAFFFFFFFFFFFFFFFFGGGGGGGGGGGGGGGGHHHHHHHHHHHHHHHHHHHHHHHHHHHIHHHJEEBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBKCCCCCCCCCCCCDCLONNNMEEEEEEEEEEE".charCodeAt(f)&31
i=j<=32?f&61694>>>r:(f&63|i<<6)>>>0
j=" \x000:XECCCCCN:lDb \x000:XECCCCCNvlDb \x000:XECCCCCN:lDb AAAAA\x00\x00\x00\x00\x00AAAAA00000AAAAA:::::AAAAAGG000AAAAA00KKKAAAAAG::::AAAAA:IIIIAAAAA000\x800AAAAA\x00\x00\x00\x00 AAAAA".charCodeAt(j+r)
if(j===0){q=A.a3(i)
h.a+=q
if(g===c)break A
break}else if((j&1)!==0){if(s)switch(j){case 69:case 67:q=A.a3(k)
h.a+=q
break
case 65:q=A.a3(k)
h.a+=q;--g
break
default:q=A.a3(k)
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
break}p=n}if(o-g<20)for(m=g;m<o;++m){q=A.a3(a[m])
h.a+=q}else{q=A.fe(a,g,o)
h.a+=q}if(o===c)break A
g=p}else g=p}if(d&&j>32)if(s){s=A.a3(k)
h.a+=s}else{l.b=77
l.c=c
return""}l.b=j
l.c=i
s=h.a
return s.charCodeAt(0)==0?s:s}}
A.dy.prototype={
$2(a,b){var s,r
if(typeof b=="string")this.a.set(a,b)
else if(b==null)this.a.set(a,"")
else for(s=J.aK(b),r=this.a;s.m();){b=s.gn()
if(typeof b=="string")r.append(a,b)
else if(b==null)r.append(a,"")
else A.fF(b)}},
$S:7}
A.d4.prototype={
h(a){return this.az()}}
A.m.prototype={
gN(){return A.hS(this)}}
A.bz.prototype={
h(a){var s=this.a
if(s!=null)return"Assertion failed: "+A.cy(s)
return"Assertion failed"}}
A.U.prototype={}
A.H.prototype={
ga9(){return"Invalid argument"+(!this.a?"(s)":"")},
ga8(){return""},
h(a){var s=this,r=s.c,q=r==null?"":" ("+r+")",p=s.d,o=p==null?"":": "+A.i(p),n=s.ga9()+q+o
if(!s.a)return n
return n+s.ga8()+": "+A.cy(s.gai())},
gai(){return this.b}}
A.b7.prototype={
gai(){return this.b},
ga9(){return"RangeError"},
ga8(){var s,r=this.e,q=this.f
if(r==null)s=q!=null?": Not less than or equal to "+A.i(q):""
else if(q==null)s=": Not greater than or equal to "+A.i(r)
else if(q>r)s=": Not in inclusive range "+A.i(r)+".."+A.i(q)
else s=q<r?": Valid value range is empty":": Only valid value is "+A.i(r)
return s}}
A.bG.prototype={
gai(){return this.b},
ga9(){return"RangeError"},
ga8(){if(this.b<0)return": index must not be negative"
var s=this.f
if(s===0)return": no indices are valid"
return": index should be less than "+s},
gl(a){return this.f}}
A.bc.prototype={
h(a){return"Unsupported operation: "+this.a}}
A.c1.prototype={
h(a){return"UnimplementedError: "+this.a}}
A.bb.prototype={
h(a){return"Bad state: "+this.a}}
A.bE.prototype={
h(a){var s=this.a
if(s==null)return"Concurrent modification during iteration."
return"Concurrent modification during iteration: "+A.cy(s)+"."}}
A.bX.prototype={
h(a){return"Out of Memory"},
gN(){return null},
$im:1}
A.ba.prototype={
h(a){return"Stack Overflow"},
gN(){return null},
$im:1}
A.d5.prototype={
h(a){return"Exception: "+this.a}}
A.P.prototype={
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
k=""}return g+l+B.a.i(e,i,j)+k+"\n"+B.a.b5(" ",f-i+l.length)+"^\n"}else return f!=null?g+(" (at offset "+A.i(f)+")"):g}}
A.o.prototype={
X(a,b){return A.hu(this,A.Y(this).j("o.E"),b)},
gl(a){var s,r=this.gA(this)
for(s=0;r.m();)++s
return s},
E(a,b){var s,r
A.eh(b,"index")
s=this.gA(this)
for(r=b;s.m();){if(r===0)return s.gn();--r}throw A.a(A.eb(b,b-r,this,"index"))},
h(a){return A.hJ(this,"(",")")}}
A.t.prototype={
gp(a){return A.k.prototype.gp.call(this,0)},
h(a){return"null"}}
A.k.prototype={$ik:1,
F(a,b){return this===b},
gp(a){return A.bZ(this)},
h(a){return"Instance of '"+A.c_(this)+"'"},
gt(a){return A.jO(this)},
toString(){return this.h(this)}}
A.cm.prototype={
h(a){return""},
$ia4:1}
A.A.prototype={
gl(a){return this.a.length},
h(a){var s=this.a
return s.charCodeAt(0)==0?s:s}}
A.cW.prototype={
$2(a,b){var s,r,q,p=B.a.aU(b,"=")
if(p===-1){if(b!=="")a.q(0,A.et(b,0,b.length,this.a,!0),"")}else if(p!==0){s=B.a.i(b,0,p)
r=B.a.I(b,p+1)
q=this.a
a.q(0,A.et(s,0,s.length,q,!0),A.et(r,0,r.length,q,!0))}return a},
$S:16}
A.cV.prototype={
$2(a,b){throw A.a(A.y("Illegal IPv6 address, "+a,this.a,b))},
$S:17}
A.bs.prototype={
gW(){var s,r,q,p,o=this,n=o.w
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
gp(a){var s,r=this,q=r.y
if(q===$){s=B.a.gp(r.gW())
r.y!==$&&A.cr()
r.y=s
q=s}return q},
gL(){var s,r=this,q=r.z
if(q===$){s=r.f
s=A.fj(s==null?"":s)
r.z!==$&&A.cr()
q=r.z=new A.ay(s,t.h)}return q},
gb3(){return this.b},
gah(){var s=this.c
if(s==null)return""
if(B.a.v(s,"[")&&!B.a.u(s,"v",1))return B.a.i(s,1,s.length-1)
return s},
ga0(){var s=this.d
return s==null?A.fu(this.a):s},
gak(){var s=this.f
return s==null?"":s},
gaM(){var s=this.r
return s==null?"":s},
al(a){var s,r,q,p,o=this,n=o.a,m=n==="file",l=o.b,k=o.d,j=o.c
if(!(j!=null))j=l.length!==0||k!=null||m?"":null
s=o.e
if(!m)r=j!=null&&s.length!==0
else r=!0
if(r&&!B.a.v(s,"/"))s="/"+s
q=s
p=A.er(null,0,0,a)
return A.ep(n,l,j,k,q,p,o.r)},
gaX(){if(this.a!==""){var s=this.r
s=(s==null?"":s)===""}else s=!1
return s},
gaP(){return this.c!=null},
gaS(){return this.f!=null},
gaQ(){return this.r!=null},
h(a){return this.gW()},
F(a,b){var s,r,q,p=this
if(b==null)return!1
if(p===b)return!0
s=!1
if(t.R.b(b))if(p.a===b.ga2())if(p.c!=null===b.gaP())if(p.b===b.gb3())if(p.gah()===b.gah())if(p.ga0()===b.ga0())if(p.e===b.ga_()){r=p.f
q=r==null
if(!q===b.gaS()){if(q)r=""
if(r===b.gak()){r=p.r
q=r==null
if(!q===b.gaQ()){s=q?"":r
s=s===b.gaM()}}}}return s},
$ic5:1,
ga2(){return this.a},
ga_(){return this.e}}
A.dx.prototype={
$2(a,b){var s=this.b,r=this.a
s.a+=r.a
r.a="&"
r=A.eu(1,a,B.e,!0)
r=s.a+=r
if(b!=null&&b.length!==0){s.a=r+"="
r=A.eu(1,b,B.e,!0)
s.a+=r}},
$S:18}
A.dw.prototype={
$2(a,b){var s,r
if(b==null||typeof b=="string")this.a.$2(a,b)
else for(s=J.aK(b),r=this.a;s.m();)r.$2(a,s.gn())},
$S:7}
A.cU.prototype={
gb2(){var s,r,q,p,o=this,n=null,m=o.c
if(m==null){m=o.a
s=o.b[0]+1
r=B.a.Z(m,"?",s)
q=m.length
if(r>=0){p=A.bt(m,r+1,q,256,!1,!1)
q=r}else p=n
m=o.c=new A.ca("data","",n,n,A.bt(m,s,q,128,!1,!1),p,n)}return m},
h(a){var s=this.a
return this.b[0]===-1?"data:"+s:s}}
A.ck.prototype={
gaP(){return this.c>0},
gaR(){return this.c>0&&this.d+1<this.e},
gaS(){return this.f<this.r},
gaQ(){return this.r<this.a.length},
gaX(){return this.b>0&&this.r>=this.a.length},
ga2(){var s=this.w
return s==null?this.w=this.bg():s},
bg(){var s,r=this,q=r.b
if(q<=0)return""
s=q===4
if(s&&B.a.v(r.a,"http"))return"http"
if(q===5&&B.a.v(r.a,"https"))return"https"
if(s&&B.a.v(r.a,"file"))return"file"
if(q===7&&B.a.v(r.a,"package"))return"package"
return B.a.i(r.a,0,q)},
gb3(){var s=this.c,r=this.b+3
return s>r?B.a.i(this.a,r,s-1):""},
gah(){var s=this.c
return s>0?B.a.i(this.a,s,this.d):""},
ga0(){var s,r=this
if(r.gaR())return A.jX(B.a.i(r.a,r.d+1,r.e))
s=r.b
if(s===4&&B.a.v(r.a,"http"))return 80
if(s===5&&B.a.v(r.a,"https"))return 443
return 0},
ga_(){return B.a.i(this.a,this.e,this.f)},
gak(){var s=this.f,r=this.r
return s<r?B.a.i(this.a,s+1,r):""},
gaM(){var s=this.r,r=this.a
return s<r.length?B.a.I(r,s+1):""},
gL(){if(this.f>=this.r)return B.a0
return new A.ay(A.fj(this.gak()),t.h)},
al(a){var s,r,q,p,o,n=this,m=null,l=n.ga2(),k=l==="file",j=n.c,i=j>0?B.a.i(n.a,n.b+3,j):"",h=n.gaR()?n.ga0():m
j=n.c
if(j>0)s=B.a.i(n.a,j,n.d)
else s=i.length!==0||h!=null||k?"":m
j=n.a
r=B.a.i(j,n.e,n.f)
if(!k)q=s!=null&&r.length!==0
else q=!0
if(q&&!B.a.v(r,"/"))r="/"+r
p=A.er(m,0,0,a)
q=n.r
o=q<j.length?B.a.I(j,q+1):m
return A.ep(l,i,s,h,r,p,o)},
gp(a){var s=this.x
return s==null?this.x=B.a.gp(this.a):s},
F(a,b){if(b==null)return!1
if(this===b)return!0
return t.R.b(b)&&this.a===b.h(0)},
h(a){return this.a},
$ic5:1}
A.ca.prototype={}
A.cN.prototype={
h(a){return"Promise was rejected with a value of `"+(this.a?"undefined":"null")+"`."}}
A.e5.prototype={
$1(a){return this.a.ae(a)},
$S:3}
A.e6.prototype={
$1(a){if(a==null)return this.a.aJ(new A.cN(a===undefined))
return this.a.aJ(a)},
$S:3}
A.n.prototype={
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
A.B.prototype={
az(){return"_MatchPosition."+this.b}}
A.cB.prototype={
aL(a){var s,r,q,p,o,n,m,l,k,j,i
if(a.length===0)return A.l([],t.M)
s=a.toLowerCase()
r=A.l([],t.r)
for(q=this.a,p=q.length,o=s.length>1,n="dart:"+s,m=0;m<q.length;q.length===p||(0,A.aa)(q),++m){l=q[m]
k=new A.cE(r,l)
j=l.a.toLowerCase()
i=l.b.toLowerCase()
if(j===s||i===s||j===n)k.$1(B.ah)
else if(o)if(B.a.v(j,s)||B.a.v(i,s))k.$1(B.ai)
else if(B.a.G(j,s)||B.a.G(i,s))k.$1(B.aj)}B.c.b9(r,new A.cC())
q=t.V
q=A.cK(new A.ah(r,new A.cD(),q),q.j("J.E"))
return q}}
A.cE.prototype={
$1(a){this.a.push(new A.cj(this.b,a))},
$S:19}
A.cC.prototype={
$2(a,b){var s,r,q=a.b.a-b.b.a
if(q!==0)return q
s=a.a
r=b.a
q=s.c-r.c
if(q!==0)return q
q=s.gaD()-r.gaD()
if(q!==0)return q
q=s.f-r.f
if(q!==0)return q
return s.a.length-r.a.length},
$S:20}
A.cD.prototype={
$1(a){return a.a},
$S:21}
A.x.prototype={
gaD(){var s=0
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
A.cw.prototype={}
A.e_.prototype={
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
q=new A.dZ(p,r,q)
if(typeof q=="function")A.ap(A.R("Attempting to rewrap a JS function.",null))
n=function(b,c){return function(){return b(c)}}(A.iU,q)
n[$.e7()]=q
p.a=s.setTimeout(n,2000)},
$S:1}
A.dZ.prototype={
$0(){this.b.textContent="content_copy"
this.c.classList.remove("copied")
this.a.a=null},
$S:2}
A.dP.prototype={
$1(a){return J.C(v.G.document.activeElement,a)||J.aL(a.value)!==0},
$S:22}
A.cg.prototype={
bB(){var s,r,q,p,o,n,m=this
for(s=m.a,r=s.length,q=0;q<s.length;s.length===r||(0,A.aa)(s),++q)m.br(s[q])
if(m.b.length!==0){p=A.L(m.gbm())
$.eH=p
v.G.document.addEventListener("keydown",p)}if(A.fS(A.az(J.a_(v.G.window.location),0,null),s))m.a7()
else if(s.length!==0){o=m.f=A.L(new A.di(m))
for(r=s.length,q=0;q<s.length;s.length===r||(0,A.aa)(s),++q){n=s[q]
n.addEventListener("focus",o)
n.addEventListener("input",o)}}},
br(a){var s
a.disabled=!1
a.placeholder="Search API Docs"
a.setAttribute("autocomplete","off")
a.setAttribute("spellcheck","false")
a.classList.add("tt-input")
A.fG(a)
s=a.form
if(s!=null)s.addEventListener("submit",A.L(new A.dh(this,a)))},
bn(a){var s,r
if(!J.C(a.key,"/"))return
s=v.G.document.activeElement
if(s!=null&&B.a3.G(0,s.nodeName.toLowerCase()))return
a.preventDefault()
r=A.jw(this.b)
if(r!=null)r.focus()
this.a7()},
a7(){var s,r,q,p,o=this,n=o.f
if(n!=null){o.f=null
for(s=o.a,r=s.length,q=0;q<s.length;s.length===r||(0,A.aa)(s),++q){p=s[q]
p.removeEventListener("focus",n)
p.removeEventListener("input",n)}}if(o.e==null)o.e=o.T()},
T(){var s=0,r=A.eF(t.n),q,p=2,o=[],n=this,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9
var $async$T=A.eK(function(b0,b1){if(b0===1){o.push(b1)
s=p}for(;;)switch(s){case 0:a8=null
p=4
s=7
return A.dF(n.c.$0(),$async$T)
case 7:m=b1
if(m!=null){l=J.hp(t.j.a(B.x.bD(m,null)),t.a)
k=l.$ti.j("ah<e.E,x>")
k=A.cK(new A.ah(l,A.k3(),k),k.j("J.E"))
a8=new A.cB(k)}p=2
s=6
break
case 4:p=3
a9=o.pop()
a8=null
s=6
break
case 3:s=2
break
case 6:if(a8==null){A.k1("Could not activate search functionality.")
for(k=n.a,i=k.length,h=0;h<k.length;k.length===i||(0,A.aa)(k),++h)k[h].placeholder="Failed to initialize search"
s=1
break}n.r=!0
k=v.G
g=A.az(J.a_(k.window.location),0,null).gL().k(0,"search")
if(g!=null){i=A.f2(a8.aL(g))
f=i==null?null:i.e
if(f!=null){n.d.$1(A.bv()+f)
s=1
break}}for(i=n.a,e=i.length,d=n.d,c=t.O,b=t.M,h=0;h<i.length;i.length===e||(0,A.aa)(i),++h){a=i[h]
a0=a8
a1=A.l([],c)
a2=A.l([],b)
a3=A.az(k.window.location.href,0,null)
a2=new A.dm(a0,a3,d,a1,a2)
a.disabled=!1
a.setAttribute("placeholder","Search API Docs")
a.setAttribute("autocomplete","off")
a.setAttribute("spellcheck","false")
a.classList.add("tt-input")
a4=A.fG(a)
a1=a4.querySelector('.tt-menu[role="listbox"]')
if(a1!=null)a1.remove()
a0=a2.gK()
a4.appendChild(a0)
a2.b6(a)
if(B.a.aK(a3.ga_(),"search.html")&&a3.gL().B("q")){a5=a3.gL().k(0,"q")
a6=a5!=null
if(a6){a7=B.j.aw(a5,0,a5.length)
a5=a7==null?a5:a7
$.eJ=$.cq
a2.bL(a5,!0)
a2.b8(a5)
a0.style.display="none"
a0.setAttribute("aria-expanded","false")
$.eJ=10}}else a6=!1
if(!a6&&J.aL(a.value)!==0&&J.C(k.document.activeElement,a))a2.aO(a.value,!0)}case 1:return A.ez(q,r)
case 2:return A.ey(o.at(-1),r)}})
return A.eA($async$T,r)}}
A.di.prototype={
$1(a){this.a.a7()},
$S:1}
A.dh.prototype={
$1(a){var s,r
a.preventDefault()
s=this.a
if(!s.r){r=this.b.value
s.d.$1(A.bv()+"search.html?q="+A.eu(1,r,B.e,!0))}},
$S:1}
A.dm.prototype={
gK(){var s,r=this,q=r.d
if(q===$){s=A.a0()
s.setAttribute("role","listbox")
s.setAttribute("aria-expanded","false")
s.style.display="none"
s.classList.add("tt-menu")
s.appendChild(r.gb_())
s.appendChild(r.gao())
r.d!==$&&A.cr()
r.d=s
q=s}return q},
gb_(){var s,r=this.e
if(r===$){s=A.a0()
s.classList.add("enter-search-message")
this.e!==$&&A.cr()
this.e=s
r=s}return r},
gao(){var s,r=this.f
if(r===$){s=A.a0()
s.classList.add("tt-search-results")
this.f!==$&&A.cr()
this.f=s
r=s}return r},
b8(a){var s,r,q,p,o=v.G,n=o.document.getElementById("dartdoc-main-content")
if(n==null)return
n.textContent=""
s=o.document.createElement("section")
s.classList.add("search-summary")
n.appendChild(s)
s=o.document.createElement("h2")
s.innerHTML="Search Results"
n.appendChild(s)
o=A.a0()
o.classList.add("search-summary")
o.innerHTML=""+$.cq+' results for "'+a+'"'
n.appendChild(o)
if($.a8.a!==0)for(o=new A.aZ($.a8,$.a8.r,$.a8.e);o.m();)n.appendChild(o.d)
else{r=A.a0()
r.classList.add("search-summary")
r.innerHTML='There was not a match for "'+a+'". Want to try searching from additional Dart-related sites? '
q=A.az("https://dart.dev/search?cx=011220921317074318178%3A_yy-tmb5t_i&ie=UTF-8&hl=en&q=",0,null).al(A.f5(["q",a],t.N,t.z))
p=A.ea()
p.setAttribute("href",q.gW())
p.textContent="Search on dart.dev."
r.appendChild(p)
n.appendChild(r)}},
aT(){var s=this.gK()
s.style.display="none"
s.setAttribute("aria-expanded","false")
return s},
b1(a,b,c){var s,r,q,p,o,n=this
n.y=A.l([],t.M)
s=n.x
B.c.Y(s)
$.a8.Y(0)
r=n.gao()
r.textContent=""
q=b.length
if(q===0){n.aT()
return}for(p=n.c,o=0;o<b.length;b.length===q||(0,A.aa)(b),++o)s.push(A.iX(a,b[o],p))
for(q=J.aK(c?new A.b_($.a8,A.Y($.a8).j("b_<2>")):s);q.m();)r.appendChild(q.gn())
n.y=b
n.z=-1
if(r.hasChildNodes()){r=n.gK()
r.style.display="block"
r.setAttribute("aria-expanded","true")}r=$.cq
r=r>10?'Press "Enter" key to see all '+r+" results":""
n.gb_().textContent=r},
bY(a,b){return this.b1(a,b,!1)},
ag(a,b,c){var s,r,q,p=this
if(p.w===a&&!b)return
if(a.length===0){p.w=""
$.cq=0
p.bY("",A.l([],t.M))
return}s=p.a.aL(a)
r=s.length
$.cq=r
q=$.eJ
if(r>q)s=B.c.ba(s,0,q)
p.w=a
p.b1(a,s,c)},
bL(a,b){return this.ag(a,!1,b)},
aO(a,b){return this.ag(a,b,!1)},
aN(a){return this.ag(a,!1,!1)},
aH(a){var s,r=this
r.z=-1
s=r.r
if(s!=null){a.value=s
r.r=null}r.aT()},
b6(a){var s=this
a.addEventListener("focus",A.L(new A.dn(s,a)))
a.addEventListener("blur",A.L(new A.dp(s,a)))
a.addEventListener("input",A.L(new A.dq(s,a)))
a.addEventListener("keydown",A.L(new A.dr(s,a)))}}
A.dn.prototype={
$1(a){this.a.aO(this.b.value,!0)},
$S:1}
A.dp.prototype={
$1(a){this.a.aH(this.b)},
$S:1}
A.dq.prototype={
$1(a){this.a.aN(this.b.value)},
$S:1}
A.dr.prototype={
$1(a){var s,r,q,p,o,n,m,l,k,j,i,h,g,f=this
if(!J.C(a.type,"keydown"))return
if(J.C(a.code,"Enter")){a.preventDefault()
s=f.a
r=s.z
if(r!==-1){q=s.x[r].getAttribute("data-href")
if(q!=null)s.c.$1(A.bv()+q)
return}else{p=B.j.R(s.w)
s.c.$1(A.az(A.bv()+"search.html",0,null).al(A.f5(["q",p],t.N,t.z)).gW())
return}}s=f.a
r=s.x
o=r.length-1
n=s.z
if(J.C(a.code,"ArrowUp")){m=s.z
if(m===-1)s.z=o
else s.z=m-1}else if(J.C(a.code,"ArrowDown")){m=s.z
if(m===o)s.z=-1
else s.z=m+1}else if(J.C(a.code,"Escape"))s.aH(f.b)
else{if(s.r!=null){s.r=null
s.aN(f.b.value)}return}m=n!==-1
if(m)r[n].classList.remove("tt-cursor")
l=s.z
if(l!==-1){k=r[l]
k.classList.add("tt-cursor")
r=s.z
if(r===0)s.gK().scrollTop=0
else if(r===o){r=s.gK()
r.scrollTop=r.scrollHeight}else{j=k.offsetTop
i=s.gK().offsetHeight
if(j<i||i<j+k.offsetHeight)k.scrollIntoView()}if(s.r==null)s.r=f.b.value
f.b.value=s.y[s.z].a}else{h=s.r
if(h!=null){r=m
g=h}else{g=null
r=!1}if(r){f.b.value=g
s.r=null}}a.preventDefault()},
$S:1}
A.dJ.prototype={
$1(a){a.preventDefault()},
$S:1}
A.dK.prototype={
$1(a){var s=this.a.e
if(s!=null){this.b.$1(A.bv()+s)
a.preventDefault()}},
$S:1}
A.dL.prototype={
$1(a){return"<strong class='tt-highlight'>"+A.i(a.k(0,0))+"</strong>"},
$S:24}
A.dM.prototype={
$1(a){var s=this.a
if(s!=null)s.classList.toggle("active")
s=this.b
if(s!=null)s.classList.toggle("active")},
$S:1}
A.dN.prototype={
$1(a){return this.b4(a)},
b4(a){var s=0,r=A.eF(t.P),q,p=this,o,n,m
var $async$$1=A.eK(function(b,c){if(b===1)return A.ey(c,r)
for(;;)switch(s){case 0:if(!J.C(a.status,200)){o=A.ea()
o.href="https://dart.dev/tools/dart-doc#troubleshoot"
o.text="Failed to load sidebar. Visit dart.dev for help troubleshooting."
p.a.appendChild(o)
s=1
break}s=3
return A.dF(A.e4(a.text(),t.N),$async$$1)
case 3:n=c
m=A.a0()
m.innerHTML=n
A.fU(p.b,m)
p.a.appendChild(m)
case 1:return A.ez(q,r)}})
return A.eA($async$$1,r)},
$S:25}
A.e1.prototype={
$1(a){var s=this.a,r=v.G
if(a){s.classList.remove("light-theme")
s.classList.add("dark-theme")
r.window.localStorage.setItem("colorTheme","true")}else{s.classList.remove("dark-theme")
s.classList.add("light-theme")
r.window.localStorage.setItem("colorTheme","false")}},
$S:26}
A.e0.prototype={
$1(a){this.b.$1(!this.a.classList.contains("dark-theme"))},
$S:1};(function aliases(){var s=J.a2.prototype
s.bb=s.h})();(function installTearOffs(){var s=hunkHelpers._static_2,r=hunkHelpers._static_1,q=hunkHelpers._static_0,p=hunkHelpers._instance_1u
s(J,"jb","hN",27)
r(A,"jF","i6",4)
r(A,"jG","i7",4)
r(A,"jH","i8",4)
q(A,"fW","jz",0)
r(A,"k3","hF",28)
r(A,"k5","iY",29)
q(A,"k4","co",30)
p(A.cg.prototype,"gbm","bn",23)})();(function inheritance(){var s=hunkHelpers.mixin,r=hunkHelpers.inherit,q=hunkHelpers.inheritMany
r(A.k,null)
q(A.k,[A.ed,J.bH,A.b9,J.O,A.o,A.bB,A.m,A.e,A.cP,A.ar,A.bW,A.aS,A.c3,A.bk,A.aN,A.cf,A.av,A.cS,A.cO,A.aR,A.bl,A.ac,A.T,A.cJ,A.bN,A.aZ,A.cF,A.ch,A.d_,A.K,A.cc,A.du,A.ds,A.c7,A.I,A.c9,A.aA,A.w,A.c8,A.cl,A.dE,A.cn,A.b0,A.bD,A.bF,A.cA,A.dC,A.dz,A.d4,A.bX,A.ba,A.d5,A.P,A.t,A.cm,A.A,A.bs,A.cU,A.ck,A.cN,A.cB,A.x,A.cw,A.cg,A.dm])
q(J.bH,[J.bJ,J.aU,J.aX,J.aW,J.aY,J.aV,J.ae])
q(J.aX,[J.a2,J.p,A.as,A.b3])
q(J.a2,[J.bY,J.aw,J.a1])
r(J.bI,A.b9)
r(J.cG,J.p)
q(J.aV,[J.aT,J.bK])
q(A.o,[A.a6,A.c,A.au])
q(A.a6,[A.ab,A.bu])
r(A.bf,A.ab)
r(A.be,A.bu)
r(A.S,A.be)
q(A.m,[A.bM,A.U,A.bL,A.c2,A.c0,A.cb,A.bz,A.H,A.bc,A.c1,A.bb,A.bE])
r(A.ax,A.e)
r(A.bC,A.ax)
q(A.c,[A.J,A.ag,A.b_])
q(A.J,[A.ah,A.ce])
r(A.ci,A.bk)
r(A.cj,A.ci)
r(A.aP,A.aN)
r(A.aO,A.av)
r(A.aQ,A.aO)
r(A.b6,A.U)
q(A.ac,[A.cu,A.cv,A.cR,A.dW,A.dY,A.d1,A.d0,A.dG,A.de,A.e5,A.e6,A.cE,A.cD,A.e_,A.dP,A.di,A.dh,A.dn,A.dp,A.dq,A.dr,A.dJ,A.dK,A.dL,A.dM,A.dN,A.e1,A.e0])
q(A.cR,[A.cQ,A.aM])
q(A.T,[A.af,A.cd])
q(A.cv,[A.dX,A.dH,A.dQ,A.df,A.cL,A.dy,A.cW,A.cV,A.dx,A.dw,A.cC])
q(A.b3,[A.bO,A.at])
q(A.at,[A.bg,A.bi])
r(A.bh,A.bg)
r(A.b1,A.bh)
r(A.bj,A.bi)
r(A.b2,A.bj)
q(A.b1,[A.bP,A.bQ])
q(A.b2,[A.bR,A.bS,A.bT,A.bU,A.bV,A.b4,A.b5])
r(A.bm,A.cb)
q(A.cu,[A.d2,A.d3,A.dt,A.d6,A.da,A.d9,A.d8,A.d7,A.dd,A.dc,A.db,A.dl,A.dO,A.dB,A.dA,A.dZ])
r(A.bd,A.c9)
r(A.dk,A.dE)
r(A.br,A.b0)
r(A.ay,A.br)
q(A.bD,[A.cs,A.cx,A.cH])
q(A.bF,[A.ct,A.cz,A.cI,A.cZ,A.cY])
r(A.cX,A.cx)
q(A.H,[A.b7,A.bG])
r(A.ca,A.bs)
q(A.d4,[A.n,A.B])
s(A.ax,A.c3)
s(A.bu,A.e)
s(A.bg,A.e)
s(A.bh,A.aS)
s(A.bi,A.e)
s(A.bj,A.aS)
s(A.br,A.cn)})()
var v={G:typeof self!="undefined"?self:globalThis,typeUniverse:{eC:new Map(),tR:{},eT:{},tPV:{},sEA:[]},mangledGlobalNames:{b:"int",r:"double",h_:"num",d:"String",al:"bool",t:"Null",f:"List",k:"Object",z:"Map",h:"JSObject"},mangledNames:{},types:["~()","t(h)","t()","~(@)","~(~())","t(@)","@()","~(d,@)","@(@)","@(@,d)","@(d)","t(~())","t(@,a4)","~(b,@)","t(k,a4)","~(k?,k?)","z<d,d>(z<d,d>,d)","0&(d,b?)","~(d,d?)","~(B)","b(+item,matchPosition(x,B),+item,matchPosition(x,B))","x(+item,matchPosition(x,B))","al(h)","~(h)","d(cM)","Q<t>(h)","~(al)","b(@,@)","x(z<d,@>)","~(d)","Q<d?>()"],interceptorsByTag:null,leafTags:null,arrayRti:Symbol("$ti"),rttc:{"2;item,matchPosition":(a,b)=>c=>c instanceof A.cj&&a.b(c.a)&&b.b(c.b)}}
A.iq(v.typeUniverse,JSON.parse('{"bY":"a2","aw":"a2","a1":"a2","kf":"as","bJ":{"al":[],"j":[]},"aU":{"t":[],"j":[]},"aX":{"h":[]},"a2":{"h":[]},"p":{"f":["1"],"c":["1"],"h":[]},"bI":{"b9":[]},"cG":{"p":["1"],"f":["1"],"c":["1"],"h":[]},"aV":{"r":[]},"aT":{"r":[],"b":[],"j":[]},"bK":{"r":[],"j":[]},"ae":{"d":[],"j":[]},"a6":{"o":["2"]},"ab":{"a6":["1","2"],"o":["2"],"o.E":"2"},"bf":{"ab":["1","2"],"a6":["1","2"],"c":["2"],"o":["2"],"o.E":"2"},"be":{"e":["2"],"f":["2"],"a6":["1","2"],"c":["2"],"o":["2"]},"S":{"be":["1","2"],"e":["2"],"f":["2"],"a6":["1","2"],"c":["2"],"o":["2"],"e.E":"2","o.E":"2"},"bM":{"m":[]},"bC":{"e":["b"],"f":["b"],"c":["b"],"e.E":"b"},"c":{"o":["1"]},"J":{"c":["1"],"o":["1"]},"ah":{"J":["2"],"c":["2"],"o":["2"],"o.E":"2","J.E":"2"},"au":{"o":["1"],"o.E":"1"},"ax":{"e":["1"],"f":["1"],"c":["1"]},"aN":{"z":["1","2"]},"aP":{"z":["1","2"]},"aO":{"av":["1"],"c":["1"]},"aQ":{"av":["1"],"c":["1"]},"b6":{"U":[],"m":[]},"bL":{"m":[]},"c2":{"m":[]},"bl":{"a4":[]},"c0":{"m":[]},"af":{"T":["1","2"],"z":["1","2"],"T.V":"2"},"ag":{"c":["1"],"o":["1"],"o.E":"1"},"b_":{"c":["1"],"o":["1"],"o.E":"1"},"ch":{"ei":[],"cM":[]},"as":{"h":[],"j":[]},"b3":{"h":[]},"bO":{"h":[],"j":[]},"at":{"D":["1"],"h":[]},"b1":{"e":["r"],"f":["r"],"D":["r"],"c":["r"],"h":[]},"b2":{"e":["b"],"f":["b"],"D":["b"],"c":["b"],"h":[]},"bP":{"e":["r"],"f":["r"],"D":["r"],"c":["r"],"h":[],"j":[],"e.E":"r"},"bQ":{"e":["r"],"f":["r"],"D":["r"],"c":["r"],"h":[],"j":[],"e.E":"r"},"bR":{"e":["b"],"f":["b"],"D":["b"],"c":["b"],"h":[],"j":[],"e.E":"b"},"bS":{"e":["b"],"f":["b"],"D":["b"],"c":["b"],"h":[],"j":[],"e.E":"b"},"bT":{"e":["b"],"f":["b"],"D":["b"],"c":["b"],"h":[],"j":[],"e.E":"b"},"bU":{"e":["b"],"f":["b"],"D":["b"],"c":["b"],"h":[],"j":[],"e.E":"b"},"bV":{"e":["b"],"f":["b"],"D":["b"],"c":["b"],"h":[],"j":[],"e.E":"b"},"b4":{"e":["b"],"f":["b"],"D":["b"],"c":["b"],"h":[],"j":[],"e.E":"b"},"b5":{"e":["b"],"f":["b"],"D":["b"],"c":["b"],"h":[],"j":[],"e.E":"b"},"cb":{"m":[]},"bm":{"U":[],"m":[]},"I":{"m":[]},"bd":{"c9":["1"]},"w":{"Q":["1"]},"e":{"f":["1"],"c":["1"]},"T":{"z":["1","2"]},"b0":{"z":["1","2"]},"ay":{"z":["1","2"]},"av":{"c":["1"]},"cd":{"T":["d","@"],"z":["d","@"],"T.V":"@"},"ce":{"J":["d"],"c":["d"],"o":["d"],"o.E":"d","J.E":"d"},"f":{"c":["1"]},"ei":{"cM":[]},"bz":{"m":[]},"U":{"m":[]},"H":{"m":[]},"b7":{"m":[]},"bG":{"m":[]},"bc":{"m":[]},"c1":{"m":[]},"bb":{"m":[]},"bE":{"m":[]},"bX":{"m":[]},"ba":{"m":[]},"cm":{"a4":[]},"bs":{"c5":[]},"ck":{"c5":[]},"ca":{"c5":[]},"hI":{"f":["b"],"c":["b"]},"i0":{"f":["b"],"c":["b"]},"i_":{"f":["b"],"c":["b"]},"hG":{"f":["b"],"c":["b"]},"hY":{"f":["b"],"c":["b"]},"hH":{"f":["b"],"c":["b"]},"hZ":{"f":["b"],"c":["b"]},"hD":{"f":["r"],"c":["r"]},"hE":{"f":["r"],"c":["r"]}}'))
A.ip(v.typeUniverse,JSON.parse('{"bW":1,"aS":1,"c3":1,"ax":1,"bu":2,"aN":2,"aO":1,"bN":1,"aZ":1,"at":1,"cl":1,"cn":2,"b0":2,"br":2,"bD":2,"bF":2}'))
var u={f:"\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\u03f6\x00\u0404\u03f4 \u03f4\u03f6\u01f6\u01f6\u03f6\u03fc\u01f4\u03ff\u03ff\u0584\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u05d4\u01f4\x00\u01f4\x00\u0504\u05c4\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u0400\x00\u0400\u0200\u03f7\u0200\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u03ff\u0200\u0200\u0200\u03f7\x00",c:"Error handler must accept one Object or one Object and a StackTrace as arguments, and return a value of the returned future's type"}
var t=(function rtii(){var s=A.by
return{U:s("c<@>"),C:s("m"),Z:s("ke"),M:s("p<x>"),O:s("p<h>"),f:s("p<k>"),r:s("p<+item,matchPosition(x,B)>"),s:s("p<d>"),b:s("p<@>"),t:s("p<b>"),o:s("p<h?>"),T:s("aU"),m:s("h"),g:s("a1"),p:s("D<@>"),j:s("f<@>"),a:s("z<d,@>"),V:s("ah<+item,matchPosition(x,B),x>"),l:s("au<h>"),P:s("t"),K:s("k"),L:s("kg"),d:s("+()"),F:s("ei"),k:s("a4"),N:s("d"),q:s("j"),_:s("U"),A:s("aw"),h:s("ay<d,d>"),R:s("c5"),c:s("w<@>"),y:s("al"),i:s("r"),z:s("@"),v:s("@(k)"),Q:s("@(k,a4)"),S:s("b"),W:s("Q<t>?"),B:s("h?"),X:s("k?"),u:s("d?"),e:s("al?"),I:s("r?"),w:s("b?"),x:s("h_?"),H:s("h_"),n:s("~")}})();(function constants(){var s=hunkHelpers.makeConstList
B.A=J.bH.prototype
B.c=J.p.prototype
B.b=J.aT.prototype
B.a=J.ae.prototype
B.B=J.a1.prototype
B.C=J.aX.prototype
B.n=A.b5.prototype
B.o=J.bY.prototype
B.i=J.aw.prototype
B.ak=new A.ct()
B.p=new A.cs()
B.al=new A.cA()
B.j=new A.cz()
B.k=function getTagFallback(o) {
  var s = Object.prototype.toString.call(o);
  return s.substring(8, s.length - 1);
}
B.q=function() {
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
B.w=function(getTagFallback) {
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
B.r=function(hooks) {
  if (typeof dartExperimentalFixupGetTag != "function") return hooks;
  hooks.getTag = dartExperimentalFixupGetTag(hooks.getTag);
}
B.v=function(hooks) {
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
B.u=function(hooks) {
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
B.t=function(hooks) {
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
B.l=function(hooks) { return hooks; }

B.x=new A.cH()
B.y=new A.bX()
B.h=new A.cP()
B.e=new A.cX()
B.z=new A.cZ()
B.d=new A.dk()
B.f=new A.cm()
B.D=new A.cI(null)
B.E=new A.n(0,"accessor")
B.F=new A.n(1,"constant")
B.Q=new A.n(2,"constructor")
B.U=new A.n(3,"class_")
B.V=new A.n(4,"dynamic")
B.W=new A.n(5,"enum_")
B.X=new A.n(6,"extension")
B.Y=new A.n(7,"extensionType")
B.Z=new A.n(8,"function")
B.a_=new A.n(9,"library")
B.G=new A.n(10,"method")
B.H=new A.n(11,"mixin")
B.I=new A.n(12,"never")
B.J=new A.n(13,"package")
B.K=new A.n(14,"parameter")
B.L=new A.n(15,"prefix")
B.M=new A.n(16,"property")
B.N=new A.n(17,"sdk")
B.O=new A.n(18,"topic")
B.P=new A.n(19,"topLevelConstant")
B.R=new A.n(20,"topLevelProperty")
B.S=new A.n(21,"typedef")
B.T=new A.n(22,"typeParameter")
B.m=s([B.E,B.F,B.Q,B.U,B.V,B.W,B.X,B.Y,B.Z,B.a_,B.G,B.H,B.I,B.J,B.K,B.L,B.M,B.N,B.O,B.P,B.R,B.S,B.T],A.by("p<n>"))
B.a1={}
B.a0=new A.aP(B.a1,[],A.by("aP<d,d>"))
B.a2={input:0,textarea:1}
B.a3=new A.aQ(B.a2,2,A.by("aQ<d>"))
B.a4=A.N("ka")
B.a5=A.N("kb")
B.a6=A.N("hD")
B.a7=A.N("hE")
B.a8=A.N("hG")
B.a9=A.N("hH")
B.aa=A.N("hI")
B.ab=A.N("k")
B.ac=A.N("hY")
B.ad=A.N("hZ")
B.ae=A.N("i_")
B.af=A.N("i0")
B.ag=new A.cY(!1)
B.ah=new A.B(0,"isExactly")
B.ai=new A.B(1,"startsWith")
B.aj=new A.B(2,"contains")})();(function staticFields(){$.dg=null
$.ak=A.l([],t.f)
$.f7=null
$.eY=null
$.eX=null
$.fY=null
$.fV=null
$.h2=null
$.dR=null
$.e2=null
$.eP=null
$.dj=A.l([],A.by("p<f<k>?>"))
$.aD=null
$.bw=null
$.bx=null
$.eE=!1
$.q=B.d
$.eH=null
$.eJ=10
$.cq=0
$.a8=A.ef(t.N,t.m)})();(function lazyInitializers(){var s=hunkHelpers.lazyFinal
s($,"kd","h5",()=>A.dU("_$dart_dartClosure"))
s($,"kc","e7",()=>A.dU("_$dart_dartClosure_dartJSInterop"))
s($,"kA","hm",()=>A.l([new J.bI()],A.by("p<b9>")))
s($,"ki","h6",()=>A.V(A.cT({
toString:function(){return"$receiver$"}})))
s($,"kj","h7",()=>A.V(A.cT({$method$:null,
toString:function(){return"$receiver$"}})))
s($,"kk","h8",()=>A.V(A.cT(null)))
s($,"kl","h9",()=>A.V(function(){var $argumentsExpr$="$arguments$"
try{null.$method$($argumentsExpr$)}catch(r){return r.message}}()))
s($,"ko","hc",()=>A.V(A.cT(void 0)))
s($,"kp","hd",()=>A.V(function(){var $argumentsExpr$="$arguments$"
try{(void 0).$method$($argumentsExpr$)}catch(r){return r.message}}()))
s($,"kn","hb",()=>A.V(A.ff(null)))
s($,"km","ha",()=>A.V(function(){try{null.$method$}catch(r){return r.message}}()))
s($,"kr","hf",()=>A.V(A.ff(void 0)))
s($,"kq","he",()=>A.V(function(){try{(void 0).$method$}catch(r){return r.message}}()))
s($,"ks","eS",()=>A.i5())
s($,"ky","hl",()=>A.hQ(4096))
s($,"kw","hj",()=>new A.dB().$0())
s($,"kx","hk",()=>new A.dA().$0())
s($,"kt","hg",()=>A.hP(A.j_(A.l([-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-1,-2,-2,-2,-2,-2,62,-2,62,-2,63,52,53,54,55,56,57,58,59,60,61,-2,-2,-2,-1,-2,-2,-2,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,-2,-2,-2,-2,63,-2,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,-2,-2,-2,-2,-2],t.t))))
s($,"ku","hh",()=>A.fb("^[\\-\\.0-9A-Z_a-z~]*$",!0))
s($,"kv","hi",()=>typeof URLSearchParams=="function")
s($,"kz","e8",()=>A.h0(B.ab))})();(function nativeSupport(){!function(){var s=function(a){var m={}
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
hunkHelpers.setOrUpdateInterceptorsByTag({ArrayBuffer:A.as,SharedArrayBuffer:A.as,ArrayBufferView:A.b3,DataView:A.bO,Float32Array:A.bP,Float64Array:A.bQ,Int16Array:A.bR,Int32Array:A.bS,Int8Array:A.bT,Uint16Array:A.bU,Uint32Array:A.bV,Uint8ClampedArray:A.b4,CanvasPixelArray:A.b4,Uint8Array:A.b5})
hunkHelpers.setOrUpdateLeafTags({ArrayBuffer:true,SharedArrayBuffer:true,ArrayBufferView:false,DataView:true,Float32Array:true,Float64Array:true,Int16Array:true,Int32Array:true,Int8Array:true,Uint16Array:true,Uint32Array:true,Uint8ClampedArray:true,CanvasPixelArray:true,Uint8Array:false})
A.at.$nativeSuperclassTag="ArrayBufferView"
A.bg.$nativeSuperclassTag="ArrayBufferView"
A.bh.$nativeSuperclassTag="ArrayBufferView"
A.b1.$nativeSuperclassTag="ArrayBufferView"
A.bi.$nativeSuperclassTag="ArrayBufferView"
A.bj.$nativeSuperclassTag="ArrayBufferView"
A.b2.$nativeSuperclassTag="ArrayBufferView"})()
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
var s=A.k_
if(typeof dartMainRunner==="function"){dartMainRunner(s,[])}else{s([])}})})()
//# sourceMappingURL=docs.dart.js.map
