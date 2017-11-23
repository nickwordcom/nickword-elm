/**
 * Wait for selector to appear before invoking related functions.
 */
var waitForElement = function (selector, fn, itemsList, tryCount) {
  tryCount = tryCount || 5;
  --tryCount;
  if (tryCount == 0) { return; }

  setTimeout(function() {
    var result = fn.call(null, selector, itemsList, tryCount);
    if (!result) {
      // Element still doesn't exist, so wait more time
      waitForElement(selector, fn, itemsList, tryCount);
    }
  }, 50);
}

module.exports = waitForElement;
