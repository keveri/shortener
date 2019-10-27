const api = {
    getShortUrl: getShortByToken,
    postShortUrl: postShort
};

const curry = function(f) {
    return function (a) {
        return function (b) {
            return f(a, b);
        };
    };
};

const showError = function (msg) {
    alert(msg);
};

const log = function (message, jsonData) {
    console.log(message + JSON.stringify(jsonData));
};

function printAndGetByToken(data) {
    log('Got response from API POST: ', data);
    api.getShortUrl(
        data.token,
        curry(log)('Got response from API GET: '),
        showError
    );
};
