(function () {
    function getFromHash(hash, regexp, body) {
        var match = hash.match(regexp);
        var result;
        if (match) {
            result = body ? body(match[1]) : match[1];
        }
        return [result, hash.replace(regexp, "")];
    }

    function getPackage(hash) {
        return getFromHash(hash, /^([^\/]+)\//, function (m) { return m.replace("-", "."); });
    }

    function getLibrary(hash) {
        return getFromHash(hash, /^([^@\.]+)/, function (m) { return m.replace("-", "."); });
    }

    function getClass(hash) {
        return getFromHash(hash, /^\.([^@]+)/);
    }

    function getFunction(hash) {
        return getFromHash(hash, /^@id_(.+)$/);
    }

    function getMethod(hash) {
        return getFromHash(hash, /^@id_(.+)$/, function (m) {
            // if it contains ',', we should discard everything after that,
            // that was probably named parameter arguments
            // if it ends with '-', it may be a constructor
            return m.replace(/,.*/, "").replace("-", "");
        });
    }

    var hash = location.hash.replace(/^#/, "");

    var packageResult = getPackage(hash);
    var packageName = packageResult[0];
    hash = packageResult[1];

    if (packageName && location.pathname.indexOf(packageName) !== -1) {
        var libraryResult = getLibrary(hash);
        var library = libraryResult[0];
        hash = libraryResult[1];

        if (library) {
            var classResult = getClass(hash);
            var className = classResult[0];
            hash = classResult[1];

            var method;
            var func;
            if (className) {
                method = getMethod(hash)[0];
            } else {
                func = getFunction(hash)[0];
            }

            var newPath;
            if (className) {
                if (method) {
                    newPath = "/" + library + "/" + className + "/" + method + ".html";
                } else {
                    newPath = "/" + library + "/" + className + "-class.html";
                }
            } else if (func) {
                newPath = "/" + library + "/" + func + ".html";
            } else {
                newPath = "/" + library + "/" + library + "-library.html";
            }

            var newLocation = location.href.replace(/\/index.html.*/, newPath);

            var http = new XMLHttpRequest();
            http.open('HEAD', newLocation);
            http.onreadystatechange = function () {
                if (this.readyState === this.DONE && this.status === 200) {
                    location.href = newLocation;
                }
            };
            http.send();
        }
    }
}());
